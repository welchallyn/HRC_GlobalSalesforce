@istest
public class BatchAlignOpportunityOwner1Test {

    //Test Method
    //
    
    static  testmethod void testThisClass() {
        
        
        //create the data for the test
        Account testAccount = new Account(name='test account34');
        insert testAccount;
        if(testAccount.id !=Null){
        
        Account_Team_Role__c atr = new Account_Team_Role__c(AccountId__c = testAccount.id
                                                           ,UserId__c = UserInfo.getUserId()
                                                           ,Position__c = 'test-x',CurrencyIsoCode ='USD');
        insert atr;
        
        
        Opportunity testOpp = new Opportunity(AccountId=testAccount.id, Name='Test Opportunity234343');
        testOpp.Return_Type__c = 'None';
        testOpp.StageName = 'Qualified Opportunity';
        testOpp.CloseDate = system.today();
        testOpp.RMA_Date_1__c = system.today();
        testOpp.RMA_Price_1__c = 100.00 ;
        testOpp.RMA_Product_1__c = 'test product' ;
        testOpp.RMA_Quantity_1__c = 10 ;
        testOpp.ReAssign_Owner__c=true;
        insert testOpp;
        
        //retrieve the default record type
        testOpp = [select Id, RecordType.Name from Opportunity where id = :testOpp.Id];
        
        //add the custom setting record
        Opportunity_Record_Type_Position_Map__c orp = new Opportunity_Record_Type_Position_Map__c(name = testOpp.RecordType.Name
                                                                                                ,positions__c = 'test-x,test-y,test-z');
         
       insert orp;
                
        //Run the batch job
        Test.startTest();
        
        BatchAlignOpportunityOwner1 b = new BatchAlignOpportunityOwner1();
        database.executebatch(b,200);
        
        Test.stopTest();
        
        //verify that the opportunity owner is set appropriatly
        System.AssertEquals(UserInfo.getUserId(), [Select OwnerId from Opportunity where id = :testOpp.Id].OwnerId);
     }
     }
    
    
 
    static  testmethod void testThisClassForElse() {
        //create the data for the test
      
        List<Account> acct = new List<Account>{new Account(name='test account 18'),new Account(name='test account 2')};
        //Account testAccount = new Account(name='test account 1');
        insert acct;
        
        if(acct!=null && !acct.isEmpty()){
        User userRec = new User(LastName='Pissani',Username='alice.pissani@hillrom.com',Email='alice.pissani@hillrom.com',Alias='APissani',TimeZoneSidKey= 'America/Los_Angeles'
                               ,LocaleSidKey='en_US',EmailEncodingKey='UTF-8',ProfileId='00eE0000000lrRK',LanguageLocaleKey='en_US',isActive=true);
        insert userRec;
        
        Account_Team_Role__c atr = new Account_Team_Role__c(AccountId__c = acct[0].id
                                                           ,UserId__c = userRec.Id
                                                           ,Position__c = 'test-a', CurrencyIsoCode ='USD');
        insert atr;
        
        //system.debug('Account_Team_Role__c==>>'+atr.Id+','+atr.AccountId__c+','+atr.AccountId__r.Name);
        Opportunity testOpp = new Opportunity(AccountId=acct[0].id, Name='Test Opportunity234343');
        testOpp.Return_Type__c = 'None';
        testOpp.StageName = 'Qualified Opportunity';
        testOpp.CloseDate = system.today();
        testOpp.RMA_Date_1__c = system.today();
        testOpp.RMA_Price_1__c = 100.00 ;
        testOpp.RMA_Product_1__c = 'test product' ;
        testOpp.RMA_Quantity_1__c = 10 ;
            testOpp.ReAssign_Owner__c=true;
       // testOpp.RecordTypeId = 'a0DE0000002sGXW';
        insert testOpp;
        
        //retrieve the default record type
        testOpp = [select Id, RecordType.Name from Opportunity where id = :testOpp.Id];
        
        //add the custom setting record
        Opportunity_Record_Type_Position_Map__c orp = new Opportunity_Record_Type_Position_Map__c(name = testOpp.RecordType.Name
                                                                                                ,positions__c = 'test-a,test-y,test-z');
       insert orp;
         
        //Run the batch job
        Test.startTest();
        
        BatchAlignOpportunityOwner1 b = new BatchAlignOpportunityOwner1();
        database.executebatch(b,200);
        
        Test.stopTest();
        }
    }
}