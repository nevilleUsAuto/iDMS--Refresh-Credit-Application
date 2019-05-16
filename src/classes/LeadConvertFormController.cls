public with sharing class LeadConvertFormController
{
	private static final String GROUP_SOBJECT_NMAE = 'Group';
	
	@AuraEnabled
	public static Boolean isManager()
	{
		Profile profile = [
			SELECT Name
			FROM Profile
			WHERE Id = :UserInfo.getProfileId()
		];
		
		List<BDC_Manager__c> managerProfileNames = BDC_Manager__c.getAll().values();
		
		for (BDC_Manager__c currentManager : managerProfileNames)
		{
			if (profile.Name.equals(currentManager.Profile_Name__c))
			{
				return true;
			}
		}
		
		return false;
	}
	
	@AuraEnabled
	public static Lead getLeadRecord(Id leadId, Boolean isConvertedMasterCase)
	{
		Lead lead = LeadConvertService.getLeadRecord(leadId);
		
		List<String> errors = new List<String>();
		
		if (lead == null)
		{
			errors.add('Lead not found.');
		}
		else if (!isConvertedMasterCase)
		{
			if (lead.OwnerId.getSobjectType() == Schema.getGlobalDescribe().get(GROUP_SOBJECT_NMAE))
			{
				errors.add('Queue\'s lead cannot be converted!');
			}
			if (!lead.Is_Verified__c && !lead.IsConverted)
			{
				errors.add('Lead is not verified. You cannot convert it. Please try to edit and save lead again!');
			}
			if (lead.Status != 'Open')
			{
				errors.add('Unable to convert closed or expired lead!');
			}
		}
		
		if (!errors.isEmpty())
		{
			throw new AuraHandledException(JSON.serialize(errors));
		}
		
		return lead;
	}
	
	@AuraEnabled
	public static String getSalesPortalAccessToken()
	{
		try
		{
			return SalesPortalAPI.authentificateOnSalesPortal(120000);
		}
		catch (Exception ex)
		{
			Utils.logException(ex);
			throw new AuraHandledException('Unable to log in to Sales Portal.');
		}
	}
	
	@AuraEnabled
	public static LeadConvertService.SearchResult checkSSNOnSalesPortal(String ssn, String salesPortalAccessToken)
	{
		SalesPortalAPIRequests.ActiveApplicationSearchRequestBody activeApplicationSearchRequestBody = new SalesPortalAPIRequests.ActiveApplicationSearchRequestBody();
		activeApplicationSearchRequestBody.SsnList = new Set<String>();
		
		if (String.isNotBlank(ssn))
		{
			activeApplicationSearchRequestBody.SsnList.add(ssn);
		}
		
		List<SalesPortalAPIResponses.ActiveApplicationData> salesPortalActiveApplications = new List<SalesPortalAPIResponses.ActiveApplicationData>();
		
		try
		{
			salesPortalActiveApplications = SalesPortalAPI.searchActiveApplications(JSON.serialize(activeApplicationSearchRequestBody), salesPortalAccessToken, 120000);
		}
		catch (Exception ex)
		{
			Utils.logException(ex);
			throw new AuraHandledException('Unable to search for active applications in Sales Portal.');
		}
		
		LeadConvertService.SearchResult searchResult;
		
		if (!salesPortalActiveApplications.isEmpty())
		{
			searchResult = new LeadConvertService.SearchResult();
			Set<String> salesPortalActiveApplicationsIds = new Set<String>();
			
			for (SalesPortalAPIResponses.ActiveApplicationData salesPortalActiveApplication : salesPortalActiveApplications)
			{
				salesPortalActiveApplicationsIds.add(String.valueOf(salesPortalActiveApplication.SPCreditAppID));
				
				if (salesPortalActiveApplication.Ssn.equals(ssn))
				{
					searchResult.activeApplicationSalesPortalId = salesPortalActiveApplication.SPCreditAppID;
					
					if (!salesPortalActiveApplication.IsPrimarySsn)
					{
						searchResult.buyerMessage = Label.Buyer_Was_Found_As_CoBuyer;
					}
				}
			}
			
			List<Credit_Application__c> salesforceActiveApplications = [
				SELECT Opportunity__c, Sales_Portal_ID__c
				FROM Credit_Application__c
				WHERE Sales_Portal_ID__c IN :salesPortalActiveApplicationsIds
			];
			
			for (Credit_Application__c salesforceActiveApplication : salesforceActiveApplications)
			{
				if (salesforceActiveApplication.Sales_Portal_ID__c.equals(String.valueOf(searchResult.activeApplicationSalesPortalId)))
				{
					if (searchResult.buyerMessage == null)
					{
						if (salesforceActiveApplication.Opportunity__c == null)
						{
							searchResult.buyerMessage = Label.Application_Was_Found_Without_SalesUp;
						}
						else
						{
							searchResult.buyerMessage = Label.Application_Was_Found_With_SalesUp;
						}
					}
					
					searchResult.buyerOpportunityId = salesforceActiveApplication.Opportunity__c;
				}
			}
		}
		
		return searchResult;
	}
	
	@AuraEnabled
	public static LeadConvertService.SearchResult searchContact(Lead lead)
	{
		Schema.Contact existingContact;
		LeadConvertService.SearchResult result;
		Integer salesPortalId = (lead.Customer_Id__c != null) ? Integer.valueOf(lead.Customer_Id__c) : null;
		
		try
		{
			existingContact = LeadConvertService.searchCustomer(lead.Social_Security_Number__c, salesPortalId);
			LeadConvertService.CustomersCompareResult copmareResult = LeadConvertService.getCustomersCompareResult(lead, existingContact, false);
			if (existingContact != null)
			{
				List<Credit_Application__c> allRelatedCreditApps = new List<Credit_Application__c>();
				allRelatedCreditApps.addAll(existingContact.Buyer_Credit_Applications__r);
				allRelatedCreditApps.addAll(existingContact.Co_BuyerCredit_Applications__r);
				
				result = LeadConvertService.searchActiveApplications(allRelatedCreditApps, existingContact.BuyerOpportunities__r, existingContact.Id);
			}
			else
			{
				result = new LeadConvertService.SearchResult();
			}
			
			result.compareResult = copmareResult;
		}
		catch(Exception ex)
		{
			System.debug(ex);
			throw new AuraHandledException(ex.getMessage() + ' ' + ex.getLineNumber() + ' ' + ex.getCause());
		}
		
		return result;
	}
	
	@AuraEnabled
	public static Id convertLead(Lead leadToConvert, String targetCustomer, String activeOpportunityId)
	{
		Id opportunityId;
		
		Schema.Contact contact = (Schema.Contact)JSON.deserialize(targetCustomer, Schema.Contact.class);
		opportunityId = LeadConvertService.convertProcess(leadToConvert, contact, activeOpportunityId, leadToConvert.OwnerId, true, false);
		
		if (opportunityId == null)
		{
			if (LeadConvertService.transactionErrorMessage != null)
			{
				throw new AuraHandledException(LeadConvertService.transactionErrorMessage);
			}
			
			throw new AuraHandledException('Convert failed!');
		}
		
		return opportunityId;
	}
}