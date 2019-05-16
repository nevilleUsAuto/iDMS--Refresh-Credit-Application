public with sharing class LeadConvertService
{
	private static final String SOCIAL_SECURITY_NUMBER_PATTERN = '^[0-9]{9}$|^[0-9]{3}-[0-9]{2}-[0-9]{4}$';
	private static final String LEAD_CONVERT_LOG_TYPE = 'Lead was converted';
	private static final String LEAD_CREATE_LOG_TYPE = 'Lead was created';
	private static final List<String> finishedStages = new List<String>{'Deal Approved', 'DEAD'};
	private static final String DEAD_OPPORTUNITY_STATUS = 'DEAD';
	private static final String COMPLETE_OPPORTUNITY_STATUS = 'COMPLETE';
	
	private static final Set<String> newOnlineApplicationStatuses = new Set<String>{
		SalesPortalUtils.CREDIT_APP_STATUS_COND_SCORED, SalesPortalUtils.CREDIT_APP_STATUS_ONLINE_APP_DECLINED
	};
	private static final Set<String> expiredApplicationStatuses = new Set<String>{
		SalesPortalUtils.CREDIT_APP_STATUS_EXPIRED 
	};
	
	public static final Map<String, String> leadToContact = LeadConvertUtils.createObjectToObjectMapping(LeadConvertUtils.LEAD_TO_CONTACT, LeadConvertUtils.CONTACT_TO_LEAD);
	public static final Map<String, String> contactToLead = LeadConvertUtils.createObjectToObjectMapping(LeadConvertUtils.CONTACT_TO_LEAD, LeadConvertUtils.LEAD_TO_CONTACT);
	public static final Map<String, String> contactToOpportunity = LeadConvertUtils.createObjectToObjectMapping(LeadConvertUtils.CONTACT_TO_OPPORTUNITY, LeadConvertUtils.OPPORTUNITY_TO_CONTACT);
	public static final Map<String, String> leadToOpportunity = LeadConvertUtils.createObjectToObjectMapping(LeadConvertUtils.LEAD_TO_OPPORTUNITY, LeadConvertUtils.OPPORTUNITY_TO_LEAD);
	public static final Map<String, String> leadToCrediApplication = LeadConvertUtils.createObjectToObjectMapping(LeadConvertUtils.LEAD_TO_CREDIT_APP, LeadConvertUtils.CREDIT_APP_TO_LEAD);
	public static final Map<String, String> leadToEmployment = LeadConvertUtils.createObjectToObjectMapping(LeadConvertUtils.LEAD_TO_EMPLOYMENT, LeadConvertUtils.EMPLOYMENT_TO_LEAD);
	public static final Map<String, String> leadToResidence = LeadConvertUtils.createObjectToObjectMapping(LeadConvertUtils.LEAD_TO_RESIDENCE, LeadConvertUtils.RESIDENCE_TO_LEAD);
	
	private static final List<String> additionalContactFields = new List<String>
	{
		'Drivers_License_State__pc', 'Drivers_License_Number__pc', 'Drivers_License_Expiration_Date__pc'
	};
	private static final List<String> additionalLeadFields = new List<String>
	{
		'Referrer_Code__c', 'Referrer_Customer__c', 'How_Hear__c', 'Channel__c', 'OwnerId', 'Is_Verified__c', 'CreatedDate', 'CreatedById',
		'Status'
	};
	
	public static String transactionErrorMessage {private set; public get;}
	
	public static Lead getLeadRecord(Id leadId)
	{
		Set<String> leadFields = leadToCrediApplication.keySet().clone();
		leadFields.addAll(additionalLeadFields);
		leadFields.addAll(leadToOpportunity.keySet());
		leadFields.addAll(leadToResidence.keySet());
		leadFields.addAll(leadToEmployment.keySet());
		
		for (String currentLeadField : leadToContact.keySet())
		{
			leadFields.add(currentLeadField);
		}
		
		String query = 'SELECT IsConverted, ' + String.join(new List<String>(leadFields), ',') + ' FROM Lead WHERE Id =:leadId';
		List<Lead> leads = Database.query(query);
		
		if (leads.isEmpty())
		{
			return null;
		}
		
		return leads[0];
	}
	
	public static Schema.Contact searchCustomer(String ssn, Integer salesPortalId)
	{
		List<String> contactFields = new List<String>();
		contactFields.addAll(leadToContact.values());
		String query = 'SELECT ' + String.join(contactFields, ',') + ',' +
			' (SELECT Opportunity__c, Buyer__c, Co_Buyer__c, Opportunity__r.CreatedDate, Opportunity__r.Lead_Status__c, CreatedDate, Credit_Application_Status__c, Is_Active__c' +
			' FROM Buyer_Credit_Applications__r ORDER BY CreatedDate DESC),' +
			' (SELECT Opportunity__c, Buyer__c, Co_Buyer__c,  Opportunity__r.CreatedDate, Opportunity__r.Lead_Status__c, CreatedDate, Credit_Application_Status__c, Is_Active__c' +
			' FROM Co_BuyerCredit_Applications__r ORDER BY CreatedDate DESC), ' +
			' (SELECT Id FROM BuyerOpportunities__r WHERE CreatedDate = LAST_N_DAYS:120 AND StageName IN :finishedStages ORDER BY CreatedDate DESC)' +
			' FROM Contact WHERE' +
			' (SocialSecurityNumber__c = :ssn AND SocialSecurityNumber__c != null) ';
		
		if (salesPortalId != null)
		{
			query += ' OR (SalesPortalId__c = :salesPortalId  AND SalesPortalId__c != null)';
		}
		
		List<Schema.Contact> contacts = Database.query(query);
		
		if (!contacts.isEmpty())
		{
			Schema.Contact buyer = contacts[0];
			
			if (salesPortalId == null)
			{
				return buyer;
			}
			else
			{
				if ((buyer.SocialSecurityNumber__c == ssn) && (buyer.SalesPortalId__c == salesPortalId))
				{
					return buyer;
				}
				else if((buyer.SocialSecurityNumber__c == null) && (buyer.SalesPortalId__c == salesPortalId))
				{
					return buyer;
				}
				else if((buyer.SocialSecurityNumber__c != ssn) && (buyer.SalesPortalId__c == salesPortalId) &&(buyer.SalesPortalId__c != null && buyer.SocialSecurityNumber__c != null))
				{
					throw new LeadConvertException('Existing customer with same Sales Portal ID: ' + salesPortalId
						+ ' has another SSN: ' + buyer.SocialSecurityNumber__c);
				}
				else if((buyer.SocialSecurityNumber__c == ssn) && buyer.SalesPortalId__c != salesPortalId && buyer.SalesPortalId__c != null && buyer.SocialSecurityNumber__c != null)
				{
					throw new LeadConvertException('Existing customer with same SSN: ' + ssn
						+ ' has another Sales Portal ID: ' + buyer.SalesPortalId__c);
				}
				else if(contacts.size() > 1)
				{
					throw new LeadConvertException('There are more than one related customers in system.');
				}
			}
		}
		
		return null;
	}
	
	public static CustomersCompareResult getCustomersCompareResult(Lead leadToConvert, Schema.Contact targetCustomer, Boolean autoMatch)
	{
		CustomersCompareResult result = new CustomersCompareResult();
		
		if (targetCustomer == null)
		{
			targetCustomer = new Schema.Contact();
			matchRecords(targetCustomer, leadToConvert, leadToContact, false, false);
		}
		else
		{
			Schema.Contact supposedLeadCustomer = new Schema.Contact();
			
			matchRecords(supposedLeadCustomer, leadToConvert, leadToContact, false, false);
			matchRecords(supposedLeadCustomer, targetCustomer, leadToContact, true, true);
			
			if (!isMatchIssues(supposedLeadCustomer, targetCustomer))
			{
				if (autoMatch)
				{
					matchRecords(targetCustomer, supposedLeadCustomer, leadToContact, true, false);
				}
				else
				{
					result.isMergeIsuues = true;
				}
				
				result.existingCustomer = targetCustomer;
				result.supposedLeadCustomer = supposedLeadCustomer;
				
				return result;
			}
			else
			{
				result.existingCustomer = targetCustomer;
			}
		}
		
		result.supposedLeadCustomer = targetCustomer;
		
		return result;
	}
	
	public static SearchResult searchActiveApplications(List<Credit_Application__c> salesforceApplications, List<Opportunity> opportunities, Id contactId)
	{
		SearchResult result = new SearchResult();
		
		if (salesforceApplications != null)
		{
			if (salesforceApplications.size() != 0)
			{
				Credit_Application__c lastCreditApplication = salesforceApplications[0];
				
				Boolean isActiveApplication = ((lastCreditApplication.CreatedDate.addDays(30) >= Date.today())
					&& !expiredApplicationStatuses.contains(lastCreditApplication.Credit_Application_Status__c));
				
				if (lastCreditApplication.Is_Active__c)
				{
					if (lastCreditApplication.Buyer__c == contactId)
					{
						if (lastCreditApplication.Opportunity__c != null)
						{
							result.buyerMessage = Label.Application_Was_Found_With_SalesUp;
							result.buyerOpportunityId = lastCreditApplication.Opportunity__c;
						}
						else
						{
							result.buyerMessage = Label.Application_Was_Found_Without_SalesUp;
						}
					}
					else if (lastCreditApplication.Co_Buyer__c == contactId)
					{
						result.buyerMessage = Label.Buyer_Was_Found_As_CoBuyer;
					}
				}
			}
		}
		else if (opportunities != null)
		{
			if (!opportunities.isEmpty())
			{
				result.isOpportunityActive = true;
				result.buyerOpportunityId = opportunities[0].Id;
			}
			else
			{
				result.isOpportunityActive = false;
			}
		}
		
		return result;
	}
	
	public static Id convertProcess(Lead leadToConvert, Schema.Contact targetCustomer, Id activeOpportunityId, Id opportunityOwnerId, Boolean isDuplicatesSearchRequired, Boolean isOwnerNotificationRequired)
	{
		Savepoint opportunityCreationSavepoint = Database.setSavepoint();
		
		Opportunity parentOpportunity = new Opportunity();
		
		try
		{
			leadToConvert.OwnerId = opportunityOwnerId;
			targetCustomer.Lead_Activity_Date__c = Datetime.now();
			targetCustomer.AccountId = leadToConvert.Source__c;
			Database.UpSertResult results = Database.upsert(targetCustomer, true);
			
			matchRecords(leadToConvert, targetCustomer, contactToLead, false, false);
			
			if (activeOpportunityId != null)
			{
				parentOpportunity.Id = activeOpportunityId;
			}
			
			parentOpportunity.Referrer_Code__c = leadToConvert.Referrer_Code__c;
			parentOpportunity.Referrer_Customer__c = leadToConvert.Referrer_Customer__c;
			parentOpportunity.Channel__c = leadToConvert.Channel__c;
			
			syncOpportunities(parentOpportunity, targetCustomer, leadToConvert);
			
			parentOpportunity.OwnerId = opportunityOwnerId;
			
			upsert parentOpportunity;
			
			if (isDuplicatesSearchRequired)
			{
				List<Lead> searchResults = LeadService.searchMasterRecords(new List<Lead>{leadToConvert});
				
				if (!searchResults.isEmpty())
				{
					transactionErrorMessage = 'Lead matched with another lead. Id: ' + searchResults[0].Id + '. Name: ' +  searchResults[0].FirstName + ' ' + searchResults[0].LastName;
					
					return null;
				}
			}
			
			if (!leadToConvert.IsConverted)
			{
				LeadService.upsertLeads(new List<Lead>{leadToConvert});
			}
			
			Credit_Application__c creditApplication = new Credit_Application__c(
				Buyer__c = targetCustomer.Id,
				Opportunity__c = parentOpportunity.Id,
				OwnerId = opportunityOwnerId
			);
			Employment__c primaryEmployment = new Employment__c();
			Residence__c primaryResidence = new Residence__c();
			
			syncCreditApplication(creditApplication, primaryEmployment, primaryResidence, leadToConvert);
			
			insert creditApplication;
			
			primaryEmployment.Credit_Application__c = creditApplication.Id;
			primaryResidence.Credit_Application__c = creditApplication.Id;
			
			insert new List<SObject>{primaryEmployment, primaryResidence};
			
			transferDuplicateLeads(leadToConvert.Id, parentOpportunity.Id);
			transferActivities(leadToConvert.Id, parentOpportunity.Id);
			transferRequestedVehicles(leadToConvert.Id, parentOpportunity.Id);
			
			if (!leadToConvert.IsConverted)
			{
				doConvert(leadToConvert, leadToConvert.Source__c, targetCustomer.Id, parentOpportunity.Id);
			}
			
			Traffic_Log_Opportunity__c leadCreateLog = Utils.createTrafficLog(creditApplication.Id, parentOpportunity.Id, targetCustomer.Id, LEAD_CREATE_LOG_TYPE, leadToConvert.CreatedDate, leadToConvert.CreatedById);
			Traffic_Log_Opportunity__c leadConvertLog = Utils.createTrafficLog(creditApplication.Id, parentOpportunity.Id, targetCustomer.Id, LEAD_CONVERT_LOG_TYPE);
			
			insert new List<Traffic_Log_Opportunity__c> {leadConvertLog, leadCreateLog};

			/* NB: 2019-04-09 Do we need this now that I am sending on updates and inserts?
			if (isOwnerNotificationRequired)
			{
				notifyConvertedLeadOwner(parentOpportunity, leadToConvert.Id);
			}*/
		}
		catch(Exception ex)
		{
			Utils.logException(ex);
			Database.rollback(opportunityCreationSavepoint);
			transactionErrorMessage = 'Exception: ' + ex.getMessage() + ' Line: ' + ex.getLineNumber() + ' Cause: ' + ex.getCause();
			
			return null;
		}
		
		return parentOpportunity.Id;
	}
	
	private static void syncOpportunities(Opportunity opportunity, Schema.Contact customer, Lead leadToConvert)
	{
		opportunity.Name = 'Prospect: ' + customer.FirstName + ' ' + customer.LastName;
		opportunity.Buyer_Contact__c = customer.Id;
		opportunity.Lead_Activity_Date__c = Datetime.now();
		opportunity.StageName = 'Qualify';
		opportunity.CloseDate = Date.today().addDays(120);
		
		matchRecords(opportunity, leadToConvert, leadToOpportunity, false, false);
		matchRecords(opportunity, customer, contactToOpportunity, false, false);
	}
	
	private static void syncCreditApplication(Credit_Application__c creditApplication, Employment__c employment, Residence__c residence, Lead leadToConvert)
	{
		employment.Is_Current_Employment__c = true;
		employment.Is_Primary_Buyer__c = true;
		
		residence.Is_Current_Residence__c = true;
		residence.Is_Primary_Buyer__c = true;
		
		matchRecords(employment, leadToConvert, leadToEmployment, false, false);
		matchRecords(residence, leadToConvert, leadToResidence, false, false);
		matchRecords(creditApplication, leadToConvert, leadToCrediApplication, false, false);
		
		if (leadToConvert.IsConverted)
		{
			creditApplication.Verified_By_Lead_Service__c = true;
		}
		
		if (creditApplication.Credit_Application_Status__c == null)
		{
			creditApplication.Credit_Application_Status__c = 'In Progress';
		}
		
		Lead leadToSaveAsParent = new Lead(
			Id = leadToConvert.Id
		);
		
		matchRecords(leadToSaveAsParent, leadToConvert, contactToLead, true, false);
		
		creditApplication.Verified_Lead__c = JSON.serialize(leadToSaveAsParent);
	}
	
	private static void matchRecords(SObject toRecord, SObject fromRecord, Map<String, String> fieldMapping, Boolean sameObject, Boolean emptyFieldMergeOnly)
	{
		for (String fromRecordFieldName : fieldMapping.keySet())
		{
			String toRecordFieldName = fieldMapping.get(fromRecordFieldName);
			fromRecordFieldName = sameObject ? toRecordFieldName : fromRecordFieldName;
			
			if (emptyFieldMergeOnly)
			{
				if (toRecord.get(toRecordFieldName) != null)
				{
					continue;
				}
			}
			
			toRecord.put(toRecordFieldName, fromRecord.get(fromRecordFieldName));
		}
	}
	
	private static Boolean isMatchIssues(Schema.Contact newCustomer, Schema.Contact existingCustomer)
	{
		for (String currentCustomerFieldName : leadToContact.values())
		{
			if (newCustomer.get(currentCustomerFieldName) != existingCustomer.get(currentCustomerFieldName))
			{
				return false;
			}
		}
		
		return true;
	}
	
	private static void transferDuplicateLeads(Id leadId, Id opportunityId)
	{
		List<Duplicate_Lead__c> duplicateLeads = [
			SELECT Id
			FROM Duplicate_Lead__c
			WHERE Master__c = :leadId
		];
		
		for (Duplicate_Lead__c currentDuplicateLead : duplicateLeads)
		{
			currentDuplicateLead.Opportunity__c = opportunityId;
		}
		
		update duplicateLeads;
	}
	
	private static void transferRequestedVehicles(Id leadId, Id opportunityId)
	{
		List<Requested_Vehicle__c> requestedVehicles = [
			SELECT Id
			FROM Requested_Vehicle__c
			WHERE Lead__c = :leadId
		];
		
		for (Requested_Vehicle__c currentRequestedVehicle : requestedVehicles)
		{
			currentRequestedVehicle.Opportunity__c = opportunityId;
		}
		
		update requestedVehicles;
	}
	
	private static void transferActivities(Id leadId, Id opportunityId)
	{
		List<Task> leadTasks = [
			SELECT Id, Subject, WhoId
			FROM Task
			WHERE WhoId = :leadId
		];
		
		for (Task currentTask : leadTasks)
		{
			currentTask.WhatId = opportunityId;
			currentTask.WhoId = null;
		}
		
		update leadTasks;
		
		List<Event> salesAppointmentEvents = [
			SELECT Id, WhatId
			FROM Event
			WHERE WhoId = :leadId
		];
		
		for (Event currentAppointmentEvent : salesAppointmentEvents)
		{
			currentAppointmentEvent.WhoId = null;
			currentAppointmentEvent.WhatId = opportunityId;
		}
		
		update salesAppointmentEvents;
	}
	
	private static void doConvert(Lead leadToConvert, Id accountId, Id contactId, Id opportunityId)
	{
		Database.LeadConvert leadConvert = new database.LeadConvert();
		
		LeadStatus convertStatus = [
			SELECT Id, MasterLabel
			FROM LeadStatus
			WHERE IsConverted = true
			LIMIT 1
		];
		
		leadConvert.setLeadId(leadToConvert.Id);
		leadConvert.setAccountId(accountId);
		leadConvert.setContactId(contactId);
		leadConvert.setOpportunityId(opportunityId);
		leadConvert.setConvertedStatus(convertStatus.MasterLabel);
		
		Database.LeadConvertResult lcr = Database.convertLead(leadConvert);
	}

    /*
	private static void notifyConvertedLeadOwner(Opportunity opportunity, Id convertedLeadId)
	{
		EmailTemplate leadConvertTemplate = [
			SELECT Id
			FROM EmailTemplate
			WHERE DeveloperName =:'Lead_Converted'
		];
		
		User ownerUser = [
			SELECT Email
			FROM User
			WHERE Id = :opportunity.OwnerId
		];
		
		List<String> toAddress = new List<String>{ownerUser.Email};
		
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		
		mail.setToAddresses(toAddress);
		mail.setSenderDisplayName('Salesforce Support');
		mail.setBccSender(false);
		mail.setSaveAsActivity(false);
		mail.setWhatId(opportunity.Id);
		mail.setTargetObjectId(convertedLeadId);
		mail.setTreatTargetObjectAsRecipient(false);
		mail.setTemplateId(leadConvertTemplate.Id);
		
		String message = 'Lead ' + opportunity.Name + ' was converted by ' + UserInfo.getUserName();
		
		Task assignTask = new Task(
			OwnerId = opportunity.OwnerId,
			WhatId = opportunity.Id,
			Status = 'Open',
			Description = message,
			Subject = 'Lead Converted'
		);
		
		try
		{
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			
			ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, opportunity.OwnerId,
				ConnectApi.FeedElementType.FeedItem, 'Your Lead was converted automatically. ' + opportunity.Name);
			ConnectApi.ChatterFeeds.postFeedElement(null, opportunity.Id, ConnectApi.FeedElementType.FeedItem,
				'Opportunity created via Project Online');
			
			insert assignTask;
		}
		catch(Exception ex)
		{
			Utils.logException(ex);
		}
	}
     */

	public class SearchResult
	{
		@AuraEnabled public CustomersCompareResult compareResult {public get; public set;}
		@AuraEnabled public String buyerOpportunityId {get; set;}
		@AuraEnabled public String buyerMessage {get; set;}
		@AuraEnabled public Integer activeApplicationSalesPortalId {get; set;}
		@AuraEnabled public Boolean isOpportunityActive {get; set;}
	}
	
	public class CustomersCompareResult
	{
		@AuraEnabled public Schema.Contact supposedLeadCustomer {public get; public set;}
		@AuraEnabled public Schema.Contact existingCustomer {public get; public set;}
		@AuraEnabled public Boolean isMergeIsuues {public get; public set;}
	}
	
	public class LeadConvertException extends Exception {}
}