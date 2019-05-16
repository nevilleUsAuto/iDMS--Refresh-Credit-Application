@isTest
private class CreditAppLinkWsTest
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
		
		List<Schema.Contact> buyers =  new List<Schema.Contact>
		{
			new Schema.Contact(
				FirstName = 'Test Buyer',
				LastName = 'Test Buyer',
				MiddleName = 'Test Buyer',
				HomePhone = '12345678',
				MobilePhone = '12345678',
				Email = 'test@test.test',
				Driver_License_Number__c = '12345678',
				Driver_License_Expiration_Date__c = Date.today().addDays(10),
				Birthdate = Date.today().addYears(-20)
			),
			new Schema.Contact(
				FirstName = 'Test Buyer',
				LastName = 'Test Buyer',
				MiddleName = 'Test Buyer',
				HomePhone = '12345678',
				MobilePhone = '12345678',
				Email = 'test@test.test',
				Driver_License_Number__c = '12345678',
				Driver_License_Expiration_Date__c = Date.today().addDays(10),
				Birthdate = Date.today().addYears(-20)
			)
		};
		
		insert buyers;
		
		List<Opportunity> opportunities = new List<Opportunity>
		{
			new Opportunity(
				Name = 'test',
				StageName = 'Qualified',
				CloseDate = Date.today().addDays(10),
				Lead_Type__c = 'BDC',
				Lead_Status__c = 'Open',
				AccountId = source.Id
			),
			
			new Opportunity(
				Name = 'test',
				StageName = 'Qualified',
				CloseDate = Date.today().addDays(10),
				Lead_Type__c = 'BDC',
				Lead_Status__c = 'Open',
				AccountId = source.Id
			)
		};
		
		insert opportunities;
		
		List<Credit_Application__c> creditApps =  new List<Credit_Application__c>{
			new Credit_Application__c(
				Buyer__c = buyers[0].Id,
				Opportunity__c = opportunities[0].Id,
				Repeat_Customer__c = '1 Prior Purchase',
				Co_App_Repeat_Customer__c = '1 Prior Purchase',
				Store_Location__c = storeLocation.Id,
				Sales_Portal_ID__c = '5'
			),
			new Credit_Application__c(
				Buyer__c = buyers[1].Id,
				Opportunity__c = opportunities[1].Id,
				Repeat_Customer__c = '1 Prior Purchase',
				Co_App_Repeat_Customer__c = '1 Prior Purchase',
				Store_Location__c = storeLocation.Id,
				Sales_Portal_ID__c = '6'
			)
		};
		
		insert creditApps;
		
		insert new List<Residence__c>{
			new Residence__c(
				Address_Duration_Years__c = '1',
				Is_Current_Residence__c = true,
				Is_Primary_Buyer__c = true,
				Credit_Application__c = creditApps[1].Id
			),
			new Residence__c(
				Address_Duration_Years__c = '1',
				Is_Current_Residence__c = true,
				Is_Primary_Buyer__c = false,
				Credit_Application__c = creditApps[1].Id
			)
		};
		
		insert new List<Employment__c>{
			new Employment__c(
				Employer_Duration_Years__c = '1',
				Other_Income__c = 100,
				Is_Current_Employment__c = true,
				Is_Primary_Buyer__c = true,
				Credit_Application__c = creditApps[1].Id
			),
			new Employment__c(
				Employer_Duration_Years__c = '1',
				Other_Income__c = 100,
				Is_Current_Employment__c = true,
				Is_Primary_Buyer__c = false,
				Credit_Application__c = creditApps[1].Id
			)
		};
	}

	@isTest
	private static void testLink()
	{
		Credit_Application__c primaryCreditApplication = [
			SELECT Buyer__c, Co_Buyer__c, Sales_Portal_ID__c, Opportunity__r.StageName
			FROM Credit_Application__c
			WHERE Sales_Portal_ID__c = '5'
			LIMIT 1
		];

		Credit_Application__c secondaryCreditApplication = [
			SELECT Buyer__c, Co_Buyer__c, Sales_Portal_ID__c, Opportunity__r.StageName
			FROM Credit_Application__c
			WHERE Sales_Portal_ID__c = '6'
			LIMIT 1
		];

		Test.startTest();
		CreditAppLinkWs.linkCreditApplication(Integer.valueOf(primaryCreditApplication.Sales_Portal_ID__c),
				Integer.valueOf(secondaryCreditApplication.Sales_Portal_ID__c),
				SalesPortalUtils.salesPortalCreditApplicationStatusValueToId.get(SalesPortalUtils.CREDIT_APP_STATUS_PENDING_PAYCALL));
		Test.stopTest();

		Credit_Application__c linkedCreditApplication = [
			SELECT Buyer__c, Co_Buyer__c, Sales_Portal_ID__c, Opportunity__r.StageName
			FROM Credit_Application__c
			WHERE Sales_Portal_ID__c = :primaryCreditApplication.Sales_Portal_ID__c
			LIMIT 1
		];

		Credit_Application__c deadCreditApplication = [
			SELECT Buyer__c, Co_Buyer__c, Sales_Portal_ID__c, Opportunity__r.StageName
			FROM Credit_Application__c
			WHERE Sales_Portal_ID__c = :secondaryCreditApplication.Sales_Portal_ID__c
			LIMIT 1
		];

		System.assertEquals(linkedCreditApplication.Co_Buyer__c, deadCreditApplication.Buyer__c);
		System.assertEquals(deadCreditApplication.Opportunity__r.StageName, SalesPortalUtils.SALES_UP_LEAD_STATUS_DEAD);
	}
}