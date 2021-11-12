/*
    *  ClassName    : AttachmentHandler
    *  CreatedOn    : 24/Oct/2016
    *  ModifiedOn   : 24/Oct/2016
    *  CreatedBy    : Jenish Shingala
    *  ModifiedBy   : Jenish Shingala
    *  Description  : Used for Handling all events for Attachment (Attachment). 
*/
public with sharing class AttachmentHandler {
    /*
        * MethodName : onBeforeInsert
        * Param      : (nothing)
        * Description: Triggers on before insert 
    */     
    public void onBeforeInsert(List<Attachment> lstAttachmentNew)
    {
		//do nothing
		
    }
    /*
        * MethodName : onAfterInsert
        * Param      : (nothing)
        * Description: Triggers on after insert 
    */  
    
    public void onAfterInsert(List<Attachment> lstAttachmentNew)
    {
        updateOppLMDfromAttachment(lstAttachmentNew);
      
    }
    
    /*
        * MethodName    : onBeforeUpdate
        * Param         :  
        * Description   : 
    */ 
    
    public void onBeforeUpdate(map<Id , Attachment> mapIdToAttachmentOld, List<Attachment> lstAttachmentNew)    
    {
        
    }
    
    /*
        * MethodName : onAfterUpdate
        * Param      :  
        * Description: method executes after update.
    */ 
    public void onAfterUpdate(List<Attachment> lstAttachmentNew)
    {
       updateOppLMDfromAttachment(lstAttachmentNew);
    }
    
    /*
        * MethodName : onBeforeDelete
        * Param      :  
        * Description: Triggers on before delete 
    */ 
    
    public void onBeforeDelete(map<Id , Attachment> mapIdToAttachmentOld)
    {
        //Do Nothing
    }
    
    /*
        * MethodName : onAfterDelete
        * Param      :  
        * Description: Triggers on after delete 
    */  
    public void onAfterDelete(map<Id , Attachment> mapIdToAttachmentOld)
    {
        //Do Nothing
    }
    
	//Method contains Code from existing Trigger.(Trigger:UpdateOppLMDfromAttachment  which has been deactivated).
	 
    public void updateOppLMDfromAttachment(List<Attachment> lstAttachmentNew){
        //Create Set to Store Opportunity Ids.
        set<id> opportunityIds = new set<id>();
        
        //Create List of Parent Opportunity to Update with Today's date.
        List<opportunity> lstOfOpportunityToUpdate = new List<opportunity>();
        
          try{
                if(lstAttachmentNew!=null && lstAttachmentNew.size()>0){
            
                    for(Attachment objAttachment:lstAttachmentNew){
                        if(objAttachment.parentid!=null && string.valueof(objAttachment.parentid).substring(0,3)=='006'){
                            //Add All Requreid Opportunity Ids into Set.
                            opportunityIds.add(objAttachment.parentid);
                        }
                    }
                    
                    if(opportunityIds!=null && opportunityIds.size()>0){
                        //Get all Opportunity to Update.
                        List<Opportunity> lstOfParentOpportunity = [select id,Attachment_Last_Update__c,IsClosed from Opportunity      
                                                                   where id in :opportunityIds];
                        
                        //Loop through all Parent Opportunity and Add into List called 'lstOfOpportunityToUpdate';
                        for(Opportunity objOpportunity:lstOfParentOpportunity){
                            if(objOpportunity.IsClosed==false){
                                objOpportunity.Attachment_Last_Update__c = Date.Today();
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