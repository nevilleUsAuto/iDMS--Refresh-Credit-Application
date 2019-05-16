({
	navigateToComponentSection : function(component, event, helper) {
		event.target.ariaSelected = true;
		console.log(event.target.id);
		component.set("v.tabShown", event.target.id);
	},
})