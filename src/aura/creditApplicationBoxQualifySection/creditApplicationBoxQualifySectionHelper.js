({
	executeAction : function (component, action) {
		return new Promise(function(resolve, reject) {
			action.setCallback(this, function(response) {
				if (component.isValid()) {
					if (response.getState() === "SUCCESS") {
						resolve(response.getReturnValue());
					}
					else if (response.getState() === "ERROR") {
						reject(response.getError()[0].message);
					}
					else {
						reject("Unknown error");
					}
				}
			});
			$A.enqueueAction(action);
		});
	},

	redirectToVisualForcePage : function (component, event, pageURL)
	{
		var redirectToVisualForcePageEvent = $A.get("e.force:navigateToURL");

		redirectToVisualForcePageEvent.setParams({
			"url" : pageURL,
			"isredirect" : "true"
		});

		redirectToVisualForcePageEvent.fire();
	}
})