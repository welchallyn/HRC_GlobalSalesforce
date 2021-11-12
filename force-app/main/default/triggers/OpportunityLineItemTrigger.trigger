/*
    *  triggerName  : opportunitylineitemtrigger
    *  CreatedOn    : 08/Feb/2017
    *  ModifiedOn   : 10/Feb/2017
    *  CreatedBy    : Jenish Shingala
    *  ModifiedBy   : Jenish Shingala
    *  Description  : Used for Handling all events for Opportunity Products (OpportunityLineItem).
*/
trigger OpportunityLineItemTrigger on OpportunityLineItem  (before update) {
    if(Trigger.isBefore && Trigger.isUpdate){
        if(OpportunitylineitemTriggerHandler.isRunTrigger==true)
             OpportunitylineitemTriggerHandler.CreateFeedItemBasedOnDateChange(Trigger.newMap,Trigger.OldMap); 
    } 
}