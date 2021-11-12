trigger createMultipleSRs on BMCServiceDesk__Incident__c (after insert, after update) {

List<BMCServiceDesk__Incident__c> newIncidents = Trigger.New;
List<BMCServiceDesk__Incident__c> incidentsToBeProcessed = new List<BMCServiceDesk__Incident__c>();
List<BMCServiceDesk__SRM_RequestDetail__c> incidentRequestDetails = new List<BMCServiceDesk__SRM_RequestDetail__c>();
Set<Id> requestDetailIds = new Set<Id>();
List<BMCServiceDesk__SRM_RequestDetailInputs__c> requestdetailinputs = new List<BMCServiceDesk__SRM_RequestDetailInputs__c>();
List<BMCServiceDesk__SRM_RequestDetailInputs__c> incidentrequestdetailinputs = new List<BMCServiceDesk__SRM_RequestDetailInputs__c>();
List<BMCServiceDesk__SRM_RequestDetailInputs__c> eachincidentrequestdetailinputs = new List<BMCServiceDesk__SRM_RequestDetailInputs__c>();
Map<String,List<BMCServiceDesk__SRM_RequestDetailInputs__c>> detailInputMap = new Map<String,List<BMCServiceDesk__SRM_RequestDetailInputs__c>>();
List<BMCServiceDesk__Incident__c> tobecreatedIncidents = new List<BMCServiceDesk__Incident__c>();
List<BMCServiceDesk__Incident__c> parentIncidentstoBeUpdated = new List<BMCServiceDesk__Incident__c>();
List<BMCServiceDesk__Incident__c> childIncidentstoBeUpdated = new List<BMCServiceDesk__Incident__c>();
Set<Id> requestDefinitionIds = new Set<Id>();
List<BMCServiceDesk__SRM_FulfillmentInputs__c> incFulfillmentInputs = new List<BMCServiceDesk__SRM_FulfillmentInputs__c>();
List<Multiple_requests_info__c> requestinfo = new List<Multiple_requests_info__c>();
List<Multiple_requests_info__c> tempreqinfo;
Map<Id,List<Multiple_requests_info__c>> requestinfomap = new Map<Id,List<Multiple_requests_info__c>>();
Set<Id> RequestdetailId = new Set<Id>();
if(Trigger.isUpdate){
  for(BMCServiceDesk__Incident__c each: Trigger.old) {
            if(each.Is_Child__c != true &&  each.BMCServiceDesk__FKRequestDetail__c == null && Trigger.newMap.get(each.Id).BMCServiceDesk__FKRequestDetail__c != null ){
                incidentsToBeProcessed.add(Trigger.newMap.get(each.Id));
                RequestdetailId.add(each.BMCServiceDesk__FKRequestDefinition__c);
            }
       }
}  
  

if(Trigger.isInsert){
//Getting service requests which are master records
    for(BMCServiceDesk__Incident__c each: newIncidents) {
        if(each.Is_Child__c != true && each.BMCServiceDesk__FKRequestDefinition__c != null){
            System.debug('####'+each);
            incidentsToBeProcessed.add(each);
            System.debug('#####'+incidentsToBeProcessed);
            RequestdetailId.add(each.BMCServiceDesk__FKRequestDefinition__c);
            System.debug('####'+RequestdetailId);
            
        }
    }
}
System.debug('incidentsToBeProcessed'+incidentsToBeProcessed);

if(incidentsToBeProcessed != null && incidentsToBeProcessed.size() > 0){

    //Getting RequestDetail Ids from list of Incidents
    for(BMCServiceDesk__Incident__c each: incidentsToBeProcessed ) {
        requestDetailIds.add(each.BMCServiceDesk__FKRequestDetail__c);
        requestDefinitionIds.add(each.BMCServiceDesk__FKRequestDefinition__c);
    }
    System.debug('requestDetailIds'+requestDetailIds);
    System.debug('requestDefinitionIds'+requestDefinitionIds);
    incFulfillmentInputs = [Select Id,BMCServiceDesk__Prompt__c,BMCServiceDesk__InputValues__c,BMCServiceDesk__ResponseType__c ,BMCServiceDesk__FKRequestDefinition__c from BMCServiceDesk__SRM_FulfillmentInputs__c 
                                where BMCServiceDesk__FKRequestDefinition__c =:requestDefinitionIds];
    if(incFulfillmentInputs != null && incFulfillmentInputs.size() > 0){
        requestinfo = [Select Id,Fulfillment_Input__c,Template__c,Request_Type__c,Request_Types__c,Request_Types__r.Template__c, OwnerId from Multiple_requests_info__c where Fulfillment_Input__c =:incFulfillmentInputs ];
    }
    if(requestinfo !=null && requestinfo.size()>0) {
        
          
            for(Multiple_requests_info__c eachmap:requestinfo ){
               
                tempreqinfo = requestinfomap.get(eachmap.Fulfillment_Input__c);
                if(tempreqinfo == null)
                 tempreqinfo = new List<Multiple_requests_info__c >();
                tempreqinfo.add(eachmap);
                requestinfomap.put(eachmap.Fulfillment_Input__c, tempreqinfo );
                System.debug('fulfillment input'+eachmap.Fulfillment_Input__c+'multiple req info'+tempreqinfo);
            }
            System.debug('requestinfomap'+requestinfomap);
       
    }
    
    //Getting lists of RequestDetail records and RequestDetailInput records
    if(requestDetailIds != null && requestDetailIds.size() > 0) {
        incidentRequestDetails = [Select Id,BMCServiceDesk__FKIncident__c,BMCServiceDesk__FKRequestDefinition__c from BMCServiceDesk__SRM_RequestDetail__c where Id=:requestDetailIds];
        requestdetailinputs = [Select Id,BMCServiceDesk__FKFulfillmentInputs__c,BMCServiceDesk__FKFulfillmentInputs__r.BMCServiceDesk__ResponseType__c ,BMCServiceDesk__Input__c,BMCServiceDesk__FKRequestDetail__c,BMCServiceDesk__Response__c,BMCServiceDesk__StoredValue__c 
                                    from BMCServiceDesk__SRM_RequestDetailInputs__c where BMCServiceDesk__FKRequestDetail__c =:requestDetailIds];
    }
    System.debug('incidentRequestDetails'+incidentRequestDetails );
    System.debug('requestdetailinputs '+requestdetailinputs );
        System.debug('requestdetailinputs '+requestdetailinputs.size() );

    
   
    //Creating map of request detail id and the corresponding requestdetail inputs
    if(requestdetailinputs != null && requestdetailinputs.size() > 0){
        for(BMCServiceDesk__Incident__c eachincident :incidentsToBeProcessed ){
            eachincidentrequestdetailinputs = new List<BMCServiceDesk__SRM_RequestDetailInputs__c>();
            for(BMCServiceDesk__SRM_RequestDetailInputs__c eachrequestdetailinput :requestdetailinputs ){
                
                if(eachrequestdetailinput.BMCServiceDesk__FKRequestDetail__c == eachincident.BMCServiceDesk__FKRequestDetail__c){
                   //System.debug('inicdent that got matched::'+eachincident.Id);
                   eachincidentrequestdetailinputs.add(eachrequestdetailinput);
                  // System.debu
                   
                }
                 
                 
             }
             System.debug('eachincidentrequestdetailinputs'+eachincidentrequestdetailinputs);
             System.debug('eachincidentrequestdetailinputs'+eachincidentrequestdetailinputs.size());

             detailInputMap.put(String.valueOf(eachincident.BMCServiceDesk__FKRequestDetail__c),eachincidentrequestdetailinputs );
             System.debug('detailInputMap'+detailInputMap);
             incidentrequestdetailinputs.addAll(eachincidentrequestdetailinputs) ;
             //Integer incidentCount = 0;
             //Integer RDInputCount = 0;
             System.debug('No.of fullfillment inputs for this SR'+incidentrequestdetailinputs);
             System.debug('No.of fullfillment inputs for this SR'+incidentrequestdetailinputs.size());

             String flag = '';
             for(BMCServiceDesk__SRM_RequestDetailInputs__c each :incidentrequestdetailinputs){
                 if(each.BMCServiceDesk__FKFulfillmentInputs__r.BMCServiceDesk__ResponseType__c == 'Picklist'){
                     if(each.BMCServiceDesk__Response__c == 'International' || each.BMCServiceDesk__Response__c == 'North America' ||each.BMCServiceDesk__Response__c =='Internationale'|| each.BMCServiceDesk__Response__c =='Nordamerika' ){
                         if(each.BMCServiceDesk__Response__c =='Internationale' || each.BMCServiceDesk__Response__c == 'International' ){
                             flag='International';
                         }
                         if(each.BMCServiceDesk__Response__c =='Nordamerika' || each.BMCServiceDesk__Response__c == 'North America'){
                             flag='North America';
                         }
                         //flag = each.BMCServiceDesk__Response__c;
                         break;
                     }                     
                 }
                 System.debug('flag'+flag);
             }
             List<Multiple_requests_info__c>  increqinfolist1 = new List<Multiple_requests_info__c>();

             if(flag != null){
                 increqinfolist1 = [Select Id,Fulfillment_Input__c,Request_Definition__c,Request_Type__c,Template__c,OwnerId from Multiple_requests_info__c where Request_Type__c =:flag AND Request_Definition__c =:RequestdetailId];
             }
             System.debug('increqinfolist1'+increqinfolist1 );
             if(incidentrequestdetailinputs != null && incidentrequestdetailinputs.size() > 0)
             for(BMCServiceDesk__SRM_RequestDetailInputs__c each :incidentrequestdetailinputs){
                
                 System.debug('each.BMCServiceDesk__FKFulfillmentInputs__r.BMCServiceDesk__ResponseType__c:'+each.BMCServiceDesk__FKFulfillmentInputs__r.BMCServiceDesk__ResponseType__c);
                 System.debug('each.BMCServiceDesk__Response__c:'+each.BMCServiceDesk__Response__c);
                                 
                 System.debug('flag'+flag);
                                 if(each.BMCServiceDesk__Response__c != null){

                    if((((each.BMCServiceDesk__FKFulfillmentInputs__r.BMCServiceDesk__ResponseType__c == 'Picklist' && 
                 (!each.BMCServiceDesk__Response__c.equalsIgnoreCase('no') && !each.BMCServiceDesk__Response__c.equalsIgnoreCase('Nein')) ||
                 
                    (each.BMCServiceDesk__Response__c.equalsIgnoreCase('International')||each.BMCServiceDesk__Response__c.equalsIgnoreCase('Internationale')||
                 each.BMCServiceDesk__Response__c.equalsIgnoreCase('North America') || each.BMCServiceDesk__Response__c.equalsIgnoreCase('Nordamerika')))) ||
                 (each.BMCServiceDesk__FKFulfillmentInputs__r.BMCServiceDesk__ResponseType__c == 'Check box' &&
                 each.BMCServiceDesk__Response__c != null && !each.BMCServiceDesk__Response__c.equalsIgnoreCase('false')))||
                 ((each.BMCServiceDesk__FKFulfillmentInputs__r.BMCServiceDesk__ResponseType__c != 'Picklist' &&
                 each.BMCServiceDesk__FKFulfillmentInputs__r.BMCServiceDesk__ResponseType__c != 'Check box'))){
                   System.debug('Response with true/yes'+each.BMCServiceDesk__Response__c +'Fullfillmetn Id'+each.id);
                     
                     if(each.BMCServiceDesk__Response__c.equalsIgnoreCase('International')||each.BMCServiceDesk__Response__c.equalsIgnoreCase('Internationale')|| each.BMCServiceDesk__Response__c.equalsIgnoreCase('Nordamerika')||each.BMCServiceDesk__Response__c.equalsIgnoreCase('North America')){
                         BMCServiceDesk__Incident__c newIncident = new BMCServiceDesk__Incident__c(Fulfillment_Input__c = each.BMCServiceDesk__FKFulfillmentInputs__c,
                                                                         BMCServiceDesk__FKClient__c = eachincident.BMCServiceDesk__FKClient__c,
                                                                         BMCServiceDesk__FKRequestDefinition__c = eachincident.BMCServiceDesk__FKRequestDefinition__c,Is_Child__c = true, 
                                                                         Request_detail_text__c = String.valueOf(eachincident.BMCServiceDesk__FKRequestDetail__c),
                                                                         BMCServiceDesk__FKIncident__c = eachincident.Id);
                                                                         
                         if(increqinfolist1 !=null && increqinfolist1.size() > 0){
                         if(increqinfolist1[0].OwnerId != null)
                             newIncident.OwnerId = increqinfolist1[0].OwnerId;
                             
                         if(increqinfolist1[0].Template__c != null)
                             newIncident.BMCServiceDesk__FKTemplate__c = increqinfolist1[0].Template__c;
                    
                         System.debug('newincident'+newincident);
                         tobecreatedIncidents.add(newIncident);
                         }
                     }
                     else{
                     List<Multiple_requests_info__c>  increqinfolist = new List<Multiple_requests_info__c>();
                     increqinfolist = requestinfomap.get(each.BMCServiceDesk__FKFulfillmentInputs__c );
                     if(increqinfolist != null && increqinfolist.size()>0){
                         BMCServiceDesk__Incident__c newIncident = new BMCServiceDesk__Incident__c(Fulfillment_Input__c = each.BMCServiceDesk__FKFulfillmentInputs__c,
                                                                         BMCServiceDesk__FKClient__c = eachincident.BMCServiceDesk__FKClient__c,
                                                                         BMCServiceDesk__FKRequestDefinition__c = eachincident.BMCServiceDesk__FKRequestDefinition__c,Is_Child__c = true, 
                                                                         Request_detail_text__c = String.valueOf(eachincident.BMCServiceDesk__FKRequestDetail__c),
                                                                         BMCServiceDesk__FKIncident__c = eachincident.Id);
                                                                         
                         
                          
                             if(increqinfolist1!=null && increqinfolist1.size() > 0){
                         if(increqinfolist[0].OwnerId != null)
                             newIncident.OwnerId = increqinfolist[0].OwnerId;
                             
                         if(increqinfolist[0].Template__c != null)
                             newIncident.BMCServiceDesk__FKTemplate__c = increqinfolist[0].Template__c;
                    
                     
                         tobecreatedIncidents.add(newIncident);
                         }
                             
                             
                             
                         
                         }
                        // RDInputCount = incidentrequestdetailinputs.size();
                     } 
                        
                    }
                    }
             }
             }
             System.debug('tobecreatedincidents###'+tobecreatedincidents);
             System.debug('tobecreatedincidents###'+tobecreatedincidents.size());
             Set<Id> ownId = new Set<Id>();
             
             Set<Id> staffId = new Set<Id>();
             Set<Id> queueId = new Set<Id>();

             List<User> userId = new List<User>();
             List<BMCServiceDesk__Incident__c> queueIncidents = new List<BMCServiceDesk__Incident__c>();
             List<BMCServiceDesk__Incident__c> staffIncidents = new List<BMCServiceDesk__Incident__c>();
                         
             if(tobecreatedincidents != null && tobecreatedincidents.size() > 0)   {   
                 for(BMCServiceDesk__Incident__c incid:tobecreatedincidents){
                     ownId.add(incid.OwnerId);
                 } 
                 System.debug('OwnerIds'+ownId);
                 userId = [Select Id from User where Id IN :ownId ];
                 System.debug('UserId'+userId );
                 Set<Id> userIdSet = new Set<Id>();
                 if(userId!=null && userId.size()>0) {
                     for(User eachUser : userId)
                         userIdSet.add(eachuser.Id);
                 }
                 for(Id owner : ownId){
                     if(userIdSet.contains(owner)) {
                         System.debug('Entered Else for StaffId@@@$$$'+owner);
                         staffId.add(owner);
                     }
                     else {
                         System.debug('Entered Else for QueueId&&&***'+owner);
                         queueId.add(owner);
                     }
                 }
                 System.debug('All the Staff Ids staffId^^'+staffId);
                 System.debug('All Queue Ids queueId$$$'+queueId);
                 
                 for(BMCServiceDesk__Incident__c inci: tobecreatedincidents){
                    if(staffId.contains(inci.OwnerId))
                        staffIncidents.add(inci);
                    else if(queueId.contains(inci.OwnerId))
                        queueIncidents.add(inci);
                     }   
             System.debug('staffIncidents Prior to insert'+staffIncidents );
             System.debug('staffIncidents Prior to insert'+staffIncidents.size() );

             System.debug('queueIncidents prior to insert queue'+queueIncidents); 
             System.debug('queueIncidents prior to insert queue'+queueIncidents.size());                  
                 
             //insert tobecreatedincidents;
             
            }  
          /*  if(staffIncidents.size() > queueIncidents.size())
            {    
                UpdateMultipleSRs um = new UpdateMultipleSRs(staffIncidents,queueIncidents,detailInputMap,0,queueIncidents.size(),0);
                 Database.executeBatch(um);
            }
            else
            {
                UpdateMultipleSRs um = new UpdateMultipleSRs(staffIncidents,queueIncidents,detailInputMap,0,staffIncidents.size(),0);
                 Database.executeBatch(um);

                
            }*/
            if((staffIncidents != null && staffIncidents.size() > 0)  || (queueIncidents != null && queueIncidents.size() > 0 )){
            UpdateMultipleSRs um = new UpdateMultipleSRs(staffIncidents,queueIncidents,detailInputMap,0,0,0);
                 Database.executeBatch(um);
             
            }     
        
        
        
        
    }
        
     
    
    
}




}