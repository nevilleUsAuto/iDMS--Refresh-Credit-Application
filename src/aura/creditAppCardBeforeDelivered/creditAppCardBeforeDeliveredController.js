({
    init : function(component, event, helper) {
        helper.setElementsAccess(component, event);

        var getDealDetailsAction = component.get("c.getDealDetails");
        getDealDetailsAction.setParams({
            creditApplicationSalesPortalId : component.get("v.creditApp.Sales_Portal_ID__c"),
            salesPortalAccessToken : component.get("v.salesPortalAccessToken")
        });

        var getDealDetailsPromise = helper.createPromise(component, getDealDetailsAction);
        getDealDetailsPromise.then(
            $A.getCallback(function(dealDetails){
                component.set("v.dealDetails", dealDetails);

                component.getEvent("hideSpinner").fire();
            })
        ).catch(
            $A.getCallback(function(error) {
                helper.showToast(error, "sticky", "error");
            })
        );
    },

    sendDealForFinalApproval : function(component, event, helper) {
        component.getEvent("showSpinner").fire();

        var sendDealForFinalApprovalAction = component.get("c.sendDealForManagersApproval");
        sendDealForFinalApprovalAction.setParams({
            creditApplication : component.get("v.creditApp"),
            salesPortalAccessToken : component.get("v.salesPortalAccessToken"),
            tradeACV : component.get("v.dealDetails.vehicleDetails.tradeACV"),
            tradePayoff : component.get("v.dealDetails.vehicleDetails.tradePayoff"),
            warrantyId : component.get("v.dealDetails.vehicleDetails.warrantyID")
        });

        var sendDealForFinalApprovalPromise = helper.createPromise(component, sendDealForFinalApprovalAction);
        sendDealForFinalApprovalPromise.then(
            $A.getCallback(function(creditApplication) {
                component.set("v.creditApp", creditApplication);

                helper.setElementsAccess(component, event);
                helper.showToast("Application was submitted for final approval.", "dismissible", "success");
            })
        ).catch(
            $A.getCallback(function(error) {
                helper.showToast(error, "sticky", "error");
            })
        ).then(
            $A.getCallback(function(error) {
                component.getEvent("hideSpinner").fire();
            })
        );
    },

    removeVehicleFromDeal : function(component, event, helper) {
        component.getEvent("showSpinner").fire();

        var removeVehicleAction = component.get("c.removeVehicle");
        removeVehicleAction.setParams({
            "creditApplication" : component.get("v.creditApp"),
            "salesPortalAccessToken" : component.get("v.salesPortalAccessToken")
        });

        var removeVehicleActionPromise = helper.createPromise(component, removeVehicleAction);
        removeVehicleActionPromise.then(
            $A.getCallback(function() {
                component.getEvent("reloadBox").fire();

                helper.showToast("Vehicle was removed.", "dismissible", "success");
            })
        ).catch(
            $A.getCallback(function(error) {
                helper.showToast(error, "sticky", "error");

                component.getEvent("hideSpinner").fire();
            })
        );
    },

    changePayment : function(component, event, helper) {
        var vscList = component.get("v.dealDetails.vehicleDetails.vscItems");

        for (var vscItem of vscList) {
            if (vscItem.id == component.get("v.dealDetails.vehicleDetails.warrantyID")) {
                component.set("v.dealDetails.vehicleDetails.payment", vscItem.payment);
                component.set("v.dealDetails.vehicleDetails.maxTerm", vscItem.term);
                component.set("v.dealDetails.vehicleDetails.warrantyPrice", vscItem.warrantyPrice);

                break;
            }
        }
    },

    validateNumberInput : function(component, event, helper) {
        var input = event.getSource();
        var inputValue = input.get("v.value");

        if ($A.util.isEmpty(inputValue) || (inputValue < 0)) {
            input.set("v.value", 0);
        }
    },

    reloadBox : function(component, event, halper) {
        event.getSource().set("v.disabled", true);

        component.getEvent("reloadBox").fire();
    },
})