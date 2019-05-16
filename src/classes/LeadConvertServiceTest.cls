@isTest
private class LeadConvertServiceTest
{
	@testSetup
	private static void init()
	{
		Location__c location = new Location__c(
			Name = 'BDC',
			City__c = 'test',
			Postal_Code__c = '12345',
			State__c = 'TX',
			SalesPortalId__c = 99,
			General_Manager__c = UserInfo.getUserId()
		);
		
		insert location;
		
		Account manualChannel = new Account(
			Name = 'Test Channel Salesforce'
		);
		
		insert manualChannel;
		
		Lead testLead = new Lead(
			FirstName = 'Bill',
			LastName = 'Willson',
			Email = 'billwillson@test.com',
			MobilePhone = '1212121212',
			Phone = '2323232323',
			Channel__c = 'Manual',
			Source__c = manualChannel.Id,
			Social_Security_Number__c = '123-45-6789'
		);
		
		insert testLead;
	}
	
	@isTest
	private static void testLeadSuccessConvert()
	{
		Boolean testEmailNotificationBoolean = true; //NB 2019-03-18
		Lead leadToConvert = [
			SELECT Id
			FROM Lead
			LIMIT 1
		];
		
		Test.startTest();
		
		leadToConvert = LeadConvertService.getLeadRecord(leadToConvert.Id);
		Schema.Contact contact = LeadConvertService.searchCustomer(leadToConvert.Social_Security_Number__c, null);
		Id contactId = (contact == null) ? null : contact.Id;
		
		LeadConvertService.SearchResult searchResult = LeadConvertService.searchActiveApplications(null, null, contactId);
		searchResult.compareResult = LeadConvertService.getCustomersCompareResult(leadToConvert, contact, true);
		
		System.assertEquals(null, searchResult.buyerOpportunityId);
		System.assertEquals(null, searchResult.buyerMessage);
		System.assertEquals(null, searchResult.activeApplicationSalesPortalId);
		System.assertEquals(null, searchResult.isOpportunityActive);
		
		LeadConvertService.CustomersCompareResult compareResult = searchResult.compareResult;
		
		System.assertEquals(null, compareResult.existingCustomer);
		System.assertEquals(null, compareResult.isMergeIsuues);
		System.assertEquals(null, compareResult.supposedLeadCustomer.Id);
		System.assertEquals(leadToConvert.Social_Security_Number__c, compareResult.supposedLeadCustomer.SocialSecurityNumber__c);
		
		LeadConvertService.convertProcess(leadToConvert, compareResult.supposedLeadCustomer,
				searchResult.buyerOpportunityId, leadToConvert.OwnerId, false, testEmailNotificationBoolean);
		
		List<Schema.Contact> createdCustomers = [
			SELECT FirstName, LastName, Email, SocialSecurityNumber__c,
			(SELECT Credit_Application_Status__c FROM Buyer_Credit_Applications__r),
			(SELECT Id FROM BuyerOpportunities__r)
			FROM Contact
			WHERE SocialSecurityNumber__c = :leadToConvert.Social_Security_Number__c
			AND FirstName = :leadToConvert.FirstName AND LastName = :leadToConvert.LastName AND Email =: leadToConvert.Email
		];
		
		Test.stopTest();
		
		System.assertEquals(1, createdCustomers.size());
		System.assertEquals(leadToConvert.FirstName, createdCustomers[0].FirstName);
		System.assertEquals(leadToConvert.LastName, createdCustomers[0].LastName);
		System.assertEquals('In Progress', createdCustomers[0].Buyer_Credit_Applications__r[0].Credit_Application_Status__c);
	}
	
	@isTest
	private static void testLeadFailConvert()
	{
		Lead leadToConvert = [
			SELECT Id
			FROM Lead
			LIMIT 1
		];
		
		Test.startTest();
		
		leadToConvert = LeadConvertService.getLeadRecord(leadToConvert.Id);
		
		createCreditApp(leadToConvert.Social_Security_Number__c);
		
		List<Credit_Application__c> testapps = [
			SELECT id, Opportunity__c
			FROM Credit_Application__c
		];
		
		System.assertEquals(1, testapps.size());
		
		Schema.Contact contact = LeadConvertService.searchCustomer(leadToConvert.Social_Security_Number__c, null);
		
		LeadConvertService.SearchResult searchResult = LeadConvertService.searchActiveApplications(contact.Buyer_Credit_Applications__r, contact.BuyerOpportunities__r, contact.Id);
		
		Test.stopTest();
		
		System.assertEquals(testapps[0].Opportunity__c, searchResult.buyerOpportunityId);
		System.assertNotEquals(null, searchResult.buyerMessage);
	}
	
	@isTest
	private static void testRecordMatching()
	{
		Lead newLead = new Lead();
		
		Id leadId = [
			SELECT Id
			FROM Lead
			LIMIT 1
		][0].Id;
		
		Lead existingLead = LeadConvertService.getLeadRecord(leadId);
		
		LeadConvertUtils.matchRecords(newLead, existingLead, LeadConvertService.contactToLead, true, false);
	}
	
	private static void createCreditApp(String ssn)
	{
		Account sourceAccount = new Account(
			Name = 'TestSource'
		);
		
		insert sourceAccount;
		
		Schema.Contact contact = new Schema.Contact(
			AccountId = sourceAccount.Id,
			FirstName = 'Name',
			MiddleName = 'Middle',
			LastName = 'Last',
			SocialSecurityNumber__c = ssn,
			HomePhone = '4647764746',
			MobilePhone = '4647764746',
			Email = 'test@test.test'
		);
		
		insert contact;
		
		Opportunity opportunity = new Opportunity(
			Name = 'Test',
			AccountId = sourceAccount.Id,
			StageName = 'DEAD',
			CloseDate = Date.today(),
			Phone__c = '4647764746',
			Lead_Type__c = 'BDC',
			Lead_Status__c = 'DEAD',
			Buyer_Contact__c = contact.Id
		);
		
		insert opportunity;
		
		insert new Credit_Application__c(
			Buyer__c = contact.Id,
			Repeat_Customer__c = '1 Prior Purchase',
			Opportunity__c = opportunity.Id,
			Sales_Portal_ID__c = '1'
		);
	}

	//NB 2019-03-18  Test Coverage at 69%.  Contributing factor, no test on email service.
	@IsTest
	private static void testLeadSuccessConvertWithEmailNotification()
	{
		Boolean testEmailNotificationBoolean = true;
		//To test for matching SSN on the Contact Record
		Account account = [SELECT Id FROM Account LIMIT 1];
		insert new Schema.Contact(LastName = 'MySSNMatch', FirstName = 'MySSNMatch', AccountId = account.Id,
				Email='MySSNMatch@Testing.com', SocialSecurityNumber__c = '123-45-6789');

		Lead leadToConvert = [
				SELECT Id
				FROM Lead
				LIMIT 1
		];

		Test.startTest();

		leadToConvert = LeadConvertService.getLeadRecord(leadToConvert.Id);
		Schema.Contact contact = LeadConvertService.searchCustomer(leadToConvert.Social_Security_Number__c, null);
		Id contactId = (contact == null) ? null : contact.Id;

		LeadConvertService.SearchResult searchResult = LeadConvertService.searchActiveApplications(null, null, contactId);
		searchResult.compareResult = LeadConvertService.getCustomersCompareResult(leadToConvert, contact, true);

		System.assertEquals(null, searchResult.buyerOpportunityId);
		System.assertEquals(null, searchResult.buyerMessage);
		System.assertEquals(null, searchResult.activeApplicationSalesPortalId);
		System.assertEquals(null, searchResult.isOpportunityActive);

		LeadConvertService.CustomersCompareResult compareResult = searchResult.compareResult;

		System.assert(compareResult.existingCustomer !=null, 'Matching...');
		//System.assertEquals(null, compareResult.isMergeIsuues);
		//System.assertEquals(null, compareResult.supposedLeadCustomer.Id);
		System.assertEquals(leadToConvert.Social_Security_Number__c, compareResult.supposedLeadCustomer.SocialSecurityNumber__c);

		LeadConvertService.convertProcess(leadToConvert, compareResult.supposedLeadCustomer,
				searchResult.buyerOpportunityId, leadToConvert.OwnerId, false, testEmailNotificationBoolean);

		List<Schema.Contact> createdCustomers = [
				SELECT FirstName, LastName, Email, SocialSecurityNumber__c,
				(SELECT Credit_Application_Status__c FROM Buyer_Credit_Applications__r),
				(SELECT Id FROM BuyerOpportunities__r)
				FROM Contact
				WHERE SocialSecurityNumber__c = :leadToConvert.Social_Security_Number__c
		];

		Test.stopTest();

		System.assertEquals(1, createdCustomers.size());

	}
}