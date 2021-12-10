/********************************************************
 * Trigger Name: HRCSVC21_QuoteLineTrigger
 * Author: Capgemini
 * Date: December/8/2021
********************************************************/

trigger HRCSVC21_QuoteLineTrigger on QuoteLineItem (before insert, after insert, before update, after update) {
	HRCSVC21_QuoteLineItemHandler ItemHandler = new HRCSVC21_QuoteLineItemHandler();
    
    if(trigger.isafter && trigger.isInsert){
        ItemHandler.onAfterInsert(trigger.new, trigger.oldmap);
    }
    if(trigger.isafter && trigger.isUpdate){
        ItemHandler.onAfterUpdate(trigger.new, trigger.oldmap);
    }
}