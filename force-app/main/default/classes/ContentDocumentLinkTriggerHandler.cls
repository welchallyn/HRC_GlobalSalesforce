public class ContentDocumentLinkTriggerHandler {
    public static void updateHasContactCheckbox (List<ContentDocument> cdocs){
        Set<Id> cdocIds = new Set<Id>();
        Set<ID> parentIds = new Set<ID>();
        system.debug('cdocs '+cdocs.size());
        for(ContentDocument cd : cdocs){
            cdocIds.add(cd.Id);
        }
        List<ContentDocumentLink> cdls = [Select Id,LinkedEntityId from ContentDocumentLink where ContentDocumentId in :cdocIds];
        List<Evaluation_Form__c> evalFormsToUpdate = new List<Evaluation_Form__c>();
        for ( ContentDocumentLink cdl : cdls ) {
            parentIds.add( cdl.LinkedEntityId );
    	}
        for ( List<Evaluation_Form__c> evalFormList : [ SELECT Id, ( SELECT Id FROM ContentDocumentLinks where ContentDocument.title like '%Leihvertrag%' AND ContentDocumentId not in :cdocIds ) FROM Evaluation_Form__c WHERE Id IN :parentIds] ) 
        {
            for ( Evaluation_Form__c evalForm : evalFormList ) {
                if(evalForm.ContentDocumentLinks.size() > 0){
                    evalForm.has_contract__c = true;
                }
                else{
                    evalForm.has_contract__c = false;
                }
                evalFormsToUpdate.add(evalForm);
            }
        }
        if(evalFormsToUpdate.size() > 0){
        	update evalFormsToUpdate;    
        }
    }
    public static void updateHasContactCheckboxInsert (List<ContentDocumentLink> cdls){
        Set<ID> parentIds = new Set<ID>();
        List<Evaluation_Form__c> evalFormsToUpdate = new List<Evaluation_Form__c>();
        for ( ContentDocumentLink cdl : cdls ) {
            parentIds.add( cdl.LinkedEntityId );
    	}
        system.debug(' cdls '+cdls);
        for ( List<Evaluation_Form__c> evalFormList : [ SELECT Id, ( SELECT Id FROM ContentDocumentLinks where ContentDocument.title like '%Leihvertrag%' ) FROM Evaluation_Form__c WHERE Id IN :parentIds] ) 
        {
            for ( Evaluation_Form__c evalForm : evalFormList ) {
                if(evalForm.ContentDocumentLinks.size() > 0){
                    evalForm.has_contract__c = true;
                }
                else{
                    evalForm.has_contract__c = false;
                }
                evalFormsToUpdate.add(evalForm);
            }
        }
        update evalFormsToUpdate;    
    }
    public static void updateHasContactCheckboxUpdate (List<ContentDocument> cdocs){
        Set<Id> cdocIds = new Set<Id>();
        Set<ID> parentIds = new Set<ID>();
        for(ContentDocument cd : cdocs){
                cdocIds.add(cd.Id);
        }
        if(cdocIds.size() > 0){
            List<ContentDocumentLink> cdls = [Select Id,LinkedEntityId from ContentDocumentLink where ContentDocumentId in :cdocIds];
            List<Evaluation_Form__c> evalFormsToUpdate = new List<Evaluation_Form__c>();
            for ( ContentDocumentLink cdl : cdls ) {
                parentIds.add( cdl.LinkedEntityId );
            }
            for ( List<Evaluation_Form__c> evalFormList : [ SELECT Id, ( SELECT Id FROM ContentDocumentLinks where ContentDocument.title like '%Leihvertrag%' ) FROM Evaluation_Form__c WHERE Id IN :parentIds] ) 
            {
                for ( Evaluation_Form__c evalForm : evalFormList ) {
                    if(evalForm.ContentDocumentLinks.size() > 0){
                        evalForm.has_contract__c = true;
                    }
                    else{
                        evalForm.has_contract__c = false;
                    }
                    evalFormsToUpdate.add(evalForm);
                }
            }
            if(evalFormsToUpdate.size() > 0){
                update evalFormsToUpdate; 
            }
            
        }
    }
}