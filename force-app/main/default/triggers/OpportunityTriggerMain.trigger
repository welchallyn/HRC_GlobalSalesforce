/*
 *  TriggerName  : OpportunityTriggerMain
 *  CreatedOn    : 11/Nov/2016
 *  ModifiedOn   : 17/Nov/2016
 *  CreatedBy    : Jenish Shingala
 *  ModifiedBy   : Jenish Shingala
 *  Description  : Used for Handling all events for Opportunities (Opportunity). 
 */
trigger OpportunityTriggerMain on Opportunity (before insert, after insert, before update, after update , before delete , after delete) {
    
    //Trigger Handler.
    OpportunityHandler objHandler = new OpportunityHandler();
    
    //handles before insert 
    if(trigger.isbefore && trigger.isInsert)
    {
        
        objHandler.onBeforeInsert(trigger.new,trigger.oldMap,trigger.isUpdate);
        
    }
    //handles after insert
    if(trigger.isafter && trigger.isInsert)
    {
        //get list of new context
        objHandler.onAfterInsert(trigger.new,trigger.newMap, trigger.isUpdate);
    }
    //handles before update
    if(trigger.isbefore && trigger.isUpdate)
    {
        objHandler.onBeforeUpdate(trigger.new,trigger.oldMap, trigger.isUpdate);
    }
    //handles after update 
    if(trigger.isafter && trigger.isUpdate)
    {
         objHandler.onAfterUpdate(trigger.new,trigger.oldmap,trigger.newmap,trigger.isUpdate);
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