/*******************************************************************************************************
* Name                             : HRCFSL_Build_Integration_Message_Test 
* Author                           : Capgemini
* Date                             : Sept/8/2020
* Requirement/Project Name         : Hill-Rom
* Requirement/Project Description  : 1.test class for HRCFSL_Build_Integration_Message class
* Revison                          :
/*******************************************************************************************************/
@isTest
public class HRCFSL_Build_Integration_Message_Test {
    @testSetUp
    public static void testDataCreation(){
        //Create Asset
        Asset createAsset = HRCFSL_TestUtilityClass.createAsset(true);
        createAsset.Name = '234567';
        createAsset.SerialNumber = '234567';
        createAsset.HRCFSL_Model_Description__c = 'Text Asset';
        createAsset.HRCFSL_Next_PM_DT__c = System.today();
        update createAsset;
        //Create WorkOrder
        List<WorkOrder> listWorkOrder = HRCFSL_TestUtilityClass.createWorkOrderWithDefaultWorkType();
        WorkOrder newWorkOrder = listWorkOrder[0];
        newWorkOrder.AssetId = createAsset.Id;
        update newWorkOrder;
        
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrderId = newWorkOrder.id;
        insert woli;
        
        HRCFSL_Inspection_Step__c inspectionTemplate = new HRCFSL_Inspection_Step__c();
        inspectionTemplate.Name = 'Test Template';
        inspectionTemplate.HRCFSL_Work_Order__c = newWorkOrder.Id;
        inspectionTemplate.HRCFSL_Visited__c = true;
        inspectionTemplate.HRCFSL_Sequence__c = 1;
        insert inspectionTemplate;
        
    }
    @isTest
    public static void testGetMessage(){
        list<workorder> listWorkorder = [Select id from workorder limit 1];
        list<Asset> listAsset = [Select id from Asset limit 1];
        
        test.startTest();
        HRCFSL_Build_Integration_Message bim = new HRCFSL_Build_Integration_Message(new list<Id>{listWorkorder[0].ID});
        bim.getMessages();
        bim.getChildMessages();
        test.stopTest();        
    }
}