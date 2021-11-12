public with sharing class AssignToMeController{
    
    @AuraEnabled
    public static Case getCase(Id caseId) {
        
        System.debug('caseid>>>'+caseId);
        Case objCase = [SELECT id,ownerid from case WHERE Id = :caseId limit 1];
        objCase.ownerid = UserInfo.getUserId();
        try{
            update objCase;
        }
        catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        
        return objCase;
    }
    
}