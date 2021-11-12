({
    
    yesResponse : function(component, event, helper) {
        var capitalRequestRecordstatus= component.get("v.CapitalRequestRecord.Status__c");
        if(capitalRequestRecordstatus == "Spend in Progress" || capitalRequestRecordstatus == "Closure in Process"){
        component.set("v.CapitalRequestRecord.Status__c", "Closure in Process");
       component.find("cfrRec").saveRecord($A.getCallback(function(saveResult) {
        if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
            alert("CFR is submitted for Closure.");
        } else if (saveResult.state === "INCOMPLETE") {
            component.set("v.recordSaveError","User is offline, device doesn't support drafts.");
        } else if (saveResult.state === "ERROR") { 
            var errMsg = "";
            // saveResult.error is an array of errors, 
            // so collect all errors into one message
            for (var i = 0; i < saveResult.error.length; i++) {
                errMsg += saveResult.error[i].message + "\n";
            }
            component.set("v.recordSaveError", errMsg);

        } else {
            alert('Unknown problem, state: ' + saveResult.state + ', error: ' + 
              JSON.stringify(saveResult.error));
            component.set("v.recordSaveError",'Unknown problem, state: ' + saveResult.state + ', error: ' + 
              JSON.stringify(saveResult.error));
        }
    }));
            
        }else{
             alert("CFR is not moved to Closure in Process. Please contact administrator.");
             component.set("v.recordSaveError", 'CFR is not moved to Closure in Process. Please contact administrator.');
        }

    $A.get("e.force:closeQuickAction").fire();  
    },
    
    noResponse : function(component, event, helper) {
        
        
        $A.get("e.force:closeQuickAction").fire();
    }
})