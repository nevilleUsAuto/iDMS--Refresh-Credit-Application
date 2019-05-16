public without sharing class CreditApplicationHandler implements TriggerTemplate.Handler
{
	private List<dealer__Credit_Application__c> newValues;
	private Map<Id, dealer__Credit_Application__c> oldValues;
	
	public void setValues(List<sObject> newValues, Map<Id, sObject> oldValues)
	{
		this.newValues = newValues;
		this.oldValues = (Map<Id, dealer__Credit_Application__c>) oldValues;
	}
	
	public void handle(TriggerTemplate.TriggerAction action)
	{
		if (action == TriggerTemplate.TriggerAction.beforeUpdate)
		{
			CreditApplicationService.addOrRemoveCoAppData(newValues, oldValues);
		}
		
		if (action == TriggerTemplate.TriggerAction.afterUpdate)
		{
			CreditApplicationService.updateRelatedRecordsSafely(newValues, oldValues);
		}
		
		if (action == TriggerTemplate.TriggerAction.afterInsert)
		{
			CreditApplicationService.updateRelatedRecordsSafely(newValues, null);
		}
		
		if (action == TriggerTemplate.TriggerAction.beforeInsert)
		{
			CreditApplicationService.setCreditAppName(newValues);
		}
	}
}