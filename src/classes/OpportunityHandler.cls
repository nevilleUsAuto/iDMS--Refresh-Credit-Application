public without sharing class OpportunityHandler implements TriggerTemplate.Handler
{
	private static Set<String> updatingFromButtonFields = new Set<String>
	{
		'OwnerId', 'Store_Location__c', 'Salesperson_1__c'
	};
	
	private List<Opportunity> newValues;
	private Map<Id, Opportunity> oldValues;
	
	public void setValues(List<sObject> newValues, Map<Id, sObject> oldValues)
	{
		this.newValues = newValues;
		this.oldValues = (Map<Id, Opportunity>) oldValues;
	}
	
	public void handle(TriggerTemplate.TriggerAction action)
	{
		List<UserRole> adminOverride = [
			SELECT Id
			FROM UserRole
			WHERE Name = :'Administrator Override'
		];
		
		if (!adminOverride.isEmpty())
		{
			if (adminOverride[0].Id == UserInfo.getUserRoleId())
			{
				return;
			}
		}
		
		if (action == TriggerTemplate.TriggerAction.beforeupdate)
		{
			handleButtonAction(newValues, oldValues, getUpdatedFields(newValues, oldValues));
		}
		if (action == TriggerTemplate.TriggerAction.afterUpdate)
		{
			List<Opportunity> updatedOpportunities = OpportunityService.getUpdatedRecords(newValues, oldValues,
                    new List<String>{'Buyer_Contact__c', 'Co_Buyer_Contact__c', 'Store_Location__c', 'OwnerId'});
			
			if (!updatedOpportunities.isEmpty())
			{
				OpportunityService.updateActiveCreditApplications(updatedOpportunities);
			}

			// NB 2019-04-04 new functionality added
			// Opportunity Owner/Salesperson 1 change notification
			System.debug('Testing: Email/Chatter notifications');
			new OwnerPersonChangeNotificationHandler(newValues, oldValues);
		}
	}
	
	private static void handleButtonAction(List<Opportunity> newOpportunities, Map<Id, Opportunity> oldOpportunities, Map<String, List<Opportunity>> updatedFields)
	{
		if (updatedFields.containsKey('OwnerId'))
		{
			OpportunityService.handleOwnerIdChange(updatedFields.get('OwnerId'), oldOpportunities);
		}
		else if (updatedFields.containsKey('Store_Location__c'))
		{
			OpportunityService.handleStoreChange(updatedFields.get('Store_Location__c'));
		}
		else if (updatedFields.containsKey('Salesperson_1__c'))
		{
			OpportunityService.handleSalespersonChange(updatedFields.get('Salesperson_1__c'));
		}
	}
	
	private static Map<String, List<Opportunity>> getUpdatedFields(List<Opportunity> newOpportunitys, Map<Id, Opportunity> oldOpportunitys)
	{
		Map<String, List<Opportunity>> updatedFieldToNewValues = new Map<String, List<Opportunity>>();
		
		for (String currentFieldName : updatingFromButtonFields)
		{
			List<Opportunity> updatedValues = OpportunityService.getUpdatedRecords(newOpportunitys, oldOpportunitys, new List<String>{currentFieldName});
			
			if (!updatedValues.isEmpty())
			{
				updatedFieldToNewValues.put(currentFieldName, updatedValues);
			}
		}
		
		return updatedFieldToNewValues;
	}
}