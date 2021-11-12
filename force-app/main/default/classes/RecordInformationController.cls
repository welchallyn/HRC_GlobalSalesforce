/*Requirement: Re-Enter credentials for approval
a.  Approval manager is prompted to re-enter his credentials before approving the items – Incident, Change Request etc.
b.  Items are approved only after verification of credentials provided by Approval Manager.
c.  However, if the approver wants to reject the record, he need not enter his credentials.
d.  For “Change Request” object records, users should not be able to make any changes to the ChangeRequest record after the approval phase. The user should only be able to change the Status, Status Reason and Work Info
*/

public class RecordInformationController {

    public Id objectId{get;set;}
    public Id workitemId{get;set;}
    public String targetObjectLabel{get;set;}
    public String targetObjectName{get;set;}
    public BMCServiceDesk__Incident__c incidentObj{get;set;}
    public BMCServiceDesk__Change_Request__c changerequestObj{get;set;}
    public String name{get;set;}
    public String description{get;set;}
    public String objecttype{get;set;}
    public String comments{get;set;}
    public String password { get; set; }
    public String userName { get; set; }
    Map<String,HillRom_Settings__c> customSettings = HillRom_Settings__c.getAll();            

    public RecordInformationController(){
        objectId = apexpages.currentpage().getparameters().get('objectId');
        workitemId = apexpages.currentpage().getparameters().get('workitemId');
        if(objectId != null) {
            Schema.SObjectType token = objectId.getSObjectType();
            Schema.DescribeSObjectResult dr = token.getDescribe();
            TargetObjectLabel = dr.getLabel();
            TargetObjectName = dr.getName();
        }   
        //auto-populate username by default
        userName = UserInfo.getUserName();
        //If Incident, get the Incident description
        if(targetObjectLabel == 'Incident') {
            incidentObj = [SELECT Name, BMCServiceDesk__incidentDescription__c FROM BMCServiceDesk__Incident__c WHERE Id = : objectId LIMIT 1];
            objecttype = targetObjectLabel;
            name = incidentObj.Name;
            description = incidentObj.BMCServiceDesk__incidentDescription__c; 
        }
        //If ChangeRequest, get the Change description
        else if(targetObjectLabel == 'Change Request') {
            changerequestObj = [SELECT Name, BMCServiceDesk__Change_Description__c FROM BMCServiceDesk__Change_Request__c WHERE Id = : objectId LIMIT 1];
            objecttype = targetObjectLabel;
            name = changerequestObj.Name;
            description = changerequestObj.BMCServiceDesk__Change_Description__c; 
        }
        // For all other objects
        else {
            if(objectId!=null) {
                sobject anyobject = Database.query('select Name from ' + targetObjectName + ' where Id = :objectId limit 1');   
                name = String.valueOf(anyobject.get('Name'));
            }
            objecttype = targetObjectLabel; 
        }
    }
    // This method when called rejects the approval record in context
    public PageReference reject() {
        try {
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setComments(comments);
            req.setAction('Reject');
            req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            req.setWorkitemId(workitemId);
            Approval.ProcessResult result =  Approval.process(req);
            
            System.assert(result.isSuccess(), 'Result Status:'+result.isSuccess());
            System.assertEquals(
            'Rejected', result.getInstanceStatus(), 
            'Instance Status'+result.getInstanceStatus());
            PageReference pg  = new PageReference('/'+objectId);
            pg.setRedirect(true);    
            return pg;
        }
        catch(Exception e) {
            System.debug('Exception message:'+e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occured. Could not process your request.<br/><a href=/apex/ItemsToApprove> Click here</a>  to view all the pending approvals.'));
            return null;
        }
    }
    
    // Functionality to clear any existing page messages
    public void clearPageMessages() {
        ApexPages.getMessages().clear();
    }
    
    // Functionality to authenticate the user
    public PageReference login() {
        final string baseUrl;
        
        String host = System.URL.getSalesforceBaseUrl().getHost();
        
        System.debug(host);
        Boolean isSandbox = Pattern.matches('(.*\\.)?cs[0-9]*(-api)?\\..*force.com',host);
        System.debug('Is Sandbox:'+ isSandbox);
        
        HillRom_Settings__c ProductionSetting = customSettings.get('Production');
        HillRom_Settings__c SandboxSetting =  customSettings.get('Sandbox');
        String productionBaseURL; //= 'https://login.salesforce.com/';
        String sandboxBaseURL; //= 'https://test.salesforce.com/';
        
        if(ProductionSetting != null)
            productionBaseURL = ProductionSetting.value__c;
        if(SandboxSetting != null)
            sandboxBaseURL = SandboxSetting.value__c;
        
        if(isSandbox)
            baseURL = sandboxBaseURL ;
        else
            baseURL = productionBaseURL ;
        
        
        /* get the client-id and client_secret of the Connected App which are maintained in the Custom Settings */
        HillRom_Settings__c client_idSetting = customSettings.get('client_id');
        HillRom_Settings__c client_secretSetting = customSettings.get('client_secret');
        String client_id;
        String client_secret;
        if(client_idSetting!=null)
            client_id = client_idSetting.value__c;
        if(client_secretSetting!=null)
            client_secret = client_secretSetting.value__c;
            
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
/* form the request body*/
        String content = '';
        content+='grant_type=password';
        content+='&client_id='+client_id;
        content+='&client_secret='+client_secret;
        content+='&username='+userName;
        content+='&password='+password;
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody(content);
        HttpResponse res;
        try {
            if(! Test.isrunningTest()) {
                /*req.setEndpoint(baseUrl + '?loginType=&un='+userName+'&pw='+password);*/
                req.setEndpoint(baseUrl + 'services/oauth2/token');
                res = h.send(req);
            }
            else {
                res = new HttpResponse();
                //res.setStatus('Found');            
            }
        }
        catch(Exception ex) {
            ApexPages.Message error = new ApexPages.Message(ApexPages.Severity.ERROR,'Some error occured. Please try again (or)<br/><a href=/apex/ItemsToApprove> Click here</a> to view all the pending approvals' );
            System.debug('Response: ' + res);
            ApexPages.addMessage(error);
            return null;
        }    
        System.debug('Response received'+res);
        System.debug('Response body'+res.getBody());
        
        PageReference pg=null;
        /*if(res.getStatus() == 'Found' && UserInfo.getUserName()==userName) { */
        ResponseBody resBody;
        if(!Test.isRunningTest())
        resBody = (ResponseBody)JSON.deserialize(res.getBody(), ResponseBody.class);
        System.debug('resBody:' + resBody);
        if(res.getStatusCode()==200 && resBody!=null && resBody.access_token!=null && resBody.access_token!='' && UserInfo.getUserName()==userName) {         
            system.debug('####Success');
            pg = approve();    
        }
        else if(String.valueOf(res.getStatusCode()).startsWith('5')) {
            ApexPages.Message error = new ApexPages.Message(ApexPages.Severity.ERROR,'Server failed to fulfil your request.' );
            System.debug('Error Status:'+res.getStatus()+' Error Body'+res.getBody());
            ApexPages.addMessage(error);            
        }
        else {
            ApexPages.Message error = new ApexPages.Message(ApexPages.Severity.ERROR,'Authentication Failed. The username or password may be <br/>incorrect.<br/><a href="/secur/forgotpassword.jsp?locale=us" target="_blank"> Click here </a> to reset your password' );
            System.debug('Error Status:'+res.getStatus()+' Error Body'+res.getBody());
            ApexPages.addMessage(error);
        }
        return pg;
    }
    
    public PageReference approve(){
        String approved = '';
        try {
            Approval.ProcessWorkItemRequest req = new Approval.ProcessWorkItemRequest();
            req.setAction('Approve');
            req.setNextApproverIds(req.getNextApproverIds());
            req.setWorkitemId(workitemId);
            System.debug('WorkItemId:'+workItemId);                
            req.setComments(comments);
            System.debug('Request:'+req);
            Approval.ProcessResult result = Approval.process(req);
            System.debug('Result:'+result+'Result Success:'+result.isSuccess());
            
            HillRom_Settings__c UseAfterApprovalRecordTypeSetting = customSettings.get('UseAfterApprovalRecordType');
            HillRom_Settings__c AfterApprovalRecordTypeSetting =  customSettings.get('AfterApprovalRecordType');
            String UseAfterApprovalRecordTypeValue = null;
            String AfterApprovalRecordTypeValue = null;
            if(UseAfterApprovalRecordTypeSetting != null)
                UseAfterApprovalRecordTypeValue = UseAfterApprovalRecordTypeSetting.Value__c;
            if(AfterApprovalRecordTypeSetting != null)
                AfterApprovalRecordTypeValue = AfterApprovalRecordTypeSetting.Value__c;

            if (result.isSuccess()) {
                System.debug('Instance Status:'+result.getInstanceStatus());
                  
                 if(result.getInstanceStatus() == 'Approved' && targetObjectName == 'BMCServiceDesk__Change_Request__c' && UseAfterApprovalRecordTypeValue != null && (UseAfterApprovalRecordTypeValue.toLowerCase().equals('true') || UseAfterApprovalRecordTypeValue.toLowerCase().equals('yes'))) {
                    BMCServiceDesk__Change_Request__c change = [select Id, BMCServiceDesk__State__c, BMCServiceDesk__Status__c, RecordTypeId, Approver1__c, Approver2__c, Approved1__c, Approved2__c, Review_Approved__c, Plan_Approved__c, Implement_Approved__c from BMCServiceDesk__Change_Request__c where Id=:objectId limit 1];
                    System.debug('Change Request:'+ change);
                    
                    
                    
                   if(change.Approver1__c != null && change.Approver2__c == null && change.Approved1__c == true){
                       change.Approver1__c = null;
                       update change;                    
                   }
                   else if(change.Approver2__c != null && change.Approved2__c == true){
                       change.Approver1__c = null;    
                       change.Approver2__c = null;
                       update change;                    
                   }   
                   
                   
                   
                   if(change.BMCServiceDesk__Status__c.equals('IMPLEMENT') && ((change.Approver1__c == null && change.Approver2__c == null && change.Implement_Approved__c == 2) || (change.Approver1__c != null && change.Approver2__c == null && change.Approved1__c == true) || (change.Approver2__c != null && change.Approved2__c == true))){
                    Schema.DescribeSObjectResult dr  = Id.ValueOf(objectId).getSObjectType().getDescribe();
                    if(dr != null && AfterApprovalRecordTypeValue != null && change.BMCServiceDesk__State__c != false) {
                        Map<String,Schema.RecordTypeInfo> rtMapByName = dr.getRecordTypeInfosByName();

                        System.debug('RecordType value:'+AfterApprovalRecordTypeValue);
                        RecordTypeInfo rti = rtMapByName.get(AfterApprovalRecordTypeValue);

                        System.debug(rti);
                        System.debug('OldRecordType'+change.RecordTypeId+'New Record Type:'+ rti.getRecordTypeId());
                        if(rti != null) {
                            change.RecordTypeId =  rti.getRecordTypeId();
                            update change;
                           
                        }
                   }
                   
                   }
                   
                   
                    
                   /* Schema.DescribeSObjectResult dr  = Id.ValueOf(objectId).getSObjectType().getDescribe();
                    if(dr != null && AfterApprovalRecordTypeValue != null && change.BMCServiceDesk__State__c != false) {
                        Map<String,Schema.RecordTypeInfo> rtMapByName = dr.getRecordTypeInfosByName();

                        System.debug('RecordType value:'+AfterApprovalRecordTypeValue);
                        RecordTypeInfo rti = rtMapByName.get(AfterApprovalRecordTypeValue);

                        System.debug(rti);
                        System.debug('OldRecordType'+change.RecordTypeId+'New Record Type:'+ rti.getRecordTypeId());
                        if(rti != null) {
                            change.RecordTypeId =  rti.getRecordTypeId();
                            update change;
                        }
                    }*/
                }                

                PageReference pg = new PageReference('/'+ objectId);
                pg.setRedirect(true);    
                return pg;
            }
            else {
                ApexPages.Message error = new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error with the Approval. Couldnot approve the record<br/><a href=/apex/ItemsToApprove> Click here</a>  to view all the pending approvals.');
                ApexPages.addMessage(error);
                System.debug('Error debug:'+result.getErrors());
                return null;
            }  
        }  
        catch(Exception e) {
            System.debug('Exception message:'+e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occured in the process.<br/><a href=/apex/ItemsToApprove> Click here</a>  to view all the pending approvals.'));
            return null;
        }
    }

    class ResponseBody {
        String id;
        String issued_at;
        String token_type;
        String instance_url;
        String signature;
        String access_token;
        String error_description;
        String error;
    }
}