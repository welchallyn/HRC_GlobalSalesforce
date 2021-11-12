public class NextStageLightningController {
    
    @AuraEnabled
    public static BMCServiceDesk__Change_Request__c getChangeRequest(Id crId) {
        system.debug('ID-->'+crId);
        BMCServiceDesk__Change_Request__c objCR = [SELECT Id, BMCServiceDesk__Change_Type__c,BMCServiceDesk__Status__c,Submitted_for_Approval__c,Plan_Rejected__c,
                                                  Implement_Rejected__c,Review_Rejected__c,Completed_Rejected__c FROM BMCServiceDesk__Change_Request__c WHERE Id = :crId];
        return objCR;
    }
}