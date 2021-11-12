public class NextStageController {
    
 public String changeType{get;set;}   
 public String status{get;set;} 
 public String changeId{get;set;}
 public String redirectId {get; set;}
 public BMCServiceDesk__Change_Request__c changeRecord{get;set;}
 
 public NextStageController(){
    changeType = apexpages.currentpage().getparameters().get('changeType');
    status = apexpages.currentpage().getparameters().get('status');
    changeId = apexpages.currentpage().getparameters().get('changeId');
    redirectId = apexpages.currentpage().getparameters().get('redirectId');
    changeRecord = [SELECT Id, RecordTypeId,Implement_Approved__c, BMCServiceDesk__FKStatus__c, Approver1__c, Approver2__c FROM BMCServiceDesk__Change_Request__c WHERE Id =: changeId LIMIT 1];
    
    
    if(changeType.equals('Emergency') || changeType.equals('Standard')){
     
       if(status.equals('INITIATE'))
           changeRecord.BMCServiceDesk__FKStatus__c = [SELECT Id from BMCServiceDesk__Status__c where Name='REVIEW+AUTHORIZATION' LIMIT 1].Id;
       
       else if(status.equals('REVIEW AUTHORIZATION'))    
           changeRecord.BMCServiceDesk__FKStatus__c = [SELECT Id from BMCServiceDesk__Status__c where Name='PLAN+SCHEDULE' LIMIT 1].Id;

       else if(status.equals('PLAN SCHEDULE'))
           changeRecord.BMCServiceDesk__FKStatus__c = [SELECT Id from BMCServiceDesk__Status__c where Name='IMPLEMENT' LIMIT 1].Id;       
       
       else if(status.equals('IMPLEMENT'))
           changeRecord.BMCServiceDesk__FKStatus__c = [SELECT Id from BMCServiceDesk__Status__c where Name='COMPLETED' LIMIT 1].Id;
       
       else if(status.equals('COMPLETED') && changeType.equals('Standard'))
           changeRecord.BMCServiceDesk__FKStatus__c = [SELECT Id from BMCServiceDesk__Status__c where Name='CLOSED' LIMIT 1].Id;    
      
       
    }
    
    else if(changeType.equals('Normal')){
       RecordType rectypeId = [Select Id,Name from RecordType where Name = 'After Approval'];
                  
                  
    
       if(status.equals('INITIATE'))
           changeRecord.BMCServiceDesk__FKStatus__c = [SELECT Id from BMCServiceDesk__Status__c where Name='PLAN+SCHEDULE' LIMIT 1].Id;
            
       else if(status.equals('PLAN SCHEDULE')){
           changeRecord.BMCServiceDesk__FKStatus__c = [SELECT Id from BMCServiceDesk__Status__c where Name='IMPLEMENT' LIMIT 1].Id;    
           changeRecord.RecordTypeId = rectypeId.Id  ;
           changeRecord.Implement_Approved__c = 2;
       }    
       else if(status.equals('IMPLEMENT'))
           changeRecord.BMCServiceDesk__FKStatus__c = [SELECT Id from BMCServiceDesk__Status__c where Name='COMPLETED' LIMIT 1].Id;    
           
         
                
    }
    else if(changeType.equals('Normal with Close Down') ){
     
       RecordType rectypeId = [Select Id,Name from RecordType where Name = 'After Approval'];
                  
                  
    
       if(status.equals('INITIATE'))
           changeRecord.BMCServiceDesk__FKStatus__c = [SELECT Id from BMCServiceDesk__Status__c where Name='PLAN+SCHEDULE' LIMIT 1].Id;
            
       else if(status.equals('PLAN SCHEDULE')){
           changeRecord.BMCServiceDesk__FKStatus__c = [SELECT Id from BMCServiceDesk__Status__c where Name='IMPLEMENT' LIMIT 1].Id;    
           changeRecord.RecordTypeId = rectypeId.Id  ;
           changeRecord.Implement_Approved__c = 2;
       }    
       else if(status.equals('IMPLEMENT'))
           changeRecord.BMCServiceDesk__FKStatus__c = [SELECT Id from BMCServiceDesk__Status__c where Name='COMPLETED' LIMIT 1].Id;    
           
       else if(status.equals('COMPLETED'))
           changeRecord.BMCServiceDesk__FKStatus__c = [SELECT Id from BMCServiceDesk__Status__c where Name='CLOSED' LIMIT 1].Id;    
      
       
    }
    

    
    
 }
 
  public PageReference ChangeRecordApproval(){
  
    update changeRecord;
    
    String status = [SELECT BMCServiceDesk__FKStatus__r.Name FROM BMCServiceDesk__Change_Request__c WHERE Id =:changeId LIMIT 1].BMCServiceDesk__FKStatus__r.Name;
    
    System.debug('changeType'+changeType);
    System.debug('status'+status);
    if(changeType.equals('Emergency') || (changeType.equals('Normal') && !status.equals('IMPLEMENT'))){
        if(!status.equals('COMPLETED') && !status.equals('INITIATE')){
        
        
        // Create an approval request for the Change Request
      //  if(changeType.equals('Normal') && !status.equals('IMPLEMENT') ){
        System.debug('before approval status'+status);
        System.debug('before approval changetype'+changeType);
            try{
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting Change Request for approval automatically');
        req1.setObjectId(changeRecord.Id);
        
        // Submit the approval request for the Change Request
        Approval.ProcessResult result = Approval.process(req1);
       // }
                }
            catch(Exception e){
                System.debug('Exception '+e);
            }
        }
    }
    
    else if(changeType.equals('Standard')){
    
    if(!status.equals('CLOSED') && !status.equals('INITIATE')){
    
    // Create an approval request for the Change Request
        try{
    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
    req1.setComments('Submitting Change Request for approval automatically');
    req1.setObjectId(changeRecord.Id);
    
    // Submit the approval request for the Change Request
    Approval.ProcessResult result = Approval.process(req1);
            }
            catch(Exception e){
                System.debug('Exception '+e);
            }
    }
    }
    else if(changeType.equals('Normal with Close Down')){
        if(status.equals('PLAN+SCHEDULE') || status.equals('COMPLETED')){
            try{
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting Change Request for approval automatically');
            req1.setObjectId(changeRecord.Id);
            
            // Submit the approval request for the Change Request
            Approval.ProcessResult result = Approval.process(req1); 
            }
            catch(Exception e){
                System.debug('Exception '+e);
            }
        }
        
    }
    if(!redirectId.equalsIgnoreCase('remedyforceconsole')) {
        PageReference pg = new PageReference('/'+ changeRecord.Id);
        pg.setRedirect(true);
        return pg;
    } else {
        PageReference pg = new PageReference('https://hill-rom--hrctest--bmcservicedesk.cs20.visual.force.com/apex/RemedyforceConsole');
        pg.setRedirect(true);
       
        return pg;
    }
    
    
  }

}