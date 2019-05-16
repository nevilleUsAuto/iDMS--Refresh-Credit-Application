public with sharing class OpportunityService
{
	public static Boolean isExecuted = false;
	
	public static List<Opportunity> getUpdatedRecords(List<Opportunity> newCreditApplications, Map<Id, Opportunity> oldCreditApplicationsByIds, List<String> fieldNames)
	{
		Map<Id, Opportunity> updatedCreditApplications = new Map<Id, Opportunity>();
		
		for (Opportunity currentNewOpportunity : newCreditApplications)
		{
			for (String currentFieldName : fieldNames)
			{
				if (oldCreditApplicationsByIds.get(currentNewOpportunity.Id).get(currentFieldName) != currentNewOpportunity.get(currentFieldName))
				{
					updatedCreditApplications.put(currentNewOpportunity.Id, currentNewOpportunity);
				}
			}
		}
		
		return updatedCreditApplications.values();
	}
	
	public static void  updateActiveCreditApplications(List<Opportunity> opportunities)
	{
		if (isExecuted)
		{
			return;
		}
		
		Map<Id, Opportunity> opportunitiesById = new Map<Id, Opportunity>();
		
		for (Opportunity currentOpportunity : opportunities)
		{
			opportunitiesById.put(currentOpportunity.Id, currentOpportunity);
		}
		
		List<Credit_Application__c> relatedCreditApplications = [
			SELECT Opportunity__c
			FROM Credit_Application__c
			WHERE Opportunity__c IN :opportunitiesById.keySet()
				AND Is_Active__c = true
		];
		
		for (Credit_Application__c currentCreditApplication : relatedCreditApplications)
		{
			currentCreditApplication.Buyer__c = opportunitiesById.get(currentCreditApplication.Opportunity__c).Buyer_Contact__c;
			currentCreditApplication.Co_Buyer__c = opportunitiesById.get(currentCreditApplication.Opportunity__c).Co_Buyer_Contact__c;
			currentCreditApplication.Store_Location__c = opportunitiesById.get(currentCreditApplication.Opportunity__c).Store_Location__c;
			currentCreditApplication.OwnerId = opportunitiesById.get(currentCreditApplication.Opportunity__c).OwnerId;
		}
		
		update relatedCreditApplications;
		
		isExecuted = true;
	}
	
	public static void handleOwnerIdChange(List<Opportunity> updatedOpportunities, Map<Id, Opportunity> oldOpportunities)
	{
		Set<Id> userIds = new Set<Id>();
		Location__c locationBDC = LeadService.getBDCLocation();
		
		List<User> bdcQueue = [
			SELECT Id
			FROM User
			WHERE (Email = :'bdcqueue@gmail.com')];
		
		Id bdcQueueId = (bdcQueue.isEmpty()) ? null : bdcQueue[0].Id;
		
		for (Opportunity currentNewOpportunity : updatedOpportunities)
		{
			userIds.add(currentNewOpportunity.OwnerId);
			
			if (currentNewOpportunity.BDC_Rep__c == null)
			{
				if (currentNewOpportunity.OwnerId.getSobjectType() == Schema.getGlobalDescribe().get('User') && oldOpportunities != null)
				{
					if ((oldOpportunities.get(currentNewOpportunity.Id).OwnerId == bdcQueueId) && bdcQueueId != null)
					{
						currentNewOpportunity.BDC_Rep__c = currentNewOpportunity.OwnerId;
						currentNewOpportunity.Salesperson_1__c = currentNewOpportunity.OwnerId;
					}
				}
			}
		}
		
		List<User_Location__c> locationJ = [
			SELECT Location__c, User__c
			FROM User_Location__c
			WHERE User__c IN :userIds
		];
		
		Map<String, User_Location__c> locationsJById =
			(Map<String, User_Location__c>)Utils.genereteMap(locationJ, 'User__c', 'User_Location__c', null);
		
		if (locationsJById != null)
		{
			for (Opportunity currentOpportunity : updatedOpportunities)
			{
				if (locationsJById.containsKey(currentOpportunity.OwnerId))
				{
					currentOpportunity.Store_Location__c = locationsJById.get(currentOpportunity.OwnerId).Location__c;
				}
				else
				{
					currentOpportunity.Store_Location__c = locationBDC.Id;
				}
			}
		}
		else
		{
			System.debug('Type was not created!');
		}
	}
	
	public static void handleStoreChange(List<Opportunity> updatedOpportunities)
	{
		Set<Id> locationIds = new Set<Id>();
		
		for (Opportunity currentNewOpportunity : updatedOpportunities)
		{
			if (currentNewOpportunity.Send_To_Store_NOW__c)
			{
				locationIds.add(currentNewOpportunity.Store_Location__c);
				currentNewOpportunity.Send_To_Store_NOW__c = false;
			}
		}
		
		Map<Id, Location__c> locations = new Map<Id, Location__c>([
			SELECT General_Manager__c, General_Manager__r.Email, Name
			FROM Location__c
			WHERE Id IN :locationIds
		]);
		
		List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
		List<EmailTemplate> emailTemplates = [
			SELECT Id, HtmlValue
			FROM EmailTemplate
			WHERE DeveloperName = :'Opportunity_Assigned_on_You'];
		
		EmailTemplate emailTemplate = emailTemplates.isEmpty() ? null : emailTemplates[0];
		
		for (Opportunity currentNewOpportunity : updatedOpportunities)
		{
			if (locations.containsKey(currentNewOpportunity.Store_Location__c))
			{
				currentNewOpportunity.OwnerId = locations.get(currentNewOpportunity.Store_Location__c).General_Manager__c;
				
				if (currentNewOpportunity.Send_email_notification_to_Store_Manager__c)
				{
					String emailBody = (emailTemplate == null) ? null : emailTemplate.HtmlValue;
					
					currentNewOpportunity.Send_email_notification_to_Store_Manager__c = false;
					Messaging.SingleEmailMessage mail = generateEmailMessage(currentNewOpportunity, locations.get(currentNewOpportunity.Store_Location__c).General_Manager__r.Email,
						locations.get(currentNewOpportunity.Store_Location__c).Name, emailBody);
					
					mails.add(mail);
				}
			}
		}
		
		try
		{
			Messaging.sendEmail(mails);
		}
		catch (Exception ex)
		{
			Utils.logException(ex);
		}
		
	}
	
	public static void handleSalespersonChange(List<Opportunity> updatedOpportunities)
	{
		Set<Id> userIds = new Set<Id>();
		Location__c locationBDC = LeadService.getBDCLocation();
		
		for (Opportunity currentNewOpportunity : updatedOpportunities)
		{
			if (currentNewOpportunity.Salesperson_1__c != null)
			{
				userIds.add(currentNewOpportunity.Salesperson_1__c);
				
				currentNewOpportunity.OwnerId = currentNewOpportunity.Salesperson_1__c;
			}
		}
		
		List<User_Location__c> locationJ = [
			SELECT Location__c, User__c
			FROM User_Location__c
			WHERE User__c IN :userIds
		];
		
		Map<String, User_Location__c> locationsJById =
			(Map<String, User_Location__c>)Utils.genereteMap(locationJ, 'User__c', 'User_Location__c', null);
		
		if (locationsJById != null)
		{
			for (Opportunity currentOpportunity : updatedOpportunities)
			{
				if (locationsJById.containsKey(currentOpportunity.Salesperson_1__c))
				{
					currentOpportunity.Store_Location__c = locationsJById.get(currentOpportunity.Salesperson_1__c).Location__c;
				}
				else
				{
					currentOpportunity.Store_Location__c = locationBDC.Id;
				}
			}
		}
		else
		{
			System.debug('Type was not created!');
		}
	}
	
	private static Messaging.SingleEmailMessage generateEmailMessage(Opportunity opportunity, String emailAddress, String storeName, String emailBody)
	{
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		List<String> sendTo = new List<String> {emailAddress};
		
		mail.setToAddresses(sendTo);
		mail.setBccSender(false);
		mail.setTreatTargetObjectAsRecipient(false);
		mail.setSaveAsActivity(true);
		mail.setSenderDisplayName('Salesforce Opportunity Was Sent To ' + storeName + ' Store!');
		mail.setSubject('Salesforce Opportunity Was Sent To ' + storeName + ' Store');
		mail.setWhatId(opportunity.Id);
		
		String leadChannel = (opportunity.Lead_Channel__c == null) ? 'Undefined' : opportunity.Lead_Channel__c;
		
		if (emailBody != null)
		{
			emailBody = emailBody.replace('{!Opportunity.Name}', opportunity.Name);
			emailBody = emailBody.replace('{!Opportunity.Channel__c}', leadChannel);
			emailBody = emailBody.replace('{!Opportunity.Link}', URL.getSalesforceBaseUrl().toExternalForm() + '/' + opportunity.Id);
		}
		else
		{
			emailBody = 'Salesforce Opportunity was assign on you. ' + opportunity.Name;
		}
		
		mail.setHtmlBody(emailBody);
		
		return mail;
	}
}