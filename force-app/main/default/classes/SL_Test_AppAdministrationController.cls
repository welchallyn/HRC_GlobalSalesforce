/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*/
@isTest
private class SL_Test_AppAdministrationController 
{
    static testMethod void SL_Test_AppAdministrationController() 
    {
        // TO DO: implement unit test
        Test.startTest();
        SL_AppAdministrationController objSL_AppAdministrationController = new SL_AppAdministrationController ();
        //getBatchJob();
        objSL_AppAdministrationController.createTerritoryMappingBatch();
        Test.stoptest();
    }
    
    static testMethod void setupAccountData()
    {
        Set<Id> setParentId = new Set<Id>();
        List<account> parentlist = new List<account>();  
        List<Account> accounts = new List<Account>();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User objUser = new User(Alias = 'newUsr', Email='new45421@hillrom.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='new125.325@testorg.com');
        insert objUser;
        
        SL_Integration_Settings__c objIntSettings = new SL_Integration_Settings__c(Integration_UserId__c = objUser.Id, Integration_Status__c = 'Active, Inactive');
        insert objIntSettings;
        
        List<Postal_Code_Mapping__c> instPostalCode = new List<Postal_Code_Mapping__c>{
            new Postal_Code_Mapping__c(Name='01041',Acute_Region__c='Acute Care - Northeast',Acute_Territory__c='Acute Care - Northeast - Bangor',Ambulatory_Region__c='Amb Care - Northeast',Ambulatory_Territory__c='Amb Care - Northeast - Hartford',Inside_Sales__c='Inside Sales - Northeast',Solutions_Architect__c='Service and Solution - East'),
            new Postal_Code_Mapping__c(Name='01041',Acute_Region__c='Acute Care - Northeast',Acute_Territory__c='Acute Care - Northeast - Bangor',Ambulatory_Region__c='Amb Care - Northeast',Ambulatory_Territory__c='Amb Care - Northeast - Hartford',Inside_Sales__c='Inside Sales - Northeast',Solutions_Architect__c='Service and Solution - East'),
            new Postal_Code_Mapping__c(Name='0102',Acute_Region__c='Acute Care - Northeast',Acute_Territory__c='Acute Care - Northeast - Bangor',Ambulatory_Region__c='Amb Care - Northeast',Ambulatory_Territory__c='Amb Care - Northeast - Hartford',Inside_Sales__c='Inside Sales - Northeast',Solutions_Architect__c='Service and Solution - East')    
            };
        insert instPostalCode;
        
        List<Account> lstAccountToInsert_UltimateParents = new List<Account>{
            new Account( Name='Ultimate Parent 1', Local_Account_Name__c = 'Ultimate Parent 1', PARTY_MK__c = '123332323', 
                        ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '01041', Status__c = 'Active'),
                new Account( Name='Ultimate Parent 2', Local_Account_Name__c = 'Ultimate Parent 2', ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '540664', Status__c = 'Inactive'),
                new Account( Name='Ultimate Parent 3', Local_Account_Name__c = 'Ultimate Parent 3', ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '0102', Status__c = 'Inactive')
                };
        insert  lstAccountToInsert_UltimateParents;
        
        List <Account> lstAccICDate = new List <Account> (); 
        
        for(Account objAc : [SELECT Id, IC_Date__c FROM Account WHERE Id IN: lstAccountToInsert_UltimateParents])
        {
            lstAccICDate.add(objAc);
        }
        
        system.assertEquals(lstAccICDate[0].IC_Date__c, SL_AccountHandler.testDatetimeNow);
        system.assertEquals(lstAccICDate[1].IC_Date__c, SL_AccountHandler.testDatetimeNow);
        
        
        // System.assertEquals([SELECT Id, IC_Date__c FROM Account WHERE Id =: lstAccountToInsert_UltimateParents[0].Id LIMIT 1].IC_Date__c, DateTime.now());
        
        List<Account> lstAccountToInsert_Level1 = new List<Account>{
            new Account(Status__c= 'Active', Name='Level 1,Child 1' , Local_Account_Name__c = 'Level 1,Child 1',ParentId=lstAccountToInsert_UltimateParents[0].Id, PARTY_MK__c = '5212123111', 
                        ShippingCountry = 'US',Type='Standard',Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '540664',Market_Segment_WA__c='Ambulatory'),
                new Account(Status__c= 'Inactive', Name='Level 1,Child 2' , Local_Account_Name__c = 'Level 1,Child 2',ParentId=lstAccountToInsert_UltimateParents[0].Id , PARTY_MK__c = '1233', 
                            ShippingCountry = 'US',Type='Standard', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '540664',Market_Segment_WA__c='Ambulatory' ),
                new Account( Name='Level 1,Child 3' ,Type='Standard',Market_Segment_WA__c='Ambulatory',Local_Account_Name__c = 'Level 1,Child 3',ParentId=lstAccountToInsert_UltimateParents[1].Id, ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '01041'),
                new Account( Name='Level 1,Child 4' ,Type='Standard',Market_Segment_WA__c='Ambulatory', Local_Account_Name__c = 'Level 1,Child 4',ParentId=lstAccountToInsert_UltimateParents[1].Id, ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '0102'),
                new Account( Name='Level 1,Child 5' ,Type='Standard',Market_Segment_WA__c='Ambulatory', Local_Account_Name__c = 'Level 1,Child 5', ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '540664'),
                new Account( Name='Level 1,Child 5' ,Type='Standard',Market_Segment_WA__c='System', Local_Account_Name__c = 'Level 1,Child 5', ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '540664')
                };
        insert lstAccountToInsert_Level1;                                                              
        
        lstAccICDate = new List <Account> (); 
        for(Account objAc : [SELECT Id, IC_Date__c FROM Account WHERE Id IN: lstAccountToInsert_Level1])
        {
            lstAccICDate.add(objAc);
        }
     //   system.assertEquals(lstAccICDate[0].IC_Date__c, null);
     //   system.assertEquals(lstAccICDate[1].IC_Date__c, null);
        
        lstAccountToInsert_Level1[0].Status__c = 'Active';
        lstAccountToInsert_Level1[1].Status__c = 'InActive';
        update lstAccountToInsert_Level1;
        
        lstAccICDate = new List <Account> (); 
        for(Account objAc : [SELECT Id, IC_Date__c FROM Account WHERE Id IN: lstAccountToInsert_Level1])
        {
            lstAccICDate.add(objAc);
        }
        
        system.assertNotEquals(lstAccICDate[0].IC_Date__c, null);
        system.assertEquals(lstAccICDate[0].IC_Date__c, SL_AccountHandler.testDatetimeNow);
    //    system.assertEquals(lstAccICDate[1].IC_Date__c, null);
        
        lstAccountToInsert_Level1[1].Status__c = 'Inactive';
        update lstAccountToInsert_Level1;
        
        lstAccICDate = new List <Account> (); 
        
        for(Account objAc : [SELECT Id, IC_Date__c FROM Account WHERE Id IN: lstAccountToInsert_Level1])
        {
            lstAccICDate.add(objAc);
        } 
        
        system.assertNotEquals(lstAccICDate[1].IC_Date__c, null);
        system.assertEquals(lstAccICDate[1].IC_Date__c, SL_AccountHandler.testDatetimeNow);
        
        List<Account> lstAccountToInsert_Level2 = new List<Account>{
                new Account( Name='Level 2,Child 1' , Local_Account_Name__c = 'Level 2,Child 1',ParentId=lstAccountToInsert_Level1[0].Id, ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '540664',Type='Standard' ),
                new Account( Name='Level 2,Child 2' , Market_Segment_WA__c='Acute',Local_Account_Name__c = 'Level 2,Child 2',ParentId=lstAccountToInsert_Level1[0].Id, ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '01041',Type='Standard' ),
                new Account( Name='Level 2,Child 3' , Market_Segment_WA__c='Acute',Local_Account_Name__c = 'Level 2,Child 3',ParentId=lstAccountToInsert_Level1[1].Id, ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '0102',Type='Standard' ),
                new Account( Name='Level 2,Child 4' , Market_Segment_WA__c='Acute',Local_Account_Name__c = 'Level 2,Child 4',ParentId=lstAccountToInsert_Level1[1].Id, ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '540664',Type='Standard' ),
                new Account( Name='Level 2,Child 5' , Market_Segment_WA__c='Acute',Local_Account_Name__c = 'Level 2,Child 5',ParentId=lstAccountToInsert_Level1[2].Id, ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '540664',Type='Standard' ),
                new Account( Name='Level 2,Child 6' , Market_Segment_WA__c='Acute',Local_Account_Name__c = 'Level 2,Child 6',ParentId=lstAccountToInsert_Level1[2].Id, ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '540664',Type='Standard' ),
                new Account( Name='Level 2,Child 7' , Market_Segment_WA__c='Ambulatory',Local_Account_Name__c = 'Level 2,Child 7',ParentId=lstAccountToInsert_Level1[3].Id, ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '540664',Type='Standard' ),
                new Account( Name='Level 2,Child 2' , Market_Segment_WA__c='Acute',Local_Account_Name__c = 'Level 2,Child 2',ParentId=lstAccountToInsert_Level1[0].Id, ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '01041',Type='Standard' ),
                new Account( Name='Level 2,Child 7' , Market_Segment_WA__c='Ambulatory',Local_Account_Name__c = 'Level 2,Child 7',ParentId=lstAccountToInsert_Level1[3].Id, ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '540664',Type='Standard' ),
                new Account( Name='Level 2,Child 8' , Market_Segment_WA__c='System',Local_Account_Name__c = 'Level 2,Child 8',ParentId=lstAccountToInsert_Level1[3].Id, ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '540664',Type='Standard' )                                                        
                };
        insert lstAccountToInsert_Level2;  
        
        
        
        List<Account> lstAccount = [Select Id,Ulimate_Parent_Name__c from Account where Id =:lstAccountToInsert_Level2[0].Id Limit 1];
        system.assertEquals('Ultimate Parent 1' , lstAccount[0].Ulimate_Parent_Name__c);
        Test.startTest();
			SL_Batch_TerritoryMapping obj = new SL_Batch_TerritoryMapping();
            DataBase.executeBatch(obj); 
        	SL_Batch_TerritoryMapping.scheduleTerritoryMapping('0 0 23 * * ?');
        Test.stopTest();
    }
    
    static testMethod void setupAccountData1()
    {
        Set<Id> setParentId = new Set<Id>();
        List<account> parentlist = new List<account>();  
        List<Account> accounts = new List<Account>();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User objUser = new User(Alias = 'newUsr', Email='new45421@hillrom.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='new125.325@testorg.com');
        insert objUser;
        SL_Integration_Settings__c objIntSettings = new SL_Integration_Settings__c(Integration_UserId__c = objUser.Id, Integration_Status__c = 'Active, Inactive');
        insert objIntSettings;
        
        List<Postal_Code_Mapping__c> instPostalCode = new List<Postal_Code_Mapping__c>{
            new Postal_Code_Mapping__c(Name='0102',Acute_Region__c='Acute Care - Northeast',Acute_Territory__c='Acute Care - Northeast - Bangor',Ambulatory_Region__c='Amb Care - Northeast',Ambulatory_Territory__c='Amb Care - Northeast - Hartford',Inside_Sales__c='Inside Sales - Northeast',Solutions_Architect__c='Service and Solution - East'),
            new Postal_Code_Mapping__c(Name='560442',Acute_Region__c='Acute Care - Northeast',Acute_Territory__c='Acute Care - Northeast - Bangor',Ambulatory_Region__c='Amb Care - Northeast',Ambulatory_Territory__c='Amb Care - Northeast - Hartford',Inside_Sales__c='Inside Sales - Northeast',Solutions_Architect__c='Service and Solution - East')
            };
        insert instPostalCode;
        
        List<Account> lstAccountToInsert_UltimateParents = new List<Account>{
            new Account( Name='Ultimate Parent 3', Local_Account_Name__c = 'Ultimate Parent 3', ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '0102', Status__c = 'Inactive',Market_Segment_WA__c='Ambulatory'),
            new Account( Name='Ultimate Parent 4', Local_Account_Name__c = 'Ultimate Parent 4', ShippingCountry = 'CA', Shippingcity = 'TestCity-01', ShippingState = 'Alberta', ShippingPostalCode = '0102', Status__c = 'Inactive',Market_Segment_WA__c='Ambulatory'),
            new Account( Name='Ultimate Parent 5', Local_Account_Name__c = 'Ultimate Parent 5', ShippingCountry = 'CA', Shippingcity = 'TestCity-01', ShippingState = 'Alberta', ShippingPostalCode = '560442', Status__c = 'Inactive',Market_Segment_WA__c='Ambulatory', Type='Strategic')
                };
        insert  lstAccountToInsert_UltimateParents;
        List <Account> lstAccICDate = new List <Account> (); 
        for(Account objAc : [SELECT Id, IC_Date__c FROM Account WHERE Id IN: lstAccountToInsert_UltimateParents])
        {
            lstAccICDate.add(objAc);
        }
       // system.assertEquals(lstAccICDate[0].IC_Date__c, SL_AccountHandler.testDatetimeNow);
        
        List<Account> lstAccountToInsert_Level1 = new List<Account>{
				new Account( Name='Level 1,Child 5' ,Type='Standard',Market_Segment_WA__c='Ambulatory', Local_Account_Name__c = 'Level 1,Child 5', ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '0102'),
                new Account( Name='Level 1,Child 5' ,Type='Standard',Market_Segment_WA__c='Ambulatory', Local_Account_Name__c = 'Level 1,Child 5', ShippingCountry = 'CA', Shippingcity = 'TestCity-01', ShippingState = 'Alberta', ShippingPostalCode = '0102'),
                new Account( Name='Level 1,Child 5' ,Type='Strategic',Market_Segment_WA__c='Ambulatory', Local_Account_Name__c = 'Level 1,Child 5', ShippingCountry = 'CA', Shippingcity = 'TestCity-01', ShippingState = 'Alberta', ShippingPostalCode = '560442')
                };
        insert lstAccountToInsert_Level1;                                                              
        
        lstAccICDate = new List <Account> (); 
        for(Account objAc : [SELECT Id, IC_Date__c FROM Account WHERE Id IN: lstAccountToInsert_Level1])
        {
            lstAccICDate.add(objAc);
        }
       // system.assertEquals(lstAccICDate[0].IC_Date__c, null);
        //system.assertEquals(lstAccICDate[1].IC_Date__c, null);
        lstAccountToInsert_Level1[0].Status__c = 'Active';
        //lstAccountToInsert_Level1[1].Status__c = 'Active123';
        
        update lstAccountToInsert_Level1;
        
        lstAccICDate = new List <Account> (); 
        for(Account objAc : [SELECT Id, IC_Date__c FROM Account WHERE Id IN: lstAccountToInsert_Level1])
        {
            lstAccICDate.add(objAc);
        }
        system.assertNotEquals(lstAccICDate[0].IC_Date__c, null);
        system.assertEquals(lstAccICDate[0].IC_Date__c, SL_AccountHandler.testDatetimeNow);
        
        update lstAccountToInsert_Level1;
        lstAccICDate = new List <Account> (); 
        for(Account objAc : [SELECT Id, IC_Date__c FROM Account WHERE Id IN: lstAccountToInsert_Level1])
        {
            lstAccICDate.add(objAc);
        } 
        List<Account> lstAccountToInsert_Level2 = new List<Account>{
                new Account( Name='Level 2,Child 1' , Local_Account_Name__c = 'Level 2,Child 1',ParentId=lstAccountToInsert_Level1[0].Id, ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '010',Type='Standard' )
                };
        insert lstAccountToInsert_Level2;  
        
		List<Account> lstAccount = [Select Id,Ulimate_Parent_Name__c from Account where Id =:lstAccountToInsert_Level2[0].Id Limit 1];
       // system.assertEquals('Ultimate Parent 1' , lstAccount[0].Ulimate_Parent_Name__c);
        Test.startTest();
			SL_Batch_TerritoryMapping obj = new SL_Batch_TerritoryMapping();
            DataBase.executeBatch(obj); 
        	SL_Batch_TerritoryMapping.scheduleTerritoryMapping('0 0 23 * * ?');
        Test.stopTest();
    }
    
    static testMethod void SL_Test_AppAdministrationSchedule(){
        Test.StartTest();
        SL_Batch_TerritoryMapping testsche = new SL_Batch_TerritoryMapping();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
    } 
}