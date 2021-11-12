/**
@ClassName    : SL_Test_BatchUltimateParentOnAllAccounts
@JIRATicket   : WADVDSC-2 
@CreatedOn    : 02/06/2015
@ModifiedBy   : Nrusingh
@Description  : This is the test class for the SL_Batch_UltimateParentOnAllAccounts batch with 10 levels of test hierarchy 
*/

@isTest
private class SL_Test_BatchUltimateParentOnAllAccounts 
{
   /*static testMethod void SL_Test_BatchUltimateParentOnAllAccounts() 
    {
    	List <Account> lstchildAccount1 = new List <Account> ();
    	List <Account> lstchildAccount2 = new List <Account> ();
    	List <Account> lstchildAccount3 = new List <Account> (); 
    	List <Account> lstchildAccount4 = new List <Account> (); 
    	List <Account> lstchildAccount5 = new List <Account> (); 
    	List <Account> lstchildAccount6 = new List <Account> (); 
    	List <Account> lstchildAccount7 = new List <Account> (); 
    	List <Account> lstchildAccount8 = new List <Account> (); 
    	List <Account> lstchildAccount9 = new List <Account> ();
    	List <Account> lstchildAccount10 = new List <Account> (); 
    	 Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User objUser = new User(Alias = 'newUsr', Email='new45421@hillrom.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='new125.325@hillrom.com');
        insert objUser;
        
    	SL_Integration_Settings__c objIntSettings = new SL_Integration_Settings__c(Integration_UserId__c = objUser.Id, Integration_Status__c = 'Active, Inactive');
        insert objIntSettings;
    	// Insert Ultimate parent
        List<Account> lstAccountToInsert_UltimateParents = new List<Account>{
																			   new Account( Name='Ultimate Parent 1', Local_Account_Name__c = 'Ultimate Parent 1', ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '540664'),
																			   new Account( Name='Ultimate Parent 2', Local_Account_Name__c = 'Ultimate Parent 2', ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '540664')
																			};
		insert 	lstAccountToInsert_UltimateParents;
		
		// Insert level-1 child record for Ultimate Parent 1
		for(Integer i=0;i<100;i++)
		{
			lstchildAccount1.add(new Account (Name = 'Child-'+i, Local_Account_Name__c = 'Child-'+i, parentId = lstAccountToInsert_UltimateParents[0].Id, ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '540664'));
		}		
		
		insert lstchildAccount1;
		
		// Insert level-2 child record for Ultimate Parent 1
		for(Integer i=0;i<100;i++)
		{
			lstchildAccount2.add(new Account (Name = 'Child2-'+i, Local_Account_Name__c = 'Child2-'+i, parentId = lstchildAccount1[0].Id, ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '540664'));
		}		
		insert lstchildAccount2;
		
		// Insert level-3 child record for Ultimate Parent 1
		for(Integer i=0;i<100;i++)
		{
			lstchildAccount3.add(new Account (Name = 'Child3-'+i, Local_Account_Name__c = 'Child3-'+i, parentId = lstchildAccount2[0].Id, ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '540664'));
		}		
		insert lstchildAccount3;
		
		// Insert level-4 child record for Ultimate Parent 1
		for(Integer i=0;i<100;i++)
		{
			lstchildAccount4.add(new Account (Name = 'Child4-'+i, Local_Account_Name__c = 'Child4-'+i, parentId = lstchildAccount3[0].Id, ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '540664'));
		}		
		insert lstchildAccount4;
		
		// Insert level-5 child record for Ultimate Parent 1
		for(Integer i=0;i<100;i++)
		{
			lstchildAccount5.add(new Account (Name = 'Child5-'+i, Local_Account_Name__c = 'Child5-'+i, parentId = lstchildAccount4[0].Id, ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '540664'));
		}		
		insert lstchildAccount5;
		
		// Insert level-6 child record for Ultimate Parent 1
		for(Integer i=0;i<100;i++)
		{
			lstchildAccount6.add(new Account (Name = 'Child6-'+i, Local_Account_Name__c = 'Child6-'+i, parentId = lstchildAccount5[0].Id, ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '540664'));
		}		
		insert lstchildAccount6;
		
		// Insert level-7 child record for Ultimate Parent 1
		for(Integer i=0;i<100;i++)
		{
			lstchildAccount7.add(new Account (Name = 'Child7-'+i, Local_Account_Name__c = 'Child7-'+i, parentId = lstchildAccount6[0].Id, ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '540664'));
		}		
		insert lstchildAccount7;
		
		// Insert level-8 child record for Ultimate Parent 1
		for(Integer i=0;i<100;i++)
		{
			lstchildAccount8.add(new Account (Name = 'Child8-'+i, Local_Account_Name__c = 'Child8-'+i, parentId = lstchildAccount7[0].Id, ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '540664'));
		}		
		insert lstchildAccount8;
		
		// Insert level-9 child record for Ultimate Parent 1
		for(Integer i=0;i<100;i++)
		{
			lstchildAccount9.add(new Account (Name = 'Child9-'+i, Local_Account_Name__c = 'Child9-'+i, parentId = lstchildAccount8[0].Id, ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '540664'));
		}		
		
		insert lstchildAccount9;
		
		// Insert level-10 child record for Ultimate Parent 1
		for(Integer i=0;i<100;i++)
		{
			lstchildAccount10.add(new Account (Name = 'Child10-'+i, Local_Account_Name__c = 'Child10-'+i, parentId = lstchildAccount9[0].Id, ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '540664'));
		}		
		
		insert lstchildAccount10;
		
		// Calling the Batch		
		Test.startTest();
  			Database.executeBatch(new SL_Batch_UltimateParentOnAllAccounts(), 200);
  		Test.StopTest();
  		
  		//Checking the Ultimate Parent Id should be same for all the Accounts
  		for(Account objAccount : [SELECT Ulimate_Parent_Name__c FROM Account WHERE Id IN: lstchildAccount1 
  																				 OR Id IN: lstchildAccount2
  																				 OR Id IN: lstchildAccount3
  																				 OR Id IN: lstchildAccount4
  																				 OR Id IN: lstchildAccount5
  																				 OR Id IN: lstchildAccount6
  																				 OR Id IN: lstchildAccount7
  																				 OR Id IN: lstchildAccount8
  																				 OR Id IN: lstchildAccount9
  																				 OR Id IN: lstchildAccount10
  																				 ])
		{
			system.assertEquals(objAccount.Ulimate_Parent_Name__c, 'Ultimate Parent 1');
		}
    }*/
    
    /*Code Addition By 
     * Name - Varun Gupta
     * Date - 04/03/2020
     * Company - Birlasoft*/
    static testMethod void SL_Test_AppAdministrationController() 
    {
        // TO DO: implement unit test
        Test.startTest();
        SL_AppAdministrationController objSL_AppAdministrationController = new SL_AppAdministrationController ();
        //getBatchJob();
        objSL_AppAdministrationController.createTerritoryMappingBatch();
        Test.stoptest();
    }
    
    
	static testMethod void setupAccountData2()
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
        
     //   system.assertEquals(lstAccICDate[0].IC_Date__c, SL_AccountHandler.testDatetimeNow);
      //  system.assertEquals(lstAccICDate[1].IC_Date__c, SL_AccountHandler.testDatetimeNow);
        
        
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
   //     system.assertEquals(lstAccICDate[0].IC_Date__c, null);
   //     system.assertEquals(lstAccICDate[1].IC_Date__c, null);
        
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
     //   system.assertEquals(lstAccICDate[1].IC_Date__c, null);
        
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
			SL_Batch_UltimateParentOnAllAccounts obj = new SL_Batch_UltimateParentOnAllAccounts();
            DataBase.executeBatch(obj); 
        	//SL_Batch_UltimateParentOnAllAccounts.scheduleTerritoryMapping('0 0 23 * * ?');
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