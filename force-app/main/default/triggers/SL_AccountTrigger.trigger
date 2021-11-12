/**
    @Trigger Name  : SL_AccountTrigger
    @JIRA Ticket   : WADVDSC - 2 , WADVDSC-4, WADVDSC-5
    @Created on    : 15/May/2015
    @Modified by   : Sanath Kumar
    @Description   : Trigger on insert, update and delete of Account, This trigger will update Account records with its ultimate parents.
*/
trigger SL_AccountTrigger on Account (before insert , before update, after update , before delete , after delete) 
{
    //Trigger Handler
    SL_AccountHandler objHandler = new SL_AccountHandler();
    
    if(trigger.isbefore && trigger.isInsert)
    {
        objHandler.onBeforeInsert(trigger.new);
    }

    if(trigger.isbefore && trigger.isUpdate)
    {
        objHandler.onBeforeUpdate(trigger.oldMap, trigger.new);
    }
        
    if(trigger.isafter && trigger.isUpdate)
    {
        objHandler.onAfterUpdate(trigger.oldMap , trigger.newMap);
    }
    
    if(trigger.isbefore && trigger.isDelete)
    {
        objHandler.onBeforeDelete(trigger.oldMap);
    }
    
    if(trigger.isAfter && trigger.isDelete)
    {
        objHandler.onAfterDelete(trigger.oldMap);
    }
}