/*
 *  TriggerName  : TaskTriggerMain
 *  CreatedOn    : 18/Oct/2016
 *  ModifiedOn   : 21/Oct/2016
 *  CreatedBy    : Jenish Shingala
 *  ModifiedBy   : Jenish Shingala
 *  Description  : Main Trigger on Task object. 
 */
trigger TaskTriggerMain on Task (before insert, after insert, before update, after update , before delete , after delete) {
    TaskHandler objTaskHandler = new TaskHandler();
      
    //After Insert Event.
    if(Trigger.isInsert && Trigger.isAfter){
        objTaskHandler.onAfterInsert(Trigger.New);
    }    
    
    //After Update Event.
    
    if(Trigger.isUpdate && Trigger.isAfter){
        objTaskHandler.onAfterUpdate(Trigger.New);
    }
    
     //handles before insert
    if(trigger.isbefore && trigger.isInsert)
    {
       objTaskHandler.onBeforeInsert(Trigger.New);
    }
    
    //handles before update
    if(trigger.isbefore && trigger.isUpdate)
    {
       objTaskHandler.onBeforeUpdate(Trigger.New);
    }
    
    //handles before delete
    if(trigger.isbefore && trigger.isDelete)
    {
         objTaskHandler.onBeforeDelete(trigger.oldMap);
    }
    //handles after delete
    if(trigger.isAfter && trigger.isDelete)
    {
          objTaskHandler.onAfterDelete(trigger.oldMap);
    }
    
    
}