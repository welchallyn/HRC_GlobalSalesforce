/*
    *  ClassName    : AttachmentHandlerTest
    *  CreatedOn    : 24/Oct/2016
    *  ModifiedOn   : 24/Oct/2016
    *  CreatedBy    : Jenish Shingala
    *  ModifiedBy   : Jenish Shingala
    *  Description  : This class contains unit tests for validating the behavior of Apex classes and triggers.
*/

@isTest
private class AttachmentHandlerTest {
    
    @isTest
    public static void attachmentTriggerMainTest() {
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
        
        //Create Attachment.
        Attachment objAttachment = new Attachment();
        objAttachment.name = 'test attachment';
        objAttachment.body = blob.valueOf('test body');
        objAttachment.parentId = objOpportunity.id;
        insert objAttachment;
        
        objAttachment.name = 'Test body1';
        update objAttachment;
        
        Opportunity getOpportunity = [select id,Attachment_Last_Update__c from opportunity where id=:objOpportunity.id limit 1];
                
        //Assertion for Opportunity OppLMD.
        system.assertEquals(getOpportunity.Attachment_Last_Update__c,Date.Today());
        
        delete objAttachment;
        
    }
}