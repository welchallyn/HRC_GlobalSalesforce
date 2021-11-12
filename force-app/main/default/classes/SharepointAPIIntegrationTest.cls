@isTest
public class SharepointAPIIntegrationTest {
    public static testmethod void testDoCallout(){
        Test.setMock(HttpCalloutMock.class, new SharepointCalloutMock()); 
        String response = SharepointAPIIntegration.doCallout('test');
        Additional_Account_Info__c accInfo = new Additional_Account_Info__c();
        system.assertEquals('success',response);
    }
    public static testmethod void testDoCallout2(){
        Test.setMock(HttpCalloutMock.class, new SharepointCalloutMock()); 
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Facility').getRecordTypeId();
        insert acc;
        
        String response = SharepointAPIIntegration.doCallout(acc.Id);
        Additional_Account_Info__c accInfo = new Additional_Account_Info__c();
        system.assertEquals('error',response);
    }
}