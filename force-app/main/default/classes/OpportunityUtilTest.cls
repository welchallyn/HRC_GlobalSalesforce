@isTest
private class OpportunityUtilTest {
    static User testUser;
    
    static void setupData() {
        String uniqueKey = '49a84701';
              Id ProfileId = [SELECT Id FROM Profile WHERE Name = 'HRC Account Executive'].Id;
         testUser = [SELECT Id FROM user where profileid =: profileid and isactive = true order by firstname asc limit 1]; 
     
       /** testUser = new User();
        testUser.Alias = uniqueKey;
        testUser.Email = uniqueKey + '@testorg.com';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.LastName = 'Test' + uniqueKey;
        testUser.LanguageLocaleKey = 'en_US';
        testUser.LocaleSidKey = 'en_US';
        testUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'HRC Account Executive'].Id;
        testUser.TimeZoneSidKey = 'America/Chicago';
        testUser.Username = uniqueKey + '@test' + Math.round(Math.random() * 10000) + '.com';
        testUser.UserRoleId = null;
        testUser.Country = 'United States';
        insert testUser;**/
    } 

    static testMethod void testOpportunitySharing_Insert() {
        setupData();
        
        Account testAccount = new Account(name='test account2342342', billingcountry='United States');
        insert testAccount;
        
        AccountTeamMember atm = new AccountTeamMember();
        atm.UserId = testUser.Id;
        atm.AccountId = testAccount.Id;
        insert atm;
        
        //Contact testcontact = new Contact(firstname='test', lastname = 'contact');
        //insert testcontact;
        
        Test.startTest();
        
        Opportunity testOpp = new Opportunity(AccountId=testAccount.id, Name='Test Opportunity234343');
        testOpp.Return_Type__c = 'None';
        testOpp.StageName = 'Qualified Opportunity';
        testOpp.CloseDate = system.today();
        testOpp.RMA_Date_1__c = system.today();
        testOpp.RMA_Price_1__c = 100.00 ;
        testOpp.RMA_Product_1__c = 'test product' ;
        testOpp.RMA_Quantity_1__c = 10 ;
        //testOpp.Order_Contact__c = testcontact.id;
        insert testOpp;
        
        System.runAs(testUser) {
            List<Opportunity> oList = [select Id from Opportunity where Id = :testOpp.Id];
            
            system.assertEquals(1, oList.size());
        }
        
        Test.stopTest();
    }
    
    static testMethod void testOpportunitySharing_Update() {
        setupData();
        
        Account testAccount = new Account(name='test account2342342',billingCountry='United States');
        insert testAccount;
        
        Account testAccount2 = new Account(name='test account2722342',billingCountry='United States');
        insert testAccount2;
        
        AccountTeamMember atm = new AccountTeamMember();
        atm.UserId = testUser.Id;
        atm.AccountId = testAccount2.Id;
        insert atm;
        
       // Contact testcontact = new Contact(firstname='test', lastname = 'contact');
       // insert testcontact;
        
        Test.startTest();
        
        Opportunity testOpp = new Opportunity(AccountId=testAccount.id, Name='Test Opportunity234343');
        testOpp.StageName = 'Qualified Opportunity';
        testOpp.Return_Type__c = 'None';
        testOpp.CloseDate = system.today();
        testOpp.RMA_Date_1__c = system.today();
        testOpp.RMA_Price_1__c = 100.00 ;
        testOpp.RMA_Product_1__c = 'test product' ;
        testOpp.RMA_Quantity_1__c = 10 ;
        //testOpp.Order_Contact__c = testcontact.id;
        insert testOpp;
        
        System.runAs(testUser) {
            List<Opportunity> oList = [select Id from Opportunity where Id = :testOpp.Id];
            
            system.assertEquals(0, oList.size());
        }
        
        testOpp.AccountId = testAccount2.Id;
        update testOpp;
        
        System.runAs(testUser) {
            List<Opportunity> oList = [select Id from Opportunity where Id = :testOpp.Id];
            
            system.assertEquals(1, oList.size());
        }
        
        Test.stopTest();
    }
}