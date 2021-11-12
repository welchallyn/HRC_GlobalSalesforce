/**
 * @File Name          : SL_RunBatchController_test.cls
 * @Description        : 
 * @Author             : Capgemini
 * @Group              : 
 * @Last Modified By   : Capgemini
 * @Last Modified On   : 03/06/2020, 4:10:35 PM
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    03/06/2020   Capgemini     Initial Version
*/
@isTest
private  class SL_RunBatchController_test {
   
    @IsTest
    static void TestPositivecase(){        
        SL_RunBatchController sl=new SL_RunBatchController();
        sl.createTerritoryMappingBatch();        
    } 
    
    @IsTest
    static void TestSL_Batch_TerritoryMapping(){        
        SL_Batch_TerritoryMapping.scheduleTerritoryMapping('0 0 23 * * ?');    
        SL_Batch_TerritoryMapping sl=new SL_Batch_TerritoryMapping();
        sl.execute(null); 
   } 
     
    @TestSetup
    static void makeData(){
        List <Account> lstInsertedAcc = new List <Account> (); 
        Id AccountRecordTypeId;
        ID AccountRecordTypeVarId;
        // Fetching the Customer RecordTypeId
            for (RecordType objRecordType : [SELECT Id FROM RecordType WHERE DeveloperName ='Customer_WA' AND sobjecttype='Account' LIMIT 1]){
                AccountRecordTypeId = objRecordType.Id;
            }
        // Fetching the Facilty RecordTypeId
            for (RecordType objRecordTypeVar : [SELECT Id FROM RecordType WHERE DeveloperName='Facility' AND sobjecttype='Account' LIMIT 1]){
                AccountRecordTypeVarId = objRecordTypeVar.Id;
            }
        
        // Insert Account
        List <Account> lstAccount = new List<Account>{new Account(Name = 'Test Account',COT_1__c = 'UN',Billingcity = 'TestCity-01',BillingPostalCode = '005441',BillingState = 'Alaska',ShippingPostalCode = '005441',BillingCountry='US',ShippingCountry = 'US',Type = 'Acute',Market_Segment_WA__c = 'Acute',RecordTypeId = AccountRecordTypeVarId,Region__c='Acute',Territory__c='Acute',Inside_Sales__c = 'InsideSales',Acute_Mortara_Territory__c='Testing',Market_Segment__c='Acute'),
            										new Account(Name = 'Test Account1',COT_1__c = 'WH',Billingcity = 'TestCity-02',BillingPostalCode = '005442',BillingState = 'Alaska',ShippingPostalCode = '005442',BillingCountry='United State',ShippingCountry = 'United States',Type = 'Acute',Market_Segment_WA__c = 'System',RecordTypeId = AccountRecordTypeVarId,Region__c='System',Territory__c='System',Inside_Sales__c = 'InsideSales',Acute_Mortara_Territory__c='Acute',Market_Segment__c='Ambulatory'),
            										new Account(Name = 'Test Account2',COT_1__c = 'UN',Billingcity = 'TestCity-03',BillingPostalCode = '005443',BillingState = 'Alaska',ShippingPostalCode = '005443',BillingCountry='CA',ShippingCountry = 'United States',Type = 'Acute',Market_Segment_WA__c = 'Ambulatory',RecordTypeId = AccountRecordTypeVarId,Region__c='Ambulatory',Territory__c='Ambulatory',Inside_Sales__c = 'InsideSales',Acute_Mortara_Territory__c='Ambulatory',Market_Segment__c='System'),
            										new Account(Name = 'test-1', Local_Account_Name__c = 'test-1', Billingcity = 'TestCity-01', BillingPostalCode = '00544', COT_1__c = 'UN', BillingCountry = 'US', BillingState = 'Alaska', recordtypeId = AccountRecordTypeId,ShippingPostalCode='12345',Market_Segment__c='Acute',ShippingCountry='US'),
            										new Account(Name = 'test-2', Local_Account_Name__c = 'test-2', Billingcity = 'TestCity-01',BillingPostalCode = '005441', COT_1__c = 'WH', BillingCountry = 'CA', BillingState = 'Manitoba', recordtypeId = AccountRecordTypeId,ShippingPostalCode='567',Market_Segment__c='Acute',ShippingCountry='CA')};
        insert lstAccount; 
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User objUser = new User(Alias = 'newUsr', Email='new45421@hillrom.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='new125.325@hillrom.com');
        insert objUser;
        
        SL_Integration_Settings__c objIntSettings = new SL_Integration_Settings__c(Integration_UserId__c = objUser.Id, Integration_Status__c = 'Active, Inactive');
        insert objIntSettings;
        
        // Inserting Postal Code Mapping for CA and Us
		List <Postal_Code_Mapping__c> lstPostal_Code_Mapping = new List<Postal_Code_Mapping__c>{new Postal_Code_Mapping__c(Name = '12345', Acute_Region__c = 'AcuteRegion', Acute_Territory__c = 'Acute Territory',Ambulatory_Territory__c = 'AmbulatoryTerritory',Ambulatory_Region__c = 'AmbulatoryRegion',Inside_Sales__c = 'InsideSales',Solutions_Architect__c = 'TestSol'),
                                                       		   new Postal_Code_Mapping__c(Name = '567', Acute_Region__c = 'AcuteRegionCA', Acute_Territory__c = 'Acute TerritoryCA',Ambulatory_Region__c = 'AmbulatoryRegionCA',Inside_Sales__c = 'InsideSalesCA',Solutions_Architect__c = 'TestSolCA')};
        insert lstPostal_Code_Mapping;        
                 
        for(Account objAccount : [SELECT Region__c, Territory__c, Inside_Sales__c, Solution_Architect__c FROM Account WHERE Id IN: lstAccount]){
            lstInsertedAcc.add(objAccount);
        }
        
        // Checking the value after the trigger fire
        //system.assertEquals(lstInsertedAcc[0].Region__c, lstPostal_Code_Mapping[0].Ambulatory_Region__c);
        //system.assertEquals(lstInsertedAcc[1].Inside_Sales__c, lstPostal_Code_Mapping[1].Inside_Sales__c);        
        lstAccount[0].COT_1__c = 'XO ';
        update lstAccount[0];           
        // Checking the value after the trigger fire
        //system.assertEquals([SELECT Region__c FROM Account WHERE Id=:lstAccount[0].Id].Region__c, 'Other');       
        lstAccount[1].ShippingPostalCode = '123456789 ';
        update lstAccount[1]; 
        /*SL_TerritoryMangRuleRlgnBatchProcess__c obj = new SL_TerritoryMangRuleRlgnBatchProcess__c(Name = 'Welchallyn--full', UserName__c = 'welchallyn@silverlinecrm.com.full',
        Insert obj;*/        
        
        SL_App_Configuration__c obj = new SL_App_Configuration__c(Org_Password__c = 'silverline@860', Org_Security_Token__c ='aOcvG50rnNtR631SJqT4wiGt1', Org_Username__c = 'welchallyn@silverlinecrm.com.full' );
        insert obj;        
        SL_App_Configuration__c objSL_App_Configiration = new SL_App_Configuration__c ();
    }    
}