/*
    *  ClassName    : EventHandler
    *  CreatedOn    : 19/Oct/2016
    *  ModifiedOn   : 21/Oct/2016
    *  CreatedBy    : Jenish Shingala
    *  ModifiedBy   : Jenish Shingala
    *  Description  : Used for Handling all events for Events (Event object). 
*/
public with sharing class EventHandler{
    /*
        * MethodName : onBeforeInsert
        * Param      : (nothing)
        * Description: Triggers on before insert 
    */     
    public void onBeforeInsert(List<Event> lstEventNew)
    {
		//do nothing
		
    } 
    /*
        * MethodName : onAfterInsert
        * Param      : (nothing)
        * Description: Triggers on after insert   
    */  
    
    public void onAfterInsert(List<Event> lstEventNew)
    {
        updateOppLMDfromEvent(lstEventNew);
      
    }
    
    /*
        * MethodName    : onBeforeUpdate
        * Param         :  
        * Description   : 
    */ 
    
    public void onBeforeUpdate(map<Id , Event> mapIdToEventOld, List<Event> lstEventNew)    
    {
       
    }
    
    /*
        * MethodName : onAfterUpdate
        * Param      :  
        * Description: method executes after update.
    */ 
    public void onAfterUpdate(List<Event> lstEventNew)
    {
       updateOppLMDfromEvent(lstEventNew);
    }
    
    /*
        * MethodName : onBeforeDelete
        * Param      :  
        * Description: Triggers on before delete 
    */ 
    
    public void onBeforeDelete(map<Id , Event> mapIdToEventOld)
    {
        //Do Nothing
    }
    
    /*
        * MethodName : onAfterDelete
        * Param      :  
        * Description: Triggers on after delete 
    */  
    public void onAfterDelete(map<Id , Event> mapIdToEventOld)
    {
        //Do Nothing
    }
    
	//Method contains Code from existing Trigger.(Trigger:UpdateOppLMDfromEvent which has been deactivated).
    public void updateOppLMDfromEvent(List<Event> lstEventNew){
           //Create Set to Store Opportunity Ids.
           set<id> opportunityIds = new set<id>();
        
           //Create List of Parent Opportunity to Update with Today's date.
           List<opportunity> lstOfOpportunityToUpdate = new List<opportunity>();
            try{
                if(lstEventNew!=null && lstEventNew.size()>0){
                
                for(Event objEvent:lstEventNew){
                    if(objEvent.whatid!=null && string.valueof(objEvent.whatid).substring(0,3)=='006'){
                        //Add All Requreid Opportunity Ids into Set.
                        opportunityIds.add(objEvent.whatid);
                    }
                }
                
                if(opportunityIds!=null && opportunityIds.size()>0){
                    //Get all Opportunity to Update.
                    List<Opportunity> lstOfParentOpportunity = [select id,Activity_Last_Update__c,IsClosed from Opportunity      
                                                               where id in :opportunityIds];
                    
                    //Loop through all Parent Opportunity and Add into List called 'lstOfOpportunityToUpdate';
                    for(Opportunity objOpportunity:lstOfParentOpportunity){
                        if(objOpportunity.IsClosed==false){
                            objOpportunity.Activity_Last_Update__c = Date.Today();
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