trigger HRCCFRSendEmailRemainderHelper on Capital_Requests__c (before insert,before update,after update) {
       
    if(Trigger.isBefore && Trigger.isUpdate){
        Map<Id, Capital_Requests__c> rejectedStatements = new Map<Id, Capital_Requests__c>{};
            for(Capital_Requests__c cr: trigger.new){
                Capital_Requests__c oldcr = System.Trigger.oldMap.get(cr.Id);
                if (oldcr.Rejection_Comments_Required__c != 'Rejected' && cr.Rejection_Comments_Required__c == 'Rejected'){ 
                  rejectedStatements.put(cr.Id, cr);  
                }
            }
           
            if (!rejectedStatements.isEmpty()){
                List<Id> processInstanceIds = new List<Id>{};
                for (Capital_Requests__c crs : [SELECT (SELECT ID FROM ProcessInstances ORDER BY CreatedDate DESC LIMIT 1) FROM Capital_Requests__c WHERE ID IN :rejectedStatements.keySet()]){
                    processInstanceIds.add(crs.ProcessInstances[0].Id);
                }
                for (ProcessInstance pi : [SELECT TargetObjectId,(SELECT Id, Actor.email, Actor.Name, Actor.Id, ActorId FROM WorkItems),(SELECT Id, StepStatus, Comments FROM Steps ORDER BY CreatedDate DESC LIMIT 1 ) FROM ProcessInstance WHERE Id IN :processInstanceIds ORDER BY CreatedDate DESC]){                   
                    System.debug('**steps'+pi.Steps[0]);
                    if ((pi.Steps[0].Comments == null || 
                        pi.Steps[0].Comments.trim().length() == 0)){
                           system.debug('pi id'+pi.id+'******04iM0000000TZsw'+'**********'+pi.WorkItems[0].id);
                        //CapitalRequestCtrl.setRedirectToOtherPage(rejectedStatements.get(pi.TargetObjectId).id);
                        rejectedStatements.get(pi.TargetObjectId).addError('<br/><br/>Reject Operation Cancelled: Please provide a <b>Rejection Comments</b> !'+'<br/>'+'Please click '+'<a href='+'https://hill-rom--hrsdev.cs7.my.salesforce.com/p/process/ProcessInstanceWorkitemWizardStageManager?id='+pi.WorkItems[0].id+'>'+'<b>here</b>'+'</a>'+' to redirect to previous page');
                      
                      
                    }
                }  
          }
    }
    if(Trigger.isAfter && Trigger.isUpdate){
        // Method call for sending approver remainder emails.
        HRCCFRApprovalReminderEmails.sendRemainderEmails(Trigger.new);
    }
}