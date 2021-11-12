({
    init : function (component) {
        // Find the component whose aura:id is "flowData"
        var flow = component.find("flowData");
        // In that component, start your flow. Reference the flow's API Name.
        flow.startFlow("Shift_Manager");
    },
    handleStatusChange : function (component, event) {
        if(event.getParam("status") === "FINISHED") {
            var action = component.get("c.navHome");
        	$A.enqueueAction(action);
        }
    },
    navHome : function (component, event, helper) {
        var homeEvent = $A.get("e.force:navigateToObjectHome");
        homeEvent.setParams({
            "scope": "Shift"
        });
        homeEvent.fire();
        $A.get("e.force:closeQuickAction").fire();  
      
    }

})