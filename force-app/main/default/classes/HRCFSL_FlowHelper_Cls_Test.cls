/***********************************************************************************************
 * Name                             : HRCFSL_FlowHelper_Cls_Test 
 * Author                           : Capgemini
 * Date                             : 8/28/2019
 * Requirement/Project Name         : Hill-Rom
 * Requirement/Project Description  :  Test Class for FlowHelper Class 
 *                                  
 * Revison                          : 
 ***********************************************************************************************/
@isTest
public class HRCFSL_FlowHelper_Cls_Test {

    @testSetup
    static void setupData() {
        HRCFSL_TestUtilityClass.generateOrgExceptionCusSettingRec();
        // Insert Product
        Product2 pr = new Product2();
        pr.Name = 'Moto - G1';
        pr.isActive = true;
        insert pr;
        
        PriceBook2 customPriceBook = HRCFSL_TestUtilityClass.generatePriceBookRec();
        // Query Standard and Custom Price Books
        Pricebook2 customPriceBookRec = [select Id from Pricebook2 where id =: customPriceBook.Id];
        Id stdPriceBookRecId = Test.getStandardPricebookId();        
        //Create Standard PriceBookEntry
        PriceBookEntry stdPriceBookEntry = new PriceBookEntry();
        stdPriceBookEntry.Product2Id = pr.Id;
        stdPriceBookEntry.Pricebook2Id = stdPriceBookRecId;
        stdPriceBookEntry.UnitPrice = 2000;
        stdPriceBookEntry.IsActive = true;
        stdPriceBookEntry.CurrencyIsoCode = 'USD';
        insert stdPriceBookEntry;
        // Create Custom PriceBookEntry
        PriceBookEntry customPriceBookEntry = new PriceBookEntry();
        customPriceBookEntry.Product2Id = pr.Id;
        customPriceBookEntry.Pricebook2Id = customPriceBookRec.Id;
        customPriceBookEntry.UnitPrice = 5000;
        customPriceBookEntry.IsActive = true;
        insert customPriceBookEntry;

        worktype wtChild=HRCFSL_TestUtilityClass.createWorkTypewithSword(true,'SQ_U','HRCFSL_Capital_Other');
        ServiceTerritory stChild =  HRCFSL_TestUtilityClass.createServiceTerritory(true, 'test12345', 'My Place');
        
        HRCFSL_TestUtilityClass.generateOrgExceptionCusSettingRec();
        HRCFSL_TestUtilityClass.generateAddress();
        List<WorkOrder> listOfWO = new List<WorkOrder>();
        Schema.Location locationNew = HRCFSL_TestUtilityClass.createCustomer(true, 'Customer1307');
        
        for(Integer i= 0; i < 2;i++){
            WorkOrder wo = new WorkOrder();
            wo.HRCFSL_Contact_First_Name__c = 'Test Contact';
            wo.HRCFSL_Contact_Last_Name__c = 'LastName';
            wo.HRCFSL_Contact_Phone__c = '0001001';
            wo.HRCFSL_Contact_Department__c = 'CON';
            wo.HRCFSL_Activity_Type__c = '4'; 
            wo.Status = 'SC';
            wo.HRCFSL_Doc_Type__c = 'SE';
            wo.HRCFSL_Actual_End__c = System.now();
            wo.HRCFSL_PO__c = 'PO123';
            wo.HRCFSL_JDE_ID__c = 'EXT'+Math.random();
            wo.Priority = '1';
            wo.Location = locationNew;
            wo.HRCFSL_Patient_First_Name__c = 'John';
            wo.HRCFSL_Patient_Last_Name__c = 'Doe';
            wo.WorkTypeId = wtChild.ID;
            wo.ServiceTerritoryId = stChild.Id;
            wo.HRCFSL_Signee_Email__c = '';
            wo.HRCFSL_Signee_Name__c = '';
            wo.HRCFSL_Signee_Title__c = '';  
            wo.Pricebook2Id = customPriceBookRec.Id;
            listOfWO.add(wo);
        }
        if(!listOfWO.isEmpty()){
            insert listOfWO;
        }
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrderId = listOfWO[0].Id;
        insert woli;

       
        ProductConsumed pc = new ProductConsumed();
        pc.WorkOrderId = listOfWO[0].Id;
        pc.QuantityConsumed = 2;
        pc.PricebookEntryId = customPriceBookEntry.Id; 
        //pc.PricebookEntryId = stdPriceBookEntry.Id; 
       
        pc.HRCFSL_Disposition_Code__c = 'REP'; 
        insert pc;
         
        // ProductConsumed pc = HRCFSL_TestUtilityClass.createProductConsumed(true, listOfWO[0].Id);
        
        
    }
    
    @isTest
    static void TestWrapper() {   
        List<WorkOrder> listOfWOUpd = [Select Id from WorkOrder ];
        listOfWOUpd[0].ParentWorkOrderId = listOfWOUpd[1].Id;
        
        List < HRCFSL_FlowHelper_Cls.flowInputWrapper > flowWrapList = new List < HRCFSL_FlowHelper_Cls.flowInputWrapper > ();
        HRCFSL_FlowHelper_Cls.flowInputWrapper flowWrap = new HRCFSL_FlowHelper_Cls.flowInputWrapper();
        flowWrap.selectedChildWOId = listOfWOUpd[0].Id;
        flowWrap.ParentWOId = listOfWOUpd[1].Id;
        flowWrapList.add(flowWrap);
        Test.startTest();
        HRCFSL_FlowHelper_Cls.updateRelatedChildRecords(flowWrapList);
        Test.stopTest();
    }
}