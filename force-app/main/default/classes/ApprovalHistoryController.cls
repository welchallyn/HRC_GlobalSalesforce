public class ApprovalHistoryController {

    public List<ApprovalHistoryRecord> ApprovalHistoryRecordsList {get; set;}
    public List<ProcessInstance> workItems {get;set;}
    public Id objectId {get;set;}
    public Boolean canRecall {get;set;}
    public Boolean isRecallCommentsSectionEnabled {get;set;}
    public String recallComments {get;set;}
    public Boolean isRecallButtonVisible {get;set;}
    
    public String TargetObjectLabel {get;set;}
    public String TargetObjectName {get;set;}    
    public List<BMCServiceDesk__Incident__c> incidentsToBeRecalled {get;set;}
    
    public ApprovalHistoryController() {
        ApprovalHistoryRecordsList = new List<ApprovalHistoryRecord>();
        ApprovalHistoryRecordsList = getApprovalHistoryRecords();
        System.debug('ApprovalHistoryRecordsList:'+ApprovalHistoryRecordsList);
        objectId = ApexPages.currentpage().getParameters().get('objectId');
        isRecallButtonVisible = true;
        canBeRecalled();  
    }

    public List<ApprovalHistoryRecord> getApprovalHistoryRecords() {
        ApprovalHistoryRecordsList.clear();
        objectId = ApexPages.currentpage().getParameters().get('objectId');  
        List<ApprovalHistoryRecord> AHR = new List<ApprovalHistoryRecord>();
        List<ProcessInstance> workItems = [SELECT Id, Status, TargetObjectId, TargetObject.Name, CreatedDate, (Select Id, CreatedDate, OriginalActorId, OriginalActor.Name, ProcessInstanceId, ActorId, Actor.Name, StepStatus, Comments From StepsAndWorkItems where StepStatus != 'Reassigned' AND Comments != 'Auto-Approved by system' order by CreatedDate desc, StepStatus)
            FROM ProcessInstance where TargetObjectId =:objectId order by CreatedDate desc];
        for(ProcessInstance pi : workItems) {
            ApprovalHistoryRecordsList.add(new ApprovalHistoryRecord (pi, pi.StepsAndWorkItems));
        }    
        return ApprovalHistoryRecordsList;           
    }
    
    public Boolean canBeRecalled() {
        
        Boolean isPending = false;
        Boolean isSubmitter = false;
        canRecall = false;
        for(ApprovalHistoryRecord eachRecord : ApprovalHistoryRecordsList) {
            System.debug('Each Records Status:'+eachRecord.pi.Status);
            if(eachRecord.pi.Status == 'Pending') {
                isPending = true;
                for(ProcessInstanceHistory eachpih : eachRecord.pih) {
                    System.debug('Step Status:'+eachpih.StepStatus);
                    if(eachpih.StepStatus == 'Started') {
                        Id submitterId = eachpih.ActorId;
                        system.debug('SubmitterId:'+submitterId);
                        if(UserInfo.getuserId() == submitterId) {
                            isSubmitter = true;
                        }
                        break;
                    }
                }                
                break;
            }    
        }
        System.debug('IsPending'+isPending);
        System.debug('IsSubmitter'+isSubmitter);
        if(isPending) {
            Profile p = [select Id, PermissionsModifyAllData from Profile where Id = :UserInfo.getProfileId()];
            if(p.PermissionsModifyAllData || isSubmitter)
                canRecall = true;
            else
                canRecall = false;
        }        
        return canRecall;
    }
    
    public PageReference enableRecallCommentsSection() {
        isRecallCommentsSectionEnabled = true;
        isRecallButtonVisible = false;
        return null;
    }
    
    public PageReference disableRecallCommentsSection() {
        isRecallCommentsSectionEnabled = false;
        isRecallButtonVisible = true;
        return null;
    }
    
    public PageReference recallApprovalRequest() {
        List<ProcessInstanceWorkItem> piwiList = [select Id, ProcessInstance.TargetObjectId from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId = : objectId];
        Approval.ProcessWorkItemRequest pwir = null;
        System.debug('piwiList:'+piwiList);
        
        if(objectId != null) {
            Schema.SObjectType token = objectId.getSObjectType();
            Schema.DescribeSObjectResult dr = token.getDescribe();
            TargetObjectLabel = dr.getLabel();
            TargetObjectName = dr.getName();
        }   
        //If Incident, get the Incident description
        if(TargetObjectName == 'BMCServiceDesk__Incident__c') {
            BMCServiceDesk__Incident__c incidentObj = [SELECT Name, BMCServiceDesk__incidentDescription__c FROM BMCServiceDesk__Incident__c WHERE Id = : objectId LIMIT 1];
            incidentsToBeRecalled = new List<BMCServiceDesk__Incident__c>();
            incidentsToBeRecalled.add(incidentObj); 
            ProcessApprovals p = new ProcessApprovals(incidentsToBeRecalled);
//            p.process();
        }        

        List<ProcessInstanceWorkItem> newPiwiList = [select Id, ProcessInstance.TargetObjectId from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId = : objectId];
        System.debug(newPiwiList);
        if(newPiwiList != null)
        for(ProcessInstanceWorkItem eachpiwi: newPiwiList) {
            pwir = new Approval.ProcessWorkItemRequest();
            pwir.setWorkItemId(eachpiwi.Id);
            pwir.setAction('Removed');
            pwir.setComments(recallComments);
//            try {
                Approval.ProcessResult pr = Approval.process(pwir);
//            }
/*            catch(Exception ex) {
                System.debug('Exception occured:'+ ex);
            } */
            break;
        }
        getApprovalHistoryRecords();
        canRecall = canBeRecalled();
        disableRecallCommentsSection();
        PageReference pg  = new PageReference('/'+objectId);
        pg.setRedirect(true);    
        return pg;                    
    }       
}