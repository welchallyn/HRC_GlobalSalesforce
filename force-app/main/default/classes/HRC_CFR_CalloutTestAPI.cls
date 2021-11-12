@isTest
public class HRC_CFR_CalloutTestAPI {
    private static List<Capital_Requests__c> lstCapitalRequest;
    @isTest static  void testGetCallout() {
        Capital_Requests__c cfrDataTest = new Capital_Requests__c();
        cfrDataTest.Status__c='Approved';
        cfrDataTest.Project_Name__c='TestingProject';
        cfrDataTest.Company_code__c='5000';
        cfrDataTest.Is_this_a_Physical_Asset__c='Yes';
        insert cfrDataTest;
        
        List<Capital_Requests__c> lstData = new List<Capital_Requests__c>();
		lstData.add(cfrDataTest);
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new HRC_CFR_CalloutTest()); 
        	HRC_CapitaRequestInvokeAPI.invokeapexcallout(lstData);
        Test.stopTest();
    }
    
    
    
    @isTest static  void testGetCalloutForSupplemental() {
        Capital_Requests__c cfrDataTest = new Capital_Requests__c();
        cfrDataTest.Status__c='Approved';
        cfrDataTest.Project_Name__c='TestingProject';
        cfrDataTest.Supplemental__c=True;
        cfrDataTest.SAP_CFR_Number__c='5000-CP-0094';
        cfrDataTest.Company_code__c='5000';
        cfrDataTest.Is_this_a_Physical_Asset__c='Yes';
        insert cfrDataTest;
        
        List<Capital_Requests__c> lstData = new List<Capital_Requests__c>();
		lstData.add(cfrDataTest);
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new HRC_CFR_CalloutTest()); 
        	HRC_CFR_SupplementalInvokeAPI.invokeapexcallout(lstData);
        Test.stopTest();
    }
}