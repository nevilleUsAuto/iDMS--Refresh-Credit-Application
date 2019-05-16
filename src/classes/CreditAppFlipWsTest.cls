@isTest
private class CreditAppFlipWsTest
{
	@testSetup
	private static void init()
	{
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
			Driver_License_Number__c = '12345678',
			Driver_License_Expiration_Date__c = Date.today().addDays(10),
			Birthdate = Date.today().addYears(-20)
		);
		
		insert new List<Schema.Contact>{buyer};
		
		Opportunity opportunity = new Opportunity(
			Name = 'test',
			StageName = 'Qualified',
			CloseDate = Date.today().addDays(10),
			Lead_Type__c = 'BDC',
			Lead_Status__c = 'Open',
			AccountId = source.Id
		);
		
		insert opportunity;
		
		Credit_Application__c creditApp =  new Credit_Application__c(
			Buyer__c = buyer.Id,
			Opportunity__c = opportunity.Id,
			Repeat_Customer__c = '1 Prior Purchase',
			Co_App_Repeat_Customer__c = '1 Prior Purchase',
			Store_Location__c = storeLocation.Id,
			Sales_Portal_ID__c = '5'
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
	private static void testFlip()
	{
		Credit_Application__c creditApplication = [
			SELECT Buyer__c, Co_Buyer__c, Sales_Portal_ID__c
			FROM Credit_Application__c
			LIMIT 1
		];

		Test.startTest();
		CreditAppFlipWs.flipCreditApplication(Integer.valueOf(creditApplication.Sales_Portal_ID__c), 8, 'testreason');
		Test.stopTest();

		Credit_Application__c flippedCreditApplication = [
			SELECT Buyer__c, Co_Buyer__c, Sales_Portal_ID__c
			FROM Credit_Application__c
			LIMIT 1
		];

		System.assertEquals(creditApplication.Buyer__c, flippedCreditApplication.Co_Buyer__c);
		System.assertEquals(creditApplication.Co_Buyer__c, flippedCreditApplication.Buyer__c);
	}
}