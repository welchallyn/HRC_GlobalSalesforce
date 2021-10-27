({
    onLoad : function(component,event,helper){
        console.log('custom lookup js');
        if (component.get("v.selectedRecordID") != null && component.get("v.selectedRecordID") != '')
        {
            var action = component.get("c.getRecordById");
            action.setParams
            ({
                "Id" :  component.get("v.selectedRecordID")
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") 
                { 
                    var result = response.getReturnValue();
                    component.set("v.selectedRecord", result);
                    if(component.get("v.index") != null && component.get("v.objectAPIName") == 'contact')
                    {
                        var orderLineItem = component.get("v.orderLineItem");
                        orderLineItem.HRCSVC_Contact_Name__c = result.Id;
                        component.set("v.orderLineItem" , orderLineItem); 
                    }
                    component.set("v.onloadvar", true);
                    helper.valueSelected(component, event);
                    component.set("v.onloadvar", false);
                }
            });
            $A.enqueueAction(action);
            
        }
         
        /*
        if(component.get("v.index") != 0 && component.get("v.objectAPIName") == 'contact'){
            if(component.get("v.baseContact") != null){
                var baseContact = component.get("v.baseContact");
                var selectedRecord = component.get("v.selectedRecord");
                selectedRecord.Name = baseContact.Name;
                selectedRecord.Id = baseContact.Id;
                //component.set("v.selectedRecord",selectedRecord);
            }
        }
        if(component.get("v.selectedRecordName") != "#ABC"){
            var selectedRecord = component.get("v.selectedRecord");
            selectedRecord.Name = component.get("v.selectedRecordName");
            selectedRecord.Id = component.get("v.selectedRecordID");
        }
        */
    },
    onfocus : function(component,event,helper){
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC  
        var getInputkeyWord = '';
        helper.searchHelper(component,event,getInputkeyWord);
    },
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    keyPressController : function(component, event, helper) {
        // get the search Input keyword   
        var getInputkeyWord = component.get("v.SearchKeyWord");
        // check if getInputKeyWord size id more then 0 then open the lookup result List and 
        // call the helper 
        // else close the lookup result List part.   
        if( getInputkeyWord.length > 0 ){
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{  
            component.set("v.listOfSearchRecords", null ); 
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },
    
    // function for clear the Record Selaction 
    clear :function(component,event,helper)
    {
       // alert('clear method called');
        if (component.get("v.disableLookup") == false)
        {
            var pillTarget = component.find("lookup-pill");
            var lookUpTarget = component.find("lookupField"); 
            
            $A.util.addClass(pillTarget, 'slds-hide');
            $A.util.removeClass(pillTarget, 'slds-show');
            
            $A.util.addClass(lookUpTarget, 'slds-show');
            $A.util.removeClass(lookUpTarget, 'slds-hide');
            
            component.set("v.SearchKeyWord",null);
            component.set("v.listOfSearchRecords", null );
            component.set("v.selectedRecord", null);
            helper.fireSelectionEvent(component, event);
        }
        
        	
    },
    
    // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
        debugger;
        // get the selected Account record from the COMPONENT event 	 
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        var objectAPIName = component.get("v.objectAPIName");
        component.set("v.selectedRecord" , selectedAccountGetFromEvent);
        if(component.get("v.index") != null && objectAPIName == 'contact'){
            var orderLineItem = component.get("v.orderLineItem");
            orderLineItem.HRCSVC_Contact_Name__c = selectedAccountGetFromEvent.Id;
            //component.set("v.orderLineItem" , orderLineItem); 
        }
        if(component.get("v.index") != null && objectAPIName == 'product2'){
            var orderLineItem = component.get("v.orderLineItem");
            orderLineItem.Product__c = selectedAccountGetFromEvent.Id;
            component.set("v.orderLineItem" , orderLineItem); 
        }
        if(component.get("v.index") != null && objectAPIName == 'HRCFSL_Ward__c'){
            var orderLineItem = component.get("v.orderLineItem");
            orderLineItem.HRCSVC_Ward__c = selectedAccountGetFromEvent.Id;
            component.set("v.orderLineItem" , orderLineItem); 
        }
        if(component.get("v.index") != null && objectAPIName == 'user'){
            var orderLineItem = component.get("v.orderLineItem");
            orderLineItem.HRCSVC_Cancelation_Approver__c = selectedAccountGetFromEvent.Id;
            component.set("v.orderLineItem" , orderLineItem); 
        }
        
        helper.valueSelected(component, event);

    },
})