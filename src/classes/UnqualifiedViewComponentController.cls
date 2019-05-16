public with sharing class UnqualifiedViewComponentController
{
	private static final Group bdcQueue = [
		SELECT Id, Name
		FROM Group
		WHERE (DeveloperName = 'BDC_Queue') AND (Type = 'Queue')];
	
	private static final User bdcQueueUser = [
		SELECT Id, Name
		FROM User
		WHERE (Email = :'bdcqueue@gmail.com')];
	
	@AuraEnabled
	public static Integer getTotalUnqualifiedRecordsCount(String days)
	{
		Integer count = 0;
		Date startCreatedDateCheck = Date.today().addDays(-Integer.valueOf(days));
		
		List<Opportunity> unqualifiedOpportunities = [
			SELECT Id
			FROM Opportunity
			WHERE OwnerId = :bdcQueueUser.Id
			AND CreatedDate > :startCreatedDateCheck
		];
		
		count += unqualifiedOpportunities.size();
		
		List<Lead> unqualifiedLeads = [
			SELECT Id
			FROM Lead
			WHERE OwnerId = :bdcQueue.Id
			AND IsConverted = false
			AND Status = :'Open'
			AND CreatedDate > :startCreatedDateCheck
		];
		
		count += unqualifiedLeads.size();
		
		return count;
	}
	
	@AuraEnabled
	public static List<UnqualifiedRecordWrapper> getUnqualifiedRecords(String days, Integer offsetRecords, Integer limitRecords)
	{
		List<UnqualifiedRecordWrapper> unqualifiedRecords = new List<UnqualifiedRecordWrapper>();
		Date startCreatedDateCheck = Date.today().addDays(-Integer.valueOf(days));
		Integer offsetInt = Integer.valueOf(offsetRecords);
		Integer limitInt = Integer.valueOf(limitRecords);

		List<Opportunity> unqualifiedOpportunities = [
			SELECT Name, Account.Name, CreatedDate, Buyer_Contact__r.Email
			FROM Opportunity
			WHERE OwnerId = :bdcQueueUser.Id
			AND CreatedDate > :startCreatedDateCheck
			ORDER BY CreatedDate ASC
			LIMIT :limitInt
			OFFSET :offsetInt
		];

		List<dealer__Sales_Up__c> unqualifiedSalesUps = [
			SELECT Name, Lead_Source__c, Lead_Source__r.Name, CreatedDate, dealer__Email__c
			FROM dealer__Sales_Up__c
			WHERE OwnerId = :bdcQueue.Id
				AND CreatedDate > :startCreatedDateCheck
			ORDER BY CreatedDate ASC
			LIMIT :limitInt
			OFFSET :offsetInt
		];
		
		List<Lead> unqualifiedLeads = [
			SELECT Name, Source__c, Source__r.Name, CreatedDate, Channel__c, Email
			FROM Lead
			WHERE OwnerId = :bdcQueue.Id
			AND CreatedDate > :startCreatedDateCheck
			AND IsConverted = false
			AND Status = :'Open'
			ORDER BY CreatedDate ASC
			LIMIT :limitInt
			OFFSET :offsetInt
		];
		
		for (Opportunity currentOpportunity : unqualifiedOpportunities)
		{
			unqualifiedRecords.add(new UnqualifiedRecordWrapper(currentOpportunity, Opportunity.getSObjectType()));
		}
		
		for (Lead currentLead : unqualifiedLeads)
		{
			unqualifiedRecords.add(new UnqualifiedRecordWrapper(currentLead, Lead.getSObjectType()));
		}
		
		unqualifiedRecords.sort();
		
		return unqualifiedRecords;
	}
	
	public class UnqualifiedRecordWrapper implements Comparable
	{
		@AuraEnabled public String id {private set; public get;}
		@AuraEnabled public String name {private set; public get;}
		@AuraEnabled public String email {private set; public get;}
		@AuraEnabled public String channel {private set; public get;}
		@AuraEnabled public String source {private set; public get;}
		@AuraEnabled public Datetime createdDate {private set; public get;}
		@AuraEnabled public String createdDateFormated {private set; public get;}
		@AuraEnabled public String type {private set; public get;}
		
		public UnqualifiedRecordWrapper(SObject record, SObjectType type)
		{
			if (type == Opportunity.getSObjectType())
			{
				Opportunity opportunity = (Opportunity)record;
				
				this.id = opportunity.Id;
				this.name = opportunity.Name;
				this.email = opportunity.Buyer_Contact__r.Email;
				this.source = opportunity.Account.Name;
				this.createdDate = opportunity.CreatedDate;
				this.createdDateFormated = opportunity.CreatedDate.format('MM/dd/yyyy HH:mm:ss');
			}
			else if (type == Lead.getSObjectType())
			{
				Lead lead = (Lead)record;
				
				this.id = lead.Id;
				this.name = lead.Name;
				this.email = lead.Email;
				this.source = lead.Source__r.Name;
				this.createdDate = lead.CreatedDate;
				this.createdDateFormated = lead.CreatedDate.format('MM/dd/yyyy HH:mm:ss');
			}
			
			this.type = type.getDescribe().name;
		}
		
		public Integer compareTo(Object toCompare)
		{
			UnqualifiedRecordWrapper toCompareWrapper = (UnqualifiedRecordWrapper)toCompare;
			
			if (this.createdDate > toCompareWrapper.createdDate)
			{
				return 1;
			}
			else if (this.createdDate < toCompareWrapper.createdDate)
			{
				return -1;
			}
			else
			{
				return 0;
			}
			
			return null;
		}
	}
}