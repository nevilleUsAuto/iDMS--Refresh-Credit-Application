/**
 * Created by admin on 2019-05-01.
 */

({
    doInit : function(component, event, helper) {

        // var userId = $A.get("$SObjectType.CurrentUser.Id");
        // Console.log(userId);
        helper.initializeComponent(component, event,  helper);

    },

    sendDeal : function(component, event, helper) {
        helper.showSpinner(component, event);

        var validExpense = component.find('idmsdealpushform').reduce(function (validSoFar, inputCmp) {
            // Displays error messages for invalid fields
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        // If we pass error checking, do some real work
        if (validExpense) {
            helper.sendToIDMS(component, event, helper);
        }
    }


});