trigger CompanyCarRequestTrigger on Company_Car_Request__c (before insert, after insert, before update, after update , before delete , after delete) {
    //Trigger Handler
    CompanyCarRequestHandler objHandler = new CompanyCarRequestHandler();
    
    //handles before insert
    if(trigger.isbefore && trigger.isInsert)
    {
        objHandler.onBeforeInsert(trigger.new);
    }
    //handles after insert
    if(trigger.isafter && trigger.isInsert)
    {
        objHandler.onAfterInsert(trigger.newMap);
    }
    //handles before update
    if(trigger.isbefore && trigger.isUpdate)
    {
        objHandler.onBeforeUpdate(trigger.oldMap, trigger.new);
    }
    //handles after update 
    if(trigger.isafter && trigger.isUpdate)
    {
        objHandler.onAfterUpdate(trigger.newMap);
    }
    //handles before delete
    if(trigger.isbefore && trigger.isDelete)
    {
        objHandler.onBeforeDelete(trigger.oldMap);
    }
    //handles after delete
    if(trigger.isAfter && trigger.isDelete)
    {
        objHandler.onAfterDelete(trigger.oldMap);
    }
}