trigger ContentDocumentTrigger on ContentDocument (before delete,after update) {
    if(Trigger.isDelete && Trigger.isBefore){  
        ContentDocumentLinkTriggerHandler.updateHasContactCheckbox(Trigger.Old);
    }
    if(Trigger.isUpdate && Trigger.isAfter){  
        ContentDocumentLinkTriggerHandler.updateHasContactCheckboxUpdate(Trigger.New);
    }
}