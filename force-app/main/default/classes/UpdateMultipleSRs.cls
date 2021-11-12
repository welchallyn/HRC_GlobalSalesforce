global class UpdateMultipleSRs implements Database.Batchable<sObject>, Database.Stateful {

public List<BMCServiceDesk__Incident__c> currentBatch = new List<BMCServiceDesk__Incident__c>();
public List<BMCServiceDesk__Incident__c> staffcurrentBatch = new List<BMCServiceDesk__Incident__c>();
public List<BMCServiceDesk__Incident__c> queuecurrentBatch = new List<BMCServiceDesk__Incident__c>();
Set<Id> parentIncidentIds = new Set<Id>();
List<BMCServiceDesk__SRM_RequestDetail__c> increqdetails = new List<BMCServiceDesk__SRM_RequestDetail__c>();
List<BMCServiceDesk__SRM_RequestDetailInputs__c> increqdetailinputs = new List<BMCServiceDesk__SRM_RequestDetailInputs__c>();
List<BMCServiceDesk__SRM_RequestDetailInputs__c> batchincreqdetailinputs = new List<BMCServiceDesk__SRM_RequestDetailInputs__c>();
List<BMCServiceDesk__Incident__c> staffIncToBeinserted {get;set;}
List<BMCServiceDesk__Incident__c> queueIncToBeinserted {get;set;}
Map<String,List<BMCServiceDesk__SRM_RequestDetailInputs__c>> incdetailInputMap {get;set;}
public Static Boolean IsInsert = True;
public Integer minValue {get;set;}
public Integer maxValue {get;set;}
public Integer endIndex {get;set;}
public Integer incidentCount {get;set;}
public Integer recordsPerTransaction = 4;


global UpdateMultipleSRs(List<BMCServiceDesk__Incident__c> staffIncToBeinserted,List<BMCServiceDesk__Incident__c> queueIncToBeinserted,Map<String,List<BMCServiceDesk__SRM_RequestDetailInputs__c>> incdetailInputMap,Integer minValue, Integer maxValue,Integer endIndex) {
        System.debug('In constructor');
        this.staffIncToBeinserted = staffIncToBeinserted;
        this.queueIncToBeinserted = queueIncToBeinserted;
        this.incdetailInputMap = incdetailInputMap;
        this.minValue = minValue;
        this.maxValue = maxValue; 
        this.endIndex = endIndex;        
}

global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('in start');
        String userId = UserInfo.getUserId();
        System.debug('User ID'+userId);
        String query = 'select Id, FirstName, LastName, Email, CreatedDate from User where Id= :userId '  ;
        return Database.getQueryLocator(query);
}

global void execute(Database.BatchableContext BC,  List<sobject> scope) {

    System.debug('in execute');
    currentBatch = new List<BMCServiceDesk__Incident__c>();
    staffcurrentBatch = new List<BMCServiceDesk__Incident__c>();
    queuecurrentBatch = new List<BMCServiceDesk__Incident__c>();
    if(IsInsert == True){
/*        for(Integer i=minValue; i< maxValue ; i++) {*/
            System.debug('staffIncToBeinserted size'+staffIncToBeinserted.size());
            System.debug('queueIncToBeinserted size'+queueIncToBeinserted.size());

        
        if(minValue < staffIncToBeinserted.size()) {
            for(Integer i=minValue; i< maxValue ; i++)        
                staffcurrentBatch.add(staffIncToBeinserted[i]); 
        }
        
        if(minValue < queueIncToBeinserted.size()) {
            for(Integer i=minValue; i< maxValue ; i++)        
                queuecurrentBatch.add(queueIncToBeinserted[i]);  
        }
        System.debug('minValue##:'+minValue);
        System.debug('maxValue##:'+maxValue);
        System.debug('staffcurrentBatch:'+staffcurrentBatch);
        System.debug('queuecurrentBatch:'+queuecurrentBatch);
//        }
        if(staffcurrentBatch!=null && staffcurrentBatch.size() > 0){
            System.debug('staffcurrentBatch'+staffcurrentBatch.size());
            try{
                    insert staffcurrentBatch;
                    System.debug('staffcurrentBatch'+staffcurrentBatch.size()+' '+staffcurrentBatch);
               }
               catch(exception e){
                   System.debug('Error in staff current batch'+e);
               }
            currentBatch.addAll(staffcurrentBatch);
            System.debug('staffincidents'+staffcurrentBatch);
        
        }
        if(queuecurrentBatch!=null && queuecurrentBatch.size() > 0){     
            System.debug('queuecurrentBatch'+queuecurrentBatch.size());
 
            try{
                    insert queuecurrentBatch;
                    System.debug('queuecurrentBatch'+queuecurrentBatch.size()+' '+queuecurrentBatch);

               }
               catch(exception e){
                   System.debug('Error in queue current batch'+e);
               }
            currentBatch.addAll(queuecurrentBatch);
            System.debug('queueincidents'+queuecurrentBatch);
        }
        
    }
}

global void finish( Database.BatchableContext BC ) {
    System.debug('in finish');
    System.debug('minvalue initial'+minValue);
    minValue = maxValue;
    incidentCount = staffIncToBeinserted.size()+ queueIncToBeinserted.size();
    if(currentBatch != null && currentBatch.size() > 0){
        for(BMCServiceDesk__Incident__c eachinc : currentBatch){
            BMCServiceDesk__SRM_RequestDetail__c newRequestDetail = new BMCServiceDesk__SRM_RequestDetail__c(BMCServiceDesk__FKIncident__c = eachinc.Id,
                                                                    BMCServiceDesk__FKClient__c = eachinc.BMCServiceDesk__FKClient__c,
                                                                    BMCServiceDesk__FKRequestDefinition__c = eachinc.BMCServiceDesk__FKRequestDefinition__c,
                                                                    BMCServiceDesk__ServiceRequest__c = eachinc.BMCServiceDesk__FKRequestDefinition__r.Name,
                                                                    ParentRequestDetail__c = eachinc.Request_detail_text__c);
            increqdetails.add(newRequestDetail);
            //parentIncidentIds.add(eachinc.BMCServiceDesk__FKIncident__c );                                                    
        } 
        insert increqdetails;
        System.debug('request details'+increqdetails);
        if(increqdetails != null && increqdetails.size() > 0){
            for(BMCServiceDesk__SRM_RequestDetail__c eachdetail :increqdetails){
                batchincreqdetailinputs = new List<BMCServiceDesk__SRM_RequestDetailInputs__c>();
                System.debug('parent detail id'+eachdetail.ParentRequestDetail__c);
                batchincreqdetailinputs = incdetailInputMap.get(eachdetail.ParentRequestDetail__c);
                System.debug('batchincreqdetailinputs'+batchincreqdetailinputs.size());
                if(batchincreqdetailinputs != null && batchincreqdetailinputs.size() > 0){
                    for(BMCServiceDesk__SRM_RequestDetailInputs__c eachdetailinput :batchincreqdetailinputs ){
                        if(String.valueOf(eachdetailinput.BMCServiceDesk__FKRequestDetail__c) == eachdetail.ParentRequestDetail__c){
                            BMCServiceDesk__SRM_RequestDetailInputs__c Requestdetailinput = new BMCServiceDesk__SRM_RequestDetailInputs__c(
                                                                 BMCServiceDesk__FKFulfillmentInputs__c = eachdetailinput.BMCServiceDesk__FKFulfillmentInputs__c,
                                                                 BMCServiceDesk__Input__c = eachdetailinput.BMCServiceDesk__Input__c,
                                                                 BMCServiceDesk__FKRequestDetail__c  = eachdetail.Id,
                                                                 BMCServiceDesk__Response__c = eachdetailinput.BMCServiceDesk__Response__c,
                                                                 BMCServiceDesk__StoredValue__c = eachdetailinput.BMCServiceDesk__StoredValue__c);
                            increqdetailinputs.add(Requestdetailinput);
                        }
                        
                    }
                    //increqdetailinputs.addAll(batchincreqdetailinputs);
                    
                }
                
            }
        }
        System.debug('increqdetailinputs'+increqdetailinputs.size());
        if(increqdetailinputs != null && increqdetailinputs.size() > 0){
            insert increqdetailinputs;
        }
    }
    Integer minimumCount = 0;
    Integer maximumCount = 0;
    
    if(staffIncToBeinserted.size() > queueIncToBeinserted.size()) {
        maximumCount = staffIncToBeinserted.size();
        minimumCount = queueIncToBeinserted.size();
    }
    else if(staffIncToBeinserted.size() < queueIncToBeinserted.size()) {
        maximumCount = queueIncToBeinserted.size();
        minimumCount = staffIncToBeinserted.size();
    }
    else{
        
        maximumCount = queueIncToBeinserted.size();
        minimumCount = staffIncToBeinserted.size();
        
    }
    if(maxValue < minimumCount) {
        if((minValue + recordsPerTransaction) >= minimumCount) {
            maxValue = minimumCount;
        }
        else {
            maxValue = minValue + recordsPerTransaction;
        }
    }
    else {
        if((minValue + recordsPerTransaction) >= maximumCount) {
            maxValue = maximumCount;
        }
        else {
            maxValue = minValue + recordsPerTransaction;
        }
    }    
    
    System.debug('maxvalue initial'+maxValue);
    
    
      if(minValue != maxValue && maxValue <= incidentCount ) {
             UpdateMultipleSRs um = new UpdateMultipleSRs(staffIncToBeinserted ,queueIncToBeinserted ,incdetailInputMap,minValue,maxValue,0);
             Database.executeBatch(um);
      }
    
    
}
    

}