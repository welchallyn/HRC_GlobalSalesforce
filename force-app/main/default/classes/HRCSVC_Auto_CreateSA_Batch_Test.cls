/**********************************************************************************************************************************************
* Name                             :  HRCSVC_Auto_CreateSA_Batch_Test
* Author                           :  Kushagra Bansal
* Date                             :  July/09/2021
* Requirement/Project Name         :  Hill-Rom
* Requirement/Project Description  :  Test class for the HRCSVC_Auto_CreateSA_Batch.
/**********************************************************************************************************************************************/
@isTest
public class HRCSVC_Auto_CreateSA_Batch_Test {
    
	@testSetup
    static void setup(){
        List<WorkOrder> newWO = new List<WorkOrder>();
        DateTime t = DateTime.now() - (40.0/1440);
        WorkType wt = new WorkType(ShouldAutoCreateSvcAppt = False, HRCFSL_Doc_Type__c = 'MA', HRCFSL_Activity_Type__c = 'M', Name = 'Test Type', HRCFSL_Work_Type_Desc__c = 'description', EstimatedDuration = 1, HRCFSL_JDE_Id__c = '15432', HRC_FSL_Work_Class__c = 'Capital' );
        insert wt;
        wt = [SELECT Id FROM WorkType WHERE ShouldAutoCreateSvcAppt = False];
        for(Integer i=0; i<10; i++){
            newWO.add(new WorkOrder(CreatedDate = t, HRCFSL_Kitted__c = False, HRCFSL_Is_Cloned__c = False, HRCFSL_Is_Quote__c = False, WorkTypeId = wt.Id, HRCFSL_Auto_Generate_SA__c = False,
                                   HRCFSL_Is_Kit_Child__c = False, HRCSVC_Remote_Tech_Support__c = False, HRCFSL_JDE_ID__c = String.valueOf(i), HRCFSL_Activity_Type__c = 'M', HRCFSL_Doc_Type__c = 'MA'));
        }
        insert newWO;
        List<WorkOrder> updateWO = [SELECT Id, HRCFSL_Auto_Generate_SA__c FROM WorkOrder];
        for(WorkOrder wo : updateWO ){
            wo.HRCFSL_Auto_generate_SA__c = True;
        }
        update updateWO;
    }
    
    @isTest static void create_SA_Batch_Test(){
        Test.startTest();
        HRCSVC_Auto_CreateSA_Batch autoTest = new HRCSVC_Auto_CreateSA_Batch();
        Database.executeBatch(autoTest);
        Test.stopTest();
        System.assertEquals(10, [select count() from ServiceAppointment]);
        system.debug([select Id, HRCFSL_Work_Order__c from ServiceAppointment]);
    }
    
    @isTest static void create_SA_Batch_Scheduled_Test(){
        Test.startTest();
        HRCSVC_Auto_CreateSA_Batch autoTest = new HRCSVC_Auto_CreateSA_Batch();
        String sch = '0 0 0 * * ?'; 
		String jobID = system.schedule('SA generation job', sch, autoTest);
        Test.stopTest();
    }
    
}