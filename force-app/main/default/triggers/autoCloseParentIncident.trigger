trigger autoCloseParentIncident on BMCServiceDesk__Incident__c (after update) {
    List<BMCServiceDesk__Incident__c> newchildincidents = new List<BMCServiceDesk__Incident__c>();
    List<BMCServiceDesk__Incident__c> parentincidents = new List<BMCServiceDesk__Incident__c>();
    List<BMCServiceDesk__Incident__c> childincidentslist = new List<BMCServiceDesk__Incident__c>();
    List<BMCServiceDesk__Incident__c> tempincidentslist;

    Map<BMCServiceDesk__Incident__c, List<BMCServiceDesk__Incident__c>> parentincidentmap = new Map<BMCServiceDesk__Incident__c, List<BMCServiceDesk__Incident__c>>();
    Set<Id> parentIncidentIds = new Set<Id>(); 
    
    System.debug('Old Trigger Map ->' + Trigger.oldMap);
         System.debug('New Trigger Map ->' + Trigger.newMap);
         
    List<BMCServiceDesk__Incident__c> newIncidentForId=Trigger.New;
    
    if((Trigger.oldMap.get(newIncidentForId[0].id).BMCServiceDesk__AllTaskCloseController__c) == (Trigger.newMap.get(newIncidentForId[0].id).BMCServiceDesk__AllTaskCloseController__c)){
    for(BMCServiceDesk__Incident__c eachincident :Trigger.New){
        if(eachincident.Is_Child__c == true){
            newchildincidents.add(eachincident);
            if(eachincident.BMCServiceDesk__FKIncident__c != null)
                parentincidentIds.add(eachincident.BMCServiceDesk__FKIncident__c);
        }
    }
    System.debug('autocloseincidents'+Trigger.New);
    System.debug('parentincidentIds size'+parentincidentIds.size());
    if(newchildincidents != null && newchildincidents.size() > 0){
        if(parentincidentIds != null && parentincidentIds.size() > 0){
            System.debug('newchildincidents '+newchildincidents );
            System.debug('parentincidentIds'+parentincidentIds );
            parentincidents = [Select Id, BMCServiceDesk__FKStatus__c from BMCServiceDesk__Incident__c where Id =:parentincidentIds AND BMCServiceDesk__state__c = true];
            System.debug('parentincidents '+parentincidents );
            if(parentIncidentIds != null && parentIncidentIds.size() > 0){
                childincidentslist = [Select Id,BMCServiceDesk__FKStatus__c ,BMCServiceDesk__state__c, BMCServiceDesk__FKIncident__c
                                        from BMCServiceDesk__Incident__c where BMCServiceDesk__FKIncident__c =:parentIncidentIds ];
            }
            if(childincidentslist != null && childincidentslist .size()>0){
                System.debug('childincidentslist '+childincidentslist );
                for(BMCServiceDesk__Incident__c  eachparent :parentincidents ){ 
                    tempincidentslist = new List<BMCServiceDesk__Incident__c >();
                    for(BMCServiceDesk__Incident__c  eachchild :childincidentslist){
                        if(eachchild.BMCServiceDesk__FKIncident__c == eachparent.Id){
                            tempincidentslist.add(eachchild );
                        }
        
                    }
                    parentincidentmap.put(eachparent , tempincidentslist);
        
                }
                
            }
            System.debug('parentincidentmap'+parentincidentmap);
            Integer numOfChildIncidents = 0;
            Integer numOfClosedChildIncidents = 0;
            BMCServiceDesk__Status__c status = [Select Id,Name from BMCServiceDesk__Status__c where BMCServiceDesk__Stage__c = 'CLOSED' limit 1];
            for(BMCServiceDesk__Incident__c eachparent :parentincidents ){
                tempincidentslist = parentincidentmap.get(eachparent);
                numOfChildIncidents = tempincidentslist.size();
                for(BMCServiceDesk__Incident__c eachchild :tempincidentslist ){
                    if(eachchild.BMCServiceDesk__state__c == false){
                        numOfClosedChildIncidents += 1;
                    }
                }
                System.debug('numOfChildIncidents '+numOfChildIncidents );
                System.debug('numOfClosedChildIncidents' +numOfClosedChildIncidents );
                if(numOfClosedChildIncidents  == numOfChildIncidents ){
                    eachparent.BMCServiceDesk__FKStatus__c = status.Id;
                    eachparent.BMCServiceDesk__closeDateTime__c = System.Now();  
                }
                numOfClosedChildIncidents  = 0;
            
            }
            System.debug('tobeupdatedparentincidents'+parentincidents);
            update parentincidents;
        }
    }
    }
}