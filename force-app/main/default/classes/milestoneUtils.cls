/*
    *  ClassName    : milestoneUtils 
    *  CreatedOn    : 16/Oct/2017
    *  ModifiedOn   : 16/Oct/2017
    *  CreatedBy    : Erik Siewert
    *  ModifiedBy   : Erik Siewert
    *  Description  : used for marking milestones complete on Salesforce Cases (Service Cloud)
*/
public with sharing class milestoneUtils {
    
    public static void completeMilestone(List<Id> caseIds, String milestoneName, DateTime complDate) {
    //get the ids for those milestones for those cases passed as inbound arguments
    List<CaseMilestone> cmsToUpdate = [select Id, completionDate
                       from CaseMilestone cm
                       where caseId in :caseIds and cm.MilestoneType.Name=:milestoneName and completionDate = null limit 1];
    if (cmsToUpdate.isEmpty() == false){
    //for each of the milestones in the list
      for (CaseMilestone cm : cmsToUpdate){
      //set them equal to the date passed in. 
        cm.completionDate = complDate;
      }
      //DML update
      system.debug('UPDATE-->'+cmsToUpdate);
      update cmsToUpdate;
    } // end if
  }
  
 
}