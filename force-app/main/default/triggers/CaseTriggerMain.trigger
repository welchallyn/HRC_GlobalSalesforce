trigger CaseTriggerMain on Case (before insert, after insert, before update, after update , before delete , after delete) {
    //Trigger Handler
    CaseHandler objHandler = new CaseHandler();
    
    //handles before insert
    if(trigger.isbefore && trigger.isInsert)
    {
        
    }
    //handles after insert
    if(trigger.isafter && trigger.isInsert)
    {
        if(CaseHandler.isTriggerRun)
            
            objHandler.onAfterInsert(trigger.new);
    }
    //handles before update
    if(trigger.isbefore && trigger.isUpdate) 
    {
        
    }
    //handles after update 
   if(trigger.isafter && trigger.isUpdate)
    {   if(CaseHandler.isTriggerRun)
            objHandler.onAfterUpdate(trigger.new, trigger.oldmap);
    }
    //handles before delete
    /* if(trigger.isbefore && trigger.isDelete)
    {
        
    }
    //handles after delete
    if(trigger.isAfter && trigger.isDelete)
    {
        
    } */
}