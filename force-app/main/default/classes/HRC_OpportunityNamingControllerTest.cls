@isTest
private class HRC_OpportunityNamingControllerTest {

    public static testMethod void myUnitTest () {
        
        Account testAccount1 = new Account(name='test account123');
        Account testAccount2 = new Account(name='test account246');
        
        List<Account> accounts = new List<Account>();
        accounts.add(testAccount1);
        accounts.add(testAccount2);
 
        insert accounts; 
        
        Contact testcontact = new Contact(firstname='test', lastname = 'contact', email = 'salesforcetest@hill-rom.com');
        insert testcontact;
        
        List<RecordType> rt = [select Id, Name from RecordType where SObjectType = 'Opportunity' order by name limit 4];
        
        Opportunity testOpp = new Opportunity(AccountId=testAccount1.id, Name='Test Opportunity123');
        testOpp.Return_Type__c = 'None';
        testOpp.StageName = 'Qualified Opportunity';
        testOpp.CloseDate = system.today();
        testOpp.RMA_Date_1__c = system.today();
        testOpp.RMA_Price_1__c = 100.00 ;
        testOpp.RMA_Product_1__c = 'test product' ;
        testOpp.RMA_Quantity_1__c = 10 ;
        testOpp.RecordTypeId = rt[0].Id; 
        testOpp.Order_Contact__c = testcontact.id;
  
        insert testOpp;

        System.debug('-->testOpp.Name ' + testOpp.Name);
        System.debug('-->rt[0].Name ' + rt[0].Name);
        testOpp = [select Id, Name from Opportunity where Id = :testOpp.Id];
        
        System.assert(testOpp.Name == testAccount1.Name +'-' + rt[0].Name + '~' + 'Test Opportunity123' );
        
        testOpp.Name = 'Test Updated Opportunity123';
        update testOpp;
        testOpp = [select Id, Name from Opportunity where Id = :testOpp.Id];
        
        System.assert(testOpp.Name == testAccount1.Name +'-' + rt[0].Name + '~' + 'Test Updated Opportunity123' );
        
        testOpp.AccountId = testAccount2.Id;
        update testOpp;
        testOpp = [select Id, Name, AccountId from Opportunity where Id = :testOpp.Id];
        System.assert(testOpp.Name == testAccount2.Name + '-' + rt[0].Name + '~' + 'Test Updated Opportunity123' );
        
        testOpp.RecordTypeId = rt[3].Id;
        update testOpp;
        testOpp = [select Id, Name, RecordTypeId from Opportunity where Id = :testOpp.Id];
        System.assert(testOpp.Name == testAccount2.Name + '-' + rt[3].Name + '~' + 'Test Updated Opportunity123' );
        
    }

}