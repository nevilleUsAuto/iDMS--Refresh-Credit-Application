({
    validateForm : function (component, joinCoBuyerFields) {
        var coBuyerInputSections = component.find("cobuyer-info");;
        var buyerInputSections = component.find("buyer-info");
        var isFormValid = true;

        var sectionErrNames = ["current-housing-information-err", "previous-housing-information-err",
            "employment-information-err", "credit-history-err", "military-expirience-err", "repeat-customer-err"];

        for (var currentSectionIndex = 0; currentSectionIndex < buyerInputSections.length; currentSectionIndex++) {
            var isValid = true;
            var buyerComponents = [];

            var inputs = buyerInputSections[currentSectionIndex].find({ instancesOf : "lightning:input" });
            var selects = buyerInputSections[currentSectionIndex].find({ instancesOf : "lightning:select" });
            var checkboxes = buyerInputSections[currentSectionIndex].find({ instancesOf : "ui:inputCheckbox" })

            Array.prototype.push.apply(inputs, coBuyerInputSections[currentSectionIndex].find({ instancesOf : "lightning:input" }));
            Array.prototype.push.apply(selects, coBuyerInputSections[currentSectionIndex].find({ instancesOf : "lightning:select" }));
            Array.prototype.push.apply(inputs, coBuyerInputSections[currentSectionIndex].find({ instancesOf : "ui:inputText" }));

            Array.prototype.push.apply(buyerComponents, inputs);
            Array.prototype.push.apply(buyerComponents, selects);
            Array.prototype.push.apply(buyerComponents, checkboxes);

            console.log("here3");

            for (var currentInputIndex = 0; currentInputIndex < buyerComponents.length; currentInputIndex++) {
                if (buyerComponents[currentInputIndex].get("v.disabled")) {
                    $A.util.removeClass(buyerComponents[currentInputIndex], "slds-has-error");
                    continue;
                }

                console.log("iteration");

                if (buyerComponents[currentInputIndex].isInstanceOf("lightning:input") || buyerComponents[currentInputIndex].isInstanceOf("lightning:select")) {
                    if (!buyerComponents[currentInputIndex].get("v.validity").valid) {

                        console.log("iteration1");
                        isValid = false;
                        $A.util.addClass(buyerComponents[currentInputIndex], "slds-has-error");
                        //buyerComponents[currentInputIndex].addEventHandler("v.change", component.getReference("c.fixInputField"));//??
                    } else {
                        $A.util.removeClass(buyerComponents[currentInputIndex], "slds-has-error");
                    }
                }

                if (buyerComponents[currentInputIndex].isInstanceOf("c:selectlist")) {
                    if (inputFields[i].get("v.required")) {
                        if (!inputFields[i].get("v.value")) {
                            isValid = false;
                            $A.util.addClass(buyerComponents[currentInputIndex], "slds-has-error");
                        } else {
                            $A.util.removeClass(buyerComponents[currentInputIndex], "slds-has-error");
                        }
                        //buyerComponents[currentInputIndex].addEventHandler("v.change", component.getReference("c.fixInputField"));//??
                    }
                }

                if (buyerComponents[currentInputIndex].isInstanceOf("ui:inputDate")) {
                    if (inputFields[i].get("v.errors").length > 0) {
                        isValid = false;
                        $A.util.addClass(buyerComponents[currentInputIndex], "slds-has-error");
                        //buyerComponents[currentInputIndex].addEventHandler("v.change", component.getReference("c.fixInputField"));//??
                    } else {
                        $A.util.removeClass(buyerComponents[currentInputIndex], "slds-has-error");
                    }
                }
            }

            console.log("here4");

            var sectionError = component.find(sectionErrNames[currentSectionIndex]);

            if (!isValid) {
                //sectionError.set("v.isTrue", false);
                $A.util.addClass(sectionError, "slds-is-active");
                isFormValid = false;
            } else { $A.util.removeClass(sectionError, "slds-is-active");
                //sectionError.set("v.isTrue", true);
            }
        }

        /*var errorMessageComponents = component.find("error-message-item");
        errorMessageComponents.forEach(function (currentComponent, i, arr) {
            currentComponent.set("v.isTrue", !isValid);
        });*/

        return isFormValid;
    },

    checkCoBuyerFilling : function (component) {
        var wasFilled = false;
        var coBuyerInputSections = component.find("cobuyer-info");
        console.log("size = " + coBuyerInputSections.length);
        var coBuyerComponents = [];

        for (var currentSectionIndex = 0; currentSectionIndex < coBuyerInputSections.length; currentSectionIndex++) {
            console.log("here1 juhu- " + coBuyerInputSections[currentSectionIndex]);
            var inputs = coBuyerInputSections[currentSectionIndex].find({instancesOf: "lightning:input"});
            var selects = coBuyerInputSections[currentSectionIndex].find({instancesOf: "lightning:select"});
            var checkBoxes = coBuyerInputSections[currentSectionIndex].find({instancesOf: "ui:inputCheckbox"});
            Array.prototype.push.apply(coBuyerComponents, inputs);
            Array.prototype.push.apply(coBuyerComponents, selects);
            Array.prototype.push.apply(coBuyerComponents, checkBoxes);
        }

        for (var currentInputIndex = 0; currentInputIndex < coBuyerComponents.length; currentInputIndex++) {
            if (coBuyerComponents[currentInputIndex].get("v.value") != null && coBuyerComponents[currentInputIndex].get("v.value") != '') {
                wasFilled = true;
                break;
            }
        }

        for (var currentInputIndex = 0; currentInputIndex < coBuyerComponents.length; currentInputIndex++) {
            if (!wasFilled) {
                $A.util.removeClass(coBuyerComponents[currentInputIndex], "slds-has-error");
            }
        }

        return wasFilled;
    },

    handleCustomerChange : function (component) {
        var customerCards;
        var saveButtonDisabled = false;
        var searchResult = component.find("customer-card");

        if (!(searchResult instanceof Array)) {
            customerCards = new Array(searchResult);
        } else {
            customerCards = searchResult;
        }

        console.log("validate");

        customerCards.forEach(function(currentCard, i, arr){
            if (!currentCard.get("v.isCardValid") && !currentCard.get("v.isReadOnly")) {
                saveButtonDisabled = true;
                return;
            }
        });

        component.find("save-creditapp-button").set("v.disabled", saveButtonDisabled);
    },

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

    showToast : function(message, mode, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            message : message,
            mode : mode,
            type : type
        });
        console.log(message);

        toastEvent.fire();
    },

    showSpinner : function(component, auraId) {
        console.log("parent show");
        var spinner = component.find(auraId);
        spinner.set("v.isTrue", true);
    },

    hideSpinner : function(component, auraId) {
        var spinner = component.find(auraId);
        spinner.set("v.isTrue", false);
    },
})