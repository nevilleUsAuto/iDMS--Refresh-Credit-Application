@isTest
public with sharing class UnqualifiedViewComponentControllerTest
{
	private static final Integer COUNT = 100;
	private static final Group bdcQueue = [
		SELECT Id, Name
		FROM Group
		WHERE (DeveloperName = 'BDC_Queue') AND (Type = 'Queue')];
	
	@testSetup
	private static void init()
	{
		Location__c location = new Location__c(
			Name = 'BDC',
			Company_Number__c = 'scscs',
			City__c = 'City',
			State__c = 'TX',
			Postal_Code__c = '74746',
			SalesPortalId__c = 99,
			Email__c = 'mail@email.com'
		);
		
		insert location;
		
		List<Lead> leads = new List<Lead>();
		
		for (Integer i = 0; i < COUNT; i++)
		{
			leads.add(new Lead(
				FirstName = 'test' + i,
				LastName = 'test',
				Email = 'test@test.com',
				Channel__c = 'Manual',
				OwnerId = bdcQueue.Id,
				Status = 'Open'
			));
		}
		
		insert leads;
	}
	
	@isTest
	private static void testGettingCount()
	{
		Test.startTest();
		Integer actualCount = UnqualifiedViewComponentController.getTotalUnqualifiedRecordsCount('120');
		Test.stopTest();
		
		System.assertEquals(COUNT, actualCount);
	}
	
	@isTest
	private static void testGetRecords()
	{
		Test.startTest();
		List<UnqualifiedViewComponentController.UnqualifiedRecordWrapper> unqualifiedRecordWrappers = UnqualifiedViewComponentController.getUnqualifiedRecords('120', 0, 50);
		Test.stopTest();
		
		System.assertEquals(50, unqualifiedRecordWrappers.size());
	}
}