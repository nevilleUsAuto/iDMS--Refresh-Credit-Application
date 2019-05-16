@isTest
private class CreditAppCardComponentControllerTest
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
			Get_Online_Apps_Adjusted_Score_URL__c = 'Test.getOnlineAppAdjustedScores.com',
			Get_Adjusted_Credit_Score_URL__c = 'Test.getAdjustedScores.com',
			Send_Approval_Email_URL__c = 'Test.sendapprovalemail.com',
			Save_App_Data_URL__c = 'Test.save.com',
			UpdateLetterPrintedFieldOnSP_URL__c = 'Test.letterPrint.com',
			Send_Deal_For_Managers_Approval_URL__c = 'Test.sendManagersApprove.com',
			Remove_Vehicle_URL__c = 'Test.removeVehicle.com',
			GetDealDetails_URL__c = 'Test.getDealDetails',
			Add_Or_Update_Lots_URL__c = 'https://wsdev.usautosales.info/web/portal/AddOrUpdateLots'
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
			Buyer_Contact__c = buyer.Id,
			AccountId = source.Id
		);
		
		insert opportunity;
		
		Credit_Application__c creditApp =  new Credit_Application__c(
			Buyer__c = buyer.Id,
			Opportunity__c = opportunity.Id,
			Repeat_Customer__c = '1 Prior Purchase',
			Co_App_Repeat_Customer__c = '1 Prior Purchase',
			Store_Location__c = storeLocation.Id,
			Sales_Portal_ID__c = '12334'
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

		Attachment creditApplicatioFile = new Attachment(
			Name = 'file name',
			Body = Blob.valueOf('body'),
			ParentId = creditApp.Id
		);

		insert creditApplicatioFile;
		
		Profile profile = [
			SELECT Id
			FROM Profile
			LIMIT 1
		][0];
		
		UserRole role = [
			SELECT Id
			FROM UserRole
			LIMIT 1
		][0];
	}

	@isTest
	private static void testGetOnlineAppAdjustedScores()
	{
		Credit_Application__c creditApplication = [
			SELECT Sales_Portal_ID__c
			FROM Credit_Application__c
			LIMIT 1
		];

		Test.startTest();
		
			SalesPortalAPIResponses.AdjustedScores adjustedScores =
					CreditAppCardComponentController.getOnlineAppAdjustedScores(creditApplication.Sales_Portal_ID__c, 'access token');


			System.assertNotEquals(null, adjustedScores);

			try
			{
				adjustedScores =
					CreditAppCardComponentController.getOnlineAppAdjustedScores(creditApplication.Sales_Portal_ID__c, null);
			}
			catch(Exception ex)
			{
				System.assertEquals(true, ex instanceof AuraHandledException);
			}
		
		Test.stopTest();
	}

	@isTest
	private static void testGetAdjustedScores()
	{
		Credit_Application__c creditApplication = [
			SELECT Sales_Portal_ID__c
			FROM Credit_Application__c
			LIMIT 1
		];

		Test.startTest();
		
			SalesPortalAPIResponses.RegularApplicationAdjustedScores adjustedScores =
					CreditAppCardComponentController.getAdjustedScores(creditApplication.Sales_Portal_ID__c, 'access token');

			System.assertNotEquals(null, adjustedScores);

			try
			{
				adjustedScores =
					CreditAppCardComponentController.getAdjustedScores(creditApplication.Sales_Portal_ID__c, null);
			}
			catch(Exception ex)
			{
				System.assertEquals(true, ex instanceof AuraHandledException);
			}
		
		Test.stopTest();
	}

	@isTest
	private static void testGetCreditApplicationFile()
	{
		Credit_Application__c creditApplication = [
			SELECT Id
			FROM Credit_Application__c
			LIMIT 1
		];

		Test.startTest();

			Attachment creditApplicatioFile = CreditAppCardComponentController.getCreditApplicationFile(creditApplication.Id);

			try
			{
				creditApplicatioFile = CreditAppCardComponentController.getCreditApplicationFile(creditApplication.Id);
			}
			catch(Exception ex)
			{
				System.assertEquals(true, ex instanceof AuraHandledException);
			}
		
		Test.stopTest();
		
		System.assertEquals('file name', creditApplicatioFile.Name);
	}

	@isTest
	private static void testSendApprovalEmail()
	{
		Test.startTest();

			Boolean isSuccessFull = CreditAppCardComponentController.sendApprovalEmail('First Name', 'email@email.com', 2000.00, 'access token');

			System.assertEquals(true, isSuccessFull);

			try
			{
				isSuccessFull = CreditAppCardComponentController.sendApprovalEmail('First Name', 'email@email.com', 2000.00, null);
			}
			catch(Exception ex)
			{
				System.assertEquals(true, ex instanceof AuraHandledException);
			}
		
		Test.stopTest();
	}

	@isTest
	private static void testSubmit()
	{
		Credit_Application__c creditApplication = [
			SELECT Id
			FROM Credit_Application__c
			LIMIT 1
		];

		Attachment file = [
			SELECT Name, ContentType
			FROM Attachment
			WHERE ParentId = :creditApplication.Id
			LIMIT 1
		];

		Test.startTest();

			creditApplication = CreditAppCardComponentController.submit(creditApplication.Id, file, 'Stips', 'access token');

			System.assertNotEquals(null, creditApplication.Credit_Application_Status__c);

			try
			{
				creditApplication = CreditAppCardComponentController.submit(creditApplication.Id, file, 'Stips', null);
			}
			catch(Exception ex)
			{
				System.assertEquals(true, ex instanceof AuraHandledException);
			}
		
		Test.stopTest();
	}

	@isTest
	private static void testMarkCreditScoreLetterAsSent()
	{
		Credit_Application__c creditApplication = [
			SELECT Sales_Portal_ID__c
			FROM Credit_Application__c
			LIMIT 1
		];

		Test.startTest();

			CreditAppCardComponentController.markCreditScoreLetterAsSent(false, creditApplication.Sales_Portal_ID__c, 'access token');

			try
			{
				CreditAppCardComponentController.markCreditScoreLetterAsSent(false, creditApplication.Sales_Portal_ID__c, null);
			}
			catch(Exception ex)
			{
				System.assertEquals(true, ex instanceof AuraHandledException);
			}
		
		Test.stopTest();
	}

	@isTest
	private static void testSendDealForManagersApproval()
	{
		Credit_Application__c creditApplication = [
			SELECT Sales_Portal_ID__c
			FROM Credit_Application__c
			LIMIT 1
		];

		Test.startTest();

			creditApplication = CreditAppCardComponentController.sendDealForManagersApproval(creditApplication, 5000.0, 2500.0, 1.0, 'access token');

			System.assertNotEquals(null, creditApplication.Credit_Application_Status__c);

			try
			{
				creditApplication = CreditAppCardComponentController.sendDealForManagersApproval(creditApplication, 5000.0, 2500.0, 1.0, null);
			}
			catch(Exception ex)
			{
				System.assertEquals(true, ex instanceof AuraHandledException);
			}

		Test.stopTest();
	}

	@isTest
	private static void testRemoveVehicle()
	{
		Credit_Application__c creditApplication = [
			SELECT Sales_Portal_ID__c
			FROM Credit_Application__c
			LIMIT 1
		];

		Test.startTest();

			CreditAppCardComponentController.removeVehicle(creditApplication, 'access token');

			try
			{
				CreditAppCardComponentController.removeVehicle(creditApplication, null);
			}
			catch(Exception ex)
			{
				System.assertEquals(true, ex instanceof AuraHandledException);
			}

		Test.stopTest();
	}

	@isTest
	private static void testGetDealDetails()
	{
		Credit_Application__c creditApplication = [
			SELECT Sales_Portal_ID__c
			FROM Credit_Application__c
			LIMIT 1
		];

		Test.startTest();

			SalesPortalAPIResponses.DealDetails dealDetails = CreditAppCardComponentController.getDealDetails(creditApplication.Sales_Portal_ID__c, 'access token');

			System.assertNotEquals(null, dealDetails);

			try
			{
				dealDetails = CreditAppCardComponentController.getDealDetails(creditApplication.Sales_Portal_ID__c, null);
			}
			catch(Exception ex)
			{
				System.assertEquals(true, ex instanceof AuraHandledException);
			}

		Test.stopTest();
	}

	@isTest
	private static void testCreateTrafficLog()
	{
		Credit_Application__c creditApplication = [
			SELECT Buyer__c, Opportunity__c
			FROM Credit_Application__c
			LIMIT 1
		];

		Test.startTest();
			CreditAppCardComponentController.createTrafficLog(creditApplication.Id, creditApplication.Opportunity__c, creditApplication.Buyer__c, 'log type');
		Test.stopTest();

		List<Traffic_Log_Opportunity__c> trafficLogs = [
			SELECT Id
			FROM Traffic_Log_Opportunity__c
			LIMIT 1
		];

		System.assertNotEquals(0, trafficLogs.size());
	}
	
	@isTest
	private static void testGetCurrentUserState()
	{
		User testUser = [
			SELECT Id, Location__c
			FROM User
			WHERE Location__c != null
				AND Location__c != 'BDC'
				AND IsActive = true
			LIMIT 1
		].get(0);
		
		Location__c userLocation = new Location__c(
			Name = testUser.Location__c,
			Company_Number__c = 'retjk',
			City__c = 'City Town',
			State__c = 'GA',
			Postal_Code__c = '747466',
			SalesPortalId__c = 11,
			Email__c = 'mail@email.com'
		);
		
		insert userLocation;
		
		Test.startTest();
		
			System.runAs(testUser)
			{
				Integer stateCode = CreditAppCardComponentController.getCurrentUserState();

				System.assertEquals(10, stateCode);
			}
		
		Test.stopTest();
	}
}