public without sharing class CreditApplicationPdfController
{
	public Credit_Application__c creditApplication {get; set;}
	public RelatedListWrapper relatedListWrapper {get; set;}

	public Boolean isPreviousAddressDisplayed {get; set;}
	public Boolean isPreviousEmployerInfoDisplayed {get; set;}
	public Boolean isOtherIncomeDisplayed {get; set;}
	public Boolean isRepeatCustomerInfoDisplayed {get; set;}

	public Boolean isCoAppInCreditApp {get; set;}
	public Boolean isCoAppPreviousAddressDisplayed {get; set;}
	public Boolean isCoAppPreviousEmployerInfoDisplayed {get; set;}
	public Boolean isCoAppOtherIncomeDisplayed {get; set;}
	public Boolean isCoAppRepeatCustomerInfoDisplayed {get; set;}

	private Years_Requiring_Previous_Information__c yearBoundCustomSetting = Years_Requiring_Previous_Information__c.getInstance('Standard Settings');

	private Set<String> yearsRequiringPreviousInformationForHousing;
	private Set<String> yearsRequiringPreviousInformationForEmployer;

	private static final String REPEAT_CUSTOMER_REASON_NO = 'No';

	public CreditApplicationPdfController(ApexPages.StandardController standardController)
	{
		yearsRequiringPreviousInformationForHousing = new Set<String>(yearBoundCustomSetting.Housing_Information__c.split(','));
		yearsRequiringPreviousInformationForEmployer = new Set<String>(yearBoundCustomSetting.Employer_Information__c.split(','));

		creditApplication = (Credit_Application__c)standardController.getRecord();
		Id creditApplicationId = creditApplication.Id;
		
		List<String> employmentFields = new List<String>();
		employmentFields.addAll(Schema.getGlobalDescribe().get('Employment__c').getDescribe().fields.getMap().keySet());
		List<String> residenceFields = new List<String>();
		residenceFields.addAll(Schema.getGlobalDescribe().get('Residence__c').getDescribe().fields.getMap().keySet());
		
		String employmentQuery = 'SELECT ' + String.join(employmentFields, ',') + ' FROM Employment__c WHERE Credit_Application__c = :creditApplicationId ORDER BY CreatedDate LIMIT 4';
		String residenceQuery = 'SELECT ' + String.join(residenceFields, ',') + ' FROM Residence__c WHERE Credit_Application__c = :creditApplicationId ORDER BY CreatedDate LIMIT 4';
		
		List<Employment__c> employmentsList = (List<Employment__c>)Database.query(employmentQuery);
		List<Residence__c> residensesList = (List<Residence__c>)Database.query(residenceQuery);
		
		relatedListWrapper = new RelatedListWrapper(employmentsList, residensesList);
		
		hideNonRequiredBuyerInfo();
		hideNonRequiredCoBuyerInfo();
	}

	public void hideNonRequiredBuyerInfo()
	{
		if (yearsRequiringPreviousInformationForHousing.contains(relatedListWrapper.buyerCurrentResidence.Address_Duration_Years__c))
		{
			isPreviousAddressDisplayed = true;
		}
		
		if (yearsRequiringPreviousInformationForEmployer.contains(relatedListWrapper.buyerCurrentEmployment.Employer_Duration_Years__c))
		{
			isPreviousEmployerInfoDisplayed = true;
		}

		if (relatedListWrapper.buyerCurrentEmployment.Other_Income__c != 0)
		{
			isOtherIncomeDisplayed = true;
		}

		if (this.creditApplication.Repeat_Customer__c != REPEAT_CUSTOMER_REASON_NO)
		{
			isRepeatCustomerInfoDisplayed = true;
		}
	}

	public void hideNonRequiredCoBuyerInfo()
	{
		if (String.isNotBlank(creditApplication.Co_Buyer__r.FirstName))
		{
			isCoAppInCreditApp = true;

			if (yearsRequiringPreviousInformationForHousing.contains(relatedListWrapper.coBuyerCurrentResidence.Address_Duration_Years__c))
			{
				isCoAppPreviousAddressDisplayed = true;
			}

			if (yearsRequiringPreviousInformationForEmployer.contains(relatedListWrapper.coBuyerCurrentEmployment.Employer_Duration_Years__c))
			{
				isCoAppPreviousEmployerInfoDisplayed = true;
			}

			if (relatedListWrapper.coBuyerPreviousEmployment.Other_Income__c != 0)
			{
				isCoAppOtherIncomeDisplayed = true;
			}

			if (creditApplication.Co_App_Repeat_Customer__c != 'No')
			{
				isCoAppRepeatCustomerInfoDisplayed = true;
			}
		}
	}
	
	public class RelatedListWrapper
	{
		public Employment__c buyerCurrentEmployment {get; set;}
		public Employment__c buyerPreviousEmployment {get; set;}
		public Employment__c coBuyerCurrentEmployment {get; set;}
		public Employment__c coBuyerPreviousEmployment {get; set;}
		public Residence__c buyerCurrentResidence {get; set;}
		public Residence__c buyerPreviousResidence {get; set;}
		public Residence__c coBuyerCurrentResidence {get; set;}
		public Residence__c coBuyerPreviousResidence {get; set;}
		
		public RelatedListWrapper(List<Employment__c> employments, List<Residence__c> residences)
		{


			for (Employment__c currentEmployment : employments)
			{
				if (currentEmployment.Is_Current_Employment__c)
				{
					if (currentEmployment.Is_Primary_Buyer__c)
					{
						if (buyerCurrentEmployment == null)
						{
							buyerCurrentEmployment = currentEmployment;
						}
					}
					else
					{
						if (coBuyerCurrentEmployment == null)
						{
							coBuyerCurrentEmployment = currentEmployment;
						}
					}
				}
				else
				{
					if (currentEmployment.Is_Primary_Buyer__c)
					{
						if (buyerPreviousEmployment == null)
						{
							buyerPreviousEmployment = currentEmployment;
						}
					}
					else
					{
						if (coBuyerPreviousEmployment == null)
						{
							coBuyerPreviousEmployment = currentEmployment;
						}
					}
				}
			}
			
			for (Residence__c currentResidence : residences)
			{
				if (currentResidence.Is_Current_Residence__c)
				{
					if (currentResidence.Is_Primary_Buyer__c)
					{
						if (buyerCurrentResidence == null)
						{
							buyerCurrentResidence = currentResidence;
						}
					}
					else
					{
						if (coBuyerCurrentResidence == null)
						{
							coBuyerCurrentResidence = currentResidence;
						}
					}
				}
				else
				{
					if (currentResidence.Is_Primary_Buyer__c)
					{
						if (buyerPreviousResidence == null)
						{
							buyerPreviousResidence = currentResidence;
						}
					}
					else
					{
						if (coBuyerPreviousResidence == null)
						{
							coBuyerPreviousResidence = currentResidence;
						}
					}
				}
			}
		}
	}
}