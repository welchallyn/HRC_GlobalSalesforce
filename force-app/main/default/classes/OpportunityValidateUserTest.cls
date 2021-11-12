@isTest(seealldata=true)
private class OpportunityValidateUserTest {
    
    
    static User testAccountExecutive;
    static User testMobilitySpecialist;
    static User testAspenOwner;
    static User testTrumpf;
    static User testAspenNotowner;
    static Opportunity Opp2Update;
    
    static void setupData() {
              Id ProfileId = [SELECT Id FROM Profile WHERE Name = 'HRC Account Executive'].Id;
        testAccountExecutive = [SELECT Id FROM user where profileid =: profileid and isactive = true order by firstname asc limit 1];
             Id Profileid2 = [SELECT Id From Profile WHERE name = 'HRC Mobility Specialist'].Id; 
        testMobilitySpecialist = [SELECT Id FROM user where profileid =: profileid2 and isactive = true order by firstname desc limit 1];
        Id ProfileTrumpf = [SELECT Id FROM Profile WHERE Name = 'HRC Trumpf Sales'].Id;
        testTrumpf = [SELECT Id FROM user where profileid =: ProfileTrumpf and isactive = true order by firstname asc limit 1];
       /** 
        String uniqueKey = '49a84701';
        
        testUser = new User();
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
        insert testUser;
        
        uniqueKey = '55a84701';
        
        testUser2 = new User();
        testUser2.Alias = uniqueKey;
        testUser2.Email = uniqueKey + '@testorg.com';
        testUser2.EmailEncodingKey = 'UTF-8';
        testUser2.LastName = 'Test' + uniqueKey;
        testUser2.LanguageLocaleKey = 'en_US';
        testUser2.LocaleSidKey = 'en_US';
        testUser2.ProfileId = [SELECT Id FROM Profile WHERE Name = 'HRC Content Only'].Id; //HRC Account Executive
        testUser2.TimeZoneSidKey = 'America/Chicago';
        testUser2.Username = uniqueKey + '@test' + Math.round(Math.random() * 10000) + '.com';
        testUser2.UserRoleId = null;
        testUser2.Country = 'United States';
        insert testUser2;**/
    }
    
    static testMethod void testValidation_userIsValid() {
        setupData();
        
        Account testAccount = new Account(name='test account2342342', BillingCountry = 'United States');
        insert testAccount;
        
        AccountTeamMember atm = new AccountTeamMember();
        atm.UserId = testAccountExecutive.Id;
        atm.AccountId = testAccount.Id;
        insert atm;
        
        
        
        Test.startTest();
        
        System.runAs(testAccountExecutive) {
                //Contact testcontact = new Contact(firstname='test', lastname = 'contact');
       // insert testcontact;
        
            Opportunity testOpp = new Opportunity(AccountId=testAccount.id, Name='Test Opportunity234343');
            testOpp.Return_Type__c = 'None';
            testOpp.StageName = 'Developing Opportunity (RC)';
            testOpp.CloseDate = system.today();
            testOpp.RMA_Date_1__c = system.today();
            testOpp.RMA_Price_1__c = 100.00 ;
            testOpp.RMA_Product_1__c = 'test product' ;
            testOpp.RMA_Quantity_1__c = 10 ;
           // testOpp.Order_Contact__c = testcontact.id;
            testOpp.respiratory_opportunity_type__c = 'DUP';
            testOpp.respiratory_product_type__c = 'Vest System';
            testOpp.potential_referrals__c = 1;
            insert testOpp;
        
        
            List<Opportunity> oList = [select Id from Opportunity where Id = :testOpp.Id];
            
            system.assertEquals(1, oList.size());
            
            testOpp.RecordTypeId = [select Id from RecordType where DeveloperName = 'Respiratory_Acute_Care' and isActive = true and sobjecttype = 'Opportunity'].Id;
            testOpp.RMA_Quantity_1__c = 11 ;
            update testOpp ;
        }
        
        Test.stopTest();
    
    }
    
    
    static testMethod void testValidation_userIsInValid() {
        setupData();
        
        Account testAccount = new Account(name='test account2342111', BillingCountry = 'United States');
        insert testAccount;
        
        AccountTeamMember atm = new AccountTeamMember();
        atm.UserId = testMobilitySpecialist.Id;
        atm.AccountId = testAccount.Id;
        insert atm;
        //Contact testcontact1 = new Contact(firstname='test', lastname = 'contact1');
       // insert testcontact1;
        
        Test.startTest();
        
        Opportunity testOpp = new Opportunity(AccountId=testAccount.id, Name='Test Opportunity23433');
            testOpp.Return_Type__c = 'None';
            testOpp.StageName = 'Developing Opportunity (RC)';
            testOpp.CloseDate = system.today();
            testOpp.RMA_Date_1__c = system.today();
            testOpp.RMA_Price_1__c = 100.00 ;
            testOpp.RMA_Product_1__c = 'test product' ;
            testOpp.RMA_Quantity_1__c = 10 ;
          // testOpp.Order_Contact__c = testcontact1.id;
        
        
        System.runAs(testMobilitySpecialist) {
            try{
                insert testOpp ;
            }catch(Exception e){
                System.assert(true) ;
            }
        
            
        }
        
        Test.stopTest();
    
    }
    //trumpf user adding non trumpf Opp. should fail. 
    static testMethod void testValidation_userIsInValid2() {
        setupData();
        
        Account testAccount = new Account(name='test account2342112', BillingCountry = 'United States');
        insert testAccount;
        
        AccountTeamMember atm = new AccountTeamMember();
        atm.UserId = testTrumpf.Id;
        atm.AccountId = testAccount.Id;
        insert atm;
        Test.startTest();
        //try service contract, should fail
        Opportunity testOpp = new Opportunity(AccountId=testAccount.id, Name='Test Opportunity23434');
            testOpp.RecordTypeId = [select Id from RecordType where DeveloperName = 'Service_Contract' and isActive = true and sobjecttype = 'Opportunity'].Id;    
            testOpp.Return_Type__c = 'None';
            testOpp.StageName = 'Developing Opportunity (RC)';
            testOpp.CloseDate = system.today();
            testOpp.RMA_Date_1__c = system.today();
            testOpp.RMA_Price_1__c = 100.00 ;
            testOpp.RMA_Product_1__c = 'test product' ;
            testOpp.RMA_Quantity_1__c = 10 ;
          // testOpp.Order_Contact__c = testcontact1.id;
        
        System.runAs(testTrumpf) {
            try{
                insert testOpp ;
            }catch(Exception e){
                System.assert(true) ;
            }
        }
        Test.stopTest();
    }

    //trumpf user adding Rental. should fail. 
    static testMethod void testValidation_userIsInValid3() {
        setupData();
        
        Account testAccount = new Account(name='test account2342114', BillingCountry = 'United States');
        insert testAccount;
        
        AccountTeamMember atm = new AccountTeamMember();
        atm.UserId = testTrumpf.Id;
        atm.AccountId = testAccount.Id;
        insert atm;
        Test.startTest();
        Opportunity testOpp2 = new Opportunity(AccountId=testAccount.id, Name='Test Opportunity23435');
        testOpp2.RecordTypeId = [select Id from RecordType where DeveloperName = 'Rental_NA' and isActive = true and sobjecttype = 'Opportunity'].Id;    
        testOpp2.Return_Type__c = 'None';
        testOpp2.StageName = 'Developing Opportunity (RC)';
        testOpp2.CloseDate = system.today();
        System.runAs(testTrumpf) {
            try{
                insert testOpp2 ;
            }catch(Exception e){
                System.assert(true) ;
            }
        Test.stopTest();
        }
    }
    //trumpf user adding Metaneb. should fail. 
    static testMethod void testValidation_userIsInValid4() {
        setupData();
        
        Account testAccount = new Account(name='test account2342114', BillingCountry = 'United States');
        insert testAccount;
        
        AccountTeamMember atm = new AccountTeamMember();
        atm.UserId = testTrumpf.Id;
        atm.AccountId = testAccount.Id;
        insert atm;
        Test.startTest();
        Opportunity testOpp3 = new Opportunity(AccountId=testAccount.id, Name='Test Opportunity234366');
        testOpp3.RecordTypeId = [select Id from RecordType where Name = 'Respiratory Home Care' and isActive = true and sobjecttype = 'Opportunity'].Id;    
        testOpp3.StageName = 'Targeting';
        testOpp3.CloseDate = system.today();     
        System.runAs(testTrumpf) {
            try{
                insert testOpp3 ;
            }catch(Exception e){
                System.assert(true) ;
            }
            Test.stopTest();
        }
    }
    //trumpf user adding CWS. should fail. 
    static testMethod void testValidation_userIsInValid5() {
        setupData();
        
        Account testAccount = new Account(name='test account2342118', BillingCountry = 'United States');
        insert testAccount;
        
        AccountTeamMember atm = new AccountTeamMember();
        atm.UserId = testTrumpf.Id;
        atm.AccountId = testAccount.Id;
        insert atm;
        Test.startTest();
        Opportunity testOpp4 = new Opportunity(AccountId=testAccount.id, Name='Test Opportunity23438');
        testOpp4.RecordTypeId = [select Id from RecordType where DeveloperName= 'HITS' and isActive = true and sobjecttype = 'Opportunity'].Id;    
        testOpp4.StageName = 'Developing Opportunity (RC)';
        testOpp4.CloseDate = system.today();     
        System.runAs(testTrumpf) {
            try{
                insert testOpp4 ;
            }catch(Exception e){
                System.assert(true) ;
            }
            Test.stopTest();
        }
    }
    //trumpf user adding Capital should fail. 
    static testMethod void testValidation_userIsInValid6() {
        setupData();
        
        Account testAccount = new Account(name='test account2342119', BillingCountry = 'United States');
        insert testAccount;
        
        AccountTeamMember atm = new AccountTeamMember();
        atm.UserId = testTrumpf.Id;
        atm.AccountId = testAccount.Id;
        insert atm;
        Test.startTest();
        Opportunity testOpp5 = new Opportunity(AccountId=testAccount.id, Name='Test Opportunity23438');
        testOpp5.RecordTypeId = [select Id from RecordType where Name = 'Capital' and isActive = true and sobjecttype = 'Opportunity'].Id;    
        testOpp5.StageName = 'Developing Opportunity (RC)';
        testOpp5.CloseDate = system.today();     
        System.runAs(testTrumpf) {
            try{
                insert testOpp5 ;
            }catch(Exception e){
                System.assert(true) ;
            }
            Test.stopTest();
        }
    }
//test Profile not in override and opportunity record type not in the check list, should allow creation by user, but not edit by another user who is not the owner
    static testMethod void testValidation_NonOpportunityOwner() {
        setupData();
        
        Account testAccount = new Account(name='test TrumpfAccount2342342', BillingCountry = 'United States');
        insert testAccount;
        
        AccountTeamMember atm = new AccountTeamMember();
        atm.UserId = testTrumpf.Id;
        atm.AccountId = testAccount.Id;
        insert atm;
        
        AccountTeamMember atm2 = new AccountTeamMember();
        atm2.Userid = testMobilitySpecialist.Id;
        atm2.AccountId = testAccount.Id;
        insert atm2;
        string recordtypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Capital').getRecordTypeId();
        Opportunity testOpp = new Opportunity(AccountId=testAccount.id, Name='Test TrumpfOpportunity234343');
        testOpp.StageName = 'Best Few';
        testOpp.CloseDate = system.today();
        testOpp.recordtypeid = recordtypeid;
        Test.startTest();
        System.runAs(testTrumpf) {    
            insert testOpp;
                
        }
                
        System.runAs(testMobilitySpecialist){
        Opp2update = [select Id from Opportunity where Id = :testOpp.Id];
        try{
                update Opp2update ;
            }catch(Exception e){
                System.assert(true) ;
            }    
        }
        
        
        
        Test.stopTest();
    
    }     
    
    
    
}