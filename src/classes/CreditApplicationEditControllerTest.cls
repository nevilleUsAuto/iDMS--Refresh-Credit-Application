@isTest
private class CreditApplicationEditControllerTest
{
	/*private static void init(Boolean isCreation)
	{
		insert new Sales_Portal_Integration_Settings__c(
			Name = 'Standard Settings',
			Login__c = 'Test',
			Password__c = 'Test',
			Authentification_URL__c = 'Test.auth.com',
			Reverse_To_In_Progress_URL__c = 'Test.reverseToInProgress.com',
			Save_Short_Credit_Score_App_URL__c = 'Test.saveShortApp.com'
		);

		insert new Years_Requiring_Previous_Information__c
		(
			Name = 'Standard Settings',
			Housing_Information__c = '0,1,2,3,4',
			Employer_Information__c = '0,1,2,3,4'
		);

		List<Account> accounts = new List<Account>
		{
			new Account
			(
				FirstName = 'Test Buyer',
				MiddleName = 'Test Buyer',
				LastName = 'Test Buyer',
				PersonHomePhone = '12345678',
				PersonMobilePhone = '12345678',
				PersonEmail = 'test@test.test',
				dealer__Drivers_License_Number__pc = '12345678',
				dealer__Drivers_License_State__pc = 'GA'
			),

			new Account
			(
				FirstName = 'Test Co-Buyer',
				MiddleName = 'Test Co-Buyer',
				LastName = 'Test Co-Buyer',
				PersonHomePhone = '12345678',
				PersonMobilePhone = '12345678',
				PersonEmail = 'test@test.test',
				dealer__Drivers_License_Number__pc = '12345678',
				dealer__Drivers_License_State__pc = 'GA'
			)
		};
		insert accounts;

		dealer__Sales_Up__c salesUp = new dealer__Sales_Up__c
		(
			dealer__FirstName__c = 'Test',
			dealer__LastName__c = 'Test',
			dealer__Phone__c = '12345678',
			dealer__Email__c = 'test@test.test',
			dealer__Lead_Type__c = 'BDC',
			dealer__Lead_Status__c = 'Open',
			dealer__Customer_Account__c = accounts[0].Id,
			dealer__Co_Buyer__c = accounts[1].Id
		);
		insert salesUp;

		dealer__Credit_Application__c creditApplication = new dealer__Credit_Application__c
		(
			dealer__First_Name__c = 'Test Buyer',
			dealer__Middle_Name__c = 'Test Buyer',
			dealer__Last_Name__c = 'Test Buyer',
			dealer__Co_App_First_Name__c = 'Test Co-Buyer',
			dealer__Co_App_Last_Name__c = 'Test Co-Buyer',
			dealer__Home_Phone__c = '12345678',
			dealer__Mobile_Phone__c = '12345678',
			dealer__Email_Address__c = 'test@test.test',
			dealer__Driver_License_No__c = '12345678',
			Driver_License_State__c = 'GA',
			Current_Address_Duration_Years__c = '1',
			Present_Employer_Duration_Years__c = '1',
			Repeat_Customer__c = '1 Prior Purchase',
			Co_App_Current_Address_Duration_Years__c = '1',
			Co_App_Present_Employer_Duration_Years__c = '1',
			Co_App_Repeat_Customer__c = '1 Prior Purchase',
			dealer__Buyer_Account__c = accounts[0].Id,
			dealer__Co_Buyer_Account__c = accounts[1].Id,
			Sales_Up__c = salesUp.Id,
			Sales_Portal_ID__c = '220'
		);
		insert creditApplication;
		
		PageReference editPage = Page.CreditApplicationEdit;

		if (isCreation)
		{
			editPage.getParameters().put('isCreation', 'true');
			editPage.getParameters().put('salesUpId', salesUp.Id);
		}
		else
		{
			editPage.getParameters().put('isCreation', 'false');
			editPage.getParameters().put('salesUpId', salesUp.Id);
			editPage.getParameters().put('creditAppId', creditApplication.Id);
			editPage.getParameters().put('mainFieldName', 'Current_Address_Duration_Years__c');
			editPage.getParameters().put('isCobuyerViewed', 'false');
		}

		Test.setCurrentPage(editPage);
	}
	
	@isTest static void testCreditApplicationEditControllerConstructorOnCreation()
	{
		init(true);

		Test.startTest();
		CreditApplicationEditController controller = new CreditApplicationEditController();
		Test.stopTest();

		System.assertEquals('Test Buyer', controller.creditApplication.dealer__First_Name__c);
		System.assertEquals('Test Co-Buyer', controller.creditApplication.dealer__Co_App_First_Name__c);
	}

	@isTest static void testCreditApplicationEditControllerConstructorOnEdit()
	{
		init(false);

		Test.startTest();
		CreditApplicationEditController controller = new CreditApplicationEditController();
		Test.stopTest();

		System.assertEquals('Test Buyer', controller.creditApplication.dealer__First_Name__c);
		System.assertEquals('Test Co-Buyer', controller.creditApplication.dealer__Co_App_First_Name__c);
	}

	@isTest static void testCreditApplicationFieldsValidation()
	{
		init(false);

		CreditApplicationEditController controller = new CreditApplicationEditController();

		Test.startTest();
		controller.validateCreditApplicationFields();
		Test.stopTest();

		System.assertEquals(true, controller.requiredEmptyFieldsJSON != null);
	}

	@isTest static void testClearValidationResults()
	{
		init(false);

		CreditApplicationEditController controller = new CreditApplicationEditController();

		Test.startTest();
		controller.clearValidationResults();
		Test.stopTest();

		System.assertEquals(true, controller.requiredEmptyFieldsJSON == null);
	}

	@isTest static void testCreateRelatedCoBuyer()
	{
		init(false);

		CreditApplicationEditController controller = new CreditApplicationEditController();
		controller.creditApplication.dealer__Co_Buyer_Account__c = null;

		Test.startTest();
		controller.createCoBuyerRecord();
		Test.stopTest();

		System.assertEquals(true, controller.creditApplication.dealer__Co_Buyer_Account__c != null);
	}

	@isTest static void testSaveAsReadyToSubmit()
	{
		init(false);

		CreditApplicationEditController controller = new CreditApplicationEditController();

		Test.startTest();
		controller.saveAsReadyToSubmit();
		Test.stopTest();

		System.assertEquals(true, controller.creditApplication.Ready_To_Submit__c);
	}

	@isTest static void testSetDefaultValuesForPreviousHousingFields()
	{
		init(false);

		CreditApplicationEditController controller = new CreditApplicationEditController();

		controller.creditApplication.Current_Address_Duration_Years__c = '10+';
		controller.creditApplication.Co_App_Current_Address_Duration_Years__c = '10+';

		Test.startTest();
		controller.setDefaultValuesForDependentFields();
		Test.stopTest();

		System.assertEquals(null, controller.creditApplication.Previous_Address_1_State__c);
		System.assertEquals(null, controller.creditApplication.dealer__Co_App_Previous_Employer_1__c);
	}

	@isTest static void testLogSocialSecurityNumberView()
	{
		init(false);

		CreditApplicationEditController controller = new CreditApplicationEditController();

		Test.startTest();
		controller.logSocialSecurityNumberView();
		Test.stopTest();

		List<TrafficLog__c> trafficLogs = [
			SELECT Id
			FROM TrafficLog__c
		];

		System.assert(trafficLogs.size() > 0, 'Traffic log should be created.');
	}

	@isTest static void testReverseToInProgress()
	{
		init(false);

		CreditApplicationEditController controller = new CreditApplicationEditController();
		controller.creditApplication.Credit_Application_Status__c = SalesPortalUtils.CREDIT_APP_STATUS_INITIAL_PAYCALL;
		controller.creditApplication.dealer__Co_Buyer_Account__c = null;

		controller.createCobuyerOnSave = true;

		Test.startTest();
		controller.save();
		Test.stopTest();

		System.assertEquals(SalesPortalUtils.CREDIT_APP_STATUS_IN_PROGRESS, controller.creditApplication.Credit_Application_Status__c);
	}

	//NB: No Previous test for this method
	@IsTEst static void testLoadDataFromRelatedRecord() {
		init(true);
		CreditApplicationEditController controller = new CreditApplicationEditController();

		Test.startTest();

		controller.loadDataFromRelatedRecords();

		Test.stopTest();
	}

	@IsTest static void testReferencesAllGood() {
		Integer refCount = 6;
		Integer ctr = 0;

		init(false);
		CreditApplicationEditController controller = new CreditApplicationEditController();

		Test.startTest();

		controller.getReferences();

		for(Schema.Contact ct : controller.refs){
			ct.FirstName = 'RefFirst' + String.valueOf(++ctr);
			ct.LastName = 'RefFirst' + String.valueOf(ctr);
			ct.Phone = '212-314-123' + String.valueOf(ctr);
		}

		//controller.saveReferences();

		Test.stopTest();

		System.assertEquals(controller.refs.size(), refCount, 'invalid number of references.');


	}*/
/*
	@IsTest static void testReferencesBusinessRuleViolation() {
		Integer refCount = 3; // business rule minimum 4.

		init(false);
		CreditApplicationEditController controller = new CreditApplicationEditController();

		Test.startTest();

		controller.getReferences();

		for (Integer ctr=0; ctr < refCount; ctr++ ) {
			controller.refs[ctr].FirstName = 'RefFirst' + String.valueOf(ctr);
			controller.refs[ctr].LastName = 'RefFirst' + String.valueOf(ctr);
			controller.refs[ctr].Phone = '212-314-123' + String.valueOf(ctr);
		}

		controller.saveReferences();

		Test.stopTest();

		System.assertEquals(controller.validateReferences(), 3, 'invalid number of references.');

	}

	@IsTest static void testReferencesMissingFields() {

		init(false);
		CreditApplicationEditController controller = new CreditApplicationEditController();

		Test.startTest();

		controller.getReferences();

		controller.refs[0].FirstName = '';
		controller.refs[0].LastName = 'RefLast1';
		controller.refs[0].Phone = '212-314-1231';

		controller.refs[1].FirstName = 'RefFirst2';
		controller.refs[1].LastName = '';
		controller.refs[1].Phone = '212-314-1232';

		controller.refs[2].FirstName = 'RefFirst3';
		controller.refs[2].LastName = 'RefLast3';
		controller.refs[2].Phone = '';

		controller.refs[3].FirstName = 'RefFirst3';
		controller.refs[3].LastName = 'RefLast3';
		controller.refs[3].Phone = '212-314-1234';

		controller.saveReferences();

		Test.stopTest();

		System.assertEquals(controller.validateReferences(), 1, 'invalid number of references.');


	}
	*/
}