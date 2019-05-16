public class CreditApplicationUploadController
{
	public Attachment file {get; set;}

	public void init()
	{
		file = new Attachment();
	}

	public PageReference attachFileToCreditApplication()
	{
		List<Attachment> existingApplicationAttachment = [
			SELECT Id
			FROM Attachment
			WHERE ParentId = :ApexPages.currentPage().getParameters().get('creditAppId')
			LIMIT 1
		];

		Attachment newCreditApplicationAttachment = new Attachment(
			ParentId = ApexPages.currentPage().getParameters().get('creditAppId'),
			Body = file.Body,
			ContentType = file.ContentType,
			Name = file.Name
		);

		delete existingApplicationAttachment;
		insert newCreditApplicationAttachment;

		file = null;

		return new PageReference('/' + ApexPages.currentPage().getParameters().get('opportunityId'));
	}
}