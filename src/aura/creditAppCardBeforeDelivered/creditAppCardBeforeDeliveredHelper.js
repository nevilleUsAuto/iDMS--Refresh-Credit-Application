({
    createPromise : function(component, action) {
        return new Promise(function(resolve, reject) {
            action.setCallback(this, function(response) {
                if (component.isValid()) {
                    if (response.getState() === "SUCCESS") {
                        resolve(response.getReturnValue());
                    }
                    else if (response.getState() === "ERROR") {
                        reject(response.getError()[0].message);
                    }
                    else {
                        reject("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        });
    },

    setElementsAccess : function(component, action) {
        var managerProfiles = new Set(["LEX SalesMgr", "Regional Manager", "Floating Manager", "LEX Sr Sales Consultant", "System Administrator"]);
        var profilesAllowingActions = new Set(["Vehicle Selected", "Denied"]);

        component.set("v.isManager", managerProfiles.has(component.get("v.userProfile")));
        component.set("v.areActionsAllowed", profilesAllowingActions.has(component.get("v.creditApp.Credit_Application_Status__c")));
    },

    showToast : function(message, mode, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            message : message,
            mode : mode,
            type : type
        });
        toastEvent.fire();
    },
})