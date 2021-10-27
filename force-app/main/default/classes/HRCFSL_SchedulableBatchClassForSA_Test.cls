/******************************************************************************************************
* Name                             : HRCFSL_SchedulableBatchClassForSA_Test
* Author                           : Capgemini
* Date                             : August/14/2020
* Requirement/Project Name         : Hill-Rom
* Requirement/Project Description  :  Class to
*                                   1. Test class for HRCFSL_SchedulableBatchClassForSA for #SE-590
* Revison                          :
/*****************************************************************************************************/
@isTest
public with sharing class HRCFSL_SchedulableBatchClassForSA_Test {
    /*
    * **************************************************************************************
    * This setup method to create test data from utlity class
    * **************************************************************************************
    */
    @testSetup
    public static void testClassData(){
        List<ServiceAppointment> listOfSA = new List<ServiceAppointment>();
        listOfSA = HRCFSL_TestUtilityClass.createMultipleServiceAppointmentsWithWO('Completed',System.now(),System.now() + 2,System.now(),system.now() + 2);
    }
    /*
    * **************************************************************************************
    * Test service appointment creation with mock
    * **************************************************************************************
    */
    @isTest
    public static void createServiceAppointmentTest(){
        Test.setMock(HttpCalloutMock.class, new HRCFSL_ServiceReportHelper_Mock());
        test.startTest();
        	Database.executeBatch(new HRCFSL_SchedulableBatchClassForSA(), 200);
        test.stopTest();
        List<ServiceAppointment> insertedSA = [Select ID,HRCFSL_Is_Service_Report_Generated__c from ServiceAppointment];
        system.assertEquals(insertedSA[0].HRCFSL_Is_Service_Report_Generated__c, true);
    }
    /*
    * **************************************************************************************
    * test schedule queue
    * **************************************************************************************
    */
    @istest
    public static void scheduleQueue(){
        Test.setMock(HttpCalloutMock.class, new HRCFSL_ServiceReportHelper_Mock());
        test.startTest();
        HRCFSL_SchedulableBatchClassForSA sh1 = new HRCFSL_SchedulableBatchClassForSA();
        String sch = '0 0 23 * * ?'; 
        String jobId = system.schedule('ScheduleApex33213', sch, sh1); 
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :jobId];
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        test.stopTest();
    }
}