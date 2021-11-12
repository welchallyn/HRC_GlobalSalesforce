/*
    *  ClassName    : EmailMessageHandlerTest 
    *  CreatedOn    : 21th Nov,2017
    *  ModifiedOn   : 4th Dec,2017
    *  CreatedBy    : Jenish Shingala
    *  ModifiedBy   : Jenish Shingala
    *  Description  : used for code coverage of EmailMessageHandler,CaseHandler,milestoneUtils classes.
*/
@isTest
public with sharing class EmailMessageHandlerTest {

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
            
            Account accountForValidation = new Account(Name = 'Test Pratyush', BillingCity = 'Pune', BillingCountry = 'India', BillingPostalCode = '411057', RecordTypeId = recordTypeRequiredForInsertion);
            insert accountForValidation;
            Id accountForInsertion = accountForValidation.Id;
           
            RecordType recordForContactValidation = [SELECT Id from RecordType WHERE sObjectType = 'Contact' AND Name = 'HRC Contact'];
            Id recordForContactInsertion = recordForContactValidation.Id;
            
            Contact contactForEmailValidation = new Contact(LastName = 'Soni', Role__c = 'Administrator', Email = 'jenish.shingala@kpit.com', Department_UK__c = 'Finance', AccountId = accountForInsertion, RecordTypeId = recordForContactInsertion);
            insert contactForEmailValidation;
            
            List<Entitlement> entitlementForValidation = [SELECT Id from Entitlement WHERE AccountId =: accountForInsertion];
            Id entitlementForInsertion = entitlementForValidation[0].Id;
            
            RecordType recordForCaseValidation = [SELECT Id from RecordType WHERE sObjectType = 'Case' AND Name = 'Scaletronix Service'];
            Id recordForCaseInsertion = recordForCaseValidation.Id;
            
           Case caseForValidation = new Case(Status = 'In Process', Type = 'Inquiry', EntitlementId = entitlementForInsertion, SlaStartDate = completionDate, Origin = 'Email', RecordTypeId = recordForCaseInsertion, ContactId = contactForEmailValidation.Id);            
            insert caseForValidation;
            Id caseForInsertion = caseForValidation.Id;
            
            List<EmailMessage> emailMessageForCases = new List<EmailMessage>{
                new EmailMessage(FromAddress = 'testscaletronix@welchallyn.com', FromName ='Pratyush', Incoming = false, IsExternallyVisible = false, Subject = 'TestPratyush', ParentId = caseForInsertion, ToAddress = 'jenish.shingala@kpit.com', TextBody = 'Testing For EmailMessage', HTMLBody = 'HTML BOdy test'),
                new EmailMessage(FromAddress = 'testscaletronix@welchallyn.com', FromName ='Jenish', Incoming = false, IsExternallyVisible = false, Subject = 'TestJenish', ParentId = caseForInsertion, ToAddress = 'jenish.shingala@kpit.com', TextBody = 'Testing For EmailMessage', HTMLBody = 'HTML BOdy test')
            };
            insert emailMessageForCases;
            
            for(EmailMessage emailMessage:emailMessageForCases)
            {
                if(emailMessage.FromName == 'Pratyush'){
                    System.assertEquals(emailMessage.Incoming,false);    
                }
                
                if(emailMessage.FromName == 'Jenish'){
                    System.assertEquals(emailMessage.Incoming,false);
                }
            }
            
            //Assertion if a Case has been logged.
            Case caseForAssertion = [SELECT Id,Status,EntitlementId,SlaStartDate,SlaExitDate from Case WHERE Id =: caseForValidation.Id];
            System.assertEquals(caseForAssertion.Status,'In Process');
            System.assertEquals(caseForAssertion.EntitlementId,entitlementForInsertion);
            System.assertEquals(caseForAssertion.SlaStartDate,completionDate);
            System.assertEquals(caseForAssertion.SlaExitDate,null);
            
            List<Id> casesToBeSentForMilestone = new List<Id>();
            casesToBeSentForMilestone.add(caseForAssertion.Id);
            
            if(casesToBeSentForMilestone.isEmpty() == false)
            {
                milestoneUtils.completeMilestone(casesToBeSentForMilestone,'First Response',completionDate);
            }
            
            //Check whether milestone is completed or not.
            CaseMilestone objMileStone = [select Id, completionDate,IsCompleted from CaseMilestone where caseId in :casesToBeSentForMilestone and MilestoneType.Name='First Response' limit 1];
            system.assertEquals(objMileStone.IsCompleted,true);
        }
    }
    
    //Method to check milestone if the case has been closed and contact name starts with 'system','No-reply' or 'noreply'
     @isTest
    public static void testMethod3(){
        RecordType recordTypeRequired = [SELECT Id from RecordType WHERE sObjectType = 'Account' AND Name = 'Facility'];
        Id recordTypeRequiredForInsertion = recordTypeRequired.Id;
        
        Account accountForValidation = new Account(Name = 'Test jenish', BillingCity = 'Pune', BillingCountry = 'India', BillingPostalCode = '411057', RecordTypeId = recordTypeRequiredForInsertion);
        insert accountForValidation;
        
        RecordType recordForContactValidation = [SELECT Id from RecordType WHERE sObjectType = 'Contact' AND Name = 'HRC Contact'];
            Id recordForContactInsertion = recordForContactValidation.Id;
            
            Contact objContact = new Contact(LastName = 'system', Role__c = 'Administrator', Email = 'jenish.shingala@kpit.com', Department_UK__c = 'Finance', AccountId = accountForValidation.id, RecordTypeId = recordForContactInsertion);
            insert objContact;
            
            List<Entitlement> entitlementForValidation = [SELECT Id from Entitlement WHERE AccountId =: accountForValidation.id];
            Id entitlementForInsertion = entitlementForValidation[0].Id;
            
            RecordType recordForCaseValidation = [SELECT Id from RecordType WHERE sObjectType = 'Case' AND Name = 'Scaletronix Service'];
            Id recordForCaseInsertion = recordForCaseValidation.Id;
            
           Case objCase = new Case(Status = 'In Process',accountid=accountForValidation.id, Type = 'Inquiry', SlaStartDate = date.today(), Origin = 'Email', RecordTypeId = recordForCaseInsertion, ContactId = objContact.Id);            
            test.startTest();
            insert objCase;
            CaseHandler.isTriggerRun = true;
            objCase.Status='Closed';
            update objCase;
            test.stopTest(); 
            
            CaseMilestone objMileStone = [select Id,IsCompleted from CaseMilestone where caseid=:objCase.id];
            //Check milestone is completed;
                    
            System.assertEquals(objMileStone.IsCompleted,true);    
        
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
            
            Account accountForValidation = new Account(Name = 'Test jenish', BillingCity = 'Pune', BillingCountry = 'India', BillingPostalCode = '411057', RecordTypeId = recordTypeRequiredForInsertion);
            insert accountForValidation;
            Id accountForInsertion = accountForValidation.Id;
           
            RecordType recordForContactValidation = [SELECT Id from RecordType WHERE sObjectType = 'Contact' AND Name = 'HRC Contact'];
            Id recordForContactInsertion = recordForContactValidation.Id;
            
            Contact contactForEmailValidation = new Contact(LastName = 'Soni', Role__c = 'Administrator', Email = 'jenish.shingala@kpit.com', Department_UK__c = 'Finance', AccountId = accountForInsertion, RecordTypeId = recordForContactInsertion);
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
            insert caseForValidation;
            
            Id caseForInsertion = caseForValidation.Id;
            case objCase = [select id,EntitlementId from case where id=:caseForInsertion limit 1];
            
            //Check if case has Entitlement of type 'Phone Support'.
            System.assertEquals(objCase.EntitlementId,createNewEntitlementRecord.id);  
            
            List<EmailMessage> emailMessageForCases = new List<EmailMessage>{
                new EmailMessage(FromAddress = 'testscaletronix@welchallyn.com', FromName ='Pratyush', Incoming = false, IsExternallyVisible = false, Subject = 'TestPratyush', ParentId = caseForInsertion, ToAddress = 'jenish.shingala@kpit.com', TextBody = 'Testing For EmailMessage', HTMLBody = 'HTML BOdy test'),
                new EmailMessage(FromAddress = 'testscaletronix@welchallyn.com', FromName ='Jenish', Incoming = false, IsExternallyVisible = false, Subject = 'TestJenish', ParentId = caseForInsertion, ToAddress = 'jenish.shingala@kpit.com', TextBody = 'Testing For EmailMessage', HTMLBody = 'HTML BOdy test')
            };
            insert emailMessageForCases;
            
            for(EmailMessage emailMessage:emailMessageForCases)
            {
                if(emailMessage.FromName == 'Pratyush'){
                    System.assertEquals(emailMessage.Incoming,false);    
                }
                
                if(emailMessage.FromName == 'Jenish'){
                    System.assertEquals(emailMessage.Incoming,false);
                }
            }
            
            //Assertion if a Case has been logged.
            Case caseForAssertion = [SELECT Id,Status,EntitlementId,SlaStartDate,SlaExitDate from Case WHERE Id =: caseForValidation.Id];
            System.assertEquals(caseForAssertion.Status,'In Process');
                        
            List<Id> casesToBeSentForMilestone = new List<Id>();
            casesToBeSentForMilestone.add(caseForAssertion.Id);
            
            if(casesToBeSentForMilestone.isEmpty() == false)
            {
                milestoneUtils.completeMilestone(casesToBeSentForMilestone,'First Response',completionDate);
            }
            
            
        }
    }
}