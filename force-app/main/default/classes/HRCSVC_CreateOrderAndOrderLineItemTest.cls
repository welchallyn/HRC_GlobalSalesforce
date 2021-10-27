/***********************************************************************************************
* Name                             : HRCSVC_CreateOrderAndOrderLineItemTest
* Author                           : Capgemini
* Date                             : Jan/05/2021
* Requirement/Project Name         : Hill-Rom
* Requirement/Project Description  :   Test Class for 
*                                   1. HRCSVC_CreateOrderAndOrderLineItem
*                                                                                           
*                                 
* Revison                          : 
***********************************************************************************************/
@isTest
public class HRCSVC_CreateOrderAndOrderLineItemTest {

  @testSetup
  static void setupData() {
    Schema.Location locationNew = HRCFSL_TestUtilityClass.createCustomer(true, 'Customer1234');
    ServiceTerritory st = HRCFSL_TestUtilityClass.createServiceTerritory(true, 'test12345', 'My Place');
    Product2 product = HRCFSL_TestUtilityClass.createProduct(true, 'PS73B', 'PAO');
    Account acc = HRCFSL_TestUtilityClass.createAccount(true, 'Active');
    Asset asset = HRCFSL_TestUtilityClass.createAsset(true, 'Available', product.id);
    HRCSVC_Customer_Rental__c customerRental = HRCFSL_TestUtilityClass.createCustomerRental(true, product.id, locationNew.Id);
    HRCSVC_ST_Product_Unavailability__c stProductUnavailability = HRCFSL_TestUtilityClass.createSTProductUnavailability(true, product.id, st.id);
    HRCSVC_Standing_PO__c standingPO = HRCFSL_TestUtilityClass.createStandingPO(true, locationNew.Id);
    HRCSVC_Standing_PO_Rule__c standingPORule = HRCFSL_TestUtilityClass.createStandingPORule(true, product.id, 'test', locationNew.Id, standingPO.Id);
    Additional_Account_Info__c additionalAccountInfo = HRCFSL_TestUtilityClass.createAdditionalAccountInfo(true, 'Temp KbAcc', 'test');
    Case caseObj = HRCFSL_TestUtilityClass.createCase(true, 'New', 'Problem - Product Related', 'Onsite Repair');
    HRCSVC_Complaint_Qualification__c complaintQualification = HRCFSL_TestUtilityClass.createComplaintQualification(true, 'Not a Complaint');
    contact con = HRCFSL_TestUtilityClass.createContact(true, 'Temp KbAcc', 'test', 'Anc', 'testanc@test.com');
  }

  @isTest
  static void TestCreateOrderandOLI() {
    Product2 product = new Product2();
    product = [select id, name from product2 where name = 'CENTRELLABED1'
    limit 1];
    Account account = new Account();
    account = [select id, name from account where name = 'Temp KbAcc'
    limit 1];
    contact con = [select id, name from contact limit 1];
    Schema.Location locationNew = [select id from location where HRCFSL_Customer_ID__c = 'Customer1234'];
    order__c ord = new Order__c();
    list < Order_Line_Item__c > ordlineitmlist = new list < Order_Line_Item__c > ();
    Order_Line_Item__c oli = new Order_Line_Item__c();
    test.startTest();
    HRCSVC_CreateOrderAndOrderLineItem.OrderRequestWrapper orderwrap = new HRCSVC_CreateOrderAndOrderLineItem.OrderRequestWrapper();
    oli.Product__c = product?.Id;
    string locationid = locationNew?.Id;
    string accountId = account?.Id;
    boolean isRentalfound = HRCSVC_CreateOrderAndOrderLineItem.FetchRentalOrder(oli, locationid, accountId);
    system.assertEquals(isRentalfound, true);
    string standingPOrulenum = HRCSVC_CreateOrderAndOrderLineItem.FetchOLIStandingPO(oli, locationid, accountId, product);
    system.AssertNotEquals(standingPOrulenum, null);
    string code = HRCSVC_CreateOrderAndOrderLineItem.getSubstitutionCode(product.Id);
    system.assertEquals(code, 'PAO');
    oli.Product__c = null;
    datetime dt = HRCSVC_CreateOrderAndOrderLineItem.getDueDate(oli, ord);
    system.assertEquals(dt, null);
    List < Additional_Account_Info__c > addobj = HRCSVC_CreateOrderAndOrderLineItem.findAdditionalRecordInfo(locationNew);
    system.assertequals(addobj.size(), 0);
    List < sObject > sobjlst = HRCSVC_CreateOrderAndOrderLineItem.fetchLookUpValues('CENTRE', 'Product2', 'HRCSVC_Rental_Offering__c = true AND id not in (select hrcsvc_product__c from HRCSVC_ST_Product_Unavailability__c where hrcsvc_service_territory__c = [ST ID])', locationNew.Id);
    system.assertNotEquals(sobjlst , null);
    product2 prod = (product2) sobjlst[0];
    system.assertEquals(prod.Name , 'CENTRELLABED1');
    sobjlst = HRCSVC_CreateOrderAndOrderLineItem.fetchLookUpValues('Temp', 'Account', 'null', locationNew.Id);
    system.assertNotEquals(sobjlst , null);
    account accnew = (Account)sobjlst[0];
    system.assertEquals(accnew.Name , 'Temp KbAcc');
    Map < String, String > testmap = HRCSVC_CreateOrderAndOrderLineItem.getPickListValuesIntoList('HRCSVC_Service_Activity_Type__c', 'Order_Line_Item__c');
    Account acc = HRCSVC_CreateOrderAndOrderLineItem.checkCustomerEligibility(locationNew);
    sobject obj = HRCSVC_CreateOrderAndOrderLineItem.getRecordById(account.id);
    system.assertNotEquals(obj , null);
    accnew=(Account)obj;
    system.assertEquals(accnew.Name , 'Temp KbAcc');
    oli.Product__c = product?.Id;
    oli.HRCSVC_Service_Activity_Type__c = 'D';
    oli.Quantity__c = 1;
    ordlineitmlist.add(oli);
    ord.HRCSVC_Contact_Source__c = 'Telephone';
    ord.HRCSVC_Patient_First_Name__c = 'test';
    ord.HRCSVC_Patient_Last_Name__c = 'Anchal';
    ord.HRCSVC_Medical_Record_ID__c = 'test1234';
    String result = HRCSVC_CreateOrderAndOrderLineItem.saveOrderandOLIRecord(ordlineitmlist, ord, locationNew, account, con);
    orderwrap = HRCSVC_CreateOrderAndOrderLineItem.checkDupOrderRecord(ordlineitmlist, ord);
    order__c ord1 = new Order__c();
    ord1 = [select id from order__c order by lastmodifieddate desc limit 1];
    list < Order_line_Item__c > orlilistnew = new list < Order_line_Item__c > ();
    string orderid = ord1?.Id;
    orderwrap = HRCSVC_CreateOrderAndOrderLineItem.getOrderAndOrderLineItems(orderid);
    HRCSVC_CreateOrderAndOrderLineItem.createWOByOLI(ordlineitmlist, 'Repair Swap', null);
    List < WorkOrder > wolst = HRCSVC_CreateOrderAndOrderLineItem.getWOAdminBedMove(ordlineitmlist);
    HRCSVC_CreateOrderAndOrderLineItem.createWOByOLI(ordlineitmlist, 'Admin Bed Move', wolst);   
    test.stopTest();
  }
  @isTest
  static void TestgetOrderandOLIitems() {
    Product2 product = new Product2();
    product = [select id, name from product2 where name = 'CENTRELLABED1'
    limit 1];
    Account account = new Account();
    account = [select id, name from account where name = 'Temp KbAcc'
    limit 1];
    contact con = [select id, name from contact limit 1];
    Schema.Location locationNew = [select id from location where HRCFSL_Customer_ID__c = 'Customer1234'];
    order__c ord = new Order__c();
    list < Order_Line_Item__c > ordlineitmlist = new list < Order_Line_Item__c > ();
    Order_Line_Item__c oli = new Order_Line_Item__c();
    test.startTest();
        HRCSVC_CreateOrderAndOrderLineItem.OrderRequestWrapper orderwrap = new HRCSVC_CreateOrderAndOrderLineItem.OrderRequestWrapper();
        oli.Product__c = product?.Id;
        string locationid = locationNew?.Id;
        string accountId = account?.Id;
        oli.Product__c = product?.Id;
        oli.HRCSVC_Service_Activity_Type__c = 'D';
        oli.Quantity__c = 1;
        ordlineitmlist.add(oli);
        ord.HRCSVC_Contact_Source__c = 'Telephone';
        ord.HRCSVC_Patient_First_Name__c = 'test';
        ord.HRCSVC_Patient_Last_Name__c = 'Anchal';
        ord.HRCSVC_Medical_Record_ID__c = 'test1234';
        String result = HRCSVC_CreateOrderAndOrderLineItem.saveOrderandOLIRecord(ordlineitmlist, ord, locationNew, account, con);
        orderwrap = HRCSVC_CreateOrderAndOrderLineItem.checkDupOrderRecord(ordlineitmlist, ord);
        order__c ord1 = new Order__c();
        ord1 = [select id from order__c order by lastmodifieddate desc limit 1];
        list < Order_line_Item__c > orlilistnew = new list < Order_line_Item__c > ();
        string orderid = ord1?.Id;
        orderwrap = HRCSVC_CreateOrderAndOrderLineItem.getOrderAndOrderLineItems(orderid);
        HRCSVC_CreateOrderAndOrderLineItem.createWOByOLI(ordlineitmlist, 'Removal', null);
        HRCSVC_CreateOrderAndOrderLineItem.createWOByOLI(ordlineitmlist, 'Non-Repair Swap', null);
        list<workorder> wolst = HRCSVC_CreateOrderAndOrderLineItem.getWOAdminBedMove(ordlineitmlist);
        boolean results = HRCSVC_CreateOrderAndOrderLineItem.allowAdminComplete(ordlineitmlist);
        system.assertEquals(results, true);
        wolst = HRCSVC_CreateOrderAndOrderLineItem.getWorkOrdersForOLIs(ordlineitmlist);
        system.assertNotEquals(wolst, null);
        HRCSVC_CreateOrderAndOrderLineItem.updateWOs(wolst);
    test.stopTest();
  }

  @isTest
  static void TestgetOrderandOLI() {
    Product2 product = new Product2();
    product = [select id, name from product2 where name = 'CENTRELLABED1'
    limit 1];
    Account account = new Account();
    account = [select id, name from account where name = 'Temp KbAcc'
    limit 1];
    contact con = [select id, name from contact limit 1];
    Schema.Location locationNew = [select id from location where HRCFSL_Customer_ID__c = 'Customer1234'];
    order__c ord = new Order__c();
    list < Order_Line_Item__c > ordlineitmlist = new list < Order_Line_Item__c > ();
    Order_Line_Item__c oli = new Order_Line_Item__c();
    test.startTest();
        HRCSVC_CreateOrderAndOrderLineItem.OrderRequestWrapper orderwrap = new HRCSVC_CreateOrderAndOrderLineItem.OrderRequestWrapper();
        oli.Product__c = product?.Id;
        string locationid = locationNew?.Id;
        string accountId = account?.Id;
        oli.Product__c = product?.Id;
        oli.HRCSVC_Service_Activity_Type__c = 'D';
        oli.Quantity__c = 1;
        ordlineitmlist.add(oli);
        ord.HRCSVC_Contact_Source__c = 'Telephone';
        ord.HRCSVC_Patient_First_Name__c = 'test';
        ord.HRCSVC_Patient_Last_Name__c = 'Anchal';
        ord.HRCSVC_Medical_Record_ID__c = 'test1234';
        String result = HRCSVC_CreateOrderAndOrderLineItem.saveOrderandOLIRecord(ordlineitmlist, ord, locationNew, account, con);
        orderwrap = HRCSVC_CreateOrderAndOrderLineItem.checkDupOrderRecord(ordlineitmlist, ord);
        order__c ord1 = new Order__c();
        ord1 = [select id from order__c order by lastmodifieddate desc limit 1];
        list < Order_line_Item__c > orlilistnew = new list < Order_line_Item__c > ();
        string orderid = ord1?.Id;
        orderwrap = HRCSVC_CreateOrderAndOrderLineItem.getOrderAndOrderLineItems(orderid);
        HRCSVC_CreateOrderAndOrderLineItem.createWOByOLI(ordlineitmlist,'Sheet Change',null);
        HRCSVC_CreateOrderAndOrderLineItem.createWOByOLI(ordlineitmlist,'On-Site Repair',null);
        list<workorder> wolst = HRCSVC_CreateOrderAndOrderLineItem.getWOAdminBedMove(ordlineitmlist);
        boolean results = HRCSVC_CreateOrderAndOrderLineItem.allowAdminComplete(ordlineitmlist);
        system.assertEquals(results, true);
        wolst = HRCSVC_CreateOrderAndOrderLineItem.getWorkOrdersForOLIs(ordlineitmlist);
        system.assertNotEquals(wolst, null);
        HRCSVC_CreateOrderAndOrderLineItem.updateWOs(wolst);
    test.stopTest();
  }
     @isTest
  static void TestMaster() {
      
      Product2 product = new Product2();
    product = [select id, name from product2 where name = 'CENTRELLABED1'
    limit 1];
    Account account = new Account();
    account = [select id, name from account where name = 'Temp KbAcc'
    limit 1];
    contact con = [select id, name from contact limit 1];
    Schema.Location locationNew = [select id from location where HRCFSL_Customer_ID__c = 'Customer1234'];
    order__c ord = new Order__c();
    list < Order_Line_Item__c > ordlineitmlist = new list < Order_Line_Item__c > ();
    Order_Line_Item__c oli = new Order_Line_Item__c();
    test.startTest();      
    string temp = HRCSVC_CreateOrderAndOrderLineItem.setDefaultTeamType();
    HRCSVC_CreateOrderAndOrderLineItem.OrderRequestWrapper orderwrap = new HRCSVC_CreateOrderAndOrderLineItem.OrderRequestWrapper();
    oli.Product__c = product?.Id;
    string locationid = locationNew?.Id;
    string accountId = account?.Id;
    boolean isRentalfound = HRCSVC_CreateOrderAndOrderLineItem.FetchRentalOrder(oli, locationid, accountId);
    system.assertEquals(isRentalfound, true);
    string standingPOrulenum = HRCSVC_CreateOrderAndOrderLineItem.FetchOLIStandingPO(oli, locationid, accountId, product);
    system.AssertNotEquals(standingPOrulenum, null);
    string code = HRCSVC_CreateOrderAndOrderLineItem.getSubstitutionCode(product.Id);
    system.assertEquals(code, 'PAO');
    oli.Product__c = null;
    datetime dt = HRCSVC_CreateOrderAndOrderLineItem.getDueDate(oli, ord);
    system.assertEquals(dt, null);
    List < Additional_Account_Info__c > addobj = HRCSVC_CreateOrderAndOrderLineItem.findAdditionalRecordInfo(locationNew);
    system.assertequals(addobj.size(), 0);
    List < sObject > sobjlst = HRCSVC_CreateOrderAndOrderLineItem.fetchLookUpValues('CENTRE', 'Product2', 'HRCSVC_Rental_Offering__c = true AND id not in (select hrcsvc_product__c from HRCSVC_ST_Product_Unavailability__c where hrcsvc_service_territory__c = [ST ID])', locationNew.Id);
    system.assertNotEquals(sobjlst , null);
    product2 prod = (product2) sobjlst[0];
    system.assertEquals(prod.Name , 'CENTRELLABED1');
    sobjlst = HRCSVC_CreateOrderAndOrderLineItem.fetchLookUpValues('Temp', 'Account', 'null', locationNew.Id);
    system.assertNotEquals(sobjlst , null);
    account accnew = (Account)sobjlst[0];
    system.assertEquals(accnew.Name , 'Temp KbAcc');
    Map < String, String > testmap = HRCSVC_CreateOrderAndOrderLineItem.getPickListValuesIntoList('HRCSVC_Service_Activity_Type__c', 'Order_Line_Item__c');
    Account acc = HRCSVC_CreateOrderAndOrderLineItem.checkCustomerEligibility(locationNew);
    sobject obj = HRCSVC_CreateOrderAndOrderLineItem.getRecordById(account.id);
    system.assertNotEquals(obj , null);
    accnew=(Account)obj;
    system.assertEquals(accnew.Name , 'Temp KbAcc');
    oli.Product__c = product?.Id;
    oli.HRCSVC_Service_Activity_Type__c = 'D';
    oli.Quantity__c = 1;
    ordlineitmlist.add(oli);
    ord.HRCSVC_Contact_Source__c = 'Telephone';
    ord.HRCSVC_Patient_First_Name__c = 'test';
    ord.HRCSVC_Patient_Last_Name__c = 'Anchal';
    ord.HRCSVC_Medical_Record_ID__c = 'test1234';
    //String result = HRCSVC_CreateOrderAndOrderLineItem.saveOrderandOLIRecord(ordlineitmlist, ord, locationNew, account, con);
    orderwrap = HRCSVC_CreateOrderAndOrderLineItem.checkDupOrderRecord(ordlineitmlist, ord);
      HRCSVC_CreateOrderAndOrderLineItem.OrderRequestWrapper objreq = new HRCSVC_CreateOrderAndOrderLineItem.OrderRequestWrapper();
      String result = HRCSVC_CreateOrderAndOrderLineItem.saveOrderandOLIRecord(ordlineitmlist, ord, locationNew, account, con);
      list < Order_line_Item__c > orlilistnew = [select id,Order__c,Order__r.HRCSVC_Ship_To_Location__r.HRCFSL_Service_Territory__c,HRCSVC_Ward_Floor__c,HRCSVC_Ward__c,HRCSVC_Customer_Cost_Center__c,HRCSVC_PO_Number__c , HRCSVC_Product_Name__c , HRCSVC_Asset__c , HRCSVC_Special_Instructions__c , HRCSVC_Start_Date__c , HRCSVC_End_Date__c , HRCSVC_Contact_Name__c from Order_line_Item__c ];
      String tempIdparse =   orlilistnew[0].Id+','+orlilistnew[0].Id;
      List<String> strLst = new List<String>();
      strLst.add(tempIdparse);
      list < Order_line_Item__c > orlilistparsed =  HRCSVC_CreateOrderAndOrderLineItem.parseOrderLineItemId(strLst);
      HRCSVC_CreateOrderAndOrderLineItem.createWOfromOLI(orlilistnew);
      test.stopTest();
      
  }
}