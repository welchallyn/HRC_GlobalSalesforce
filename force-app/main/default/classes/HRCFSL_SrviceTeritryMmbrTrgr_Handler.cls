/**********************************************************************************************
* Class Name                       : HRCFSL_SrviceTeritryMmbrTrgr_Handler
* Author                           : Anchal Garg
* Date                             : June/20/2019
* Requirement/Project Name         : Hill-Rom
* Requirement/Project Description  : Handler class to
*                                  1. to populate user id from the assigned service resource(#HF26)
*                                  2. to populate paging team member field from Paging team MultiSelect Picklist (#HF26)
* Revision                         :
************************************************************************************************/
public with sharing class HRCFSL_SrviceTeritryMmbrTrgr_Handler {
   /*************************************************
     * Method Name: onAfterInsert
     * Author: Capgemini
     * Date: June/20/2019
     * Params: ServiceTerritoryMember
     * Return: void
     * Requirement : to handle before insert ServiceTerritoryMember actions.
     *************************************************/
     public void OnAfterInsert(ServiceTerritoryMember[] stMembers, Map < Id, ServiceTerritoryMember > OldstMemberMap, Map < Id, ServiceTerritoryMember > NewstMemberMap) {
        populateUserNPagingTeamMember(stMembers,OldstMemberMap, NewstMemberMap);
     }

    /*************************************************
     * Method Name: OnAfterUpdate
     * Author: Capgemini
     * Date: June/20/2019
     * Params: ServiceTerritoryMember,OldServiceTerritoryMembers,OldServiceTerritoryMemberMap,NewServiceTerritoryMemberMap
     * Return: void
     * Requirement : to handle before update ServiceTerritoryMember actions.
     *************************************************/
    public void OnAfterUpdate(ServiceTerritoryMember[] stMembers, Map < Id, ServiceTerritoryMember > OldstMemberMap, Map < Id, ServiceTerritoryMember > NewstMemberMap) {
        populateUserNPagingTeamMember(stMembers,OldstMemberMap, NewstMemberMap);
     }
    /*************************************************
     * Method Name: populateUserNPagingTeamMember
     * Author: Capgemini
     * Date: June/20/2019
     * Params: ServiceTerritoryMember
     * Return: void
     * Requirement : to handle before insert ServiceTerritoryMember actions.
     *************************************************/
     public void populateUserNPagingTeamMember(ServiceTerritoryMember[] stMembers, Map < Id, ServiceTerritoryMember > OldstMemberMap, Map < Id, ServiceTerritoryMember > NewstMemberMap) {
        set<string> serviceRecourceIdSet = new set<String>();
        map<string,string> ServiceResUserMap  = new map<string,string>();
        List<ServiceTerritoryMember> recNeedstobeUpdated = new List<ServiceTerritoryMember>();

            for(ServiceTerritoryMember stm : stMembers){
              serviceRecourceIdSet.add(stm.ServiceResourceId);
            }
            for(ServiceResource sr : [select id,RelatedRecordId from ServiceResource where id in : serviceRecourceIdSet]){
                ServiceResUserMap.put(sr.id,sr.RelatedRecordId);
            }
            for(ServiceTerritoryMember stm : [select id,HRCFSL_Paging_Team_Members__c,HRCFSL_Paging_Team__c,HRCFSL_Service_Resource_User__c,ServiceResourceId from ServiceTerritoryMember where id in : NewstMemberMap.keyset() ]){
                    if(OldstMemberMap!=null && (stm.HRCFSL_Paging_Team__c!=OldstMemberMap.get(stm.Id).HRCFSL_Paging_Team__c || stm.ServiceResourceId!=OldstMemberMap.get(stm.Id).ServiceResourceId)){
                        stm.HRCFSL_Paging_Team_Members__c = stm.HRCFSL_Paging_Team__c;
                        stm.HRCFSL_Service_Resource_User__c=ServiceResUserMap.containsKey(stm.ServiceResourceId) ? ServiceResUserMap.get(stm.ServiceResourceId) : '';
                        recNeedstobeUpdated.add(stm);
                    }
                    else if(OldstMemberMap==null){
                        stm.HRCFSL_Paging_Team_Members__c = stm.HRCFSL_Paging_Team__c;
                        stm.HRCFSL_Service_Resource_User__c=ServiceResUserMap.containsKey(stm.ServiceResourceId) ? ServiceResUserMap.get(stm.ServiceResourceId) : '';
                        recNeedstobeUpdated.add(stm);
                    }
           }
           if(!recNeedstobeUpdated.isEmpty()){
               update recNeedstobeUpdated;
           }

     }

}