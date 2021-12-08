/*
    *  ClassName    : ContentNoteHandler
    *  CreatedOn    : 11th Jan,2018
    *  CreatedBy    : Jenish Shingala
    *  ModifiedBy   : David Berman
    *  Modified		: 1 Dec 2021
    *  Description  : Handler class of ContentDocumentLinkTrigger.
*/
public with sharing class ContentNoteHandler
{
    
    /*
        * MethodName : onAfterInsert
        * Param      : List of ContentDocumentLink records
        * Description: Triggers on after insert 
    */  
    
    public void onAfterInsert(List<ContentDocumentLink> lstNoteNew)
    {
        //updateParentOpportunity(lstNoteNew);
        Set<Id> setOpptyIDs = new Set<Id>();
        Set<Id> setComplaintQualIDs = new Set<Id>();
        
        for(ContentDocumentLink objNote:lstNoteNew)
        {
            if(objNote.LinkedEntityId != null)
            {
                //Add All Requreid Opportunity Ids into Set.
                switch on string.valueof(objNote.LinkedEntityId).substring(0,3)
                {
                    when '006'{setOpptyIDs.add(objNote.LinkedEntityId);} // Opportunity IDs
                    
                    when 'a9c'{setComplaintQualIDs.add(objNote.LinkedEntityId);} // Complaint Qualification IDs
                }
        	}
    	}
        
        if(setOpptyIDs.size() > 0)	updateParentOpportunity(setOpptyIDs);
        
        if(setComplaintQualIDs.size() > 0)	updateParentComplaintQualifications(setComplaintQualIDs);
    }
        
    // Capgemini, David Berman, 1-Dec 2021 added for SE-2621
    public void updateParentComplaintQualifications(Set<Id> setComplaintQualIDs)
    {
        try
        {
            for(List<HRCSVC_Complaint_Qualification__c> listCQ : [SELECT Id, HRCSVC21_Complaint_Attachment_Info__c 
                                                        		FROM HRCSVC_Complaint_Qualification__c
                                                      			 WHERE HRCSVC21_Complaint_Attachment_Info__c = null and id In :setComplaintQualIDs]) 
            {
                for(HRCSVC_Complaint_Qualification__c cq : listCQ)
                {
                    String sURL = Label.HRCSVC_Complaint_Qual_Attachments_URL;
                    sURL = sURL.replace('COMPLAINT_QUALIFICATION_ID', cq.Id);
                    cq.HRCSVC21_Complaint_Attachment_Info__c = sURL;
                }              
                update listCQ;   
            }
        }
        catch(Exception ex){system.debug('Exception occurred in updateParentComplaintQualifications: '+ex);}
    }
    
    
    //Method contains Code from existing Trigger.(Trigger:UpdateOppLMDfromNote which has been deactivated).
	 
    //public void updateParentOpportunity(List<ContentDocumentLink> lstNoteNew)
    public void updateParentOpportunity(Set<Id> setOpptyIDs) // Capgemini, David Berman, 1-Dec 2021 changed from list to set input
    {
        
        //Create List of Parent Opportunity to Update with Today's date.
        List<opportunity> lstOfOpportunityToUpdate = new List<opportunity>();
        
          try
          {
              // Capgemini, David Berman, 1-Dec 2021 - moved extraction logic to 'onAfterInsert'
               /* if(lstNoteNew!=null && lstNoteNew.size()>0){
            
                    for(ContentDocumentLink objNote:lstNoteNew){
                        if(objNote.LinkedEntityId!=null && string.valueof(objNote.LinkedEntityId).substring(0,3)=='006'){
                            //Add All Requreid Opportunity Ids into Set.
                            opportunityIds.add(objNote.LinkedEntityId);
                        }
                    }*/
                    
              
                //Loop through all Parent Opportunity and Add into List called 'lstOfOpportunityToUpdate';
                for(List<Opportunity> listObjOpportunity  : [select id,Note_Last_Update__c,IsClosed from Opportunity      
                                                           where id in :setOpptyIDs AND IsClosed = false])
                {
                    for(Opportunity objOpportunity : listObjOpportunity)
                        objOpportunity.Note_Last_Update__c = Date.Today();
                    
                    update listObjOpportunity;                    
                }
          }
          catch(Exception e){              system.debug('Exception occurred in updateParentOpportunity: '+e);        }
    }
}