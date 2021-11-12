/**
 * This is a queueable job to auto approve incident based on role selected.
 * This is called from the batch class AutoApproveIncBasedOnRole
 *  
 */
global class AutoApproveIncidentQueueable implements Queueable {
    
    global Set<ProcessInstanceWorkItem> requests; 
    global AutoApproveIncidentQueueable(Set<ProcessInstanceWorkItem> requests){
        this.requests=requests;
    }
    global void execute(QueueableContext context) {
        
        List<Approval.ProcessWorkItemRequest> autoApprovalRequestList = new List<Approval.ProcessWorkItemRequest>();
        Approval.ProcessWorkItemRequest autoApprovalRequest= new Approval.ProcessWorkItemRequest(); 
        //Auto Approve the ProcessInstanceWorkItem record
        for(ProcessInstanceWorkItem each:requests){ 
            autoApprovalRequest = new Approval.ProcessWorkItemRequest();
            autoApprovalRequest.setWorkItemId(each.Id);
            autoApprovalRequest.setComments('Auto-Approved');
            autoApprovalRequest.setAction('Approve');
            autoApprovalRequestList.add(autoApprovalRequest);
        }
        if(autoApprovalRequestList.size() > 0){
            try{
			Approval.ProcessResult[] result =  Approval.process(autoApprovalRequestList);
            System.debug('****>>>****'+result);       
            System.debug('****>>>****'+requests); 
            }
            catch(Exception e){
                System.debug('exeception occured'+e.getMessage());
            }
        }
			
    }
}