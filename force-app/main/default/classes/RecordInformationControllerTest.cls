@isTest(seeAllData=true)
public class RecordInformationControllerTest {

    public static testmethod void RecordInformationTest() {
    
        BMCServiceDesk__Category__c newCategory = new BMCServiceDesk__Category__c(Name='testCategory',BMCServiceDesk__AvailableForIncidents__c=true);
        insert newCategory;
 
        BMCServiceDesk__Incident__c newIncident = new BMCServiceDesk__Incident__c(BMCServiceDesk__FKClient__c= UserInfo.getUserid() , BMCServiceDesk__FKCategory__c=newCategory.id, Operational_Catalog_Tier_1__c='Install/Add/Create',Operational_Catalog_Tier_2__c='Security',Product_Catalog_Tier_2__c='GEMINI', OwnerId=UserInfo.getUserid());
        insert newIncident;
        
        BMCServiceDesk__Change_Request__c newCR = new BMCServiceDesk__Change_Request__c(
            BMCServiceDesk__FKInitiator__c=UserInfo.getUserid() , BMCServiceDesk__FKCategory__c=newCategory.id);
        insert newCR; 
        
        // Testing rejection functionality
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval automatically');
        req1.setObjectId(newIncident.id);
        req1.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        Approval.ProcessResult result1 = Approval.process(req1);
        
        PageReference pageRef1 = Page.RecordInformation;
        pageRef1.getParameters().put('objectId', newIncident.Id);
        
        List<Id> newWorkItemIds = result1.getNewWorkItemIds();
        pageRef1.getParameters().put('workItemId', newWorkItemIds[0]);
        
        Schema.DescribeSObjectResult dr = newIncident.Id.getSObjectType().getDescribe();
        String TargetObjectLabel = dr.getLabel();
        String TargetObjectName = dr.getName();
        pageRef1.getParameters().put('TargetObjectLabel', TargetObjectLabel);
        pageRef1.getParameters().put('TargetObjectName', TargetObjectName);
        
        Test.setCurrentPage(pageRef1);
    
        RecordInformationController ric1 = new RecordInformationController();
        ric1.reject();
        
        //Testing successful approval functionality
        Approval.ProcessSubmitRequest req2 = new Approval.ProcessSubmitRequest();
        req2.setComments('Submitting request for approval automatically');
        req2.setObjectId(newIncident.id);
        req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        Approval.ProcessResult result2 = Approval.process(req2);
        
        PageReference pageRef2 = Page.RecordInformation;
        pageRef2.getParameters().put('objectId', newCR.Id);
        
        List<Id> newWorkItemIds2 = result2.getNewWorkItemIds();
        pageRef2.getParameters().put('workItemId', newWorkItemIds2[0]);
        
        Schema.DescribeSObjectResult dr2 = newCR.Id.getSObjectType().getDescribe();
        String TargetObjectLabel2 = dr2.getLabel();
        String TargetObjectName2 = dr2.getName();
        pageRef2.getParameters().put('TargetObjectLabel', TargetObjectLabel2);
        pageRef2.getParameters().put('TargetObjectName', TargetObjectName2);
        
        Test.setCurrentPage(pageRef2);
        RecordInformationController ric2 = new RecordInformationController();
        
        ric2.userName = UserInfo.getUserName();
        ric2.login();
        ric2.approve();
        
        
        ric2.clearpageMessages();
        test.startTest();
        // Testing the error case where an approval process may fail (ProcessinstanceWorkItem Id not provided
        Approval.ProcessSubmitRequest req3 = new Approval.ProcessSubmitRequest();
        req3.setComments('Submitting request for approval automatically');
        req3.setObjectId(newIncident.id);
        req3.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        Approval.ProcessResult result3 = Approval.process(req3);
        
        PageReference pageRef3 = Page.RecordInformation;
        pageRef3.getParameters().put('objectId', newIncident.Id);
        
        List<Id> newWorkItemIds3 = result3.getNewWorkItemIds();
//      pageRef3.getParameters().put('workItemId', newWorkItemIds2[0]);
        
        Schema.DescribeSObjectResult dr3 = newIncident.Id.getSObjectType().getDescribe();
        String TargetObjectLabel3 = dr3.getLabel();
        String TargetObjectName3 = dr3.getName();
        pageRef3.getParameters().put('TargetObjectLabel', TargetObjectLabel3);
        pageRef3.getParameters().put('TargetObjectName', TargetObjectName3);
        
        Test.setCurrentPage(pageRef3);
        RecordInformationController ric3 = new RecordInformationController();
        
        ric3.userName = UserInfo.getUserName().substring(0,UserInfo.getUserName().length()-2);
        ric3.login();
        
        // Tring to approve a already approved/rejected record
        ric3.userName = UserInfo.getUserName();
        ric3.reject();
        ric3.login(); 
        
        // Testing Approval functionality for a Task record 
        BMCServiceDesk__Task__c newTask =  new BMCServiceDesk__Task__c (
            BMCServiceDesk__FKClient__c= UserInfo.getUserid() , BMCServiceDesk__FKCategory__c=newCategory.id, OwnerId=UserInfo.getUserid());
        insert newTask;
        
        PageReference pageRef4 = Page.RecordInformation;
        pageRef4.getParameters().put('objectId', newTask.Id);
        Schema.DescribeSObjectResult dr4 = newTask.Id.getSObjectType().getDescribe();
        String TargetObjectLabel4 = dr4.getLabel();
        String TargetObjectName4 = dr4.getName();
        pageRef4.getParameters().put('TargetObjectLabel', TargetObjectLabel4);
        pageRef4.getParameters().put('TargetObjectName', TargetObjectName4);
        Test.setCurrentPage(pageRef4);
        RecordInformationController ric4 = new RecordInformationController();
        test.stopTest();
    }
}