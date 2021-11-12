/***********************************************************************************************
 * Name                             : HRCFSL_DeleteEntitlementsScheduler
 s
 * Author                           : Anchal Garg 
 * Date                             : August/13/2019
 * Requirement/Project Name         : Hill-Rom
 * Requirement/Project Description  :  Scheduled apex
 *                                   1. HF-251 that runs nightly at 3am Amsterdam time that deletes all Entitlements
 *                                      such that EndDate < (TODAY - 90) && RecordType = HRC Service Entitlement
 * Revison                          :
/***********************************************************************************************/
global class HRCFSL_DeleteEntitlementsScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        string entRectypename='';
        list<string> rectypenamelst=new list<string>();
        string recQuery='Select e.endDate,e.id From Entitlement e where EndDate<LAST_N_DAYS:90 ';
        list<HRCFSL_Organization_Settings__mdt> Os = [select HRCFSL_Component_Detail__c,DeveloperName from HRCFSL_Organization_Settings__mdt where DeveloperName='Entitlement_Record_Type' ];
            if(os.size()>0){
             entRectypename=os[0].HRCFSL_Component_Detail__c;
             rectypenamelst=entRectypename.split(',');
             recQuery+='and recordtype.name in: rectypenamelst '; 
            }
        recQuery+='order by EndDate ASC Limit 10000';
         list<Entitlement> entlst= database.query(recQuery);
             if(entlst.size()>0){
                  delete entlst;
            }
    }
}