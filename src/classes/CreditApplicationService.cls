public without sharing class CreditApplicationService
{
	public static Boolean isExecuted = false;
	
	private static final Set<String> newOnlineApplicationStatuses = new Set<String>{
		SalesPortalUtils.CREDIT_APP_STATUS_COND_SCORED, SalesPortalUtils.CREDIT_APP_STATUS_ONLINE_APP_DECLINED
	};
	
	private static final Set<String> expiredApplicationStatuses = new Set<String>{
		SalesPortalUtils.CREDIT_APP_STATUS_EXPIRED
	};
	
	private static final Map<String, String> creditAppToOpportunity = new Map<String, String>{
		'Store_Location__c' => 'Store_Location__c',
		'Credit_Application_Status__c' => 'StageName',
		'Co_Buyer__c' => 'Co_Buyer_Contact__c'
	};
	
	private static final Map<String, String> creditAppStatusToOpportunityStage = new Map<String, String>
	{
		'New' => 'Qualify',
		'In Progress' => 'Qualify',
		'Incomplete' => 'Qualify',
		'Conditionally Scored' => 'Qualify',
		'Online App Declined' => 'Qualify',
		'Awaiting Stips' => 'Qualify',
		'Pending Verification' => 'Approval',
		'Pending Paycall' => 'Approval',
		'Initial Paycall' => 'Select Vehicle',
		'Letter Printed' => 'Select Vehicle',
		'Vehicle Selected' => 'Select Vehicle',
		'Pending Final Approval' => 'Worksheet Submitted',
		'Approved' => 'Deal Approved',
		'Denied' => 'Layaway',
		'Delivered' => 'Delivered',
		'Expired' => 'DEAD'  //??
	};
	
	private static final Map<String, String> creditApplicationStatusToTrafficLogType = new Map<String, String>
	{
		'Initial Paycall' => 'Opportunity progressed to Credit App Approved',
		'Vehicle Selected' => 'Opportunity progressed to Select Vehicle',
		'Pending Final Approval' => 'Opportunity progressed to Worksheet Submitted',
		'Approved' => 'Opportunity progressed to Deal Approved',
		'Denied' => 'Opportunity progressed to Layaway',
		'Delivered' => 'Opportunity progressed to Delivered'
	};
	
	private static final Map<String, String> creditAppToBuyer = new Map<String, String>{
		'dealer__First_Name__c' => 'FirstName',
		'dealer__Middle_Name__c' => 'MiddleName',
		'dealer__Last_Name__c' => 'LastName',
		'Suffix__c' => 'Suffix',
		'dealer__Home_Phone__c' => 'PersonHomePhone',
		'dealer__Mobile_Phone__c' => 'PersonMobilePhone',
		'dealer__Email_Address__c' => 'PersonEmail',
		'dealer__BirthDate__c' => 'PersonBirthdate',
		'dealer__Driver_License_No__c' => 'dealer__Drivers_License_Number__pc',
		'Driver_License_State__c' => 'dealer__Drivers_License_State__pc'
	};
	
	private static final Map<String, String> creditAppToCoBuyer = new Map<String, String>{
		'dealer__Co_App_First_Name__c' => 'FirstName',
		'dealer__Co_App_Middle_Name__c' => 'MiddleName',
		'dealer__Co_App_Last_Name__c' => 'LastName',
		'Co_App_Suffix__c' => 'Suffix',
		'dealer__Co_App_Phone__c' => 'PersonHomePhone',
		'dealer__Co_App_Mobile_Phone__c' => 'PersonMobilePhone',
		'dealer__Co_App_Email_Address__c' => 'PersonEmail',
		'dealer__Co_App_Date_of_Birth__c' => 'PersonBirthdate',
		'dealer__Co_App_Driver_License_Number__c' => 'dealer__Drivers_License_Number__pc',
		'Co_App_Driver_License_State__c' => 'dealer__Drivers_License_State__pc'
	};
	
	private static final Map<String, String> creditAppToSalesUp = new Map<String, String>{
		'dealer__First_Name__c' => 'dealer__FirstName__c',
		'dealer__Last_Name__c' => 'dealer__LastName__c',
		'dealer__Home_Phone__c' => 'dealer__Home_Phone__c',
		'dealer__Mobile_Phone__c' => 'dealer__Mobile__c',
		'dealer__Email_Address__c' => 'dealer__Email__c',
		'dealer__Buyer_Account__c' => 'dealer__Customer_Account__c',
		'dealer__Co_Buyer_Account__c' => 'dealer__Co_Buyer__c',
		'dealer__Buyer__c' => 'dealer__Buyer_Contact__c',
		'dealer__Co_Buyer__c' => 'dealer__Co_Buyer_Contact__c',
		'dealer__Store_Location__c' => 'dealer__Store_Location__c'
	};
	
	//NB 2018-03-13
	private static final Map<String, String> salesAppointment = new Map<String, String>{
		'Credit_Application_Status__c' => 'Credit_Application_Status__c'
	};
	
	private static final List<String> creditAppCoBuyerNullableFields = new List<String>{
		'dealer__Co_App_First_Name__c', 'dealer__Co_App_Last_Name__c',
		'dealer__Co_App_Middle_Name__c', 'Co_App_Suffix__c', 'dealer__Co_App_Phone__c', 'dealer__Co_App_Mobile_Phone__c',
		'dealer__Co_App_Email_Address__c', 'dealer__Co_App_Social_Security_Number__c', 'dealer__Co_App_Date_of_Birth__c',
		'dealer__Co_App_Driver_License_Number__c', 'Co_App_Driver_License_State__c', 'Co_App_Housing_Type__c',
		'Co_App_Current_House_Number__c', 'Co_App_Current_Street__c', 'Co_App_Current_Street_Type__c',
		'dealer__Co_App_Current_Address_City__c', 'dealer__Co_App_Current_Address_State__c',
		'dealer__Co_App_Current_Address_Zip__c', 'Co_Applicant_House_Payment__c', 'dealer__Co_App_Present_Employer__c',
		'dealer__Co_App_Present_Employer_Street__c', 'dealer__Co_App_Present_Employer_City__c', 'dealer__Co_App_Present_Employer_State__c',
		'dealer__Co_App_Present_Employer_Zip__c', 'dealer__Co_App_Occupation_Or_Rank__c', 'dealer__Co_App_Present_Employer_Phone__c',
		'dealer__Co_App_Gross_Monthly_Income__c', 'Co_App_Salary_Type__c', 'Co_App_Other_Income__c',
		'Co_App_Available_Down_Payment__c', 'Co_App_Home_Address_2__c', 'dealer__Co_App_Previous_Address_1_Street__c',
		'dealer__Co_App_Previous_Address_1_City__c', 'Co_App_Prev_Address_1_State__c', 'dealer__Co_App_Prev_Address_1_Zip__c',
		'Co_App_Previous_Address_2__c', 'dealer__Co_App_Previous_Employer_1__c', 'Co_App_Repeat_Reason__c',
		'Co_App_Previous_Account_Number__c'
	};
	
	private static final List<String> creditAppCoBuyerDurationFields = new List<String>{
		'Co_App_Address_Duration_Months__c', 'Co_App_Current_Address_Duration_Years__c',
		'Co_App_Present_Employer_Duration_Month__c', 'Co_App_Present_Employer_Duration_Years__c',
		'Co_App_Prev_Address_Duration_Months__c', 'Co_App_Prev_Address_Duration_Years__c',
		'Co_App_Previous_Employer_1_Duration_M__c', 'Co_App_Previous_Employer_1_Duration_Y__c'
	};
	
	private static final List<String> fieldsWithSSN = new List<String>{
		'dealer__Social_Security_Number__c', 'dealer__Co_App_Social_Security_Number__c'
	};
	
	public static List<Credit_Application__c> getUpdatedRecords(List<Credit_Application__c> newCreditApplications, Map<Id, Credit_Application__c> oldCreditApplicationsByIds, List<String> fieldNames)
	{
		Map<Id, Credit_Application__c> updatedCreditApplications = new Map<Id, Credit_Application__c>();
		
		for (Credit_Application__c currentNewLead : newCreditApplications)
		{
			if (currentNewLead.Is_Active__c)
			{
				for (String currentFieldName : fieldNames)
				{
					if (oldCreditApplicationsByIds.get(currentNewLead.Id).get(currentFieldName) != currentNewLead.get(currentFieldName))
					{
						updatedCreditApplications.put(currentNewLead.Id, currentNewLead);
					}
				}
			}
		}
		
		return updatedCreditApplications.values();
	}

	public static void updateSyncedFields(List<Credit_Application__c> creditApps)
	{
		if (isExecuted)
		{
			return;
		}

		List<Opportunity> oppportunitiesToUpdate = new List<Opportunity>();
		List<Traffic_Log_Opportunity__c> trafficLogsToInsert = new List<Traffic_Log_Opportunity__c>();

		for (Credit_Application__c currentCreditApplication : creditApps)
		{
			Opportunity opportunity = new Opportunity(Id = currentCreditApplication.Opportunity__c);

			for (String currentCreditAppFiledName : creditAppToOpportunity.keySet())
			{
				if (currentCreditAppFiledName == 'Credit_Application_Status__c')
				{
					String currentCreditAppStatus = String.valueOf(currentCreditApplication.get(currentCreditAppFiledName));

					if (creditAppStatusToOpportunityStage.containsKey(currentCreditAppStatus))
					{
						opportunity.put(creditAppToOpportunity.get(currentCreditAppFiledName), creditAppStatusToOpportunityStage.get(currentCreditAppStatus));
					}
					if (creditApplicationStatusToTrafficLogType.containsKey(currentCreditAppStatus))
					{
						trafficLogsToInsert.add(Utils.createTrafficLog(currentCreditApplication.Id, currentCreditApplication.Opportunity__c,
								currentCreditApplication.Buyer__c, creditApplicationStatusToTrafficLogType.get(currentCreditAppStatus), Datetime.now(), UserInfo.getUserId()));
					}
				}
				else if (currentCreditAppFiledName == 'Store_Location__c')
				{
					opportunity.put(creditAppToOpportunity.get(currentCreditAppFiledName), currentCreditApplication.get(currentCreditAppFiledName));
					trafficLogsToInsert.add(Utils.createTrafficLog(currentCreditApplication.Id, currentCreditApplication.Opportunity__c,
							currentCreditApplication.Buyer__c, 'Lead Assigned to Store', Datetime.now(), UserInfo.getUserId()));
				}
				else
				{
					opportunity.put(creditAppToOpportunity.get(currentCreditAppFiledName), currentCreditApplication.get(currentCreditAppFiledName));
					updateRelatedInformation(creditApps);
				}
			}

			oppportunitiesToUpdate.add(opportunity);
		}

		update oppportunitiesToUpdate;
		insert trafficLogsToInsert;

		isExecuted = true;
	}

	private static void updateRelatedInformation(List<Credit_Application__c> newCreditApplications)
	{
//		if (isExecuted)
//		{
//			return;
//		}
		
		Map<Id, Set<Id>> creditAppIdToBuyersIds = new Map<Id, Set<Id>>();
		
		Set<Id> creditAppIdsWithRemovedBuyer = new Set<Id>();
		Set<Id> creditAppIdsWithRemovedCoBuyer = new Set<Id>();
		Map<Id, Opportunity> opportunitiesWithUpdatedBuyer = new Map<Id, Opportunity>();
		
		for (Credit_Application__c currentNewCreditApplication : newCreditApplications)
		{
			if (currentNewCreditApplication.Buyer__c == null)
			{
				creditAppIdsWithRemovedBuyer.add(currentNewCreditApplication.Id);
				
				if (!opportunitiesWithUpdatedBuyer.containsKey(currentNewCreditApplication.Opportunity__c))
				{
					opportunitiesWithUpdatedBuyer.put(currentNewCreditApplication.Opportunity__c, new Opportunity(
						Id = currentNewCreditApplication.Opportunity__c
					));
				}
				
				opportunitiesWithUpdatedBuyer.get(currentNewCreditApplication.Opportunity__c).Buyer_Contact__c = null;
			}
			if (currentNewCreditApplication.Co_Buyer__c == null)
			{
				creditAppIdsWithRemovedCoBuyer.add(currentNewCreditApplication.Id);
				
				if (!opportunitiesWithUpdatedBuyer.containsKey(currentNewCreditApplication.Opportunity__c))
				{
					opportunitiesWithUpdatedBuyer.put(currentNewCreditApplication.Opportunity__c, new Opportunity(
						Id = currentNewCreditApplication.Opportunity__c
					));
				}
				
				opportunitiesWithUpdatedBuyer.get(currentNewCreditApplication.Opportunity__c).Co_Buyer_Contact__c = null;
			}
		}
		
		List<Residence__c> residencesToDelete = [
			SELECT Id
			FROM Residence__c
			WHERE (Credit_Application__c IN :creditAppIdsWithRemovedBuyer AND Is_Primary_Buyer__c = true)
				OR ((Credit_Application__c IN :creditAppIdsWithRemovedCoBuyer AND Is_Primary_Buyer__c = false))
		];
		
		List<Employment__c> employmentsToDelete = [
			SELECT Id
			FROM Employment__c
			WHERE (Credit_Application__c IN :creditAppIdsWithRemovedBuyer AND Is_Primary_Buyer__c = true)
				OR ((Credit_Application__c IN :creditAppIdsWithRemovedCoBuyer AND Is_Primary_Buyer__c = false))
		];
		
	//	update opportunitiesWithUpdatedBuyer.values();
		delete residencesToDelete;
		delete employmentsToDelete;
		
		//isExecuted = true;
	}

	
	public static SObject getUpdatedRecord(dealer__Credit_Application__c upsertedCreditApplication, String sObjectName, String recordId, Map<String, String> mapping)
	{
		SObject record = Schema.getGlobalDescribe().get(sObjectName).newSObject(recordId);
		
		for (String field : mapping.keySet())
		{
			record.put(mapping.get(field), upsertedCreditApplication.get(field));
		}
		
		return record;
	}
	
	public static void addOrRemoveCoAppData(List<dealer__Credit_Application__c> newCreditApplications, Map<Id, dealer__Credit_Application__c> oldCreditApplications)
	{
		for (dealer__Credit_Application__c creditApplication : newCreditApplications)
		{
			if ((creditApplication.dealer__Co_Buyer_Account__c != oldCreditApplications.get(creditApplication.Id).dealer__Co_Buyer_Account__c)
				&& (creditApplication.dealer__Co_Buyer_Account__c == null))
			{
				for (String field : creditAppCoBuyerNullableFields)
				{
					creditApplication.put(field, null);
				}
				for (String field : creditAppCoBuyerDurationFields)
				{
					creditApplication.put(field, '0');
				}
			}
			
			else if (creditApplication.dealer__Co_Buyer_Account__c != oldCreditApplications.get(creditApplication.Id).dealer__Co_Buyer_Account__c)
			{
				String request = 'SELECT ' + String.join(creditAppToCoBuyer.values(), ',') +
					' FROM Account' +
					' WHERE Id = \'' + creditApplication.dealer__Co_Buyer_Account__c + '\'' +
					' LIMIT 1';
				
				Account coBuyer = Database.query(request);
				
				for (String field : creditAppToCoBuyer.keySet())
				{
					creditApplication.put(field, coBuyer.get(creditAppToCoBuyer.get(field)));
				}
			}
		}
	}
	
	public static void setCreditAppName(List<dealer__Credit_Application__c> newCreditApplications)
	{
		for (dealer__Credit_Application__c creditApplication : newCreditApplications)
		{
			String generatedName = '';
			
			if (String.isNotBlank(creditApplication.dealer__First_Name__c))
			{
				generatedName += creditApplication.dealer__First_Name__c;
			}
			
			if (String.isNotBlank(creditApplication.dealer__Last_Name__c))
			{
				generatedName += creditApplication.dealer__Last_Name__c;
			}
			
			creditApplication.Name = generatedName;
		}
	}
	
	public static void updateRelatedRecords(List<dealer__Credit_Application__c> upsertedCreditApplications)
	{
		List<Account> buyerAccountsToUpdate = new List<Account>();
		List<Account> coBuyerAccountsToUpdate = new List<Account>();
		List<dealer__Sales_Up__c> salesUpsToUpdate = new List<dealer__Sales_Up__c>();
		
		Set<Id> buyerAccountsToUpdateIds = new Set<Id>();
		Set<Id> coBuyerAccountsToUpdateIds = new Set<Id>();
		Set<Id> salesUpsToUpdateIds = new Set<Id>();
		Set<Id> salesUpsForAppointments = new Set<Id>();
		
		for (dealer__Credit_Application__c upsertedCreditApplication : upsertedCreditApplications)
		{
			if (upsertedCreditApplication.dealer__Buyer_Account__c != null)
			{
				if (!buyerAccountsToUpdateIds.contains(upsertedCreditApplication.dealer__Buyer_Account__c))
				{
					buyerAccountsToUpdateIds.add(upsertedCreditApplication.dealer__Buyer_Account__c);
					
					buyerAccountsToUpdate.add((Account)getUpdatedRecord(upsertedCreditApplication, 'Account',
						upsertedCreditApplication.dealer__Buyer_Account__c, creditAppToBuyer));
				}
			
			}
			
			if (upsertedCreditApplication.dealer__Co_Buyer_Account__c != null)
			{
				if (!coBuyerAccountsToUpdateIds.contains(upsertedCreditApplication.dealer__Co_Buyer_Account__c))
				{
					coBuyerAccountsToUpdateIds.add(upsertedCreditApplication.dealer__Co_Buyer_Account__c);
					
					coBuyerAccountsToUpdate.add((Account)getUpdatedRecord(upsertedCreditApplication, 'Account',
						upsertedCreditApplication.dealer__Co_Buyer_Account__c, creditAppToCoBuyer));
				}
			}
			
			if (upsertedCreditApplication.Sales_Up__c != null)
			{
				if (!salesUpsToUpdateIds.contains(upsertedCreditApplication.Sales_Up__c))
				{
					salesUpsToUpdateIds.add(upsertedCreditApplication.Sales_Up__c);
					
					salesUpsToUpdate.add((dealer__Sales_Up__c)getUpdatedRecord(upsertedCreditApplication, 'dealer__Sales_Up__c',
						upsertedCreditApplication.Sales_Up__c, creditAppToSalesUp));
				}
				
				if ( upsertedCreditApplication.Credit_Application_Status__c == 'Initial Paycall'
					|| upsertedCreditApplication.Credit_Application_Status__c == 'Pending Verification'
					|| upsertedCreditApplication.Credit_Application_Status__c == 'Incomplete' ) {
					
					salesUpsForAppointments.add(upsertedCreditApplication.Sales_Up__c);
				}
			}
		}
		
		update buyerAccountsToUpdate;
		update coBuyerAccountsToUpdate;
		update salesUpsToUpdate;
		
		if (salesUpsForAppointments.size() > 0) {
			usas_setAppointmentShow.setAppointment(salesUpsForAppointments);
		}
	}
	
	public static void updateRelatedRecordsSafely(List<dealer__Credit_Application__c> upsertedCreditApplications, Map<Id, dealer__Credit_Application__c> oldCreditApplications)
	{
		if (!(AccountService.isExecuted || SalesUpService.isExecuted))
		{
			if (!isExecuted)
			{
				if (oldCreditApplications == null)
				{
					isExecuted = true;
					updateRelatedRecords(upsertedCreditApplications);
					
					return;
				}
				
				Set<String> fieldsToCheck = new Set<String>();
				
				fieldsToCheck.addAll(creditAppToBuyer.keySet());
				fieldsToCheck.addAll(creditAppToCoBuyer.keySet());
				fieldsToCheck.addAll(creditAppToSalesUp.keySet());
				fieldsToCheck.addAll(salesAppointment.keySet()); //NB: 2018-03-13
				
				List<dealer__Credit_Application__c> creditApplicationsToUpdate = new List<dealer__Credit_Application__c>();
				
				for (dealer__Credit_Application__c currentCreditApplication : upsertedCreditApplications)
				{
					for (String field : fieldsToCheck)
					{
						if (currentCreditApplication.get(field) != oldCreditApplications.get(currentCreditApplication.Id).get(field))
						{
							creditApplicationsToUpdate.add(currentCreditApplication);
						}
					}
				}
				
				if (!creditApplicationsToUpdate.isEmpty())
				{
					isExecuted = true;
					updateRelatedRecords(creditApplicationsToUpdate);
				}
			}
		}
	}
}