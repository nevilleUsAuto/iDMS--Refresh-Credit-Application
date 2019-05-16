public with sharing class CreditAppEditComponentController
{
    private static final String CREDIT_APP_COMPLETED_LOG_TYPE = 'Credit App Completed';
    private static final Set<String> insideSalesAndBDCProfiles = new Set<String>{'ISC New', 'BDC Agent', 'BDC Manager New'};
    
    private static final Set<String> initialPaycallStatuses = new Set<String>{
        SalesPortalUtils.CREDIT_APP_STATUS_INITIAL_PAYCALL, SalesPortalUtils.CREDIT_APP_STATUS_LETTER_PRINTED
    };
    
    private static final Set<String> creditAppRequiredFields = new Set<String>{
        'Available_Down_Payment__c'
    };

    private static final Set<String> creditAppCoRequiredFields = new Set<String>{
        'Co_App_Available_Down_Payment__c'
    };

    private static final Set<String> emplotmentRequiredFields = new Set<String>{
        'Employer_Name__c', 'Employer_Phone__c', 'Employer_Street__c', 'Employer_Duration_Years__c','Employer_City__c',
        'Employer_State__c','Salary_Type__c','Employer_Zip__c','Applicant_Net_Period_Paycheck__c','Occupation_Or_Rank__c',
        'Employer_Duration_Months__c'
    };

    private static final Set<String> emplotmentPrevRequiredFields = new Set<String>{
        'Employer_Name__c', 'Employer_Duration_Years__c','Employer_Duration_Months__c'
    };

    private static final Set<String> residenceRequiredFields = new Set<String>{
        'Housing_Type__c','Address_State__c','House_Number__c','Address_Zip__c','Address_Street__c','Address_Duration_Years__c',
        'Address_Street_Type__c','Address_City__c','Home_Payment__c', 'Address_Duration_Months__c'
    };

    private static final Set<String> contactRequiredFields = new Set<String>{
        'Email','FirstName','Work_Phone__c','MobilePhone','LastName','Driver_License_State__c','Driver_License_Expiration_Date__c',
        'Driver_License_Number__c','Birthdate','HomePhone'
    };
    
    @AuraEnabled
    public static String getAllPicklistsByName()
    {
        List<PicklistItem> suffixPicklistValues = createPicklistValuesList(Contact.Suffix__c.getDescribe().getPickListValues());
        List<PicklistItem> licenseStatePicklistValues = createPicklistValuesList(Contact.Driver_License_State__c.getDescribe().getPickListValues());
        List<PicklistItem> housingTypePicklistValues = createPicklistValuesList(Residence__c.Housing_Type__c.getDescribe().getPickListValues());
        List<PicklistItem> currentStreetTypPicklistValues = createPicklistValuesList(Residence__c.Address_Street_Type__c.getDescribe().getPickListValues());
        List<PicklistItem> currentAddressStatePicklistValues = createPicklistValuesList(Residence__c.Address_State__c.getDescribe().getPickListValues());
        List<PicklistItem> currentAddressDurationYearsPicklistValues = createPicklistValuesList(Residence__c.Address_Duration_Years__c.getDescribe().getPickListValues());
        List<PicklistItem> currentAddressDurationMounthsPicklistValues = createPicklistValuesList(Residence__c.Address_Duration_Months__c.getDescribe().getPickListValues());
        List<PicklistItem> currentAddressDurationPicklistValues = createPicklistValuesList(Residence__c.Address_Duration_Years__c.getDescribe().getPickListValues());
        List<PicklistItem> presentEmployeerStatePicklistValues = createPicklistValuesList(Employment__c.Employer_State__c.getDescribe().getPickListValues());
        List<PicklistItem> presentEmployeerDurationYearsPicklistValues = createPicklistValuesList(Employment__c.Employer_Duration_Years__c.getDescribe().getPickListValues());
        List<PicklistItem> presentEmployeerDurationMounthsPicklistValues = createPicklistValuesList(Employment__c.Employer_Duration_Months__c.getDescribe().getPickListValues());
        List<PicklistItem> salaryTypePicklistValues = createPicklistValuesList(Employment__c.Salary_Type__c.getDescribe().getPickListValues());
        List<PicklistItem> militaryStatusPicklistValues = createPicklistValuesList(Schema.Contact.Military_Status__c.getDescribe().getPickListValues());
        List<PicklistItem> repeatCustomerPicklistValues = createPicklistValuesList(Credit_Application__c.Repeat_Customer__c.getDescribe().getPickListValues());
        List<PicklistItem> repeatReasonPicklistValues = createPicklistValuesList(Credit_Application__c.Repeat_Reason__c.getDescribe().getPickListValues());
        
        Map<String, List<PicklistItem>> picklistNameToValueSet = new Map<String, List<PicklistItem>>
        {
            'Suffix__c' => suffixPicklistValues,
            'Driver_License_State__c' => licenseStatePicklistValues,
            'Housing_Type__c' => housingTypePicklistValues,
            'Current_Street_Type__c' => currentStreetTypPicklistValues,
            'Current_Address_State__c' => currentAddressStatePicklistValues,
            'Current_Address_Duration_Years__c' => currentAddressDurationYearsPicklistValues,
            'Current_Address_Duration_Months__c' => currentAddressDurationMounthsPicklistValues,
            'Present_Employer_State__c' => presentEmployeerStatePicklistValues,
            'Present_Employer_Duration_Years__c' => presentEmployeerDurationYearsPicklistValues,
            'Present_Employer_Duration_Months__c' => presentEmployeerDurationMounthsPicklistValues,
            'Salary_Type__c' => salaryTypePicklistValues,
            'Military_Status__c' => militaryStatusPicklistValues,
            'Repeat_Customer__c' => repeatCustomerPicklistValues,
            'Repeat_Reason__c' => repeatReasonPicklistValues
        };
        
        return JSON.serialize(picklistNameToValueSet);
    }
    
    @AuraEnabled
    public static Object getCreditApplication(Id opportunityId)
    {
        List<Credit_Application__c> cas = [
            SELECT Id, Buyer__r.FirstName, Buyer__r.LastName, Buyer__r.HomePhone, Buyer__r.MobilePhone, Buyer__r.Email, Buyer__r.MiddleName, Buyer__r.Work_Phone__c,
                Buyer__r.SocialSecurityNumber__c, Buyer__r.Social_Security_Number_Sec__c, Buyer__r.Birthdate, Buyer__r.Driver_License_Number__c,
                Buyer__r.Driver_License_Expiration_Date__c, Buyer__r.Driver_License_State__c,
                Co_Buyer__r.FirstName, Co_Buyer__r.LastName, Co_Buyer__r.HomePhone, Co_Buyer__r.MobilePhone, Co_Buyer__r.Email, Co_Buyer__r.MiddleName, Co_Buyer__r.Work_Phone__c,
                Co_Buyer__r.SocialSecurityNumber__c, Co_Buyer__r.Social_Security_Number_Sec__c, Co_Buyer__r.Birthdate,
                Co_Buyer__r.Driver_License_Expiration_Date__c, Co_Buyer__r.Driver_License_Number__c, Co_Buyer__r.Driver_License_State__c,
            (SELECT Id, Is_Current_Residence__c, Housing_Type__c, House_Number__c, Address_Street__c, Address_Street_Type__c,
                Address_City__c, Address_State__c, Address_Zip__c, Home_Payment__c, Is_Primary_Buyer__c, Address_Duration_Years__c, Address_Duration_Months__c
            FROM Residences__r),
            (SELECT Id, FirstName, LastName, MailingPostalCode, MobilePhone, MailingCity, MailingStreet, Phone, MailingState
            FROM Contacts__r
            WHERE RecordType.Name = 'Reference'),
            (SELECT Id, Is_Current_Employment__c, Name, Employer_Name__c, Employer_Street__c, Employer_City__c, Employer_State__c, Employer_Zip__c,
                Occupation_Or_Rank__c, Employer_Phone__c, Salary_Type__c, Other_Income__c, Employer_Duration_Years__c,
                Employer_Duration_Months__c, Is_Primary_Buyer__c, Applicant_Net_Period_Paycheck__c
            FROM Employments__r),
                Available_Down_Payment__c, Co_App_Available_Down_Payment__c, Ever_Filed_Bankruptcy_or_Chapter_13__c,
                Car_Repossessed__c, Currently_in_bankruptcy__c, Buyer__r.Suffix__c,  Co_Buyer__r.Suffix__c, Repeat_Customer__c,
                Repeat_Reason__c, Co_App_Repeat_Customer__c, Co_App_Repeat_Reason__c, Co_App_car_repossessed__c,
                Co_App_Currently_In_Bankruptcy__c, Co_App_Gone_Through_Bankruptcy__c, Ready_To_Submit__c,
                Credit_Application_Comment__c, Opportunity__c, Opportunity__r.Referrer_code__c, Opportunity__r.AccountId,
                    Previous_Account_Number__c, Co_App_Previous_Account_Number__c, Buyer__r.Is_Military__c,
                    Buyer__r.Military_Status__c, Co_Buyer__r.Is_Military__c, Co_Buyer__r.Military_Status__c, Valid_Sections__c, Client_Ancestor__c,
                    Opportunity__r.StageName, CreatedDate, //NB: 2019-04-20 Added Portal Creation date, Is_Active
                    Credit_Application_Status__c, Sales_Portal_ID__c, Sales_Portal_Creation_Date__c, Is_Active__c
            FROM Credit_Application__c
            WHERE Opportunity__c = :opportunityId ORDER BY CreatedDate DESC  //NB: necessary order clause added
        ];

        Boolean updateCA = false;
        List<Opportunity> oppStageUpdate = new List<Opportunity>{
                new Opportunity( StageName = 'Qualify', Id = opportunityId)
        };
        //Set<String> stages = new Set<String>{'Qualify', 'Approval', 'Select Vehicle'};
        Set<String> caStatus = new Set<String>(); //{'Expired', 'Online App Declined', 'Delivered', 'Denied'}; //, 'Pending Verification'
        for (Credit_App_NonRenewal_Status__mdt cn : [SELECT MasterLabel FROM Credit_App_NonRenewal_Status__mdt]) {
            caStatus.add(cn.MasterLabel);
        }
        //Note: Make new CA if Pending Verification is greater than 30 days from the Sales Portal Created Date.  Otherwise, preserve as well.

        Boolean renewCreditApp = ( Date.valueOf(cas[0].CreatedDate).daysBetween(Date.today()) > 120 ? true : false);

        if ( renewCreditApp && !caStatus.contains(cas[0].Credit_Application_Status__c) ) {

            delete cas[0].Employments__r;
            delete cas[0].Contacts__r;  // these are references
            delete cas[0].Residences__r;

            // update buyer/CoBuyer contact information
            List<Contact> byr = new List<Contact>{
                    new Contact(
                            Id = cas[0].Buyer__c,
                            Driver_License_Expiration_Date__c = null,
                            Driver_License_Number__c = null,
                            Driver_License_State__c = null,
                            MobilePhone = null,
                            Work_Phone__c = null,
                            Phone = null,
                            HomePhone = null,
                            LastName = cas[0].Buyer__r.LastName,
                            FirstName = cas[0].Buyer__r.FirstName
                    )
            };

            // Co-Buyer
            if (cas[0].Co_Buyer__c != null) {
                byr.add(
                        new Contact(
                                Id = cas[0].Co_Buyer__c,
                                Driver_License_Expiration_Date__c = null,
                                Driver_License_Number__c = null,
                                Driver_License_State__c = null,
                                MobilePhone = null,
                                Work_Phone__c = null,
                                Phone = null,
                                HomePhone = null,
                                LastName = cas[0].Co_Buyer__r.LastName,
                                FirstName = cas[0].Co_Buyer__r.FirstName
                        )
                );
            }

            upsert byr;

            cas.add(
                    new Credit_Application__c(
                            Opportunity__c = opportunityId,
                            Buyer__c = cas[0].Buyer__c,
                            Buyer__r = byr[0],
                            Co_Buyer__c = cas[0].Co_Buyer__c, // okay if blank
                            Credit_Application_Status__c = 'In Progress'
                    )
            );

            delete cas[0];
            cas.remove(0);
            insert cas;

            updateCA = true;

        } else if (!cas[0].Is_Active__c && !caStatus.contains(cas[0].Credit_Application_Status__c) ) {
            cas[0].Credit_Application_Status__c = 'In Progress';
            cas[0].Sales_Portal_ID__c = '';
            cas[0].Sales_Portal_Creation_Date__c = null;
            //ca.Expiring_Date__c = Datetime.now().addDays(30); formula field -- Field is updated and should be included in the change set
            updateCA = true;
        }

        if (updateCA) {
            upsert cas;
            update oppStageUpdate;
        }

        CreditAppWrapper wrapper = new CreditAppWrapper();
        if (!cas.isEmpty())
        {
            wrapper.buyer = cas.get(0).Buyer__r == null ? new Schema.Contact() : cas.get(0).Buyer__r;
            wrapper.coBuyer = cas.get(0).Co_Buyer__r == null ? new Schema.Contact() : cas.get(0).Co_Buyer__r;
            wrapper.creditApplication = cas.get(0);
            wrapper.currentEmployment = new Employment__c();
            wrapper.previousEmployment = new Employment__c();
            wrapper.coAppCurrentEmployment = new Employment__c();
            wrapper.coAppPreviousEmployment = new Employment__c();
            wrapper.currentHousing = new Residence__c();
            wrapper.previousHousing = new Residence__c();
            wrapper.coAppCurrentHousing = new Residence__c();
            wrapper.coAppPreviousHousing = new Residence__c();
            wrapper.references = cas.get(0).Contacts__r == null ? new List<Schema.Contact>() : cas.get(0).Contacts__r;
            wrapper.removedReferences = new List<Schema.Contact>();
            wrapper.isPrevBuyerEmploymentDeleted = false;
            wrapper.isPrevBuyerHousingDeleted = false;
            wrapper.isPrevCoBuyerEmploymentDeleted = false;
            wrapper.isPrevCoBuyerHousingDeleted = false;
            
            for (Employment__c employment : cas.get(0).Employments__r)
            {
                if (employment.Is_Primary_Buyer__c && employment.Is_Current_Employment__c)
                {
                    wrapper.currentEmployment = employment;
                }
                else if (employment.Is_Primary_Buyer__c && !employment.Is_Current_Employment__c)
                {
                    wrapper.previousEmployment = employment;
                }
                else if (!employment.Is_Primary_Buyer__c && employment.Is_Current_Employment__c)
                {
                    wrapper.coAppCurrentEmployment = employment;
                }
                else
                {
                    wrapper.coAppPreviousEmployment = employment;
                }
            }
            for (Residence__c residence : cas.get(0).Residences__r)
            {
                if (residence.Is_Primary_Buyer__c && residence.Is_Current_Residence__c)
                {
                    wrapper.currentHousing = residence;
                }
                else if (residence.Is_Primary_Buyer__c && !residence.Is_Current_Residence__c)
                {
                    wrapper.previousHousing = residence;
                }
                else if (!residence.Is_Primary_Buyer__c && residence.Is_Current_Residence__c)
                {
                    wrapper.coAppCurrentHousing = residence;
                }
                else
                {
                    wrapper.coAppPreviousHousing = residence;
                }
            }
            
            validateWrapper(wrapper);

            return JSON.serialize(wrapper);
        }
        else
        {
            throw new AuraHandledException('Credit Application was not found!');
        }
    }
    
    @AuraEnabled
    public static List<Schema.Contact> getCustomers(Id buyerId, Id coBuyerId)
    {
        Set<Id> customerIds = new Set<Id>{buyerId, coBuyerId};
        
        Map<Id, Schema.Contact> customers = new Map<Id, Schema.Contact>([
            SELECT FirstName, LastName, SocialSecurityNumber__c,  Suffix__c, Email, HomePhone,
                MobilePhone, Driver_License_Number__c, Driver_License_Expiration_Date__c,
                Birthdate, Driver_License_State__c, Middle_Name__c
            FROM Contact
            WHERE Id In :customerIds
        ]);
        
        List<Schema.Contact> customerRetrieveResult = new List<Schema.Contact>();
        
        if (customers.size() == 0)
        {
            throw new AuraHandledException('No customers were found.');
        }
        else if (customers.size() == 1)
        {
            if (customers.values()[0].Id == coBuyerId)
            {
                throw new AuraHandledException('Buyer was not found.');
            }
            else {
                customerRetrieveResult.add(customers.values()[0]);
            }
        }
        else if (customers.size() == 2 )
        {
            customerRetrieveResult.add(customers.get(buyerId));
            customerRetrieveResult.add(customers.get(coBuyerId));
        }
        
        return customerRetrieveResult;
    }
    
    @AuraEnabled
    public static SearchResult getAccountsBySocialSecurityNumber(String coBuyerSocialSecurityNumber)
    {
        List<Schema.Contact> contacts = [
            SELECT FirstName, LastName, SocialSecurityNumber__c, Social_Security_Number_Sec__c,  Suffix__c, Email, Phone,
                MobilePhone, Driver_License_Number__c, Driver_License_Expiration_Date__c,
                Birthdate, Driver_License_State__c, Middle_Name__c
            FROM Contact
            WHERE SocialSecurityNumber__c =: coBuyerSocialSecurityNumber
        ];
        
        SearchResult result;
        
        if (contacts.isEmpty()) {
            Schema.Contact cobuyer = new Schema.Contact();
            cobuyer.SocialSecurityNumber__c = coBuyerSocialSecurityNumber;
            
            result = new SearchResult();
            
            result.coBuyer = cobuyer;
            result.coBuyerMessage = 'Social Security Number is unique. Please click Save to create Co-Buer and continue working.';
            result.canContinue = true;
        } else {
            result = searchActiveApplications(contacts[0].Id, coBuyerSocialSecurityNumber);
            result.coBuyer = contacts[0];
        }

        result.coBuyer.recalculateFormulas();

        return result;
    }
    
    @TestVisible
    private static SearchResult searchActiveApplications(Id coBuyerId, String coBuyerSocialSecurityNumber)
    {
        List<Credit_Application__c> salesforceActiveApplications = [
            SELECT Opportunity__c, Buyer__r.SocialSecurityNumber__c, Co_Buyer__r.SocialSecurityNumber__c
            FROM Credit_Application__c
            WHERE (Buyer__c = :coBuyerId
            OR Co_Buyer__c = :coBuyerId)
        ];
        
        SearchResult result = new SearchResult();
        
        if (!salesforceActiveApplications.isEmpty())
        {
            Credit_Application__c activeApplication = salesforceActiveApplications[0];
            
            if ((coBuyerSocialSecurityNumber != null) && (activeApplication.Co_Buyer__r.SocialSecurityNumber__c == coBuyerSocialSecurityNumber))
            {
                if (activeApplication.Opportunity__c != null)
                {
                    result.coBuyerMessage = Label.Co_Application_Was_Found_With_SalesUp;
                    result.coBuyerOpportunityId = activeApplication.Opportunity__c;
                    result.canContinue = false;
                }
                else
                {
                    result.coBuyerMessage = Label.Co_Application_Was_Found_Without_SalesUp;
                    result.canContinue = false;
                }
            }
            else if (activeApplication.Buyer__r.SocialSecurityNumber__c == coBuyerSocialSecurityNumber)
            {
                result.coBuyerMessage = Label.CoBuyer_Was_Found_As_Buyer;
                result.canContinue = false;
            }
        }
        else
        {
            result.coBuyerMessage = 'Co-Buyer was found. Click Save to retrive data from existing customer or retry search.';
            result.canContinue = true;
        }
        
        return result;
    }
    
    public class CreditAppWrapper
    {
        public Credit_Application__c creditApplication;
        public Schema.Contact buyer;
        public Schema.Contact coBuyer;
        public Residence__c currentHousing;
        public Residence__c previousHousing;
        public Employment__c currentEmployment;
        public Employment__c previousEmployment;
        public Residence__c coAppCurrentHousing;
        public Residence__c coAppPreviousHousing;
        public Employment__c coAppCurrentEmployment;
        public Employment__c coAppPreviousEmployment;
        public List<Schema.Contact> references;
        public List<Schema.Contact> removedReferences;
        public Boolean isPrevBuyerHousingDeleted;
        public Boolean isPrevCoBuyerHousingDeleted;
        public Boolean isPrevBuyerEmploymentDeleted;
        public Boolean isPrevCoBuyerEmploymentDeleted;
    }

    @AuraEnabled
    public static InvalidFieldsWrapper validateData(String wrapperJSON)
    {
        CreditAppWrapper wrapper;

        try
        {
            wrapper = (CreditAppWrapper) JSON.deserialize(wrapperJSON, CreditAppWrapper.class);
        }
        catch(Exception ex)
        {
            Utils.logException(ex);
            throw new AuraHandledException('Please review all required fields');
        }

        return validateWrapper(wrapper);
    }
    
    @AuraEnabled
    public static Id saveCreditApplication(String creditAppJSON, Boolean isReadyToSubmit)
    {
        CreditAppWrapper wrapper = (CreditAppWrapper)JSON.deserialize((String)creditAppJSON, CreditAppWrapper.class);
    
        if (initialPaycallStatuses.contains(wrapper.creditApplication.Credit_Application_Status__c))
        {
            reverseCreditApplicationToInProgress(wrapper.creditApplication);
        }
        
        if (isReadyToSubmit)
        {
            wrapper.creditApplication.Credit_Application_Status__c = 'In Progress';
            wrapper.creditApplication.Ready_To_Submit__c = true;

            saveShortCreditApp(wrapper);

            Traffic_Log_Opportunity__c trafficLog = Utils.createTrafficLog(wrapper.creditApplication.Id, wrapper.creditApplication.Opportunity__c,
                wrapper.creditApplication.Buyer__c, CREDIT_APP_COMPLETED_LOG_TYPE);
            insert trafficLog;
        }
        else
        {
            wrapper.creditApplication.Credit_Application_Status__c = 'In Progress';
            wrapper.creditApplication.Ready_To_Submit__c = false;
        }
        
        SavePoint beforeBuyersSave = Database.setSavepoint();
        List<Residence__c> residences = new List<Residence__c>();
        List<Employment__c> employments = new List<Employment__c>();
        List<SObject> recordsToDelete = new List<SObject>();
        
        try
        {
            List<Schema.Contact> customers = (wrapper.coBuyer == null) ? new List<Schema.Contact>{wrapper.buyer} : new List<Schema.Contact>{wrapper.buyer, wrapper.coBuyer};
            
            upsert customers;
            
            if (wrapper.coBuyer != null)
            {
                wrapper.creditApplication.Co_Buyer__c = wrapper.coBuyer.Id;
                wrapper.coBuyer.AccountId = wrapper.creditApplication.Opportunity__r.AccountId;
            }
           
            update wrapper.creditApplication;
    
            List<Attachment> creditApplicationAttachments = [
                SELECT Body, Name, ContentType
                FROM Attachment
                WHERE ParentId = :wrapper.creditApplication.Id
                LIMIT 1
            ];
    
            delete creditApplicationAttachments;
        }
        catch(Exception ex)
        {
            Database.rollback(beforeBuyersSave);
            System.debug(ex);
            throw new AuraHandledException(ex.getMessage());
        }
        
        try
        {
            if(wrapper.coAppCurrentHousing != null)
            {
                wrapper.coAppCurrentHousing.Is_Primary_Buyer__c = false;
                wrapper.coAppCurrentHousing.Is_Current_Residence__c = true;
                wrapper.coAppCurrentHousing.Credit_Application__c = wrapper.creditApplication.Id;
                residences.add(wrapper.coAppCurrentHousing);
            }
            
            if(wrapper.coAppPreviousHousing != null && !wrapper.isPrevCoBuyerHousingDeleted)
            {
                wrapper.coAppPreviousHousing.Is_Primary_Buyer__c = false;
                wrapper.coAppPreviousHousing.Is_Current_Residence__c = false;
                wrapper.coAppPreviousHousing.Credit_Application__c = wrapper.creditApplication.Id;
                residences.add(wrapper.coAppPreviousHousing);
            }
            else if(wrapper.coAppPreviousHousing != null && wrapper.coAppPreviousHousing.Id != null && wrapper.isPrevCoBuyerHousingDeleted)
            {
                recordsToDelete.add(wrapper.coAppPreviousHousing);
            }
            
            if(wrapper.coAppCurrentEmployment != null)
            {
                wrapper.coAppCurrentEmployment.Is_Primary_Buyer__c = false;
                wrapper.coAppCurrentEmployment.Is_Current_Employment__c = true;
                wrapper.coAppCurrentEmployment.Credit_Application__c = wrapper.creditApplication.Id;
                employments.add(wrapper.coAppCurrentEmployment);
            }
            
            if(wrapper.coAppPreviousEmployment != null && !wrapper.isPrevCoBuyerEmploymentDeleted)
            {
                wrapper.coAppPreviousEmployment.Is_Primary_Buyer__c = false;
                wrapper.coAppPreviousEmployment.Is_Current_Employment__c = false;
                wrapper.coAppPreviousEmployment.Credit_Application__c = wrapper.creditApplication.Id;
                employments.add(wrapper.coAppPreviousEmployment);
            }
            else if(wrapper.coAppPreviousEmployment != null && wrapper.coAppPreviousEmployment.Id != null && wrapper.isPrevCoBuyerEmploymentDeleted)
            {
                recordsToDelete.add(wrapper.coAppPreviousEmployment);
            }
            
            if(wrapper.currentHousing != null)
            {
                wrapper.currentHousing.Credit_Application__c = wrapper.creditApplication.Id;
                wrapper.currentHousing.Is_Primary_Buyer__c = true;
                wrapper.currentHousing.Is_Current_Residence__c = true;
                residences.add(wrapper.currentHousing);
            }
            
            if(wrapper.previousHousing != null && !wrapper.isPrevBuyerHousingDeleted)
            {
                wrapper.previousHousing.Credit_Application__c = wrapper.creditApplication.Id;
                wrapper.previousHousing.Is_Primary_Buyer__c = true;
                wrapper.previousHousing.Is_Current_Residence__c = false;
                residences.add(wrapper.previousHousing);
            }
            else if(wrapper.previousHousing != null && wrapper.previousHousing.Id != null && wrapper.isPrevBuyerHousingDeleted)
            {
                recordsToDelete.add(wrapper.previousHousing);
            }
            
            if(wrapper.currentEmployment != null)
            {
                wrapper.currentEmployment.Credit_Application__c = wrapper.creditApplication.Id;
                wrapper.currentEmployment.Is_Primary_Buyer__c = true;
                wrapper.currentEmployment.Is_Current_Employment__c = true;
                employments.add(wrapper.currentEmployment);
            }
            
            if(wrapper.previousEmployment != null && !wrapper.isPrevBuyerEmploymentDeleted)
            {
                wrapper.previousEmployment.Credit_Application__c = wrapper.creditApplication.Id;
                wrapper.previousEmployment.Is_Primary_Buyer__c = true;
                wrapper.previousEmployment.Is_Current_Employment__c = false;
                employments.add(wrapper.previousEmployment);
            }
            else if(wrapper.previousEmployment != null && wrapper.previousEmployment.Id != null && wrapper.isPrevBuyerEmploymentDeleted)
            {
                recordsToDelete.add(wrapper.previousEmployment);
            }
            
            saveReferences(wrapper.references, wrapper.creditApplication, wrapper.removedReferences);
            
            if (!residences.isEmpty())
            {
                upsert residences;
            }
            
            if (!employments.isEmpty())
            {
                upsert employments;
            }
            
            if (!recordsToDelete.isEmpty())
            {
                delete recordsToDelete;
            }
        }
        catch(Exception ex)
        {
            Database.rollback(beforeBuyersSave);
            System.debug(ex);
            throw new AuraHandledException(ex.getMessage());
        }

        //NB: 2019-03-13 option to update the Email and Phone numbers on the Opportunity
        try {
            Schema.Contact buyer = wrapper.buyer;
            Opportunity o = new Opportunity(
                    Id = wrapper.creditApplication.Opportunity__c,
                    Home_Phone__c = buyer.HomePhone,
                    Phone__c = buyer.Work_Phone__c,
                    Mobile__c = buyer.MobilePhone,
                    Email__c = buyer.Email
            );
            System.debug('Opportunity ID: ' + wrapper.creditApplication.Opportunity__c);
            update o;
        } catch(Exception ex) {
            Database.rollback(beforeBuyersSave);
            System.debug(ex);
            throw new AuraHandledException(ex.getMessage());
        }

        return wrapper.creditApplication.Opportunity__c;
    }
    
    private static void reverseCreditApplicationToInProgress(Credit_Application__c creditApplication)
    {
        try
        {
            String salesPortalAccessToken = SalesPortalAPI.authentificateOnSalesPortal(20000);
            SalesPortalAPIRequests.CreditApplicationSubmitRequestWrapper reverseToInProgressRequestBody
                = new SalesPortalAPIRequests.CreditApplicationSubmitRequestWrapper();
            reverseToInProgressRequestBody.SFEmailCreatedBy = UserInfo.getUserEmail();
            reverseToInProgressRequestBody.SPCreditAppID = Integer.valueOf(creditApplication.Sales_Portal_ID__c);
            SalesPortalAPIResponses.SubmitResult response = SalesPortalAPI.revertToIncomplete(JSON.serialize(reverseToInProgressRequestBody), salesPortalAccessToken, 100000);
            creditApplication.Credit_Application_Status__c = SalesPortalUtils.salesPortalCreditApplicationStatusIdToValue.get(response.StatusID);
            creditApplication.Client_Ancestor__c = SalesPortalUtils.CREDIT_APP_CLIENT_ANCESTOR_SALESFORCE;
        }
        catch (Exception e)
        {
            System.debug('CreditAppEditComponentController->reverseCreditApplicationToInProgress: ' + e.getMessage());
            Utils.logException(e);
           throw new AuraHandledException(e.getMessage());
        }
    }

    @TestVisible
    private static void saveShortCreditApp(CreditAppWrapper wrapper)
    {
        Profile currentUserProfile = [
                SELECT Name
                FROM Profile
                WHERE Id = :UserInfo.getProfileId()
        ];

        Boolean isInsideSalesOrBDC = insideSalesAndBDCProfiles.contains(currentUserProfile.Name);

        if (String.isBlank(wrapper.creditApplication.Sales_Portal_ID__c) && isInsideSalesOrBDC ) //NB 2019-03-16 -- UNBELIEVABLE!   -- && !Test.isRunningTest()
        {
            Opportunity relatedOpportunity = new Opportunity(Id = wrapper.creditApplication.Opportunity__c);
            wrapper.creditApplication.Client_Ancestor__c = SalesPortalUtils.CREDIT_APP_CLIENT_ANCESTOR_PHONE_APPLICATION;

            SalesPortalAPIRequests.SaveShortCreditScoreApplicationRequestBody requestBody = new SalesPortalAPIRequests.SaveShortCreditScoreApplicationRequestBody();

            requestBody.ClientAncestorId = SalesPortalUtils.salesPortalClientAncestorsValueToId.get(wrapper.creditApplication.Client_Ancestor__c);

            requestBody.CurrentlyInBankruptcy = wrapper.creditApplication.Currently_In_Bankruptcy__c;

            requestBody.ReferrerCode = wrapper.creditApplication.Opportunity__r.Referrer_code__c;

            requestBody.Email = wrapper.buyer.Email;
            requestBody.FirstName = wrapper.buyer.FirstName;
            requestBody.HomePhone = wrapper.buyer.HomePhone;
            requestBody.LastName = wrapper.buyer.LastName;
            requestBody.MiddleName = wrapper.buyer.MiddleName;
            requestBody.MobilePhone = wrapper.buyer.MobilePhone;
            requestBody.Ssn = wrapper.buyer.SocialSecurityNumber__c;
            requestBody.ActiveOrFormerMilitary = wrapper.buyer.Is_Military__c;
            requestBody.MilitaryChoise = SalesPortalUtils.militaryNameToSalesPortalId.get(wrapper.buyer.Military_Status__c);

            requestBody.City = wrapper.currentHousing.Address_City__c;
            requestBody.AddressLine = wrapper.currentHousing.Address_Street__c;
            requestBody.HouseNumber = wrapper.currentHousing.House_Number__c;
            requestBody.HouseType = SalesPortalUtils.salesPortalHousingTypeValueToId.get(wrapper.currentHousing.Housing_Type__c);
            requestBody.ResidenceMonthsId = SalesPortalUtils.salesPortalDurationMonthsValueToId.get(wrapper.currentHousing.Address_Duration_Months__c);
            requestBody.ResidenceYearsId = SalesPortalUtils.salesPortalDurationYearsValueToId.get(wrapper.currentHousing.Address_Duration_Years__c);
            requestBody.State = SalesPortalUtils.salesPortalStateValueToId.get(wrapper.currentHousing.Address_State__c);
            requestBody.StreetType = SalesPortalUtils.salesPortalStreetTypeValueToId.get(wrapper.currentHousing.Address_Street_Type__c);
            requestBody.StreetName = wrapper.currentHousing.Address_Street__c;
            requestBody.Zip = wrapper.currentHousing.Address_Zip__c;

            requestBody.JobMonthsId = SalesPortalUtils.salesPortalDurationMonthsValueToId.get(wrapper.currentEmployment.Employer_Duration_Months__c);
            requestBody.JobYearsId = SalesPortalUtils.salesPortalDurationYearsValueToId.get(wrapper.currentEmployment.Employer_Duration_Years__c);
            requestBody.OtherIncome = wrapper.currentEmployment.Other_Income__c == null ? 0 : wrapper.currentEmployment.Other_Income__c;
            requestBody.PaymentType = SalesPortalUtils.salesPortalSalaryTypeValueToId.get(wrapper.currentEmployment.Salary_Type__c);
            requestBody.PeriodPaycheck = wrapper.currentEmployment.Applicant_Net_Period_Paycheck__c;
            requestBody.WorkPhone = wrapper.currentEmployment.Employer_Phone__c;

            try
            {
                String salesPortalAccessToken = SalesPortalAPI.authentificateOnSalesPortal(20000);

                SalesPortalAPIResponses.ShortCreditApplicationData result = SalesPortalAPI.saveShortCreditScoreApplication(JSON.serialize(requestBody), salesPortalAccessToken , 100000);

                wrapper.creditApplication.Sales_Portal_ID__c = String.valueOf(result.SPCreditAppID);
                wrapper.creditApplication.Credit_Application_Status__c = SalesPortalUtils.salesPortalCreditApplicationStatusIdToValue.get(result.StatusID);
                wrapper.creditApplication.Sales_Portal_Creation_Date__c = Date.today();

                relatedOpportunity.Lead_Status__c = SalesPortalUtils.SALES_UP_LEAD_STATUS_PHONE_APPLICATION;

                if (SalesPortalUtils.salesPortalCreditApplicationStatusIdToValue.get(result.StatusID) == SalesPortalUtils.CREDIT_APP_STATUS_COND_SCORED)
                {
                    relatedOpportunity.StatusCategory__c = SalesPortalUtils.SALES_UP_STATUS_CATEGORY_CONDITIONALLY_APPROVED;
                }
                else if (SalesPortalUtils.salesPortalCreditApplicationStatusIdToValue.get(result.StatusID) == SalesPortalUtils.CREDIT_APP_STATUS_ONLINE_APP_DECLINED)
                {
                    relatedOpportunity.StatusCategory__c = SalesPortalUtils.SALES_UP_STATUS_CATEGORY_SHORT_APP_DECLINED;
                }

                update relatedOpportunity;
            }
            catch (Exception ex)
            {
				System.debug('Exception on saveShortCreditApp Method: ' + ex);
				throw new AuraHandledException(ex.getMessage());
            }
        }
    }

    @TestVisible
    private static void saveReferences(List<Schema.Contact> references, Credit_Application__c creditApplication, List<Schema.Contact> removedReferences) {
        Id referenceRecordTypeId = Utils.getRecordTypeId('Contact:Reference');
        
        for (Schema.Contact cs : references)
        {
            if (String.IsNotBlank(cs.FirstName) && (String.IsNotBlank(cs.LastName) && String.IsNotBlank(cs.Phone)) )
            {
                cs.RecordTypeId = referenceRecordTypeId;
                cs.Credit_App_Reference__c = creditApplication.Id;
                cs.AccountId =  creditApplication.Opportunity__r.AccountId;
            }
        }
        
        if (references.size() > 0)
        {
            upsert references;
            
            if (removedReferences != null && !removedReferences.isEmpty())
            {
                delete removedReferences;
            }
        }
    }

    private static InvalidFieldsWrapper validateWrapper(CreditAppWrapper wrapper)
    {
        InvalidFieldsWrapper invalidFields = new InvalidFieldsWrapper();
        invalidFields.buyerFields = new List<String>();
        invalidFields.coBuyerFields = new List<String>();
        
        wrapper.creditApplication.Valid_Sections__c = '';

        Set<String> allSections = new Set<String>{
            'personal', 'current-housing', 'previous-housing', 'current-employment', 'previous-employment', 'references',
            'credit-history', 'military-experience', 'repeat-customer', 'optional-message'
        };

        Map<String, SObjectField> contactFields = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap();
        Map<String, SObjectField> residenceFields = Schema.getGlobalDescribe().get('Residence__c').getDescribe().fields.getMap();
        Map<String, SObjectField> employmentFields = Schema.getGlobalDescribe().get('Employment__c').getDescribe().fields.getMap();
        Map<String, SObjectField> crediAppFields = Schema.getGlobalDescribe().get('Credit_Application__c').getDescribe().fields.getMap();

        for (String currentSection : allSections.clone())
        {
            if (currentSection == 'personal')
            {
                for (String currentContactField : contactRequiredFields)
                {
                    if (wrapper.buyer.get(currentContactField) == null
                            || !validateField(currentContactField, wrapper.buyer.get(currentContactField)))
                    {
                        allSections.remove('personal');
                        invalidFields.buyerFields.add(contactFields.get(currentContactField).getDescribe().label);
                    }

                    if (wrapper.coBuyer != null)
                    {
                        if (wrapper.coBuyer.get(currentContactField) == null
                                || !validateField(currentContactField, wrapper.coBuyer.get(currentContactField)))
                        {
                            allSections.remove('personal');
                            invalidFields.coBuyerFields.add('Co-App ' + contactFields.get(currentContactField).getDescribe().label);
                        }
                    }
                }
            }
            else if (currentSection == 'current-housing')
            {
                for (String currentResField : residenceRequiredFields)
                {
                    if (wrapper.currentHousing.get(currentResField) == null
                            || !validateField(currentResField, wrapper.currentHousing.get(currentResField)))
                    {
                        allSections.remove('current-housing');
                        invalidFields.buyerFields.add(residenceFields.get(currentResField).getDescribe().label);
                    }
                    if (wrapper.coAppCurrentHousing != null)
                    {
                        if (wrapper.coAppCurrentHousing.get(currentResField) == null
                                || !validateField(currentResField, wrapper.coAppCurrentHousing.get(currentResField)))
                        {
                            allSections.remove('personal');
                            invalidFields.coBuyerFields.add('Co-App ' + residenceFields.get(currentResField).getDescribe().label);
                        }
                    }
                }
            }
            else if (currentSection == 'previous-housing')
            {
                for (String currentResField : residenceRequiredFields)
                {
                    if (wrapper.previousHousing != null && !wrapper.isPrevBuyerHousingDeleted)
                    {
                        if (wrapper.previousHousing.get(currentResField) == null
                                || !validateField(currentResField, wrapper.previousHousing.get(currentResField))) {
                            allSections.remove('previous-housing');
                            invalidFields.buyerFields.add('Previous ' + residenceFields.get(currentResField).getDescribe().label);
                        }
                    }
                    if (wrapper.coAppPreviousHousing != null && !wrapper.isPrevCoBuyerHousingDeleted && wrapper.coBuyer != null)
                    {
                        if (wrapper.coAppPreviousHousing.get(currentResField) == null
                                || !validateField(currentResField, wrapper.coAppPreviousHousing.get(currentResField)))
                        {
                            allSections.remove('personal');
                            invalidFields.coBuyerFields.add('Co-App Previous ' + residenceFields.get(currentResField).getDescribe().label);
                        }
                    }
                }
            }
            else if (currentSection == 'current-employment')
            {
                for (String currentEmplField : emplotmentRequiredFields)
                {
                    if (wrapper.currentEmployment.get(currentEmplField) == null
                            || !validateField(currentEmplField, wrapper.currentEmployment.get(currentEmplField)))
                    {
                        allSections.remove('current-employment');
                        invalidFields.buyerFields.add(employmentFields.get(currentEmplField).getDescribe().label);
                    }
                    if (wrapper.coAppCurrentEmployment != null && wrapper.coBuyer != null)
                    {
                        if (wrapper.coAppCurrentEmployment.get(currentEmplField) == null
                                || !validateField(currentEmplField, wrapper.coAppCurrentEmployment.get(currentEmplField)))
                        {
                            allSections.remove('current-employment');
                            invalidFields.coBuyerFields.add('Co-App ' + employmentFields.get(currentEmplField).getDescribe().label);
                        }
                    }
                }
            }
            else if (currentSection == 'previous-employment')
            {

                for (String currentEmplField : emplotmentPrevRequiredFields)
                {
                    if (wrapper.previousEmployment != null && !wrapper.isPrevBuyerEmploymentDeleted)
                    {
                        if (wrapper.previousEmployment.get(currentEmplField) == null
                                || !validateField(currentEmplField, wrapper.previousEmployment.get(currentEmplField))) {
                            allSections.remove('previous-employment');
                            invalidFields.buyerFields.add('Previous ' + employmentFields.get(currentEmplField).getDescribe().label);
                        }
                    }


                    if (wrapper.coAppPreviousEmployment != null && !wrapper.isPrevCoBuyerEmploymentDeleted && wrapper.coBuyer != null)
                    {
                        if (wrapper.coAppPreviousEmployment.get(currentEmplField) == null
                                || !validateField(currentEmplField, wrapper.coAppPreviousEmployment.get(currentEmplField)))
                        {
                            allSections.remove('previous-employment');
                            invalidFields.coBuyerFields.add('Co-App Previous ' + employmentFields.get(currentEmplField).getDescribe().label);
                        }
                    }
                }

            }
            else if (currentSection == 'credit-history')
            {
                for (String currentCreditAppField : creditAppRequiredFields)
                {
                    if (wrapper.creditApplication.get(currentCreditAppField) == null
                            || !validateField(currentCreditAppField, wrapper.creditApplication.get(currentCreditAppField)))
                    {
                        allSections.remove('credit-history');
                        invalidFields.buyerFields.add(crediAppFields.get(currentCreditAppField).getDescribe().label);
                    }
                    if (wrapper.coBuyer != null)
                    {
                        for (String currentCreditAppCoField : creditAppCoRequiredFields)
                        {
                            if (wrapper.creditApplication.get(currentCreditAppCoField) == null
                                    || !validateField(currentCreditAppCoField, wrapper.creditApplication.get(currentCreditAppCoField)))
                            {
                                allSections.remove('credit-history');
                                invalidFields.coBuyerFields.add('Co-App ' + crediAppFields.get(currentCreditAppCoField).getDescribe().label);
                            }
                        }
                    }
                }
            }
        }

        if (wrapper.references.size() < 4)
        {
            invalidFields.buyerFields.add('At least 4 references');
        }

        for (Contact reference : wrapper.references)
        {
            if (String.IsBlank(reference.FirstName) || String.IsBlank(reference.LastName) || String.IsBlank(reference.Phone))
            {
                invalidFields.buyerFields.add('Fill all require fields reference');
                break;
            }
        }

        if (wrapper.buyer.Is_Military__c)
        {
            if (wrapper.buyer.Military_Status__c == null)
            {
                invalidFields.buyerFields.add('Military Status');
            }
        }

        if (wrapper.coBuyer != null && wrapper.coBuyer.Is_Military__c)
        {
            if (wrapper.coBuyer.Military_Status__c == null)
            {
                invalidFields.coBuyerFields.add('Co App Military Status');
            }
        }

        if (wrapper.creditApplication.Repeat_Customer__c != 'No' && !String.isBlank(wrapper.creditApplication.Repeat_Customer__c))
        {
            if (String.isBlank(wrapper.creditApplication.Repeat_Reason__c))
            {
                invalidFields.buyerFields.add('Repeat Reason');
            }
        }

        if (wrapper.creditApplication.Co_App_Repeat_Customer__c != 'No' && !String.isBlank(wrapper.creditApplication.Co_App_Repeat_Customer__c))
        {
            if (String.isBlank(wrapper.creditApplication.Co_App_Repeat_Reason__c))
            {
                invalidFields.coBuyerFields.add('Co App Repeat Reason');
            }
        }

        if (String.isBlank(String.valueOf(wrapper.creditApplication.Previous_Account_Number__c)))
        {
            wrapper.creditApplication.Previous_Account_Number__c = '0';
        }

        if (String.isBlank(String.valueOf(wrapper.creditApplication.Co_App_Previous_Account_Number__c)))
        {
            wrapper.creditApplication.Co_App_Previous_Account_Number__c = '0';
        }

        for (String currentSection : allSections)
        {
            wrapper.creditApplication.Valid_Sections__c += currentSection + ' ';
        }

        return invalidFields;
    }

    private static Boolean validateField(String fieldName, Object value)
    {
        Boolean result = true;

        if (Utils.requiredFields.contains(fieldName))
        {
            if (String.isBlank(String.valueOf(value)))
            {
                result = false;
            }
        }
        else if (Utils.requiredCurrencyFields.contains(fieldName))
        {
            if (Double.valueOf(value) == 0.0)
            {
                //result = false;
            }
        }
        else if (Utils.requiredPhoneFields.contains(fieldName))
        {
            Matcher phoneMatcher = Utils.phonePattern.matcher(String.valueOf(value));
            result = phoneMatcher.matches();
        }
        else if (Utils.requiredEmailFields.contains(fieldName))
        {
            Matcher emailMatcher = Utils.emailPattern.matcher(String.valueOf(value));
            result = emailMatcher.matches();
        }
        else if (Utils.requiredZipFields.contains(fieldName))
        {
            Matcher zipMatcher = Utils.zipPattern.matcher(String.valueOf(value));
            result = zipMatcher.matches();
        }
        else if (fieldName == 'Driver_License_Expiration_Date__c')
        {
            if (Date.valueOf(value) < Date.today())
            {
                result = false;
            }
        }
        else if (fieldName == 'Birthdate')
        {
            if(Date.valueOf(value).addYears(16) > Date.today())
            {
                result = false;
            }
        }

        return result;
    }

    private static List<PicklistItem> createPicklistValuesList(List<Schema.PicklistEntry> picklistEntries)
    {
        List<PicklistItem> picklistValues = new List<PicklistItem>();
        picklistValues.add(new PicklistItem('--None--', null));
        
        for (Schema.PicklistEntry currentPicklistEntry : picklistEntries)
        {
            picklistValues.add(new PicklistItem(currentPicklistEntry.getLabel(), currentPicklistEntry.getValue()));
        }
        
        return picklistValues;
    }
    
    public class InvalidFieldsWrapper
    {
        @AuraEnabled public List<String> buyerFields {public get; public set;}
        @AuraEnabled public List<String> coBuyerFields {public get; public set;}
    }
    
    public class SearchResult
    {
        @AuraEnabled public Schema.Contact coBuyer {get; set;}
        @AuraEnabled public String coBuyerOpportunityId {get; set;}
        @AuraEnabled public String coBuyerMessage {get; set;}
        @AuraEnabled public Boolean canContinue {get; set;}
    }
    
    public class PicklistItem
    {
        public PicklistItem() {}
        
        public PicklistItem(String label, String value)
        {
            this.label = label;
            this.value = value;
        }
        
        public String label;
        public String value;
        
        public PicklistItem setLabel(String label)
        {
            this.label = label;
            return this;
        }
    }
    
    //TrafficLog__c trafficLog = Utils.createTrafficLog(creditApplication.Id, creditApplication.Sales_Up__c, customerId, SSN_VIEWED_LOG_TYPE);
}