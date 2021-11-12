/***********************************************************************************************
 * Name                             : HRCFSL_ServiceTerritoryMember_trigger
 * Author                           : Anchal Garg 
 * Date                             : June/20/2019
 * Requirement/Project Name         : Hill-Rom
 * Requirement/Project Description  :  Trigger to
 *                                   1. to populate user id from the assigned service resource(#HF26)
 *                                   2. to populate paging team member field from Paging team MultiSelect Picklist (#HF26)
 * Revison                          :
/***********************************************************************************************/
trigger HRCFSL_ServiceTerritoryMember_trigger on ServiceTerritoryMember (before insert,before update,after insert,after update) {
//HRCFSL_Paging_Team_Members__c     HRCFSL_Paging_Team__c
 HRCFSL_SrviceTeritryMmbrTrgr_Handler handler = new HRCFSL_SrviceTeritryMmbrTrgr_Handler();
    /*Before Insert*/
    if(Trigger.isInsert && Trigger.isbefore){
    //handler.OnbeforeInsert(Trigger.new, Trigger.oldmap, Trigger.newmap);
    }
    /* After Insert */
    else if(Trigger.isInsert && Trigger.isAfter){
    handler.OnAfterInsert(Trigger.new,Trigger.oldmap,Trigger.newmap);
    }
    /*Before Update*/
    else if(Trigger.isUpdate && Trigger.isBefore){
   // handler.Onbeforeupdate(Trigger.old,Trigger.new,Trigger.oldmap, Trigger.newmap);
    }
    /* After Update */
    else if(Trigger.isUpdate && Trigger.isAfter){
    handler.OnAfterUpdate(Trigger.new,Trigger.oldmap, Trigger.newmap);   
    }
}