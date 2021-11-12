@isTest
public class ContentDocumentLinkTriggerHandlerTest {
    public static testMethod void dataSetup(){
        User objeUser = [Select Id, ProfileId from User where name = 'Joffrey Marechal'];
        system.runAs(objeUser){
        Test.startTest();
        Evaluation_Form__c eval = new Evaluation_Form__c();
        insert eval;
        ContentVersion content=new ContentVersion(); 
        content.Title='Leihvertrag'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        content.origin = 'H';
        content.PathOnClient   = 'Leihvertrag.doc';
        insert content;
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=eval.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        ContentDocument cd = [select id from ContentDocument where id = :contentlink.contentdocumentid];
            delete cd;
        Test.stopTest();
        system.assertEquals(false, [Select Id,has_contract__c from Evaluation_Form__c where id = :eval.id].has_contract__c);
        }
    }

}