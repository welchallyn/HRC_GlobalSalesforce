/**********************************************************************************************************************************************
* Name                             :  HRCSVC_ContentVersionTrigger_Test
* Author                           :  Kushagra Bansal
* Date                             :  March/22/2021
* Requirement/Project Name         :  Hill-Rom
* Requirement/Project Description  :  Test class for the HRCSVC_ContentVersionTrigger, part of the components developed for SE-1770.
/**********************************************************************************************************************************************/
@isTest
public class HRCSVC_ContentVersionTrigger_Test {
    
    public static testMethod void testRunAsSM() {
        String uniqueUserName = 'servicemanager' + DateTime.now().getTime() + '@capgemini.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='HRC Service Manager'];
        User u = new User(Alias = 'standt', Email='servicemanager@capgemini.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        
        System.runAs(u) 
        {
            List<ContentVersion> cvList = new List<ContentVersion>();
            for(Integer i=1;i<=10;i++){
                ContentVersion cv = new ContentVersion();
                cv.Title = 'Test Document';
                cv.PathOnClient = 'TestDocument.pdf';
                cv.VersionData = Blob.valueOf('Test Content');
                cv.IsMajorVersion = true;
                cvList.add(cv);
            }    
            Test.startTest();
            insert cvList; 
            List<ContentVersion> cvInserted= [SELECT Id,HRCSVC_AEM_Visibility__c FROM ContentVersion];            
            Test.stopTest();
            for(ContentVersion cv:cvInserted){
                System.assertNotEquals('Private',cv.HRCSVC_AEM_Visibility__c,'HRCSVC_AEM_Visibility__c should be not be Private, since user is case management user');
            }   
        }
    }
    
    public static testMethod void testRunAsSA() {
        String uniqueUserName = 'servicemanager' + DateTime.now().getTime() + '@capgemini.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='HRC Service Agent'];
        User u = new User(Alias = 'standt', Email='servicemanager@capgemini.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        
        System.runAs(u) 
        {
            List<ContentVersion> cvList = new List<ContentVersion>();
            for(Integer i=1;i<=10;i++){
                ContentVersion cv = new ContentVersion();
                cv.Title = 'Test Document';
                cv.PathOnClient = 'TestDocument.pdf';
                cv.VersionData = Blob.valueOf('Test Content');
                cv.IsMajorVersion = true;
                cvList.add(cv);
            }    
            Test.startTest();
            insert cvList; 
            List<ContentVersion> cvInserted= [SELECT Id,HRCSVC_AEM_Visibility__c FROM ContentVersion];
            Test.stopTest();
            for(ContentVersion cv:cvInserted){
                System.assertNotEquals('Private',cv.HRCSVC_AEM_Visibility__c,'HRCSVC_AEM_Visibility__c should be not be Private, since user is case management user');
            }   
        }
    }
    
    public static testMethod void testPublicLiinkGeneration() {
        String uniqueUserName = 'servicemanager' + DateTime.now().getTime() + '@capgemini.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='HRC Service Agent'];
        User u = new User(Alias = 'standt', Email='servicemanager@capgemini.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        
        System.runAs(u) 
        {
            List<ContentVersion> cvList = new List<ContentVersion>();
            for(Integer i=1;i<=10;i++){
                ContentVersion cv = new ContentVersion();
                cv.Title = 'Test Document';
                cv.PathOnClient = 'TestDocument.pdf';
                cv.VersionData = Blob.valueOf('Test Content');
                cv.IsMajorVersion = true;
                cv.HRCSVC_AEM_Visibility__c = 'Public';
                cvList.add(cv);
            }    
            Test.startTest();
            insert cvList; 
            List<ContentVersion> cvInserted= [SELECT Id,HRCSVC_AEM_Visibility__c FROM ContentVersion];
            ContentDistribution cdURL = [SELECT Id,DistributionPublicUrl FROM ContentDistribution WHERE ContentVersionId = :cvInserted[0].Id LIMIT 1];
            Test.stopTest();
            for(ContentVersion cv:cvInserted){
                System.assertNotEquals('Private',cv.HRCSVC_AEM_Visibility__c,'HRCSVC_AEM_Visibility__c should be not be Private, since user is case management user');
            }   
   			System.assertNotEquals(null, cdURL, 'Public URL Should get generated'); 
        }
    }
    
    
}