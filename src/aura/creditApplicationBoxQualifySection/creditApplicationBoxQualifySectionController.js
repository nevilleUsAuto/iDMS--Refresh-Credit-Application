({
	searchActiveApplicationsInSystem : function(component, event, helper) {
		var searchStepNumber = 1;
		var finalStepNumber = 2;

		component.set("v.stepNumber", searchStepNumber);

		var searchActiveApplicationsAction = component.get("c.searchActiveApplications");

		searchActiveApplicationsAction.setParams({
			"buyerSocialSecurityNumber" : component.get("v.buyerSocialSecurityNumber"),
			"coBuyerSocialSecurityNumber" : component.get("v.coBuyerSocialSecurityNumber"),
			"salesPortalAccessToken" : component.get("v.salesPortalAccessToken")
		});

		var searchActiveApplicationsPromise = helper.executeAction(component, searchActiveApplicationsAction);
		searchActiveApplicationsPromise.then(
			$A.getCallback(function(searchResultJSON) {
				console.log(JSON.parse(searchResultJSON));
				component.set("v.searchResult", JSON.parse(searchResultJSON));
				component.set("v.stepNumber", finalStepNumber);
			})
		)
		.catch(
			$A.getCallback(function(errorMessage) {
				component.set("v.errorMessage", errorMessage);

				var showExceptionEvent = component.getEvent("showInnerErrorMessageEvent");

				showExceptionEvent.setParams({
					"errorMessage" : errorMessage
				});

				showExceptionEvent.fire();
			})
		);
	},

	validateSocialSecurityNumber : function(component, event, helper) {
		var ssnFormatWithNoDashes = new RegExp("^[0-9]{9}$");
		var socialSecurityNumberInputs = component.find("social-security-number");

		for (var input of socialSecurityNumberInputs) {
			if (!input.get("v.validity").valid) {
				component.find("search-button").set("v.disabled", true);

				return;
			}
			else {
				var inputValue = input.get("v.value");

				if (ssnFormatWithNoDashes.test(inputValue))
				{
					input.set("v.value", inputValue.substring(0, 3) + "-" + inputValue.substring(3, 5) + "-" + inputValue.substring(5, 9));
				}
			}
		}

		component.find("search-button").set("v.disabled", false);
	},

	qualifyCreditApplication : function(component, event, helper) {
		var createCreditApplicationURL = "/apex/CreditApplicationEdit?isCreation=true&salesUpId=" + component.get("v.salesUpId");

        helper.redirectToVisualForcePage(component, event, createCreditApplicationURL);
	}
})