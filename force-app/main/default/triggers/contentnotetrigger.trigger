/*
    *  TriggerName  : contentnotetrigger
    *  CreatedOn    : 11th Jan,2018
    *  CreatedBy    : Jenish Shingala
    *  ModifiedBy   : Jenish Shingala
    *  Description  : Trigger on ContentDocumentLinkr.
*/
trigger contentnotetrigger on ContentDocumentLink(after insert,after delete) {
    ContentNoteHandler objNoteHandler = new ContentNoteHandler();
     //After Insert Event.
    if(Trigger.isInsert && Trigger.isAfter){
        objNoteHandler.onAfterInsert(Trigger.New);
        ContentDocumentLinkTriggerHandler.updateHasContactCheckboxInsert(Trigger.New);
    }
    
}