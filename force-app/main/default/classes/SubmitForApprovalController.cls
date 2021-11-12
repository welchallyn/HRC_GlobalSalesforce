public class SubmitForApprovalController{

    public Id objectId {get;set;}
    public Id changeStatusId {get;set;}
    public String comments {get;set;}
    public String targetObjectLabel {get;set;}
    public String targetObjectName {get;set;}
    public String name {get;set;}
    public String recordURL {get;set;}
    
    public Boolean isProcessComplete {get;set;}
    public Boolean isInitiate{get;set;}
    public Boolean isSuccessful {get;set;}
    public String errorMsg {get;set;}
    public String successMsg {get;set;}
    public Map<String,HillRom_Settings__c> customSettings;
    
    public SubmitForApprovalController() {
        customSettings = HillRom_Settings__c.getAll();
        isProcessComplete = false; 
        String currentPageURL = EncodingUtil.URLDecode(apexpages.currentpage().getURL(), 'UTF-8');
        System.debug('CurrentPageURL:' + currentPageURL);
        objectId = apexpages.currentpage().getparameters().get('objectId');
        changeStatusId = apexpages.currentpage().getparameters().get('changeStatusId');
        System.debug('ObjectId'+objectId);
        System.debug('IS Initiated Status'+changeStatusId);
        
        if(objectId != null) {
            Schema.SObjectType token = objectId.getSObjectType();
            Schema.DescribeSObjectResult dr = token.getDescribe();
            targetObjectLabel = dr.getLabel();
            targetObjectName = dr.getName();
        }
        
        sobject anyObject = Database.query('select Name from ' + targetObjectName + ' where Id = :objectId limit 1');   
        name = String.valueOf(anyobject.get('Name'));
        
        String pageURL = ApexPages.currentPage().getURL();
        System.debug('pageURL' + pageURL);
        
        recordURL = pageURL.substring(0,pageURL.indexOf('/apex/')) + '/' +objectId; 
        System.debug('recordURL' + recordURL);
        
        System.debug('Submitted for approval ' + getIsSubmittedForApproval());
        System.debug('Process Comelete'+ isProcessComplete);
        isInitiate = false;
        if(targetObjectName == 'BMCServiceDesk__Change_Request__c') {            
            BMCServiceDesk__Change_Request__c changeRecord = [select id, Name, BMCServiceDesk__Status__c from BMCServiceDesk__Change_Request__c where Id = :objectId limit 1];
            isInitiate = getChangeIsInInitiate(changeRecord.BMCServiceDesk__Status__c);            
            System.debug('Initiated'+getChangeIsInInitiate(changeRecord.BMCServiceDesk__Status__c));        
        }   
        System.debug('Initiated'+IsInitiate);
    
    }    
     public Boolean getChangeIsInInitiate(String changeStatus){
        HillRom_Settings__c initiateStatus = customSettings.get('INITIATE_STATUS');
        String initiateStatusValue;
        if(initiateStatus != null)
            initiateStatusValue = initiateStatus.Value__c;
        
        if(initiateStatusValue != null && changeStatus != null) {
            if(changeStatus == initiateStatusValue)
                return true;
            else
                return false;      
         }    
         return false;
     }   
    
    public Boolean getIsSubmittedForApproval() {
        objectId = apexpages.currentpage().getparameters().get('objectId');
        List<ProcessInstanceWorkItem> processInstanceWorkItemsList = [Select Id, ProcessInstanceId, ActorId, Actor.Name, Createddate,
            ProcessInstance.TargetObjectId, ProcessInstance.Status, ProcessInstance.CreatedDate
            From ProcessInstanceWorkItem Where ProcessInstance.TargetObjectId = :objectId and
                                                isDeleted = false and
                                                ProcessInstance.Status = 'Pending'
                                         Order By Createddate Desc limit 30000];
        if(processInstanceWorkItemsList != null && processInstanceWorkItemsList.size() > 0)
            return true;
        else 
            return false;
        
    }
    
     
    public PageReference submitForApproval() {
        objectId = apexpages.currentpage().getparameters().get('objectId');
        System.debug('Object Id'+ objectId);
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments(comments);
        req.setObjectId(objectId);
        
        Approval.ProcessResult result;
        try {
            result = Approval.process(req);    
        }
        catch(Exception ex) {
            System.debug('Error occured:' + ex);
            errorMsg = 'Error occured with ' + targetObjectLabel + ' ' + Name + ' when submitting for Approval:\n' + ex.getMessage();
        }
        System.debug('Result:'+ result);
        if(result != null && result.getInstanceStatus() == 'Pending') 
            isSuccessful = true;
        else
            isSuccessful = false;
                        
        successMsg = targetObjectLabel + ' ' + Name + ' has been submitted for approval successfully';
        isProcessComplete = true;
        
        return null;
    }
}