@isTest
private class CreditAppQualifyComponentControllerTest
{
	/*@testSetup
	private static void init()
	{
		insert new Sales_Portal_Integration_Settings__c(
			Name = 'Standard Settings',
			Login__c = 'Test',
			Password__c = 'Test',
			Authentification_URL__c = 'test.auth.com',
			Search_Active_Applications_URL__c = 'test.search.com'
		);

		List<Account> accounts = new List<Account>
		{
			new Account(
				FirstName = 'Test Buyer',
				MiddleName = 'Test Buyer',
				LastName = 'Test Buyer',
				PersonHomePhone = '12345678',
				PersonMobilePhone = '12345678',
				PersonEmail = 'test@test.test',
				dealer__Drivers_License_Number__pc = '12345678',
				dealer__Drivers_License_State__pc = 'GA'
			),
			new Account(
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

		dealer__Sales_Up__c salesUp = new dealer__Sales_Up__c(
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

		insert new List<dealer__Credit_Application__c>{
			new dealer__Credit_Application__c(
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
				Sales_Portal_ID__c = '1'
			),
			new dealer__Credit_Application__c(
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
				Sales_Portal_ID__c = '2'
			)
		};
	}

	@isTest
	private static void testSocialSecurityNumberCheck()
	{
		Test.startTest();
		CreditAppQualifyComponentController.SearchResult searchResult = CreditAppQualifyComponentController.searchActiveApplications('111-11-1111', '222-22-2222', 'access_token');
		Test.stopTest();

		System.assertNotEquals(null, searchResult);
	}*/
}