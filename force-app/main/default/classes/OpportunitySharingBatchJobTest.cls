@isTest(seealldata = true)
private class OpportunitySharingBatchJobTest {
    static User testUser;
    static User testUser2;
    
    static void setupData() {
        String uniqueKey = '49a84701';
       Id ProfileId = [SELECT Id FROM Profile WHERE Name = 'HRC Account Executive'].Id;
         testUser = [SELECT Id FROM user where profileid =: profileid and isactive = true order by firstname asc limit 1]; 
     testUser2 = [SELECT Id FROM user where profileid =: profileid and isactive = true order by firstname desc limit 1]; 
        /**testUser = new User();
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
       // insert testUser;
        User objUserSalesAdmin = [SELECT Id FROM user limit 1]; 
        uniqueKey = '49a84791';
        
        testUser2 = new User();
        testUser2.Alias = uniqueKey;
        testUser2.Email = uniqueKey + '@testorg.com';
        testUser2.EmailEncodingKey = 'UTF-8';
        testUser2.LastName = 'Test' + uniqueKey;
        testUser2.LanguageLocaleKey = 'en_US';
        testUser2.LocaleSidKey = 'en_US';
        testUser2.ProfileId = [SELECT Id FROM Profile WHERE Name = 'HRC Account Executive'].Id;
        testUser2.TimeZoneSidKey = 'America/Chicago';
        testUser2.Username = uniqueKey + '@test' + Math.round(Math.random() * 10000) + '.com';
        testUser2.UserRoleId = null;
        testUser2.Country = 'United States';
        insert testUser2; **/
    }


    static testMethod void testOpportunityBatch() {
        setupData();
        
        Account testAccount = new Account(name='test account2342342',BillingCountry='United States');
        insert testAccount;
        
        Account testAccount2 = new Account(name='test account2722342',BillingCountry='United States');
        insert testAccount2;
      //  Contact testcontact = new Contact(firstname='test', lastname = 'contact');
       // insert testcontact;
        
        AccountTeamMember atm = new AccountTeamMember();
        atm.UserId = testUser.Id;
        atm.AccountId = testAccount.Id;
        insert atm;
        
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
        
        System.runAs(testUser2) {
            List<Opportunity> oList = [select Id from Opportunity where Id = :testOpp.Id];
            
            system.assertEquals(0, oList.size());
        }
        
        atm = new AccountTeamMember();
        atm.UserId = testUser2.Id;
        atm.AccountId = testAccount.Id;
        insert atm;
        
        System.runAs(testUser2) {
            List<Opportunity> oList = [select Id from Opportunity where Id = :testOpp.Id];
            
            system.assertEquals(0, oList.size());
        }
        
        String query='select OwnerId, (select UserId, AccountId from AccountTeamMembers), (select Id, OwnerId from Opportunities) from Account where Id = \'' + testAccount.Id + '\'';
            
        OpportunitySharingBatchJob olBatch = new OpportunitySharingBatchJob(query);
         
        Id accountbatchprocessid = Database.executeBatch(olBatch);
        
        Test.stopTest();
        
        System.runAs(testUser2) {
            List<Opportunity> oList = [select Id from Opportunity where Id = :testOpp.Id];
            
            system.assertEquals(1, oList.size());
        }
        
        
    }
}