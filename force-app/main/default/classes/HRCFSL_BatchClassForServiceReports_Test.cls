/******************************************************************************************************
* Name                             : HRCFSL_BatchClassForServiceReports_Test
* Author                           : Birlasoft Ops Excellence
* Date                             : November/17/2020
* Requirement/Project Name         : Hill-Rom
* Requirement/Project Description  :  Test Class to cover the Batch Class HRCFSL_BatchClassForServiceReports
* Revison                          :
*****************************************************************************************************/

@isTest
public with sharing class HRCFSL_BatchClassForServiceReports_Test {

    /****************************************************************************************
        * This setup method to create test data from utlity class
    *****************************************************************************************/
    @testSetup
    public static void testClassData(){
        List<ServiceAppointment> listOfSA = new List<ServiceAppointment>();
        listOfSA = HRCFSL_TestUtilityClass.createMultipleServiceAppointmentsWithWO('Completed',System.now(),System.now() + 2,System.now(),system.now() + 2);
        
        for(Integer i=0; i<listOfSA.size(); i++){
            listOfSA[i].HRCFSL_Is_Service_Report_Generated__c = true;
            listOfSA[i].HRCFSL_Service_Report_Generated_byBatch__c = true;
        }
        update listOfSA;
    }
    
    /****************************************************************************************
        * This test method to run the Batch class
    *****************************************************************************************/
    public static testmethod void testRunBatch(){
        Test.startTest();
        HRCFSL_BatchClassForServiceReports clsBatch = new HRCFSL_BatchClassForServiceReports();
        Database.executeBatch(clsBatch);
        Test.stopTest();
    }
    
    /****************************************************************************************
        * This test method to schedule the Batch class
    *****************************************************************************************/
    public static testmethod void testScheduleBatch(){
        Test.startTest();
        HRCFSL_BatchClassForServiceReports clsSchedule = new HRCFSL_BatchClassForServiceReports();
        String sch1 = '0 0 * * * ?';
        System.schedule('Schedule Job1', sch1, clsSchedule);
        Test.stopTest();
    }
}