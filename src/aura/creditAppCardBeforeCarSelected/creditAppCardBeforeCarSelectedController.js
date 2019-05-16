({
    init : function(component, event, helper) {
        console.log('before car selected here');
        var getAdjustedScoresAction = component.get("c.getAdjustedScores");
        getAdjustedScoresAction.setParams({
            creditApplicationSalesPortalId : component.get("v.creditApp.Sales_Portal_ID__c"),
            salesPortalAccessToken : component.get("v.salesPortalAccessToken")
        });

        var getAdjustedScoresPromise = helper.createPromise(component, getAdjustedScoresAction);
        getAdjustedScoresPromise.then(
            $A.getCallback(function(adjustedScores) {
                component.set("v.adjustedScores", adjustedScores);

                component.getEvent("reloadForm").fire();
                component.getEvent("hideSpinner").fire();
                
            })
        ).catch(
            $A.getCallback(function(error) {
                console.log('before car selected init error');
                helper.showToast(error, "sticky", "error");
            })
        );
    },

    openInventoryGrid : function(component, event, helper) {
        component.getEvent("showSpinner").fire();
	
        var getCurrentUserStateAction = component.get("c.getCurrentUserState");
        var getCurrentUserStatePromise = helper.createPromise(component, getCurrentUserStateAction);

		getCurrentUserStatePromise.then(
            $A.getCallback(function (result) {
				var creditApp = component.get("v.creditApp");
                var navigateEvent = $A.get("e.force:navigateToComponent");
                navigateEvent.setParams({
                    componentDef : "c:inventoryGrid",
                    componentAttributes : {
                        creditAppId : creditApp.Id,
                        salesPortalAccessToken : component.get("v.salesPortalAccessToken"),
						selectedLocationId : creditApp.Store_Location__r.SalesPortalId__c,
						userStateId : result,
                        userProfile : component.get("v.userProfile"),
                        isJoint : (event.getSource().getLocalId() == "joint")
                    }
                });
                navigateEvent.fire();
            }).bind(this)
        ).catch(
            $A.getCallback(function(error) {
                helper.showToast(error, "sticky", "error");
            })
        );

        component.getEvent("hideSpinner").fire();
    },

    editCreditApplication : function(component, event, helper) {
        component.getEvent("showSpinner").fire();

        var creditApp = component.get("v.creditApp");

        var logEditAction = component.get("c.createTrafficLog");
        logEditAction.setParams({
            creditApplicationId : creditApp.Id,
            OpportunityId : creditApp.Opportunity__c,
            customerId : creditApp.Buyer__c,
            logType : "Credit App Edited"
        });

        var logEditPromise = helper.createPromise(component, logEditAction);
        logEditPromise.then(
            $A.getCallback(function() {
				var redirectToOpportunityEvent = $A.get("e.force:navigateToSObject");

				redirectToOpportunityEvent.setParams({
					"recordId": creditApp.Opportunity__c,
					"slideDevName": "detail"
				});
				redirectToOpportunityEvent.fire();
            })
        ).catch(
            $A.getCallback(function(error) {
                helper.showToast(error, "sticky", "error");
            })
        );
    },

    getCreditScoreLetterPrinted : function(component, event, helper) {
        component.getEvent("showSpinner").fire();

        var isJoint = event.getSource().getLocalId() == "jointLetter";
        var creditApp = component.get("v.creditApp");
        var adjustedScores = component.get("v.adjustedScores");
        var salesPortalAccessToken = component.get("v.salesPortalAccessToken");

        var printLetterAction = component.get("c.markCreditScoreLetterAsSent");
        printLetterAction.setParams({
            "isJointScore" : isJoint,
            "creditApplicationSalesPortalId" : creditApp.Sales_Portal_ID__c,
            "salesPortalAccessToken" : component.get("v.salesPortalAccessToken")
        });

        var getCreditScoreLetterPrintedPromise = helper.createPromise(component, printLetterAction);
        getCreditScoreLetterPrintedPromise.then(
            $A.getCallback(function() {
                var urlString = "/apex/CreditScoreLetterPdfDownload?OpportunityId=" + creditApp.Opportunity__c
                    + "&buyerFirstName=" + creditApp.Buyer__r.FirstName + "&buyerLastName=" + creditApp.Buyer__r.LastName
                    + "&buyerScore=" + adjustedScores.primaryScore.beaconScoreValue + "&buyerAdvantagePercent=" + adjustedScores.primaryScore.ficoPercent;

                if (isJoint) {
                    urlString += "&calledFromPrintButton=joint&coBuyerFirstName=" + creditApp.Co_Buyer__r.FirstName
                        + "&coBuyerLastName=" + creditApp.Co_Buyer__r.LastName + "&coBuyerScore=" + adjustedScores.coBuyerScore.beaconScoreValue
                        + "&coBuyerAdvantagePercent=" + adjustedScores.coBuyerScore.ficoPercent;
                }
                else {
                    urlString += "&calledFromPrintButton=single";
                }

                $A.createComponent(
                    "c:visualforceDownloadFrame",
                    {
                        url : urlString,
                        onload : component.getReference("c.init")
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
            })
        ).catch(
            $A.getCallback(function(error) {
                helper.showToast(error, "sticky", "error");
            })
        );
    },

    downloadInitialPaycallInfoDocument : function(component, event, helper) {
        component.getEvent("showSpinner").fire();

        var adjustedScores = component.get("v.adjustedScores");
        var creditApp = component.get("v.creditApp");

        var initialPaycallInfoDownloadPageURL = "/apex/InitialPaycallInfoPdfDownload?dealId=" + creditApp.Sales_Portal_ID__c;

        if ($A.util.isEmpty(adjustedScores.jointScore)){
            initialPaycallInfoDownloadPageURL += "&customer=" + creditApp.Buyer__r.FirstName + ' ' + creditApp.Buyer__r.LastName
                + "&maxPurchase=" + adjustedScores.primaryScore.maxPurchasePrice
                + "&downPaymentOver=" + (adjustedScores.primaryScore.minimumDownPaymentOver * 100)
                + "&downPaymentUnder=" + (adjustedScores.primaryScore.minimumDownPaymentUnder * 100)
                + "&customerCode=" + adjustedScores.primaryScore.customerCode
                + "&maxMonthly=" + adjustedScores.primaryScore.maxMonthlyPayment;
        } else {
            initialPaycallInfoDownloadPageURL += "&customer=" + creditApp.Buyer__r.FirstName + ' ' + creditApp.Buyer__r.LastName + '/' + creditApp.Co_Buyer__r.FirstName + ' ' + creditApp.Co_Buyer__r.LastName
                + "&maxPurchase=" + adjustedScores.jointScore.maxPurchasePrice
                + "&downPaymentOver=" + (adjustedScores.jointScore.minimumDownPaymentOver * 100)
                + "&downPaymentUnder=" + (adjustedScores.jointScore.minimumDownPaymentUnder * 100)
                + "&customerCode=" + adjustedScores.coBuyerScore.customerCode
                + "&maxMonthly=" + adjustedScores.jointScore.maxMonthlyPayment;
        }

        $A.createComponent(
            "c:visualforceDownloadFrame",
            {
                url : initialPaycallInfoDownloadPageURL,
                onload : component.getReference("c.hideSpinner")
            },
            function(newComponent, status, errorMessage) {
                if (status === "SUCCESS") {
                    var visualforceDownloadFrameContainer = component.find("visualforce-download-frame-container");
                    visualforceDownloadFrameContainer.set("v.body", [newComponent]);
                } else if (status === "INCOMPLETE") {
                    helper.showToast("No response from server or client offline", "dismissible", "warning");
                } else if (status === "ERROR") {
                    helper.showToast("Error: " + errorMessage, "sticky", "error");
                }
            }
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