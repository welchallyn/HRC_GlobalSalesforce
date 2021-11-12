@isTest(seeAllData=true)
public class SubmitForApprovalControllerTest{

public static testmethod void submitForApprovalTest(){

  BMCServiceDesk__Status__c CRId = [Select Id from BMCServiceDesk__Status__c where Name = 'REVIEW+AUTHORIZATION']; 
  
  BMCServiceDesk__Change_Request__c newCR = new BMCServiceDesk__Change_Request__c(
        BMCServiceDesk__FKInitiator__c=UserInfo.getUserid(),Product_Catalog_Tier_1__c='Voice',BMCServiceDesk__Change_Type__c='Emergency',BMCServiceDesk__FKStatus__c=CRId.Id);
        insert newCR; 
        
        PageReference p = Page.SubmitForApproval;
        p.getParameters().put('objectId',newCR.Id);
        Test.setCurrentPage(p);
        
        SubmitForApprovalController s = new SubmitForApprovalController();
        s.getIsSubmittedForApproval();
        s.submitForApproval() ; 
        
 }
 }