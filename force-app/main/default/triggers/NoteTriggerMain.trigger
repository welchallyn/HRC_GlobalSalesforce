/*
    *  triggerName  :NoteTriggerMain
    *  CreatedOn    : 19/Oct/2016
    *  ModifiedOn   : 19/Oct/2016
    *  CreatedBy    : Jenish Shingala
    *  ModifiedBy   : Jenish Shingala
    *  Description  : Used for Handling all events for Notes (Note). 
*/
trigger NoteTriggerMain on Note (before insert, after insert, before update, after update , before delete , after delete) {
    NoteHandler objNoteHandler = new NoteHandler();
    
    //After Insert Event.
    if(Trigger.isInsert && Trigger.isAfter){
        objNoteHandler.onAfterInsert(Trigger.New);
    }
    
    //After Update Event.
    
    if(Trigger.isUpdate && Trigger.isAfter){
        objNoteHandler.onAfterUpdate(Trigger.New);
    }
    
     //handles before insert
    if(trigger.isbefore && trigger.isInsert)
    {
       objNoteHandler.onBeforeInsert(Trigger.New);
    }
    
    //handles before update
    if(trigger.isbefore && trigger.isUpdate)
    {
       objNoteHandler.onBeforeUpdate(Trigger.oldmap,Trigger.New);
    }
    
    //handles before delete
    if(trigger.isbefore && trigger.isDelete)
    {
         objNoteHandler.onBeforeDelete(trigger.oldMap);
    }
    //handles after delete
    if(trigger.isAfter && trigger.isDelete)
    {
          objNoteHandler.onAfterDelete(trigger.oldMap);
    }
    
    
}