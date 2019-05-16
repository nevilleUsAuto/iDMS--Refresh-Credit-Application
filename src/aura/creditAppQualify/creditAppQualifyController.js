({
    init : function(component, event, helper) {
        var hideSpinnerEvent = component.getEvent("hideSpinner");
        hideSpinnerEvent.fire();
    },

    searchActiveApplicationsInSystem : function(component, event, helper) {
        const SEARCH_STEP_NUMBER = 1;
        const FINAL_STEP_NUMBER = 2;

        component.set("v.stepNumber", SEARCH_STEP_NUMBER);

        var searchActiveApplicationsAction = component.get("c.searchActiveApplications");
        searchActiveApplicationsAction.setParams({
            buyerSocialSecurityNumber : component.get("v.buyerSocialSecurityNumber"),
            coBuyerSocialSecurityNumber : component.get("v.coBuyerSocialSecurityNumber"),
            salesPortalAccessToken : component.get("v.salesPortalAccessToken")
        });

        var searchActiveApplicationsPromise = helper.createPromise(component, searchActiveApplicationsAction);
        searchActiveApplicationsPromise.then(
            $A.getCallback(function(searchResult) {
                component.set("v.searchResult", searchResult);
                component.set("v.stepNumber", FINAL_STEP_NUMBER);
            })
        )
        .catch(
            $A.getCallback(function(errorMessage) {
                component.set("v.isErrorOccured", true);

                helper.showToast(errorMessage, "sticky", "error");
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
            } else {
                var inputValue = input.get("v.value");

                if (ssnFormatWithNoDashes.test(inputValue)) {
                    input.set("v.value", inputValue.substring(0, 3) + "-" + inputValue.substring(3, 5) + "-" + inputValue.substring(5, 9));
                }
            }
        }

        component.find("search-button").set("v.disabled", false);
    },

    qualifyCreditApplication : function(component, event, helper) {
        var opportunity = component.get("v.opportunity");

        var logQualifyAction = component.get("c.createTrafficLog");
        logQualifyAction.setParams({
            "opportunityId" : opportunity.Id,
            "customerId" : opportunity.Buyer__c,
            "logType" : "Credit App Created"
        });

        var logQualifyPromise = helper.createPromise(component, logQualifyAction);
        logQualifyPromise.then(
            $A.getCallback(function() {
                var createCreditApplicationURL = "/apex/CreditApplicationEdit?isCreation=true&OpportunityId=" + opportunity.Id;

                helper.redirectToVisualForcePage(component, event, createCreditApplicationURL);
            })
        ).catch(
            $A.getCallback(function(error) {
                helper.showToast(errorMessage, "sticky", "error");
            })
        );
    },

    retry : function(component, event, helper) {
        const INITIAL_STEP_NUMBER = 0;

        component.set("v.stepNumber", INITIAL_STEP_NUMBER);

        component.find("search-button").set("v.disabled", false);
    },
})