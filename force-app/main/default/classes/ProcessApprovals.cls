public class ProcessApprovals {

    List<BMCServiceDesk__Incident__c> allNewIncidents;
    public List<ProcessInstanceWorkItem> toBeAutoApprovedList  = new List<ProcessInstanceWorkItem>();
    public Map<String, Id> approvalRoleMappings = new Map<String, Id>();
    public List<ProcessInstanceWorkItem> newApprovalsList = new List<ProcessInstanceWorkItem>();
    public List<ApprovalHistoryRecord> ApprovalHistoryRecordsList;
    public set<Id> recallableIncidentIds = new set<Id>();
    public Map<Id,List<ProcessInstanceWorkItem>> piwiMap = new Map<Id,List<ProcessInstanceWorkItem>>();
    List<BMCServiceDesk__Incident__c> unprocessedApprovalsIncidentsList = new List<BMCServiceDesk__Incident__c>();
    List<ProcessInstanceWorkItem> toBeRecalledItems = new List<ProcessInstanceWorkItem>();
    Approval.ProcessWorkItemRequest newRequestForApproval;
    public String objectId = null;
    String cognosValue = null;
    String jdedwardsValue = null;
    String cognosValue2 = null;
    String jdedwardsValue2 = null;
    HillRom_Settings__c COGNOS_CATEGORY = HillRom_Settings__c.getValues('COGNOS');
    HillRom_Settings__c JDEDWARDS_CATEGORY = HillRom_Settings__c.getValues('JD EDWARDS');
    HillRom_Settings__c COGNOS2_CATEGORY = HillRom_Settings__c.getValues('COGNOS2');
    HillRom_Settings__c JDEDWARDS2_CATEGORY = HillRom_Settings__c.getValues('JD EDWARDS2');
    
       
        
        
    
    
    public ProcessApprovals(List<BMCServiceDesk__Incident__c> allIncidents) {
        if(allIncidents!=null && allIncidents.size()>0)
            allNewIncidents = [select Id, Name, Product_Catalog_Tier_2__c, Approval_processed__c, Cognos_Roles__c, Cognos_Roles_2__c, JD_Edwards_Roles__c, JD_Edwards_Roles2__c from BMCServiceDesk__Incident__c where Id=:allIncidents];
        
        if(COGNOS_CATEGORY != null){
        cognosValue = COGNOS_CATEGORY.value__c;
        }
        if(COGNOS2_CATEGORY != null){
        cognosValue2 = COGNOS2_CATEGORY.value__c;
        }
        if(JDEDWARDS_CATEGORY != null){
        jdedwardsValue = JDEDWARDS_CATEGORY .value__c;
        }
        if(JDEDWARDS2_CATEGORY != null){
        jdedwardsValue2 = JDEDWARDS_CATEGORY .value__c;
        }
        process();
    }
    
    
    public void process() {
        
        if(allNewIncidents!=null && allNewIncidents.size()>0) {

            for(BMCServiceDesk__Incident__c eachIncident : allNewIncidents){
                if(eachIncident.Approval_processed__c == false) {
                    unprocessedApprovalsIncidentsList.add(eachIncident);
                }
            }

            String requestCategoryString;
            String [] requestCategories;
            List<ProcessInstanceWorkItem> eachWorkItemsList;
            Set<Id> requestCategoryApprovers;
            List<Id> requestCategoryApproversList;
            Id requestCategoryOwnerId;
            Integer startIndex = 0;
            Integer endIndex = 0;
            List<BMCServiceDesk__Incident__c> incidentsList = new List<BMCServiceDesk__Incident__c>();
            Set<Id> incidentIdSet = new Set<Id>();
            System.debug('In finish');
            List<ApprovalRoleMapping__c> approvalRoleMappingsList = [select Name, OwnerId from ApprovalRoleMapping__c limit 20000];
            List<ProcessInstanceWorkItem> piwiList;
            
            if(approvalRoleMappingsList != null){
                for(ApprovalRoleMapping__c eachApprovalMapping : approvalRoleMappingsList)
                    approvalRoleMappings.put(eachApprovalMapping.Name, eachApprovalMapping.OwnerId);
             }
            
            List<ProcessInstance> workItems = [SELECT Id, Status, TargetObjectId, TargetObject.Name, CreatedDate, (Select Id, CreatedDate, OriginalActorId, OriginalActor.Name, ProcessInstanceId, ActorId, Actor.Name, StepStatus, Comments From StepsAndWorkItems order by CreatedDate desc, StepStatus)
                   FROM ProcessInstance where TargetObjectId =:allNewIncidents order by CreatedDate desc];
                    
            List<ProcessInstanceWorkitem> piwi = [SELECT Id,CreatedDate, OriginalActorId, OriginalActor.Name, ProcessInstanceId, ProcessInstance.TargetObjectId, ActorId, Actor.Name From ProcessInstanceWorkitem where ProcessInstanceId =:workItems order by CreatedDate desc];
            if(piwi!=null && piwi.size()>0) {
                for(ProcessInstanceWorkItem eachpiwi : piwi){
                        piwiList = piwiMap.get(eachpiwi.ProcessInstance.TargetObjectId);
                        if(piwiList == null){
                            piwiList = new List<ProcessInstanceWorkItem>();
                        }
                        piwiList.add(eachpiwi);
                        piwiMap.put(eachpiwi.ProcessInstance.TargetObjectId, piwiList);
                        System.debug('Piwi list'+piwiList);
                }
            }
            
            for(BMCServiceDesk__Incident__c  eachIncident : unprocessedApprovalsIncidentsList) {
                 if(eachIncident.Product_Catalog_Tier_2__c == cognosValue && eachIncident.Cognos_Roles__c!= null)
                     requestCategoryString = String.valueOf(eachIncident.Cognos_Roles__c);
                 else if(eachIncident.Product_Catalog_Tier_2__c == jdedwardsValue && eachIncident.JD_Edwards_Roles__c != null)
                     requestCategoryString = String.valueOf(eachIncident.JD_Edwards_Roles__c); 
                 else if(eachIncident.Product_Catalog_Tier_2__c == jdedwardsValue2 && eachIncident.JD_Edwards_Roles2__c!= null)
                     requestCategoryString = String.valueOf(eachIncident.JD_Edwards_Roles2__c);
                 else if(eachIncident.Product_Catalog_Tier_2__c == cognosValue2 && eachIncident.Cognos_Roles_2__c   != null)
                     requestCategoryString = String.valueOf(eachIncident.Cognos_Roles_2__c  );
                 
                System.debug('Roles selected full string'+requestCategoryString );        
                if(requestCategoryString != null){
                    requestCategories = requestCategoryString.split(';');
                    System.debug('requestCategories:before adding genericapproval&&&&&& '+requestCategories);
                    Integer listSize= requestCategories.size();
                    System.debug('requestCategories size before adding&^$*^$: '+requestCategories.size());
                    if(eachIncident.Product_Catalog_Tier_2__c == jdedwardsValue )
                        requestCategories.add('GenericApproval');
                }
                else
                    requestCategories = null;
                    
                System.debug('requestCategories: '+requestCategories);
                
                if(requestCategories != null) {
                    System.debug('requestCategories size after adding8975: '+requestCategories.size());
                    
                    requestCategoryApprovers = new Set<Id>();
                    requestCategoryApproversList = new List<Id>();
                    if(requestCategories != null && requestCategories.size() > 0) {
                        for(String eachRequestCategory : requestCategories) {
                            requestCategoryOwnerId = approvalRoleMappings.get(eachRequestCategory);
                            if(requestCategoryOwnerId != null && !requestCategoryApprovers.contains(requestCategoryOwnerId)) {
                                requestCategoryApprovers.add(requestCategoryOwnerId);
                                requestCategoryApproversList.add(requestCategoryOwnerId);
                            }
                        }
                    }
                    
                    requestCategoryApproversList.sort();
                    System.debug('requestCategoryApprovers:'+requestCategoryApprovers);
                    System.debug('requestCategoryApproversList:'+requestCategoryApproversList);
                    eachWorkItemsList = piwiMap.get(eachIncident.Id);
                    System.debug('eachWorkItemsList:'+eachWorkItemsList);
                    startIndex = 0;
                    for(Id eachRequestCategoryApprover : requestCategoryApproversList) {
                        System.debug('Start Index:'+ startIndex);
                        System.debug('approver in list'+eachWorkItemsList[startIndex].Actor.Name);
                        System.debug('approver in get list'+eachRequestCategoryApprover);
                        if(eachWorkItemsList[startIndex].ActorId != eachRequestCategoryApprover) {
                        System.debug('approver in inside%^&$*&*&^before list'+eachWorkItemsList[startIndex].Actor.Name);
                            eachWorkItemsList[startIndex].ActorId = eachRequestCategoryApprover;
                            eachWorkItemsList[startIndex].OriginalActorId = eachRequestCategoryApprover;
                            System.debug('approver in inside%^&$*&*&^ list'+eachWorkItemsList[startIndex].Actor.Name);
                            newApprovalsList.add(eachWorkItemsList[startIndex]);
                        }
                        startIndex = startIndex + 1;
                        endIndex = startIndex;
                    } 
            
                    for(Integer i = endIndex; i<eachWorkItemsList.size(); i++) {
                       toBeAutoApprovedList.add(eachWorkItemsList[i]);           
                    }
                }        
            }
            
            try {
                if(newApprovalsList!=null && newApprovalsList.size()>0)
                    update newApprovalsList;
            }
            catch(Exception ex) {
                System.debug('Exception:' + ex);
            }
            
            if(toBeAutoApprovedList != null && toBeAutoApprovedList.size() > 0) {
                for(ProcessInstanceWorkItem each:toBeAutoApprovedList) {
                    newRequestForApproval = new Approval.ProcessWorkItemRequest();
                    newRequestForApproval.setWorkItemId(each.Id);
                    newRequestForApproval.setComments('Auto-Approved by system');
                    newRequestForApproval.setAction('Approve');
                    try {
                        Approval.ProcessResult result =  Approval.process(newRequestForApproval);
                    }
                    catch(Exception ex) {
                        System.debug('Exception occured: '+ ex.getMessage());
                    }                
                }
            }
        }
    }        
}