public class ClosureQuestionnaireExtension {
    public string answer {get;set;}
    public static Boolean render {get;set;}
    public BMCServiceDesk__Change_Request__c record;
    private ApexPages.StandardController controller;
        public ClosureQuestionnaireExtension(ApexPages.StandardController controller) {
        this.controller = controller; 
            record= (BMCServiceDesk__Change_Request__c )controller.getRecord();
            if(record.Is_this_issue_caused_due_to_another_CR__c != 'Yes'){
                render = false;
            }
            
             //record= (BMCServiceDesk__Change_Request__c )controller.getRecord();
            system.debug('controller ClosureQuestionnaireExtension '+ controller); 
    }
    
    public PageReference saveAndRedirect() {
        record = (BMCServiceDesk__Change_Request__c )controller.getRecord();
       
        if(record.Is_this_issue_caused_due_to_another_CR__c == 'Yes'&& record.If_Yes_then_CR_number_to_be_updated__c==null ){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter CR number'));
        }
        else{
            if(record.Is_this_issue_caused_due_to_another_CR__c == 'No'){
            	record.If_Yes_then_CR_number_to_be_updated__c = null;
        	}
            if(record.Is_this_an_Emergency_Change__c == 'Yes'){
            	record.BMCServiceDesk__Change_Type__c = 'Emergency';    
            }
            update record;
            BMCServiceDesk__Change_Request__c crDetails = [Select Id,BMCServiceDesk__Change_Type__c,BMCServiceDesk__FKStatus__r.Name from BMCServiceDesk__Change_Request__c where id = :controller.getId()];
            system.debug('crDetails '+crDetails);
            PageReference result= new PageReference('/apex/NextStage?redirectId=default&changeType=' + crDetails.BMCServiceDesk__Change_Type__c + '&status=' + crDetails.BMCServiceDesk__FKStatus__r.Name + '&changeId=' + controller.getId());
            return result;
            }
            return null;
    }
}