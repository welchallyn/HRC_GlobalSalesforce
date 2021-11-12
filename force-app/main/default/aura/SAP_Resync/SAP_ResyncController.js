({
    yesResponse : function(component, event, helper) {
        var status= component.get("v.CapitalRequestRecord.Status__c");
        var projectName= component.get("v.CapitalRequestRecord.Project_Name__c");
        var id = component.get("v.CapitalRequestRecord.Id");
        var sapCFRNumber = component.get("v.CapitalRequestRecord.SAP_CFR_Number__c");
        var companyCode = component.get("v.CapitalRequestRecord.Company_Code__c");
        
        console.log(status,'+',projectName,'+',id,'+',companyCode,'+',sapCFRNumber);
        
        if(status == "Approved" && sapCFRNumber==null && (companyCode=="5000" || companyCode=="5018")){
            var action = component.get("c.apexcallout");
            action.setParams({"status" : status,"projectName" : projectName,"capitalReqId" : id});
            
            action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("From server: " + response.getReturnValue());
                // return doesn't work for async server action call
                //return response.getReturnValue();
                // call the callback passed into aura:method
                if (callback) callback(response.getReturnValue());
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                          errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
            $A.get('e.force:refreshView').fire();
            /*component.find("cfrRec").saveRecord($A.getCallback(function(saveResult) {
                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                    alert("SAP CFR Number generated successfully.");
                     
                } else {
                    component.set("v.recordSaveError",'Unknown problem, state: ' + saveResult.state + ', error: ' + 
                                  JSON.stringify(saveResult.error));
                    alert('Unknown problem, state: ' + saveResult.state + ', error: ' + 
                          JSON.stringify(saveResult.error));
                }
            }));
         $A.enqueueAction(action);   */
        }else if(status != "Approved"){
             component.set("v.recordSaveError", 'In order to resync the SAP CFR Number, the status should be Approved.');
             alert("In order to resync the SAP CFR Number, the status should be Approved.");
        }else if(companyCode!="5000" || companyCode!="5018"){
            component.set("v.recordSaveError", 'In order to resync the SAP CFR Number, the Company Code should be 5000 or 5018.');
            alert("In order to resync the SAP CFR Number, the Company Code should be 5000 or 5018.");
        }else{
            component.set("v.recordSaveError", 'Resync of SAP CFR Number failed,since SAP CFR NUmber is already there.');
            alert("Resync of SAP CFR Number failed,since SAP CFR NUmber is already there.");
        }
	 $A.get("e.force:closeQuickAction").fire();  
        
    },
    
       noResponse : function(component, event, helper) {
       $A.get("e.force:closeQuickAction").fire();
    }
})