/**
*   This class handles following use-cases
*       - Remove Duplicate Approver
*       - Auto Approval of record if all step aprrovers are already approved users
*       - Providing record edit access to currently pending step approvers
*       - Adding PM into group 'HRC CFR Project Manager' if he is notowner of the record
*       - Setting current step approvers name in field to be used to display on list view
*/
public class HRCCFR_CapitalRequest_Handler {
    
    public id LeaseRecordTypeId;
    public id CapitalRecordTypeId;
    public map<integer,String> CapitalStepQueueMap      = new map<integer,String>();    //Map of Approval Step number and Queue name for Capital Approval Process
    public map<integer,String> LeaseStepQueueMap        = new map<integer,String>();    //Map of Approval Step number and Queue name for Lease Approval Process
    public map<string,Id> GroupNameWithIdMap            = new map<string, Id>();        //Map of Groupname vs GroupId/QueueID 
    public map<id,list<GroupMember>> GroupID_MembersMap = new map<id,list<GroupMember>>(); // List to hold Group Id and GroupMember Object
    
    private boolean isTriggerExecuting = false;
    private integer batchSize = 0;
    public static boolean isRun = true;
    
/**
* Constructor to set trigger context and get size of trigger context
*/
    public HRCCFR_CapitalRequest_Handler(boolean isExecuting, integer size){
        isTriggerExecuting = isExecuting;
        BatchSize = size;
        
        // Get Lease and Capital Record Type Ids
        LeaseRecordTypeId = Schema.SObjectType.Capital_Requests__c.getRecordTypeInfosByName().get('CFR Lease').getRecordTypeId();
        CapitalRecordTypeId = Schema.SObjectType.Capital_Requests__c.getRecordTypeInfosByName().get('CFR Capital').getRecordTypeId();         
    
    }// End Constructor    
    
/*
* Method to setup Map for Custom setting(step number & queue pair) for Capital and Lease record
*/
    public void initGroupMembers(){
        //Populate Map CapitalStepQueueMap      
        for (HRCCFR_Capital_ApprovalStep_Queue_pair__c cp : HRCCFR_Capital_ApprovalStep_Queue_pair__c.getall().values()){
            CapitalStepQueueMap.put(integer.valueof(cp.Step_Number__c),cp.name);        
        }
        
        //Populate Map LeaseStepQueueMap    
        for (HRCCFR_Lease_ApprovalStep_Queue_pair__c le : HRCCFR_Lease_ApprovalStep_Queue_pair__c.getall().values()){
            LeaseStepQueueMap.put(integer.valueof(le.Step_Number__c),le.name);    
        }
        
        //Populate Map GroupNameWithIdMap
        list<string> groupTypes = new list<string>();
        groupTypes.add('Queue');
        groupTypes.add('Regular');
        
        for(Group g: [select Id, name,(Select groupId, UserOrGroupId from GroupMembers) from Group where type IN :groupTypes ]){  
            GroupNameWithIdMap.put(g.name, g.id);
            GroupID_MembersMap.put(g.id, g.GroupMembers);
        }
        
    }
/**
*  Generic method to hold logic on After Insert of record           
*/
    public void onAfterInsert(List<Capital_Requests__c> crNewList){        
        // to add PM in Group if he is not record owner and not already present in group
        addPMToGroup(crNewList);     
    }    
        
/**
*  Generic method - placeholder for all "Before Update" use-cases          
*/
    public void onBeforeUpdate(List<Capital_Requests__c> newCapReqList , Map<id,Capital_Requests__c> oldCapReqMap){
        
        // Remove Duplicate Approvers from Approver list    
        removeDuplicateApprover(newCapReqList,oldCapReqMap);
        
        // Grant EDIT access to next step's approver
        shareRecord(newCapReqList,oldCapReqMap);     
        
        HRCCFRSendEmailRemainder(newCapReqList,oldCapReqMap);
        
    }
    
    //Method to consolidate HRCCFRSendEmailRemainderHelper into HRCCFR_Capital_Request_Trigger trigger.
    public void HRCCFRSendEmailRemainder(List<Capital_Requests__c> newCapReqList , Map<id,Capital_Requests__c> oldCapReqMap){
        Map<Id, Capital_Requests__c> rejectedStatements = new Map<Id, Capital_Requests__c>{};
            for(Capital_Requests__c cr: newCapReqList){
                Capital_Requests__c oldcr = oldCapReqMap.get(cr.Id);
                if (oldcr.Rejection_Comments_Required__c != 'Rejected' && cr.Rejection_Comments_Required__c == 'Rejected'){ 
                  rejectedStatements.put(cr.Id, cr);  
                }
            }
           
            if (!rejectedStatements.isEmpty()){
                List<Id> processInstanceIds = new List<Id>{};
                for (Capital_Requests__c crs : [SELECT (SELECT ID FROM ProcessInstances ORDER BY CreatedDate DESC LIMIT 1) FROM Capital_Requests__c WHERE ID IN :rejectedStatements.keySet()]){
                    processInstanceIds.add(crs.ProcessInstances[0].Id);
                }
                for (ProcessInstance pi : [SELECT TargetObjectId,(SELECT Id, Actor.email, Actor.Name, Actor.Id, ActorId FROM WorkItems),(SELECT Id, StepStatus, Comments FROM Steps ORDER BY CreatedDate DESC LIMIT 1 ) FROM ProcessInstance WHERE Id IN :processInstanceIds ORDER BY CreatedDate DESC]){                   
                    System.debug('**steps'+pi.Steps[0]);
                    if ((pi.Steps[0].Comments == null || 
                        pi.Steps[0].Comments.trim().length() == 0)){
                           system.debug('pi id'+pi.id+'******04iM0000000TZsw'+'**********'+pi.WorkItems[0].id);
                        //CapitalRequestCtrl.setRedirectToOtherPage(rejectedStatements.get(pi.TargetObjectId).id);
                        rejectedStatements.get(pi.TargetObjectId).addError('<br/><br/>Reject Operation Cancelled: Please provide a <b>Rejection Comments</b> !'+'<br/>'+'Please click '+'<a href='+'https://hill-rom--hrsdev.cs7.my.salesforce.com/p/process/ProcessInstanceWorkitemWizardStageManager?id='+pi.WorkItems[0].id+'>'+'<b>here</b>'+'</a>'+' to redirect to previous page');
                      
                      
                    }
                }  
          }
    }
    
/**
*  Method to  remove duplicate approvers from the approvers set  
*        1. Get stepwise approver-Queue information from Custom Setting, and Queue Members
*        2. Identify the CRs which needs to be processed for duplicate removal activity, and the corresponding current step approvers
*        3. Update 4 approver fields - with non-duplicate approvers
*
*/
    public void removeDuplicateApprover(List<Capital_Requests__c> newCapReqList , Map<id,Capital_Requests__c> oldCapReqMap){
        map<Capital_Requests__c,Set<Id>> CR_QueueMembers_Map = new map<Capital_Requests__c,Set<Id>>();      //Map of CR record and QueueMembers-to-be-set-as-approver
        
        // Populating map by fetching data from custom setting for step and corresponding queue pair 
        initGroupMembers();
        
        //Identify the CRs where approvers need to be set wrt Queues 
        CR_QueueMembers_Map = IdentifyCRsAndApprovers(newCapReqList, oldCapReqMap);
        
        //set CR approver fields based on CR_QueueMembers_Map
        if(!CR_QueueMembers_Map.isEmpty()){
            setApproversInCR(CR_QueueMembers_Map);
        }
    }
    
  
/**
*    Grant EDIT access to current step approver, if doesn't has already
*    Revoke EDIT access once the step is approved 
*
*/
      public void shareRecord(List<Capital_Requests__c> newCapReqList,Map<id,Capital_Requests__c> oldCapReqMap){
        Set<Id> CurrentPendingStepApproverIdsSet = new Set<Id>();      
    
        List<Id> All_Step_Approvrs_Set = new List<Id>();   // Set containing all step approvers of a record
        

        List<Capital_Requests__Share> recordsToDelete = new List<Capital_Requests__Share>();
        List<Capital_Requests__Share> recordsToAdd = new List<Capital_Requests__Share>();      
        boolean isFinalStepApprovedRejectedRecalled = false;
        

        Map<Id,Set<Id>> CR_CurrentApprovers_Map = new Map<Id,Set<Id>>(); // map of CR and its current approvers
        Map<Id,Set<Capital_Requests__Share>> CR_CRShare_Map = new Map<Id,Set<Capital_Requests__Share>>();


        //Map of CR and its current approvers          
        for(ProcessInstanceWorkitem workItem  : [Select Id, ActorId, OriginalActorId, ProcessInstance.TargetObjectId from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId IN :newCapReqList ]){
            if(CR_CurrentApprovers_Map.containsKey(workItem.ProcessInstance.TargetObjectId)) {
                Set<Id> approvers = CR_CurrentApprovers_Map.get(workItem.ProcessInstance.TargetObjectId);
                approvers.add(workItem.ActorId); 
                CR_CurrentApprovers_Map.put(workItem.ProcessInstance.TargetObjectId, approvers);
            } else {
                CR_CurrentApprovers_Map.put(workItem.ProcessInstance.TargetObjectId, new Set<Id> { workItem.ActorId });
            }   
            All_Step_Approvrs_Set.add(workItem.ActorId);          
        }
        
        //get list of all Approvers for a record
       /* for(Id uId: CR_CurrentApprovers_Map.keyset()){       
            Set<Id> uSet =  CR_CurrentApprovers_Map.get(uId);
                for (Id sUid : uSet){
                        All_Step_Approvrs_Set.add(sUid);
                }            
        }*/   
        
        //If record is just submitted for Approval, Add Step-1 approvers into All_Step_Approvrs_Set separately
        for(Capital_Requests__c capitalRequestObj: newCapReqList){            
                if(capitalRequestObj.Financial_Analyst__c!=null){
                    All_Step_Approvrs_Set.add(capitalRequestObj.Financial_Analyst__c);
                }
                if(capitalRequestObj.Project_Manager__c!=null){
                    All_Step_Approvrs_Set.add(capitalRequestObj.Project_Manager__c);
                }                        
       }
        
        List<User> userList = [select id, name from User where IsActive = True and id in : All_Step_Approvrs_Set ];
        Map<Id, User> userMap = new Map<Id, User>(userList);
        
        
        for(Capital_Requests__c capitalRequestObj: newCapReqList ){ 
            if(CR_CurrentApprovers_Map.containsKey(capitalRequestObj.id)){
            String  currentApproverOfCFR ;
                for(Id ApproverID:CR_CurrentApprovers_Map.get(capitalRequestObj.id) ){
                    if(userMap.containsKey(ApproverID)){      
                        currentApproverOfCFR = currentApproverOfCFR +',' +userMap.get(ApproverID).name;            
                    }  
                }//End Inner FOR
                    if(null!= currentApproverOfCFR ){
                        if(currentApproverOfCFR.containsAny(',')){
                            capitalRequestObj.current_approver_of_CFR__c = currentApproverOfCFR.substringAfter(','); 
                        }else{
                            capitalRequestObj.current_approver_of_CFR__c = currentApproverOfCFR ;
                        }            
                        }          
            }
        }
        
        //Map of CR and corresponding CR_Share entries
        for(Capital_Requests__Share crShare : [SELECT Id, ParentId, UserOrGroupId FROM Capital_Requests__Share 
                                WHERE ParentId IN :newCapReqList AND RowCause = 'Access_of_CR_record_to_approvers__c' ]){
            
            if(CR_CRShare_Map.containsKey(crShare.ParentId)) {
                Set<Capital_Requests__Share> shareRec = CR_CRShare_Map.get(crShare.ParentId);
                shareRec.add(crShare);
                CR_CRShare_Map.put(crShare.ParentId, shareRec);
            } else {
                CR_CRShare_Map.put(crShare.ParentId, new set<Capital_Requests__Share> { crShare });
            }
        }
        
        for(Capital_Requests__c capitalRequestObj: newCapReqList){            
            if( capitalRequestObj.Status__c =='Routed for Approval'){
                if(CR_CurrentApprovers_Map.get(capitalRequestObj.id) != null){
                    CurrentPendingStepApproverIdsSet = CR_CurrentApprovers_Map.get(capitalRequestObj.id);
                }        
                        
            }
            
            if(capitalRequestObj.Status__c != null && capitalRequestObj.Status__c != oldCapReqMap.get(capitalRequestObj.Id).Status__c) {
                //If record is just submitted for Approval, Add Step-1 approvers to CurrentPendingStepApproverIdsSet separately
                if( capitalRequestObj.Status__c =='Routed for Approval' && capitalRequestObj.Last_Approved_Step__c==null){ 
                    if(capitalRequestObj.recordTypeID == CapitalRecordTypeId){
                        if(capitalRequestObj.Financial_Analyst__c != null){
                           CurrentPendingStepApproverIdsSet.add(capitalRequestObj.Financial_Analyst__c);  
                           capitalRequestObj.current_approver_of_CFR__c = userMap.get(capitalRequestObj.Financial_Analyst__c).name;                               
                                        
                        }
                    } else if(capitalRequestObj.recordTypeID == LeaseRecordTypeId){
                        if(capitalRequestObj.Project_Manager__c != null){
                           CurrentPendingStepApproverIdsSet.add(capitalRequestObj.Project_Manager__c);     
                           capitalRequestObj.current_approver_of_CFR__c = userMap.get(capitalRequestObj.Project_Manager__c).name;  
                            
                        }
                        
                    }
                }
                //If record is approved, rejected or recalled in Approval process, access should be revoked from Share object 
                else if((oldCapReqMap.get(capitalRequestObj.Id).Status__c =='Routed for Approval') && (capitalRequestObj.Status__c=='Draft' || capitalRequestObj.Status__c=='Approved' || capitalRequestObj.Status__c=='Rejected')){
                    System.debug('Record Approved');
                    isFinalStepApprovedRejectedRecalled = true;
                    capitalRequestObj.current_approver_of_CFR__c = '';
                    System.debug('------capitalRequestObj.current_approver_of_CFR__c-------'+ capitalRequestObj.current_approver_of_CFR__c);
                    if(CR_CRShare_Map.get(capitalRequestObj.id) != null){
                        recordsToDelete.addAll(CR_CRShare_Map.get(capitalRequestObj.id));
                    }
                }
            }
            
            if(capitalRequestObj.Status__c =='Routed for Approval' && isFinalStepApprovedRejectedRecalled == false ){
                Set<Id> UsersInShareObject = new set<ID>();
                if(CR_CRShare_Map.get(capitalRequestObj.id) != null){
                    for(Capital_Requests__Share share : CR_CRShare_Map.get(capitalRequestObj.id) ){
                        //If Share object contains a user which is not current Approvers list, it shoudl be deleted
                        if(! CurrentPendingStepApproverIdsSet.contains(share.UserOrGroupId)){
                            recordsToDelete.add(share);
                        }
                        UsersInShareObject.add(share.UserOrGroupId);
                    }
                }
               
                for(Id ApproverID : CurrentPendingStepApproverIdsSet){
                    if(! UsersInShareObject.contains(ApproverID)){
                            recordsToAdd.add(new Capital_Requests__Share(ParentId= capitalRequestObj.id,UserOrGroupId= ApproverID, AccessLevel = 'edit', 
                                                                        RowCause = Schema.Capital_Requests__Share.RowCause.Access_of_CR_record_to_approvers__c));
                     }
                 }
                
            }//End IF
        
        
        }//End FOR
        
        if(!recordsToDelete.isEmpty()){
            Database.Delete(recordsToDelete, false);
        }
        if(!recordsToAdd.isEmpty()){
            Database.insert(recordsToAdd, false);
        }
        
    }// End Method      
        


    
/**
*   Method to fetch All members of given Queue  
*/
    public Set<ID> fetchQueueMembers(ID QueueID){
        Set<Id> membersIdSet = new set<Id>();
        
        for(GroupMember member : GroupID_MembersMap.get(QueueID)){
            String memberID = member.UserOrGroupId;
            if(memberID.startsWith('005')){         //If member is a User, add it to list
                membersIdSet.add(memberID);
            }else if(memberID.startsWith('00G')){   //If member is a Group, call the method recursively to get members of group and add to list
                membersIdSet.addAll(fetchQueueMembers(memberID));
            }
        }//End For
        return membersIdSet;
    }//End Method 
    

    
/**
*   Method to fetch IDs of Approvers who previously approved the CR  
*/    
    public map<Id, set<Id>> getApprovedUserIDs(List<ID> CR_ID_List ){
        
        map<Id, set<Id>> CR_PreviousApprovers_Map = new map<Id, set<Id>>();
        Set<Id> alreadyApprovedUserIdSet = new Set<Id>();
        
        if(! CR_ID_List.isEmpty()){
            //query to get already approved user in Approval Process
            for ( ProcessInstance pi: [SELECT Id, Status,TargetObjectId, (SELECT Id, ActorId, StepStatus FROM StepsAndWorkitems where StepStatus='Approved' )
                                       FROM ProcessInstance WHERE TargetObjectId IN :CR_ID_List AND status='Pending'] ) {                                 
                                           alreadyApprovedUserIdSet.clear();                
                                           for (ProcessInstanceHistory pih : pi.StepsAndWorkItems) {                                                                                       
                                               alreadyApprovedUserIdSet.add(pih.actorId);      
                                           }//End Inner FOR
                                           CR_PreviousApprovers_Map.put(pi.TargetObjectId, alreadyApprovedUserIdSet);                                                            
                                       }//End outer FOR            
        } //End IF             
        return CR_PreviousApprovers_Map;
    }//End Method
    
/**
*   Identify the CRs where approvers need to be set wrt Queues 
*/
    public map<Capital_Requests__c,Set<Id>> IdentifyCRsAndApprovers(List<Capital_Requests__c> newCapReqList , Map<id,Capital_Requests__c> oldCapReqMap){              
                
        map<Capital_Requests__c,Set<Id>> CR_QueueMembers_Map = new map<Capital_Requests__c,Set<Id>>();      //Map of CR record and Queue-to-be-set-as-approver
                
        //Populate Map CR_QueueMembers_Map -- by CR record and Queue-to-be-set-as-approver
        for(Capital_Requests__c capitalRequestObj: newCapReqList){ 
            //Proceed only if Approval Step has recently changed
            if(capitalRequestObj.Last_Approved_Step__c != null && capitalRequestObj.Last_Approved_Step__c != oldCapReqMap.get(capitalRequestObj.Id).Last_Approved_Step__c ){ 
                String queueName= '';            
                Integer NextApprovalStepNumber ;
                
                //Setting NextApprovalStepNumber for Capital record type by identifying step criteria 
                if(capitalRequestObj.recordTypeID == CapitalRecordTypeId){
                    // Setting Next approval step no by identifying all the state of field Project Object and Does Project req IT asset purchase
                    if(capitalRequestObj.Last_Approved_Step__c == '3'){
                        if(capitalRequestObj.Project_Objective__c == 'Rental'){                 
                            NextApprovalStepNumber = integer.valueof(capitalRequestObj.Last_Approved_Step__c)+1 ;        
                        }else if(capitalRequestObj.Does_project_require_IT_asset_purc__c == true){
                            NextApprovalStepNumber = integer.valueof(capitalRequestObj.Last_Approved_Step__c)+2 ;           
                        }else if(capitalRequestObj.Does_project_require_IT_asset_purc__c == false){
                            NextApprovalStepNumber = integer.valueof(capitalRequestObj.Last_Approved_Step__c)+3 ;           
                        }
                        // Setting NextApprovalStepNumber by identifying all the state of field Project Object and Does Project req IT asset purchase       
                    }else if(capitalRequestObj.Last_Approved_Step__c == '4'){
                        if(capitalRequestObj.Project_Objective__c == 'Rental' ){
                            if(capitalRequestObj.Does_project_require_IT_asset_purc__c == true){
                                NextApprovalStepNumber = integer.valueof(capitalRequestObj.Last_Approved_Step__c)+1 ;                               
                            }else if(capitalRequestObj.Does_project_require_IT_asset_purc__c == false){
                                NextApprovalStepNumber = integer.valueof(capitalRequestObj.Last_Approved_Step__c)+2 ;                               
                            }                           
                        }
                    }
                    // Setting NextApprovalStepNumber by identifying all the state of field Safety Issues and Facility Impact
                    else if(capitalRequestObj.Last_Approved_Step__c == '6'){
                        if(capitalRequestObj.Is_a_Safety_Issue__c == true){             
                            NextApprovalStepNumber = integer.valueof(capitalRequestObj.Last_Approved_Step__c)+1 ;               
                        }else if(capitalRequestObj.Facilities_Impact__c == true){
                            NextApprovalStepNumber = integer.valueof(capitalRequestObj.Last_Approved_Step__c)+2 ;           
                        }else if(capitalRequestObj.Facilities_Impact__c == false){
                            NextApprovalStepNumber = integer.valueof(capitalRequestObj.Last_Approved_Step__c)+3 ;           
                        }
                        // Setting NextApprovalStepNumber by identifying all the state of field Safety Issues and Facility Impact
                    }else if(capitalRequestObj.Last_Approved_Step__c == '7'){
                        if(capitalRequestObj.Is_a_Safety_Issue__c == true ){
                            if(capitalRequestObj.Facilities_Impact__c == true){
                                NextApprovalStepNumber = integer.valueof(capitalRequestObj.Last_Approved_Step__c)+1 ;                               
                            }else if(capitalRequestObj.Facilities_Impact__c == false){
                                NextApprovalStepNumber = integer.valueof(capitalRequestObj.Last_Approved_Step__c)+2 ;                               
                            }                       
                        }
                    }else if(capitalRequestObj.Last_Approved_Step__c == '11' ){
                     //Setting NextApprovalStepNumber for Capital record type as per value of field Is related to US field service or therapy fleet
                            if(capitalRequestObj.Related_US_field_service_therapy_fleet__c == null){
                                NextApprovalStepNumber = integer.valueof(capitalRequestObj.Last_Approved_Step__c)+2 ;
                            }else {
                                NextApprovalStepNumber = integer.valueof(capitalRequestObj.Last_Approved_Step__c)+1 ;           
                            }
                    }
                    else{ 
                        NextApprovalStepNumber = integer.valueof(capitalRequestObj.Last_Approved_Step__c)+1 ;                        
                    }
                }else if(capitalRequestObj.recordTypeID == LeaseRecordTypeId){ 
                    //Setting NextApprovalStepNumber for Lease record type by identifying step criteria  
                    if(capitalRequestObj.Last_Approved_Step__c == '1' && capitalRequestObj.Area_AVP__c == null ){
                        NextApprovalStepNumber = integer.valueof(capitalRequestObj.Last_Approved_Step__c)+2 ;
                    }else {
                        NextApprovalStepNumber = integer.valueof(capitalRequestObj.Last_Approved_Step__c)+1 ;           
                    }
                   //Setting NextApprovalStepNumber for Lease record type as per value of field Is related to US field service or therapy fleet
                    if(capitalRequestObj.Last_Approved_Step__c == '11' && capitalRequestObj.Related_US_field_service_therapy_fleet__c == null ){
                        NextApprovalStepNumber = integer.valueof(capitalRequestObj.Last_Approved_Step__c)+2 ;
                    }else {
                        NextApprovalStepNumber = integer.valueof(capitalRequestObj.Last_Approved_Step__c)+1 ;           
                    }
                } 
                
                // Identify Approver-QueueName For CAPITAL record type    
                if(capitalRequestObj.recordTypeID == CapitalRecordTypeId){              
                    if(CapitalStepQueueMap.get(NextApprovalStepNumber) != null){                        
                        queueName = CapitalStepQueueMap.get(NextApprovalStepNumber);
                    }   
                }// Identify Approver-QueueNameFor LEASE record Type
                else if(capitalRequestObj.recordTypeID == LeaseRecordTypeId){               
                    if(LeaseStepQueueMap.get(NextApprovalStepNumber) != null){
                        queueName = LeaseStepQueueMap.get(NextApprovalStepNumber);
                    }                   
                }                
                
                //Add to Map CR_QueueMembers_Map
                if(queueName != ''){
                    CR_QueueMembers_Map.put(capitalRequestObj, fetchQueueMembers(GroupNameWithIdMap.get(queueName)));
                }                
            }// End IF                       
        } // End FOR                
        return CR_QueueMembers_Map;         
    }// End Method
    
/**
*   Set approver fields in Capital Request record eliminating the duplicate approvers
*/
    public void setApproversInCR( Map<Capital_Requests__c,set<Id>> CR_members_Map){
        list<Id> finalApproversList;
        list<ID> CrIDList = new list<Id>();                      //List of IDs of CRs to be processed
        map<Id, set<Id>> cr_PreviousApproverIds_Map = new map<Id, set<Id>>();  //Set of Approver IDs who previously approved the CRs
        Set<Id> previousApproversOfCR = new set<Id>();
        Set<ID> QueueMembersForNextStep = new set<Id>();        
        
        //Populate list CrIDList 
        for(Capital_Requests__c cr: CR_members_Map.keyset()){       
            CrIDList.add(cr.id);
        }        
        
        //Populate Set PreviousApproverIdsSet -- by IDs of Approvers who previously approve the CRs
        cr_PreviousApproverIds_Map = getApprovedUserIDs(CrIDList);          
        
        for(Capital_Requests__c capitalRequest : CR_members_Map.keyset()){
            
            previousApproversOfCR = cr_PreviousApproverIds_Map.get(capitalRequest.id);         
            
            QueueMembersForNextStep = CR_members_Map.get(capitalRequest);            
            
            QueueMembersForNextStep.removeAll(previousApproversOfCR);
            finalApproversList = new list<Id>(QueueMembersForNextStep);
            //set Approvers using finalApproversList
            if(!finalApproversList.isEmpty()){            
                
                //    if only 1 user in finalApproversList, then set that users in all 4 Approver fields
                if(finalApproversList.size() == 1){                           
                    capitalRequest.Approver_1__c = finalApproversList[0];
                    capitalRequest.Approver_2__c = finalApproversList[0];
                    capitalRequest.Approver_3__c = finalApproversList[0];
                    capitalRequest.Approver_4__c = finalApproversList[0];
                    
                    //  if 2 users in finalApproversList, then set Approver 1,Approver 3,Approver 4 as user 1 and Approver 2 as user 2
                }else if(finalApproversList.size() ==2){                                   
                    capitalRequest.Approver_1__c = finalApproversList[0];                
                    capitalRequest.Approver_2__c = finalApproversList[1];                
                    capitalRequest.Approver_3__c = finalApproversList[0];                
                    capitalRequest.Approver_4__c = finalApproversList[0];
                    
                    //  if 3 users in finalApproversList, then set Approver 1 as user 1,Approver 2 as user 2, Approver 3 as user 3 and Approver 4 as user 1
                }else if(finalApproversList.size() ==3){                                    
                    capitalRequest.Approver_1__c = finalApproversList[0];
                    capitalRequest.Approver_2__c = finalApproversList[1];
                    capitalRequest.Approver_3__c = finalApproversList[2];
                    capitalRequest.Approver_4__c = finalApproversList[0];
                    
                    //  if 4 users in finalApproversList, then set Approver 1 as user 1,Approver 2 as user 2, Approver 3 as user 3 and Approver 4 as user 4
                }else if(finalApproversList.size() > 3){  
                    capitalRequest.Approver_1__c = finalApproversList[0];                    
                    capitalRequest.Approver_2__c = finalApproversList[1];                    
                    capitalRequest.Approver_3__c = finalApproversList[2];                    
                    capitalRequest.Approver_4__c = finalApproversList[3];
                    
                }
            }//End IF
            else{
                    capitalRequest.Approver_1__c = capitalRequest.Approver_2__c = capitalRequest.Approver_3__c = capitalRequest.Approver_4__c = UserInfo.getUserId();                
            }
        }//End FOR
    }//End Method removeDuplicateApprovers
    
/*
* Auto Approval of record if the approver has already approved the record in previous step and he is unique approver in following step
*/
    public void AutoApproveWhenAllDuplicate(List<Capital_Requests__c> newCapReqList, Map<id,Capital_Requests__c> oldCapReqMap){
       
        List<Id> crList = new List<Id>();   //List of CRs who should be processed, whose approval step is moved forward
        map<Id, Id> CR_StepID_Map = new map<Id, Id>();      //Map of CapitalRequest and corresponding Approval-stepID(ProcessInstanceWorkitem)  
        map<Id, set<Id>> cr_PreviousApproverIds_Map = new map<Id, set<Id>>();  //Set of Approver IDs who previously approved the CRs
        map<ID, Set<Id>> CR_Approvers_Map = new map<ID,Set<Id>>();  // CR and list of approvers of current pending step
        set<Id> finalApproversList;
        Set<Id> TempApprovers = new Set<Id>();
        
        for(Capital_Requests__c cr : newCapReqList){
            if(cr.Auto_Approve_Step_HelperField__c  != null && cr.Auto_Approve_Step_HelperField__c != oldCapReqMap.get(cr.Id).Auto_Approve_Step_HelperField__c ){                
                crList.add(cr.id);                
            }//End IF
        }        
        //Identify assigned approvers of current pending Approval Step 
        for(ProcessInstanceWorkitem workItem  : [Select Id, ActorId, OriginalActorId, ProcessInstance.TargetObjectId from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId IN :crList ]){
                     
            //CR_PendingForApproval.add(workItem.ProcessInstance.TargetObjectId);
            CR_StepID_Map.put(workItem.ProcessInstance.TargetObjectId, workItem.Id);
            
            //populate CR_Approvers_Map
            if(CR_Approvers_Map.containsKey(workItem.ProcessInstance.TargetObjectId)){
                //TempApprovers.clear();
                //TempApprovers.addAll(CR_Approvers_Map.get(workItem.ProcessInstance.TargetObjectId));
                CR_Approvers_Map.get(workItem.ProcessInstance.TargetObjectId).add(workItem.OriginalActorId);
                
            }else{
                CR_Approvers_Map.put(workItem.ProcessInstance.TargetObjectId,new Set<ID>{workItem.OriginalActorId});
                //TempApprovers.clear();
                //TempApprovers.add(workItem.OriginalActorId);
                //CR_Approvers_Map.put(workItem.ProcessInstance.TargetObjectId,TempApprovers);
            }
            //TempApprovers.add(workItem.OriginalActorId);
            //CR_Approvers_Map.put(workItem.ProcessInstance.TargetObjectId,TempApprovers);
            
        }//End For
        
        //list<ID> CR_PendingForApproval = new list<Id>(CR_StepID_Map.keyset());
        //cr_PreviousApproverIds_Map = getApprovedUserIDs(CR_PendingForApproval); 
        
        //Identify Previous approvers for this CR
        
        for ( ProcessInstance pi: [SELECT Id, Status,TargetObjectId, (SELECT Id, ActorId, StepStatus FROM StepsAndWorkitems WHERE StepStatus = 'Approved')
                                   FROM ProcessInstance WHERE TargetObjectId IN :CR_StepID_Map.keyset() AND status='Pending' ] ) {                                      
                                       
                                       //alreadyApprovedUserIdSet.clear();
                                       Set<Id> alreadyApprovedUserIdSet = new Set<Id>();
                                       for (ProcessInstanceHistory pih : pi.StepsAndWorkItems) {                                             
                                           alreadyApprovedUserIdSet.add(pih.actorId);      
                                       }//End Inner FOR
                                       cr_PreviousApproverIds_Map.put(pi.TargetObjectId, alreadyApprovedUserIdSet); 
                                       
                                   }//End outer FOR        
        
        for (ID cr_ID :cr_PreviousApproverIds_Map.keyset()) {
            Set<Id> previousApproversSet = cr_PreviousApproverIds_Map.get(cr_ID);
            finalApproversList =  CR_Approvers_Map.get(cr_ID);
            
            finalApproversList.removeAll(previousApproversSet);
            
            if(finalApproversList.IsEmpty()){
                //auto Approve the step
                autoApproveRecord(cr_ID, CR_StepID_Map);
            }else{
                system.debug('---record should NOT be auto-approved----');
            }
        } 
        
    }//End Method   
    
/**
*   Used to auto approve step of approval process
*/
    public  void autoApproveRecord(ID CRidToApprove, map<Id, Id> CRStepMap) {     
         isRun = false;
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments('Auto-Approved as this approver had previously approved the request');
        req.setAction('Approve');
        req.setWorkitemId(CRStepMap.get(CRidToApprove));              
        Approval.ProcessResult result =  Approval.process(req);      
        
    } //End Method 
    
    

/**
* Method to identify if a Owner of record is not PM, then add PM to Group 
*/    
    public void addPMToGroup(List<Capital_Requests__c> crNewList){
        Set<Id> PMsToBeAddedToGroup = new Set<id>();
        
        // Method to identify if a Owner of record is not PM,then add PM to Group 
        for(Capital_Requests__c cr: crNewList){
            if(cr.Project_Manager__c != null && cr.Project_Manager__c != cr.OwnerId){
                PMsToBeAddedToGroup.add(cr.Project_Manager__c);
            }
        } 
        if(PMsToBeAddedToGroup.size()>0){
            createGroupMembers(PMsToBeAddedToGroup);
        }
        
    }
    
/**
* Method to add Project Manager into Group 'HRC CFR Project Manager'
*/  
    @future
    public static void createGroupMembers(Set<Id> PMIdSet) {
        List<GroupMember> gmList = new List<GroupMember>();
        Set<id> ExistingGroupMembersSet= new Set<id>();
        Group  PM_group = [Select id from group where type='Regular' and name='HRC CFR Project Manager' LIMIT 1];
        
        //Populate ExistingGroupMembersSet
        for (GroupMember gm : [Select Id, UserOrGroupId From GroupMember Where GroupId = :PM_group.id ]){
            ExistingGroupMembersSet.add(gm.UserOrGroupId);
        }
        
        //add PM into group, if he is not already present in group 
        for(Id PMId :PMIdSet){  
            if(!ExistingGroupMembersSet.contains(PMId )){        
                GroupMember newGroupMembers = new GroupMember(GroupId=PM_group.Id, UserOrGroupId=PMId );    
                gmList.add(newGroupMembers);
            }
        }
        
        if (Test.isRunningTest()) {
            // start new context via system.runAs() for the same user for test code only
            System.runAs(new User(Id = Userinfo.getUserId())) {
                insert gmList;
            }
        } else {
            // in non-test code insert normally
            insert gmList;
        }    
    }//End Method          
}//End Class