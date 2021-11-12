trigger AccountTriggerMain on Account (before insert, after insert, before update, after update , before delete , after delete) {
    
    //Trigger Handler
    AccountHandler objHandler = new AccountHandler();
    
    //handles before insert
    if(trigger.isbefore && trigger.isInsert)
    {
        objHandler.onBeforeInsert(trigger.new);
    }
    //handles after insert
    if(trigger.isafter && trigger.isInsert)
    {
        //get list of new context
        objHandler.onAfterInsert(trigger.new);
    }
    //handles before update
    if(trigger.isbefore && trigger.isUpdate)
    {
        //list of new
        objHandler.onBeforeUpdate(trigger.new);
    }
    //handles after update 
    if(trigger.isafter && trigger.isUpdate)
    {
        
    }
    //handles before delete
    if(trigger.isbefore && trigger.isDelete)
    {
         objHandler.onBeforeDelete(trigger.old);
    }
    //handles after delete
    if(trigger.isAfter && trigger.isDelete)
    {
     	objHandler.onAfterDelete(trigger.old);
  
    }
}