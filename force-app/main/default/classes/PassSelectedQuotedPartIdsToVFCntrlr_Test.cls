/*************************************************************************************************
* Class Name                       : PassSelectedQuotedPartIdsToVFCntrlr_Test
* Author                           : Capgemini
* Date                             : 20/01/2020
* Description                      : Test class for HRCFSL_CreateJSONForServiceReport class. 
*************************************************************************************************/
@isTest
public class PassSelectedQuotedPartIdsToVFCntrlr_Test {
        /*
    for  setting up Test Data 
    */
    @testSetup
    static void setupData() {
        List <HRCFSL_Quoted_Part__c> testListQp = new List<HRCFSL_Quoted_Part__c>();

            Product2 product=new Product2();
            product.Name = 'Test Prod';
            product.Description = 'Test Prod Desc';
            product.ProductCode = 'TESR1';
            insert product;
            Id prod=product.Id;

            Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
                );
            update standardPricebook;

            PricebookEntry pbe = new PricebookEntry(
                Pricebook2Id = standardPricebook.Id,
                Product2Id = prod,
                UnitPrice = 1020,
                IsActive = true
            );
            insert pbe;

            WorkOrder wo=new WorkOrder();
            wo.Pricebook2Id=standardPricebook.Id;
            insert wo;

            
            HRCFSL_Quoted_Part__c testQP = new HRCFSL_Quoted_Part__c();
            testQP.HRCFSL_Product__c=prod;
            testQP.HRCFSL_Work_Order__c=wo.Id;
            testQP.HRCFSL_Quantity__c=1;
            testListQp.add(testQP);
            insert testListQp;
    }
    /*
    for testing functionality
    */
    @isTest static void PassSelectedQuotedTest() {
        // Test data setup.
        List <HRCFSL_Quoted_Part__c> testListQp = [Select Id from HRCFSL_Quoted_Part__c];

        // Perform test.
        Test.startTest();
        Test.setCurrentPage(Page.HRCSVC_Consume_Quoted_Parts);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(testListQp);
        stdSetController.setSelected(testListQp);
        PassSelectedQuotedPartIdsToVFController  obj = new PassSelectedQuotedPartIdsToVFController(stdSetController);   
        Test.stopTest();

        // Verify the test.
        string[] idslist=obj.SelectedQuotedPartIDs;
        System.assertEquals(idslist.size(), testListQp.size(), 'Size should be same');

        //check code coverage.
    }

     
     
}