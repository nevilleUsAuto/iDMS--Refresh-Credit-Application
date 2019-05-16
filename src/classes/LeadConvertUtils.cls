public with sharing class LeadConvertUtils
{
	public static final List<String> LEAD_TO_OPPORTUNITY = new List<String>{'Phone', 'MobilePhone', 'Work_Phone__c', 'Make__c', 'Year_High__c', 'VIN__c', 'Model__c', 'Trim__c', 'Transmission__c', 'Color_Preference_Ext__c', 'Color_Preference_Int__c', 'Comments__c', 'BDC_Rep__c', 'Source__c', 'Salesperson_1__c', 'Store_Location_New__c', 'Channel__c'};
	public static final List<String> LEAD_TO_EMPLOYMENT = new List<String>{'Present_Employer_Duration_Years__c', 'Present_Employer_Duration_Months__c', 'Net_Period_Paycheck__c', 'Salary_Type__c', 'Work_Phone__c'};
	public static final List<String> LEAD_TO_RESIDENCE = new List<String>{'House_Number__c', 'Street', 'City', 'State', 'PostalCode', 'Home_Address_2__c', 'Current_Address_Duration_Years__c', 'Current_Address_Duration_Months__c', 'Housing_type__c'};
	public static final List<String> LEAD_TO_CREDIT_APP = new List<String>{'Currently_in_bankruptcy__c', 'Credit_Application_Status__c', 'Other_Income__c', 'Sales_Portal_Creation_Date__c', 'Store_Location_New__c', 'Sales_Portal_Id__c', 'Is_Verified__c'};
	public static final List<String> LEAD_TO_CONTACT = new List<String>{'FirstName', 'LastName', 'Middle_Name__c', 'Social_Security_Number__c', 'Personal_Birthdate__c', 'Email', 'Phone', 'MobilePhone', 'Work_Phone__c', 'Customer_Id__c', 'Driver_s_License_State__c', 'Drivers_License_Number__c', 'Drivers_License_Expiration_Date__c', 'Is_Military__c', 'Military_Status__c'};
	public static final List<String> OPPORTUNITY_TO_LEAD = new List<String>{'Home_Phone__c', 'Mobile__c', 'Phone__c', 'Make__c', 'Year_High__c', 'Trade_VIN__c', 'Model__c', 'Trim__c', 'Transmission__c', 'Color_Preference_Ext__c', 'Color_Preference_Int__c', 'Comments__c', 'BDC_Rep__c', 'AccountId', 'Salesperson_1__c', 'Store_Location__c', 'Lead_Channel__c'};
	public static final List<String> CREDIT_APP_TO_LEAD = new List<String>{'Currently_in_bankruptcy__c', 'Credit_Application_Status__c', 'Other_Income__c', 'Sales_Portal_Creation_Date__c', 'Store_Location__c', 'Sales_Portal_ID__c', 'Verified_By_Lead_Service__c'};
	public static final List<String> CONTACT_TO_LEAD = new List<String>{'FirstName', 'LastName', 'MiddleName', 'SocialSecurityNumber__c', 'Birthdate', 'Email', 'HomePhone', 'MobilePhone', 'Work_Phone__c', 'SalesPortalId__c', 'Driver_License_State__c', 'Driver_License_Number__c', 'Driver_License_Expiration_Date__c', 'Is_Military__c', 'Military_Status__c'};
	public static final List<String> CONTACT_TO_OPPORTUNITY = new List<String>{'HomePhone', 'MobilePhone', 'Work_Phone__c', 'Email'};  //NB 2019-03-18  Added Email to the list so that it will be added to the opportunity record.
	public static final List<String> OPPORTUNITY_TO_CONTACT = new List<String>{'Home_Phone__c', 'Mobile__c', 'Phone__c', 'Email__c'};  //NB 2019-03-18  Added Email to the list so that it will be added to the opportunity record.
	public static final List<String> EMPLOYMENT_TO_LEAD = new List<String>{'Employer_Duration_Years__c', 'Employer_Duration_Months__c', 'Applicant_Net_Period_Paycheck__c', 'Salary_Type__c', 'Employer_Phone__c'};
	public static final List<String> RESIDENCE_TO_LEAD = new List<String>{'House_Number__c', 'Address_Street__c', 'Address_City__c', 'Address_State__c', 'Address_Zip__c', 'Home_Address_2__c', 'Address_Duration_Years__c', 'Address_Duration_Months__c', 'Housing_type__c'};
	
	public static Map<String, String> createObjectToObjectMapping(List<String> fromFields, List<String> toFields)
	{
		if (fromFields.size() != toFields.size())
		{
			throw new CannotGenerateMappingException('Field mappinп cannot be generated! ' + fromFields + ' ' + toFields);
		}
		
		Map<String, String> result = new Map<String, String>();
		
		for (Iterator<String> fromIterator = fromFields.iterator(), toIterator = toFields.iterator();
			fromIterator.hasNext() & toIterator.hasNext(); )
		{
			result.put(fromIterator.next(), toIterator.next());
		}
		
		return result;
	}
	
	public static void matchRecords(SObject toRecord, SObject fromRecord, Map<String, String> fieldMapping, Boolean sameObject, Boolean emptyFieldMergeOnly)
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
	
	class CannotGenerateMappingException extends Exception {}
}