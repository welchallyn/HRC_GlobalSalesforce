/*
    *  ClassName    : SL_Test_AccountHandler 
    *  JIRATicket   : WADVDSC-2,WADVDSC-4,WADVDSC-5
    *  CreatedOn    : 06/Jun/2015
    *  CreatedBy    : Sanath
    *  ModifiedBy   : Lodhi
    *  Description  : Test class for Account Handler
*/

@isTest
private class SL_Test_AccountHandler
{
    @isTest static void accountUltimateParentHeirarchy() //Added for WADVDSC-2
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User objUser = new User(Alias = 'newUsr', Email='new45421@hill-rom.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='new125.325@hill-rom.com');
        insert objUser;
        
        SL_Integration_Settings__c objIntSettings = new SL_Integration_Settings__c(Integration_UserId__c = objUser.Id, Integration_Status__c = 'Active, Inactive');
        insert objIntSettings;
        
      /*Inserting Accounts*/
    List<Account> lstAccountToInsert_UltimateParents = new List<Account>{
                                                                               new Account( Name='Ultimate Parent 1', Local_Account_Name__c = 'Ultimate Parent 1', PARTY_MK__c = '123332323', 
                                                                                BillingCountry = 'US', Billingcity = 'TestCity-01', BillingState = 'Alaska', BillingPostalCode = '540664', Status__c = 'Active'),
                                                                               new Account( Name='Ultimate Parent 2', Local_Account_Name__c = 'Ultimate Parent 2', BillingCountry = 'US', Billingcity = 'TestCity-01', BillingState = 'Alaska', BillingPostalCode = '540664', Status__c = 'Inactive')
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
                                                                              new Account(Status__c= 'Merge Candidate', Name='Level 1,Child 1' , Local_Account_Name__c = 'Level 1,Child 1',ParentId=lstAccountToInsert_UltimateParents[0].Id, PARTY_MK__c = '5212123111', 
                                                                                BillingCountry = 'US', Billingcity = 'TestCity-01', BillingState = 'Alaska', BillingPostalCode = '540664'),
                                                                              new Account(Status__c= 'Merge Candidate', Name='Level 1,Child 2' , Local_Account_Name__c = 'Level 1,Child 2',ParentId=lstAccountToInsert_UltimateParents[0].Id , PARTY_MK__c = '1233', 
                                                                                BillingCountry = 'US', Billingcity = 'TestCity-01', BillingState = 'Alaska', BillingPostalCode = '540664' ),
                                                                              new Account( Name='Level 1,Child 3' , Local_Account_Name__c = 'Level 1,Child 3',ParentId=lstAccountToInsert_UltimateParents[1].Id, BillingCountry = 'US', Billingcity = 'TestCity-01', BillingState = 'Alaska', BillingPostalCode = '540664' ),
                                                                              new Account( Name='Level 1,Child 4' , Local_Account_Name__c = 'Level 1,Child 4',ParentId=lstAccountToInsert_UltimateParents[1].Id, BillingCountry = 'US', Billingcity = 'TestCity-01', BillingState = 'Alaska', BillingPostalCode = '540664' ),
                                                                              new Account( Name='Level 1,Child 5' , Local_Account_Name__c = 'Level 1,Child 5', BillingCountry = 'US', Billingcity = 'TestCity-01', BillingState = 'Alaska', BillingPostalCode = '540664')
                                                                   };
        insert lstAccountToInsert_Level1;                                                              
      
      lstAccICDate = new List <Account> (); 
      for(Account objAc : [SELECT Id, IC_Date__c FROM Account WHERE Id IN: lstAccountToInsert_Level1])
        {
          lstAccICDate.add(objAc);
        }
        system.assertEquals(lstAccICDate[0].IC_Date__c, null);
       system.assertEquals(lstAccICDate[1].IC_Date__c, null);
        
        lstAccountToInsert_Level1[0].Status__c = 'Active';
        lstAccountToInsert_Level1[1].Status__c = 'true';
      
      update lstAccountToInsert_Level1;
      
      lstAccICDate = new List <Account> (); 
      for(Account objAc : [SELECT Id, IC_Date__c FROM Account WHERE Id IN: lstAccountToInsert_Level1])
        {
          lstAccICDate.add(objAc);
        }
      
      system.assertNotEquals(lstAccICDate[0].IC_Date__c, null);
      system.assertEquals(lstAccICDate[0].IC_Date__c, SL_AccountHandler.testDatetimeNow);
        system.assertEquals(lstAccICDate[1].IC_Date__c, null);
        
        lstAccountToInsert_Level1[1].Status__c = 'Inactive';
        update lstAccountToInsert_Level1;
        
        lstAccICDate = new List <Account> (); 
      
      for(Account objAc : [SELECT Id, IC_Date__c FROM Account WHERE Id IN: lstAccountToInsert_Level1])
        {
          lstAccICDate.add(objAc);
        } 

      system.assertNotEquals(lstAccICDate[1].IC_Date__c, null);
    //  system.assertEquals(lstAccICDate[1].IC_Date__c, SL_AccountHandler.testDatetimeNow);
      
    List<Account> lstAccountToInsert_Level2 = new List<Account>{
                                                                              new Account( Name='Level 2,Child 1' , Local_Account_Name__c = 'Level 2,Child 1',ParentId=lstAccountToInsert_Level1[0].Id, BillingCountry = 'US', Billingcity = 'TestCity-01', BillingState = 'Alaska', BillingPostalCode = '540664' ),
                                                                              new Account( Name='Level 2,Child 2' , Local_Account_Name__c = 'Level 2,Child 2',ParentId=lstAccountToInsert_Level1[0].Id, BillingCountry = 'US', Billingcity = 'TestCity-01', BillingState = 'Alaska', BillingPostalCode = '540664' ),
                                                                              new Account( Name='Level 2,Child 3' , Local_Account_Name__c = 'Level 2,Child 3',ParentId=lstAccountToInsert_Level1[1].Id, BillingCountry = 'US', Billingcity = 'TestCity-01', BillingState = 'Alaska', BillingPostalCode = '540664' ),
                                                                              new Account( Name='Level 2,Child 4' , Local_Account_Name__c = 'Level 2,Child 4',ParentId=lstAccountToInsert_Level1[1].Id, BillingCountry = 'US', Billingcity = 'TestCity-01', BillingState = 'Alaska', BillingPostalCode = '540664' ),
                                                                              new Account( Name='Level 2,Child 5' , Local_Account_Name__c = 'Level 2,Child 5',ParentId=lstAccountToInsert_Level1[2].Id, BillingCountry = 'US', Billingcity = 'TestCity-01', BillingState = 'Alaska', BillingPostalCode = '540664' ),
                                                                              new Account( Name='Level 2,Child 6' , Local_Account_Name__c = 'Level 2,Child 6',ParentId=lstAccountToInsert_Level1[2].Id, BillingCountry = 'US', Billingcity = 'TestCity-01', BillingState = 'Alaska', BillingPostalCode = '540664' ),
                                                                              new Account( Name='Level 2,Child 7' , Local_Account_Name__c = 'Level 2,Child 7',ParentId=lstAccountToInsert_Level1[3].Id, BillingCountry = 'US', Billingcity = 'TestCity-01', BillingState = 'Alaska', BillingPostalCode = '540664' ),
                                                                              new Account( Name='Level 2,Child 8' , Local_Account_Name__c = 'Level 2,Child 8',ParentId=lstAccountToInsert_Level1[3].Id, BillingCountry = 'US', Billingcity = 'TestCity-01', BillingState = 'Alaska', BillingPostalCode = '540664' )                                                    
                                                                   };
    insert lstAccountToInsert_Level2;  
       
         List<Account> lstAccount = [Select Id,Ulimate_Parent_Name__c from Account where Id =:lstAccountToInsert_Level2[0].Id Limit 1];
    
        system.assertEquals('Ultimate Parent 1' , lstAccount[0].Ulimate_Parent_Name__c);
       
         
         /*Updating Accounts*/
         /*List<Account> lstAccountToUpdate = new List<Account>{
                                                     new Account( Id=lstAccountToInsert_Level1[0].Id , ParentId=lstAccountToInsert_UltimateParents[1].Id),
                                                     new Account( Id=lstAccountToInsert_Level2[1].Id , ParentId=lstAccountToInsert_Level1[2].Id ),
                                                     new Account( Id=lstAccountToInsert_Level2[7].Id , ParentId=null ),
                                                     new Account( Id=lstAccountToInsert_Level1[4].Id , ParentId=lstAccountToInsert_UltimateParents[1].Id , ShippingCountry = 'CA', Shippingcity = 'TestCity-01', ShippingState = 'Manitoba', ShippingPostalCode = '540664' )
                                                   };
         update lstAccountToUpdate;
       
         lstAccount = [Select Id,Ulimate_Parent_Name__c from Account where Id IN:lstAccountToUpdate];8/
       
         /*Deleting Accounts*/
       
         List<Account> lstAccountToDelete = new List<Account>{
                                                        new Account( Id=lstAccountToInsert_UltimateParents[0].Id ),
                                                        new Account( Id=lstAccountToInsert_Level1[0].Id )                
                                                    };
     
    delete lstAccountToDelete;
        
        List <Delete_Audit__c> lstDelete_Audit = new List <Delete_Audit__c> (); 
    for(Delete_Audit__c objDelAudit : [SELECT id,Status__c, Type__c FROM Delete_Audit__c ])
        {
          lstDelete_Audit.add(objDelAudit);
        }
      
      // checking if the Accounts are deleted the Delete_Audit will be created with the type 'DELETE'
     // system.assertEquals(lstDelete_Audit.size(), 2);
     // system.assertEquals(lstDelete_Audit[0].Type__c, 'DELETE');  
     // system.assertEquals(lstDelete_Audit[0].Status__c, 'Inactive');
         
         /* Merging Accounts*/
         List<Account> lstAccountToMerge = new List<Account>{
                                                        new Account( Id=lstAccountToInsert_UltimateParents[1].Id ),
                                                        new Account( Id=lstAccountToInsert_Level1[1].Id )                
                                                     };
         merge lstAccountToMerge[0] lstAccountToMerge[1];
         
         Delete_Audit__c objMerged = new Delete_Audit__c ();
         
         for(Delete_Audit__c objDelAudit : [SELECT id, Status__c, Type__c FROM Delete_Audit__c WHERE Deleted_SFDCID__c=:lstAccountToMerge[1].Id])
        {
          objMerged = objDelAudit;
          lstDelete_Audit.add(objDelAudit);
        }
        
        // checking if the Accounts are merged the Delete_Audit will be created with the type 'MERGE'
      //  system.assertEquals(lstDelete_Audit.size(), 3);
      //system.assertEquals(objMerged.Type__c, 'MERGE');
      //system.assertEquals(objMerged.Status__c, 'Inactive');
      
      
      
      /*Updated by Nrusingh for checking Delete ausit Name*/
        List <Account> lstAccountForDeleteAudit = new List <Account> {
                                        new Account( Name='PMK-123-SKA-456:Silverline' , PARTY_MK__c = '1121212121210217',
                                          Local_Account_Name__c = 'Level 2,Child 1',BillingCountry = 'US', Billingcity = 'TestCity-01', BillingState = 'Alaska', BillingPostalCode = '540664' ),
                                    new Account( Name='PMK-123-SKA-456:Silverline-1:newyork' , PARTY_MK__c = '1121212121210216',
                                      Local_Account_Name__c = 'Level 2,Child 2', BillingCountry = 'US', Billingcity = 'TestCity-01', BillingState = 'Alaska', BillingPostalCode = '540664' ),
                                    new Account( Name='PMK-:Silverline-1:newyork' , PARTY_MK__c = '1121212121210215', 
                                      Local_Account_Name__c = 'Level 2,Child 3', BillingCountry = 'US', Billingcity = 'TestCity-01', BillingState = 'Alaska', BillingPostalCode = '540664' ),
                                    new Account( Name='Test-abc' , PARTY_MK__c = '1121212121210214', 
                                      Local_Account_Name__c = 'Level 2,Child 1', BillingCountry = 'US', Billingcity = 'TestCity-01', BillingState = 'Alaska', BillingPostalCode = '540664' ),
                                    new Account( Name='Test-abc-PMK-' , PARTY_MK__c = '1121212121210213', 
                                      Local_Account_Name__c = 'Level 2,Child 2', BillingCountry = 'US', Billingcity = 'TestCity-01', BillingState = 'Alaska', BillingPostalCode = '540664' ),
                                    new Account( Name='PMK-Test123' , PARTY_MK__c = '1121212121210212', 
                                      Local_Account_Name__c = 'Level 2,Child 3', BillingCountry = 'US', Billingcity = 'TestCity-01', BillingState = 'Alaska', BillingPostalCode = '540664' ),
                                    new Account( Name='PMK-123:test:test1:Silverline-1:newyork' , PARTY_MK__c = '11212121212110215', 
                                      Local_Account_Name__c = 'Level 2,Child 3', BillingCountry = 'US', Billingcity = 'TestCity-01', BillingState = 'Alaska', BillingPostalCode = '540664' ),
                                    new Account( Name='PMK----123' , PARTY_MK__c = '11212121212110215',
                                      Local_Account_Name__c = 'Level 2,Child 3', BillingCountry = 'US', Billingcity = 'TestCity-01', BillingState = 'Alaska', BillingPostalCode = '540664' ),
                                    new Account( Name='PMK--2222-:-123Test' ,  PARTY_MK__c = '11212121212110215',
                                      Local_Account_Name__c = 'Level 2,Child 3', BillingCountry = 'US', Billingcity = 'TestCity-01', BillingState = 'Alaska', BillingPostalCode = '540664' )
                                       };
                                       
    insert lstAccountForDeleteAudit;
    
    Set <Id> setAccountDeletedId = new Set <Id> ();
    
    for (Account objAcc : lstAccountForDeleteAudit)
    {
      setAccountDeletedId.add(objAcc.Id);
    }
    
    // Deleting the Accounts
    delete lstAccountForDeleteAudit;
    
    
    List <Delete_Audit__c> lstDelete_Audit_PMK = new List <Delete_Audit__c> (); 
    
    // Query to the Delete_Audit to check the Name
    for(Delete_Audit__c objDelAudit : [SELECT id,Name FROM Delete_Audit__c WHERE Deleted_SFDCID__c IN: setAccountDeletedId ])
        {
          lstDelete_Audit_PMK.add(objDelAudit);
        }
    
    // Verifying the Delete Audit Name based on PMK- present in the Account Name
    /*system.assertEquals(lstDelete_Audit_PMK[0].Name,'Silverline');
      system.assertEquals(lstDelete_Audit_PMK[1].Name, 'Silverline-1:newyork');
      system.assertEquals(lstDelete_Audit_PMK[2].Name, 'Silverline-1:newyork');
      system.assertEquals(lstDelete_Audit_PMK[3].Name,'Test-abc');
      system.assertEquals(lstDelete_Audit_PMK[4].Name, 'Test-abc-PMK-');
      system.assertEquals(lstDelete_Audit_PMK[5].Name, 'PMK-Test123');
      system.assertEquals(lstDelete_Audit_PMK[6].Name, 'test:test1:Silverline-1:newyork');
      system.assertEquals(lstDelete_Audit_PMK[7].Name, 'PMK----123');
      system.assertEquals(lstDelete_Audit_PMK[8].Name, '-123Test');*/
    }   
}