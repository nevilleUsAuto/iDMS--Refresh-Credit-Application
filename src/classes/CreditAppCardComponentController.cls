/****************************************************************************************************
 *
 * Moidifications:
 *
 *
 *
 *      20180422 -- NB -- Added validation for the minimun number of credit references on CA submit
 *      20180422 -- NB -- Added credit references entry on VFP
 *
 *
 ***************************************************************************************************/

public class CreditAppCardComponentController
{
    private static final String LOCATION_NAME_BDC = 'BDC';
    private static final Integer MINIMUM_CREDIT_REFERENCES = 4;

    @AuraEnabled
    public static SalesPortalAPIResponses.AdjustedScores getOnlineAppAdjustedScores(String creditApplicationSalesPortalId, String salesPortalAccessToken)
    {
        SalesPortalAPIResponses.OnlineApplicationAdjustedScores onlineCreditApplicationScores;

        try
        {
            onlineCreditApplicationScores = SalesPortalAPI.getOnlineApplicationsAdjustedScores(new List<String>{creditApplicationSalesPortalId}, salesPortalAccessToken, 120000)[0];
        }
        catch (Exception ex)
        {
            Utils.logException(ex);
            throw new AuraHandledException('Unable to load customers paying capacity from Sales Portal. You are not able to view it or send approval email.');
        }

        return onlineCreditApplicationScores.scoreData;
    }

    @AuraEnabled
    public static SalesPortalAPIResponses.RegularApplicationAdjustedScores getAdjustedScores(String creditApplicationSalesPortalId, String salesPortalAccessToken)
    {
        SalesPortalAPIResponses.RegularApplicationAdjustedScores adjustedScores;

        try
        {
            adjustedScores = SalesPortalAPI.getAdjustedCreditScores(new List<String>{creditApplicationSalesPortalId}, salesPortalAccessToken, 120000)[0];
        }
        catch (Exception ex)
        {
            Utils.logException(ex);
            throw new AuraHandledException('Unable to get adjusted scores from Sales Portal.');
        }

        return adjustedScores;
    }

    @AuraEnabled
    public static Attachment getCreditApplicationFile(Id creditApplicationId)
    {
        Attachment creditApplicationFile;

        if (String.isNotBlank(creditApplicationId))
        {
            List<Attachment> creditApplicationFiles = [
                    SELECT Name, ContentType
                    FROM Attachment
                    WHERE ParentId = :creditApplicationId
            ];

            if (!creditApplicationFiles.isEmpty())
            {
                creditApplicationFile = creditApplicationFiles[0];
            }
        }

        return creditApplicationFile;
    }

    @AuraEnabled
    public static Boolean sendApprovalEmail(String firstName, String email, Decimal maxFinanceAmount, String salesPortalAccessToken)
    {
        SalesPortalAPIRequests.SendApprovalEmailRequestBody requestBody = new SalesPortalAPIRequests.SendApprovalEmailRequestBody();
        requestBody.FirstName = firstName;
        requestBody.CustomerEmail = email;
        requestBody.MaxFinanceAmount = maxFinanceAmount;

        try
        {
            Boolean isSuccessful = SalesPortalAPI.sendApprovalEmail(JSON.serialize(requestBody), salesPortalAccessToken , 120000);

            return isSuccessful;
        }
        catch (Exception ex)
        {
            Utils.logException(ex);
            throw new AuraHandledException('Error occurred during email sending. Please notify your manager.');
        }
    }

    @AuraEnabled
    public static Credit_Application__c submit(Id creditApplicationId, Attachment creditApplicationFile, String fileType, String salesPortalAccessToken)
    {
        Credit_Application__c creditApplication;

        List<Credit_Application__c> creditApplications = [
                SELECT  Buyer__r.FirstName, Buyer__r.LastName, Buyer__r.MiddleName, Buyer__r.HomePhone,
                        Buyer__r.MobilePhone, Buyer__r.Email, Buyer__r.SocialSecurityNumber__c, Buyer__r.Birthdate,
                        Buyer__r.Driver_License_Number__c, Buyer__r.Driver_License_State__c, Buyer__r.Suffix__c, Buyer__r.SalesPortalId__c,
                        Buyer__r.Is_Military__c, Buyer__r.Military_Status__c, Buyer__r.Driver_License_Expiration_Date__c,
        
                        Co_Buyer__r.FirstName, Co_Buyer__r.LastName, Co_Buyer__r.MiddleName, Co_Buyer__r.HomePhone,
                        Co_Buyer__r.MobilePhone, Co_Buyer__r.Email, Co_Buyer__r.SocialSecurityNumber__c, Co_Buyer__r.Birthdate,
                        Co_Buyer__r.Driver_License_Number__c, Co_Buyer__r.Driver_License_State__c, Co_Buyer__r.Suffix__c,
                        Co_Buyer__r.Is_Military__c, Co_Buyer__r.Military_Status__c, Co_Buyer__r.Driver_License_Expiration_Date__c,
    
                        Opportunity__r.ISC__c, Opportunity__r.Referrer_Code__c,

                        (SELECT Is_Primary_Buyer__c, Is_Current_Residence__c, Housing_Type__c, House_Number__c, Home_Payment__c,
                            Address_Street__c, Address_Street_Type__c, Address_City__c, Address_State__c, Home_Address_2__c,
                            Address_Zip__c, Address_Duration_Months__c, Address_Duration_Years__c
                        FROM Residences__r
                        ORDER BY CreatedDate DESC
                        LIMIT 20),
                            
                        (SELECT Is_Primary_Buyer__c, Is_Current_Employment__c, Name, Employer_Street__c,
                            Employer_City__c, Employer_State__c, Employer_Zip__c, Employer_Name__c,
                            Occupation_Or_Rank__c, Employer_Phone__c, Employer_Duration_Months__c,
                            Employer_Duration_Years__c, Applicant_Net_Period_Paycheck__c, Salary_Type__c,
                            Other_Income__c
                        FROM Employments__r
                        ORDER BY CreatedDate DESC
                        LIMIT 20),
    
                        Car_Repossessed__c, Currently_in_bankruptcy__c, Ever_filed_Bankruptcy_or_Chapter_13__c, Repeat_Customer__c,
                        Repeat_Reason__c, Co_App_Repeat_Customer__c, Co_App_Repeat_Reason__c,
                        Previous_Account_Number__c, Co_App_Previous_Account_Number__c, Co_App_car_repossessed__c, Co_App_currently_in_bankruptcy__c,
                        Co_App_gone_through_bankruptcy__c, Ready_To_Submit__c,  Credit_Application_Status__c, Opportunity__c,
                        Credit_Application_Comment__c, Last_Comment_Left_By__c, Sales_Portal_ID__c, Owner.Name, Owner.Email,
                        Buyer__c, Co_Buyer__c, Co_Buyer__r.SalesPortalId__c,
                        Client_Ancestor__c, Store_Location__c, Store_Location__r.Name, Store_Location__r.SalesPortalId__c, Store_Location__r.State__c, Store_Location__r.StateCode__c,
                        Co_App_Available_Down_Payment__c, Available_Down_Payment__c
                FROM Credit_Application__c
                WHERE Id = :creditApplicationId
                LIMIT 1
        ];

        if (creditApplications.isEmpty())
        {
            throw new AuraHandledException('Credit application not found.');
        }
        else
        {
            creditApplication = creditApplications[0];
        }

        if (String.isBlank(creditApplication.Store_Location__c))
        {
            throw new AuraHandledException('Set store location on your Opportunity');
        }
        else if (creditApplication.Store_Location__r.Name == LOCATION_NAME_BDC)
        {
            User currentUser = [
                    SELECT Division
                    FROM User
                    WHERE Id = :UserInfo.getUserId()
            ];

            List<Location__c> userLocation = [
                    SELECT Id
                    FROM Location__c
                    WHERE Company_Number__c = :currentUser.Division
                    FOR UPDATE
            ];

            if (!userLocation.isEmpty())
            {
                creditApplication.Store_Location__c = userLocation[0].Id;
            }
        }

        if (creditApplication.Buyer__r.Driver_License_Expiration_Date__c < Date.today())
        {
            throw new AuraHandledException('Buyer\'s driver license expiration date is not valid.');
        }
        else if ((creditApplication.Co_Buyer__r.Driver_License_Expiration_Date__c != null) &&
                (creditApplication.Co_Buyer__r.Driver_License_Expiration_Date__c < Date.today()))
        {
            throw new AuraHandledException('Cobuyer\'s driver license expiration date is not valid.');
        }

        try
        {
            String requestBody = CreditApplicationWrapperGenerator.getCreditApplicationJSON(creditApplication, creditApplicationFile, fileType);

            SalesPortalAPIResponses.CreditScoreApplicationData creditApplicationSaveResult
                    = SalesPortalAPI.saveCreditScoreApplication(requestBody, salesPortalAccessToken, 120000);

            creditApplication.Sales_Portal_ID__c = String.valueOf(creditApplicationSaveResult.SPCreditAppID);
            creditApplication.Credit_Application_Status__c = SalesPortalUtils.salesPortalCreditApplicationStatusIdToValue.get(creditApplicationSaveResult.CreditScoreAppStatusID);

            if (creditApplication.Sales_Portal_Creation_Date__c == null)
            {
                creditApplication.Sales_Portal_Creation_Date__c = Date.today();
            }

            if (creditApplicationSaveResult.UploadedFileJson != null)
            {
                creditApplication.Document_Sales_Portal_Id__c = Decimal.valueOf(creditApplicationSaveResult.UploadedFileJson.FileGUID);
            }

            if (String.isNotBlank(creditApplication.Opportunity__r.ISC__c))
            {
                if (!creditApplication.Opportunity__r.ISC__c.equals(UserInfo.getUserId()))
                {
                    creditApplication.Opportunity__r.ISC__c = null;
                }
            }

            List<Schema.Contact> contactsToUpdate = new List<Schema.Contact>();

            if (String.isNotBlank(creditApplication.Buyer__c))
            {
                contactsToUpdate.add(new Schema.Contact(Id = creditApplication.Buyer__c, SalesPortalId__c = creditApplicationSaveResult.PrimaryBuyerApp.CustomerID));
            }

            if (String.isNotBlank(creditApplication.Co_Buyer__c))
            {
                contactsToUpdate.add(new Schema.Contact(Id = creditApplication.Co_Buyer__c, SalesPortalId__c = creditApplicationSaveResult.CoBuyerApp.CustomerID));
            }
            
            Opportunity parentOpportunity = creditApplication.Opportunity__r;

            update parentOpportunity;
            update creditApplication;
            update contactsToUpdate;
        }
        catch (Exception ex)
        {
            Utils.logException(ex);

            Map<String, String> salesPortalErrorMessageToSalesForceErrorMessage = new Map<String, String>
            {
                    'Invalid Update Of Verified Customer ID' => Label.Duplicate_Customer_SSN_Error_Message
            };

            for (String currentErrorMessageKey : salesPortalErrorMessageToSalesForceErrorMessage.keySet())
            {
                if ((ex.getMessage().containsIgnoreCase(currentErrorMessageKey)) && (ex.getMessage().containsIgnoreCase(creditApplication.Buyer__r.SocialSecurityNumber__c.remove('-'))))
                {
                    throw new AuraHandledException(salesPortalErrorMessageToSalesForceErrorMessage.get(currentErrorMessageKey));
                }
            }

            throw new AuraHandledException('Unable to submit credit application. ' + ex.getMessage());
        }

        return creditApplication;
    }

   @AuraEnabled
    public static void markCreditScoreLetterAsSent(boolean isJointScore, String creditApplicationSalesPortalId, String salesPortalAccessToken)
    {
        SalesPortalAPIRequests.PrintLetterRequestBody printLetterRequestBody = new SalesPortalAPIRequests.PrintLetterRequestBody();
        printLetterRequestBody.isJointScore = isJointScore;
        printLetterRequestBody.SFEmailCreatedBy = UserInfo.getUserEmail();
        printLetterRequestBody.SPCreditAppID = Integer.valueOf(creditApplicationSalesPortalId);

        try
        {
            SalesPortalAPI.printLetter(JSON.serialize(printLetterRequestBody), salesPortalAccessToken , 100000);
        }
        catch (Exception ex)
        {
            Utils.logException(ex);
            throw new AuraHandledException('Unable to print credit score letter.');
        }
    }

    @AuraEnabled
    public static Credit_Application__c sendDealForManagersApproval(Credit_Application__c creditApplication, Decimal tradeACV, Decimal tradePayoff, Decimal warrantyId, String salesPortalAccessToken)
    {
        SalesPortalAPIRequests.ManagersSubmitRequestWrapper sendDealForManagersApprovalRequestBody = new SalesPortalAPIRequests.ManagersSubmitRequestWrapper();
        sendDealForManagersApprovalRequestBody.SFEmailCreatedBy = UserInfo.getUserEmail();
        sendDealForManagersApprovalRequestBody.SPCreditAppID = Integer.valueOf(creditApplication.Sales_Portal_ID__c);
        sendDealForManagersApprovalRequestBody.TradeACV = tradeACV;
        sendDealForManagersApprovalRequestBody.TradePayoff = tradePayoff;
        sendDealForManagersApprovalRequestBody.WarrantyID = Integer.valueOf(warrantyId);

        try
        {
            SalesPortalAPIResponses.SubmitResult response = SalesPortalAPI.sendDealForManagersApproval(JSON.serialize(sendDealForManagersApprovalRequestBody), salesPortalAccessToken, 100000);

            creditApplication.Credit_Application_Status__c = SalesPortalUtils.salesPortalCreditApplicationStatusIdToValue.get(response.StatusID);

            update creditApplication;
        }
        catch (Exception ex)
        {
            Utils.logException(ex);
            throw new AuraHandledException('Unable to send deal for managers approval.');
        }

        return creditApplication;
    }

    @AuraEnabled
    public static void removeVehicle(Credit_Application__c creditApplication, String salesPortalAccessToken)
    {
        SalesPortalAPIRequests.CreditApplicationSubmitRequestWrapper removeVehicleRequestBody
                = new SalesPortalAPIRequests.CreditApplicationSubmitRequestWrapper();
        removeVehicleRequestBody.SFEmailCreatedBy = UserInfo.getUserEmail();
        removeVehicleRequestBody.SPCreditAppID = Integer.valueOf(creditApplication.Sales_Portal_ID__c);

        try
        {
            SalesPortalAPIResponses.SubmitResult response = SalesPortalAPI.removeVehicle(JSON.serialize(removeVehicleRequestBody), salesPortalAccessToken, 120000);

            creditApplication.Credit_Application_Status__c = SalesPortalUtils.salesPortalCreditApplicationStatusIdToValue.get(response.StatusID);

            update creditApplication;
        }
        catch (Exception ex)
        {
            Utils.logException(ex);
            throw new AuraHandledException('Unable to remove vehicle.');
        }
    }

    @AuraEnabled
    public static SalesPortalAPIResponses.DealDetails getDealDetails(String creditApplicationSalesPortalId, String salesPortalAccessToken)
    {
        SalesPortalAPIResponses.DealDetails dealDetails;

        try
        {
            dealDetails = SalesPortalAPI.getDealDetails(new List<String>{creditApplicationSalesPortalId}, salesPortalAccessToken, 120000)[0];
        }
        catch (Exception ex)
        {
            Utils.logException(ex);
            throw new AuraHandledException('Unable to get deal details from Sales Portal.');
        }

        return dealDetails;
    }

    @AuraEnabled
    public static void createTrafficLog(Id creditApplicationId, Id opportunityId, Id customerId, String logType)
    {
        Traffic_Log_Opportunity__c trafficLog = Utils.createTrafficLog(creditApplicationId, opportunityId, customerId, logType);

        insert trafficLog;
    }

    @AuraEnabled
    public static Integer getCurrentUserState()
    {
        Integer stateId = 0;
        List<User> currentUser = [SELECT Id, Location__c FROM User WHERE Id =:UserInfo.getUserId()];
        if(!currentUser.isEmpty() && currentUser.get(0).Location__c != null)
        {
            List<Location__c> currentUserLocation = [SELECT StateCode__c FROM Location__c WHERE Name = :currentUser.get(0).Location__c LIMIT 1];
            if (!currentUserLocation.isEmpty())
            {
                stateId = Integer.valueOf(currentUserLocation.get(0).StateCode__c);
            }
        }
        return stateId;
    }
}