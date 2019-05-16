/**
 * Created by admin on 4/27/18.
 */
({
    handleClick : function(cmp, event, helper) {
        var caId = cmp.get('v.recordId'); // picks up the record id from the url
        var vin = cmp.get('v.vin');

        var action = cmp.get("c.makeCallout");
        action.setParams({ isTesting : false, caId : caId, vin : vin });

        action.setCallback(this, function(response) {
            cmp.set('v.showProcessed', true);

            var state = response.getState();
            if (state === "SUCCESS") {
                // cannot make DML and CallOut in the same transaction.
                //alert("From server -- TEST MODE ONLY: " + response.getReturnValue());
                helper.sendTextAndEmail(cmp, response.getReturnValue());

            }
            else if (state === "INCOMPLETE") {
                // do something
                //alert("incomplete");
                cmp.set( 'v.processed','Process incomplete.');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                        cmp.set( 'v.processed',errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                    cmp.set( 'v.processed','Unknown Error!');
                }

                alert("Error Message: " + errors[0].message);
            }
        });

        // optionally set storable, abortable, background flag here

        // A client-side action could cause multiple events,
        // which could trigger other events and
        // other server-side action calls.
        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action);

    }
})