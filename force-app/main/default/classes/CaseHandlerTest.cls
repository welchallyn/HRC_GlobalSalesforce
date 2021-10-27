/*
    *  ClassName    : CaseHandlerTest 
    *  CreatedOn    : 28th april,2021
    *  ModifiedOn   : 28th april,2021
    *  CreatedBy    : capgemini
    *  ModifiedBy   : capgemini
    *  Description  : used for code coverage of CaseHandler,milestoneUtils classes.
*/
@isTest
public with sharing class CaseHandlerTest {

    @isTest
    public static void testupdateFirstResponse()
    {
        //This code provides data.
        
        User u = [SELECT Id from User WHERE UserType='Standard' AND Active_c__c = 'Y' LIMIT 1];
        System.runAs(u){
            DateTime completionDate = System.now();
            System.debug('UserType'+UserInfo.getUserType());
           
            RecordType recordTypeRequired = [SELECT Id from RecordType WHERE sObjectType = 'Account' AND Name = 'Facility'];
            Id recordTypeRequiredForInsertion = recordTypeRequired.Id;
            
            Account accountForValidation = new Account(Name = 'Test Acc', BillingCity = 'Pune', BillingCountry = 'India', BillingPostalCode = '411057', RecordTypeId = recordTypeRequiredForInsertion);
            insert accountForValidation;
            Id accountForInsertion = accountForValidation.Id;
           
            RecordType recordForContactValidation = [SELECT Id from RecordType WHERE sObjectType = 'Contact' AND Name = 'HRC Contact'];
            Id recordForContactInsertion = recordForContactValidation.Id;
            
            Contact contactForEmailValidation = new Contact(LastName = 'Max', Role__c = 'Administrator', Email = 'test.user@cap.com', Department_UK__c = 'Finance', AccountId = accountForInsertion, RecordTypeId = recordForContactInsertion);
            insert contactForEmailValidation;
            
            //List<Entitlement> entitlementForValidation = [SELECT Id from Entitlement WHERE AccountId =: accountForInsertion];4
             Entitlement createNewEntitlementRecord = new Entitlement();
                   createNewEntitlementRecord.StartDate = Date.today();
                   createNewEntitlementRecord.EndDate = null;
                   createNewEntitlementRecord.Type = 'Phone Support';
                   createNewEntitlementRecord.Name = 'Standard Hill-Rom Entitlement';
                   createNewEntitlementRecord.accountid = accountForInsertion;
            	  // createNewEntitlementRecord.HRCSVC_Active_Status__c = true;	
            	   Asset ast = HRCFSL_TestUtilityClass.createAsset(true);
            		createNewEntitlementRecord.AssetId = ast.Id;
            	
                   
                   insert createNewEntitlementRecord;
            Id entitlementForInsertion = createNewEntitlementRecord.Id;
            
            RecordType recordForCaseValidation = [SELECT Id from RecordType WHERE sObjectType = 'Case' AND Name = 'Scaletronix Service'];
            Id recordForCaseInsertion = recordForCaseValidation.Id;
            
           Case caseForValidation = new Case(Status = 'In Process', Type = 'Inquiry',  SlaStartDate = completionDate, Origin = 'Email', RecordTypeId = recordForCaseInsertion, ContactId = contactForEmailValidation.Id);            
             Schema.Location loc = HRCFSL_TestUtilityClass.createCustomer(true,'12345');
        loc.HRCFSL_Country__c = 'US';
        update loc;
        caseForValidation.HRCSVC_Location__c = loc.Id; 
       //     caseForValidation.AssetId = ast.Id;
            caseForValidation.AccountId = accountForInsertion;
            insert caseForValidation;
            Id caseForInsertion = caseForValidation.Id;
           update caseForValidation;
        }
    }
    
    //Method to check milestone if the case has been closed and contact name starts with 'system','No-reply' or 'noreply'
     @isTest
    public static void testMethod3(){
        RecordType recordTypeRequired = [SELECT Id from RecordType WHERE sObjectType = 'Account' AND Name = 'Facility'];
        Id recordTypeRequiredForInsertion = recordTypeRequired.Id;
        
        Account accountForValidation = new Account(Name = 'Test test', BillingCity = 'Pune', BillingCountry = 'India', BillingPostalCode = '411057', RecordTypeId = recordTypeRequiredForInsertion);
        insert accountForValidation;
        
        RecordType recordForContactValidation = [SELECT Id from RecordType WHERE sObjectType = 'Contact' AND Name = 'HRC Contact'];
            Id recordForContactInsertion = recordForContactValidation.Id;
            
            Contact objContact = new Contact(LastName = 'system', Role__c = 'Administrator', Email = 'test.user.two@cap.com', Department_UK__c = 'Finance', AccountId = accountForValidation.id, RecordTypeId = recordForContactInsertion);
            insert objContact;
            
            List<Entitlement> entitlementForValidation = [SELECT Id from Entitlement WHERE AccountId =: accountForValidation.id];
            Id entitlementForInsertion = entitlementForValidation[0].Id;
            
            RecordType recordForCaseValidation = [SELECT Id from RecordType WHERE sObjectType = 'Case' AND Name = 'Scaletronix Service'];
            Id recordForCaseInsertion = recordForCaseValidation.Id;
            
           Case objCase = new Case(Status = 'In Process',accountid=accountForValidation.id, Type = 'Inquiry', SlaStartDate = date.today(), Origin = 'Email', RecordTypeId = recordForCaseInsertion, ContactId = objContact.Id);            
         Schema.Location loc = HRCFSL_TestUtilityClass.createCustomer(true,'12345');
        loc.HRCFSL_Country__c = 'US';
        update loc;
        objCase.HRCSVC_Location__c = loc.Id;        
        test.startTest();
            insert objCase;
            CaseHandler.isTriggerRun = true;
            objCase.Status='Closed';
        	objCase.HRCSVC_Case_Resolution__c = 'Test';
            update objCase;
            test.stopTest(); 
            
            //CaseMilestone objMileStone = [select Id,IsCompleted from CaseMilestone where caseid=:objCase.id];
            //Check milestone is completed;
                    
            //System.assertEquals(objMileStone.IsCompleted,true);    //
        
    }
    
    @isTest
    public static void testMethod2(){
         //This code provides data.
        
        User u = [SELECT Id from User WHERE UserType='Standard' AND Active_c__c = 'Y' LIMIT 1];
        System.runAs(u){
            DateTime completionDate = System.now();
            System.debug('UserType'+UserInfo.getUserType());
           
            RecordType recordTypeRequired = [SELECT Id from RecordType WHERE sObjectType = 'Account' AND Name = 'Facility'];
            Id recordTypeRequiredForInsertion = recordTypeRequired.Id;
            
            Account accountForValidation = new Account(Name = 'Test test', BillingCity = 'Pune', BillingCountry = 'India', BillingPostalCode = '411057', RecordTypeId = recordTypeRequiredForInsertion);
            insert accountForValidation;
            Id accountForInsertion = accountForValidation.Id;
           
            RecordType recordForContactValidation = [SELECT Id from RecordType WHERE sObjectType = 'Contact' AND Name = 'HRC Contact'];
            Id recordForContactInsertion = recordForContactValidation.Id;
            
            Contact contactForEmailValidation = new Contact(LastName = 'Soni', Role__c = 'Administrator', Email = 'test.user.three@cap.com', Department_UK__c = 'Finance', AccountId = accountForInsertion, RecordTypeId = recordForContactInsertion);
            insert contactForEmailValidation;
            
            
            
             Entitlement createNewEntitlementRecord = new Entitlement();
                   createNewEntitlementRecord.StartDate = Date.today();
                   createNewEntitlementRecord.EndDate = null;
                   createNewEntitlementRecord.Type = 'Phone Support';
                   createNewEntitlementRecord.Name = 'Standard Hill-Rom Entitlement';
                   createNewEntitlementRecord.accountid = accountForInsertion;
                   
                   insert createNewEntitlementRecord;
            
            RecordType recordForCaseValidation = [SELECT Id from RecordType WHERE sObjectType = 'Case' AND Name = 'Junk'];
            Id recordForCaseInsertion = recordForCaseValidation.Id;
           
           
           Case caseForValidation = new Case(Status = 'In Process', Type = 'Inquiry', SlaStartDate = completionDate, Origin = 'Phone', RecordTypeId = recordForCaseInsertion, accountid = accountForInsertion);            
            Schema.Location loc = HRCFSL_TestUtilityClass.createCustomer(true,'12345');
        loc.HRCFSL_Country__c = 'US';
        update loc;
        caseForValidation.HRCSVC_Location__c = loc.Id;
            Contact objContact = new Contact(LastName = 'system', Role__c = 'Administrator', Email = 'tt@cap.com', Department_UK__c = 'Finance', AccountId = accountForValidation.id, RecordTypeId = recordForContactInsertion);
            insert objContact;
            caseForValidation.ContactId = objContact.Id;
            insert caseForValidation;
            
            Id caseForInsertion = caseForValidation.Id;
            case objCase = [select id,EntitlementId from case where id=:caseForInsertion limit 1];
            
        }
    }
}