({
    createPromise : function(component, action) {
        return new Promise(function(resolve, reject) {
            action.setCallback(this, function(response) {
                if (component.isValid()) {
                    if (response.getState() === "SUCCESS") {
                        resolve(response.getReturnValue());
                    } else if (response.getState() === "ERROR") {
                        reject(response.getError()[0].message);
                    } else {
                        reject("Unknown error");
                    }
                }
            });

            $A.enqueueAction(action);
        });
    },

    showSpinner : function(component, event) {
        var popovers = component.find("box-container").find({instancesOf : "c:popover"});

        for (var i = 0; i < popovers.length; i++) {
            popovers[i].set("v.isVisible", false);
        }

        var actionSpinner = component.find("action-spinner");
        actionSpinner.set("v.isTrue", true);
    },

    hideSpinner : function(component, event) {
        var actionSpinner = component.find("action-spinner");
        actionSpinner.set("v.isTrue", false);
    },

    showToast : function(message, mode, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            message : message,
            mode : mode,
            type : type
        });
        toastEvent.fire();
    }
});