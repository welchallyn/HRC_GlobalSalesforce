({
	doInit : function(component, event, helper) {
        var status;
        var changeType;
        var changeId;
        var submittedForApproval;
        var rejected = false; 
       
        var action = component.get("c.getChangeRequest");
        action.setParams({"crId": component.get("v.recordId")});
       // Configure response handler
        action.setCallback(this, function(response) {
             window.setTimeout(
            $A.getCallback(function() {
                $A.get("e.force:closeQuickAction").fire();
            }), 1000 
        );
            
            var state = response.getState();
            console.log('-------',state);
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.changerequest", response.getReturnValue());
                status = component.get("v.changerequest.BMCServiceDesk__Status__c");  
                changeId = component.get("v.recordId");
                submittedForApproval = component.get("v.changerequest.Submitted_for_Approval__c"); 
                changeType = component.get("v.changerequest.BMCServiceDesk__Change_Type__c");
                console.log(component.get("v.changerequest"));
                if(changeType === "Normal"){
                    if(status == "INITIATE" && submittedForApproval == false) {
                        var approverSelection = window.confirm("Please select appropriate Ad-Hoc Approvers \n If you want to continue press Ok or if you want to change approvers, press Cancel"); 
                        if(approverSelection == true){ 
                            var answer = window.confirm("This will now be moved to the PLAN & SCHEDULE state. Do you want to continue?"); 
                            if(answer == true) 
                                window.open('/apex/NextStage?redirectId=default&changeType=' + changeType + '&status=' + status + '&changeId=' + changeId, '_self'); 
                        }
                    }
                    else if(status == "PLAN+SCHEDULE") { 
                        rejected = component.get("v.changerequest.Plan_Rejected__c");
                        if(rejected == true) 
                        alert("Please make necessary changes and re-submit for approval at " + status + " stage"); 
                        else{ 
                        if(submittedForApproval == true) 
                        alert("This record is already submitted for Approval"); 
                        else{ 
                        var approverSelection = window.confirm("Please select appropriate Ad-Hoc Approvers \n If you want to continue press Ok or if you want to change approvers, press Cancel"); 
                        if(approverSelection == true){ 
                        var answer = window.confirm("Do you want to move to next stage?"); 
                        if(answer == true) 
                        window.open('/apex/NextStage?redirectId=default&changeType=' + changeType + '&status=' + status + '&changeId=' + changeId, '_self'); 
                        } 
                        } 
                        } 
                        rejected = false; 
                        } 
                    else if(status == "IMPLEMENT") { 
                        rejected = component.get("v.changerequest.Implement_Rejected__c"); 
                        if(rejected == true) 
                        alert("Please make necessary changes and re-submit for approval at " + status + " stage"); 
                        else{ 
                        if(submittedForApproval == true) 
                        alert("This record is already submitted for Approval"); 
                        else{ 
                        var answer = window.confirm("Do you want to move to next stage?"); 
                        if(answer == true) 
                        window.open('/apex/NextStage?redirectId=default&changeType=' + changeType + '&status=' + status + '&changeId=' + changeId, '_self'); 
                        
                        } 
                        } 
                        rejected = false; 
                        }
                    else if(status === "COMPLETED") 
						alert("There are no further stages"); 
                }
                else if(changeType === "Emergency" || changeType === "Standard"){ 
                    
                    if(status == "INITIATE" && submittedForApproval == false) { 
                        var approverSelection = window.confirm("Please select appropriate Ad-Hoc Approvers \n If you want to continue press Ok or if you want to change approvers, press Cancel"); 
                        if(approverSelection == true){ 
                            var answer = window.confirm("Do you want to move to next stage?"); 
                            if(answer == true) 
                                window.open('/apex/NextStage?redirectId=default&changeType=' + changeType + '&status=' + status + '&changeId=' + changeId, '_self'); 
                        } 
                    } 
                    
                    else if(status == "REVIEW+AUTHORIZATION") { 
                        rejected = component.get("v.changerequest.Review_Rejected__c");
                        
                        if(rejected == true) 
                            alert("Please make necessary changes and re-submit for approval at " + status + " stage"); 
                        else{ 
                            if(submittedForApproval == true) 
                                alert("This record is already submitted for Approval"); 
                            else{ 
                                var approverSelection = window.confirm("Please select appropriate Ad-Hoc Approvers \n If you want to continue press Ok or if you want to change approvers, press Cancel"); 
                                if(approverSelection == true){ 
                                    var answer = window.confirm("Do you want to move to next stage?"); 
                                    if(answer == true) 
                                        window.open('/apex/NextStage?redirectId=default&changeType=' + changeType + '&status=' + status + '&changeId=' + changeId, '_self'); 
                                } 
                            } 
                        } 
                        rejected = false; 
                    } 
                    
                        else if(status == "PLAN+SCHEDULE") { 
                            rejected = component.get("v.changerequest.Plan_Rejected__c"); 
                            
                            if(rejected == true) 
                                alert("Please make necessary changes and re-submit for approval at " + status + " stage"); 
                            else{ 
                                if(submittedForApproval == true) 
                                    alert("This record is already submitted for Approval"); 
                                else{ 
                                    var approverSelection = window.confirm("Please select appropriate Ad-Hoc Approvers \n If you want to continue press Ok or if you want to change approvers, press Cancel"); 
                                    if(approverSelection == true){ 
                                        var answer = window.confirm("Do you want to move to next stage?"); 
                                        if(answer == true) 
                                            window.open('/apex/NextStage?redirectId=default&changeType=' + changeType + '&status=' + status + '&changeId=' + changeId, '_self'); 
                                    } 
                                } 
                            } 
                            rejected = false; 
                        } 
                    
                            else if(status === "IMPLEMENT") { 
                                rejected = component.get("v.changerequest.Implement_Rejected__c"); 
                                
                                if(rejected == true) 
                                    alert("Please make necessary changes and re-submit for approval at " + status + " stage"); 
                                else{ 
                                    if(submittedForApproval == true) 
                                        alert("This record is already submitted for Approval"); 
                                    else{ 
                                        var answer = window.confirm("Do you want to move to next stage?"); 
                                        if(answer == true) 
                                            window.open('/apex/NextStage?redirectId=default&changeType=' + changeType + '&status=' + status + '&changeId=' + changeId, '_self'); 
                                    } 
                                } 
                                rejected = false; 
                            } 
                    
                                else if(status === "COMPLETED" && changeType === "Emergency"){ 
                                    alert("There are no further stages"); 
                                } 
                    
                                    else if(status === "COMPLETED" && changeType === "Standard"){ 
                                        rejected = component.get("v.changerequest.Completed_Rejected__c");
                                        if(rejected == true) 
                                            alert("Please make necessary changes and re-submit for approval at " + status + " stage"); 
                                        else{ 
                                            if(submittedForApproval == true) 
                                                alert("This record is already submitted for Approval"); 
                                            else{ 
                                                var answer = window.confirm("Do you want to move to next stage?"); 
                                                if(answer == true) 
                                                    window.open('/apex/NextStage?redirectId=default&changeType=' + changeType + '&status=' + status + '&changeId=' + changeId, '_self'); 
                                            } 
                                        } 
                                        rejected = false; 
                                    } 
                    
                                        else if(status === "CLOSED" && changeType === "Standard"){ 
                                            alert("There are no further stages"); 
                                        } 
                }
                if(changeType === "Normal with Close Down"){ 
                    if(status == "INITIATE" && submittedForApproval == false) { 
                    var approverSelection = window.confirm("Please select appropriate Ad-Hoc Approvers \n If you want to continue press Ok or if you want to change approvers, press Cancel"); 
                    if(approverSelection == true){ 
                    var answer = window.confirm("This will now be moved to the PLAN & SCHEDULE state. Do you want to continue?"); 
                    if(answer == true) 
                    window.open('/apex/NextStage?redirectId=default&changeType=' + changeType + '&status=' + status + '&changeId=' + changeId, '_self'); 
                    } 
                    } 
                    else if(status == "PLAN+SCHEDULE") { 
                    rejected = component.get("v.changerequest.Plan_Rejected__c");; 
                    if(rejected == true) 
                    alert("Please make necessary changes and re-submit for approval at " + status + " stage"); 
                    else{ 
                    if(submittedForApproval == true) 
                    alert("This record is already submitted for Approval"); 
                    else{ 
                    var approverSelection = window.confirm("Please select appropriate Ad-Hoc Approvers \n If you want to continue press Ok or if you want to change approvers, press Cancel"); 
                    if(approverSelection == true){ 
                    var answer = window.confirm("Do you want to move to next stage?"); 
                    if(answer == true) 
                    window.open('/apex/NextStage?redirectId=default&changeType=' + changeType + '&status=' + status + '&changeId=' + changeId, '_self'); 
                    } 
                    } 
                    } 
                    rejected = false; 
                    } 
                    else if(status == "IMPLEMENT") { 
                    rejected = component.get("v.changerequest.Implement_Rejected__c");
                    if(rejected == true) 
                    alert("Please make necessary changes and re-submit for approval at " + status + " stage"); 
                    else{ 
                    if(submittedForApproval == true) 
                    alert("This record is already submitted for Approval"); 
                    else{ 
                    var answer = window.confirm("Do you want to move to next stage?"); 
                    if(answer == true) 
                    window.open('/apex/NextStage?redirectId=default&changeType=' + changeType + '&status=' + status + '&changeId=' + changeId, '_self'); 
                    
                    } 
                    } 
                    rejected = false; 
                    } 
                    else if(status === "COMPLETED"){ 
                    rejected = component.get("v.changerequest.Completed_Rejected__c");; 
                    if(rejected == true) 
                    alert("Please make necessary changes and re-submit for approval at " + status + " stage"); 
                    else{ 
                    if(submittedForApproval == true) 
                    alert("This record is already submitted for Approval"); 
                    else{ 
                    var answer = window.confirm("Do you want to move to next stage?"); 
                    if(answer == true) 
                    window.open('/apex/NextStage?redirectId=default&changeType=' + changeType + '&status=' + status + '&changeId=' + changeId, '_self'); 
                    } 
                    } 
                    rejected = false; 
                    } 
                    else if(status === "CLOSED"){ 
                    alert("There are no further stages"); 
                    } 
                    }
                
                
                
            } else {
                console.log('Problem getting Case, response state: ' + state);
            }
        });

        $A.enqueueAction(action);
		        
	}
	
	
})