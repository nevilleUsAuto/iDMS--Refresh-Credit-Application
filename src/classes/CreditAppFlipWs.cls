@RestResource(urlMapping = '/CreditAppFlipWs')
global class CreditAppFlipWs
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
		'(SELECT Is_Primary_Buyer__c, Is_Current_Residence__c, Housing_Type__c, House_Number__c, Home_Payment__c,' +
			' Address_Street__c, Address_Street_Type__c, Address_City__c, Address_State__c, Home_Address_2__c,' +
			' Address_Zip__c, Address_Duration_Months__c, Address_Duration_Years__c' +
			' FROM Residences__r' +
			' ORDER BY CreatedDate DESC' +
			' LIMIT 4)',
		'(SELECT Is_Primary_Buyer__c, Is_Current_Employment__c, Name, Employer_Street__c, Employer_City__c,' +
			' Employer_State__c, Employer_Zip__c, Occupation_Or_Rank__c, Employer_Phone__c, Employer_Duration_Months__c,' +
			' Employer_Duration_Years__c, Applicant_Net_Period_Paycheck__c, Salary_Type__c, Other_Income__c' +
			' FROM Employments__r' +
			' ORDER BY CreatedDate DESC' +
			' LIMIT 4)'
	};
	
	@HttpPost
	global static ApplicationFlipResponse flipCreditApplication(Integer salesPortalId, Integer creditApplicationStatusId, String flipReason)
	{
		List<String> creditApplicationFiedsToSelect = new List<String>();
		creditApplicationFiedsToSelect.addAll(buyerToCobuyerCreditApplicationFields.keySet());
		creditApplicationFiedsToSelect.addAll(buyerToCobuyerCreditApplicationFields.values());
		creditApplicationFiedsToSelect.addAll(relatedRecorsFields);
		creditApplicationFiedsToSelect.add('Opportunity__c');
		
		Credit_Application__c creditApplication = (Credit_Application__c)Utils.getRecordByFieldValue('Credit_Application__c',
				String.join(creditApplicationFiedsToSelect, ','), 'Sales_Portal_ID__c', String.valueOf(salesPortalId));

		ApplicationFlipResponse response = new ApplicationFlipResponse();

		if (creditApplication == null)
		{
			response.isError = true;
			response.errorMessage = 'No Credit Application found.';
			return response;
		}
		
		for (String currentBuyerFieldName : buyerToCobuyerCreditApplicationFields.keySet())
		{
			Object currentBuyerFieldValue = creditApplication.get(currentBuyerFieldName);
			String currentCobuyerFieldName = buyerToCobuyerCreditApplicationFields.get(currentBuyerFieldName);
			
			creditApplication.put(currentBuyerFieldName, creditApplication.get(currentCobuyerFieldName));
			creditApplication.put(currentCobuyerFieldName, currentBuyerFieldValue);
		}
		
		for (Residence__c currentResidence : creditApplication.Residences__r)
		{
			currentResidence.Is_Primary_Buyer__c = !currentResidence.Is_Primary_Buyer__c;
		}
		
		for (Employment__c currentEmployment : creditApplication.Employments__r)
		{
			currentEmployment.Is_Primary_Buyer__c = !currentEmployment.Is_Primary_Buyer__c;
		}

		creditApplication.Is_Flipped__c = true;
		creditApplication.Credit_Application_Status__c = SalesPortalUtils.salesPortalCreditApplicationStatusIdToValue.get(creditApplicationStatusId);
		creditApplication.Flip_Reason__c = flipReason;
		
		List<SObject> relatedrecoedsToUpdate = new List<SObject>();
		relatedrecoedsToUpdate.addAll(((List<SObject>)creditApplication.Employments__r));
		relatedrecoedsToUpdate.addAll(((List<SObject>)creditApplication.Residences__r));

		try
		{
			update creditApplication;
			
			Traffic_Log_Opportunity__c trafficLog = Utils.createTrafficLog(creditApplication.Id, creditApplication.Opportunity__c, creditApplication.Buyer__c, 'Application Flipped');

			insert trafficLog;
			
			update relatedrecoedsToUpdate;
		}
		catch (Exception ex)
		{
			response.isError = true;
			response.errorMessage = ex.getMessage() + ex.getCause();
			response.creditAppId = creditApplication.Id;
			return response;
		}

		response.isError = false;
		response.creditAppId = creditApplication.Id;

		return response;
	}

	global class ApplicationFlipResponse
	{
		public Boolean isError {get; set;}
		public String errorMessage {get; set;}
		public String creditAppId {get; set;}
	}
}