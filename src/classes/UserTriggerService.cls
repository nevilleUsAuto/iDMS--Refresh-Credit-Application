public with sharing class UserTriggerService
{
	public static void createUsersOnSalesPortal(List<User> newValues)
	{
		Set<Id> newSalesforceUsersIds = new Set<Id>();

		for (User newSalesForceUser : newValues)
		{
			newSalesforceUsersIds.add(newSalesForceUser.Id);
		}

		sendUsersToSalesPortal(newSalesforceUsersIds);
	}

	@future(callout = true)
	public static void sendUsersToSalesPortal(Set<Id> newSalesForceUsersIds)
	{
		List<User> newSalesForceUsers = [
			SELECT Email, FirstName, LastName
			FROM User
			WHERE Id IN :newSalesForceUsersIds
		];

		Map<String, User> emailToSalesForceUser = new Map<String, User>();

		for (User newSalesForceUser : newSalesForceUsers)
		{
			emailToSalesForceUser.put(newSalesForceUser.Email, newSalesForceUser);
		}

		List<SalesPortalAPIRequests.SaveUserRequestBody> newSalesPortalUsers = new List<SalesPortalAPIRequests.SaveUserRequestBody>();

		for (User newSalesForceUser : newSalesForceUsers)
		{
			SalesPortalAPIRequests.SaveUserRequestBody newSalesPortalUser = new SalesPortalAPIRequests.SaveUserRequestBody();

			newSalesPortalUser.SFEmail = newSalesForceUser.Email;
			newSalesPortalUser.SPUser = 'USAUTOSALES\\' + newSalesForceUser.FirstName + ' ' + newSalesForceUser.LastName;

			newSalesPortalUsers.add(newSalesPortalUser);
		}

		String salesPortalAccessToken = SalesPortalAPI.authentificateOnSalesPortal(20000);

		List<SalesPortalAPIResponses.UserData> createdSalesPortalUsers = SalesPortalAPI.saveUser(JSON.serialize(newSalesPortalUsers), salesPortalAccessToken, 100000);

		for (SalesPortalAPIResponses.UserData createdSalesPortalUser : createdSalesPortalUsers)
		{
			// NBO 2019-05-07 added if condition below.  Idiotic programming sending bank a hard-coded email.
			// Meaning: only that hard coded email is acceptable in testing. -- (emailsavetest@email.com)
			// additionally, this should use a MOCK for HTTP callout test classes.

			if (emailToSalesForceUser.get(createdSalesPortalUser.SFEmail) != null) {
				emailToSalesForceUser.get(createdSalesPortalUser.SFEmail).Sales_Portal_ID__c = String.valueOf(createdSalesPortalUser.UserId);
			}
		}

		update emailToSalesForceUser.values();
	}
}