@isTest(seeAllData=true)
public class ApprovalHistoryControllerTest {

    public static testmethod void ApprovalHistoryTest() {
        
        BMCServiceDesk__Status__c CRId = [Select Id from BMCServiceDesk__Status__c where Name = 'REVIEW+AUTHORIZATION'];
    
    
       BMCServiceDesk__Change_Request__c newCR = new BMCServiceDesk__Change_Request__c(
            BMCServiceDesk__FKInitiator__c=UserInfo.getUserid(),Product_Catalog_Tier_1__c='Voice',BMCServiceDesk__Change_Type__c='Emergency',BMCServiceDesk__FKStatus__c=CRId.Id);
        insert newCR; 
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval automatically');
        req1.setObjectId(newCR.id);
        Approval.ProcessResult result1 = Approval.process(req1);
        
        PageReference pageRef1 = Page.ApprovalHistory;
        pageRef1.getParameters().put('objectId', newCR.Id);
    
        Test.setCurrentPage(pageRef1);

        ApprovalHistoryController a= new ApprovalHistoryController();
        System.debug('ApprvalHistory records List:'+ a.ApprovalHistoryRecordsList);
        a.enableRecallCommentsSection();
        
        a.disableRecallCommentsSection();
        
        a.recallApprovalRequest();
        
        BMCServiceDesk__Change_Request__c newCR1 = new BMCServiceDesk__Change_Request__c(
            BMCServiceDesk__FKInitiator__c=UserInfo.getUserid(), Product_Catalog_Tier_1__c='Voice',BMCServiceDesk__Change_Type__c='Emergency',BMCServiceDesk__FKStatus__c=CRId.Id);
        insert newCR1; 
        
        
        Approval.ProcessSubmitRequest req2 = new Approval.ProcessSubmitRequest();
        req2.setComments('Submitting request for approval automatically');
        req2.setObjectId(newCR1.id);
        Approval.ProcessResult result2 = Approval.process(req2);
        
        PageReference pageRef2 = Page.ApprovalHistory;
        pageRef2.getParameters().put('objectId', newCR1.Id);
        
            
        Test.setCurrentPage(pageRef2);

        ApprovalHistoryController a1= new ApprovalHistoryController();
        System.debug('ApprvalHistory records List:'+ a1.ApprovalHistoryRecordsList);
        a1.enableRecallCommentsSection();
        
        a1.disableRecallCommentsSection();
        
       
        
               
    }
}