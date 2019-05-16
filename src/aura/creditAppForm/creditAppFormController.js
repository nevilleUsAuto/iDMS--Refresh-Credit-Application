({
    init : function(component, event, helper) {
        var initPromises = new Array();
        initPromises.push(helper.createPromise(component, component.get("c.createNewCreditApp")));
        initPromises.push(helper.createPromise(component, component.get("c.getSuffixValues")));
        initPromises.push(helper.createPromise(component, component.get("c.getStateValues")));
        initPromises.push(helper.createPromise(component, component.get("c.getHousingTypeValues")));
        initPromises.push(helper.createPromise(component, component.get("c.getStreetTypeValues")));

        Promise.all(initPromises).then(
            $A.getCallback(function(response) {
                component.set("v.creditApplication", response[0]);
                component.set("v.suffixOptions", response[1]);
                component.set("v.stateOptions", response[2]);
                component.set("v.housingTypeOptions", response[3]);
                component.set("v.streetTypeOptions", response[4]);
            })
        )
    },

    navigateToFormSection : function(component, event, helper) {
        var navigatedSection = component.find(event.target.id);

        navigatedSection.getElement().scrollIntoView();

        if (event.target.getAttribute("aria-level") < 6) {
            var scrolledY = window.scrollY;

            if(scrolledY) {
                window.scroll(0, scrolledY - 140);
            }
        }
    },

    validateInputComponentAndForm : function(component, event, helper) {
        var validationMethodsMapping = helper.getValidationMethodsMapping();
        var sourceInputComponent = event.getSource();
        var sourceInputComponentName = sourceInputComponent.get("v.name");

        if (validationMethodsMapping.has(sourceInputComponentName)) {
            var validateSourceInputComponent = validationMethodsMapping.get(sourceInputComponentName);

            validateSourceInputComponent(sourceInputComponent);
        }

        var inputComponents = component.find("credit-app-form").find({instancesOf : "lightning:input"});
        var saveButtonComponent = component.find("save-button");

        for (var inputComponent of inputComponents) {
            if (!inputComponent.get("v.validity").valid) {
                saveButtonComponent.set("v.disabled", true);

                return;
            }
        }

        saveButtonComponent.set("v.disabled", false);
    },
})