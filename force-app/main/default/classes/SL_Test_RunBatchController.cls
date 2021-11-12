@isTest
private class SL_Test_RunBatchController 
{
    static testMethod void instRunBatchTest() {
        Test.startTest();
        SL_RunBatchController instRunBatch = new SL_RunBatchController();
        instRunBatch.createTerritoryMappingBatch();
        Test.stopTest();
    }
}