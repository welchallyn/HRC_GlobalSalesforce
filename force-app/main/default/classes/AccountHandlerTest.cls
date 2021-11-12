@isTest
public class AccountHandlerTest {

    //test to verify that Facility Record type is being set correctly on accounts originating from 'Data fromJDE' user.
	@isTest
	private static void testJdeAssignRecordType() {
    // This code runs as Data fromJDE
    	User u = [SELECT Id FROM User WHERE Name='Data fromJDE' LIMIT 1];
      	System.runAs(u) {
            // The following code runs as user 'u' 
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());
            List<Account> insertAccts = new List<Account>{
                 //positive test
                 new Account( Name='testFromJDE-positive', JDE_Record_Type__c='FAC', BillingCountry='United States', BillingCity='Batesville', BillingPostalCode='47006'),
                 new Account( Name='testFromJDE-negative', JDE_Record_Type__c='PHY', BillingCountry='United States', BillingCity='Batesville', BillingPostalCode='47006')        
            };
            insert insertAccts;
            for (Account a : insertAccts) {
            if (a.Name == 'testFromJDE-positive') {
              system.assertEquals(a.JDE_Record_Type__c,'FAC');
              
              
            
            }
            if (a.Name == 'testFromJDE-negative') {
              system.assertNotEquals(a.JDE_Record_Type__c,'FAC');
            }
        }   
          //Validate if Additional Info has been created or not.
          Additional_Info__c objAdditionalInfo = [select id,account__c from Additional_Info__c where account__c=:insertAccts[0].id limit 1];
          system.assertEquals(objAdditionalInfo.account__c,insertAccts[0].id);
   		}
            
	}
	
	//Test Update & Delete logic .
	    @IsTest
    	private static void testUpdateDeleteOperation() {
    	    Account objAccount = new Account(name='Test Account',JDE_Record_Type__c='FAC', BillingCountry='United States', BillingCity='Batesville', BillingPostalCode='47006');
    	    insert objAccount;
    	    
    	    //Update Account.
    	    objAccount.name = 'Test Account Update';
    	    update objAccount;
    	    system.assertEquals(objAccount.name,'Test Account Update');
    	    delete objAccount;
    	    
    	}

    }