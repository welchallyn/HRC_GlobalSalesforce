/*
    *  ClassName    : ContentNoteHandler
    *  CreatedOn    : 11th Jan,2018
    *  CreatedBy    : Jenish Shingala
    *  ModifiedBy   : Jenish Shingala
    *  Description  : Handler class of ContentDocumentLinkTrigger.
*/
public with sharing class ContentNoteHandler{
    
    /*
        * MethodName : onAfterInsert
        * Param      : (nothing)
        * Description: Triggers on after insert 
    */  
    
    public void onAfterInsert(List<ContentDocumentLink> lstNoteNew)
    {
        updateParentOpportunity(lstNoteNew);
      
    }
    
    /*
        * MethodName : onAfterUpdate
        * Param      :  
        * Description: method executes after update.
    */ 
    public void onAfterUpdate(List<ContentDocumentLink> lstNoteNew)
    {
       
    }
    
    //Method contains Code from existing Trigger.(Trigger:UpdateOppLMDfromNote which has been deactivated).
	 
    public void updateParentOpportunity(List<ContentDocumentLink> lstNoteNew){
        //Create Set to Store Opportunity Ids.
        set<id> opportunityIds = new set<id>();
        
        //Create List of Parent Opportunity to Update with Today's date.
        List<opportunity> lstOfOpportunityToUpdate = new List<opportunity>();
        
          try{
                if(lstNoteNew!=null && lstNoteNew.size()>0){
            
                    for(ContentDocumentLink objNote:lstNoteNew){
                        if(objNote.LinkedEntityId!=null && string.valueof(objNote.LinkedEntityId).substring(0,3)=='006'){
                            //Add All Requreid Opportunity Ids into Set.
                            opportunityIds.add(objNote.LinkedEntityId);
                        }
                    }
                    
                    if(opportunityIds!=null && opportunityIds.size()>0){
                        //Get all Opportunity to Update.
                        List<Opportunity> lstOfParentOpportunity = [select id,Note_Last_Update__c,IsClosed from Opportunity      
                                                                   where id in :opportunityIds];
                        
                        //Loop through all Parent Opportunity and Add into List called 'lstOfOpportunityToUpdate';
                        for(Opportunity objOpportunity:lstOfParentOpportunity){
                            if(objOpportunity.IsClosed==false){
                                objOpportunity.Note_Last_Update__c = Date.Today();
                                lstOfOpportunityToUpdate.add(objOpportunity);
                            } 
                        }
                        if(lstOfOpportunityToUpdate!=null && lstOfOpportunityToUpdate.size()>0){
                            update lstOfOpportunityToUpdate;
                        }
                    }
                    
                    
                }
            
          }
          catch(Exception e){
              system.debug('Exception Occured..'+e);
          }
    }
}