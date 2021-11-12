/*
    *  ClassName    : ContentNoteHandlerTest
    *  CreatedOn    : 11th Jan,2018
    *  CreatedBy    : Jenish Shingala
    *  ModifiedBy   : Jenish Shingala
    *  Description  : This class contains unit tests for validating the behavior of Apex classes and triggers.
*/
@isTest
public with sharing class ContentNoteHandlerTest {

	@isTest
	public static void test() {
        //Create Account.
   	    Account objAccount = new Account( Name='testFromJDE-positive', JDE_Record_Type__c='FAC', BillingCountry='United States', 
   	    BillingCity='Batesville', BillingPostalCode='47006');
   	    insert objAccount;
   	   
        //Create Opportunity.
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test Opportunity';
        objOpportunity.accountId = objAccount.id;
        objOpportunity.closeDate = Date.today().adddays(1);
        objOpportunity.stageName = 'Price Reasons';
        insert objOpportunity;
        
        ContentNote cn = new ContentNote();
        cn.Title = 'test1';
        String body = 'Test body';
        cn.Content = Blob.valueOf(body.escapeHTML4());
        insert cn;
        
        ContentDocumentLink newCD = new ContentDocumentLink();
        newCD.ContentDocumentId = cn.id;
        newCD.LinkedEntityId = objOpportunity.id;
        newCD.ShareType = 'V';
        newCD.Visibility = 'AllUsers';
        insert newCD;
        
        Opportunity getOpportunity = [select id,Note_Last_Update__c from opportunity where id=:objOpportunity.id limit 1];
                
        //Assertion for Opportunity OppLMD.
        system.assertEquals(getOpportunity.Note_Last_Update__c,Date.Today());
	}

}