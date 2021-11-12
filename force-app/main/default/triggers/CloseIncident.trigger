trigger CloseIncident on BMCServiceDesk__Incident__c (before update)  {
    system.debug('*****called');
    List<BMCServiceDesk__Status__c> closedStatus = [SELECT Id, Name FROM BMCServiceDesk__Status__c WHERE Name = 'CLOSED' LIMIT 1];
    List<BMCServiceDesk__Incident__c> incidents = Trigger.new;
    
     List<BMCServiceDesk__Incident__c> newIncidentForId=Trigger.New;
    
    if((Trigger.oldMap.get(newIncidentForId[0].id).BMCServiceDesk__AllTaskCloseController__c) == (Trigger.newMap.get(newIncidentForId[0].id).BMCServiceDesk__AllTaskCloseController__c)){
    

        if(closedStatus != null && closedStatus.size()>0 ){
            for(BMCServiceDesk__Incident__c incident: incidents) {
              if(incident.IsResolved__c == true || incident.IsResolved__c == TRUE) 
                incident.BMCServiceDesk__FKStatus__c = closedStatus[0].Id; 
//                incident.BMCServiceDesk__closeDateTime__c = System.Now();       
            }  
        }
    }  

}