/*
*    - For an Approval Process step, Identify duplicate approvers and accordingly set unique approvers 
*    - If all approvers are found to be duplicate, then auto-approve the record
*/

trigger HRCCFR_Capital_Request_Trigger on Capital_Requests__c (after update, before update,after insert) {
    
    HRCCFR_CapitalRequest_Handler handler = new HRCCFR_CapitalRequest_Handler(Trigger.isExecuting, Trigger.size);
   
/**
* Handle all bussiness logic for After Insert
*/  
    if(trigger.isInsert && trigger.isAfter){
      handler.onAfterInsert(Trigger.new);
    }   
    
/**
* Handle all bussiness logic for Before Update
*/  
    if(trigger.isBefore && trigger.isUpdate ){   
      handler.onBeforeUpdate(Trigger.new,Trigger.oldMap);              
    }
    
/**
* Handle all bussiness logic for After Update
*/    
    if(Trigger.isAfter  && Trigger.isUpdate ){
      system.debug('after update@@@');
      if(HRCCFR_CapitalRequest_Handler.isRun)
      handler.AutoApproveWhenAllDuplicate(Trigger.new, Trigger.oldMap);  
      //Code from HRCCFRSendEmailRemainderHelper.
      HRCCFRApprovalReminderEmails.sendRemainderEmails(Trigger.new);
    }    

   
   
 
}