/*
    *  ClassName    : NoteHandler
    *  CreatedOn    : 19/Oct/2016
    *  ModifiedOn   : 19/Oct/2016
    *  CreatedBy    : Jenish Shingala
    *  ModifiedBy   : Jenish Shingala
    *  Description  : Used for Handling all events for Notes (Note). 
*/
public with sharing class NoteHandler{
    /*
        * MethodName : onBeforeInsert
        * Param      : (nothing)
        * Description: Triggers on before insert 
    */     
    public void onBeforeInsert(List<Note> lstNoteNew)
    {
		//do nothing
		
    }
    /*
        * MethodName : onAfterInsert
        * Param      : (nothing)
        * Description: Triggers on after insert 
    */  
    
    public void onAfterInsert(List<Note> lstNoteNew)
    {
        updateParentOpportunity(lstNoteNew);
      
    }
    
    /*
        * MethodName    : onBeforeUpdate
        * Param         :  
        * Description   : 
    */ 
    
    public void onBeforeUpdate(map<Id , Note> mapIdToNoteOld, List<Note> lstNoteNew)    
    {
       
    }
    
    /*
        * MethodName : onAfterUpdate
        * Param      :  
        * Description: method executes after update.
    */ 
    public void onAfterUpdate(List<Note> lstNoteNew)
    {
       updateParentOpportunity(lstNoteNew);
    }
    
    /*
        * MethodName : onBeforeDelete
        * Param      :  
        * Description: Triggers on before delete 
    */ 
    
    public void onBeforeDelete(map<Id , Note> mapIdToNoteOld)
    {
        //Do Nothing
    }
    
    /*
        * MethodName : onAfterDelete
        * Param      :  
        * Description: Triggers on after delete 
    */  
    public void onAfterDelete(map<Id , Note> mapIdToNoteOld)
    {
        //Do Nothing
    }
    
	//Method contains Code from existing Trigger.(Trigger:UpdateOppLMDfromNote which has been deactivated).
	 
    public void updateParentOpportunity(List<Note> lstNoteNew){
        //Create Set to Store Opportunity Ids.
        set<id> opportunityIds = new set<id>();
        
        //Create List of Parent Opportunity to Update with Today's date.
        List<opportunity> lstOfOpportunityToUpdate = new List<opportunity>();
        
          try{
                if(lstNoteNew!=null && lstNoteNew.size()>0){
            
                    for(Note objNote:lstNoteNew){
                        if(objNote.parentid!=null && string.valueof(objNote.parentid).substring(0,3)=='006'){
                            //Add All Requreid Opportunity Ids into Set.
                            opportunityIds.add(objNote.parentid);
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