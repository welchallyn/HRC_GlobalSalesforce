/***********************************************************************************************
* Name                             : HRCFSL_LockWorkOrderQueueable
* Author                           : Capgemini
* Date                             : August/11/2020
* Requirement/Project Name         : Hill-Rom
* Requirement/Project Description  : Class to
*                                   1.Update Lock Work Order checkbox as true
2.Calls Flow HRCFSL_Close_Service_Appointment to complete the Service Appointments
*                                      #SE-604
* Revison                          :
/***********************************************************************************************/
public class HRCFSL_LockWorkOrderQueueable implements Queueable {
    
    list<WorkOrder> workOrderlistToBeUpdated = new List<WorkOrder>();
    Map <Id,WorkOrder> woMap = new Map <Id,WorkOrder>();
    public HRCFSL_LockWorkOrderQueueable(List<Id> woIdsList){
        woMap = new Map <Id,WorkOrder>([select id,HRCFSL_Lock_Work_Order__c,StatusCategory,StartDate from WorkOrder where Id in: woIdsList]);
    }
    
    /******************************************************************************
* Method Name: execute
* Author: Capgemini
* Date: August/11/2020
* Params:
* Return: void
* Requirement : Updates Lock Work Order checkbox as true and Calls Flow (HRCFSL_Close_Service_Appointment) to close the Service Appointments
******************************************************************************/
    public void execute(QueueableContext context) {
        for(WorkOrder wo : woMap.values()){
            wo.HRCFSL_Lock_Work_Order__c = true;
            workOrderlistToBeUpdated.add(wo);
        }
        if(workOrderlistToBeUpdated.size()>0){
            update workOrderlistToBeUpdated;
        }
        //calls flow (HRCFSL_Close_Service_Appointment) to close Service Appointments
        HRCFSL_Organization_Settings__mdt customMetaData = [select HRCFSL_Component_Detail__c from HRCFSL_Organization_Settings__mdt where developerName='SA_Status_needs_to_be_Sync_with_JDE'];
        list<ServiceAppointment> SaListToBeClosed =new list<ServiceAppointment>();
        Map <Id,ServiceAppointment> saMap = new Map <Id,ServiceAppointment>([Select Id,ParentRecordId,ActualStartTime,ActualEndTime,DurationInMinutes from ServiceAppointment where  StatusCategory !=: customMetaData.HRCFSL_Component_Detail__c and ParentRecordId in :woMap.keySet()]);
        if(saMap.size() > 0) {
            List<ServiceAppointment> saList = new List<ServiceAppointment>();
            List<ServiceAppointment> saListToBeUpdated = new List<ServiceAppointment>();
            ServiceAppointment satemp = new ServiceAppointment();        
            Map <Id,List<ServiceAppointment>> wosaMap = new Map <Id,List<ServiceAppointment>>();
            
            HRCFSL_Organization_Settings__mdt orgSetting = [select HRCFSL_Component_Detail__c from HRCFSL_Organization_Settings__mdt where developerName='HRCFSL_DataLoader_Profile'];
            Id profileId=userinfo.getProfileId();
            List<Profile> profileList = new List<Profile>(); 
            profileList =[Select Id,Name from Profile where Id=:profileId];
            String profileName = profileList.size()>0 ? profileList[0].Name : '';
            if(profileName == orgSetting.HRCFSL_Component_Detail__c ){
                for(Id said:saMap.keySet()){
                    satemp = new ServiceAppointment();
                    satemp = saMap.get(said);
                    if(wosaMap.containsKey(satemp.ParentRecordId)){
                        saList = wosaMap.get(satemp.ParentRecordId);                   
                    }
                    else{
                        saList = new List<ServiceAppointment>();                     
                    }
                    saList.add(satemp);
                    wosaMap.put(satemp.ParentRecordId,saList);
                }
                saList = new List<ServiceAppointment>(); 
                for(WorkOrder wo : woMap.values()){
                    if(wo.StatusCategory == 'Completed'){
                        for(ServiceAppointment sa: wosaMap.get(wo.Id)){
                            sa.Status = 'Completed';
                            sa.HRCFSL_ClosedByJDE__c = True;
                            if(sa.ActualStartTime == null){
                                sa.ActualStartTime = wo.StartDate;
                            }
                            if(sa.ActualEndTime == null){
                                sa.ActualEndTime = sa.ActualStartTime + (sa.DurationInMinutes/1440);
                            }
                            saListToBeUpdated.add(sa);
                        }
                    }
                    else if(wo.StatusCategory == 'Canceled'){
                        for(ServiceAppointment sa: wosaMap.get(wo.Id)){
                            sa.Status = 'Canceled';
                            sa.HRCFSL_ClosedByJDE__c = True;
                            saListToBeUpdated.add(sa);
                        }
                    }   
                }
                if(saListToBeUpdated.size()>0) 
                {
                    update saListToBeUpdated;
                }
            }
        }
    }
}