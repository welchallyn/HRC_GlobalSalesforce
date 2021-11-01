/**********************************************************************************************************************************************
* Name                             :  HRCSVC_Auto_CreateSA_Batch
* Author                           :  Capgemini
* Date                             :  July/09/2021
* Requirement/Project Name         :  Hill-Rom
* Requirement/Project Description  :  This batch class was developed as a retry mechanism to ensure that all work orders have Service Appointments
									  auto generated for them. 
/**********************************************************************************************************************************************/
public class HRCSVC_Auto_CreateSA_Batch implements Database.Batchable<sObject>,schedulable {
    
    public Database.QueryLocator start(Database.BatchableContext bc){       
        Integer Minutes = Integer.valueOf(System.label.HRCSVC_Minutes_For_Auto_SA); 
        DateTime WOTime = Datetime.now().addMinutes(-Minutes);
        String Query = 'SELECT Id, WorkOrderNumber FROM WorkOrder WHERE ServiceAppointmentCount = 0 AND CreatedDate <= :WOTime AND HRCFSL_Is_Cloned__c = False AND HRCFSL_Tech_Generated__c = False AND HRCFSL_Is_Quote__c = False AND WorkType.ShouldAutoCreateSvcAppt = False AND HRCFSL_Auto_Generate_SA__c = True AND HRCFSL_Is_Kit_Child__c = False AND HRCSVC_Remote_Tech_Support__c = False AND StatusCategory = \'New\' LIMIT 10';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<WorkOrder> ListWO){
        Map<String, Object> inputs = new Map<String, Object>();
        if(ListWO.size()>0){
            for(WorkOrder w : ListWO){   
                inputs.put('WorkOrderId', w.id);
                inputs.put('FromERP', false);
                Flow.Interview.HRCFSL_Auto_Generate_Service_Appointment AutoGenFlow = new Flow.Interview.HRCFSL_Auto_Generate_Service_Appointment(inputs);
                AutoGenFlow.start();
            }
        }        
    }
    
    public void finish(Database.BatchableContext bc){
        
    }
    
    public void execute(SchedulableContext SC) {
        database.executebatch(new HRCSVC_Auto_CreateSA_Batch());
    }
    
}