@isTest
private class CreditAppBoxComponentControllerTest
{
	@testSetup
	private static void init()
	{
		insert new Years_Requiring_Previous_Information__c(
			Housing_Information__c = '1,2,3,4',
			Employer_Information__c = '1,2,3,4',
			Name = 'Standard Settings'
		);

		insert new Sales_Portal_Integration_Settings__c(
			Name = 'Standard Settings',
			Login__c = 'Test',
			Password__c = 'Test',
			Authentification_URL__c = 'Test.auth.com',
			Get_Credit_Applications_Statuses_URL__c = 'Test.getStatuses.com'
		);

		Location__c storeLocation = new Location__c(
			Name = 'Test Name',
			Company_Number__c = 'scscs',
			City__c = 'City',
			Postal_Code__c = '74746'
		);

		insert storeLocation;
		
		Account source = new Account(
			FirstName = 'Test Source',
			LastName = 'Test'
		);
		
		insert source;
		
		Schema.Contact buyer =  new Schema.Contact(
			FirstName = 'Test Buyer',
			LastName = 'Test Buyer',
			MiddleName = 'Test Buyer',
			HomePhone = '12345678',
			MobilePhone = '12345678',
			Email = 'test@test.test',
			Driver_License_Number__c = '12345678'
		);
		
		Schema.Contact cobuyer = new Schema.Contact(
			FirstName = 'Test Co-Buyer',
			LastName = 'Test Co-Buyer',
			MiddleName = 'Test Co-Buyer'
		);
		
		insert new List<Schema.Contact>{buyer, cobuyer};
		
		Opportunity opportunity = new Opportunity(
			Name = 'test',
			StageName = 'Qualified',
			CloseDate = Date.today().addDays(10),
			Lead_Type__c = 'BDC',
			Lead_Status__c = 'Open',
			Buyer_Contact__c = buyer.Id,
			AccountId = source.Id
		);
		
		insert opportunity;
		
		Credit_Application__c creditApp =  new Credit_Application__c(
			Buyer__c = buyer.Id,
			Co_Buyer__c = cobuyer.Id,
			Opportunity__c = opportunity.Id,
			Repeat_Customer__c = '1 Prior Purchase',
			Co_App_Repeat_Customer__c = '1 Prior Purchase',
			Sales_Portal_Creation_Date__c = Date.today().addDays(-3),
			Sales_Portal_ID__c = '12',
			Credit_Application_Status__c = 'In Progress'
		);
		
		insert creditApp;
		
		insert new List<Residence__c>{
			new Residence__c(
				Address_Duration_Years__c = '1',
				Is_Current_Residence__c = true,
				Is_Primary_Buyer__c = true,
				Credit_Application__c = creditApp.Id
			),
			new Residence__c(
				Address_Duration_Years__c = '1',
				Is_Current_Residence__c = true,
				Is_Primary_Buyer__c = false,
				Credit_Application__c = creditApp.Id
			)
		};
		
		insert new List<Employment__c>{
			new Employment__c(
				Employer_Duration_Years__c = '1',
				Other_Income__c = 100,
				Is_Current_Employment__c = true,
				Is_Primary_Buyer__c = true,
				Credit_Application__c = creditApp.Id
			),
			new Employment__c(
				Employer_Duration_Years__c = '1',
				Other_Income__c = 100,
				Is_Current_Employment__c = true,
				Is_Primary_Buyer__c = false,
				Credit_Application__c = creditApp.Id
			)
		};
	}

	@isTest
	private static void testGetSalesportalAccessToken()
	{
		String accessToken;

		Test.startTest();
			accessToken = CreditAppBoxComponentController.getSalesPortalAccessToken();
		Test.stopTest();

		System.assertNotEquals(null, accessToken);
	}

	@isTest
	private static void testGetUserProfile()
	{
		String profileName;

		Test.startTest();
			profileName = CreditAppBoxComponentController.getUserProfile();
		Test.stopTest();

		System.assertNotEquals(null, profileName);
	}

	@isTest static void testGetOpportunity()
	{
		Opportunity opportunity = [
			SELECT Id
			FROM Opportunity
			LIMIT 1
		];

		Test.startTest();
			opportunity = CreditAppBoxComponentController.getOpportunity(opportunity.Id);
		Test.stopTest();

		System.assertNotEquals(null, opportunity.Buyer_Contact__c);
	}

	@isTest static void testGetCreditApplication()
	{
		Opportunity opportunity = [
			SELECT Id
			FROM Opportunity
			LIMIT 1
		];

		String creditApplication;

		Test.startTest();
			creditApplication = CreditAppBoxComponentController.getCreditApplication(opportunity.Id, 'access token');
		Test.stopTest();

		System.assertNotEquals(null, creditApplication);
	}
}