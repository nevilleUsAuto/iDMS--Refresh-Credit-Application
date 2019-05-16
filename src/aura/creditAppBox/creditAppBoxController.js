({
    init : function(component, event, helper) {
        helper.showSpinner(component, event);

        var salesPortalAccessToken, opportunity, wrapper, userProfile;

        var getSalesPortalAccessTokenAction = component.get("c.getSalesPortalAccessToken");

        var getSalesPortalAccessTokenPromise = helper.createPromise(component, getSalesPortalAccessTokenAction);
        getSalesPortalAccessTokenPromise.then(
            $A.getCallback(function(token) {
                salesPortalAccessToken = token;

                var getUserProfileNameAction = component.get("c.getUserProfile");

                var getOpportunityAction = component.get("c.getOpportunity");
                getOpportunityAction.setParams({
                    opportunityId : component.get("v.recordId")
                });

                var getCreditApplicationAction = component.get("c.getCreditApplication");
                getCreditApplicationAction.setParams({
                    opportunityId : component.get("v.recordId"),
                    salesPortalAccessToken : salesPortalAccessToken
                });

                var getUserProfileNamePromise = helper.createPromise(component, getUserProfileNameAction);
                var getSalesUpPromise = helper.createPromise(component, getOpportunityAction);
                var getCreditApplicationPromise = helper.createPromise(component, getCreditApplicationAction);

                return Promise.all([getUserProfileNamePromise, getSalesUpPromise, getCreditApplicationPromise]);
            })
        ).then(
            $A.getCallback(function(results) {
                userProfile = results[0];
                opportunity = results[1];
                wrapper = JSON.parse(results[2]);

                var creditApplicationBoxContainer = component.find("box-container");

                if ($A.util.isEmpty(wrapper)) {
                    $A.createComponent(
                        "c:creditAppQualify",
                        {
                            opportunity : opportunity,
                            salesPortalAccessToken : salesPortalAccessToken
                        },
                        function(newComponent, status, errorMessage) {
                            if (status === "SUCCESS") {
                                creditApplicationBoxContainer.set("v.body", [newComponent]);

                            } else if (status === "INCOMPLETE") {
                                helper.showToast("No response from server or client offline", "dismissible", "warning");
                            } else if (status === "ERROR") {
                                helper.showToast("Unexpected error. " + errorMessage, "sticky", "error");
                            }
                        }
                    );
                } else {
                    $A.createComponent(
                        "c:creditAppCard",
                        {
                            creditApp : wrapper.creditApp,
                            employment : wrapper.employment,
                            userProfile : userProfile,
                            salesPortalAccessToken : salesPortalAccessToken,
                            opportunityId : opportunity.Id
                        },
                        function(newComponent, status, errorMessage) {
                            if (status === "SUCCESS") {
                                creditApplicationBoxContainer.set("v.body", [newComponent]);
                            } else if (status === "INCOMPLETE") {
                                helper.showToast("No response from server or client offline", "dismissible", "warning");
                            } else if (status === "ERROR") {
                                helper.showToast("Unexpected error. " + errorMessage, "sticky", "error");
                            }
                        }
                    );
                }
                component.set('v.showIDMSNow', true);
            })
        ).catch(
             $A.getCallback(function(errorMessage) {
                 helper.showToast(errorMessage, "sticky", "error");
             })
        );
    },

    showSpinner : function (component, event, helper) {
        helper.showSpinner(component, event);
    },

    hideSpinner : function (component, event, helper) {
        helper.hideSpinner(component, event);
    }

});