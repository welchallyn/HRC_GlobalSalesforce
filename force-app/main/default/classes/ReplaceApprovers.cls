global class ReplaceApprovers implements Database.Batchable<sObject>, Database.Stateful{
//, Schedulable { old comment


    public Map<Id,List<ProcessInstanceWorkItem>> piwiMap = new Map<Id,List<ProcessInstanceWorkItem>>();
    public Map<String, Id> approvalRoleMappings = new Map<String, Id>();
    public Map<String, List<Id>> newapprovalRoleMappings = new Map<String, List<Id>>();
    public List<Id> newRoleOwners = new List<Id>();
    public List<ProcessInstanceWorkItem> newApprovalsList = new List<ProcessInstanceWorkItem>();
    public List<ProcessInstanceWorkItem> toBeAutoApprovedList  = new List<ProcessInstanceWorkItem>();
    Map<Id,List<ProcessInstanceWorkItem>> toBeAutoApprovedMap = new Map<Id,List<ProcessInstanceWorkItem>>();
    String cognosValue = null;
    String jdedwardsValue = null;
    String cognosValue2 = null;
    String jdedwardsValue2 = null;
    String cognosgenericapprovalvalue = null;
    String sapRolesValue= null;

    HillRom_Settings__c COGNOS_CATEGORY;
    HillRom_Settings__c JDEDWARDS_CATEGORY;
    HillRom_Settings__c COGNOS2_CATEGORY;
    HillRom_Settings__c JDEDWARDS2_CATEGORY;
    HillRom_Settings__c CognosGenericApr;
    HillRom_Settings__c SAP_ROLES;
     
    global Database.QueryLocator start(Database.BatchableContext bc) {
            String query;
            query = 'select Id, ProcessInstanceId, ActorId, Actor.Name, Createddate, ProcessInstance.TargetObjectId, ProcessInstance.Status, ProcessInstance.CreatedDate from ProcessInstanceWorkItem Where isDeleted = false and ProcessInstance.Status = \'Pending\' Order By Createddate,ActorId';
            System.debug('Query from QueryLocator start'+query);
            return Database.getQueryLocator(query); 
     } 
      
    global void execute(Database.BatchableContext BC,  List<ProcessInstanceWorkItem> scope) {
        List<ProcessInstanceWorkItem> piwiList;
        
        for(integer count=0;count<scope.size();count++){
            System.debug('result'+scope[count].ProcessInstance.TargetObjectId+'###'+scope[count].Id+'###'+ scope[count].ProcessInstanceId);}
        COGNOS_CATEGORY = HillRom_Settings__c.getValues('COGNOS');
        JDEDWARDS_CATEGORY = HillRom_Settings__c.getValues('JD EDWARDS');
        COGNOS2_CATEGORY = HillRom_Settings__c.getValues('COGNOS2');
        JDEDWARDS2_CATEGORY = HillRom_Settings__c.getValues('JD EDWARDS2');
        CognosGenericApr = HillRom_Settings__c.getValues('Cognos Generic Approval');
        SAP_ROLES= HillRom_Settings__c.getValues('SAP ROLES');
        
        System.debug('CognosGenericApr :::'+CognosGenericApr );
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
        jdedwardsValue2 = JDEDWARDS2_CATEGORY.value__c;
        }
        if(CognosGenericApr != null){
        cognosgenericapprovalvalue = CognosGenericApr.value__c;
        }
        if(SAP_ROLES != null){
            sapRolesValue = SAP_ROLES.value__c;
        }
        
        
       System.debug('cognosgenericapprovalvalue:::'+cognosgenericapprovalvalue );

        //creating map for each incident and their approvals list
        for(ProcessInstanceWorkItem eachpiwi:scope){
            piwiList = piwiMap.get(eachpiwi.ProcessInstance.TargetObjectId);
            if(piwiList == null){
                piwiList = new List<ProcessInstanceWorkItem>();
            }
            piwiList.add(eachpiwi);
            piwiMap.put(eachpiwi.ProcessInstance.TargetObjectId, piwiList);
            System.debug('Approvalprocessmao in pending'+piwiList);
            System.debug('Piwi list'+piwiList);
        }
    }
  
    global void finish( Database.BatchableContext BC ) {
        
        Schema.SObjectType token;
        Schema.DescribeSObjectResult dr;
        String targetObjectLabel;
        String targetObjectName;
        
        String requestCategoryString;
        String [] requestCategories;
        List<ProcessInstanceWorkItem> eachWorkItemsList;
        Set<Id> requestCategoryApprovers;
        List<Id> requestCategoryApproversList;
        Id requestCategoryOwnerId;
        List<Id> requestCategoryOwnerIdList;

        Integer startIndex = 0;
        Integer endIndex = 0;
        List<BMCServiceDesk__Incident__c> incidentsList = new List<BMCServiceDesk__Incident__c>();
        Set<Id> incidentIdSet = new Set<Id>();
        System.debug('In finish');
        List<ApprovalRoleMapping__c> approvalRoleMappingsList = [select Name, OwnerId from ApprovalRoleMapping__c limit 20000];
        Set<String> approavalrolenames = new Set<String>();
        
        if(approvalRoleMappingsList != null){
            for(ApprovalRoleMapping__c eachApprovalMapping : approvalRoleMappingsList){
                approavalrolenames.add(eachApprovalMapping.Name);
            }
            for(ApprovalRoleMapping__c eachApprovalMapping : approvalRoleMappingsList){
                  String s = eachApprovalMapping.Name.toLowerCase();
                  newRoleOwners = new List<Id>();
                  newRoleOwners = newapprovalRoleMappings.get(s);
                  if(newRoleOwners == null){
                      newRoleOwners = new List<Id>();                  
                  } 
                      
                  newRoleOwners.add(eachApprovalMapping.OwnerId);
                  newapprovalRoleMappings.put(s, newRoleOwners);
                  
                
            }
         }
         System.debug('approvalRoleMappings orginal all mappings'+newapprovalRoleMappings);
         System.debug('PiwiMap:'+ piwiMap);
         
         for(Id eachTargetObjectId : piwiMap.keySet()) {
            token = eachTargetObjectId.getSObjectType();
            dr = token.getDescribe();
            targetObjectLabel = dr.getLabel();
            targetObjectName = dr.getName();
            if(targetObjectName == 'BMCServiceDesk__Incident__c')
                incidentIdSet.add(eachTargetObjectId);
            }
                
             Map<Id,BMCServiceDesk__Incident__c> incidentMap = new Map<Id,BMCServiceDesk__Incident__c>(
                 [select Id, Name,Product_Catalog_Tier_1__c, Product_Catalog_Tier_2__c, Cognos_Roles__c,Cognos_Roles_2__c,JD_Edwards_Roles__c,JD_Edwards_Roles2__c, SAP_Roles__c from BMCServiceDesk__Incident__c where Id = :incidentIdSet and Approval_processed__c = false and Role_Based_Approval__c = true]);
             System.debug('IncidentIdSet::'+incidentIdSet);  
             System.debug('Incidentmap with roles****&&&@@'+incidentMap );  
            for(Id eachIncidentId: incidentMap.keySet()) {
                BMCServiceDesk__Incident__c eachIncident = incidentMap.get(eachIncidentId);
                System.debug('Incident id in for loop%$^#(*::'+eachIncidentId);
                System.debug('Each incident object$$$$'+eachIncident);
/*                if(eachIncident.Cognos_Roles__c != null && eachIncident.Cognos_Roles_2__c == null && eachIncident.JD_Edwards_Roles__c ==null && eachIncident.JD_Edwards_Roles2__c == null)
                   requestCategoryString = String.valueOf(eachIncident.Cognos_Roles__c);
                else if(eachIncident.Cognos_Roles__c == null && eachIncident.Cognos_Roles_2__c != null && eachIncident.JD_Edwards_Roles__c ==null && eachIncident.JD_Edwards_Roles2__c == null)
                    requestCategoryString = String.valueOf(eachIncident.Cognos_Roles_2__c); 
                else if(eachIncident.Cognos_Roles__c == null && eachIncident.Cognos_Roles_2__c == null && eachIncident.JD_Edwards_Roles__c !=null && eachIncident.JD_Edwards_Roles2__c == null)
                    requestCategoryString = String.valueOf(eachIncident.JD_Edwards_Roles__c);
                else if(eachIncident.Cognos_Roles__c == null && eachIncident.Cognos_Roles_2__c == null && eachIncident.JD_Edwards_Roles__c ==null && eachIncident.JD_Edwards_Roles2__c != null)
                    requestCategoryString = String.valueOf(eachIncident.JD_Edwards_Roles2__c);
               
*/
                if(eachIncident.Product_Catalog_Tier_2__c == cognosValue && eachIncident.Cognos_Roles__c!= null)
                     requestCategoryString = String.valueOf(eachIncident.Cognos_Roles__c);
                 else if(eachIncident.Product_Catalog_Tier_2__c == jdedwardsValue && eachIncident.JD_Edwards_Roles__c != null)
                     requestCategoryString = String.valueOf(eachIncident.JD_Edwards_Roles__c); 
                 else if(eachIncident.Product_Catalog_Tier_1__c == jdedwardsValue2 && eachIncident.JD_Edwards_Roles2__c!= null)
                     requestCategoryString = String.valueOf(eachIncident.JD_Edwards_Roles2__c);
                 else if(eachIncident.Product_Catalog_Tier_2__c == cognosValue2 && eachIncident.Cognos_Roles_2__c   != null)
                     requestCategoryString = String.valueOf(eachIncident.Cognos_Roles_2__c  );
                 else if(eachIncident.Product_Catalog_Tier_2__c == sapRolesValue && eachIncident.SAP_Roles__c != null)
                     requestCategoryString = String.valueOf(eachIncident.SAP_Roles__c );
                
                System.debug('Roles selected full string'+requestCategoryString );        
                if(requestCategoryString != null){
                    requestCategories = requestCategoryString.split(';');
                    System.debug('requestCategories:before adding genericapproval&&&&&& '+requestCategories);
                    Integer listSize= requestCategories.size();
                    System.debug('requestCategories size before adding&^$*^$: '+requestCategories.size());
                    
                    if(eachIncident.Product_Catalog_Tier_2__c == jdedwardsValue )
                        requestCategories.add('GenericApproval');
                    else if(eachIncident.Product_Catalog_Tier_2__c == cognosValue )
                        requestCategories.add(cognosgenericapprovalvalue);
                        
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
                            String s = eachRequestCategory.toLowerCase();
                            requestCategoryOwnerIdList = newapprovalRoleMappings.get(s);
                            System.debug(requestCategoryOwnerId +'^^^requestCategoryOwnerId ');
                            if(requestCategoryOwnerIdList != null){
                                for(Id eachownerId :requestCategoryOwnerIdList ){
                                    if(!requestCategoryApprovers.contains(eachownerId)) {
                                            System.debug('inside if ownerId'+eachownerId );
                                            requestCategoryApprovers.add(eachownerId );
                                            requestCategoryApproversList.add(eachownerId );
                                     }
                                }
                            }
                        }
                    }
                    
                    requestCategoryApproversList.sort();
                    System.debug('requestCategoryApprovers:'+requestCategoryApprovers);
                    System.debug('requestCategoryApproversList:'+requestCategoryApproversList);
                    eachWorkItemsList = piwiMap.get(eachIncidentId);
                    System.debug('eachWorkItemsList:'+eachWorkItemsList);
                    System.debug('eachWorkItemsListsize:'+eachWorkItemsList.size());
                    startIndex = 0;
                   
                    for(Id eachRequestCategoryApprover : requestCategoryApproversList) {
                        System.debug('Start Index:'+ startIndex);
                        //System.debug('approver in list'+eachWorkItemsList[startIndex].Actor.Name);
                        System.debug('approver in get list'+eachRequestCategoryApprover);
                        if(startIndex<=eachWorkItemsList.size()-1)
                {
                        if(eachWorkItemsList[startIndex].ActorId != eachRequestCategoryApprover) {
                        System.debug('approver in inside%^&$*&*&^before list'+eachWorkItemsList[startIndex].Actor.Name);
                            eachWorkItemsList[startIndex].ActorId = eachRequestCategoryApprover;
                            eachWorkItemsList[startIndex].OriginalActorId = eachRequestCategoryApprover;
                            System.debug('approver in inside%^&$*&*&^ list'+eachWorkItemsList[startIndex].Actor.Name);
                            newApprovalsList.add(eachWorkItemsList[startIndex]);
                        }
                    }
                        startIndex = startIndex + 1;
                        endIndex = startIndex;
                    } 
                    Approval.ProcessWorkItemRequest newRequestForApproval;
                    for(Integer i = endIndex; i<eachWorkItemsList.size(); i++) {
                       toBeAutoApprovedList = toBeAutoApprovedMap.get(eachWorkItemsList[i].ProcessInstance.TargetObjectId);
                       if(toBeAutoApprovedList == null){
                           toBeAutoApprovedList = new List<ProcessInstanceWorkItem>();
                       }
                       toBeAutoApprovedList.add(eachWorkItemsList[i]);
                       toBeAutoApprovedMap.put(eachWorkItemsList[i].ProcessInstance.TargetObjectId,toBeAutoApprovedList);
                       
                       System.debug('tobeapproved map'+toBeAutoApprovedMap);
                    }
                  
                }
            }
        System.debug('NewApproversList:' + newApprovalsList);
        System.debug('toBeAutoApprovedList&&&&'+toBeAutoApprovedList);
       
        System.debug('tobeapproved map'+  toBeAutoApprovedMap);
            UpdateApprovers ua = new UpdateApprovers(newApprovalsList, incidentMap, 0, 0,toBeAutoApprovedMap,endIndex);
            Database.executeBatch(ua);
    }

   
   /* global void execute(SchedulableContext sc) {
        ReplaceApprovers ra = new ReplaceApprovers();
        system.debug('in schedulable execute');
        Database.executeBatch(ra);
    }*/

 }