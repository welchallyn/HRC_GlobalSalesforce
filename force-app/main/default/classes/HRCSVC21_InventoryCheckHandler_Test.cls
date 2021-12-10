/*********************************************************************************************************************************************
* Class Name: HRCSVC21_InventoryCheckHandler_Test
* Author: Capgemini
* Date: Dec/02/2021
***************************************************************************************************************/
@isTest
public class HRCSVC21_InventoryCheckHandler_Test implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        String fullJson =  'your Json Response';
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'text/json');
        res.setBody(fullJson);
        res.setStatusCode(200);
        return res;
    }
    @testSetup
    static void setupData() {
        Schema.Location locationNew = HRCFSL_TestUtilityClass.createCustomer(true, 'Customer1234');
        Product2 product1 = HRCFSL_TestUtilityClass.createProduct(true, 'PS73B', 'PAO');
        Product2 product2= HRCFSL_TestUtilityClass.createProduct(true, 'PS73B', 'PAO');
         
    }
    
    @isTest
    static void TestCreateOrderandOLI() {
        try{
            test.startTest(); 
            product2 product1 = [select id, name from product2 where name = 'CENTRELLABED1' limit 1];
           // product2  product2 = [select id, name from product2 where ProductCode = 'ABC' limit 1];
            Test.setMock(HttpCalloutMock.class, new HRCSVC21_InventoryCheckHandler_Test());
            Schema.Location loc = [select id from location where HRCFSL_Customer_ID__c = 'Customer1234'];
            List<Id> orderList= new List<Id>();
            Order__c ord1 = new Order__c(Name='CG',HRCSVC_ERP_Order_Number__c='CG',Proposal_Date__c=system.today(),
                                         HRCSVC_Proposal_Date__c=system.today(),HRCSVC_Ship_To_Location__c=loc.id,HRCSVC_Patient_First_Name__c='John',HRCSVC_Patient_Last_Name__c='Mrak');
            insert ord1;
            orderList.add(ord1.Id);
            
   
            List<Order_Line_Item__c> olisList= new List<Order_Line_Item__c>();
            Order_Line_Item__c oli1 = new Order_Line_Item__c(Order__c=ord1.id,Quantity__c=100,Product__c=product1.id);
            Order_Line_Item__c oli2 = new Order_Line_Item__c(Order__c=ord1.id,Quantity__c=130,Product__c=product1.id);
            
            
            olisList.add(oli1);
            olisList.add(oli2);
            insert olisList;
            HRCSVC21_InventoryCheckHandler.UpdateorderLines(orderList);
            HRCSVC21_InventoryCheckHandler.UpdateorderLines(null);
            
            List<String> oliId= new List<String>();
            oliId.add(oli1.id);
            List<List<String>> oliList= new List<List<String>>();
            oliList.add(oliId);
            HRCSVC21_InventoryCheckHandler.getavailablequantity(oliId);
            oliId.add(oli2.id);
            oliList.add(oliId);
            
            
            
          //  HRCSVC21_InventoryCheckHandler.getavailablequantity(oliId);
            HRCSVC21_InventoryCheckHandler.getavailablequantity(null);
         
            HRCSVC21_InventoryCheckHandler.returnmessage rm = new HRCSVC21_InventoryCheckHandler.returnmessage();
            rm.succerrmsg='';
            
            
            test.stopTest(); 
        }catch(Exception e){
            system.debug('e'+e.getLineNumber()+e.getCause()+e.getStackTraceString());
        }
    }
    
    
}