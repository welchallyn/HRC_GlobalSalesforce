@isTest
private class TestAssignAccountRecordTypeFromJDE {

    static testMethod void runTest() {
	  	 Account_Record_Type_Ids__c art 
	  	   = new Account_Record_Type_Ids__c(name = 'FACx',
	  	                                    RecordTypeId__c = [Select Id from RecordType where SObjectType = 'Account' Limit 1].Id );
	  	 insert art;                   
	     
	     Account a = new Account(Name = 'x', JDE_Record_Type__c = 'FACx');
	     try{
	        insert a;
	     }
	     catch(Exception e){}
	  }

}