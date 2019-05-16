({
    init : function(component, event, helper) {
        var beforeInitialPaycallStatuses = new Set(["In Progress", "Incomplete", "Conditionally Scored", "Awaiting Stips", "Pending Verification", "Pending Paycall"]);
        var beforeVehicleSelectedStatuses = new Set(["Initial Paycall", "Letter Printed"]);
        var beforeDeliveredStatuses = new Set(["Vehicle Selected", "Pending Final Approval", "Approved", "Denied", "Delivered"]);

        var profilesBDC = new Set(["BDC Agent", "ISC New", "BDC Manager New"]);

        var creditApplicationCardContainer = component.find("card-container");
        var creditApp = component.get("v.creditApp");

        if (beforeInitialPaycallStatuses.has(creditApp.Credit_Application_Status__c)) {
            $A.createComponent(
                "c:creditAppCardBeforePaycall",
                {
                    creditApp : component.getReference("v.creditApp"),
                    salesPortalAccessToken : component.get("v.salesPortalAccessToken"),
                    isBDC : profilesBDC.has(component.get("v.userProfile"))
                },
                function(newComponent, status, errorMessage) {
                    if (status === "SUCCESS") {
                        creditApplicationCardContainer.set("v.body", [newComponent]);
                    } else if (status === "INCOMPLETE") {
                        helper.showToast("No response from server or client offline.", "dismissible", "warning");
                    } else if (status === "ERROR") {
                        helper.showToast("Error: " + errorMessage, "sticky", "error");
                    }
                }
            );
        } else if (beforeVehicleSelectedStatuses.has(creditApp.Credit_Application_Status__c)) {
            $A.createComponent(
                "c:creditAppCardBeforeCarSelected",
                {
                    creditApp : component.getReference("v.creditApp"),
                    salesPortalAccessToken : component.get("v.salesPortalAccessToken"),
                    userProfile : component.get("v.userProfile")
                },
                function(newComponent, status, errorMessage) {
                    if (status === "SUCCESS") {
                        creditApplicationCardContainer.set("v.body", [newComponent]);
                    } else if (status === "INCOMPLETE") {
                        helper.showToast("No response from server or client offline.", "dismissible", "warning");
                    } else if (status === "ERROR") {
                        helper.showToast("Error: " + errorMessage, "sticky", "error");
                    }
                }
            );
        } else if (beforeDeliveredStatuses.has(creditApp.Credit_Application_Status__c)) {
            $A.createComponent(
                "c:creditAppCardBeforeDelivered",
                {
                    creditApp : component.getReference("v.creditApp"),
                    employment : component.getReference("v.employment"),
                    salesPortalAccessToken : component.get("v.salesPortalAccessToken"),
                    userProfile : component.get("v.userProfile")
                },
                function(newComponent, status, errorMessage) {
                    if (status === "SUCCESS") {
                        creditApplicationCardContainer.set("v.body", [newComponent]);
                    } else if (status === "INCOMPLETE") {
                        helper.showToast("No response from server or client offline.", "dismissible", "warning");
                    } else if (status === "ERROR") {
                        helper.showToast("Error: " + errorMessage, "sticky", "error");
                    }
                }
            );
        }
    }

});