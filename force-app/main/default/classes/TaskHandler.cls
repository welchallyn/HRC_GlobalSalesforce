/*
 *  ClassName    : TaskHandler
 *  CreatedOn    : 18/Oct/2016
 *  ModifiedOn   : 22/Jan/2018
 *  CreatedBy    : Jenish Shingala
 *  ModifiedBy   : Jenish Shingala
 *  Description  : Used for Handling all events for Tasks (Task). 
 */
public with sharing class TaskHandler {
    
     /*
         * MethodName : onAfterInsert
         * Param      : lstAccountNew
         * Description: Triggers on after insert 
         */

    public void onAfterInsert(List <Task> lstTaskNew) {
        updateOppLMDfromTask(lstTaskNew);
        completeMilestoneofParentCase(lstTaskNew);
        
    } 
    
     /*
     * MethodName : onBeforeInsert
     * Param      : lstTaskNew
     * Description: Triggers on before insert 
     */
    public void onBeforeInsert(List < Task > lstTaskNew) {
            //Add Before Insert Logic.
    }
    
       /*
     * MethodName    : onBeforeUpdate
     * Param         : lstTaskNew.
     * Description   : 
     */

    public void onBeforeUpdate(List<Task> lstTaskNew) {
         //Add before Update Logic.
    }
    
    /*
     * MethodName : onAfterUpdate
     * Param      : 
     * Description: method executes after update.
     */
     
    public void onAfterUpdate(List <Task> lstTaskNew) {
        updateOppLMDfromTask(lstTaskNew);
        completeMilestoneofParentCase(lstTaskNew);
    }
    
     /*
     * MethodName : onBeforeDelete
     * Param      :  
     * Description: Triggers on before delete 
     */

    public void onBeforeDelete(map < Id, Task > mapIdToTaskOld) {
          //Add Before Delete logic here.
    }

    /*
     * MethodName : onAfterDelete
     * Param      :  
     * Description: Triggers on after delete 
     */
    public void onAfterDelete(map < Id, Task > mapIdToTaskOld) {
       //Add After Delete logic here.
    }
    
    /*
     * MethodName : completeMilestoneofParentCase
     * Param      : 
     * Description:  if task is of call type and status is completed than mark milestone completed of parent case .
     */
     
     public void completeMilestoneofParentCase(List<Task> lstTaskNew){
         Datetime completionDate = system.now();
         set<id> caseIds = new set<id>();
         List<id> caseIdToCloseMilestone  = new List<id>();
         for(Task objTask:lstTaskNew){
               if(objTask.whatid!=null && string.valueof(objTask.whatid).substring(0,3)=='500'){
                   if(objTask.Type=='Call' && objTask.IsClosed==true){
                       caseIds.add(objTask.whatid);
                   }
               }
         }
         if(caseIds!=null && caseIds.size()>0){
             List<case> caselist = [select id,ContactId,SlaStartDate,EntitlementId,SlaExitDate from case where id in :caseIds];
             for(Case objCase:caselist){
                   if ((objCase.EntitlementId != null)&&
                       (objCase.SlaStartDate <= completionDate)&&
                       (objCase.SlaStartDate != null)&&
                       (objCase.SlaExitDate == null))
                       caseIdToCloseMilestone.add(objCase.id);    
                       
             }
             if(caseIdToCloseMilestone.isEmpty() == false){
                    milestoneUtils.completeMilestone(caseIdToCloseMilestone, 'First Response', completionDate);
                }
         }
     }
    
    
    /*
     * MethodName : updateOppLMDfromTask
     * Param      : 
     * Description: Code from previous trigger(Trigger Name:updateOppLMDfromTask. This trigger has been deactivated by Jenish).
     */
    
    public void updateOppLMDfromTask(List<Task> lstTaskNew){
        //Create Set to Store Opportunity Ids.
        set<id> opportunityIds = new set<id>();
        
        //Create List of Parent Opportunity to Update with Today's date.
        List<opportunity> lstOfOpportunityToUpdate = new List<opportunity>();
        try{
            if(lstTaskNew!=null && lstTaskNew.size()>0){
            
            for(Task objTask:lstTaskNew){
                if(objTask.whatid!=null && string.valueof(objTask.whatid).substring(0,3)=='006'){
                    //Add All Requreid Opportunity Ids into Set.
                    opportunityIds.add(objTask.whatid);
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
            system.debug(e);
        }
        
    }
}