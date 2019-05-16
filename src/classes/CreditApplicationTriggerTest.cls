@isTest
private class CreditApplicationTriggerTest
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
		
		Schema.Contact cobuyer =  new Schema.Contact(
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
		
		insert new List<Schema.Contact>{buyer, cobuyer};
		
		Opportunity opportunity = new Opportunity(
			Name = 'test',
			StageName = 'Qualified',
			CloseDate = Date.today().addDays(10),
			Lead_Type__c = 'BDC',
			Lead_Status__c = 'Open',
			AccountId = source.Id,
			Buyer_Contact__c = buyer.Id,
			Co_Buyer_Contact__c = cobuyer.Id,
			Store_Location__c = storeLocation.Id
		);
		
		insert opportunity;
		
		Credit_Application__c creditApp =  new Credit_Application__c(
			Buyer__c = buyer.Id,
			Co_Buyer__c = cobuyer.Id,
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
			),
			new Residence__c(
				Address_Duration_Years__c = '1',
				Is_Current_Residence__c = true,
				Is_Primary_Buyer__c = false,
				Credit_Application__c = creditApp.Id
			),
			new Residence__c(
				Address_Duration_Years__c = '1',
				Is_Current_Residence__c = false,
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
			),
			new Employment__c(
				Employer_Duration_Years__c = '1',
				Other_Income__c = 100,
				Is_Current_Employment__c = true,
				Is_Primary_Buyer__c = false,
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
	private static void testRelatedRecorsUpdate()
	{
		Credit_Application__c creditApp = [SELECT Id FROM Credit_Application__c LIMIT 1];
		creditApp.Store_Location__c = null;
		
		Test.startTest();
		update creditApp;
		Test.stopTest();
		
		Opportunity opp = [SELECT Id, Store_Location__c FROM Opportunity LIMIT 1];
		
		System.assertEquals(null, opp.Store_Location__c);
	}

	@isTest static void testCoAppDataDelete()
	{
		Credit_Application__c creditApp = [SELECT Id FROM Credit_Application__c LIMIT 1];
		creditApp.Co_Buyer__c = null;
		
		Test.startTest();
		update creditApp;
		Test.stopTest();
		
		Opportunity opp = [SELECT Id, Co_Buyer_Contact__c FROM Opportunity LIMIT 1];
		List<Employment__c> employments = [SELECT Id FROM Employment__c WHERE Is_Primary_Buyer__c = false];
		List<Residence__c> residences = [SELECT Id FROM Residence__c WHERE Is_Primary_Buyer__c = false];
		
		System.assertEquals(0, employments.size());
		System.assertEquals(0, residences.size());
	}
}