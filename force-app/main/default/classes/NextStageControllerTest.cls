@isTest(seeAllData=true)
public class NextStageControllerTest{

  //Test for ChangeType Normal
  public static testmethod void NextStageTest() {
     test.StartTest();
     BMCServiceDesk__Change_Request__c changeRecord = new BMCServiceDesk__Change_Request__c(BMCServiceDesk__FKInitiator__c=UserInfo.getUserid(), BMCServiceDesk__Change_Type__c = 'Normal', Support_Group_Name__c = 'HRC-DBA-CHGMGR');
     insert changeRecord; 
     PageReference pageRef1 = Page.NextStage;
     pageRef1.getParameters().put('changeType', changeRecord.BMCServiceDesk__Change_Type__c);
     pageRef1.getParameters().put('status', 'INITIATE');
     pageRef1.getParameters().put('changeId', changeRecord.Id);
     pageRef1.getParameters().put('redirectId','default');
     Test.setCurrentPage(pageRef1);
     NextStageController ns1 = new NextStageController();
     ns1.ChangeRecordApproval();
      try{
     ProcessInstanceWorkItem wi = [Select Id, ProcessInstanceId, ActorId, Actor.Name, Createddate, ProcessInstance.TargetObjectId, ProcessInstance.Status, ProcessInstance.CreatedDate From ProcessInstanceWorkItem Where isDeleted = false and ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId = :changeRecord.Id LIMIT 1];
      
      Approval.ProcessWorkItemRequest req = new Approval.ProcessWorkItemRequest();
     req.setAction('Approve');
     req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
     req.setWorkitemId(wi.Id);
     Approval.ProcessResult result = Approval.process(req);
          System.assertEquals('Approved', result.getInstanceStatus());
          }
            catch(Exception e){
                System.debug('Exception '+e);
            }
     
     test.StopTest();
    }
    
    public static testmethod void NextStageTest1() {
     test.StartTest();
     Id PlanScheduleID = [select id from BMCServiceDesk__Status__c where Name='PLAN+SCHEDULE'].Id;
     BMCServiceDesk__Change_Request__c changeRecord0 = new BMCServiceDesk__Change_Request__c(BMCServiceDesk__FKStatus__c = PlanScheduleID, Plan_Approved__c = 2, BMCServiceDesk__FKInitiator__c=UserInfo.getUserid(), BMCServiceDesk__Change_Type__c = 'Normal', Support_Group_Name__c = 'HRC-DBA-CHGMGR');
     insert changeRecord0;  
     PageReference pageRef2 = Page.NextStage;
     pageRef2.getParameters().put('changeType', changeRecord0.BMCServiceDesk__Change_Type__c);
     pageRef2.getParameters().put('status', 'PLAN SCHEDULE');
     pageRef2.getParameters().put('changeId', changeRecord0.Id);
     pageRef2.getParameters().put('redirectId','default');
     Test.setCurrentPage(pageRef2);    
     NextStageController ns2 = new NextStageController();
     ns2.ChangeRecordApproval();   
    /* ProcessInstanceWorkItem wi1 = [Select Id, ProcessInstanceId, ActorId, Actor.Name, Createddate, ProcessInstance.TargetObjectId, ProcessInstance.Status, ProcessInstance.CreatedDate From ProcessInstanceWorkItem Where isDeleted = false and ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId = :changeRecord0.Id LIMIT 1];
     Approval.ProcessWorkItemRequest req1 = new Approval.ProcessWorkItemRequest();
     req1.setAction('Approve');
     req1.setNextApproverIds(new Id[] {UserInfo.getUserId()});
     req1.setWorkitemId(wi1.Id);
     Approval.ProcessResult result1 = Approval.process(req1);*/
     test.StopTest();
     }
     
     /*public static testmethod void NextStageTest2() {
     test.StartTest();
     Id ImplementID = [select id from BMCServiceDesk__Status__c where Name='IMPLEMENT'].Id;
     BMCServiceDesk__Change_Request__c changeRecord00 = new BMCServiceDesk__Change_Request__c(BMCServiceDesk__FKStatus__c = ImplementID, Implement_Approved__c = 2, BMCServiceDesk__FKInitiator__c=UserInfo.getUserid(), BMCServiceDesk__Change_Type__c = 'Normal', Support_Group_Name__c = 'HRC-DBA-CHGMGR');
     insert changeRecord00;     
     PageReference pageRef3 = Page.NextStage;
     pageRef3.getParameters().put('changeType', changeRecord00.BMCServiceDesk__Change_Type__c);
     pageRef3.getParameters().put('status', 'IMPLEMENT');
     pageRef3.getParameters().put('changeId', changeRecord00.Id);
     Test.setCurrentPage(pageRef3);     
     NextStageController ns3 = new NextStageController();
     ns3.ChangeRecordApproval();
     test.StopTest();
     }*/
     
     //Test for ChangeType Emergency
     public static testmethod void NextStageTest3() {
     test.StartTest();    
     BMCServiceDesk__Change_Request__c changeRecord1 = new BMCServiceDesk__Change_Request__c(BMCServiceDesk__FKInitiator__c=UserInfo.getUserid(), BMCServiceDesk__Change_Type__c = 'Emergency', Support_Group_Name__c = 'HRC-DBA-CHGMGR');
     insert changeRecord1;    
     PageReference pageRef4 = Page.NextStage;
     pageRef4.getParameters().put('changeType', changeRecord1.BMCServiceDesk__Change_Type__c);
     pageRef4.getParameters().put('status', 'INITIATE');
     pageRef4.getParameters().put('changeId', changeRecord1.Id);
     pageRef4.getParameters().put('redirectId','default');
     Test.setCurrentPage(pageRef4);     
     NextStageController ns4 = new NextStageController();
     ns4.ChangeRecordApproval();
         try{
     ProcessInstanceWorkItem wi3 = [Select Id, ProcessInstanceId, ActorId, Actor.Name, Createddate, ProcessInstance.TargetObjectId, ProcessInstance.Status, ProcessInstance.CreatedDate From ProcessInstanceWorkItem Where isDeleted = false and ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId = :changeRecord1.Id LIMIT 1];
         
         Approval.ProcessWorkItemRequest req3 = new Approval.ProcessWorkItemRequest();
     req3.setAction('Approve');
     req3.setNextApproverIds(new Id[] {UserInfo.getUserId()});
     req3.setWorkitemId(wi3.Id);
     Approval.ProcessResult result3 = Approval.process(req3);
         }
            catch(Exception e){
                System.debug('Exception '+e);
            }
     test.StopTest();
     }
     
     public static testmethod void NextStageTest4() {
     test.StartTest();
     Id ReviewID = [select id from BMCServiceDesk__Status__c where Name='REVIEW+AUTHORIZATION'].Id;
     BMCServiceDesk__Change_Request__c changeRecord11 = new BMCServiceDesk__Change_Request__c(BMCServiceDesk__FKStatus__c = ReviewID, Review_Approved__c = 2, BMCServiceDesk__FKInitiator__c=UserInfo.getUserid(), BMCServiceDesk__Change_Type__c = 'Emergency', Support_Group_Name__c = 'HRC-DBA-CHGMGR');
     insert changeRecord11;
     PageReference pageRef5 = Page.NextStage;
     pageRef5.getParameters().put('changeType', changeRecord11.BMCServiceDesk__Change_Type__c);
     pageRef5.getParameters().put('status', 'REVIEW AUTHORIZATION');
     pageRef5.getParameters().put('changeId', changeRecord11.Id);
     pageRef5.getParameters().put('redirectId','default');
     Test.setCurrentPage(pageRef5);    
     NextStageController ns5 = new NextStageController();
     ns5.ChangeRecordApproval();
         try{
     ProcessInstanceWorkItem wi4 = [Select Id, ProcessInstanceId, ActorId, Actor.Name, Createddate, ProcessInstance.TargetObjectId, ProcessInstance.Status, ProcessInstance.CreatedDate From ProcessInstanceWorkItem Where isDeleted = false and ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId = :changeRecord11.Id LIMIT 1];
         
         Approval.ProcessWorkItemRequest req4 = new Approval.ProcessWorkItemRequest();
     req4.setAction('Approve');
     req4.setNextApproverIds(new Id[] {UserInfo.getUserId()});
     req4.setWorkitemId(wi4.Id);
     Approval.ProcessResult result4 = Approval.process(req4);
             }
            catch(Exception e){
                System.debug('Exception '+e);
            }
     test.StopTest();
     }
     
     public static testmethod void NextStageTest5() {
     test.StartTest();
     Id PlanID = [select id from BMCServiceDesk__Status__c where Name='PLAN+SCHEDULE'].Id;
     BMCServiceDesk__Change_Request__c changeRecord12 = new BMCServiceDesk__Change_Request__c(BMCServiceDesk__FKStatus__c = PlanID, Plan_Approved__c = 2, BMCServiceDesk__FKInitiator__c=UserInfo.getUserid(), BMCServiceDesk__Change_Type__c = 'Emergency', Support_Group_Name__c = 'HRC-DBA-CHGMGR');
     insert changeRecord12;
     PageReference pageRef6 = Page.NextStage;
     pageRef6.getParameters().put('changeType', changeRecord12.BMCServiceDesk__Change_Type__c);
     pageRef6.getParameters().put('status', 'PLAN SCHEDULE');
     pageRef6.getParameters().put('changeId', changeRecord12.Id);
     pageRef6.getParameters().put('redirectId','default');
     Test.setCurrentPage(pageRef6);     
     NextStageController ns6 = new NextStageController();
     ns6.ChangeRecordApproval();
         try{
     ProcessInstanceWorkItem wi5 = [Select Id, ProcessInstanceId, ActorId, Actor.Name, Createddate, ProcessInstance.TargetObjectId, ProcessInstance.Status, ProcessInstance.CreatedDate From ProcessInstanceWorkItem Where isDeleted = false and ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId = :changeRecord12.Id LIMIT 1];
         
             Approval.ProcessWorkItemRequest req5 = new Approval.ProcessWorkItemRequest();
     req5.setAction('Approve');
     req5.setNextApproverIds(new Id[] {UserInfo.getUserId()});
     req5.setWorkitemId(wi5.Id);
     Approval.ProcessResult result5 = Approval.process(req5);
             }
            catch(Exception e){
                System.debug('Exception '+e);
            }
     test.StopTest();
     }
     
     /*public static testmethod void NextStageTest6() {
     test.StartTest();
     Id ImplementID = [select id from BMCServiceDesk__Status__c where Name='IMPLEMENT'].Id;
     BMCServiceDesk__Change_Request__c changeRecord13 = new BMCServiceDesk__Change_Request__c(BMCServiceDesk__FKStatus__c = ImplementID, Implement_Approved__c = 2, BMCServiceDesk__FKInitiator__c=UserInfo.getUserid(), BMCServiceDesk__Change_Type__c = 'Emergency', Support_Group_Name__c = 'HRC-DBA-CHGMGR');
     insert changeRecord13;
     PageReference pageRef7 = Page.NextStage;
     pageRef7.getParameters().put('changeType', changeRecord13.BMCServiceDesk__Change_Type__c);
     pageRef7.getParameters().put('status', 'IMPLEMENT');
     pageRef7.getParameters().put('changeId', changeRecord13.Id);
     Test.setCurrentPage(pageRef7);    
     NextStageController ns7 = new NextStageController();
     ns7.ChangeRecordApproval();
     test.StopTest();
     }*/
     
     //Test for ChangeType Standard
     public static testmethod void NextStageTest7() {
     test.StartTest();
     BMCServiceDesk__Change_Request__c changeRecord2 = new BMCServiceDesk__Change_Request__c(BMCServiceDesk__FKInitiator__c=UserInfo.getUserid(), BMCServiceDesk__Change_Type__c = 'Standard', Support_Group_Name__c = 'HRC-DBA-CHGMGR');
     insert changeRecord2;    
     PageReference pageRef8 = Page.NextStage;
     pageRef8.getParameters().put('changeType', changeRecord2.BMCServiceDesk__Change_Type__c);
     pageRef8.getParameters().put('status', 'INITIATE');
     pageRef8.getParameters().put('changeId', changeRecord2.Id); 
     pageRef8.getParameters().put('redirectId','default');
     Test.setCurrentPage(pageRef8);    
     NextStageController ns8 = new NextStageController();
     ns8.ChangeRecordApproval();
         try{
     ProcessInstanceWorkItem wi7 = [Select Id, ProcessInstanceId, ActorId, Actor.Name, Createddate, ProcessInstance.TargetObjectId, ProcessInstance.Status, ProcessInstance.CreatedDate From ProcessInstanceWorkItem Where isDeleted = false and ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId = :changeRecord2.Id LIMIT 1];
         
         Approval.ProcessWorkItemRequest req7 = new Approval.ProcessWorkItemRequest();
     req7.setAction('Approve');
     req7.setNextApproverIds(new Id[] {UserInfo.getUserId()});
     req7.setWorkitemId(wi7.Id);
     Approval.ProcessResult result7 = Approval.process(req7);
             }
            catch(Exception e){
                System.debug('Exception '+e);
            }
     test.StopTest();
     }
     
     public static testmethod void NextStageTest8() {
     test.StartTest();
     Id ReviewID = [select id from BMCServiceDesk__Status__c where Name='REVIEW+AUTHORIZATION'].Id;
     BMCServiceDesk__Change_Request__c changeRecord21 = new BMCServiceDesk__Change_Request__c(BMCServiceDesk__FKStatus__c = ReviewID, Review_Approved__c = 2, BMCServiceDesk__FKInitiator__c=UserInfo.getUserid(), BMCServiceDesk__Change_Type__c = 'Standard', Support_Group_Name__c = 'HRC-DBA-CHGMGR');
     insert changeRecord21;
     PageReference pageRef9 = Page.NextStage;
     pageRef9.getParameters().put('changeType', changeRecord21.BMCServiceDesk__Change_Type__c);
     pageRef9.getParameters().put('status', 'REVIEW AUTHORIZATION');
     pageRef9.getParameters().put('changeId', changeRecord21.Id);
     pageRef9.getParameters().put('redirectId','default');
     Test.setCurrentPage(pageRef9);     
     NextStageController ns9 = new NextStageController();
     ns9.ChangeRecordApproval();
         try{
     ProcessInstanceWorkItem wi8 = [Select Id, ProcessInstanceId, ActorId, Actor.Name, Createddate, ProcessInstance.TargetObjectId, ProcessInstance.Status, ProcessInstance.CreatedDate From ProcessInstanceWorkItem Where isDeleted = false and ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId = :changeRecord21.Id LIMIT 1];
         
         Approval.ProcessWorkItemRequest req8 = new Approval.ProcessWorkItemRequest();
     req8.setAction('Approve');
     req8.setNextApproverIds(new Id[] {UserInfo.getUserId()});
     req8.setWorkitemId(wi8.Id);
     Approval.ProcessResult result8 = Approval.process(req8);
             }
            catch(Exception e){
                System.debug('Exception '+e);
            }
     test.StopTest();
     }
     
     public static testmethod void NextStageTest9() {
     test.StartTest();
     Id PlanID = [select id from BMCServiceDesk__Status__c where Name='PLAN+SCHEDULE'].Id;
     BMCServiceDesk__Change_Request__c changeRecord22 = new BMCServiceDesk__Change_Request__c(BMCServiceDesk__FKStatus__c = PlanID, Plan_Approved__c = 2, BMCServiceDesk__FKInitiator__c=UserInfo.getUserid(), BMCServiceDesk__Change_Type__c = 'Standard', Support_Group_Name__c = 'HRC-DBA-CHGMGR');
     insert changeRecord22;
     PageReference pageRef10 = Page.NextStage;
     pageRef10.getParameters().put('changeType', changeRecord22.BMCServiceDesk__Change_Type__c);
     pageRef10.getParameters().put('status', 'PLAN SCHEDULE');
     pageRef10.getParameters().put('changeId', changeRecord22.Id);
     pageRef10.getParameters().put('redirectId','default');
     Test.setCurrentPage(pageRef10);    
     NextStageController ns10 = new NextStageController();
     ns10.ChangeRecordApproval();
         try{
     ProcessInstanceWorkItem wi9 = [Select Id, ProcessInstanceId, ActorId, Actor.Name, Createddate, ProcessInstance.TargetObjectId, ProcessInstance.Status, ProcessInstance.CreatedDate From ProcessInstanceWorkItem Where isDeleted = false and ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId = :changeRecord22.Id LIMIT 1];
         
         Approval.ProcessWorkItemRequest req9 = new Approval.ProcessWorkItemRequest();
     req9.setAction('Approve');
     req9.setNextApproverIds(new Id[] {UserInfo.getUserId()});
     req9.setWorkitemId(wi9.Id);
     Approval.ProcessResult result9 = Approval.process(req9);
             }
            catch(Exception e){
                System.debug('Exception '+e);
            }
     test.StopTest();
     }
     
     /*public static testmethod void NextStageTest10() {
     test.StartTest();
     Id ImplementID = [select id from BMCServiceDesk__Status__c where Name='IMPLEMENT'].Id;
     BMCServiceDesk__Change_Request__c changeRecord23 = new BMCServiceDesk__Change_Request__c(BMCServiceDesk__FKStatus__c = ImplementID, Implement_Approved__c = 2, BMCServiceDesk__FKInitiator__c=UserInfo.getUserid(), BMCServiceDesk__Change_Type__c = 'Standard', Support_Group_Name__c = 'HRC-DBA-CHGMGR');
     insert changeRecord23;
     PageReference pageRef11 = Page.NextStage;
     pageRef11.getParameters().put('changeType', changeRecord23.BMCServiceDesk__Change_Type__c);
     pageRef11.getParameters().put('status', 'IMPLEMENT');
     pageRef11.getParameters().put('changeId', changeRecord23.Id);
     Test.setCurrentPage(pageRef11);    
     NextStageController ns11 = new NextStageController();
     ns11.ChangeRecordApproval();
     ProcessInstanceWorkItem wi10 = [Select Id, ProcessInstanceId, ActorId, Actor.Name, Createddate, ProcessInstance.TargetObjectId, ProcessInstance.Status, ProcessInstance.CreatedDate From ProcessInstanceWorkItem Where isDeleted = false and ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId = :changeRecord23.Id LIMIT 1];
     Approval.ProcessWorkItemRequest req10 = new Approval.ProcessWorkItemRequest();
     req10.setAction('Approve');
     req10.setNextApproverIds(new Id[] {UserInfo.getUserId()});
     req10.setWorkitemId(wi10.Id);
     Approval.ProcessResult result10 = Approval.process(req10);
     test.StopTest();
     }*/
     
     public static testmethod void NextStageTest11() {
     test.StartTest();
     Id CompletedID = [select id from BMCServiceDesk__Status__c where Name='COMPLETED'].Id;
     BMCServiceDesk__Change_Request__c changeRecord24 = new BMCServiceDesk__Change_Request__c(BMCServiceDesk__FKStatus__c = CompletedID, Completed_Approved__c = 2,BMCServiceDesk__FKInitiator__c=UserInfo.getUserid(), BMCServiceDesk__Change_Type__c = 'Standard', Support_Group_Name__c = 'HRC-DBA-CHGMGR');
     insert changeRecord24;
     PageReference pageRef12 = Page.NextStage;
     pageRef12.getParameters().put('changeType', changeRecord24.BMCServiceDesk__Change_Type__c);
     pageRef12.getParameters().put('status', 'COMPLETED');
     pageRef12.getParameters().put('changeId', changeRecord24.Id);
     pageRef12.getParameters().put('redirectId','default');
     Test.setCurrentPage(pageRef12);    
     NextStageController ns12 = new NextStageController();
     ns12.ChangeRecordApproval();
     test.StopTest();
     }
     
     //Test for changetype normal with closedown
  public static testmethod void NextStageTest12() {
     test.StartTest();
     BMCServiceDesk__Change_Request__c changeRecord = new BMCServiceDesk__Change_Request__c(BMCServiceDesk__FKInitiator__c=UserInfo.getUserid(), BMCServiceDesk__Change_Type__c = 'Normal with Close Down', Support_Group_Name__c = 'HRC-DBA-CHGMGR');
     insert changeRecord; 
     PageReference pageRef1 = Page.NextStage;
     pageRef1.getParameters().put('changeType', changeRecord.BMCServiceDesk__Change_Type__c);
     pageRef1.getParameters().put('status', 'INITIATE');
     pageRef1.getParameters().put('changeId', changeRecord.Id);
     pageRef1.getParameters().put('redirectId','default');
     Test.setCurrentPage(pageRef1);
     NextStageController ns1 = new NextStageController();
     ns1.ChangeRecordApproval();
    /* List<ProcessInstanceWorkItem> wi = [Select Id, ProcessInstanceId, ActorId, Actor.Name, Createddate, ProcessInstance.TargetObjectId, ProcessInstance.Status, ProcessInstance.CreatedDate From ProcessInstanceWorkItem Where isDeleted = false and ProcessInstance.Status = 'Pending' and ProcessInstance.TargetObjectId = :changeRecord.Id LIMIT 1];
     Approval.ProcessWorkItemRequest req = new Approval.ProcessWorkItemRequest();
     req.setAction('Approve');
     req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
     req.setWorkitemId(wi[0].Id);
     Approval.ProcessResult result = Approval.process(req);
     System.assertEquals('Approved', result.getInstanceStatus());*/
     test.StopTest();
    }
    
    public static testmethod void NextStageTest13() {
     test.StartTest();
     Id PlanScheduleID = [select id from BMCServiceDesk__Status__c where Name='PLAN+SCHEDULE'].Id;
     BMCServiceDesk__Change_Request__c changeRecord0 = new BMCServiceDesk__Change_Request__c(BMCServiceDesk__FKStatus__c = PlanScheduleID, Plan_Approved__c = 2, BMCServiceDesk__FKInitiator__c=UserInfo.getUserid(), BMCServiceDesk__Change_Type__c = 'Normal with Close Down', Support_Group_Name__c = 'HRC-DBA-CHGMGR');
     insert changeRecord0;  
     PageReference pageRef2 = Page.NextStage;
     pageRef2.getParameters().put('changeType', changeRecord0.BMCServiceDesk__Change_Type__c);
     pageRef2.getParameters().put('status', 'PLAN SCHEDULE');
     pageRef2.getParameters().put('changeId', changeRecord0.Id);
     pageRef2.getParameters().put('redirectId','default');
     Test.setCurrentPage(pageRef2);    
     NextStageController ns2 = new NextStageController();
     ns2.ChangeRecordApproval();   
     test.StopTest();
     }
     
     public static testmethod void NextStageTest14() {
     test.StartTest();
     Id CompletedID = [select id from BMCServiceDesk__Status__c where Name='COMPLETED'].Id;
     BMCServiceDesk__Change_Request__c changeRecord24 = new BMCServiceDesk__Change_Request__c(BMCServiceDesk__FKStatus__c = CompletedID, Completed_Approved__c = 2,BMCServiceDesk__FKInitiator__c=UserInfo.getUserid(), BMCServiceDesk__Change_Type__c = 'Normal with Close Down', Support_Group_Name__c = 'HRC-DBA-CHGMGR');
     insert changeRecord24;
     PageReference pageRef12 = Page.NextStage;
     pageRef12.getParameters().put('changeType', changeRecord24.BMCServiceDesk__Change_Type__c);
     pageRef12.getParameters().put('status', 'COMPLETED');
     pageRef12.getParameters().put('changeId', changeRecord24.Id);
     pageRef12.getParameters().put('redirectId','default');
     Test.setCurrentPage(pageRef12);    
     NextStageController ns12 = new NextStageController();
     ns12.ChangeRecordApproval();
     test.StopTest();
     }
     
   
}