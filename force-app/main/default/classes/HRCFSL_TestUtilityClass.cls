/*************************************************************************************************
* Class Name                       : HRCFSL_TestUtilityClass 
* Author                           : Capgemini
* Date                             : 06/21/2019
* Description                      : Test utility for creating dummy records for Apex Test classes.
*************************************************************************************************/
//@isTest
public with sharing class HRCFSL_TestUtilityClass {
    
    /*
* ********************************************************
* This method is test data for create  Custom setting record
* ********************************************************
*/
    public static void generateOrgExceptionCusSettingRec() {
        list < HRCFSL_Org_Exception_Rule__c > settinglst = [select id, name from HRCFSL_Org_Exception_Rule__c where name = 'Test Setting'];
        if (settinglst.isEmpty()) {
            HRCFSL_Org_Exception_Rule__c setting = new HRCFSL_Org_Exception_Rule__c();
            setting.Name = 'Test Setting';
            setting.HRCFSL_Validation_Rule__c = true;
            setting.HRCFSL_Trigger__c = true;
            setting.HRCFSL_Process_Builder__c = true;
            insert setting;
        }
    }
    
    
    /*
* ********************************************************
* This method is test data for create  PriceBook
* ********************************************************
*/
    public static PriceBook2 generatePriceBookRec() {
        PriceBook2 customPriceBook = new PriceBook2();
        list < PriceBook2 > custmPriceBooklst = [select id, name from PriceBook2 where name = 'Custom Pricebook'];
        if (custmPriceBooklst.isEmpty()) {
            customPriceBook = new PriceBook2();
            customPriceBook.Name = 'Custom Pricebook';
            customPriceBook.IsActive = true;
            insert customPriceBook;
        } else {
            customPriceBook = custmPriceBooklst[0];
        }
        return customPriceBook;
    }
    
    /*
* ********************************************************
* This method is test data for create  User
* ********************************************************
*/
    
    public static list < User > createUsers(Boolean doInsert, String pname, integer num_of_users) {
        generateOrgExceptionCusSettingRec();
        Profile pf = [Select Id from Profile where Name =: pname];
        list < user > usrlst = new list < user > ();
        user u = new user();
        for (integer usrnum = 1; usrnum <= num_of_users; usrnum++) {
            u = new user();
            u.FirstName = 'test';
            u.LastName = 'User' + usrnum;
            u.Email = 'testxyz123user' + usrnum + '@capgemini.com';
            u.CompanyName = 'test.com';
            u.Title = 'Test Usr' + usrnum;
            u.Username = 'testxyz123user' + usrnum + '@capgemini.com';
            u.Alias = 'ttusr' + usrnum;
            u.CommunityNickname = 'tst Usr' + usrnum;
            u.TimeZoneSidKey = 'America/Mexico_City';
            u.LocaleSidKey = 'en_US';
            u.EmailEncodingKey = 'ISO-8859-1';
            u.ProfileId = pf.Id;
            u.LanguageLocaleKey = 'en_US';
            usrlst.add(u);
        }
        if (doInsert) {
            insert usrlst;
        }
        return usrlst;
    }
      /*    
* ******************************************************************************    
* This method is test data for create  Work type with vallid Sword object record    
* ******************************************************************************    
*/  
    public static worktype createWorkTypewithSword(Boolean doInsert,String Swordcode,string WTrecordType) { 
        generateOrgExceptionCusSettingRec();    
         list < HRCFSL_SWORD__c > swolst = new list < HRCFSL_SWORD__c > (); 
        swolst = [select name, id, HRCFSL_SWORD_ID__c from HRCFSL_SWORD__c where name =:Swordcode]; 
        HRCFSL_SWORD__c swo = new HRCFSL_SWORD__c();    
        swo.name = Swordcode;   
        swo.HRCFSL_SWORD_ID__c = Swordcode; 
        swo.HRCFSL_Priority_Code__c = '2';  
        if (swolst.isempty()) { 
            insert swo; 
        } else {    
            swo = swolst[0];    
        }   
        list < worktype > wtlst = new list < worktype > ();     
        wtlst = [select name, id, EstimatedDuration, durationtype, HRCFSL_SWORD__c, HRCFSL_Work_Type_Desc__c, HRCFSL_JDE_Id__c from worktype where name = 'SE4'];   
        worktype wt = new worktype();   
        wt.name = Swordcode;    
        wt.EstimatedDuration = 3;   
        wt.durationtype = 'Minutes';    
        wt.HRCFSL_JDE_Id__c = Swordcode;    
        wt.HRCFSL_SWORD__c = swo.Id;    
        wt.HRCFSL_Work_Type_Desc__c = 'Test';   
        wt.HRC_FSL_Work_Class__c = 'Capital';   
        wt.HRCFSL_Record_Type__c =WTrecordType; 
        if(wtlst.size()>0){ 
            wt=wtlst[0];    
        }else  if (doInsert){   
            insert wt;  
        }   
       return wt;   
    }   
    
    /*
* ********************************************************
* This method is test data for create  service resources
* ********************************************************
*/
    public static list < ServiceResource > createServiceResources(Boolean doInsert, list < user > usrlst) {
        generateOrgExceptionCusSettingRec();
        list < ServiceResource > srlst = new list < ServiceResource > ();
        ServiceResource sr = new ServiceResource();
        for (user usr: usrlst) {
            sr = new serviceResource();
            sr.Name = usr.firstname + ' ' + usr.lastname;
            sr.isActive = true;
            sr.RelatedRecordId = usr.id;
            sr.ResourceType = 'T';
            //sr.HRCFSL_JDE_ID__c='test';
            srlst.add(sr);
        }
        if (doInsert) {
            insert srlst;
        }
        return srlst;
    }
    
    /*
* ********************************************************
* This method is test data for create  Asset
* ********************************************************
*/
    public static Asset createAsset(Boolean doInsert) {
        generateOrgExceptionCusSettingRec();
        Asset ast = new Asset();
        ast.Name = 'Test Asset';
        
        if (doInsert) {
            insert ast;
        }
        return ast;
    }
    
    /*
* ********************************************************
* This method is test data for create ProductConsumed
* ********************************************************
*/
    public static ProductConsumed createProductConsumed(Boolean doInsert, String woId) {
        generateOrgExceptionCusSettingRec();
        // Insert Product
        Product2 pr = new Product2();
        pr.Name = 'Moto - G1';
        pr.isActive = true;
        insert pr;
        
        PriceBook2 customPriceBook = generatePriceBookRec();
        // Query Standard and Custom Price Books
        Pricebook2 customPriceBookRec = [select Id from Pricebook2 where id =: customPriceBook.Id];
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        
        // Create Standard PriceBookEntry
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
        ProductConsumed pc = new ProductConsumed();
        pc.WorkOrderId = woId;
        pc.QuantityConsumed = 2;
        pc.PricebookEntryId = customPriceBookEntry.Id; 
        //pc.PricebookEntryId = stdPriceBookEntry.Id; 
       
        pc.HRCFSL_Disposition_Code__c = 'REP'; 
        if (doInsert) {
            insert pc;
        }
        return pc;
    }
    /*
* ********************************************************
* This method is test data for create  Service Territory
* ********************************************************
*/
    public static ServiceTerritory createServiceTerritory(Boolean doInsert, String Externalid, String TerritoryName) {
        generateOrgExceptionCusSettingRec();
        OperatingHours oh = new OperatingHours();
        oh.name = 'India';
        insert Oh;
        ServiceTerritory st = new ServiceTerritory();
        st.name = TerritoryName;
        st.OperatingHoursId = oh.id;
        st.isActive = true;
        st.HRCFSL_External_ID__c = Externalid;
        if (doInsert) {
            insert st;
        }
        return st;
    }
    /*
* ********************************************************
* This method is test data for create  Entitlement records
* ********************************************************
*/
    public static Entitlement createEntitlement(Boolean doInsert, string entname, date startdate, date enddate, String accid) {
        generateOrgExceptionCusSettingRec();
        Entitlement ent = new Entitlement();
        ent.name = entname;
        ent.startdate = startdate;
        ent.enddate = endDate;
        ent.accountid = accid;
        if (doInsert) {
            insert ent;
        }
        return ent;
    }
    /*
* ********************************************************
* This method is test data for create  Location record
* ********************************************************
*/
    public static Schema.Location createCustomer(Boolean doInsert, string externalid) {
        //generateOrgExceptionCusSettingRec();
        Schema.Location loc = new Schema.Location();
        loc.Name = 'TestCust'+Integer.valueof((Math.random() * 1000));
        loc.LocationType = 'Site';
        loc.HRCFSL_Customer_ID__c = externalid;
        loc.HRCFSL_Country__c='US';
        if (doInsert)
            insert loc;
        return loc;
    }
    /*
* ********************************************************
* This method is test data for create  Service report
* ********************************************************
*/
    public static ServiceReport createServiceReport(Boolean doInsert, String saID) {
        generateOrgExceptionCusSettingRec();
        /*ServiceReport report = new ServiceReport();
report.ParentId = saID;
report.IsSigned = false;
insert report;
return report;*/
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;
        List < ContentDocument > documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        //create ContentDocumentLink  record
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = saID;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        ServiceReport sr = new ServiceReport();
        // sr.ContentVersionDocumentId = documents[0].Id ;
        sr.DocumentBody = Blob.valueOf('Test Content');
        sr.DocumentContentType = 'application/pdf';
        sr.DocumentName = 'Test';
        sr.ParentId = saID;
        if (doInsert) {
            insert sr;
        }
        return sr;
    }
    /*
* ************************************************************************
* This method is test data for create  Service appointment with work order
* ************************************************************************
*/
    public static ServiceAppointment createSAwithWorkOrder(Boolean doInsert, String externalid, String locationid) {
        generateOrgExceptionCusSettingRec(); 
        generateAddress();
        list < HRCFSL_SWORD__c > swolst = new list < HRCFSL_SWORD__c > ();
        swolst = [select name, id, HRCFSL_SWORD_ID__c from HRCFSL_SWORD__c where name = 'SE_4'];
        HRCFSL_SWORD__c swo = new HRCFSL_SWORD__c();
        swo.name = 'SE_4';
        swo.HRCFSL_SWORD_ID__c = 'SE_4';
        swo.HRCFSL_Priority_Code__c = '2'; 
        if (swolst.isempty()) {
            insert swo;
        } else {
            swo = swolst[0];
        }
        list < worktype > wtlst = new list < worktype > (); 
        wtlst = [select name, id, EstimatedDuration, durationtype, HRCFSL_SWORD__c, HRCFSL_Work_Type_Desc__c from worktype where HRCFSL_JDE_Id__c = 'SE_4'];
        worktype wt = new worktype();
        wt.name = 'SE2';
        wt.EstimatedDuration = 3;
        wt.durationtype = 'Minutes';
        wt.HRCFSL_JDE_Id__c = 'SE_4';
        wt.HRCFSL_SWORD__c = swo.Id;
        wt.HRCFSL_Work_Type_Desc__c = 'Test';
        wt.HRC_FSL_Work_Class__c = 'Capital'; 
        wt.HRCFSL_Record_Type__c ='HRCFSL_Capital_Other'; //Added RecordType value to fix Work Order RecordType issue
        if (wtlst.isempty()) {
            insert wt;
        } else {
            wt = wtlst[0];
        }
        PriceBook2 customPriceBook = generatePriceBookRec();
        WorkOrder wo = new WorkOrder();
        wo.HRCFSL_Doc_Type__c = 'SE';
        wo.HRCFSL_Activity_Type__c = '4';
        wo.HRCFSL_Actual_End__c = System.now();
        wo.HRCFSL_PO__c = 'PO123'+externalid;
        wo.HRCFSL_JDE_ID__c = externalid;
        wo.Priority = '1';
        
        Schema.Location l = new Schema.Location(HRCFSL_Customer_ID__c = locationid); 
        //Schema.Location l = [SELECT id, hrcfsl_country__c ,HRCFSL_Customer_ID__c FROM Location where id =:locationid limit 1];
        wo.Location = l;
        // wo.HRCFSL_Is_Quote__c = false;
        wo.HRCFSL_Patient_First_Name__c = 'John';
        wo.HRCFSL_Patient_Last_Name__c = 'Doe';
        wo.Pricebook2Id = customPriceBook.Id;
        insert wo;
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrderId = wo.id;
        insert woli;
        ServiceAppointment sa = new ServiceAppointment();
        sa.ParentRecordId = wo.Id;
        sa.HRCFSL_Work_Order__c = wo.Id;
        sa.EarliestStartTime = System.now();
        sa.DueDate = System.now() + 2;
        sa.SchedStartTime = System.now();
        sa.SchedEndTime = system.now() + 2;
        sa.status = 'Awaiting signature';
        //sa.status = 'In progress';
        insert sa;
        return sa;
    }
    /*
* **************************************************************************************
* This method is test data for create multiple Service appointment with work order
* **************************************************************************************
*/
    public static List<ServiceAppointment> createMultipleServiceAppointmentsWithWO(String status,DateTime earliestStartTime,DateTime dueDate,DateTime scheduleStartTime,DateTime scheduleEndTime){
        generateOrgExceptionCusSettingRec();        
        generateAddress();
        List<ServiceAppointment> listOfSA = new List<ServiceAppointment>();
        Schema.Location locationNew = HRCFSL_TestUtilityClass.createCustomer(true, 'Customer1234');
        list < HRCFSL_SWORD__c > swolst = new list < HRCFSL_SWORD__c > ();
        swolst = [select name, id, HRCFSL_SWORD_ID__c from HRCFSL_SWORD__c where name = 'SE_4'];
        HRCFSL_SWORD__c swo = new HRCFSL_SWORD__c();
        swo.name = 'SE_4';
        swo.HRCFSL_SWORD_ID__c = 'SE_4';
        swo.HRCFSL_Priority_Code__c = '2'; 
        if (swolst.isempty()) {
            insert swo;
        } else {
            swo = swolst[0];
        }
        list < worktype > wtlst = new list < worktype > (); 
        wtlst = [select name, id, EstimatedDuration, durationtype, HRCFSL_SWORD__c, HRCFSL_Work_Type_Desc__c, HRCFSL_JDE_Id__c from worktype where name = 'SE4'];
        worktype wt = new worktype();
        wt.name = 'SE2';
        wt.EstimatedDuration = 3;
        wt.durationtype = 'Minutes';
        wt.HRCFSL_JDE_Id__c = 'SE_4';
        wt.HRCFSL_SWORD__c = swo.Id;
        wt.HRCFSL_Work_Type_Desc__c = 'Test';
        wt.HRC_FSL_Work_Class__c = 'Capital';
        wt.HRCFSL_SWORD__c =  swo.ID;
        if (wtlst.isempty()) {
            insert wt;
        } else {
            wt = wtlst[0];
        }
        WorkOrder wo = new WorkOrder();
        wo.HRCFSL_Contact_First_Name__c = 'Test Contact';
        wo.HRCFSL_Contact_Last_Name__c = 'LastName';
        wo.HRCFSL_Contact_Phone__c = '0001001';
        wo.HRCFSL_Contact_Department__c = 'CON';
        wo.HRCFSL_Activity_Type__c = '4'; //value before 20th Jan - M
        wo.Status = 'SC';
        wo.HRCFSL_Doc_Type__c = 'SE'; //value before 20th Jan - SN
        wo.HRCFSL_Actual_End__c = System.now();
        wo.HRCFSL_PO__c = 'PO123';
        wo.HRCFSL_JDE_ID__c = 'EXT'+Math.random();
        wo.Priority = '1';
        wo.Location = locationNew;
        wo.HRCFSL_Patient_First_Name__c = 'John';
        wo.HRCFSL_Patient_Last_Name__c = 'Doe';
        wo.WorkTypeId = wt.ID;
        insert wo;
        WorkOrderLineItem woli = new WorkOrderLineItem();
        woli.WorkOrderId = wo.id;
        insert woli;
        for(Integer i=0; i < 10;i++ ){
            ServiceAppointment sa = new ServiceAppointment();
            sa.Status = status;
            sa.EarliestStartTime = earliestStartTime;
            sa.DueDate = dueDate;
            sa.ParentRecordId = wo.ID;
            sa.SchedStartTime = scheduleStartTime;
            sa.SchedEndTime = scheduleEndTime; 
            sa.HRCFSL_Is_Service_Report_Generated__c = false;
            listOfSA.add(sa);
        }
        if(!listOfSA.isEmpty()){
            insert listOfSA;
            return listOfSA;
        }
        return  new List<ServiceAppointment>();
    }
    
    /*
* **************************************************************************************
* This method is test data for create multiple work orders with default work type
* **************************************************************************************
*/
    public static List<WorkOrder> createWorkOrderWithDefaultWorkType(){
        generateOrgExceptionCusSettingRec();
        generateAddress();
        List<WorkOrder> listOfWO = new List<WorkOrder>();
        Schema.Location locationNew = HRCFSL_TestUtilityClass.createCustomer(true, 'Customer1307');
        list < HRCFSL_SWORD__c > swolst = new list < HRCFSL_SWORD__c > ();
        swolst = [select name, id, HRCFSL_SWORD_ID__c from HRCFSL_SWORD__c where name = 'SE_4'];
        HRCFSL_SWORD__c swo = new HRCFSL_SWORD__c();
        swo.name = 'SE_4';
        swo.HRCFSL_SWORD_ID__c = 'SE_4';
        swo.HRCFSL_Priority_Code__c = '2'; 
        if (swolst.isempty()) {
            insert swo;
        } else {
            swo = swolst[0];
        }
        list < worktype > wtlst = new list < worktype > (); 
        wtlst = [select name, id, EstimatedDuration, durationtype, HRCFSL_SWORD__c, HRCFSL_Work_Type_Desc__c, HRCFSL_JDE_Id__c from worktype where name = 'SE4'];
        worktype wt = new worktype();
        wt.name = 'SE2';
        wt.EstimatedDuration = 3;
        wt.durationtype = 'Minutes';
        wt.HRCFSL_JDE_Id__c = 'SE_4';
        wt.HRCFSL_SWORD__c = swo.Id;
        wt.HRCFSL_Work_Type_Desc__c = 'Test';
        wt.HRC_FSL_Work_Class__c = 'Capital';
        wt.HRCFSL_SWORD__c =  swo.ID;
        if (wtlst.isempty()) {
            insert wt;
        } else {
            wt = wtlst[0];
        }
        for(Integer i= 0; i < 10;i++){
            WorkOrder wo = new WorkOrder();
            wo.HRCFSL_Contact_First_Name__c = 'Test Contact';
            wo.HRCFSL_Contact_Last_Name__c = 'LastName';
            wo.HRCFSL_Contact_Phone__c = '0001001';
            wo.HRCFSL_Contact_Department__c = 'CON';
            wo.HRCFSL_Activity_Type__c = '4'; ////value before 20th Jan - M
            wo.Status = 'SC';
            wo.HRCFSL_Doc_Type__c = 'SE';//value before 20th Jan - SN
            wo.HRCFSL_Actual_End__c = System.now();
            wo.HRCFSL_PO__c = 'PO123';
            wo.HRCFSL_JDE_ID__c = 'EXT'+Math.random();
            wo.Priority = '1';
            wo.Location = locationNew;
            wo.HRCFSL_Patient_First_Name__c = 'John';
            wo.HRCFSL_Patient_Last_Name__c = 'Doe';
            wo.WorkTypeId = wt.ID;
            listOfWO.add(wo);
        }
        if(!listOfWO.isEmpty()){
            insert listOfWO;
            return listOfWO;
        }
        return new List<WorkOrder>();
    }
    
    /*
creatADress method:
1. check location with us, if it's there or not, generate or not
2. generate address method
*/
    
    /*
* ********************************************************
* This method is test data for create Address
* Added as a dependency for SLA management class
* Added on 21st Jan 2020
* ********************************************************
*/
    public static void generateAddress() {
        List<Schema.Address> addresses = 
            [SELECT id, latitude, longitude, parent.hrcfsl_country__c, timezone, parentid, parent.timezone 
             FROM Address 
             where parent.hrcfsl_country__c = 'US'];
        if (addresses.isEmpty()) {
            List<Schema.Location> locations = 
                [SELECT id, hrcfsl_country__c 
                 FROM Location 
                 where hrcfsl_country__c = 'US'];
            if(locations.isEmpty()){
                Schema.Location locationNew = HRCFSL_TestUtilityClass.createCustomer(true, 'Customer9063'); 
            }
            locations = 
                [SELECT Id, hrcfsl_country__c 
                 FROM Location 
                 where hrcfsl_country__c = 'US'];
            
            Schema.Address addr=new Schema.Address();
            addr.parentid=locations[0].Id;
            
            
            insert addr;
        }
    }
    
    /*
* ********************************************************
* This method is test data for creating Product
* Added on 22nd Jan 2021
* ********************************************************
*/
    public static Product2 createProduct(Boolean doInsert, String productCode, String jdeCatgoryCode) {
        Product2 product = new Product2();
        product.Name = 'CENTRELLABED1';
        product.ProductCode = productCode;
        product.IsActive = true;
        product.Family = 'Centrella';
        product.CurrencyIsoCode = 'USD';
        product.Package_Code__c = 'CNT-PAK355';
        product.HRCFSL_Serialized__c = false;
        product.HRCSVC_Rental_Offering__c = true;
        product.HRCSVC_JDE_Category_Code_39__c = jdeCatgoryCode;
            if(doInsert){
              insert product;
            }
        return product;
    }
    /*
* ********************************************************
* This method is test data for creating Account
* Added on 22nd Jan 2021
* ********************************************************
*/
    public static Account createAccount(Boolean doInsert, String status) {
        Account account = new Account();
        account.Name = 'Temp KbAcc';
        account.recordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Facility').getRecordTypeId();
        account.Account_Type__c = 'Prospect';
        account.Status__c = status;
        account.Local_Account_Name__c = 'Temp KbAcc';
            if(doInsert){
              insert account;
            }
        return account;
    }
    /*
* ********************************************************
* This method is test data for creating Asset
* Added on 22nd Jan 2021
* ********************************************************
*/
    public static Asset createAsset(Boolean doInsert, String Status ,Id productId) {
        Account account = new Account();
        account = [select id,name from account where name='Temp KbAcc'];
            if(account==null){
                account = createAccount(true,'Active'); 
            }
        Product2 product = new Product2();
        product = [select id,name from product2 where Id=:productId];
            if(product==null){
                product = createProduct(true,'PS73B','PAO'); 
            }
        Asset ast= new Asset();
        ast.AccountId = account.Id;
        ast.Product2Id = product.Id;
        ast.IsCompetitorProduct = false;
        ast.CurrencyIsoCode = 'USD';
        ast.Name = 'HRP004115515';
        ast.SerialNumber = 'HRP004115515';
        ast.Status = Status;
        ast.Description = 'We are testing';
        ast.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('HRC Service Asset').getRecordTypeId();
        ast.HRCFSL_Active__c = true;
        ast.HRCFSL_Country__c = 'ES';
        ast.HRCFSL_Customer__c = '90440';
        ast.HRCFSL_Eq_Class__c = 'N';
        ast.HRCFSL_Next_PM_DT__c = Date.newInstance(2022,01,13);
        ast.HRCFSL_Product_Family__c = 'CC01';
        ast.HRCFSL_Second_Item__c = 'E1270A1001001';
        ast.HRCFSL_Sh_Item__c = 1423109.0;
        ast.HRCFSL_Asset_Status__c = 'SS';
        ast.HRCFSL_Number_Open_WOs__c = 169.0;
        ast.HRCFSL_Real_Product_Family__c = 'Test 497';
        ast.HRCSVC_Last_PM_Date__c = Date.newInstance(2020,10,09);
        ast.HRCSVC_Asset_Category__c = 'Exchange';
            if(doInsert){
                insert ast;
            }        
        return ast;
    }
    
    /*
* ********************************************************
* This method is test data for creating Customer Rental
* Added on 22nd Jan 2021
* ********************************************************
*/
    public static HRCSVC_Customer_Rental__c createCustomerRental(Boolean doInsert, id productid,id locationid) {
        Schema.Location locationNew = [select id from location where id=:locationid];
            if(locationnew==null){
                locationNew= createCustomer(true, 'Customer0619');
            }
        Product2 product = new Product2();
        product = [select id,name from product2 where id=:productid order by lastmodifieddate desc ];
            if(product==null){
                product = createProduct(true,'PS73B','PAO'); 
            }
        HRCSVC_Customer_Rental__c hrcsvc_customer_rental = new HRCSVC_Customer_Rental__c();
        hrcsvc_customer_rental.Name = 'CR-1';
        hrcsvc_customer_rental.CurrencyIsoCode = 'USD';
        hrcsvc_customer_rental.HRCSVC_Product__c = product.Id;
        hrcsvc_customer_rental.HRCSVC_Location__c = locationNew.Id;
            if(doInsert){
                insert hrcsvc_customer_rental;
            }
        return hrcsvc_customer_rental;
    }
    /*
* ********************************************************
* This method is test data for creating ST Product Unavailability
* Added on 22nd Jan 2021
* ********************************************************
*/
    public static HRCSVC_ST_Product_Unavailability__c createSTProductUnavailability(Boolean doInsert, id productid,id stid) {
        
        ServiceTerritory st = [select id from ServiceTerritory where id=:stid];
            if(st==null){
                st= createServiceTerritory(true, 'test12345', 'My Place');
            }
        Product2 product1 = new Product2();
        product1 = [select id,name from product2 where id=:productid];
            if(product1==null){
                product1 = createProduct(true,'PS73B','PAO'); 
            }
        HRCSVC_ST_Product_Unavailability__c hrcsvc_st_product_unavailability = new HRCSVC_ST_Product_Unavailability__c();
        hrcsvc_st_product_unavailability.Name = 'STP-1';
        hrcsvc_st_product_unavailability.CurrencyIsoCode = 'USD';
        hrcsvc_st_product_unavailability.HRCSVC_Product__c = product1.Id;
        hrcsvc_st_product_unavailability.HRCSVC_Service_Territory__c=st.id;
            if(doInsert){
                insert hrcsvc_st_product_unavailability;
            }        
        return hrcsvc_st_product_unavailability;
    }
    
    /*
* ********************************************************
* This method is test data for creating Standing PO
* Added on 22nd Jan 2021
* ********************************************************
*/
    public static HRCSVC_Standing_PO__c createStandingPO(Boolean doInsert,Id Locationid) {
        Schema.Location locationNew = [select id from location where id=:locationid];
            if(locationnew==null){
                locationNew= createCustomer(true, 'Customer0808');
            }
        HRCSVC_Standing_PO__c hrcsvc_standing_po = new HRCSVC_Standing_PO__c();
        hrcsvc_standing_po.Name = 'PO-1';
        hrcsvc_standing_po.CurrencyIsoCode = 'USD';
        hrcsvc_standing_po.HRCSVC_Location__c=locationNew.Id;
            if(doInsert){
                insert hrcsvc_standing_po;
            }       
        return hrcsvc_standing_po;
    }
    /*

* ********************************************************
* This method is test data for creating Standing PO Rule
* Added on 22nd Jan 2021
* ********************************************************
*/
    public static HRCSVC_Standing_PO_Rule__c createStandingPORule(Boolean doInsert, id productid, string wardname,id Locationid,id standingpoid) {
        Schema.Location locationNew = [select id from location where id=:locationid];
        if(locationnew==null){
            locationNew= createCustomer(true, 'Customer2304');
        }
        HRCSVC_Standing_PO__c standingpoObj = [select id from HRCSVC_Standing_PO__c where id=:standingpoid];
        if(standingpoObj==null){
            standingpoObj= createStandingPO(true,locationNew.id);
        }
      
        Product2 product3 = new Product2();
        product3 = [select id,name from product2 where id=:productid];
            if(product3==null){
                product3 = createProduct(true,'PS73B','PAO'); 
            }
        HRCFSL_Ward__c ward1 = new HRCFSL_Ward__c();
        ward1.Name = wardname;
        ward1.HRCFSL_Location__c=locationNew.id;
        insert ward1;
        HRCSVC_Standing_PO_Rule__c hrcsvc_standing_po_rule = new HRCSVC_Standing_PO_Rule__c();
        hrcsvc_standing_po_rule.Name = 'PO Rule-1';
        hrcsvc_standing_po_rule.CurrencyIsoCode = 'USD';
        hrcsvc_standing_po_rule.HRCSVC_Product__c = product3.Id;
        hrcsvc_standing_po_rule.HRCSVC_Item_Class__c = '1';
        hrcsvc_standing_po_rule.HRCSVC_Agreement_Number__c = '123';
        hrcsvc_standing_po_rule.HRCSVC_Ward__c = ward1.Id;
        hrcsvc_standing_po_rule.HRCSVC_Ward_Text__c = 'abcd';
        hrcsvc_standing_po_rule.HRCSVC_Valid_From__c = Date.newInstance(2020,12,01);
        hrcsvc_standing_po_rule.HRCSVC_Valid_To__c = Date.newInstance(2021,12,31);
        hrcsvc_standing_po_rule.HRCSVC_Standing_PO__c=standingpoObj.id;
            if(doInsert){
                insert hrcsvc_standing_po_rule;
            }
        return hrcsvc_standing_po_rule;
    }
    
    /*
* ********************************************************
* This method is test data for creating Additional Account Info
* Added on 22nd Jan 2021
* ********************************************************
*/
    public static Additional_Account_Info__c createAdditionalAccountInfo(Boolean doInsert, String Accountname, String accountProtocol) {
        Account account = new Account();
        account = [select id,name from account where name=:Accountname];
            if(account==null){
                account = createAccount(true,'Active'); 
            }
        Additional_Account_Info__c additional_account_info = new Additional_Account_Info__c();
        additional_account_info.Name = 'William Osler Account Protocol - Rental';
        additional_account_info.CurrencyIsoCode = 'USD';
        additional_account_info.Account__c = account.Id;
        additional_account_info.Acute_Customer__c = false;
        additional_account_info.HRCSVC_Account_Protocol__c = accountProtocol;
        additional_account_info.HRCSVC_Protocol_Category__c = 'Rental';
            if(doInsert){
                insert additional_account_info;
            }
       
        return additional_account_info;
    }
    /*
* ********************************************************
* This method is test data for creating Case
* Added on 22nd Jan 2021
* ********************************************************
*/
    public static Case createCase(Boolean doInsert, String Status, String type, String subTypes) {
       
        Product2 product= new Product2();
        product = [select id,name from product2 where name='CENTRELLABED1'];
            if(product==null){
                product = createProduct(true,'PS73B','PAO'); 
            }
        Asset assetObj = new Asset();
        assetObj = [select id,name from Asset where name='HRP004115515'];
            if(assetObj==null){
                assetObj = createAsset(true,'ST',product.Id);
            }
        Case caseObj = new Case();
        caseObj.AssetId = assetObj.Id;
        caseObj.ProductId = product.Id;
        caseObj.Type = type;
        caseObj.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Factory Repair Depot').getRecordTypeId();
        caseObj.Status = Status;
        caseObj.Reason = 'New';
        caseObj.Origin = 'Email';
        caseObj.IsVisibleInSelfService = false;
        caseObj.Subject = 'rete';
        caseObj.Priority = 'Medium';
        caseObj.Description = 'rete';
        caseObj.IsEscalated = false;
        caseObj.CurrencyIsoCode = 'USD';
        caseObj.IsSelfServiceClosed = false;
        caseObj.IsStopped = false;
        caseObj.Is_Email_To_Case__c = false;
        caseObj.Lead_Created__c = false;
        caseObj.HRCSVC_Email_Case_Contacts__c = false;
        caseObj.HRCSVC_Close_Child_Cases__c = false;
        caseObj.HRCSVC_Send_Email_Notifications__c = false;
        caseObj.HRCSVC_Protocol_Category__c = 'Depot';
        caseObj.HRCSVC_Is_Complain_Qualification_Exist__c = true;
        caseObj.HRCSVC_Prevent_Case_Close__c = false;
        caseObj.HRCSVC_Cancel_Child_Case__c = false;
        caseObj.HRCSVC_Cancel_Work_Orders__c = false;
        caseObj.HRCSVC_CQ_Resolution_Status__c = 'Resolved';
        caseObj.HRCSVC_Send_Email_Notifications_Picklist__c = 'No';
        caseObj.HRCSVC_Subtypes__c = subTypes;
        caseObj.HRCSVC_Date_Time_Individual_Was_Assigned__c = DateTime.newInstance(2021,1,15,13,807,48447);
            if(doInsert){
                insert caseObj;
            }
        
        return caseObj;
    }
    /*
* ********************************************************
* This method is test data for creating Complaint Qualification
* Added on 22nd Jan 2021
* ********************************************************
*/
    public static HRCSVC_Complaint_Qualification__c createComplaintQualification(Boolean doInsert, String status) {
        Product2 product= new Product2();
        product = [select id,name from product2 where name='CENTRELLABED1'];
            if(product==null){
                product = createProduct(true,'PS73B','PAO'); 
            }
        Asset assetObj = new Asset();
        assetObj = [select id,name from Asset where name='HRP004115515'];
            if(assetObj==null){
                assetObj = createAsset(true,'ST',product.id);
            }
        Case caseObj = new case();
        caseObj = [select id,subject from case where subject='rete'];
            if(caseObj==null){
                caseObj = createCase(true,'New','Problem - Product Related','Onsite Repair');
            }
        HRCSVC_Complaint_Qualification__c hrcsvc_complaint_qualification = new HRCSVC_Complaint_Qualification__c();
        hrcsvc_complaint_qualification.CurrencyIsoCode = 'USD';
        hrcsvc_complaint_qualification.HRCSVC_Aware_Date__c = Date.newInstance(2021,01,19);
        hrcsvc_complaint_qualification.HRCSVC_Injury_or_Death__c = 'No';
        hrcsvc_complaint_qualification.HRCSVC_Device_Life_Override__c = 'No';
        hrcsvc_complaint_qualification.HRCSVC_Design_Life_Override_Justificatn__c = 'None';
        hrcsvc_complaint_qualification.HRCSVC_Status__c = status;
        hrcsvc_complaint_qualification.HRCSVC_Condition__c = 'None';
        hrcsvc_complaint_qualification.HRCSVC_Test_performed_per_service_manual__c = 'Functional';
        hrcsvc_complaint_qualification.HRCSVC_Case__c = caseObj.Id;
        hrcsvc_complaint_qualification.HRCSVC_Source_Of_Complaint__c = 'Customer';
        hrcsvc_complaint_qualification.HRCSVC_Asset__c = assetObj.Id;
        hrcsvc_complaint_qualification.HRCSVC_Existing_CQ_with_case__c = true;
        hrcsvc_complaint_qualification.HRCSVC_Device_Message_Alert__c = 'Unknown';
        hrcsvc_complaint_qualification.HRCSVC_Device_Used_On_With_Individual__c = 'Unknown';
        hrcsvc_complaint_qualification.HRCSVC_Resolution_Complete__c = true;
            if(doInsert){
                insert hrcsvc_complaint_qualification;
            }       
        return hrcsvc_complaint_qualification;
    }

      /*
* ********************************************************
* This method is test data for creating contact
* Added on 25th Jan 2021
* ********************************************************
*/
public static contact createContact(Boolean doInsert,String Accountname, String firstname , String lastname , String Emailtest) {
    Account account = new Account();
    account = [select id,name from account where name=:Accountname];
        if(account==null){
            account = createAccount(true,'Active'); 
        }
    Contact contact = new Contact();
    contact.AccountId = account.Id;
    contact.LastName = lastname;
    contact.FirstName = firstname;
   // contact.RecordTypeId = '012E00000002Jl8IAE';
    contact.Email = Emailtest;
    contact.LeadSource = 'Trade Show';
    contact.CurrencyIsoCode = 'USD';
    contact.HasOptedOutOfEmail = false;
    contact.DoNotCall = false;
    contact.Contact_Type__c = 'Prospect';   
    contact.Active__c = 'Active';
        if(doInsert){
            insert contact;
        }
    return contact;
}

public static ServiceAppointment createSAwithWOInPrg(Boolean doInsert, String externalid, String locationid) {
    generateOrgExceptionCusSettingRec(); 
    generateAddress();
    list < HRCFSL_SWORD__c > swolst = new list < HRCFSL_SWORD__c > ();
    swolst = [select name, id, HRCFSL_SWORD_ID__c from HRCFSL_SWORD__c where name = 'SE_4'];
    HRCFSL_SWORD__c swo = new HRCFSL_SWORD__c();
    swo.name = 'SE_4';
    swo.HRCFSL_SWORD_ID__c = 'SE_4';
    swo.HRCFSL_Priority_Code__c = '2'; 
    if (swolst.isempty()) {
        insert swo;
    } else {
        swo = swolst[0];
    }
    list < worktype > wtlst = new list < worktype > (); 
    wtlst = [select name, id, EstimatedDuration, durationtype, HRCFSL_SWORD__c, HRCFSL_Work_Type_Desc__c, HRCFSL_JDE_Id__c from worktype where name = 'SE4'];
    worktype wt = new worktype();
    wt.name = 'SE2';
    wt.EstimatedDuration = 3;
    wt.durationtype = 'Minutes';
    wt.HRCFSL_JDE_Id__c = 'SE_4';
    wt.HRCFSL_SWORD__c = swo.Id;
    wt.HRCFSL_Work_Type_Desc__c = 'Test';
    wt.HRC_FSL_Work_Class__c = 'Capital'; 
    wt.HRCFSL_Record_Type__c ='HRCFSL_Capital_Other'; //Added RecordType value to fix Work Order RecordType issue
    if (wtlst.isempty()) {
        insert wt;
    } else {
        wt = wtlst[0];
    }
    PriceBook2 customPriceBook = generatePriceBookRec();
    WorkOrder wo = new WorkOrder();
    wo.HRCFSL_Doc_Type__c = 'SE';
    wo.HRCFSL_Activity_Type__c = '4';
    wo.HRCFSL_Actual_End__c = System.now();
    wo.HRCFSL_PO__c = 'PO123';
    wo.HRCFSL_JDE_ID__c = externalid;
    wo.Priority = '1';
    
    //Schema.Location l = new Schema.Location(HRCFSL_Customer_ID__c = locationid); 
    Schema.Location l = [SELECT id, hrcfsl_country__c ,HRCFSL_Customer_ID__c FROM Location where id =:locationid limit 1];
    wo.Location = l;
    // wo.HRCFSL_Is_Quote__c = false;
    wo.HRCFSL_Patient_First_Name__c = 'John';
    wo.HRCFSL_Patient_Last_Name__c = 'Doe';
    wo.Pricebook2Id = customPriceBook.Id;
    insert wo;
    WorkOrderLineItem woli = new WorkOrderLineItem();
    woli.WorkOrderId = wo.id;
    insert woli;
    ServiceAppointment sa = new ServiceAppointment();
    sa.ParentRecordId = wo.Id;
    sa.HRCFSL_Work_Order__c = wo.Id;
    sa.EarliestStartTime = System.now();
    sa.DueDate = System.now() + 2;
    sa.SchedStartTime = System.now();
    sa.SchedEndTime = system.now() + 2;
    //sa.status = 'Awaiting signature';
    sa.status = 'In progress';
    insert sa;
    return sa;
}

public static ServiceAppointment createSAwithWONone(Boolean doInsert, String externalid, String locationid) {
    generateOrgExceptionCusSettingRec(); 
    generateAddress();
    list < HRCFSL_SWORD__c > swolst = new list < HRCFSL_SWORD__c > ();
    swolst = [select name, id, HRCFSL_SWORD_ID__c from HRCFSL_SWORD__c where name = 'SE_4'];
    HRCFSL_SWORD__c swo = new HRCFSL_SWORD__c();
    swo.name = 'SE_4';
    swo.HRCFSL_SWORD_ID__c = 'SE_4';
    swo.HRCFSL_Priority_Code__c = '2'; 
    if (swolst.isempty()) {
        insert swo;
    } else {
        swo = swolst[0];
    }
    list < worktype > wtlst = new list < worktype > (); 
    wtlst = [select name, id, EstimatedDuration, durationtype, HRCFSL_SWORD__c, HRCFSL_Work_Type_Desc__c, HRCFSL_JDE_Id__c from worktype where name = 'SE4'];
    worktype wt = new worktype();
    wt.name = 'SE2';
    wt.EstimatedDuration = 3;
    wt.durationtype = 'Minutes';
    wt.HRCFSL_JDE_Id__c = 'SE_4';
    wt.HRCFSL_SWORD__c = swo.Id;
    wt.HRCFSL_Work_Type_Desc__c = 'Test';
    wt.HRC_FSL_Work_Class__c = 'Capital'; 
    wt.HRCFSL_Record_Type__c ='HRCFSL_Capital_Other'; //Added RecordType value to fix Work Order RecordType issue
    if (wtlst.isempty()) {
        insert wt;
    } else {
        wt = wtlst[0];
    }
    PriceBook2 customPriceBook = generatePriceBookRec();
    WorkOrder wo = new WorkOrder();
    wo.HRCFSL_Doc_Type__c = 'SE';
    wo.HRCFSL_Activity_Type__c = '4';
    wo.HRCFSL_Actual_End__c = System.now();
    wo.HRCFSL_PO__c = 'PO123';
    wo.HRCFSL_JDE_ID__c = externalid;
    wo.Priority = '1';
    
    //Schema.Location l = new Schema.Location(HRCFSL_Customer_ID__c = locationid); 
    Schema.Location l = [SELECT id, hrcfsl_country__c ,HRCFSL_Customer_ID__c FROM Location where id =:locationid limit 1];
    wo.Location = l;
    // wo.HRCFSL_Is_Quote__c = false;
    wo.HRCFSL_Patient_First_Name__c = 'John';
    wo.HRCFSL_Patient_Last_Name__c = 'Doe';
    wo.Pricebook2Id = customPriceBook.Id;
    insert wo;
    WorkOrderLineItem woli = new WorkOrderLineItem();
    woli.WorkOrderId = wo.id;
    insert woli;
    ServiceAppointment sa = new ServiceAppointment();
    sa.ParentRecordId = wo.Id;
    sa.HRCFSL_Work_Order__c = wo.Id;
    sa.EarliestStartTime = System.now();
    sa.DueDate = System.now() + 2;
    sa.SchedStartTime = System.now();
    sa.SchedEndTime = system.now() + 2;
    //sa.status = 'Awaiting signature';
    sa.status = 'None';
    insert sa;
    return sa;
}
}