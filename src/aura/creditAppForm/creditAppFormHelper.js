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

    getValidationMethodsMapping : function() {
        var validationMethodsMapping = new Map();

        validationMethodsMapping.set("Drivers_License_Expiration_Date__c", this.validateDriversLicenseExpirationDate);

        return validationMethodsMapping;
    },

    validateDriversLicenseExpirationDate : function(inputComponent) {
        var driversLicenseExpirationDate = new Date(inputComponent.get("v.value"));
        var today = new Date();

        if (driversLicenseExpirationDate < today) {
            inputComponent.set("v.validity", {valid : false, badInput : true});
        }
    },
})