/*************************************************************************************************
* Class Name                       : HRCSVC_getAssetDetails_Test
* Author                           : Capgemini
* Date                             : 20/01/2020
* Description                      : Test class for HRCSVC_getAssetDetails class. 
*************************************************************************************************/
@isTest
public class HRCSVC_getAssetDetails_Test {
    /*
for  setting up Test Data 
*/
@testSetup
static void setupData() {
    //List<WorkOrder> wos=HRCSVC_TestUtilityClass.createWOs(1,true);
    WorkOrder wo=new WorkOrder();
    insert wo;
}
/*
for testing functionality
*/
    @isTest static void TestretrieveWorkOrders() {
        // Test data setup.
        List<WorkOrder> testwos = [ SELECT Id 
                                    FROM WorkOrder 
                                    WHERE  MaintenancePlan.Id!=null
                                    ORDER BY HRCFSL_Next_PM_DT__c ASC ]; 
        
        // Perform test.
        Test.startTest();
        List<WorkOrder> result = HRCSVC_getAssetDetails.retrieveWorkOrders();
        Test.stopTest();

        // Verify the test.
        System.assertEquals(testwos.size(), result.size(), 'Size should be same');

        //check code coverage.
}

}