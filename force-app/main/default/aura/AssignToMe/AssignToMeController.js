({
	doInit : function(component, event, helper) {

        console.log('recordId>>>'+component.get("v.recordId"));
        // Prepare the action to load case record
        var action = component.get("c.getCase");
        action.setParams({"caseId": component.get("v.recordId")});

        // Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                 // Prepare a toast UI message
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "type": "success",
                        "message": "Case is Assigned to Me."
                    });

                    // Update the UI: close panel, show toast, refresh case page
                    $A.get("e.force:closeQuickAction").fire();
                    resultsToast.fire();
                    $A.get("e.force:refreshView").fire();
                component.set("v.case", response.getReturnValue());
            } else {
                var errorMsg = response.getError()[0];
                console.log('Problem getting Case, response state: ' + state+'....'+errorMsg);
            }
        });
        $A.enqueueAction(action);
    }
})