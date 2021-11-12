/*
    *  ClassName    : EmailMessageHandler
    *  CreatedOn    : 16/Oct/2017
    *  ModifiedOn   : 16/Oct/2017
    *  CreatedBy    : Erik Siewert
    *  ModifiedBy   : Erik siewert
    *  Description  : Used for Handling all events for EmailMessage. 
*/
public with sharing class EmailMessageHandler {
    /*
        * MethodName : onAfterInsert
        * Param      : (nothing)
        * Description: Triggers on after insert 
    */  
    public void onAfterInsert(List<EmailMessage> lstEmailMessageNew)
    {
        updateFirstResponse(lstEmailMessageNew);
      
    }

    public void updateFirstResponse(List<EmailMessage> lstEmailMessageNew) {
    
    // Cannot be a portal user
    if (UserInfo.getUserType() == 'Standard'){
        DateTime completionDate = System.now();
        Map<Id, String> emIds = new Map<Id, String>();
        //for each email message being created
        for (EmailMessage em : lstEmailMessageNew){
            //if it's an outgoing email
            if(em.Incoming == false)
                //add to emIds
                emIds.put(em.ParentId, em.ToAddress);
        }
        //if there's any records in emIds 
        if (emIds.isEmpty() == false){
            Set <Id> emCaseIds = new Set<Id>();
            //add all of the keys to emCaseIds Set
            emCaseIds = emIds.keySet();
            //Query Salesforce to get the details of the cases in the set
            List<Case> caseList = [Select c.Id, c.ContactId, c.Contact.Email,c.contact.name,isclosed,
                              c.OwnerId, c.Status,
                              c.EntitlementId,
                              c.SlaStartDate, c.SlaExitDate
                           From Case c where c.Id IN :emCaseIds];
                           system.debug('CASE-->'+caseList);
            //if there are any cases
            if (caseList.isEmpty()==false){
                List<Id> updateCases = new List<Id>();
                //for each email
                for (Case caseObj:caseList) {
                    // consider an outbound email to the contact on the case a valid first response
                    // if the Case has an Entitlement, the SLAStartDate is in the past, 
                    // the SLAExitDate hasn't been set yet -- add the Id of the case to a list of cases to be updated. 
                    if ((caseObj.EntitlementId != null)&&
                       (caseObj.SlaStartDate <= completionDate)&&
                       (caseObj.SlaStartDate != null)&&
                       (caseObj.SlaExitDate == null))
                        updateCases.add(caseObj.Id);
                
                }
                //if any qualify for updating, 
                //pass the cases to milestoneUtils for milestone updating. 
                if(updateCases.isEmpty() == false)
                {
                    //system.debug('now attempt to update first response milestone');
                    milestoneUtils.completeMilestone(updateCases, 'First Response', completionDate);
                }
                    
            }
        }
    }        
    }
}