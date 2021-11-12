/**
    *  Controller        : SL_Test_Account_Hierarchy
    *  CreatedOn         : 20/MAY/2015
    *  ModifiedOn        : 12/22/2017
    *  ModifiedBy        : ESiewert
    *  Description       : This the account Hierarchy page Test Class  - ERS - added assertion back in.
*/
@isTest
private class SL_Test_Account_Hierarchy 
{
    static testMethod void Test_Account_Hierarchy() 
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User objUser = new User(Alias = 'newUsr', Email='new45421@welchallyn.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='new125.325@welchallyn.com');
        insert objUser;
        SL_Integration_Settings__c objIntSettings = new SL_Integration_Settings__c(Integration_UserId__c = objUser.Id, Integration_Status__c = 'Active, Inactive');
        insert objIntSettings;
        // Insert Ultimate Parent
        List<Account> lstAccountToInsert_UltimateParents = new List<Account>{
                                                                               new Account( Name='Ultimate Parent 1', Local_Account_Name__c = 'Ultimate Parent 1', ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '540664'),
                                                                               new Account( Name='Ultimate Parent 2', Local_Account_Name__c = 'Ultimate Parent ', ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '540664')
                                                                            };
        insert  lstAccountToInsert_UltimateParents;
        
        // Insert Account For level 1
        List<Account> lstAccountToInsert_Level1 = new List<Account>{
                                                                              new Account( Name='Level 1,Child 1' , Local_Account_Name__c = 'Level 1,Child 1', ParentId=lstAccountToInsert_UltimateParents[0].Id , ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '540664'),
                                                                              new Account( Name='Level 1,Child 2' , Local_Account_Name__c = 'Level 1,Child 2', ParentId=lstAccountToInsert_UltimateParents[0].Id , ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '540664'),
                                                                              new Account( Name='Level 1,Child 3' , Local_Account_Name__c = 'Level 1,Child 3', ParentId=lstAccountToInsert_UltimateParents[1].Id , ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '540664'),
                                                                              new Account( Name='Level 1,Child 4' , Local_Account_Name__c = 'Level 1,Child 4', ParentId=lstAccountToInsert_UltimateParents[1].Id , ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '540664'),
                                                                              new Account( Name='Level 1,Child 5', Local_Account_Name__c = 'Level 1,Child 5', ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '540664')
                                                                   };
        insert lstAccountToInsert_Level1;                                                              
        
        // Insert Account For level 2   
        List<Account> lstAccountToInsert_Level2 = new List<Account>{
                                                                              new Account( Name='Level 2,Child 1' , Local_Account_Name__c = 'Level 2,Child 1', ParentId=lstAccountToInsert_Level1[0].Id , ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '540664'),
                                                                              new Account( Name='Level 2,Child 2' , Local_Account_Name__c = 'Level 2,Child 2', ParentId=lstAccountToInsert_Level1[0].Id , ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '540664'),
                                                                              new Account( Name='Level 2,Child 3' , Local_Account_Name__c = 'Level 2,Child 3', ParentId=lstAccountToInsert_Level1[1].Id , ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '540664'),
                                                                              new Account( Name='Level 2,Child 4' , Local_Account_Name__c = 'Level 2,Child 4', ParentId=lstAccountToInsert_Level1[1].Id , ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '540664'),
                                                                              new Account( Name='Level 2,Child 5' , Local_Account_Name__c = 'Level 2,Child 5', ParentId=lstAccountToInsert_Level1[2].Id , ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '540664'),
                                                                              new Account( Name='Level 2,Child 6' , Local_Account_Name__c = 'Level 2,Child 6', ParentId=lstAccountToInsert_Level1[2].Id , ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '540664'),
                                                                              new Account( Name='Level 2,Child 7' , Local_Account_Name__c = 'Level 2,Child 7', ParentId=lstAccountToInsert_Level1[3].Id , ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '540664'),
                                                                              new Account( Name='Level 2,Child 8' , Local_Account_Name__c = 'Level 2,Child 8', ParentId=lstAccountToInsert_Level1[3].Id , ShippingCountry = 'US', Shippingcity = 'TestCity-01', ShippingState = 'Alaska', ShippingPostalCode = '540664')                                                    
                                                                   };
       insert lstAccountToInsert_Level2;  
       
       List<Account> lstAccount = [Select Id,Ulimate_Parent_Name__c from Account where Id =:lstAccountToInsert_Level2[0].Id Limit 1];
    
      system.assertEquals('Ultimate Parent 1' , lstAccount[0].Ulimate_Parent_Name__c);
       
       Apexpages.currentPage().getParameters().put('id', lstAccountToInsert_Level1[0].Id);
       
       // Calling SL_Account_Hierarchy class
       SL_Account_Hierarchy objSL_Account_Hierarchy = new SL_Account_Hierarchy ();
    }
}