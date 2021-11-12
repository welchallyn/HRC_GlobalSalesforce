public class ItemsToApproveController {

List<PendingApprovalRecord> pendingApprovalRecordsList {get; set;}

    public ItemsToApproveController() {
        pendingApprovalRecordsList = new List<PendingApprovalRecord>();
    }
    
    public List<PendingApprovalRecord> queryPendingApprovalRecords() {
    
          // Query the list of queues/groups in which the logged-in user is a member.  
          List<GroupMember> GM = [select GroupId, UserOrGroupId from GroupMember where UserOrGroupId = :UserInfo.getUserId() limit 10000];
          Set<Id> groupIdSet = new Set<Id>();
          for (GroupMember g : GM) {
              groupIdSet.add(g.GroupId);
          }
        // Query the records pending for approval by either the logged-in user (or) by the queue in which logged-in user is a member 
        List<ProcessInstanceWorkItem> processInstanceWorkItemsList = [Select Id, ProcessInstanceId, ActorId, Actor.Name, Createddate,
            ProcessInstance.TargetObjectId, ProcessInstance.Status, ProcessInstance.CreatedDate
            From ProcessInstanceWorkItem Where isDeleted = false and
                                                ProcessInstance.Status = 'Pending' and
                                                (ActorId = :UserInfo.getUserId() or ActorId=:groupIdSet)
            Order By Createddate Desc limit 30000];
       
       // Create a Pending Approval object for each pending approval record  
       for(ProcessInstanceWorkItem piwi : processInstanceWorkItemsList) {
           PendingApprovalRecord par = new PendingApprovalRecord(piwi);
           pendingApprovalRecordsList.add(par);
       }
              
       return pendingApprovalRecordsList;
  } 
}