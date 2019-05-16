@isTest
public with sharing class LeadConvertFormControllerTest
{
	private static final Set<String> sourceAccountNames = new Set<String>{'Walk In', 'Inbound Call', 'Outbound Call'};
	
	@testSetup
	private static void init()
	{
		insert new Sales_Portal_Integration_Settings__c(
			Name = 'Standard Settings',
			Login__c = 'Test',
			Password__c = 'Test',
			Authentification_URL__c = 'Test.auth.com',
			Get_Credit_Applications_Statuses_URL__c = 'Test.getStatuses.com'
		);
		
		insert new Sales_Portal_Integration_Settings__c(
			Name = 'Standard Settings',
			Login__c = 'Test',
			Password__c = 'Test',
			Authentification_URL__c = 'test.auth.com',
			Search_Active_Applications_URL__c = 'test.search.com'
		);
		
		Location__c location = new Location__c(
			Name = 'BDC',
			City__c = 'test',
			Postal_Code__c = '12345',
			State__c = 'TX',
			SalesPortalId__c = 99,
			General_Manager__c = UserInfo.getUserId()
		);
		
		insert location;
		
		List<Account> sources = new List<Account>();
		
		for (String currentSourceName : sourceAccountNames)
		{
			sources.add(new Account(Name = currentSourceName));
		}
		
		insert sources;
		
		String currentProfileName = [
			SELECT Name
			FROM Profile
			WHERE Id = :UserInfo.getProfileId()
			LIMIT 1
		][0].Name;
		
		insert new BDC_Manager__c(
			Name = 'Admin',
			Profile_Name__c = currentProfileName
		);
		
		insert new List<Lead>
		{
			new Lead(
				FirstName = 'test',
				LastName = 'test',
				Email = 'test@test.com',
				Status = 'Open',
				Is_Verified__c = true,
				Social_Security_Number__c = '111-11-1111',
				Source__c = sources[0].Id
			)
		};
		
		Schema.Contact buyer = new Schema.Contact(
			FirstName = 'Test Buyer',
			LastName = 'Test Buyer',
			SalesPortalId__c = 4,
			AccountId = sources[0].Id
		);
		
		insert buyer;
		
		Opportunity opportunity = new Opportunity(
			Name = 'Test',
			AccountId = sources[0].Id,
			StageName = 'Open',
			CloseDate = Date.today(),
			Phone__c = '4647764746',
			Lead_Type__c = 'BDC',
			Lead_Status__c = 'Open',
			Buyer_Contact__c = buyer.Id
		);
		
		insert opportunity;
		
		Credit_Application__c creditApplication = new Credit_Application__c(
			Repeat_Customer__c = '1 Prior Purchase',
			Ready_To_Submit__c = true,
			Credit_Application_Status__c = SalesPortalUtils.CREDIT_APP_STATUS_COND_SCORED,
			Sales_Portal_ID__c = '1',
			Opportunity__c = opportunity.Id,
			Client_Ancestor__c = 'SalesForce',
			Sales_Portal_Creation_Date__c = Date.today()
		);
		
		insert creditApplication;
		
		Test.setCreatedDate(creditApplication.Id, Datetime.now().addDays(-32));
	}
	
	@IsTest
	private static void testInit()
	{
		Id leadId = [
			SELECT Id
			FROM Lead
			LIMIT 1
		].Id;
		
		Test.startTest();
		
		Boolean isManager = LeadConvertFormController.isManager();
		Lead lead = LeadConvertFormController.getLeadRecord(leadId, false);
		String spToken = LeadConvertFormController.getSalesPortalAccessToken();
		
		Test.stopTest();
		
		System.assert(isManager);
		System.assertEquals(leadId, lead.Id);
		System.assertEquals('token', spToken);
	}
	
	@IsTest
	private static void testFailInit()
	{
		Lead lead = [
			SELECT Id
			FROM Lead
			LIMIT 1
		];
		
		User user = [
			SELECT Id
			FROM User
			WHERE Profile.Name = 'LEX Sales Consultant New'
				AND isActive = true
			LIMIT 1
		];
		
		Test.startTest();
		
		Boolean isManager;
		
		System.runAs(user)
		{
			isManager = LeadConvertFormController.isManager();
		}
		
		try
		{
			lead.Status = 'Expired';
			update lead;
			
			Lead retrivedLead = LeadConvertFormController.getLeadRecord(lead.Id, false);
			
			System.assert(false, 'Exception did bot fire');
		}
		catch(Exception ex)
		{
			System.assert(ex instanceof AuraHandledException);
		}
		
		try
		{
			lead.Is_Verified__c = false;
			update lead;
			
			Lead retrivedLead = LeadConvertFormController.getLeadRecord(lead.Id, false);
			
			System.assert(false, 'Exception did bot fire');
		}
		catch(Exception ex)
		{
			System.assert(ex instanceof AuraHandledException);
		}
		
		
		String spToken = LeadConvertFormController.getSalesPortalAccessToken();
		
		Test.stopTest();
		
		System.assert(!isManager);
		System.assertEquals('token', spToken);
	}
	
	@IsTest
	private static void testSalesPortalDuplicatesSearch()
	{
		Id leadId = [
			SELECT Id
			FROM Lead
			LIMIT 1
		].Id;
		
		Lead lead = LeadConvertFormController.getLeadRecord(leadId, false);
		String spToken = LeadConvertFormController.getSalesPortalAccessToken();
		
		Test.startTest();
		
		LeadConvertService.SearchResult result = LeadConvertFormController.checkSSNOnSalesPortal(lead.Social_Security_Number__c, spToken);
		
		Test.stopTest();
		
		System.assertNotEquals(null, result.activeApplicationSalesPortalId);
	}
	
	@IsTest
	private static void testConvertProcess()
	{
		Id leadId = [
			SELECT Id
			FROM Lead
			LIMIT 1
		].Id;
		
		Lead lead = LeadConvertFormController.getLeadRecord(leadId, false);
		
		Test.startTest();
		
		LeadConvertService.SearchResult result = LeadConvertFormController.searchContact(lead);
		System.assertEquals(null, result.buyerMessage);
	
		System.assertEquals(null, result.compareResult.isMergeIsuues);
		LeadConvertFormController.convertLead(lead, JSON.serialize(result.compareResult.supposedLeadCustomer), result.buyerOpportunityId);
		
		Test.stopTest();
		
		Credit_Application__c creditApp = [
			SELECT Opportunity__c, Buyer__c, CreatedDate
			FROM Credit_Application__c
			ORDER BY CreatedDate DESC
			LIMIT 1
		];
		
		System.assertNotEquals(null, creditApp.Opportunity__c);
		System.assertNotEquals(null, creditApp.Buyer__c);
	}
}