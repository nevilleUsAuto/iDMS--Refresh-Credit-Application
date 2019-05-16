({
    navigateToComponentSection : function(component, event, helper) {
        var navigatedSection = component.find(event.target.id);

        navigatedSection.getElement().scrollIntoView();

        if (event.target.getAttribute("aria-level") < 6) {
            var scrolledY = window.scrollY;

            if(scrolledY) {
                window.scroll(0, scrolledY - 140);
            }
        }
    },
})