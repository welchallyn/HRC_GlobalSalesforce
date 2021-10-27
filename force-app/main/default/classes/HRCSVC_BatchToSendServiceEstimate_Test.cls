/******************************************************************************************************
* Name                             : HRCSVC_BatchToSendServiceEstimate_Test
* Author                           : Capgemini
* Date                             : August/14/2020
* Requirement/Project Name         : Hill-Rom
* Requirement/Project Description  :  Class to
*                                   1. Test class for HRCSVC_BatchToSendServiceEstimate for #SE-46
* Revison                          :
/*****************************************************************************************************/
@isTest
public with sharing class HRCSVC_BatchToSendServiceEstimate_Test {
    /*
* **************************************************************************************
* This setup method to create test data from utlity class
* **************************************************************************************
*/
    @testSetup
    public static void testClassData(){
        worktype wtChild=HRCFSL_TestUtilityClass.createWorkTypewithSword(true,'SN_U','HRCFSL_Capital_Preventative');
        
        ServiceTerritory stChild =  HRCFSL_TestUtilityClass.createServiceTerritory(true, 'test12345', 'My Place');
        HRCFSL_TestUtilityClass.generateOrgExceptionCusSettingRec();
        HRCFSL_TestUtilityClass.generateAddress();
        List<WorkOrder> listOfWO = new List<WorkOrder>();
        Schema.Location locationNew = HRCFSL_TestUtilityClass.createCustomer(true, 'Customer1307');
        
        for(Integer i= 0; i < 10;i++){
            WorkOrder wo = new WorkOrder();
            wo.HRCFSL_Contact_First_Name__c = 'Test Contact';
            wo.HRCFSL_Contact_Last_Name__c = 'LastName';
            wo.HRCFSL_Contact_Phone__c = '0001001';
            wo.HRCFSL_Contact_Department__c = 'CON';
            wo.HRCFSL_Activity_Type__c = '4'; ////value before 20th Jan - M
            wo.Status = 'SC';
            wo.HRCFSL_Doc_Type__c = 'SE';//value before 20th Jan - SN
            wo.HRCFSL_Actual_End__c = System.now();
            wo.HRCFSL_PO__c = 'PO123';
            wo.HRCFSL_JDE_ID__c = 'EXT'+Math.random();
            wo.Priority = '1';
            wo.Location = locationNew;
            wo.HRCFSL_Patient_First_Name__c = 'John';
            wo.HRCFSL_Patient_Last_Name__c = 'Doe';
            wo.WorkTypeId = wtChild.ID;
            wo.ServiceTerritoryId = stChild.Id;
            wo.HRCFSL_Signee_Email__c = '';
            wo.HRCFSL_Signee_Name__c = '';
            wo.HRCFSL_Signee_Title__c = '';
            wo.HRCSVC_Latest_Quote_Status_Change__c = system.now().addDays(-10);
            
            if(i < 1){
                wo.HRCSVC_Quote_Status__c = 'Quote Sent';
            }else if(i<2){
                wo.HRCSVC_Quote_Status__c = 'Quote Follow-Up 1';
            }
            wo.HRCFSL_Contact_Email__c = 'testme1212@me.com';            
            listOfWO.add(wo);
        }
        if(!listOfWO.isEmpty()){
            insert listOfWO;
        }
        ServiceAppointment sa = new ServiceAppointment();
        sa.ParentRecordId = listOfWO[0].Id;
        sa.HRCFSL_Work_Order__c = listOfWO[0].Id;
        sa.EarliestStartTime = System.now();
        sa.DueDate = System.now() + 2;
        sa.SchedStartTime = System.now();
        sa.SchedEndTime = system.now() + 2;
        //sa.status = 'Awaiting signature';
        sa.status = 'None';
        insert sa;
        
    }
    @isTest
    public static void sendEmailFromBatchTest(){
        test.startTest();
        Database.executeBatch(new HRCSVC_BatchToSendServiceEstimate(), 9);
        
        ServiceAppointment sa = [select id, ParentRecordId from ServiceAppointment limit 1];
        WorkOrder wo=[Select id,HRCSVC_Quote_Status__c,AssetId,HRCFSL_Contact_Email__c from WorkOrder Where id=:sa.ParentRecordId Limit 1];
        ServiceReport report = HRCFSL_TestUtilityClass.createServiceReport(true, wo.Id);
        Map<Id,ServiceReport> mapOfSRByWOId = new Map<Id,ServiceReport>();
        mapOfSRByWOId.put(report.ParentId,report);
        
        list<workorder> listOfWO2 = new list<workorder>();
        listOfWO2.add(wo);
        String messageBody;
        messageBody = 'Test Body';
        HRCSVC_BatchToSendServiceEstimate.sendEmailAndUpdateWO(listOfWO2,mapOfSRByWOId);
        HRCSVC_BatchToSendServiceEstimate b = new HRCSVC_BatchToSendServiceEstimate();
        Database.executeBatch(b);
        
        Database.QueryLocator ql = b.start(null);
        b.execute(null,listOfWO2);
        b.Finish(null);
        test.stopTest();
    }
    /*
* **************************************************************************************
* Test service appointment creation with mock
* **************************************************************************************
*/
    @isTest
    public static void sendEmailTest(){
        test.startTest();
        HRCSVC_BatchToSendServiceEstimate sh1 = new HRCSVC_BatchToSendServiceEstimate();
        String sch = '0 0 0/1 1/1 * ? *'; 
        String jobId = system.schedule('ScheduleApex33213567', sch, sh1); 
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :jobId];
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        test.stopTest();
    }
    @isTest
    public static void sendBatchTest(){
        test.startTest();
        HRCSVC_BatchToSendServiceEstimate b = new HRCSVC_BatchToSendServiceEstimate();
        Database.executeBatch(b);
        test.stopTest();
    }
}