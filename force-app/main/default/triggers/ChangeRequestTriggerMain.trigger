trigger ChangeRequestTriggerMain on BMCServiceDesk__Change_Request__c (before insert, after insert, before update, after update , before delete , after delete) {
    
    //Trigger Handler
    ChangeRequestHandler objHandler = new ChangeRequestHandler();
    
    //handles before insert
    if(trigger.isbefore && trigger.isInsert)
    {
        objHandler.onBeforeInsert(trigger.new,trigger.oldmap,trigger.newmap,false);
    }
    //handles after insert
    if(trigger.isafter && trigger.isInsert)
    {
       
    }
    //handles before update
    if(trigger.isbefore && trigger.isUpdate)
    {
        //list of new
        objHandler.onBeforeUpdate(trigger.new,trigger.oldmap,trigger.newmap,true);
    }
    //handles after update 
    if(trigger.isafter && trigger.isUpdate)
    {
        
    }
    //handles before delete
    if(trigger.isbefore && trigger.isDelete)
    {
        
    }
    //handles after delete
    if(trigger.isAfter && trigger.isDelete)
    {
        
    }
}