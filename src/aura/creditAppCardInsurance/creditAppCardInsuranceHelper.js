/**
 * Created by admin on 4/27/18.
 */
({
    sendTextAndEmail : function(cmp, response) {
        debugger;
        if (response.indexOf('Error:') === -1) {

            var action = cmp.get("c.sendMSM");
            action.setParams({frResponse: response});
            action.setCallback(this, function (response) {

                debugger;

                cmp.set('v.showProcessed', true); // regardless on state

                var state = response.getState();
                if (state === "SUCCESS") {
                    //alert("From server -- TEST MODE ONLY: " + response.getReturnValue());
                    //Console.log('Insurance Process completed successfully.')
                }
                else if (state === "INCOMPLETE") {
                    cmp.set('v.processed', 'Process incomplete.');
                    alert('Process incomplete; please retry.  Thank you.')
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                errors[0].message);
                            cmp.set('v.processed', errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                        cmp.set('v.processed', 'Unknown Error!');
                    }

                    alert("Error Message: " + errors[0].message);
                }
            });
            $A.enqueueAction(action);
        }
    }
})