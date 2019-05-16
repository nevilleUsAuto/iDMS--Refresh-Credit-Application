({
    init : function(component, event, helper) {
        var getPicklistsAction = component.get("c.getAllPicklistsByName");
        var getPickListsAction = helper.createPromise(component, getPicklistsAction);

        getPickListsAction.then(
            $A.getCallback(function(picklists){
                component.set("v.picklists", JSON.parse(picklists));

                var getCreditApplicationAction = component.get("c.getCreditApplication");

                getCreditApplicationAction.setParams({
                    creditApplicationId : component.get("v.creditApplicationId")
                });

                return helper.createPromise(component, getCreditApplicationAction);
            })
        ).then(
            $A.getCallback(function (creditApplication) {
                component.set("v.creditApplication", creditApplication);

                if (creditApplication.Current_Address_Duration_Years__c > 5) {
                    component.set("v.previousBuyerAddressDisabled", true);
                }

                if (creditApplication.Co_App_Current_Address_Duration_Years__c > 5) {
                    component.set("v.previousCoBuyerAddressDisabled", true);
                }

                if (creditApplication.Present_Employer_Duration_Years__c > 5) {
                    component.set("v.previousBuyerEmployerDisabled", true);
                }

                if (creditApplication.Co_App_Present_Employer_Duration_Years__c > 5) {
                    component.set("v.previousCoBuyerEmployerDisabled", true);
                }

                if (creditApplication.Is_Military__c) {
                    component.set("v.buyerMilitaryDisabled", false);
                }

                if (creditApplication.Co_App_Is_Military__c) {
                    component.set("v.coBuyerMilitaryDisabled", false);
                }

                var creditApplication = component.get("v.creditApplication");
                var getCustomersAction = component.get("c.getCustomers");

                getCustomersAction.setParams({
                    buyerId : creditApplication.dealer__Buyer_Account__c,
                    coBuyerId : creditApplication.dealer__Co_Buyer_Account__c
                });

                return helper.createPromise(component, getCustomersAction);
            })
        ).then(
            $A.getCallback(function(customers){
                component.set("v.buyer", customers[0]);

                if (customers.length == 2) {
                    component.set("v.cobuyer", customers[1]);
                }

                helper.hideSpinner(component, "component-action-spinner");
            })
        ).catch(
            $A.getCallback(function(errorMessage) {
                helper.showToast(errorMessage, "sticky", "error")
            })
        );
    },

    navigateToFormSection : function(component, event, helper) {
        console.log("here -656    " + event.getSource().get("v.selectedItem"));
        var navigatedSection = component.find(event.getSource().get("v.selectedItem"));

        navigatedSection.getElement().scrollIntoView();

        /*if (event.target.getAttribute("aria-level") < 6) {
            var scrolledY = window.scrollY;

            if(scrolledY) {
                window.scroll(0, scrolledY - 140);
            }
        }*/
    },

    setValidPhoneFormat : function(component, event, helper) {
        var editablePhoneValuePattern = new RegExp("^[0-9]{10}$");

        var sourceComponent = event.getSource();
        var phoneValue = sourceComponent.get("v.value");

        if (editablePhoneValuePattern.test(phoneValue)) {
            sourceComponent.set("v.value", phoneValue.substring(0, 3) + "-" + phoneValue.substring(3, 6) + "-" + phoneValue.substring(6, 10));
        }
    },

    validateSocialSecurityNumber : function(component, event, helper) {
        var ssnFormatWithNoDashes = new RegExp("^[0-9]{9}$");
        var socialSecurityNumberInput = event.getSource();

        if (!socialSecurityNumberInput.get("v.validity").valid) {
            component.find("search-button").set("v.disabled", true);
            return;
        } else {
            var inputValue = socialSecurityNumberInput.get("v.value");

            if (inputValue == component.get("v.buyer").SocialSecurityNumber__c) {
                component.find("search-button").set("v.disabled", true);
                socialSecurityNumberInput.set('v.validity', {valid:false, badInput :true});
                return;
            }

            if (ssnFormatWithNoDashes.test(inputValue)) {
                socialSecurityNumberInput.set("v.value", inputValue.substring(0, 3) + "-" + inputValue.substring(3, 5) + "-" + inputValue.substring(5, 9));
            }
        }

        component.find("search-button").set("v.disabled", false);
    },

    validateLicenseExpirationDate : function(component, event, helper) {
        var licenseExpirationDateInput = event.getSource();

        var licenseExpirationDate = licenseExpirationDateInput.get("v.value");
        var today = new Date()

        if (licenseExpirationDate < today) {
            licenseExpirationDateInput.set("v.validity", {valid : false, badInput : true});
        }
    },

    handlePreviousAddressEnabling : function (component, event, helper) {
        var priviousAddressInput = event.getSource();
        var creditApp = component.get("v.creditApplication");

        if (priviousAddressInput.get("v.name") == "currentAddressYears") {
            if (parseInt(priviousAddressInput.get("v.value")) > 5) {
                var previousHousingInputs = component.find("buyer-previous-housing");

                previousHousingInputs.forEach(function(currentInput, i, arr) {
                    currentInput.set("v.value", null);
                    $A.util.removeClass(currentInput, "slds-has-error");
                });

                component.set("v.previousBuyerAddressDisabled", true);
            } else {
                component.set("v.previousBuyerAddressDisabled", false);
            }
        } else {
            if (parseInt(priviousAddressInput.get("v.value")) > 5) {
                var previousHousingInputs = component.find("cobuyer-previous-housing");

                previousHousingInputs.forEach(function(currentInput, i, arr) {
                    currentInput.set("v.value", null);
                    $A.util.removeClass(currentInput, "slds-has-error");
                });

                component.set("v.previousCoBuyerAddressDisabled", true);
            } else {
                component.set("v.previousCoBuyerAddressDisabled", false);
            }
        }

        component.set("v.creditApplication", creditApp);
    },

    handlePreviuosEmoloyerEnabling : function (component, event, helper) {
        var prsentEmployerYearsInput = event.getSource();
        var creditApp = component.get("v.creditApplication");
        var previousEmployerInputs;

        if (prsentEmployerYearsInput.get("v.name") == "presentEmployerDurationYears") {
            if (parseInt(prsentEmployerYearsInput.get("v.value")) > 5) {
                component.set("v.previousBuyerEmployerDisabled", true);
                var previousEmployerInputs = component.find("buyer-previous-employer");

                previousEmployerInputs.forEach(function (currentInput, i, arr) {
                    currentInput.set("v.value", null);
                    $A.util.removeClass(currentInput, "slds-has-error");
                });
            } else {
                component.set("v.previousBuyerEmployerDisabled", false);
            }

        } else {
            if (parseInt(prsentEmployerYearsInput.get("v.value")) > 5) {
                component.set("v.previousCoBuyerEmployerDisabled", true);
                var previousEmployerInputs = component.find("cobuyer-previous-employer");

                previousEmployerInputs.forEach(function (currentInput, i, arr) {
                    currentInput.set("v.value", null);
                    $A.util.removeClass(currentInput, "slds-has-error");
                });
            } else {
                component.set("v.previousCoBuyerEmployerDisabled", false);
            }
        }

        component.set("v.creditApplication", creditApp);
    },

    handleMiliraryEnabling : function (component, event, helper) {
        var militaryCheckbox = event.getSource();
        var creditApp = component.get("v.creditApplication");

        if (militaryCheckbox.get("v.name") == "isMilitary") {
            if (militaryCheckbox.get("v.value")) {
                component.set("v.buyerMilitaryDisabled", false);
            } else {
                component.set("v.buyerMilitaryDisabled", true);

                var militaryInput = component.find("buyer-military");
                militaryInput.set("v.value", null);
                $A.util.removeClass(militaryInput, "slds-has-error");
            }
        } else {
            if (militaryCheckbox.get("v.value")) {
                component.set("v.coBuyerMilitaryDisabled", false);
            } else {
                component.set("v.coBuyerMilitaryDisabled", true);

                var militaryInput = component.find("cobuyer-military");
                militaryInput.set("v.value", null);
                $A.util.removeClass(militaryInput, "slds-has-error");
            }
        }

        component.set("v.creditApplication", creditApp);
    },

    enableCoBuyerCreateModal : function (component, event, helper) {
        component.set("v.coBuyerSocialSecurityNumber", null);
        component.set("v.searchResult", null);
        component.set("v.addCobuyerModal", true);
    },

    enableDeleteCoBuyerModal : function (component, event, helper) {
        component.set("v.deleteCoBuyerModal", true);
    },

    closeModal : function (component, event, helper) {
        component.set("v.addCobuyerModal", false);
        component.set("v.finishEditModal", false);
        component.set("v.deleteCoBuyerModal", false);
    },

    searchCobuyer : function (component, event, helper) {
        component.set("v.searchResult", null);

        var searchForCustomerAction = component.get("c.getAccountsBySocialSecurityNumber");

        searchForCustomerAction.setParams({
            "coBuyerSocialSecurityNumber" : component.get("v.coBuyerSocialSecurityNumber")
        });

        var searchForCustomerPromise = helper.createPromise(component, searchForCustomerAction);

        searchForCustomerPromise.then(
            $A.getCallback(function(searchResult){
                if (searchResult != null) {
                    component.set("v.searchResult", searchResult);
                    component.find("save-button").set("v.disabled", !searchResult.canContinue);
                }
            })
        );
    },

    saveCoBuyer : function (component, event, helper) {
        var cobuyer = component.get("v.searchResult").coBuyer;
        var creditApplication = component.get("v.creditApplication");

        creditApplication.dealer__Co_Buyer_Account__c = cobuyer.Id;
        component.set("v.creditApplication", creditApplication);
        component.set("v.cobuyer", cobuyer);
        component.set("v.addCobuyerModal", false);
        component.set("v.coBuyerSocialSecurityNumber", null);
        component.set("v.searchResult", null);

        if (component.get("v.saveButtonClickedMode")) {
            helper.validateForm(component, true);
        }
    },

    deleteCoBuyer : function (component, event, helper) {
        component.set("v.cobuyer", null);
        var creditApplication = component.get("v.creditApplication");

        //retry with selecting all cobuyer sections and empty all inputs!!
        var coBuyerFieldNames = [];
        for(var fieldName in creditApplication) {
            if (fieldName.includes("Co_App")) {
                coBuyerFieldNames.push(fieldName);
            }
        }

        coBuyerFieldNames.forEach(function(currentFieldName, i, arr){
            creditApplication[currentFieldName] = null;
        });

        component.set("v.creditApplication", creditApplication);
        component.set("v.deleteCoBuyerModal", false);

        helper.handleCustomerChange(component);

        if (component.get("v.saveButtonClickedMode")) {
            helper.validateForm(component, false);
        }
    },

    redirectToSalesUp : function (component, event, helper) {
        var redirectToSalesUpEvent = $A.get("e.force:navigateToSObject");

        redirectToSalesUpEvent.setParams({
            "recordId" : event.getSource().get("v.value"),
            "slideDevName": "detail"
        });

        redirectToSalesUpEvent.fire();
    },

    tryToSaveCreditApplication : function (component, event, helper) {
        helper.showSpinner(component, "component-action-spinner");

        //var wasCoBuyerFilled = helper.checkCoBuyerFilling(component);

        console.log("here1");

        var isFormValid = helper.validateForm(component);

        console.log("here2");

        component.set("v.isFormValid", isFormValid);
        component.set("v.finishEditModal", true);
        component.set("v.saveButtonClickedMode", true);

        helper.hideSpinner(component, "component-action-spinner");
    },

    finishSaveCreditApplication : function (component, event, helper) {
        helper.showSpinner(component, "component-action-spinner");

        var finishSaveCreditApplicationAction = component.get("c.saveCreditApplication");

        finishSaveCreditApplicationAction.setParams({
            buyer : component.get("v.buyer"),
            coBuyer : component.get("v.cobuyer"),
            creditApplication : component.get("v.creditApplication"),
            isReadyToSubmit : component.get("v.isFormValid")
        });

        var finishSaveCreditApplicationPromise = helper.createPromise(component, finishSaveCreditApplicationAction);
        finishSaveCreditApplicationPromise.then(
            $A.getCallback(function(salesUpId){
                var redirectToSalesUpEvent = $A.get("e.force:navigateToSObject");

                redirectToSalesUpEvent.setParams({
                    "recordId" : salesUpId,
                    "slideDevName": "detail"
                });

                redirectToSalesUpEvent.fire();
            })
        ).catch(
            $A.getCallback(function(errorMessage) {
                helper.showToast(errorMessage, "sticky", "error");
                console.log(errorMessage);
            })
        );
    },

    backToSalesUp : function (component, event, helper) {
        var salesUpId = component.get("v.creditApplication").Sales_Up__c;
        var redirectToSalesUpEvent = $A.get("e.force:navigateToSObject");

        redirectToSalesUpEvent.setParams({
            "recordId" : salesUpId,
            "slideDevName": "detail"
        });

        redirectToSalesUpEvent.fire();
    },

    handleCustomerChange : function (component, event, helper) {
        helper.handleCustomerChange(component);
    },

    fixInputField : function (component, event, helper, type) {
        if (event.getSource().get("v.validity").valid) {
            $A.util.removeClass(event.getSource(), "slds-has-error");
        }
    },
})