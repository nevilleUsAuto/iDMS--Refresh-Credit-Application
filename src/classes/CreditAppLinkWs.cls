@RestResource(urlMapping = '/CreditAppLinkWs')
global class CreditAppLinkWs
{
	private static final Map<String, String> buyerToCobuyerCreditApplicationFields = new Map<String, String>
	{
		'Buyer__c' => 'Co_Buyer__c',
		'Available_Down_Payment__c' => 'Co_App_Available_Down_Payment__c',
		'Car_Repossessed__c' => 'Co_App_Car_Repossessed__c',
		'Currently_In_Bankruptcy__c' => 'Co_App_Currently_In_Bankruptcy__c',
		'Ever_filed_Bankruptcy_or_Chapter_13__c' => 'Co_App_gone_through_bankruptcy__c',
		'Previous_Account_Number__c' => 'Co_App_Previous_Account_Number__c',
		'Repeat_Customer__c' => 'Co_App_Repeat_Customer__c',
		'Repeat_Reason__c' => 'Co_App_Repeat_Reason__c'
	};
	
	private static List<String> relatedRecorsFields = new List<String>
	{
		'(SELECT Is_Primary_Buyer__c, Is_Current_Residence__c' +
			' FROM Residences__r' +
			' WHERE Is_Primary_Buyer__c = true' +
			' ORDER BY CreatedDate DESC' +
			' LIMIT 2)',
		'(SELECT Is_Primary_Buyer__c, Is_Current_Employment__c' +
			' FROM Employments__r' +
			' WHERE Is_Primary_Buyer__c = true' +
			' ORDER BY CreatedDate DESC' +
			' LIMIT 2)'
	};
	
	@HttpPost
	global static ApplicationFlipResponse linkCreditApplication(Integer primarySpCreditAppID, Integer secondarySPCreditAppID, Integer newCreditAppStatusId)
	{
		List<String> creditApplicationFiedsToSelect = new List<String>();
		creditApplicationFiedsToSelect.addAll(buyerToCobuyerCreditApplicationFields.keySet());
		creditApplicationFiedsToSelect.addAll(buyerToCobuyerCreditApplicationFields.values());
		creditApplicationFiedsToSelect.addAll(relatedRecorsFields);
		creditApplicationFiedsToSelect.add('Opportunity__c');
		
		Credit_Application__c mergedCreditApplication = (Credit_Application__c)Utils.getRecordByFieldValue('Credit_Application__c',
				String.join(creditApplicationFiedsToSelect, ','), 'Sales_Portal_ID__c', String.valueOf(primarySpCreditAppID));
		Credit_Application__c disabledCreditApplication = (Credit_Application__c)Utils.getRecordByFieldValue('Credit_Application__c',
				String.join(creditApplicationFiedsToSelect, ','), 'Sales_Portal_ID__c', String.valueOf(secondarySPCreditAppID));
		
		ApplicationFlipResponse response = new ApplicationFlipResponse();
		
		if (mergedCreditApplication == null || disabledCreditApplication == null)
		{
			response.isError = true;
			response.errorMessage = 'One or both applications don\'t exist in Salesforce database';
			return response;
		}
		
		if (mergedCreditApplication.Co_Buyer__c != null || disabledCreditApplication.Co_Buyer__c != null)
		{
			response.isError = true;
			response.errorMessage = 'One or both applications have co-buyer in Salesforce database';
			return response;
		}
		
		for (String currentBuyerFieldName : buyerToCobuyerCreditApplicationFields.keySet())
		{
			String currentCoBuyerFieldName = buyerToCobuyerCreditApplicationFields.get(currentBuyerFieldName);
			mergedCreditApplication.put(currentCoBuyerFieldName, disabledCreditApplication.get(currentBuyerFieldName));
		}
		
		for (Residence__c currentResidence : disabledCreditApplication.Residences__r)
		{
			currentResidence.Is_Primary_Buyer__c = false;
			currentResidence.Credit_Application__c = mergedCreditApplication.Id;
		}
		
		for (Employment__c currentEmployment : disabledCreditApplication.Employments__r)
		{
			currentEmployment.Is_Primary_Buyer__c = false;
			currentEmployment.Credit_Application__c = mergedCreditApplication.Id;
		}
		
		mergedCreditApplication.Credit_Application_Status__c = SalesPortalUtils.salesPortalCreditApplicationStatusIdToValue.get(newCreditAppStatusId);
		mergedCreditApplication.Link_Details__c = 'Application with Deal Id ' + secondarySPCreditAppID + ' was linked to this application.';

		disabledCreditApplication.Link_Details__c = 'This application was linked to application with Deal Id ' + primarySpCreditAppID + '.';

		List<Credit_Application__c> linkedApplications = new List<Credit_Application__c>{mergedCreditApplication, disabledCreditApplication};

		for (Credit_Application__c creditApplication : linkedApplications)
		{
			creditApplication.Is_Linked__c = true;
		}

		Opportunity deadSalesUp = new Opportunity(Id = disabledCreditApplication.Opportunity__c, StageName = 'DEAD');
		
		List<SObject> relatedrecoedsToUpdate = new List<SObject>();
		relatedrecoedsToUpdate.addAll(((List<SObject>)disabledCreditApplication.Employments__r));
		relatedrecoedsToUpdate.addAll(((List<SObject>)disabledCreditApplication.Residences__r));
		
		Savepoint savepoint = Database.setSavepoint();
		
		try
		{
			update relatedrecoedsToUpdate;
			update linkedApplications;
			update deadSalesUp;
		}
		catch(Exception ex)
		{
			Database.rollback(savepoint);

			response.isError = true;
			response.errorMessage = ex.getMessage() + ex.getCause();
			response.creditAppId = mergedCreditApplication.Id;
			return response;
		}
		
		List<Traffic_Log_Opportunity__c> trafficLogs = new List<Traffic_Log_Opportunity__c>
		{
			Utils.createTrafficLog(mergedCreditApplication.Id, mergedCreditApplication.Opportunity__c,
				mergedCreditApplication.Buyer__c, 'Credit App Linked'),
			Utils.createTrafficLog(disabledCreditApplication.Id, disabledCreditApplication.Opportunity__c,
				disabledCreditApplication.Buyer__c, 'Credit App Linked')
		};
		
		insert trafficLogs;
		
		response.isError = false;
		response.creditAppId = mergedCreditApplication.Id;
		return response;
	}
	
	global class ApplicationFlipResponse
	{
		public Boolean isError {get; set;}
		public String errorMessage {get; set;}
		public String creditAppId {get; set;}
	}
}