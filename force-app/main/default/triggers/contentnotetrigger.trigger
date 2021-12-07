/*
    *  TriggerName  : contentnotetrigger
    *  CreatedOn    : 11th Jan,2018
    *  CreatedBy    : Jenish Shingala
    *  ModifiedBy   : Capgemini, David Berman, 1-Dec-2021
    *  Description  : Trigger on ContentDocumentLinkr.
*/
trigger contentnotetrigger on ContentDocumentLink(after insert) 
{
    
    switch on Trigger.operationType
    {
        when AFTER_INSERT
        {
            ContentNoteHandler objNoteHandler = new ContentNoteHandler();
            objNoteHandler.onAfterInsert(Trigger.New);
        }
    }
    
    
}