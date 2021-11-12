({
    
    yesResponse : function(component, event, helper) {
        var capitalRequestRecordstatus= component.get("v.CapitalRequestRecord.Status__c");
        if(capitalRequestRecordstatus == "Closure Approval" || capitalRequestRecordstatus == "Closure in Process"){
        component.set("v.CapitalRequestRecord.Status__c", "Closure Approval");
       component.find("cfrRec").saveRecord($A.getCallback(function(saveResult) {
        if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
            alert("CFR submitted for closure Documents successfully.");
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
            component.set("v.recordSaveError",'Unknown problem, state: ' + saveResult.state + ', error: ' + 
              JSON.stringify(saveResult.error));
             alert('Unknown problem, state: ' + saveResult.state + ', error: ' + 
              JSON.stringify(saveResult.error));
        }
    }));
            
        }else{
             component.set("v.recordSaveError", 'For the Closure Approval of CFR, it should be Closure in Process');
            alert("For the Closure Approval of CFR, it should be Closure Approval or Closure in Process.");
        }

    $A.get("e.force:closeQuickAction").fire();  
    },
    
    noResponse : function(component, event, helper) {
        
        
        $A.get("e.force:closeQuickAction").fire();
    }
})