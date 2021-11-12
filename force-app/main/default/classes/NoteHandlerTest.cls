/*
    *  ClassName    : NoteHandlerTest
    *  CreatedOn    : 21/Oct/2016
    *  ModifiedOn   : 21/Oct/2016
    *  CreatedBy    : Jenish Shingala
    *  ModifiedBy   : Jenish Shingala
    *  Description  : This class contains unit tests for validating the behavior of Apex classes and triggers.
*/

@isTest
private class NoteHandlerTest {
    
    @isTest
    public static void noteTriggerMainTest() {
        //Create Account.
        Account objAccount = new Account( Name='testFromJDE-positive', JDE_Record_Type__c='FAC', BillingCountry='United States', 
        BillingCity='Batesville', BillingPostalCode='47006');
        insert objAccount;
        
        //Create Contact.
        Contact objContact = new Contact(lastName = 'test last name',Role__c='Risk Management',email='sftest@hill-rom.com',accountId = objAccount.id);
        insert objContact;
        
        //Create Opportunity.
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test Opportunity';
        objOpportunity.accountId = objAccount.id;
        objOpportunity.closeDate = Date.today().adddays(1);
        objOpportunity.stageName = 'Price Reasons';
        insert objOpportunity;
        
        //Create Note.
        Note objNote = new Note();
        objNote.title = 'test note';
        objNote.body = 'test body';
        objNote.parentId = objOpportunity.id;
        insert objNote;
        
        objNote.body = 'Test body1';
        update objNote;
        
        Opportunity getOpportunity = [select id,Note_Last_Update__c from opportunity where id=:objOpportunity.id limit 1];
                
        //Assertion for Opportunity OppLMD.
        system.assertEquals(getOpportunity.Note_Last_Update__c,Date.Today());
        
    }
}