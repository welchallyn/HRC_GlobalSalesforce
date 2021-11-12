({
	doInit : function(component, event, helper) {
        var accId = component.get("v.pageReference.state.c__accountId");
		var action = component.get("c.doCallout");
        action.setParams({ accountId : accId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('response.getReturnValue() '+JSON.stringify(response.getReturnValue()));
            var workspaceAPI = component.find("workspace");
            workspaceAPI.getFocusedTabInfo().then(function(response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({tabId: focusedTabId});
            })
            .catch(function(error) {
                console.log(error);
            });
            var navLink = component.find("navLink");
            var pageRef = {
                type: 'standard__recordPage',
                attributes: {
                    actionName: 'view',
                    objectApiName: 'Account',
                    recordId : accId 
                },
            };
            navLink.navigate(pageRef);
            if(response.getReturnValue() == 'success'){
                window.setTimeout( $A.getCallback(function() { 
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Sharepoint folder created successfully.",
                        "mode" : "sticky",
                        "type" : "success"
                    }); 
                    toastEvent.fire();
                }), 1000 );
                helper.reload(component, event, helper);
            }
            else if(response.getReturnValue() == 'Sharepoint link already exist'){
                window.setTimeout( $A.getCallback(function() { 
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "message": "Sharepoint link already exist.",
                        "mode" : "sticky",
                        "type" : "error"
                    }); 
                    toastEvent.fire();
                }), 1000 ); 
                helper.reload(component, event, helper);
            }
            else if(response.getReturnValue() == 'error'){
                window.setTimeout( $A.getCallback(function() { 
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "message": "An error occured. Please contact your administrator.",
                        "mode" : "sticky",
                        "type" : "error"
                    }); 
                    toastEvent.fire();
                }), 1000 );
                helper.reload(component, event, helper);
            }
            
        });
    
        $A.enqueueAction(action);
	},
    
})