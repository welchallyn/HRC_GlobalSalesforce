trigger PSP_Notes_NoteTrigger on Note(after insert, after update) {
   persp.PSPLogger Logger = new persp.PSPLogger('PSP_Notes_NoteTrigger', false);
   List<BMCServiceDesk__Incident__c> incToUpdate = new List<BMCServiceDesk__Incident__c>();
   for (Note obj : Trigger.new) {
      // Go to the parent of the note and if it is an incident, force update it, so that the trigger on the incident itself fires
      List<BMCServiceDesk__Incident__c> incList = [select Id from BMCServiceDesk__Incident__c where Id = :obj.ParentId];
      if(incList!=null && incList.size()>0){
        for(BMCServiceDesk__Incident__c inc:incList){
           incToUpdate.add(inc);
        }
      }
      try{
          update incToUpdate;
      }
      catch(Exception e){
          //Logger.logDebug('Exception caught: ' + e);
      }
   }
}