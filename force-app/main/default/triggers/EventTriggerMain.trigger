/*
 *  TriggerName  :EventTriggerMain
 *  CreatedOn    : 18/Oct/2016
 *  ModifiedOn   : 18/Oct/2016
 *  CreatedBy    : Jenish Shingala
 *  ModifiedBy   : Jenish Shingala
 *  Description  : Main Trigger on Event object. 
 */
trigger EventTriggerMain on Event (before insert, after insert, before update, after update , before delete , after delete) {
    EventHandler objEventHandler = new EventHandler();
    
    //After Insert Event.
    if(Trigger.isInsert && Trigger.isAfter){
        objEventHandler.onAfterInsert(Trigger.New);
    }
    
    //After Update Event.
    
    if(Trigger.isUpdate && Trigger.isAfter){
        objEventHandler.onAfterUpdate(Trigger.New);
    } 
    
     //handles before insert
    if(trigger.isbefore && trigger.isInsert)
    {
       objEventHandler.onBeforeInsert(Trigger.New);
    }
    
    //handles before update
    if(trigger.isbefore && trigger.isUpdate)
    {
       objEventHandler.onBeforeUpdate(Trigger.oldmap,Trigger.New);
    }
    
    //handles before delete
    if(trigger.isbefore && trigger.isDelete)
    {
         objEventHandler.onBeforeDelete(trigger.oldMap);
    }
    //handles after delete
    if(trigger.isAfter && trigger.isDelete)
    {
          objEventHandler.onAfterDelete(trigger.oldMap);
    }
    
    
}