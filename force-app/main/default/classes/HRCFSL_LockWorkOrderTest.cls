/***********************************************************************************************
* Name                             : HRCFSL_Outbound_JDE_Work_Order_Trigger
* Author                           : Capgemini
* Date                             : Aug/14/2019
* Requirement/Project Name         : Hill-Rom
* Requirement/Project Description  :  #604 Test Class for 
*                                   1. HRCFSL_LockWorkOrder & HRCFSL_LockWorkOrderQueueable
*                                                                                           
*                                 
* Revison                          : 
***********************************************************************************************/
@isTest
public class HRCFSL_LockWorkOrderTest {
    /*
for  setting up Test Data 
*/
    @testSetup
    static void setupData() {
        Schema.Location locationNew = HRCFSL_TestUtilityClass.createCustomer(true, 'Customer1234');
        ServiceAppointment saNew = HRCFSL_TestUtilityClass.createSAwithWONone(true, 'sa1234', locationNew.Id);
    }
    /*
for testing functionality
*/
    @isTest
    static void testQueueableWOCanceled() {
        String uniqueUserName = 'dataloader' + DateTime.now().getTime() + '@capgemini.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='HRC DataLoader'];
        User u = new User(Alias = 'standt', Email='dataloader@capgemini.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        
        System.runAs(u) 
        {
        
        ServiceAppointment sa = [select id, ParentRecordId from ServiceAppointment limit 1];
        WorkOrder wo=[Select id,RecordType.Name,HRCFSL_Lock_Work_Order__c from WorkOrder Where id=:sa.ParentRecordId Limit 1];
		wo.Status = 'SE';
        update wo;
        List<Id> woList = new List<Id>();
        woList.add(wo.Id);
        HRCFSL_LockWorkOrderQueueable lockWO = new HRCFSL_LockWorkOrderQueueable(woList);
        Test.startTest();
        System.enqueueJob(lockWO);
        HRCFSL_LockWorkOrder.lockWorkOrder(woList);
        Test.stopTest();
        List<WorkOrder> woUpdated=[Select id,RecordType.Name,HRCFSL_Lock_Work_Order__c,StatusCategory,Status from WorkOrder Where id=:sa.ParentRecordId Limit 1];
        System.assertEquals(woUpdated[0].HRCFSL_Lock_Work_Order__c, true);
        System.assertEquals('SE',woUpdated[0].Status); 
        System.assertEquals('Canceled',woUpdated[0].StatusCategory);  
          
        }
    }       
    
    
}