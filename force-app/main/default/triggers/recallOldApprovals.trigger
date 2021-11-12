trigger recallOldApprovals on BMCServiceDesk__Incident__c (before insert,after update) {
   System.debug('entering trigger');
    public List<ApprovalHistoryRecord> ApprovalHistoryRecordsList;
    public set<Id> recallableIncidentIds = new set<Id>();
    public Map<Id,List<ProcessInstanceWorkItem>> piwiMap = new Map<Id,List<ProcessInstanceWorkItem>>();
    
    public String objectId = null;
    
    public Map<String, Id> approvalRoleMappings = new Map<String, Id>();

    public List<ProcessInstanceWorkItem> toBeAutoApprovedList  = new List<ProcessInstanceWorkItem>();
    public List<ProcessInstanceWorkItem> newApprovalsList = new List<ProcessInstanceWorkItem>();    
    //check recursion
    if(checkRecursive.runOnce()){
        
    List<BMCServiceDesk__Incident__c> allIncidents= Trigger.new;
    
        
    
    List<BMCServiceDesk__Incident__c> unprocessedApprovalsIncidentsList = new List<BMCServiceDesk__Incident__c>();
    List<ProcessInstanceWorkItem> toBeRecalledItems = new List<ProcessInstanceWorkItem>();
    Approval.ProcessWorkItemRequest newRequestForApproval;
    
    String cognosValue = null;
    String jdedwardsValue = null;
    String cognosValue2 = null;
    String jdedwardsValue2 = null;
    String sapRolesValue= null;
    
    HillRom_Settings__c COGNOS_CATEGORY;
    HillRom_Settings__c JDEDWARDS_CATEGORY;
    HillRom_Settings__c COGNOS2_CATEGORY;
    HillRom_Settings__c JDEDWARDS2_CATEGORY;
    HillRom_Settings__c SAP_ROLES;
    
    COGNOS_CATEGORY = HillRom_Settings__c.getValues('COGNOS');
        JDEDWARDS_CATEGORY = HillRom_Settings__c.getValues('JD EDWARDS');
        COGNOS2_CATEGORY = HillRom_Settings__c.getValues('COGNOS2');
        JDEDWARDS2_CATEGORY = HillRom_Settings__c.getValues('JD EDWARDS2');
        SAP_ROLES= HillRom_Settings__c.getValues('SAP ROLES');
        
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
        jdedwardsValue2 = JDEDWARDS2_CATEGORY .value__c;
        }
        if(SAP_ROLES != null){
        sapRolesValue = SAP_ROLES.value__c;
        }
    
    // Start Approval requirement
    List<BMCServiceDesk__Incident__c> IncsRequireApprovalList = new List<BMCServiceDesk__Incident__c>();
    List<BMCServiceDesk__Incident__c> IncsNoRequireApprovalList = new List<BMCServiceDesk__Incident__c>();
    
    List<ApprovalRoleMapping__c> approvalRoleMappingsList = [select Name, OwnerId from ApprovalRoleMapping__c limit 20000];
    if(approvalRoleMappingsList != null){
        for(ApprovalRoleMapping__c eachApprovalMapping : approvalRoleMappingsList)
            approvalRoleMappings.put(eachApprovalMapping.Name, eachApprovalMapping.OwnerId);
    }
    String selectedRolesString;
    String [] selectedRoles;
    boolean approvalRequired = false;
    system.debug('allIncidents-->'+allIncidents);
   
  
  if(trigger.isUpdate && trigger.isAfter){
       system.debug('####after update');
       list<BMCServiceDesk__Incident__c> IncUpdatelist = new list<BMCServiceDesk__Incident__c>();
    for(BMCServiceDesk__Incident__c eachIncident:allIncidents){
      
        System.debug('Old Trigger Map ->' + Trigger.oldMap);
         System.debug('New Trigger Map ->' + Trigger.newMap);
        BMCServiceDesk__Incident__c oldIncident = Trigger.oldMap.get(eachIncident.ID);
        
        if(((eachIncident.JD_Edwards_Roles__c != null && oldIncident.JD_Edwards_Roles__c != null)&&(eachIncident.JD_Edwards_Roles__c != oldIncident.JD_Edwards_Roles__c)) ||
           ((eachIncident.JD_Edwards_Roles2__c != null &&  oldIncident.JD_Edwards_Roles2__c != null) &&(eachIncident.JD_Edwards_Roles2__c != oldIncident.JD_Edwards_Roles2__c)) ||
           ((eachIncident.SAP_Roles__c != null && oldIncident.SAP_Roles__c!= null) && (eachIncident.SAP_Roles__c != oldIncident.SAP_Roles__c)) ||
           ((eachIncident.Cognos_Roles__c != null && oldIncident.Cognos_Roles__c!= null) && (eachIncident.Cognos_Roles__c != oldIncident.Cognos_Roles__c)) ||
           ((eachIncident.Cognos_Roles_2__c != null && oldIncident.Cognos_Roles_2__c != null)&& (eachIncident.Cognos_Roles_2__c != oldIncident.Cognos_Roles_2__c))){
         
            recallableIncidentIds.add(eachIncident.Id);
            if(eachIncident.Approval_processed__c == false) {
                unprocessedApprovalsIncidentsList.add(eachIncident);
                System.debug('####'+unprocessedApprovalsIncidentsList);
            }
            
           }
            
            //Shirisha
            system.debug('Before change --> each incident'+ eachIncident.JD_Edwards_Roles__c);
            system.debug('oldIncident -->'+oldIncident.JD_Edwards_Roles__c);
            //To fetch selected roles
      if(eachIncident.Product_Catalog_Tier_2__c == cognosValue && eachIncident.Cognos_Roles__c!= null && ((oldIncident.Cognos_Roles__c != null && eachIncident.Cognos_Roles__c != oldIncident.Cognos_Roles__c) || (oldIncident.Cognos_Roles__c == null)))
           selectedRolesString = String.valueOf(eachIncident.Cognos_Roles__c);
      else if(eachIncident.Product_Catalog_Tier_2__c == jdedwardsValue && eachIncident.JD_Edwards_Roles__c != null && ((oldIncident.JD_Edwards_Roles__c != null && eachIncident.JD_Edwards_Roles__c != oldIncident.JD_Edwards_Roles__c) || (oldIncident.JD_Edwards_Roles__c == null)))
           selectedRolesString = String.valueOf(eachIncident.JD_Edwards_Roles__c); 
      else if(eachIncident.Product_Catalog_Tier_1__c == jdedwardsValue2 && eachIncident.JD_Edwards_Roles2__c!= null && ((oldIncident.JD_Edwards_Roles2__c != null && eachIncident.JD_Edwards_Roles2__c != oldIncident.JD_Edwards_Roles2__c) || (oldIncident.JD_Edwards_Roles2__c == null)))
           selectedRolesString = String.valueOf(eachIncident.JD_Edwards_Roles2__c);
      else if(eachIncident.Product_Catalog_Tier_2__c == cognosValue2 && eachIncident.Cognos_Roles_2__c   != null && ((oldIncident.Cognos_Roles_2__c != null && eachIncident.Cognos_Roles_2__c != oldIncident.Cognos_Roles_2__c) || (oldIncident.Cognos_Roles_2__c == null)))
           selectedRolesString = String.valueOf(eachIncident.Cognos_Roles_2__c  );
      else if(eachIncident.Product_Catalog_Tier_2__c == sapRolesValue && eachIncident.SAP_Roles__c != null && ((oldIncident.SAP_Roles__c != null && eachIncident.SAP_Roles__c != oldIncident.SAP_Roles__c ) || (oldIncident.SAP_Roles__c == null)))
           selectedRolesString = String.valueOf(eachIncident.SAP_Roles__c   );
           
          System.debug('Selected Roles string --->'+selectedRolesString ); 
                 
          if(selectedRolesString != null){
              selectedRoles = selectedRolesString.split(';');
              
              System.debug('All selected roles -->'+selectedRoles);
          
            if(selectedRoles != null) {
              for(String eachselectedRole : selectedRoles) {
                if(!approvalRequired){
                        if(approvalRoleMappings != null && approvalRoleMappings.containsKey(eachselectedRole)) {
                          approvalRequired = true;
                        }
                }
                  }
                  if(approvalRequired){
                  IncsRequireApprovalList.add(eachIncident);
                  system.debug('eachIncident requries approval-->'+eachIncident);
                  }
                  else{
                    IncsNoRequireApprovalList.add(eachIncident);
                  }
            }
                
              approvalRequired = false; 
              system.debug('IncsRequireApprovalList-->'+IncsRequireApprovalList);
              system.debug('IncsNoRequireApprovalList-->'+IncsNoRequireApprovalList);
          }
          else{
              selectedRoles = null;
          }
              
      
    
      if(!IncsRequireApprovalList.isEmpty() || !IncsNoRequireApprovalList.isEmpty()){
      for(BMCServiceDesk__Incident__c eachinc:IncsRequireApprovalList){
        BMCServiceDesk__Incident__c test1 = new BMCServiceDesk__Incident__c(id = eachinc.id,Approval_Required__c = true,Role_Based_Approval__c=true);
         //eachinc.Approval_Required__c=true;
          IncUpdatelist.add(test1);
      }
      for(BMCServiceDesk__Incident__c eachNoinc:IncsNoRequireApprovalList){
        BMCServiceDesk__Incident__c test = new BMCServiceDesk__Incident__c(id = eachNoinc.id,Approval_Required__c = false);
        //eachNoinc.Approval_Required__c=false;
          IncUpdatelist.add(test);
      }
      IncsRequireApprovalList.clear();
      IncsNoRequireApprovalList.clear();
      system.debug('IncUpdatelist-->'+IncUpdatelist);
     // update IncUpdatelist;
      }
             
            //Shirisha
        
    }
    try{
    update IncUpdatelist;
    }
    catch(Exception ex) {
      System.debug('Exception occured while updating the incident "Approval Required" checkbox -->'+ ex.getMessage());
    }
    
    System.debug('recallableIncidentIds'+recallableIncidentIds);
    
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
    
    List<ProcessInstanceWorkItem> piwiList;
    
        
    
    List<ProcessInstance> workItems = [SELECT Id, Status, TargetObjectId, TargetObject.Name, CreatedDate, (Select Id, CreatedDate, OriginalActorId, OriginalActor.Name, ProcessInstanceId, ActorId, Actor.Name, StepStatus, Comments From StepsAndWorkItems order by CreatedDate desc, StepStatus)
           FROM ProcessInstance where TargetObjectId =:Trigger.New order by CreatedDate desc];
            
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
                 else if(eachIncident.Product_Catalog_Tier_1__c == jdedwardsValue2 && eachIncident.JD_Edwards_Roles2__c!= null)
                     requestCategoryString = String.valueOf(eachIncident.JD_Edwards_Roles2__c);
                 else if(eachIncident.Product_Catalog_Tier_2__c == cognosValue2 && eachIncident.Cognos_Roles_2__c   != null)
                     requestCategoryString = String.valueOf(eachIncident.Cognos_Roles_2__c  );
                 else if(eachIncident.Product_Catalog_Tier_2__c == sapRolesValue && eachIncident.SAP_Roles__c   != null)
                     requestCategoryString = String.valueOf(eachIncident.SAP_Roles__c);

        
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
            if(eachWorkItemsList!=null && eachWorkItemsList.size() > 0){
            for(Id eachRequestCategoryApprover : requestCategoryApproversList) {
              //  System.debug('Start Index:'+ startIndex);
              //  System.debug('approver in list'+eachWorkItemsList[startIndex].Actor.Name);
              //  System.debug('approver in get list'+eachRequestCategoryApprover);
                if(startIndex<=eachWorkItemsList.size()-1)
                {
                   
                
                if(eachWorkItemsList[startIndex].ActorId != eachRequestCategoryApprover) {
              //  System.debug('approver in inside%^&$*&*&^before list'+eachWorkItemsList[startIndex].Actor.Name);
                    eachWorkItemsList[startIndex].ActorId = eachRequestCategoryApprover;
                    eachWorkItemsList[startIndex].OriginalActorId = eachRequestCategoryApprover;
                    System.debug('approver in inside%^&$*&*&^ list'+eachWorkItemsList[startIndex].Actor.Name);
                    newApprovalsList.add(eachWorkItemsList[startIndex]);
                }
                }
                
                startIndex = startIndex + 1;
                endIndex = startIndex;
            } 
            

            for(Integer i = endIndex; endIndex!=0 && i<eachWorkItemsList.size(); i++) {
               toBeAutoApprovedList.add(eachWorkItemsList[i]);           
            }
            }
        }        
    }
    
    try {
        if(newApprovalsList!=null && newApprovalsList.size()>0){
            System.debug('new Approvals List'+ newApprovalsList);
            update newApprovalsList;
         }
    }
    catch(Exception ex) {
        System.debug('Exception:' + ex);
    }
    
    if(toBeAutoApprovedList != null && toBeAutoApprovedList.size() > 0) {
        List<Approval.ProcessWorkItemRequest> resultList=new List<Approval.ProcessWorkItemRequest>(); 
        for(ProcessInstanceWorkItem each:toBeAutoApprovedList) {
            newRequestForApproval = new Approval.ProcessWorkItemRequest();
            newRequestForApproval.setWorkItemId(each.Id);
            newRequestForApproval.setComments('Auto-Approved by system');
            newRequestForApproval.setAction('Approve');
            System.debug('new request for approval auto approved'+newRequestForApproval);
               // Approval.ProcessResult result =  Approval.process(newRequestForApproval);
             resultList.add(newRequestForApproval);
                            
        }
        Approval.ProcessResult[] processResults = null;
         try {
                    processResults = Approval.process(resultList);
        }catch (Exception e) {
            System.debug('Exception Is ' + e.getMessage());
        }
    }
                
    if(piwi!=null && piwi.size()>0) {
        for(ProcessInstanceWorkItem eachPiwi : piwi) {
            if(recallableIncidentIds.contains(eachPiwi.ProcessInstance.TargetObjectId))
                toBeRecalledItems.add(eachPiwi);
                System.debug('recalled items'+toBeRecalledItems);
        }
        
    }
    if(toBeRecalledItems.size() > 0) {  
        List<Approval.ProcessWorkItemRequest> resultList=new List<Approval.ProcessWorkItemRequest>(); 
        for(Integer i=0;i<toBeRecalledItems.size();i++ ) {
            newRequestForApproval = new Approval.ProcessWorkItemRequest();
            newRequestForApproval.setWorkItemId(piwi[i].id);
            System.debug(piwi[i].id);
            newRequestForApproval.setComments('Re-called due to roles change');
            newRequestForApproval.setAction('Removed');
            System.debug('new request for approval'+newRequestForApproval);
            try{
                Approval.ProcessResult result =  Approval.process(newRequestForApproval);
            }
            catch (Exception e) {
            System.debug('Exception Is ' + e.getMessage());
        }
            
           // resultList.add(newRequestForApproval);
        } 
        /* Approval.ProcessResult[] processResults = null;
         try {
                    processResults = Approval.process(resultList);
        }catch (Exception e) {
            System.debug('Exception Is ' + e.getMessage());
        } */         
    }          
    
  }
  if(trigger.isBefore && trigger.isInsert){
       system.debug('####before insert');
      for(BMCServiceDesk__Incident__c  eachIncident :allIncidents){
           if(eachIncident.Product_Catalog_Tier_2__c == cognosValue && eachIncident.Cognos_Roles__c!= null )
           selectedRolesString = String.valueOf(eachIncident.Cognos_Roles__c);
      else if(eachIncident.Product_Catalog_Tier_2__c == jdedwardsValue && eachIncident.JD_Edwards_Roles__c != null )
           selectedRolesString = String.valueOf(eachIncident.JD_Edwards_Roles__c); 
      else if(eachIncident.Product_Catalog_Tier_1__c == jdedwardsValue2 && eachIncident.JD_Edwards_Roles2__c!= null )
           selectedRolesString = String.valueOf(eachIncident.JD_Edwards_Roles2__c);
      else if(eachIncident.Product_Catalog_Tier_2__c == cognosValue2 && eachIncident.Cognos_Roles_2__c   != null )
           selectedRolesString = String.valueOf(eachIncident.Cognos_Roles_2__c  );
      else if(eachIncident.Product_Catalog_Tier_2__c == sapRolesValue && eachIncident.SAP_Roles__c   != null )
           selectedRolesString = String.valueOf(eachIncident.SAP_Roles__c );
           
          System.debug('Selected Roles string --->'+selectedRolesString ); 
                 
          if(selectedRolesString != null){
              selectedRoles = selectedRolesString.split(';');
              
              System.debug('All selected roles -->'+selectedRoles);
          
            if(selectedRoles != null) {
              for(String eachselectedRole : selectedRoles) {
                if(!approvalRequired){
                        if(approvalRoleMappings != null && approvalRoleMappings.containsKey(eachselectedRole)) {
                          approvalRequired = true;
                        }
                }
                  }
                  if(approvalRequired){
                  IncsRequireApprovalList.add(eachIncident);
                  system.debug('eachIncident requries approval-->'+eachIncident);
                  }
                  else{
                    IncsNoRequireApprovalList.add(eachIncident);
                  }
            }
                
              approvalRequired = false; 
              system.debug('IncsRequireApprovalList-->'+IncsRequireApprovalList);
              system.debug('IncsNoRequireApprovalList-->'+IncsNoRequireApprovalList);
          }
          else{
              selectedRoles = null;
          } 
  
  
 //Start Approval requirement

     
    try{
    list<BMCServiceDesk__Incident__c> IncUpdatelist = new list<BMCServiceDesk__Incident__c>();
      if(!IncsRequireApprovalList.isEmpty() || !IncsNoRequireApprovalList.isEmpty()){
      for(BMCServiceDesk__Incident__c eachinc:IncsRequireApprovalList){
        BMCServiceDesk__Incident__c test1 = new BMCServiceDesk__Incident__c(id = eachinc.id,Approval_Required__c = true, Role_Based_Approval__c= true);
         eachinc.Approval_Required__c=true;
          eachinc.Role_Based_Approval__c=true;
          IncUpdatelist.add(test1);
      }
      for(BMCServiceDesk__Incident__c eachNoinc:IncsNoRequireApprovalList){
        BMCServiceDesk__Incident__c test = new BMCServiceDesk__Incident__c(id = eachNoinc.id,Approval_Required__c = false);
        eachNoinc.Approval_Required__c=false;
          IncUpdatelist.add(test);
      }
      IncsRequireApprovalList.clear();
      IncsNoRequireApprovalList.clear();
      system.debug('IncUpdatelist-->'+IncUpdatelist);
      //update IncUpdatelist;
      }
    } 
    catch(Exception ex) {
      System.debug('Exception occured while updating the incident "Approval Required" checkbox -->'+ ex.getMessage());
    } 
    //END Approval requirement  
     
    }
  }
    }
}