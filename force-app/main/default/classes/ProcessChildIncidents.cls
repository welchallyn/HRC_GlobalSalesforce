global class ProcessChildIncidents implements Schedulable{

    List<BMCServiceDesk__Incident__c> allNewParentIncidents = new List<BMCServiceDesk__Incident__c> ();
    List<BMCServiceDesk__Incident__c> allNewChildIncidents= new List<BMCServiceDesk__Incident__c> ();
    List<BMCServiceDesk__SRM_RequestDetail__c> requestdetails = new List<BMCServiceDesk__SRM_RequestDetail__c> ();
    Set<String> parentrequestdetailIds = new Set<String> ();

    Set<Id> incidentIds = new Set<Id>();
    public ProcessChildIncidents () {
        System.debug('in process child incidents constructor');
        allNewChildIncidents  = [select Id, BMCServiceDesk__FKRequestDetail__c, BMCServiceDesk__FKRequestDefinition__c,
                                Request_detail_text__c,Is_Child__c,BMCServiceDesk__state__c from BMCServiceDesk__Incident__c 
                                where Is_Child__c = True AND BMCServiceDesk__FKRequestDetail__c = null AND BMCServiceDesk__state__c = true limit 5000];
        System.debug(' allNewChildIncidents before update'+allNewChildIncidents  ); 
        for(BMCServiceDesk__Incident__c eachIncident: allNewChildIncidents ){
            parentrequestdetailIds.add(eachIncident.Request_detail_text__c);
            
        } 
        System.debug('parentrequestdetailIds'+parentrequestdetailIds);
        //Integer l = Limits.getLimitQueryRows();
        allNewParentIncidents = [select Id, BMCServiceDesk__FKRequestDetail__c, BMCServiceDesk__FKRequestDefinition__c,
                                Request_detail_text__c,Is_Child__c from BMCServiceDesk__Incident__c 
                                where Is_Child__c = False AND BMCServiceDesk__FKRequestDetail__c =: parentrequestdetailIds LIMIT 5000];                 
       // process();
       System.debug('allNewParentIncidents'+allNewParentIncidents );
        }
        
    public void process() {
        System.debug('in process');
        if(allNewChildIncidents != null && allNewChildIncidents.size() > 0){
            for(BMCServiceDesk__Incident__c incident :allNewChildIncidents){
                incidentIds.add(incident.Id);
            }
            requestdetails = [Select Id, BMCServiceDesk__FKIncident__c,BMCServiceDesk__FKRequestDefinition__c from BMCServiceDesk__SRM_RequestDetail__c where BMCServiceDesk__FKIncident__c = :incidentIds];
            System.debug('requestdetails  '+requestdetails  );
            if(requestdetails  != null && requestdetails.size() > 0){
                for(BMCServiceDesk__Incident__c eachincident: allNewChildIncidents ){
                    for(BMCServiceDesk__SRM_RequestDetail__c eachrequestdetail: requestdetails){
                        if(eachrequestdetail.BMCServiceDesk__FKIncident__c == eachincident.Id){
                            eachincident.BMCServiceDesk__FKRequestDetail__c = eachrequestdetail.Id;
                            if(eachincident.BMCServiceDesk__FKRequestDefinition__c == null)
                            eachincident.BMCServiceDesk__FKRequestDefinition__c = eachrequestdetail.BMCServiceDesk__FKRequestDefinition__c;
                        }
                    } 
                }
                System.debug('allNewChildIncidents'+allNewChildIncidents);
                
            }
            
        
            if(allNewParentIncidents != null && allNewParentIncidents.size() > 0){
                System.debug('allNewParentIncidents'+allNewParentIncidents );
                for(BMCServiceDesk__Incident__c eachparent :allNewParentIncidents){
                    for(BMCServiceDesk__Incident__c eachincident: allNewChildIncidents ){
                        if(String.valueOf(eachparent.BMCServiceDesk__FKRequestDetail__c)== eachincident.Request_detail_text__c){
                            eachincident.BMCServiceDesk__FKIncident__c = eachparent.Id;
                        }
                    }
                }
            }
            update allNewChildIncidents;
        }
    }
    global void execute(SchedulableContext sc) {
        try {
            system.debug('in schedulable execute'); 
            ProcessChildIncidents p = new ProcessChildIncidents();
            p.process();
                        system.debug('after process'); 

            
            
        }
        catch(Exception ex) {
            System.debug('Exception occured:' + ex);
            System.debug('Exception Message:' + ex.getMessage());            
        }
        try {
            ReplaceApprovers ra = new ReplaceApprovers();
            system.debug('after replaceapprovers');
            
            if(!Test.isRunningTest())
                Database.executeBatch(ra);
        }
        catch(Exception ex){
            System.debug('Exception occured:' + ex);
            System.debug('Exception Message:' + ex.getMessage());  
        
        }
    }
}