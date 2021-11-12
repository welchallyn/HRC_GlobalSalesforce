trigger OpportunityTrigger on Opportunity (before insert , before update, after update , before delete , after delete) 
{
    //Trigger Handler
    OpportunityHandler1 objHandler = new OpportunityHandler1();
    
    if(trigger.isbefore && trigger.isInsert)
    {
        objHandler.onBeforeInsert(trigger.new);
    }

    if(trigger.isbefore && trigger.isUpdate)
    {
        objHandler.onBeforeUpdate(trigger.oldMap, trigger.new);
    }
        
    if(trigger.isafter && trigger.isUpdate)
    {
        objHandler.onAfterUpdate(trigger.oldMap , trigger.newMap);
    }
    
    if(trigger.isbefore && trigger.isDelete)
    {
        objHandler.onBeforeDelete(trigger.oldMap);
    }
    
    if(trigger.isAfter && trigger.isDelete)
    {
        objHandler.onAfterDelete(trigger.oldMap);
    }
}