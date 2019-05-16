public with sharing class CreditAppQualifyComponentController
{
	/*@AuraEnabled
	public static SearchResult searchActiveApplications(String buyerSocialSecurityNumber, String coBuyerSocialSecurityNumber, String salesPortalAccessToken)
	{
		SalesPortalAPIRequests.ActiveApplicationSearchRequestBody activeApplicationSearchRequestBody = new SalesPortalAPIRequests.ActiveApplicationSearchRequestBody();
		activeApplicationSearchRequestBody.SsnList = new Set<String>();

		if (String.isNotBlank(buyerSocialSecurityNumber))
		{
			activeApplicationSearchRequestBody.SsnList.add(buyerSocialSecurityNumber);
		}
		if (String.isNotBlank(coBuyerSocialSecurityNumber))
		{
			activeApplicationSearchRequestBody.SsnList.add(coBuyerSocialSecurityNumber);
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

		SearchResult searchResult = new SearchResult();
		searchResult.areActiveApplicationsFound = false;

		if (!salesPortalActiveApplications.isEmpty())
		{
			searchResult.areActiveApplicationsFound = true;

			Set<String> salesPortalActiveApplicationsIds = new Set<String>();

			for (SalesPortalAPIResponses.ActiveApplicationData salesPortalActiveApplication : salesPortalActiveApplications)
			{
				salesPortalActiveApplicationsIds.add(String.valueOf(salesPortalActiveApplication.SPCreditAppID));

				if (salesPortalActiveApplication.Ssn.equals(buyerSocialSecurityNumber))
				{
					searchResult.activeBuyerApplication = new SalesforceActiveApplicationInformation();

					searchResult.activeBuyerApplication.isBuyer = salesPortalActiveApplication.IsPrimarySsn;
					searchResult.activeBuyerApplication.socialSecurityNumber = salesPortalActiveApplication.Ssn;
					searchResult.activeBuyerApplication.activeApplicationSalesPortalId = String.valueOf(salesPortalActiveApplication.SPCreditAppID);
				}
				else if (salesPortalActiveApplication.Ssn.equals(coBuyerSocialSecurityNumber))
				{
					searchResult.activeCoBuyerApplication = new SalesforceActiveApplicationInformation();

					searchResult.activeCoBuyerApplication.isBuyer = salesPortalActiveApplication.IsPrimarySsn;
					searchResult.activeCoBuyerApplication.socialSecurityNumber = salesPortalActiveApplication.Ssn;
					searchResult.activeCoBuyerApplication.activeApplicationSalesPortalId = String.valueOf(salesPortalActiveApplication.SPCreditAppID);
				}
			}

			List<dealer__Credit_Application__c> salesforceActiveApplications = [
				SELECT Sales_Up__c, Sales_Portal_ID__c, dealer__Social_Security_Number__c, dealer__Co_App_Social_Security_Number__c
				FROM dealer__Credit_Application__c
				WHERE Sales_Portal_ID__c IN :salesPortalActiveApplicationsIds
			];

			for (dealer__Credit_Application__c salesforceActiveApplication : salesforceActiveApplications)
			{
				if (searchResult.activeBuyerApplication != null)
				{
					if (salesforceActiveApplication.Sales_Portal_ID__c.equals(searchResult.activeBuyerApplication.activeApplicationSalesPortalId))
					{
						searchResult.activeBuyerApplication.activeApplicationId = salesforceActiveApplication.Id;
						searchResult.activeBuyerApplication.activeApplicationSalesUpId = salesforceActiveApplication.Sales_Up__c;
					}
				}
				if (searchResult.activeCoBuyerApplication != null)
				{
					if (salesforceActiveApplication.Sales_Portal_ID__c.equals(searchResult.activeCoBuyerApplication.activeApplicationSalesPortalId))
					{
						searchResult.activeCoBuyerApplication.activeApplicationId = salesforceActiveApplication.Id;
						searchResult.activeCoBuyerApplication.activeApplicationSalesUpId = salesforceActiveApplication.Sales_Up__c;
					}
				}
			}
		}

		return searchResult;
	}

	@AuraEnabled
	public static void createTrafficLog(Id creditApplicationId, Id salesUpId, Id customerId, String logType)
	{
		//TrafficLog__c trafficLog = Utils.createTrafficLog(creditApplicationId, salesUpId, customerId, logType);

		//insert trafficLog;
	}

	public class SearchResult
	{
		@AuraEnabled public Boolean areActiveApplicationsFound {get; set;}
		@AuraEnabled public SalesforceActiveApplicationInformation activeBuyerApplication {get; set;}
		@AuraEnabled public SalesforceActiveApplicationInformation activeCoBuyerApplication {get; set;}
	}

	public class SalesforceActiveApplicationInformation
	{
		@AuraEnabled public Boolean isBuyer {get; set;}
		@AuraEnabled public String socialSecurityNumber {get; set;}
		@AuraEnabled public String activeApplicationId {get; set;}
		@AuraEnabled public String activeApplicationSalesPortalId {get; set;}
		@AuraEnabled public String activeApplicationSalesUpId {get; set;}
	}*/
}