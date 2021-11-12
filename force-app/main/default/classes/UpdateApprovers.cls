/**
 * This batch class updates the approvers for incidents based on Role
 * This is called from ReplaceApprovers batch class
 */
global class UpdateApprovers implements Database.Batchable<sObject>, Database.Stateful {
    
    public List<ProcessInstanceWorkItem> newApprovalsList {get;set;}
    public List<ProcessInstanceWorkItem> currentBatch = new List<ProcessInstanceWorkItem>();
    public Map<Id,List<ProcessInstanceWorkItem>> toBeAutoApprovedMap {get;set;}
    public List<ProcessInstanceWorkItem> toBeAutoApprovedList{get;set;}
    public Integer minValue {get;set;}
    public Integer maxValue {get;set;}
    public Integer endIndex {get;set;}
    public Boolean firstTimeIn = True;
    public Integer recordsPerTransaction = 400;
    Map<Id, BMCServiceDesk__Incident__c> incidentMap;
    List<BMCServiceDesk__Incident__c> incToBeUpdated {get;set;}
    Set<BMCServiceDesk__Incident__c> incToBeUpdatedSet {get;set;}
    
    // To be used in AutoApproveIncBasedOnRole
    Map<Id, BMCServiceDesk__Incident__c> incMap=new Map<Id, BMCServiceDesk__Incident__c>();
    List<String> incAutoApproveList =new List<String>();
    
    /*
     * To be called from ReplaceApprovers batch class
     */
    global UpdateApprovers(List<ProcessInstanceWorkItem> newApprovalsList, Map<Id, BMCServiceDesk__Incident__c> incidentMap, Integer minValue, Integer maxValue,Map<Id,List<ProcessInstanceWorkItem>> toBeAutoApprovedMap, Integer endIndex) {
        this.newApprovalsList = newApprovalsList;
        this.incidentMap = incidentMap;
        this.minValue = minValue;
        this.maxValue = maxValue; 
        this.endIndex = endIndex; 
        this.toBeAutoApprovedMap = toBeAutoApprovedMap;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String userId = UserInfo.getUserId();
        System.debug('User ID'+userId);
        String query = 'select Id, FirstName, LastName, Email, CreatedDate from User where Id= :userId '  ;
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,  List<sobject> scope) {
        incToBeUpdated = new List<BMCServiceDesk__Incident__c>();
        incToBeUpdatedSet = new Set<BMCServiceDesk__Incident__c>();
        System.debug('In execute batchable');
        System.debug('New approval List%%% in update'+newApprovalsList +'Size of approval List:'+newApprovalsList.size());
        
        Approval.ProcessWorkItemRequest newRequestForApproval;
        List<Approval.ProcessWorkItemRequest> newRequestForApprovals = new List<Approval.ProcessWorkItemRequest>();
        currentBatch = new List<ProcessInstanceWorkItem>();
        
        //Auto Approve the extra placeholder work items
        for(Integer i=minValue; i< maxValue; i++) {
            currentBatch.add(newApprovalsList[i]);
            System.debug('toBeAutoApprovedMap:' + toBeAutoApprovedMap);
            toBeAutoApprovedList = toBeAutoApprovedMap.get(newApprovalsList[i].ProcessInstance.TargetObjectId);
            if(toBeAutoApprovedList != null && toBeAutoApprovedList.size() > 0) {
                for(ProcessInstanceWorkItem each:toBeAutoApprovedList) {
                    newRequestForApproval = new Approval.ProcessWorkItemRequest();
                    newRequestForApproval.setWorkItemId(each.Id);
                    newRequestForApproval.setComments('Auto-Approved by system');
                    newRequestForApproval.setAction('Approve');
                    newRequestForApprovals.add(newRequestForApproval);              
                }
                toBeAutoApprovedMap.remove(newApprovalsList[i].ProcessInstance.TargetObjectId); 
            }               
        }
        //Updating the approver to specified owner as in ApprovalRoleMappings
        try {
            Approval.ProcessResult[] result =  Approval.process(newRequestForApprovals);
        }
        catch(Exception ex) {
             System.debug('Exception occured: '+ ex.getMessage());
        } 
        
        System.debug('CurrentBatch: '+currentBatch);
        //Updating the Incident processed in the currentBatch
        if(currentBatch.size() > 0) {
            for(ProcessInstanceWorkItem each : currentBatch) {
                BMCServiceDesk__Incident__c inc = incidentMap.get(each.ProcessInstance.TargetObjectId);
                if(!incToBeUpdatedSet.contains(inc)) {
                    System.debug('####inc'+inc);
                    inc.Approval_processed__c = true;
                    incToBeUpdated.add(inc);
                    incToBeUpdatedSet.add(inc);
                    incMap.put(inc.id,inc);
              		incAutoApproveList.add('\''+inc.id+'\'');
  
                }
            } 
            System.debug('Batch Updated: MinValue: '+ minValue + ' MaxValue: '+ maxValue);
           if(currentBatch != null && currentBatch.size() > 0){
           try{
                update currentBatch;}
           catch(exception e){
               System.debug('Error in current batch'+e);}
               }
           if(incToBeUpdated != null && incToBeUpdated.size() > 0){
           try{
                update incToBeUpdated;}
           catch(exception e){
               System.debug('Error in Update incidents batch'+e);}
           }
        }            
    }
    
    global void finish( Database.BatchableContext BC ) {
        minValue = maxValue;
        System.debug('In finish Batchable');
        
        if((minValue + recordsPerTransaction ) > newApprovalsList.size() )
            maxValue = newApprovalsList.size();
        else 
            maxValue = minValue + recordsPerTransaction;
         
        System.debug('MinValue:' + minValue);
        System.debug('MaxValue:' + maxValue);
        /*
         * New code added for Auto Approval of Incident based on role 
         * August 1, 2016
         */
		List<ApprovalRoleMapping__c> approvalRoleMappingsList = [select Name, OwnerId from ApprovalRoleMapping__c where Approval_Not_Required__c = true limit 20000];
        Map<String,Id> noApprovalRolenames=new Map<String,Id>();
        //Creating a map of Roles and Owner that do not require approval
        if(approvalRoleMappingsList != null){
             for(ApprovalRoleMapping__c eachApprovalMapping : approvalRoleMappingsList){
                  noApprovalRolenames.put(eachApprovalMapping.Name, eachApprovalMapping.OwnerId);
               }
         }
        //Calling the batch class which auto approves the incident
        if( noApprovalRolenames != null && !noApprovalRolenames.isEmpty() && incAutoApproveList.size()>0){
            AutoApproveIncBasedOnRole autoApproveInstance = new AutoApproveIncBasedOnRole(incMap,incAutoApproveList,noApprovalRolenames);
            Database.executeBatch(autoApproveInstance);
        }
        /*
         * End of Auto Approval Code
         */
        if(minValue != maxValue) {
            UpdateApprovers ua = new UpdateApprovers(newApprovalsList, incidentMap, minValue, maxValue, toBeAutoApprovedMap, 0);
            Database.executeBatch(ua);
        }
/*        else {
            String str = System.now().addMinutes(1).format(‘ss mm HH dd MM ? yyyy’);
            System.schedule(‘AutomaticApprovalScheduler’, str , new ReplaceApprovers());
        }
*/
    }
}