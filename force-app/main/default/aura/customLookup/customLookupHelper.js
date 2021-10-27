({
    searchHelper : function(component,event,getInputkeyWord) {
        // call the apex class method 
        var action = component.get("c.fetchLookUpValues");
        // set param to method  
        var shiptoid="";
        var shiptoobj = component.get("v.SelectedShipto");
            if(shiptoobj){
                shiptoid=shiptoobj['Id'];
            }
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName' : component.get("v.objectAPIName"),
            'filterCondition' : component.get("v.filterCondition"),
            'selectedShiptoId' : shiptoid
        });
        // set a callBack    
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
            }
            
        });
        // enqueue the Action  
        $A.enqueueAction(action);
        
    },
    valueSelected : function (component, event)
    {
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show');
        this.fireSelectionEvent(component, event);
    },
    
    fireSelectionEvent : function(component, event)
    {
       var isOnloadevt=component.get("v.onloadvar");
       var selectionEvent = component.getEvent("selectionChange");
       if(isOnloadevt === true){
        component.set("v.onloadvar", false);
        }
        selectionEvent.setParams
        ({
            "label" : component.get("v.label"),
            "selectedRecord" : component.get("v.selectedRecord"),
            "uniqueId" : component.get("v.uniqueId"),
            "Index":component.get("v.index"),
            "AssociatedRec":component.get("v.orderLineItem"),
            "OnLoadEvt" : isOnloadevt
        });
        selectionEvent.fire();
    }
        
})