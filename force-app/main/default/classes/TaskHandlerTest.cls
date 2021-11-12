/*
 *  ClassName    : TaskHandlerTest
 *  CreatedOn    : 21/Oct/2016
 *  ModifiedOn   : 22/Jan/2018
 *  CreatedBy    : Jenish Shingala
 *  ModifiedBy   : Jenish Shingala
 *  Description  : This class contains unit tests for validating the behavior of Apex classes and triggers.. 
 */

@isTest  
public class TaskHandlerTest {
   
   @isTest
   public static  void taskTriggerMain() {
   	    //Create Account.
   	    Account objAccount = new Account( Name='testFromJDE-positive', JDE_Record_Type__c='FAC', BillingCountry='United States', 
   	    BillingCity='Batesville', BillingPostalCode='47006');
   	    insert objAccount;
   	    
   	    //Create Contact.
   	    Contact objContact = new Contact(lastName = 'test last name',Role__c='Risk Management',accountId = objAccount.id,Email='test@gmail.com');
   	    insert objContact;
   	    
        //Create Opportunity.
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test Opportunity';
        objOpportunity.accountId = objAccount.id;
        objOpportunity.closeDate = Date.today().adddays(1);
        objOpportunity.stageName = 'Price Reasons';
        insert objOpportunity;
        
        
        
        //Create Task.
        String userId = UserInfo.getUserId();

		Task objTask = new Task();
		objTask.OwnerId = userId;
		objTask.RecordTypeId = [Select Id from RecordType where SObjectType = 'Task' Limit 1].Id;
		objTask.Subject = 'Hello World';
		objTask.Status = 'Open';
		objTask.Priority = 'Normal';
		objTask.WhatId = objOpportunity.Id;
		insert objTask;
		
		       
        
        objTask.Subject = 'Hello World1';
        update objTask;
        
        Opportunity getOpportunity = [select id,Activity_Last_Update__c from opportunity where id=:objOpportunity.id limit 1];
                
        //Assertion for Opportunity OppLMD.
        system.assertEquals(getOpportunity.Activity_Last_Update__c,Date.Today());
        
        delete objTask;
        
        
        
    }
    
    @isTest
   public static  void taskTriggerMain2() {
        RecordType recordTypeRequired = [SELECT Id from RecordType WHERE sObjectType = 'Account' AND Name = 'Facility'];
        Id recordTypeRequiredForInsertion = recordTypeRequired.Id;
        
        Account accountForValidation = new Account(Name = 'Test', BillingCity = 'Pune', BillingCountry = 'India', BillingPostalCode = '411057', RecordTypeId = recordTypeRequiredForInsertion);
        insert accountForValidation;
        
        List<Entitlement> entitlementForValidation = [SELECT Id from Entitlement WHERE AccountId =: accountForValidation.id];
        Id entitlementForInsertion = entitlementForValidation[0].Id;
        
        RecordType recordForCaseValidation = [SELECT Id from RecordType WHERE sObjectType = 'Case' AND Name = 'Scaletronix Service'];
        Id recordForCaseInsertion = recordForCaseValidation.Id;
        
        Case caseForValidation = new Case(Status = 'In Process', Type = 'Inquiry', EntitlementId = entitlementForInsertion, SlaStartDate = system.Today(),Origin = 'Email', RecordTypeId = recordForCaseInsertion, accountid = accountForValidation.id);            
        insert caseForValidation;
        
        String userId = UserInfo.getUserId();

		Task objTask = new Task();
		objTask.OwnerId = userId;
		objTask.RecordTypeId = [Select Id from RecordType where SObjectType = 'Task' Limit 1].Id;
		objTask.Subject = 'Hello World';
		objTask.Status = 'Completed';
		objTask.type = 'Call';
		objTask.Priority = 'Normal';
		objTask.WhatId = caseForValidation.Id;
		insert objTask;
		
		 List<Id> casesToBeSentForMilestone = new List<Id>();
         casesToBeSentForMilestone.add(caseForValidation.Id);
         
         //Check whether milestone is completed or not.
            CaseMilestone objMileStone = [select Id, completionDate,IsCompleted from CaseMilestone where caseId in :casesToBeSentForMilestone and MilestoneType.Name='First Response' limit 1];
            system.assertEquals(objMileStone.IsCompleted,true);
   }
}