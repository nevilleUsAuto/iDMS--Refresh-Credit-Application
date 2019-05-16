@isTest
private class CreditApplicationUploadControllerTest
{
	private static void init()
	{
		dealer__Credit_Application__c creditApplication = new dealer__Credit_Application__c
		(
			dealer__First_Name__c = 'Test Buyer',
			dealer__Middle_Name__c = 'Test Buyer',
			dealer__Last_Name__c = 'Test Buyer',
			dealer__Co_App_First_Name__c = 'Test Co-Buyer',
			dealer__Co_App_Last_Name__c = 'Test Co-Buyer',
			dealer__Home_Phone__c = '12345678',
			dealer__Mobile_Phone__c = '12345678',
			dealer__Email_Address__c = 'test@test.test',
			dealer__Driver_License_No__c = '12345678',
			Driver_License_State__c = 'GA',
			Current_Address_Duration_Years__c = '1',
			Present_Employer_Duration_Years__c = '1',
			Repeat_Customer__c = '1 Prior Purchase',
			Co_App_Current_Address_Duration_Years__c = '1',
			Co_App_Present_Employer_Duration_Years__c = '1',
			Co_App_Repeat_Customer__c = '1 Prior Purchase'
		);
		insert creditApplication;

		PageReference uploadPage = Page.CreditApplicationUpload;
		uploadPage.getParameters().put('creditAppId', creditApplication.Id);

		Test.setCurrentPage(uploadPage);
	}
	
	@isTest static void testAttachFileToCreditApplication()
	{
		init();

		CreditApplicationUploadController controller = new CreditApplicationUploadController();
		controller.init();
		controller.file.Name = 'Test.txt';
		controller.file.Body = Blob.valueOf('Test string');

		Test.startTest();
		controller.attachFileToCreditApplication();
		Test.stopTest();

		List<Attachment> existingApplicationAttachment = [
			SELECT Id
			FROM Attachment
			WHERE ParentId = :ApexPages.currentPage().getParameters().get('creditAppId')
			LIMIT 1
		];

		System.assertEquals(false, existingApplicationAttachment.isEmpty());
	}
}