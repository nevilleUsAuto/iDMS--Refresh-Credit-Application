public without sharing class CreditApplicationEditController
{/*
    private static final Map<String, String> creditAppToSalesUp = new Map<String, String>{
        'Sales_Up__c' => 'Id',
        'dealer__Store_Location__c' => 'dealer__Store_Location__c',
        'dealer__Buyer_Account__c' => 'dealer__Customer_Account__c',
        'dealer__Co_Buyer_Account__c' => 'dealer__Co_Buyer__c',
        'dealer__Buyer__c' => 'dealer__Buyer_Contact__c',
        'dealer__Co_Buyer__c' => 'dealer__Co_Buyer_Contact__c'
    };
    
    private static final Map<String, String> creditAppToBuyer = new Map<String, String>{
        'dealer__First_Name__c' => 'FirstName',
        'dealer__Middle_Name__c' => 'MiddleName',
        'dealer__Last_Name__c' => 'LastName',
        'Suffix__c' => 'Suffix',
        'dealer__Home_Phone__c' => 'PersonHomePhone',
        'dealer__Mobile_Phone__c' => 'PersonMobilePhone',
        'dealer__Email_Address__c' => 'PersonEmail',
        'dealer__BirthDate__c' => 'PersonBirthdate',
        'dealer__Driver_License_No__c' => 'dealer__Drivers_License_Number__pc',
        'Driver_License_State__c' => 'dealer__Drivers_License_State__pc'
    };
    
    private static final Map<String, String> creditAppToCoBuyer = new Map<String, String>{
        'dealer__Co_App_First_Name__c' => 'FirstName',
        'dealer__Co_App_Middle_Name__c' => 'MiddleName',
        'dealer__Co_App_Last_Name__c' => 'LastName',
        'Co_App_Suffix__c' => 'Suffix',
        'dealer__Co_App_Phone__c' => 'PersonHomePhone',
        'dealer__Co_App_Mobile_Phone__c' => 'PersonMobilePhone',
        'dealer__Co_App_Email_Address__c' => 'PersonEmail',
        'dealer__Co_App_Date_of_Birth__c' => 'PersonBirthdate',
        'dealer__Co_App_Driver_License_Number__c' => 'dealer__Drivers_License_Number__pc',
        'Co_App_Driver_License_State__c' => 'dealer__Drivers_License_State__pc'
    };
    
    private static final Map<String, String> coBuyerToCreditApp = new Map<String, String>{
        'FirstName' => 'dealer__Co_App_First_Name__c',
        'MiddleName' => 'dealer__Co_App_Middle_Name__c',
        'LastName' => 'dealer__Co_App_Last_Name__c',
        'Suffix' => 'Co_App_Suffix__c',
        'PersonHomePhone' => 'dealer__Co_App_Phone__c',
        'PersonMobilePhone' => 'dealer__Co_App_Mobile_Phone__c',
        'PersonEmail' => 'dealer__Co_App_Email_Address__c',
        'PersonBirthdate' => 'dealer__Co_App_Date_of_Birth__c',
        'dealer__Drivers_License_Number__pc' => 'dealer__Co_App_Driver_License_Number__c',
        'dealer__Drivers_License_State__pc' => 'Co_App_Driver_License_State__c'
    };
    
    private static final List<String> buyerRequiredToSaveNullableFields = new List<String>{
        'dealer__First_Name__c', 'dealer__Last_Name__c'
    };
    
    private static final List<String> buyerRequiredToSubmitNullableFields = new List<String>{
        'dealer__First_Name__c', 'dealer__Last_Name__c', 'dealer__Home_Phone__c', 'dealer__Mobile_Phone__c',
        'dealer__Email_Address__c', 'dealer__Social_Security_Number__c', 'dealer__BirthDate__c',
        'dealer__Driver_License_No__c', 'Driver_License_State__c', 'Housing_Type__c', 'Current_House_Number__c',
        'Current_Street__c', 'Current_Street_Type__c', 'dealer__Current_Address_City__c', 'Current_Address_State__c',
        'dealer__Current_Address_Zip__c', 'dealer__Home_Payment__c', 'dealer__Present_Employer__c',
        'dealer__Present_Employer_Street__c', 'dealer__Present_Employer_City__c', 'Present_Employer_State__c',
        'dealer__Present_Employer_Zip__c', 'dealer__Occupation_Or_Rank__c', 'dealer__Present_Employer_Phone__c',
        'Net_Period_Paycheck__c', 'Salary_Type__c', 'Available_Down_Payment__c', 'Other_Income__c', 'Drivers_License_Expiration_Date__c'
    };
    
    private static final List<String> buyerRequiredToSubmitDurationFields = new List<String>{
        'Current_Address_Duration_Years__c', 'Present_Employer_Duration_Years__c'
    };
    
    private static final List<String> creditAppBuyerNonRequiredFields = new List<String>{
        'Car_Repossessed__c', 'Currently_in_bankruptcy__c', 'Ever_filed_Bankruptcy_or_Chapter_13__c',
        'Home_Address_2__c', 'dealer__Previous_Address_1_Street__c', 'dealer__Previous_Address_1_City__c',
        'Previous_Address_1_State__c', 'dealer__Previous_Address_1_Zip__c', 'Suffix__c', 'Previous_Address_2__c',
        'dealer__Previous_Employer_1__c', 'Repeat_Customer__c', 'Repeat_Reason__c', 'Previous_Account_Number__c',
        'Previous_Address_Duration_Years__c', 'Previous_Employer_1_Duration_Years__c', 'dealer__Middle_Name__c'
    };
    
    private static final List<String> coBuyerRequiredToSaveNullableFields = new List<String>{
        'dealer__Co_App_First_Name__c', 'dealer__Co_App_Last_Name__c'
    };
    
    private static final List<String> coBuyerRequiredToSubmitNullableFields = new List<String>{
        'dealer__Co_App_First_Name__c', 'dealer__Co_App_Last_Name__c', 'dealer__Co_App_Phone__c',
        'dealer__Co_App_Mobile_Phone__c', 'dealer__Co_App_Email_Address__c', 'dealer__Co_App_Social_Security_Number__c',
        'dealer__Co_App_Date_of_Birth__c', 'dealer__Co_App_Driver_License_Number__c', 'Co_App_Driver_License_State__c',
        'Co_App_Housing_Type__c', 'Co_App_Current_House_Number__c', 'Co_App_Current_Street__c', 'Co_App_Current_Street_Type__c',
        'dealer__Co_App_Current_Address_City__c', 'Co_App_Current_Address_State__c', 'dealer__Co_App_Current_Address_Zip__c',
        'Co_Applicant_House_Payment__c', 'dealer__Co_App_Present_Employer__c', 'dealer__Co_App_Present_Employer_Street__c',
        'dealer__Co_App_Present_Employer_City__c', 'Co_App_Present_Employer_State__c', 'dealer__Co_App_Present_Employer_Zip__c',
        'dealer__Co_App_Occupation_Or_Rank__c', 'dealer__Co_App_Present_Employer_Phone__c',
        'Co_App_Net_Period_Paycheck__c', 'Co_App_Salary_Type__c', 'Co_App_Available_Down_Payment__c',
        'Co_App_Other_Income__c', 'Co_App_Drivers_License_Expiration_Date__c'
    };
    
    private static final List<String> coBuyerRequiredToSubmitDurationFields = new List<String>{
        'Co_App_Current_Address_Duration_Years__c', 'Co_App_Present_Employer_Duration_Years__c'
    };
    
    private static final List<String> creditAppCoBuyerNonRequiredFields = new List<String>{
        'Co_App_Home_Address_2__c', 'dealer__Co_App_Previous_Address_1_Street__c',
        'dealer__Co_App_Previous_Address_1_City__c', 'Co_App_Prev_Address_1_State__c', 'dealer__Co_App_Prev_Address_1_Zip__c',
        'Co_App_Suffix__c', 'Co_App_Previous_Address_2__c', 'dealer__Co_App_Previous_Employer_1__c',
        'Co_App_Repeat_Customer__c', 'Co_App_Repeat_Reason__c', 'Co_App_Previous_Account_Number__c',
        'Co_App_car_repossessed__c', 'Co_App_currently_in_bankruptcy__c', 'Co_App_gone_through_bankruptcy__c',
        'Co_App_Prev_Address_Duration_Years__c', 'Co_App_Previous_Employer_1_Duration_Y__c', 'dealer__Co_App_Middle_Name__c'
    };
    
    private static final List<String> creditAppAdditionalFields = new List<String>{
        'Ready_To_Submit__c', 'dealer__Co_Buyer_Account__c', 'Credit_Application_Comment__c', 'Sales_Up__c',
        'dealer__Buyer_Account__c', 'Credit_Application_Status__c', 'Sales_Portal_ID__c', 'Sales_Up__r.Referrer_Code__c',
        'Is_Military__c', 'Co_App_Is_Military__c', 'Military_Status__c', 'Co_App_Military_Status__c'
    };
    
    private static final Map<String, String> durationFields = new Map<String, String>{
        'Current_Address_Duration_Years__c' => 'Current_Address_Duration_Months__c',
        'Present_Employer_Duration_Years__c' => 'Present_Employer_Duration_Months__c',
        'Previous_Address_Duration_Years__c' => 'Previous_Address_Duration_Months__c',
        'Previous_Employer_1_Duration_Years__c' => 'Previous_Employer_1_Duration_Months__c',
        'Co_App_Current_Address_Duration_Years__c' => 'Co_App_Address_Duration_Months__c',
        'Co_App_Present_Employer_Duration_Years__c' => 'Co_App_Present_Employer_Duration_Month__c',
        'Co_App_Prev_Address_Duration_Years__c' => 'Co_App_Prev_Address_Duration_Months__c',
        'Co_App_Previous_Employer_1_Duration_Y__c' => 'Co_App_Previous_Employer_1_Duration_M__c'
    };
    
    private Map<String, List<String>> requiredToSubmitNullableDependentFields = new Map<String, List<String>>
    {
        'Current_Address_Duration_Years__c' => new List<String>
        {
            'dealer__Previous_Address_1_Street__c', 'dealer__Previous_Address_1_City__c',
            'Previous_Address_1_State__c', 'dealer__Previous_Address_1_Zip__c'
        },
        'Present_Employer_Duration_Years__c' => new List<String>
        {
            'dealer__Previous_Employer_1__c'
        },
        'Repeat_Customer__c' => new List<String>
        {
            'Repeat_Reason__c', 'Previous_Account_Number__c'
        },
        'Is_Military__c' => new List<String>
        {
            'Military_Status__c'
        },
        'Co_App_Current_Address_Duration_Years__c' => new List<String>
        {
            'dealer__Co_App_Previous_Address_1_Street__c', 'dealer__Co_App_Previous_Address_1_City__c',
            'Co_App_Prev_Address_1_State__c', 'dealer__Co_App_Prev_Address_1_Zip__c'
        },
        'Co_App_Present_Employer_Duration_Years__c' => new List<String>
        {
            'dealer__Co_App_Previous_Employer_1__c'
        },
        'Co_App_Repeat_Customer__c' => new List<String>
        {
            'Co_App_Repeat_Reason__c', 'Co_App_Previous_Account_Number__c'
        },
        'Co_App_Is_Military__c' => new List<String>
        {
            'Co_App_Military_Status__c'
        }
    };
    
    private static final Map<String, List<String>> requiredToSubmitDurationDependentFields = new Map<String, List<String>>
    {
        'Current_Address_Duration_Years__c' => new List<String>
        {
            'Previous_Address_Duration_Years__c'
        },
        'Present_Employer_Duration_Years__c' => new List<String>
        {
            'Previous_Employer_1_Duration_Years__c'
        },
        'Co_App_Current_Address_Duration_Years__c' => new List<String>
        {
            'Co_App_Prev_Address_Duration_Years__c'
        },
        'Co_App_Present_Employer_Duration_Years__c' => new List<String>
        {
            'Co_App_Previous_Employer_1_Duration_Y__c'
        }
    };
    
    private static final Map<String, List<String>> dependentFields = new Map<String, List<String>>
    {
        'Current_Address_Duration_Years__c' => new List<String>
        {
            'dealer__Previous_Address_1_Street__c', 'Previous_Address_2__c', 'dealer__Previous_Address_1_City__c',
            'Previous_Address_1_State__c', 'dealer__Previous_Address_1_Zip__c', 'Previous_Address_Duration_Years__c',
            'Previous_Address_Duration_Months__c'
        },
        'Present_Employer_Duration_Years__c' => new List<String>
        {
            'dealer__Previous_Employer_1__c', 'Previous_Employer_1_Duration_Years__c', 'Previous_Employer_1_Duration_Months__c'
        },
        'Repeat_Customer__c' => new List<String>
        {
            'Repeat_Reason__c', 'Previous_Account_Number__c'
        },
        'Is_Military__c' => new List<String>
        {
            'Military_Status__c'
        },
        'Co_App_Current_Address_Duration_Years__c' => new List<String>
        {
            'dealer__Co_App_Previous_Address_1_Street__c', 'Co_App_Previous_Address_2__c',
            'dealer__Co_App_Previous_Address_1_City__c', 'Co_App_Prev_Address_1_State__c',
            'dealer__Co_App_Prev_Address_1_Zip__c', 'Co_App_Prev_Address_Duration_Years__c',
            'Co_App_Prev_Address_Duration_Months__c'
        },
        'Co_App_Present_Employer_Duration_Years__c' => new List<String>
        {
            'dealer__Co_App_Previous_Employer_1__c', 'Co_App_Previous_Employer_1_Duration_Y__c',
            'Co_App_Previous_Employer_1_Duration_M__c'
        },
        'Co_App_Repeat_Customer__c' => new List<String>
        {
            'Co_App_Repeat_Reason__c', 'Co_App_Previous_Account_Number__c'
        },
        'Co_App_Is_Military__c' => new List<String>
        {
            'Co_App_Military_Status__c'
        }
    };
    
    private static final Map<String, String> customLabels = new Map<String, String>{
        'dealer__Previous_Address_1_Street__c' => 'Previous Address 1',
        'dealer__Co_App_Previous_Address_1_Street__c' => 'Co-App Previous Address 1',
        'dealer__Present_Employer_Street__c' => 'Present Employer Address',
        'dealer__Co_App_Present_Employer_Street__c' => 'Co-App Present Employer Address',
        'dealer__Applicants_Gross_Monthly_Income__c' => 'Applicant&#39s Net Period Paycheck',
        'dealer__Co_App_Gross_Monthly_Income__c' => 'Co-App Net Period Paycheck'
    };
    
    private static final List<String> buyerPhoneMainFieldsOfCreditApplication = new List<String>{
        'dealer__Home_Phone__c', 'dealer__Mobile_Phone__c', 'dealer__Present_Employer_Phone__c'
    };
    
    private static final List<String> coBuyerPhoneMainFieldsOfCreditApplication = new List<String>{
        'dealer__Co_App_Mobile_Phone__c', 'dealer__Co_App_Phone__c', 'dealer__Co_App_Present_Employer_Phone__c'
    };
    
    private static final List<String> buyerZipMainFieldsOfCreditApplication = new List<String>{
        'dealer__Current_Address_Zip__c', 'dealer__Present_Employer_Zip__c'
    };
    
    private static final List<String> coBuyerZipMainFieldsOfCreditApplication = new List<String>{
        'dealer__Co_App_Current_Address_Zip__c', 'dealer__Co_App_Present_Employer_Zip__c'
    };
    
    private static final Set<String> initialPaycallStatuses = new Set<String>{
        SalesPortalUtils.CREDIT_APP_STATUS_INITIAL_PAYCALL, SalesPortalUtils.CREDIT_APP_STATUS_LETTER_PRINTED
    };
    
    private static final Set<String> insideSalesAndBDCProfiles = new Set<String>{
        'ISC New', 'BDC Agent', 'BDC Manager New'
    };
    
    private static final String SSN_VIEWED_LOG_TYPE = 'SSN Viewed';
    private static final String CREDIT_APP_COMPLETED_LOG_TYPE = 'Credit App Completed';
    private static final String BDC_MANAGER_PROFILE = 'BDC Manager New';
    private static final Integer MAXIMUM_CREDIT_REFERENCES = 6;  // 20180422 -- NB
    
    private static final Years_Requiring_Previous_Information__c yearBoundCustomSetting =
        Years_Requiring_Previous_Information__c.getInstance('Standard Settings');
    
    private static final dealer__Credit_Application__c defaultCreditApplication =
        (dealer__Credit_Application__c)dealer__Credit_Application__c.sObjectType.newSObject(null, true);
    
    private List<String> creditApplicationFields;
    private Map<String, Schema.SObjectField> creditAppFieldMap;
    
    public Set<String> yearsRequiringPreviousInformationForHousing {get; set;}
    public Set<String> yearsRequiringPreviousInformationForEmployer {get; set;}
    
    public List<String> requiredEmptyFields {get; set;}
    public List<String> zeroDurationFields  {get; set;}
    
    public String requiredEmptyFieldsJSON {get; set;}
    public String zeroDurationFieldsJSON {get; set;}
    
    public String errorMessage {get; set;}
    
    public dealer__Credit_Application__c creditApplication {get; set;}
    
    public Boolean isInsideSalesOrBDC {get; set;}
    public Boolean canNotBeSaved {get; set;}
    public Boolean createCobuyerOnSave {get; set;}
    
    public CreditApplicationEditController()
    {
        Profile currentUserProfile = [
            SELECT Name
            FROM Profile
            WHERE Id = :UserInfo.getProfileId()
        ];
        
        isInsideSalesOrBDC = insideSalesAndBDCProfiles.contains(currentUserProfile.Name);
        
        if (isInsideSalesOrBDC)
        {
            requiredToSubmitNullableDependentFields.put('Repeat_Customer__c', new List<String>{'Repeat_Reason__c'});
        }
        
        yearsRequiringPreviousInformationForHousing = new Set<String>();
        yearsRequiringPreviousInformationForEmployer = new Set<String>();
        
        if (yearBoundCustomSetting != null)
        {
            yearsRequiringPreviousInformationForHousing.addAll(yearBoundCustomSetting.Housing_Information__c.split(','));
            yearsRequiringPreviousInformationForEmployer.addAll(yearBoundCustomSetting.Employer_Information__c.split(','));
        }
        
        zeroDurationFields = new List<String>();
        requiredEmptyFields = new List<String>();
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType creditApplicationSchema = schemaMap.get('dealer__Credit_Application__c');
        creditAppFieldMap = creditApplicationSchema.getDescribe().fields.getMap();
        
        creditApplicationFields = new List<String>();
        creditApplicationFields.addAll(buyerRequiredToSubmitNullableFields);
        creditApplicationFields.addAll(buyerRequiredToSubmitDurationFields);
        creditApplicationFields.addAll(creditAppBuyerNonRequiredFields);
        creditApplicationFields.addAll(coBuyerRequiredToSubmitNullableFields);
        creditApplicationFields.addAll(coBuyerRequiredToSubmitDurationFields);
        creditApplicationFields.addAll(creditAppCoBuyerNonRequiredFields);
        creditApplicationFields.addAll(creditAppAdditionalFields);
        creditApplicationFields.addAll(durationFields.values());
        
        Boolean isCreation = Boolean.valueOf(ApexPages.currentPage().getParameters().get('isCreation'));
        
        if (isCreation)
        {
            List<dealer__Credit_Application__c> existingCreditApplications = [
                SELECT Id, Name
                FROM dealer__Credit_Application__c
                WHERE Sales_Up__c = :ApexPages.currentPage().getParameters().get('salesUpId')
                ORDER BY CreatedDate, Id DESC
            ];
            
            if (!existingCreditApplications.isEmpty())
            {
                creditApplication = (dealer__Credit_Application__c)Utils.getRecordById('dealer__Credit_Application__c', String.join(creditApplicationFields, ','), existingCreditApplications[0].Id)
                    .clone(false, true, false, false);
                
                creditApplication.Sales_Portal_ID__c = null;
                creditApplication.Sales_Portal_Creation_Date__c = null;
                creditApplication.Credit_Application_Comment__c = null;
                creditApplication.Ready_To_Submit__c = false;
                creditApplication.Credit_Application_Status__c = SalesPortalUtils.CREDIT_APP_STATUS_IN_PROGRESS;
            }
            else
            {
                loadDataFromRelatedRecords();
            }
            
            creditApplication.Client_Ancestor__c = SalesPortalUtils.CREDIT_APP_CLIENT_ANCESTOR_SALESFORCE;
        }
        else
        {
            creditApplication = (dealer__Credit_Application__c)Utils.getRecordById('dealer__Credit_Application__c',
                String.join(creditApplicationFields, ','), ApexPages.currentPage().getParameters().get('creditAppId'));
            
            creditApplication.Ready_To_Submit__c = false;
        }
        
        if (String.isBlank(creditApplication.ISC__c))
        {
            Profile usersProfile = [
                SELECT Name
                FROM Profile
                WHERE Id = :UserInfo.getProfileId()
            ];
            
            if (usersProfile.Name.equals(BDC_MANAGER_PROFILE))
            {
                creditApplication.ISC__c = UserInfo.getUserId();
            }
        }
    }
    
    public void loadDataFromRelatedRecords()
    {
        dealer__Sales_Up__c salesUp = (dealer__Sales_Up__c)Utils.getRecordById('dealer__Sales_Up__c',
            String.join(creditAppToSalesUp.values(), ','), ApexPages.currentPage().getParameters().get('salesUpId'));
        
        creditApplication = new dealer__Credit_Application__c();
        creditApplication = (dealer__Credit_Application__c)getFieldValuesFromRelatedRecord(creditApplication, salesUp, creditAppToSalesUp);
        
        if (String.isNotBlank(creditApplication.dealer__Buyer_Account__c))
        {
            Account buyer = (Account)Utils.getRecordById('Account', String.join(creditAppToBuyer.values(), ','),
                creditApplication.dealer__Buyer_Account__c);
            
            creditApplication = (dealer__Credit_Application__c)getFieldValuesFromRelatedRecord(creditApplication, buyer, creditAppToBuyer);
        }
        
        if (String.isNotBlank(creditApplication.dealer__Co_Buyer_Account__c))
        {
            Account coBuyer = (Account)Utils.getRecordById('Account', String.join(creditAppToCoBuyer.values(), ','),
                creditApplication.dealer__Co_Buyer_Account__c);
            
            creditApplication = (dealer__Credit_Application__c)getFieldValuesFromRelatedRecord(creditApplication, coBuyer, creditAppToCoBuyer);
        }
        
        creditApplication.Credit_Application_Status__c = SalesPortalUtils.CREDIT_APP_STATUS_IN_PROGRESS;
    }
    
    public SObject getFieldValuesFromRelatedRecord(SObject toRecord, SObject fromRecord, Map<String, String> fieldMapping)
    {
        for (String field : fieldMapping.keySet())
        {
            toRecord.put(field, fromRecord.get(fieldMapping.get(field)));
        }
        
        return toRecord;
    }
    
    public void validateCreditApplicationFields()
    {
        clearValidationResults();
        
        List<String> buyerEmptyNullableFields = new List<String>();
        List<String> buyerCompleteNullableFields = new List<String>();
        List<String> buyerZeroDurationFields = new List<String>();
        List<String> buyerCompleteDurationFields = new List<String>();
        
        getBuyerIncompleteAndCompleteLabelsLists(buyerEmptyNullableFields, buyerCompleteNullableFields,
            buyerZeroDurationFields, buyerCompleteDurationFields);
        
        requiredEmptyFields.addAll(buyerEmptyNullableFields);
        zeroDurationFields.addAll(buyerZeroDurationFields);
        
        validateNameFields(buyerRequiredToSaveNullableFields);
        
        List<String> coBuyerEmptyNullableFields = new List<String>();
        List<String> coBuyerCompleteNullableFields = new List<String>();
        List<String> coBuyerZeroDurationFields = new List<String>();
        List<String> coBuyerCompleteDurationFields = new List<String>();
        
        getCoBuyerIncompleteAndCompleteLabelsLists(coBuyerEmptyNullableFields, coBuyerCompleteNullableFields,
            coBuyerZeroDurationFields, coBuyerCompleteDurationFields);
        
        if ((creditApplication.dealer__Co_Buyer_Account__c != null) || (!coBuyerCompleteNullableFields.isEmpty()) || (!coBuyerCompleteDurationFields.isEmpty()))
        {
            requiredEmptyFields.addAll(coBuyerEmptyNullableFields);
            zeroDurationFields.addAll(coBuyerZeroDurationFields);
            
            validateNameFields(coBuyerRequiredToSaveNullableFields);
            
            if (creditApplication.dealer__Co_Buyer_Account__c == null)
            {
                createCobuyerOnSave = true;
            }
        }
        
        
        // NB -- 20180422
        Integer validRefCount = this.validateReferences();
        system.debug('number of good references: ' + validRefCount);
        
        Set<String> excludedProfiles = new set<String>{'BCD Manager', 'ISC'}; //, 'System Administrator'
        Set<Id> excludedIds = usas_UtilityMethods.getProfileIdByName(excludedProfiles);
        
        if ( ! excludedIds.Contains(UserInfo.getProfileId()) && validRefCount < 4) {
            
            this.requiredEmptyFields.add('Business rule requires at least four (4) references. Number of qualified entries: '
                + validRefCount);
        }
        
        requiredEmptyFieldsJSON = JSON.serialize(requiredEmptyFields);
        zeroDurationFieldsJSON = JSON.serialize(zeroDurationFields);
    }
    
    public void getBuyerIncompleteAndCompleteLabelsLists(List<String> emptyNullableFields, List<String> completedNullableFields, List<String> zeroDurationFields, List<String> completedZeroDurationFields)
    {
        getEmptyAndCompletedFieldsLabels(buyerRequiredToSubmitNullableFields, emptyNullableFields, completedNullableFields);
        getZeroAndCompletedDurationFieldsLabels(buyerRequiredToSubmitDurationFields, zeroDurationFields, completedZeroDurationFields);
        
        if (yearsRequiringPreviousInformationForHousing.contains(creditApplication.Current_Address_Duration_Years__c))
        {
            getEmptyAndCompletedFieldsLabels(requiredToSubmitNullableDependentFields.get('Current_Address_Duration_Years__c'),
                emptyNullableFields, completedNullableFields);
            getZeroAndCompletedDurationFieldsLabels(requiredToSubmitDurationDependentFields.get('Current_Address_Duration_Years__c'),
                zeroDurationFields, completedZeroDurationFields);
        }
        
        if (yearsRequiringPreviousInformationForEmployer.contains(creditApplication.Present_Employer_Duration_Years__c))
        {
            getEmptyAndCompletedFieldsLabels(requiredToSubmitNullableDependentFields.get('Present_Employer_Duration_Years__c'),
                emptyNullableFields, completedNullableFields);
            getZeroAndCompletedDurationFieldsLabels(requiredToSubmitDurationDependentFields.get('Present_Employer_Duration_Years__c'),
                zeroDurationFields, completedZeroDurationFields);
        }
        
        if (!creditApplication.Repeat_Customer__c.equals('No'))
        {
            getEmptyAndCompletedFieldsLabels(requiredToSubmitNullableDependentFields.get('Repeat_Customer__c'),
                emptyNullableFields, completedNullableFields);
        }
        
        if (creditApplication.Is_Military__c)
        {
            getEmptyAndCompletedFieldsLabels(requiredToSubmitNullableDependentFields.get('Is_Military__c'),
                emptyNullableFields, completedNullableFields);
        }
    }
    
    public void getCoBuyerIncompleteAndCompleteLabelsLists(List<String> emptyNullableFields, List<String> completedNullableFields,
        List<String> zeroDurationFields, List<String> completedZeroDurationFields)
    {
        getEmptyAndCompletedFieldsLabels(coBuyerRequiredToSubmitNullableFields, emptyNullableFields, completedNullableFields);
        getZeroAndCompletedDurationFieldsLabels(coBuyerRequiredToSubmitDurationFields, zeroDurationFields, completedZeroDurationFields);
        
        if (yearsRequiringPreviousInformationForHousing.contains(creditApplication.Co_App_Current_Address_Duration_Years__c))
        {
            getEmptyAndCompletedFieldsLabels(requiredToSubmitNullableDependentFields.get('Co_App_Current_Address_Duration_Years__c'),
                emptyNullableFields, completedNullableFields);
            getZeroAndCompletedDurationFieldsLabels(requiredToSubmitDurationDependentFields.get('Co_App_Current_Address_Duration_Years__c'),
                zeroDurationFields, completedZeroDurationFields);
        }
        
        if (yearsRequiringPreviousInformationForEmployer.contains(creditApplication.Co_App_Present_Employer_Duration_Years__c))
        {
            getEmptyAndCompletedFieldsLabels(requiredToSubmitNullableDependentFields.get('Co_App_Present_Employer_Duration_Years__c'),
                emptyNullableFields, completedNullableFields);
            getZeroAndCompletedDurationFieldsLabels(requiredToSubmitDurationDependentFields.get('Co_App_Present_Employer_Duration_Years__c'),
                zeroDurationFields, completedZeroDurationFields);
        }
        
        if (!creditApplication.Co_App_Repeat_Customer__c.equals('No'))
        {
            getEmptyAndCompletedFieldsLabels(requiredToSubmitNullableDependentFields.get('Co_App_Repeat_Customer__c'),
                emptyNullableFields, completedNullableFields);
        }
        
        if (creditApplication.Co_App_Is_Military__c)
        {
            getEmptyAndCompletedFieldsLabels(requiredToSubmitNullableDependentFields.get('Co_App_Is_Military__c'),
                emptyNullableFields, completedNullableFields);
        }
    
    }
    
    public void getEmptyAndCompletedFieldsLabels(List<String> fieldNames, List<String> emptyFields, List<String> completedFields)
    {
        for (String fieldName : fieldNames)
        {
            if (creditApplication.get(fieldName) == null)
            {
                emptyFields.add(getFieldLabel(fieldName));
            }
            else
            {
                completedFields.add(getFieldLabel(fieldName));
            }
        }
    }
    
    public void getZeroAndCompletedDurationFieldsLabels(List<String> fieldNames, List<String> zeroDurationFields, List<String> completedFields)
    {
        for (String fieldName : fieldNames)
        {
            String yearsField = fieldName;
            String monthsField = durationFields.get(fieldName);
            
            if (creditApplication.get(yearsField).equals(creditApplication.get(monthsField)) && creditApplication.get(yearsField).equals('0'))
            {
                zeroDurationFields.add(getFieldLabel(yearsField) + ' and ' + getFieldLabel(monthsField));
            }
            else
            {
                completedFields.add(getFieldLabel(yearsField) + ' and ' + getFieldLabel(monthsField));
            }
        }
    }
    
    public String getFieldLabel(String fieldName)
    {
        if (customLabels.containsKey(fieldName))
        {
            return customLabels.get(fieldName);
        }
        else
        {
            return creditAppFieldMap.get(fieldName).getDescribe().getLabel().replace('\'', '&#39');
        }
    }
    
    public void validateNameFields(List<String> nameFields)
    {
        for (String field : nameFields)
        {
            if (creditApplication.get(field) == null)
            {
                canNotBeSaved = true;
            }
        }
    }
    
    public void clearValidationResults()
    {
        requiredEmptyFields.clear();
        zeroDurationFields.clear();
        createCobuyerOnSave = false;
        canNotBeSaved = false;
        errorMessage = '';
    }
    
    public void setDefaultValuesForDependentFields()
    {
        String mainFieldName = Apexpages.currentPage().getParameters().get('mainFieldName');
        
        Boolean isDefaultValueSetRequired =
            (mainFieldName.equals('Current_Address_Duration_Years__c') && (!yearsRequiringPreviousInformationForHousing.contains(creditApplication.Current_Address_Duration_Years__c)))
                || (mainFieldName.equals('Co_App_Current_Address_Duration_Years__c') && (!yearsRequiringPreviousInformationForHousing.contains(creditApplication.Co_App_Current_Address_Duration_Years__c)))
                || (mainFieldName.equals('Present_Employer_Duration_Years__c') && (!yearsRequiringPreviousInformationForEmployer.contains(creditApplication.Present_Employer_Duration_Years__c)))
                || (mainFieldName.equals('Co_App_Present_Employer_Duration_Years__c') && (!yearsRequiringPreviousInformationForEmployer.contains(creditApplication.Co_App_Present_Employer_Duration_Years__c)))
                || (creditApplication.get(mainFieldName).equals(defaultCreditApplication.get(mainFieldName)));
        
        if (isDefaultValueSetRequired)
        {
            for (String dependentFieldName : dependentFields.get(mainFieldName))
            {
                creditApplication.put(dependentFieldName, defaultCreditApplication.get(dependentFieldName));
            }
        }
    }
    
    public void logSocialSecurityNumberView()
    {
        Id customerId = Apexpages.currentPage().getParameters().get('customerId');
        
        //TrafficLog__c trafficLog = Utils.createTrafficLog(creditApplication.Id, creditApplication.Sales_Up__c, customerId, SSN_VIEWED_LOG_TYPE);
        
        //insert trafficLog;
    }
    
    public void createCoBuyerRecord()
    {
        Account coBuyer = new Account();
        coBuyer = (Account)getFieldValuesFromRelatedRecord(coBuyer, creditApplication, coBuyerToCreditApp);
        insert coBuyer;
        
        creditApplication.dealer__Co_Buyer_Account__c = coBuyer.Id;
    }
    
    public void saveAsReadyToSubmit()
    {
        dealer__Sales_Up__c relatedSalesUp = new dealer__Sales_Up__c(Id = creditApplication.Sales_Up__c);
        
        if ((String.isBlank(creditApplication.Sales_Portal_ID__c) && isInsideSalesOrBDC) || Test.isRunningTest())
        {
            creditApplication.Client_Ancestor__c = SalesPortalUtils.CREDIT_APP_CLIENT_ANCESTOR_PHONE_APPLICATION;
            
            SalesPortalAPIRequests.SaveShortCreditScoreApplicationRequestBody requestBody = new SalesPortalAPIRequests.SaveShortCreditScoreApplicationRequestBody();
            
            requestBody.AddressLine = creditApplication.Current_Street__c;
            requestBody.City = creditApplication.dealer__Current_Address_City__c;
            requestBody.ClientAncestorId = SalesPortalUtils.salesPortalClientAncestorsValueToId.get(creditApplication.Client_Ancestor__c);
            requestBody.CurrentlyInBankruptcy = creditApplication.Currently_in_bankruptcy__c;
            requestBody.Email = creditApplication.dealer__Email_Address__c;
            requestBody.FirstName = creditApplication.dealer__First_Name__c;
            requestBody.HomePhone = creditApplication.dealer__Home_Phone__c;
            requestBody.HouseNumber = creditApplication.Current_House_Number__c;
            requestBody.HouseType = SalesPortalUtils.salesPortalHousingTypeValueToId.get(creditApplication.Housing_Type__c);
            requestBody.JobMonthsId = SalesPortalUtils.salesPortalDurationMonthsValueToId.get(creditApplication.Present_Employer_Duration_Months__c);
            requestBody.JobYearsId = SalesPortalUtils.salesPortalDurationYearsValueToId.get(creditApplication.Present_Employer_Duration_Years__c);
            requestBody.LastName = creditApplication.dealer__Last_Name__c;
            requestBody.MiddleName = creditApplication.dealer__Middle_Name__c;
            requestBody.MobilePhone = creditApplication.dealer__Mobile_Phone__c;
            requestBody.OtherIncome = creditApplication.Other_Income__c;
            requestBody.PaymentType = SalesPortalUtils.salesPortalSalaryTypeValueToId.get(creditApplication.Salary_Type__c);
            requestBody.PeriodPaycheck = creditApplication.Net_Period_Paycheck__c;
            requestBody.ReferrerCode = creditApplication.Sales_Up__r.Referrer_code__c;
            requestBody.ResidenceMonthsId = SalesPortalUtils.salesPortalDurationMonthsValueToId.get(creditApplication.Current_Address_Duration_Months__c);
            requestBody.ResidenceYearsId = SalesPortalUtils.salesPortalDurationYearsValueToId.get(creditApplication.Current_Address_Duration_Years__c);
            requestBody.ResidenceYearsId = SalesPortalUtils.salesPortalDurationYearsValueToId.get(creditApplication.Current_Address_Duration_Years__c);
            requestBody.Ssn = creditApplication.dealer__Social_Security_Number__c;
            requestBody.State = SalesPortalUtils.salesPortalStateValueToId.get(creditApplication.Current_Address_State__c);
            requestBody.StreetName = creditApplication.Current_Street__c;
            requestBody.StreetType = SalesPortalUtils.salesPortalStreetTypeValueToId.get(creditApplication.Current_Street_Type__c);
            requestBody.WorkPhone = creditApplication.dealer__Present_Employer_Phone__c;
            requestBody.Zip = creditApplication.dealer__Current_Address_Zip__c;
            requestBody.ActiveOrFormerMilitary = creditApplication.Is_Military__c;
            requestBody.MilitaryChoise = SalesPortalUtils.militaryNameToSalesPortalId.get(creditApplication.Military_Status__c);
            
            try
            {
                String salesPortalAccessToken = SalesPortalAPI.authentificateOnSalesPortal(20000);
                
                SalesPortalAPIResponses.ShortCreditApplicationData result = SalesPortalAPI.saveShortCreditScoreApplication(JSON.serialize(requestBody), salesPortalAccessToken , 100000);
                
                creditApplication.Sales_Portal_ID__c = String.valueOf(result.SPCreditAppID);
                creditApplication.Credit_Application_Status__c = SalesPortalUtils.salesPortalCreditApplicationStatusIdToValue.get(result.StatusID);
                creditApplication.Sales_Portal_Creation_Date__c = Date.today();
                
                relatedSalesUp.dealer__Lead_Status__c = SalesPortalUtils.SALES_UP_LEAD_STATUS_PHONE_APPLICATION;
                
                if (SalesPortalUtils.salesPortalCreditApplicationStatusIdToValue.get(result.StatusID) == SalesPortalUtils.CREDIT_APP_STATUS_COND_SCORED)
                {
                    relatedSalesUp.StatusCategory__c = SalesPortalUtils.SALES_UP_STATUS_CATEGORY_CONDITIONALLY_APPROVED;
                }
                else if (SalesPortalUtils.salesPortalCreditApplicationStatusIdToValue.get(result.StatusID) == SalesPortalUtils.CREDIT_APP_STATUS_ONLINE_APP_DECLINED)
                {
                    relatedSalesUp.StatusCategory__c = SalesPortalUtils.SALES_UP_STATUS_CATEGORY_SHORT_APP_DECLINED;
                }
                
                update relatedSalesUp;
            }
            catch (Exception ex)
            {
                errorMessage = ex.getMessage();
            }
        }
        
        creditApplication.Ready_To_Submit__c = true;
        
        save();
        
        //TrafficLog__c trafficLog = Utils.createTrafficLog(creditApplication.Id, creditApplication.Sales_Up__c, creditApplication.dealer__Buyer_Account__c, CREDIT_APP_COMPLETED_LOG_TYPE);
        
        //insert trafficLog;
    }
    
    public void save()
    {
        try
        {
            system.debug('saving creadit application -- nb');
            if (initialPaycallStatuses.contains(creditApplication.Credit_Application_Status__c))
            {
                reverseCreditApplicationToInProgress();
            }
            
            if (createCobuyerOnSave)
            {
                createCoBuyerRecord();
            }
            
            List<Attachment> creditApplicationAttachments = [
                SELECT Body, Name, ContentType
                FROM Attachment
                WHERE ParentId = :creditApplication.Id
                LIMIT 1
            ];
            
            delete creditApplicationAttachments;
            upsert creditApplication;
            
            this.saveReferences(); //NB - 20180422
        }
        catch (Exception e)
        {
            errorMessage = e.getMessage();
        }
    }
    
    private void reverseCreditApplicationToInProgress()
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
            errorMessage = e.getMessage();
        }
    }


    *//***********************************************************************************************
    **   REFERENCES SECTION
    ***********************************************************************************************//*
    @TestVisible private List<Schema.Contact> refs = new List<Schema.Contact>();
    public List<Schema.Contact> getReferences() {
        if (this.refs == null || this.refs.size() == 0) {
            Id contactRefRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Reference').getRecordTypeId();
            
            if (this.creditApplication.Id != null) {
                this.refs = [
                    SELECT id, ca_Reference__c, RecordTypeId, FirstName, LastName, MailingStreet, MailingCity,
                        MailingState, MailingPostalCode, Phone
                    FROM Contact
                    WHERE ca_Reference__c = :this.creditApplication.Id
                ];
            }
            
            Integer addCount = ( this.refs.size() < MAXIMUM_CREDIT_REFERENCES ? MAXIMUM_CREDIT_REFERENCES - this.refs.size() : MAXIMUM_CREDIT_REFERENCES);
            
            for (Integer idx = 0; idx < addCount; idx++) {
                this.refs.add(new Schema.Contact(
                    ca_Reference__c = creditApplication.Id,
                    RecordTypeId = contactRefRecTypeId
                ));
            }
        
        }
        return refs;
    }
    
    @TestVisible private void saveReferences() {
        
        system.debug('saving references');
        List<Schema.Contact> saveThese = new List<Schema.Contact>();
        
        for (Schema.Contact cs : refs) {
            if (String.IsNotBlank(cs.FirstName) && (String.IsNotBlank(cs.LastName) && String.IsNotBlank(cs.Phone)) ) {
                cs.ca_Reference__c = this.creditApplication.Id;
                saveThese.add(cs);
            }
        }
        
        //Must have a minimum of 4 Credit References from NON BDC Applications
        Set<String> excludedProfiles = new set<String>{'BCD Manager', 'ISC'}; //, 'System Administrator'
        Set<Id> excludedIds = usas_UtilityMethods.getProfileIdByName(excludedProfiles);
        
        if ( ! excludedIds.Contains(UserInfo.getProfileId()) && saveThese.size() < 4) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Business rule requires at least four (4) references.  Record(s) not saved.'));
        } else if ( saveThese.size() > 0) {
            upsert saveThese;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'References Updated!'));
        }
    }
    
    private Boolean isAllInformation(Schema.Contact cs) {
        return (String.IsBlank(cs.FirstName) || String.IsBlank(cs.LastName) || String.IsBlank(cs.Phone) ? false : true );
    }
    
    @TestVisible private Integer validateReferences() {
        
        Integer numReferences = 0;
        
        for (Schema.Contact cs : this.refs) {
            if (this.isAllInformation(cs)) {
                numReferences++;
            }
        }
        
        return numReferences;
    
    }*/

    /***********************************************************************************************
    **   REFERENCES SECTION
    ***********************************************************************************************/
}