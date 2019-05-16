/**
 * Created by admin on 2019-05-01.
 */
({
    showToast : function(msg, title) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode : 'sticky',
            title: title,
            message: msg
        });
        toastEvent.fire();
    },

    initializeComponent : function(component, event,  helper) {
        var action = component.get('c.isCurrentUserAdmin');
        var p = helper.executeAction(component, action);
        p.then(
            $A.getCallback( function(response) {
                component.set('v.isAdmin', response);
                return response;
            })
        ).then(
            $A.getCallback( function() {
                var action = component.get('c.getTokenString');
                return helper.executeAction(component, action);
            })
        ).then(
            $A.getCallback( function(response) {
                debugger;
                component.set('v.token', response);
                return response;
            })
        ).catch(
            $A.getCallback(function (error) {
                alert('Catch - (iDMS_push): ' + error.message);
            })
        );
    },

    executeAction: function(component, action, callback) {
        return new Promise(function(resolve, reject) {
            action.setCallback(this, function(response) {

                var state = response.getState();

                if (state === "SUCCESS") {
                    var retVal=response.getReturnValue();
                    resolve(retVal);
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            reject(Error("Error message: " + errors[0].message));
                        }
                    }
                    else {
                        reject(Error("Unknown error"));
                    }
                }
            });
            $A.enqueueAction(action);
        });
    },

    sendToIDMS : function(component, event, helper) {

        var action = component.get('c.sendToIDMS');
        action.setParams(
            {
                securityToken : component.get('v.token'),
                dealId : component.get('v.iDMS_dealId'),
                StockNo : component.get('v.iDMS_StockNo')
            });
        var p = helper.executeAction(component, action);
        p.then(
            $A.getCallback( function(response) {
                helper.hideSpinner(component, event);
                helper.showToast(response, 'IDMS Send' );
            })
        ).catch(
            $A.getCallback(function (error) {
                helper.hideSpinner(component, event);
                alert('Catch - (iDMS_push): ' + error.message);
            })
        )
    },

    showSpinner : function(component) {
        debugger;

        /*(var popovers = component.find("box-container").find({instancesOf : "c:popover"});
        for (var i = 0; i < popovers.length; i++) {
            popovers[i].set("v.isVisible", false);
        }*/

        var actionSpinner = component.find("action-spinner");
        actionSpinner.set("v.isTrue", true);
    },

    hideSpinner : function(component) {
        var actionSpinner = component.find("action-spinner");
        actionSpinner.set("v.isTrue", false);
    }

});