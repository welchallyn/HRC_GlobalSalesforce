/***********************************************************************************************
 * Name                             : HRCFSL_EmailServiceReport_Test
 * Author                           : Capgemini
 * Date                             : Aug/21/2019
 * Requirement/Project Name         : Hill-Rom
 * Requirement/Project Description  : Test Class for 
*                                       1. #HF-109 Testing functionality of "HRCFSL_EmailServiceReport"
*                                       2. #HF-67 , #HF-266 : testing functionality of class "HRCFSL_Outbound_JDE_Work_Order_Trigger
*                                       I>    HRCFSL_Outbound_JDE_Work_Order_Trigger
*                                       II>   HRCFSL_Outbound_JDE_Work_Order_Handler
*                                       III>  HRCFSL_Work_Order_Callout
 * Revison                          : 
 ***********************************************************************************************/
@isTest
public class HRCFSL_EmailServiceReport_Test {
    /*
      for  setting up Test Data 
    */
    @testSetup
    static void setupData() {
        HRCFSL_TestUtilityClass.generateOrgExceptionCusSettingRec();
        Schema.Location location = HRCFSL_TestUtilityClass.createCustomer(true, 'Customer098');
        location.HRCFSL_Language__c = 'en_US';
        update location;
        FSL.GlobalAPIS.addStatusTransition('Awaiting signature', 'Completed');
        ServiceAppointment sa = HRCFSL_TestUtilityClass.createSAwithWorkOrder(true, 'sa123', 'Customer098');
        Asset astNew = HRCFSL_TestUtilityClass.createAsset(True);
        //ProductConsumed pc = HRCFSL_TestUtilityClass.createProductConsumed(true, sa.ParentRecordId);
        WorkOrderLineItem woli= new WorkOrderLineItem(WorkOrderId=sa.ParentRecordId);
        insert woli;
    }
    /*
      for testing service report functionality
    */
    @isTest
    static void TestServiceReport() {
        Test.startTest();
        ServiceAppointment sa = [select id,status,ParentRecordId from ServiceAppointment where status ='Awaiting signature' limit 1];//where status ='Completed' limit 1];
        ServiceReport report = HRCFSL_TestUtilityClass.createServiceReport(true, sa.Id);
        //report.isSigned = true;
        list < HRCFSL_EmailServiceReport.emailParams > params = new List < HRCFSL_EmailServiceReport.emailParams > ();
        HRCFSL_EmailServiceReport.emailParams param = new HRCFSL_EmailServiceReport.emailParams();
        param.emailAddress = 'test@test.com';
        param.srId = report.id;
        param.delimiter = '^';
        params.add(param);
        HRCFSL_EmailServiceReport.emailServiceReport(params);
        Test.stopTest();
        //List<workorder> listOfworkorder = [select id from workorder where HRCFSL_Signee_Email__c = 'test@testhillrom.com'];
        //system.assertEquals(listOfworkorder[0].ID, sa.ParentRecordId);
        //system.assertEquals(true,report.isSigned);
    }
    /*
      for testing service report functionality
    */
    @isTest
    static void TestServiceReportwithWO() {
        Test.startTest();
        ServiceAppointment sa = [select id, ParentRecordId from ServiceAppointment limit 1];
        WorkOrder wo=[Select id from WorkOrder Where id=:sa.ParentRecordId Limit 1];
        ServiceReport report = HRCFSL_TestUtilityClass.createServiceReport(true, wo.Id);
        //report.isSigned = true;
        list < HRCFSL_EmailServiceReport.emailParams > params = new List < HRCFSL_EmailServiceReport.emailParams > ();
        HRCFSL_EmailServiceReport.emailParams param = new HRCFSL_EmailServiceReport.emailParams();
        param.emailAddress = 'test@test.com';
        param.srId = report.id;
        param.delimiter = '^';
        params.add(param);
        //HRCFSL_EmailServiceReport.emailServiceReport(params);
        Test.stopTest();
        system.assertEquals(wo.ID, sa.ParentRecordId);
    }
    /*
      for testing service report functionality
    */
    @isTest
    static void TestServiceReportwithWOLI() {
        Test.startTest();
        WorkOrderLineItem woli=[Select id, WorkOrderId from WorkOrderLineItem Limit 1];
        ServiceReport report = HRCFSL_TestUtilityClass.createServiceReport(true, woli.Id);
        //report.isSigned = true;
        list < HRCFSL_EmailServiceReport.emailParams > params = new List < HRCFSL_EmailServiceReport.emailParams > ();
        HRCFSL_EmailServiceReport.emailParams param = new HRCFSL_EmailServiceReport.emailParams();
        param.emailAddress = 'test@test.com';
        param.srId = report.id;
        param.delimiter = '^';
        params.add(param);
       // HRCFSL_EmailServiceReport.emailServiceReport(params);
        Test.stopTest();
        system.assertEquals(woli.ID, report.ParentId);
    }
    /*
      for testing JDE integration code 
    */
    @isTest
    static void TestSynctoJdeService() {
        test.startTest();
        Asset ast = [Select id from Asset limit 1];
        serviceappointment sa = [select id, ParentRecordId from serviceappointment limit 1];
        WorkOrder wo = [Select id, AssetId from WorkOrder where Id =: sa.ParentRecordId];
        wo.AssetId = ast.Id;
        Update wo;
        list < HRCFSL_Outbound_JDE_Work_Order__e > events = new list < HRCFSL_Outbound_JDE_Work_Order__e > ();
        events.add(new HRCFSL_Outbound_JDE_Work_Order__e(HRCFSL_Work_Order__c = sa.parentRecordId));
        List < database.saveresult > results = EventBus.publish(events);
        test.stopTest();
        system.assertEquals(wo.ID, sa.ParentRecordId);
    }
}