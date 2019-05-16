({
    init : function(component, event, helper) {
        var statusesRequiringVisibleHelpMessage = new Set(["In Progress", "Conditionally Scored", "Awaiting Stips", "Pending Verification", "Pending Paycall"]);
        var statusesRequiringVisibleContent = new Set(["In Progress", "Incomplete", "Conditionally Scored", "Awaiting Stips"]);
        var shortOrPhoneAppStatuses = new Set(["Conditionally Scored", "Awaiting Stips"]);

        if (statusesRequiringVisibleHelpMessage.has(component.get("v.creditApp.Credit_Application_Status__c"))) {
            component.set("v.isHelpMessageVisible", true);
        }

        if (statusesRequiringVisibleContent.has(component.get("v.creditApp.Credit_Application_Status__c"))) {
            component.set("v.isCardContentVisible", true);
        }

        var initPromises = [];

        var getCreditApplicationFilePromise;

        if (component.get("v.creditApp.Ready_To_Submit__c")) {
            var getCreditApplicationFileAction = component.get("c.getCreditApplicationFile");
            getCreditApplicationFileAction.setParams({
                creditApplicationId : component.get("v.creditApp.Id"),
            });

            getCreditApplicationFilePromise = helper.createPromise(component, getCreditApplicationFileAction);
            initPromises.push(getCreditApplicationFilePromise);
        }

        var getAdjustedScoresPromise;

        if (shortOrPhoneAppStatuses.has(component.get("v.creditApp.Credit_Application_Status__c"))) {
            var getAdjustedScoresAction = component.get("c.getOnlineAppAdjustedScores");
            getAdjustedScoresAction.setParams({
                creditApplicationSalesPortalId : component.get("v.creditApp.Sales_Portal_ID__c"),
                salesPortalAccessToken : component.get("v.salesPortalAccessToken")
            });

            getAdjustedScoresPromise = helper.createPromise(component, getAdjustedScoresAction);
            initPromises.push(getAdjustedScoresPromise);
        }

        if (initPromises.length > 0) {
            Promise.all(initPromises).then(
                $A.getCallback(function(results) {
                    if (!$A.util.isEmpty(getCreditApplicationFilePromise)) {
                        component.set("v.creditAppFile", results[0]);
                    } else {
                        component.set("v.adjustedScores", results[0]);
                        component.getEvent("hideSpinner").fire();
                        console.log('fire1');
                        component.getEvent("reloadForm").fire();
                        return;
                    }

                    if (!$A.util.isEmpty(getAdjustedScoresPromise)) {
                        component.set("v.adjustedScores", results[1]);
                    }

                    component.getEvent("hideSpinner").fire();
                    console.log('fire2');
                    component.getEvent("reloadForm").fire();
                }).bind(this)
            ).catch(
                $A.getCallback(function(errorMessage) {
                    helper.showToast(errorMessage, "sticky", "error")
                })
            );
        } else {
            component.getEvent("hideSpinner").fire();
        }
    },

    openCreditApplicationEditForm : function(component, event, helper) {
        component.getEvent("showSpinner").fire();

        var logEditAction = component.get("c.createTrafficLog");
        logEditAction.setParams({
            creditApplicationId : component.get("v.creditApp.Id"),
            OpportunityId : component.get("v.creditApp.Opportunity__c"),
            customerId : component.get("v.creditApp.Buyer__c"),
            logType : "Credit App Edited"
        });

        var logEditPromise = helper.createPromise(component, logEditAction);
        logEditPromise.then(
            $A.getCallback(function() {
                var creditApplicationEditURL = "/apex/CreditApplicationEdit?isCreation=false&OpportunityId=" + component.get("v.creditApp.Opportunity__c")
                    + "&creditAppId=" + component.get("v.creditApp.Id");

                helper.redirectToVisualForcePage(creditApplicationEditURL);
            })
        ).catch(
            $A.getCallback(function(errorMessage) {
                helper.showToast(errorMessage, "sticky", "error")
            })
        );
    },

    downloadCreditApplicationFile : function(component, event, helper) {
        component.getEvent("showSpinner").fire();

        var fileDownloadURL = "/apex/CreditApplicationPdfDownload?OpportunityId=" + component.get("v.creditApp.Opportunity__c")
            + "&id=" + component.get("v.creditApp.Id");

        console.log('test - ' + fileDownloadURL);

        $A.createComponent(
            "c:visualforceDownloadFrame",
            {
                url : fileDownloadURL,
                onload : component.getReference("c.hideSpinner")
            },
            function(newComponent, status, errorMessage) {
                if (status === "SUCCESS") {
                    var visualforceDownloadFrameContainer = component.find("visualforce-download-frame-container");
                    visualforceDownloadFrameContainer.set("v.body", [newComponent]);
                } else if (status === "INCOMPLETE") {
                    alert("No response from server or client offline.");
                } else if (status === "ERROR") {
                    alert("Error: " + errorMessage)
                }
            }
        );
    },

    openFileUploadPage : function(component, event, helper) {
        component.getEvent("showSpinner").fire();

        var fileUploadURL = "/apex/CreditApplicationUpload?opportunityId=" + component.get("v.creditApp.Opportunity__c")
                + "&creditAppId=" + component.get("v.creditApp.Id");

        helper.redirectToVisualForcePage(fileUploadURL);
    },

    sendShortApplicationApprovalEmail : function(component, event, helper) {
        component.getEvent("showSpinner").fire();

        var sendApprovalEmailAction = component.get("c.sendApprovalEmail");
        sendApprovalEmailAction.setParams({
            firstName : component.get("v.creditApp.Buyer__r.FirstName"),
            email : component.get("v.creditApp.Buyer__r.Email"),
            maxFinanceAmount : component.get("v.adjustedScores.maxPurchasePrice"),
            salesPortalAccessToken : component.get("v.salesPortalAccessToken")
        });

        var sendApprovalEmailActionPromise = helper.createPromise(component, sendApprovalEmailAction);
        sendApprovalEmailActionPromise.then(
            $A.getCallback(function(isSuccessful) {
                if (isSuccessful) {
                    helper.showToast("Email was sent.", "dismissible", "success");
                } else {
                    helper.showToast("Email was not sent. Please try again later or notify your manager.", "dismissible", "warning");
                }
            })
        ).catch(
            $A.getCallback(function(errorMessage) {
                helper.showToast(errorMessage, "sticky", "error");
            })
        ).then(
            $A.getCallback(function() {
                component.getEvent("hideSpinner").fire();
            })
        );
    },

    submitCreditApplication : function(component, event, helper) {
        component.getEvent("showSpinner").fire();

        var isSubmitWithoutStips = (event.getSource().getLocalId() == "submit-without-stips");
        var creditApp = component.get("v.creditApp");

        var submitCreditApplicationAction = component.get("c.submit");
        submitCreditApplicationAction.setParams({
            creditApplicationId : creditApp.Id,
            creditApplicationFile : component.get("v.creditAppFile"),
            fileType : isSubmitWithoutStips ? "Stips" : "Stips",
            salesPortalAccessToken : component.get("v.salesPortalAccessToken")
        });

        var submitCreditApplicationActionPromise = helper.createPromise(component, submitCreditApplicationAction);
        submitCreditApplicationActionPromise.then(
            $A.getCallback(function(creditApp) {
                if (!isSubmitWithoutStips) {
                    component.set("v.isCardContentVisible", false);
                    component.set("v.isHelpMessageVisible", true);
                }

                component.set("v.creditApp", creditApp);

                if (creditApp.Credit_Application_Status__c == "Pending Verification") {
                    component.set("v.adjustedScores", null);
                }
            })
        ).then(
            $A.getCallback(function() {
                var logSubmitAction = component.get("c.createTrafficLog");
                logSubmitAction.setParams({
                    creditApplicationId : creditApp.Id,
					OpportunityId : creditApp.Opportunity__c,
                    customerId : creditApp.Buyer__c,
                    logType : "Credit App Submitted"
                });

                return helper.createPromise(component, logSubmitAction);
            })
        ).then(
            $A.getCallback(function() {
                helper.showToast("Credit application submitted.", "dismissible", "success");

                component.getEvent("reloadForm").fire();
            })
        ).catch(
            $A.getCallback(function(errorMessage) {
                console.log(errorMessage);
                helper.showToast(errorMessage, "sticky", "error");
            })
        ).then(
            $A.getCallback(function() {
                component.getEvent("hideSpinner").fire();
                $A.get('e.force:refreshView').fire();
            })
        );
    },

    reloadBox : function(component, event, helper) {
        event.getSource().set("v.disabled", true);

        component.getEvent("reloadBox").fire();
    },

    hideSpinner : function(component, event, helper) {
        component.getEvent("hideSpinner").fire();
    },
})