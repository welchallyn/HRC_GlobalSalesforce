/***********************************************************************************************
* Name                             : HRCFSL_ServiceReportHelper_Test
* Author                           : Capgemini
* Date                             : August/04/2020
* Requirement/Project Name         : Hill-Rom
* Requirement/Project Description  :  Class to
*                                   1. Test HRCFSL_ServiceReportHelper by using the mock class
* Revison                          :   #SE-590
/***********************************************************************************************/
@isTest
public with sharing class HRCFSL_ServiceReportHelper_Test {
    /*******************************************************************************************************
    * Method Name: serviceReportTestMock
    * Author: Capgemini
    * Date: August/04/2020
    * Params: 
    * Return: 
    * Requirement : 1. test class to create service report 
    *******************************************************************************************************/
    @isTest
    public static void serviceReportTestMock() {
        Test.setMock(HttpCalloutMock.class, new HRCFSL_ServiceReportHelper_Mock());
        String[] email = new String[]{'test@hillrom.com'};
        HRCFSL_ServiceReportHelper.FlowInputWrapper wrapperInput = new HRCFSL_ServiceReportHelper.FlowInputWrapper();
        //to set as equal to mock
        wrapperInput.ParentRecordID = '0WOL000000275BNOAY';
        wrapperInput.sendEmailConfirmation = true;
        wrapperInput.EmailRecipient = email;
        List<HRCFSL_ServiceReportHelper.FlowInputWrapper> flowInputs = new List<HRCFSL_ServiceReportHelper.FlowInputWrapper>();
        flowInputs.add(wrapperInput);
        test.startTest();
        	List<String> response = HRCFSL_ServiceReportHelper.createServiceReport(flowInputs);
        test.stopTest();
        //this method is run from the flow
        //so returning null for this
        system.assertEquals(null, response);
    }	
}