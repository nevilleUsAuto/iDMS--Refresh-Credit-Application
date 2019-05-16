public with sharing class CreditApplicationProcessHandler implements TriggerTemplate.Handler
{
	private static final List<String> fieldsRequiredToSync = new List<String> {'Store_Location__c', 'Credit_Application_Status__c', 'Buyer__c', 'Co_Buyer__c'};
	
	private List<Credit_Application__c> newValues;
	private Map<Id, Credit_Application__c> oldValues;
	
	public void setValues(List<sObject> newValues, Map<Id, sObject> oldValues)
	{
		this.newValues = newValues;
		this.oldValues = (Map<Id, Credit_Application__c>) oldValues;
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
		
		if (action == TriggerTemplate.TriggerAction.afterUpdate)
		{
			List<Credit_Application__c> updatedSyncedFieldCreditApplications = CreditApplicationService.getUpdatedRecords(newValues, oldValues, fieldsRequiredToSync);
			
			if (!updatedSyncedFieldCreditApplications.isEmpty())
			{
				CreditApplicationService.updateSyncedFields(updatedSyncedFieldCreditApplications);
			}
		}
	}
}