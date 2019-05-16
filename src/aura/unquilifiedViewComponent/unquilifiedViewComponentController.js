({
    init : function (component, event, helper) {

        var currentLimit = component.get('v.currentLimit');
        helper.updateForm(component, 0, currentLimit, false);
    },

    updateForm : function (component, event, helper) {
        var currentLimit = component.get('v.currentLimit');
        helper.updateForm(component, 0, currentLimit, false);
    },

    nextList : function (component, event, helper) {
        var endLine = parseInt(component.get("v.endLineNumber"));
        var startLine = parseInt(component.get("v.startLineNumber"));
        var totalRecords = parseInt(component.get("v.totalDatabaseRecordCount"));
        var currentLimit = parseInt(component.get('v.currentLimit'));
        var quantityOnPage = parseInt(component.get("v.quantityOnPage"));

        if (endLine >= component.get("v.unqualifiedRecords").length && endLine < totalRecords) {
            helper.updateForm(component, currentLimit, 100, true);
            component.set('v.currentLimit', currentLimit + 100);
        }

        component.set("v.startLineNumber", startLine + quantityOnPage);
        component.set("v.endLineNumber", component.get("v.startLineNumber") + quantityOnPage);

        if (component.get("v.endLineNumber") >= totalRecords) {
            component.find("next-button").set("v.disabled", true);
        }

        if (component.get("v.startLineNumber") - quantityOnPage >= 0) {
            component.find("previous-button").set("v.disabled", false);
        }
    },

    previousList : function (component, event, helper) {
        component.set("v.endLineNumber", component.get("v.startLineNumber"));
        component.set("v.startLineNumber", component.get("v.startLineNumber") - component.get("v.quantityOnPage"));

        if (parseInt(component.get("v.startLineNumber")) + parseInt(component.get("v.quantityOnPage")) <= parseInt(component.get("v.totalDatabaseRecordCount"))) {
            component.find("next-button").set("v.disabled", false);
        }

        if (component.get("v.startLineNumber") == 0) {
            component.find("previous-button").set("v.disabled", true);
        }
    },

    quantityChange : function (component, event, helper) {
        component.set("v.startLineNumber", 0);
        component.set("v.endLineNumber", parseInt(component.get("v.quantityOnPage")));

        var previousButton = component.find("previous-button");

        if (previousButton) {
            previousButton.set("v.disabled", true);
        }

        if (component.get("v.startLineNumber") + component.get("v.quantityOnPage") <= component.get("v.totalDatabaseRecordCount")) {
            var nextButton = component.find("next-button");

            if (nextButton) {
                nextButton .set("v.disabled", false);
            }
        }
    },
});