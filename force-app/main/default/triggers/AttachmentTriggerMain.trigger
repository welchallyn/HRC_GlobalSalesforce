/*
    *  triggerName  : AttachmentTriggerMain
    *  CreatedOn    : 24/Oct/2016
    *  ModifiedOn   : 24/Oct/2016
    *  CreatedBy    : Jenish Shingala
    *  ModifiedBy   : Jenish Shingala
    *  Description  : Used for Handling all events for Attachment (Attachment). 
*/
trigger AttachmentTriggerMain on Attachment (after delete, after insert, after update, before delete, before insert) {
    AttachmentHandler objAttachmentHandler = new AttachmentHandler();
    
    //After Insert Event.
    if(Trigger.isInsert && Trigger.isAfter){
        objAttachmentHandler.onAfterInsert(Trigger.New);
    }
    
    //After Update Event.
    
    if(Trigger.isUpdate && Trigger.isAfter){
        objAttachmentHandler.onAfterUpdate(Trigger.New);
    }
    
     //handles before insert
    if(trigger.isbefore && trigger.isInsert)
    {
       objAttachmentHandler.onBeforeInsert(Trigger.New);
    }
    
    //handles before update
    if(trigger.isbefore && trigger.isUpdate)
    {
       objAttachmentHandler.onBeforeUpdate(Trigger.oldmap,Trigger.New);
    }
    
    //handles before delete
    if(trigger.isbefore && trigger.isDelete)
    {
         objAttachmentHandler.onBeforeDelete(trigger.oldMap);
    }
    //handles after delete
    if(trigger.isAfter && trigger.isDelete)
    { 
          objAttachmentHandler.onAfterDelete(trigger.oldMap);
    }
}