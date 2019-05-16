@isTest
public class CreditAppEditComponentControllerTest
{
	private static final String BUYER_SSN = '1234567890';
	private static final String CO_BUYER_SSN = '1211111111';
	
	@testSetup
	static void setup()
	{
        insert new Sales_Portal_Integration_Settings__c(Name = 'Standard Settings', Login__c = 'it@usauto-sales.com',
                Password__c = 'IntegrationAX2',Save_Short_Credit_Score_App_URL__c = 'https://ws.usautosales.info/web/portal/SaveShortCreditScoreApp',
                Save_App_Data_URL__c = 'https://ws.usautosales.info/web/portal/SaveCreditScoreApp',
                Get_Credit_Applications_Statuses_URL__c = 'https://ws.usautosales.info/web/portal/GetAllAppStatusComments?ids={ID}',
                Get_Adjusted_Credit_Score_URL__c = 'https://ws.usautosales.info/web/portal/GetAdjustedCreditScore?ids={ID}',
                UpdateLetterPrintedFieldOnSP_URL__c = 'https://ws.usautosales.info/web/portal/PrintLetter',
                GetCalculatorData_URL__c = 'https://ws.usautosales.info/web/portal/GetCalculatorData?id={ID}&isJoint={ISJOINT}',
                Add_User_URL__c = 'https://ws.usautosales.info/web/portal/AddUser',
                Reverse_To_In_Progress_URL__c = 'https://ws.usautosales.info/web/portal/SetInitialPaycallToInProgress',
                Authentification_URL__c = 'https://ws.usautosales.info/web/auth/Authenticate');

		Contact buyer = new Contact(LastName = 'Buyer', SocialSecurityNumber__c = BUYER_SSN);
		Contact cobuyer = new Contact(LastName = 'Co-Buyer');
		insert new List<Contact>{buyer, cobuyer};
            
        List<Opportunity> opp = new List<Opportunity>{
                new Opportunity(Name = 'Test', StageName = 'Qualification', CloseDate = Date.today().addDays(1), Buyer_Contact__c = buyer.Id),
                new Opportunity(Name = 'Test1', StageName = 'Qualification', CloseDate = Date.today().addDays(2), Buyer_Contact__c = buyer.Id)
        };
		insert opp;
		
		List<Credit_Application__c> creditApp = new List<Credit_Application__c>{
                new Credit_Application__c(
                        Opportunity__c = opp[0].Id, Buyer__c = buyer.Id,
                        Co_Buyer__c =cobuyer.Id,
                        Sales_Portal_Creation_Date__c = Date.today().addDays(-40)
                ),
                new Credit_Application__c(
                        Opportunity__c = opp[1].Id, Buyer__c = buyer.Id,
                        Co_Buyer__c =cobuyer.Id,
                        Sales_Portal_Creation_Date__c = Date.today().addDays(-20)
                )
        };
		insert creditApp;
        Datetime oldDatetime = Datetime.now().addDays(-130);
        Test.setCreatedDate(creditApp[1].Id, oldDatetime);

        Residence__c residence = new Residence__c(Credit_Application__c = creditApp[0].Id, Is_Primary_Buyer__c = true, Is_Current_Residence__c = true);
		insert residence;

		Employment__c employment = new Employment__c(Credit_Application__c = creditApp[0].Id, Is_Primary_Buyer__c = true, Is_Current_Employment__c = true);
		insert employment;

	}
	
	@isTest 
	static void test_getCreditApplication()
	{
        Credit_Application__c cac = [SELECT Id, CreatedDate, Buyer__c, Opportunity__c FROM Credit_Application__c WHERE CreatedDate = TODAY LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Id =: cac.Opportunity__c LIMIT 1];

        System.debug('The CA: ' + cac + '~~~' + Date.valueOf(cac.CreatedDate).daysBetween(Date.today()) );

		Test.startTest();
			Object jsonWrapper = CreditAppEditComponentController.getCreditApplication(opp.Id);
		Test.stopTest();
		
		CreditAppEditComponentController.CreditAppWrapper wrapper = (CreditAppEditComponentController.CreditAppWrapper) JSON.deserialize((String)jsonWrapper,
			CreditAppEditComponentController.CreditAppWrapper.class);
		System.assertEquals(wrapper.creditApplication.Id, [SELECT Id FROM Credit_Application__c WHERE Opportunity__c =: opp.Id LIMIT 1].Id, 'Wrong credit app id returned');
	}

    @isTest
    static void test_getCreditApplicationOld()
    {
        Credit_Application__c cac = [SELECT Id, CreatedDate, Buyer__c, Opportunity__c FROM Credit_Application__c WHERE CreatedDate != TODAY  LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Id =: cac.Opportunity__c LIMIT 1];

        System.debug('The CA 1: ' + cac + '~~~' + Date.valueOf(cac.CreatedDate).daysBetween(Date.today()) );

        Test.startTest();
        Object jsonWrapper = CreditAppEditComponentController.getCreditApplication(opp.Id);
        Test.stopTest();

        CreditAppEditComponentController.CreditAppWrapper wrapper = (CreditAppEditComponentController.CreditAppWrapper) JSON.deserialize((String)jsonWrapper,
                CreditAppEditComponentController.CreditAppWrapper.class);
        System.assertEquals(wrapper.creditApplication.Id, [SELECT Id FROM Credit_Application__c WHERE Opportunity__c =: opp.Id LIMIT 1].Id, 'Wrong credit app id returned');
    }

	@isTest
	static void test_getPicklistvalues()
	{
		Test.startTest();
			Object obj = CreditAppEditComponentController.getAllPicklistsByName();
		Test.stopTest();
	}

	@isTest
	static void test_getCustomers()
	{
		List<Contact> customers = [SELECT Id FROM Contact];
		
		Test.startTest();
			List<Contact> result = CreditAppEditComponentController.getCustomers(customers.get(0).Id, customers.get(1).Id);
		Test.stopTest();
		
		System.assertEquals(2, result.size(), 'Wrong amount of returned customers');
	}
	
	@isTest
	static void test_getCustomersBySSN()
	{
		Test.startTest();
			CreditAppEditComponentController.SearchResult result = CreditAppEditComponentController.getAccountsBySocialSecurityNumber('1234555567');
		Test.stopTest();
		
		System.assertEquals(true, result.canContinue);
	}
	
	@isTest
	static void test_searchActiveApplications()
	{
		Contact cobuyer = new Contact(LastName = 'Co-Buyer', SocialSecurityNumber__c = CO_BUYER_SSN);
		insert cobuyer;
		
		Opportunity opp = [SELECT Id FROM Opportunity WHERE CreatedDate = TODAY LIMIT 1];
		Credit_Application__c creditApp = new Credit_Application__c(Co_Buyer__c = cobuyer.Id, Opportunity__c = opp.Id);
		insert creditApp;
		
		Test.startTest();
			CreditAppEditComponentController.SearchResult result = CreditAppEditComponentController.searchActiveApplications(cobuyer.Id, CO_BUYER_SSN);
		Test.stopTest();
		
		System.assertEquals(Label.Co_Application_Was_Found_With_SalesUp, result.coBuyerMessage);
	}

    //NB 2019-03-16 Updated
	@isTest
	static void test_save() {

        CreditAppEditComponentController.CreditAppWrapper wrapper = new CreditAppEditComponentController.CreditAppWrapper();
        List<Contact> customers = [
                SELECT Id, Email,FirstName, HomePhone,LastName, MiddleName,MobilePhone,
                        SocialSecurityNumber__c,Is_Military__c,Military_Status__c
                FROM Contact
        ];
        wrapper.creditApplication = [SELECT Id, Opportunity__c, Sales_Portal_ID__c, Currently_In_Bankruptcy__c FROM Credit_Application__c LIMIT 1];
        wrapper.buyer = customers.get(0);
        wrapper.coBuyer = customers.get(1);
        wrapper.currentHousing = new Residence__c(Is_Primary_Buyer__c = true, Address_City__c = 'Duluth',
                Address_Street__c = 'Test Street', House_Number__c = '12', Housing_Type__c = 'Own',
                Address_Duration_Months__c = '11', Address_Duration_Years__c = '7',
                Address_State__c = 'GA', Address_Street_Type__c = 'Annex', Address_Zip__c = '30097');
        wrapper.coAppCurrentHousing = new Residence__c(Is_Primary_Buyer__c = false, Address_City__c = 'Duluth',
                Address_Street__c = 'Test Street', House_Number__c = '12', Housing_Type__c = 'Own',
                Address_Duration_Months__c = '11', Address_Duration_Years__c = '7',
                Address_State__c = 'GA', Address_Street_Type__c = 'Court', Address_Zip__c = '30097');
        wrapper.coAppPreviousHousing = new Residence__c (Is_Primary_Buyer__c = false, Address_City__c = 'Lawrenceville',
                Address_Street__c = 'Test Street', House_Number__c = '12', Housing_Type__c = 'Own',
                Address_Duration_Months__c = '11', Address_Duration_Years__c = '7',
                Address_State__c = 'GA', Address_Street_Type__c = 'Court', Address_Zip__c = '30098');
        wrapper.previousEmployment = new Employment__c(Is_Primary_Buyer__c = true, Employer_Duration_Months__c = '4',
                Employer_Duration_Years__c = '8', Other_Income__c = 1500, Salary_Type__c = 'Weekly',
                Applicant_Net_Period_Paycheck__c = 875, Employer_Phone__c = '770-909-7890');
        wrapper.coAppCurrentEmployment = new Employment__c(Is_Primary_Buyer__c = false, Employer_Duration_Months__c = '4',
                Employer_Duration_Years__c = '8', Other_Income__c = 1900, Salary_Type__c = 'Weekly',
                Applicant_Net_Period_Paycheck__c = 875, Employer_Phone__c = '770-949-7890');
        wrapper.coAppPreviousEmployment = new Employment__c(Is_Primary_Buyer__c = false, Employer_Duration_Months__c = '4',
                Employer_Duration_Years__c = '8', Other_Income__c = 1300, Salary_Type__c = 'Weekly',
                Applicant_Net_Period_Paycheck__c = 875, Employer_Phone__c = '770-909-1190');
        wrapper.references = new List<Contact>{
                new Contact(LastName = 'Test Ref 1'), new Contact(LastName = 'Test Ref 2'), new Contact(LastName = 'Test Ref 3'), new Contact(LastName = 'Test Ref 4')
        };
        wrapper.isPrevBuyerHousingDeleted = false;
        wrapper.isPrevCoBuyerHousingDeleted = false;
        wrapper.isPrevBuyerEmploymentDeleted = false;
        wrapper.isPrevCoBuyerEmploymentDeleted = false;

        //NB: 2019-03-16 --make a BDC User
        UserRole tmpRole = new UserRole(Name='BDC User', DeveloperName='HelpDesk');
        Insert tmpRole;

        String uniqueUserName = 'bdcuser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name = 'ISC New'];
        //NB: 2019-03-17 -- THIS IS RIDICULOUS, I HAVE TO MAKE THE EMAIL ADDRESS emailsavetest@email.com SO THAT IT DOESN'T BREAK USERTRIGGERSERVICE->emailToSalesForceUser
        User u = new User(Alias = 'standt', Email = 'emailsavetest@email.com',
                EmailEncodingKey = 'UTF-8', LastName = 'bdcTesting', FirstName = 'bdcTestFirst', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = p.Id,
                TimeZoneSidKey = 'America/New_York', UserRoleId = tmpRole.Id,
                Username = uniqueUserName);
        insert u;
        System.assert(u.Id != null,'User cannot be null after insert');

        Test.startTest();
        System.runAs(u) {
            Id oppId = CreditAppEditComponentController.saveCreditApplication(JSON.serialize(wrapper), true);
            Test.stopTest();

            System.assertEquals(wrapper.creditApplication.Opportunity__c, oppId, 'Wrong returned opportunity Id');
            System.assertEquals(4, [SELECT COUNT() FROM Residence__c WHERE Credit_Application__c = :wrapper.creditApplication.Id], 'Wrong amount of saved residences');
            System.assertEquals(4, [SELECT COUNT() FROM Employment__c WHERE Credit_Application__c = :wrapper.creditApplication.Id], 'Wrong amount of saved employments');
        }
    }

    //NB 2019-03-16 added -- Necessary to get better code coverage.
    @isTest
    static void test_reverseCreditAppStatus() {
        CreditAppEditComponentController.CreditAppWrapper wrapper = new CreditAppEditComponentController.CreditAppWrapper();
        List<Contact> customers = [
                SELECT Id, Email,FirstName, HomePhone,LastName, MiddleName,MobilePhone,
                        SocialSecurityNumber__c,Is_Military__c,Military_Status__c
                FROM Contact
        ];
        wrapper.creditApplication = [
                SELECT Id, Opportunity__c, Sales_Portal_ID__c,
                        Currently_In_Bankruptcy__c, Credit_Application_Status__c
                FROM Credit_Application__c
                LIMIT 1
        ];
        wrapper.creditApplication.Sales_Portal_ID__c = '10000';  //DEFAULT VALUE
        wrapper.creditApplication.Credit_Application_Status__c = 'Initial Paycall';
        wrapper.buyer = customers.get(0);
        wrapper.coBuyer = customers.get(1);
        wrapper.currentHousing = new Residence__c(Is_Primary_Buyer__c = true, Address_City__c = 'Duluth',
                Address_Street__c = 'Test Street', House_Number__c = '12', Housing_Type__c = 'Own',
                Address_Duration_Months__c = '11', Address_Duration_Years__c = '7',
                Address_State__c = 'GA', Address_Street_Type__c = 'Annex', Address_Zip__c = '30097');
        wrapper.coAppCurrentHousing = new Residence__c(Is_Primary_Buyer__c = false, Address_City__c = 'Duluth',
                Address_Street__c = 'Test Street', House_Number__c = '12', Housing_Type__c = 'Own',
                Address_Duration_Months__c = '11', Address_Duration_Years__c = '7',
                Address_State__c = 'GA', Address_Street_Type__c = 'Court', Address_Zip__c = '30097');
        wrapper.coAppPreviousHousing = new Residence__c (Is_Primary_Buyer__c = false, Address_City__c = 'Lawrenceville',
                Address_Street__c = 'Test Street', House_Number__c = '12', Housing_Type__c = 'Own',
                Address_Duration_Months__c = '11', Address_Duration_Years__c = '7',
                Address_State__c = 'GA', Address_Street_Type__c = 'Court', Address_Zip__c = '30098');
        wrapper.previousEmployment = new Employment__c(Is_Primary_Buyer__c = true, Employer_Duration_Months__c = '4',
                Employer_Duration_Years__c = '8', Other_Income__c = 1500, Salary_Type__c = 'Weekly',
                Applicant_Net_Period_Paycheck__c = 875, Employer_Phone__c = '770-909-7890');
        wrapper.coAppCurrentEmployment = new Employment__c(Is_Primary_Buyer__c = false, Employer_Duration_Months__c = '4',
                Employer_Duration_Years__c = '8', Other_Income__c = 1900, Salary_Type__c = 'Weekly',
                Applicant_Net_Period_Paycheck__c = 875, Employer_Phone__c = '770-949-7890');
        wrapper.coAppPreviousEmployment = new Employment__c(Is_Primary_Buyer__c = false, Employer_Duration_Months__c = '4',
                Employer_Duration_Years__c = '8', Other_Income__c = 1300, Salary_Type__c = 'Weekly',
                Applicant_Net_Period_Paycheck__c = 875, Employer_Phone__c = '770-909-1190');
        wrapper.references = new List<Contact>{
                new Contact(LastName = 'Test Ref 1'), new Contact(LastName = 'Test Ref 2'), new Contact(LastName = 'Test Ref 3'), new Contact(LastName = 'Test Ref 4')
        };
        wrapper.isPrevBuyerHousingDeleted = false;
        wrapper.isPrevCoBuyerHousingDeleted = false;
        wrapper.isPrevBuyerEmploymentDeleted = false;
        wrapper.isPrevCoBuyerEmploymentDeleted = false;
        wrapper.isPrevBuyerHousingDeleted = false;

        wrapper.previousHousing = new Residence__c (Is_Primary_Buyer__c = false, Address_City__c = 'Snellville',
                Address_Street__c = 'Test Street', House_Number__c = '12', Housing_Type__c = 'Own',
                Address_Duration_Months__c = '11', Address_Duration_Years__c = '7',
                Address_State__c = 'GA', Address_Street_Type__c = 'Court', Address_Zip__c = '30098');
        wrapper.currentEmployment = new Employment__c(Is_Primary_Buyer__c = true, Employer_Duration_Months__c = '4',
                Employer_Duration_Years__c = '6', Other_Income__c = 150, Salary_Type__c = 'Weekly',
                Applicant_Net_Period_Paycheck__c = 875, Employer_Phone__c = '770-909-7890');

        //NB: 2019-03-16 --make a BDC User
        UserRole tmpRole = new UserRole(Name = 'BDC User', DeveloperName = 'HelpDesk');
        Insert tmpRole;

        String uniqueUserName = 'bdcuser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name = 'ISC New'];
        //NB: 2019-03-17 -- THIS IS RIDICULOUS, I HAVE TO MAKE THE EMAIL ADDRESS emailsavetest@email.com SO THAT IT DOESN'T BREAK USERTRIGGERSERVICE->emailToSalesForceUser
        User u = new User(Alias = 'standt', Email = 'emailsavetest@email.com',
                EmailEncodingKey = 'UTF-8', LastName = 'bdcTesting', FirstName = 'bdcTest', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = p.Id,
                TimeZoneSidKey = 'America/New_York', UserRoleId = tmpRole.Id,
                Username = uniqueUserName);
        insert u;
        System.assert(u.Id != null,'User cannot be null after insert');

        Test.startTest();
        System.runAs(u) {
            Id oppId = CreditAppEditComponentController.saveCreditApplication(JSON.serialize(wrapper), true);
            Test.stopTest();

            System.assertEquals(wrapper.creditApplication.Opportunity__c, oppId, 'Wrong returned opportunity Id');
            System.assert( [SELECT COUNT() FROM Residence__c WHERE Credit_Application__c = :wrapper.creditApplication.Id] >= 4, 'Wrong amount of saved residences');
            System.assert([SELECT COUNT() FROM Employment__c WHERE Credit_Application__c = :wrapper.creditApplication.Id] >= 4, 'Wrong amount of saved employments');
        }
    }

    @isTest
    static void test_CA_Refresh() {
        Opportunity opp = [SELECT Id, StageName FROM Opportunity LIMIT 1];
        opp.StageName = 'Qualify';
        update opp;

        Credit_Application__c cac = [SELECT Id, Sales_Portal_Creation_Date__c  FROM Credit_Application__c LIMIT 1];
        cac.Sales_Portal_Creation_Date__c = Date.today().addDays(-90);
        update cac;

        System.assert(cac.Sales_Portal_Creation_Date__c != null, 'Credit Application Portal Creation Date should not be blank.');

        Test.startTest();
        String resultString = '[' + (String)CreditAppEditComponentController.getCreditApplication(opp.Id) + ']';
        Test.stopTest();

        System.debug('serialized string: ' + resultString);

        List<CreditAppEditComponentController.CreditAppWrapper> result =
                (List<CreditAppEditComponentController.CreditAppWrapper>)JSON.deserialize( resultString,
                        List<CreditAppEditComponentController.CreditAppWrapper>.class);

        System.assertEquals(result[0].creditApplication.Sales_Portal_Creation_Date__c, null, 'Credit Application should be reset.');

    }
}