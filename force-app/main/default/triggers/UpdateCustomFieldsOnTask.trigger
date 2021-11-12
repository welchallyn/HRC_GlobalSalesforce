trigger UpdateCustomFieldsOnTask on BMCServiceDesk__Task__c (before insert) {

    List<BMCServiceDesk__Task__c> newTasks = Trigger.New;
    Set<Id> IncidentIdSet = new Set<Id>();
    Set<Id> problemIdSet = new Set<Id>();
    Set<Id> changeIdSet = new Set<Id>();
    
    List<BMCServiceDesk__Incident__c> relatedIncidents;
    list<BMCServiceDesk__Problem__c> relatedProblems;
    List<BMCServiceDesk__Change_Request__c> relatedChangeRequests;
    
    Map<Id,BMCServiceDesk__Incident__c> incidentMap = new Map<Id,BMCServiceDesk__Incident__c>();
    Map<Id,BMCServiceDesk__Problem__c> problemMap = new Map<Id,BMCServiceDesk__Problem__c>();
    Map<Id,BMCServiceDesk__Change_Request__c> changeMap = new Map<Id,BMCServiceDesk__Change_Request__c>();
    system.debug('<<<<<<< >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>UpdateCustomFieldsOnTask');
    
    for(BMCServiceDesk__Task__c eachNewTask : newTasks) {
        if(eachNewTask.BMCServiceDesk__FKIncident__c != null) {
            IncidentIdSet.add(eachNewTask.BMCServiceDesk__FKIncident__c);    
        }
        else if(eachNewTask.BMCServiceDesk__FKProblem__c != null) {
            problemIdSet.add(eachNewTask.BMCServiceDesk__FKProblem__c);
        }
        else if(eachNewTask.BMCServiceDesk__FKChange__c != null) {
            changeIdSet.add(eachNewTask.BMCServiceDesk__FKChange__c);
        }
    }
    
    if(!IncidentIdSet.isEmpty()) {
        relatedIncidents = [select Id, Operational_Catalog_Tier_1__c, Operational_Catalog_Tier_2__c, Product_Catalog_Tier_1__c, Product_Catalog_Tier_2__c from BMCServiceDesk__Incident__c where Id=:IncidentIdSet];
        for(BMCServiceDesk__Incident__c eachIncident : relatedIncidents) {
            incidentMap.put(eachIncident.Id, eachIncident);
        }
    }
    if(!problemIdSet.isEmpty()) {
        relatedProblems = [select Id, Operational_Catalog_Tier_1__c, Operational_Catalog_Tier_2__c, Product_Catalog_Tier_1__c, Product_Catalog_Tier_2__c from BMCServiceDesk__Problem__c where Id=:problemIdSet];
        for(BMCServiceDesk__Problem__c eachProblem : relatedProblems) {
            problemMap.put(eachProblem.Id, eachProblem);
        }
    }
    if(!changeIdSet.isEmpty()) {
        relatedChangeRequests = [select Id, Operational_Catalog_Tier_1__c, Operational_Catalog_Tier_2__c, Product_Catalog_Tier_1__c, Product_Catalog_Tier_2__c from BMCServiceDesk__Change_Request__c where Id=:changeIdSet];
        for(BMCServiceDesk__Change_Request__c eachChange : relatedChangeRequests) {
            changeMap.put(eachChange.Id, eachChange);
        }
    }
    
    for(BMCServiceDesk__Task__c eachNewTask : newTasks) {
        if(eachNewTask.BMCServiceDesk__FKIncident__c != null) {
            BMCServiceDesk__Incident__c incidentRecord = incidentMap.get(eachNewTask.BMCServiceDesk__FKIncident__c);
            eachNewTask.Operational_Catalog_Tier_1__c = incidentRecord.Operational_Catalog_Tier_1__c;
            eachNewTask.Operational_Catalog_Tier_2__c = incidentRecord.Operational_Catalog_Tier_2__c ;
            eachNewTask.Product_Catalog_Tier_1__c = incidentRecord.Product_Catalog_Tier_1__c ;     
            eachNewTask.Product_Catalog_Tier_2__c = incidentRecord.Product_Catalog_Tier_2__c ;
        }
        else if(eachNewTask.BMCServiceDesk__FKProblem__c != null) {
            BMCServiceDesk__Problem__c problemRecord = problemMap.get(eachNewTask.BMCServiceDesk__FKProblem__c);
            eachNewTask.Operational_Catalog_Tier_1__c = problemRecord.Operational_Catalog_Tier_1__c;
            eachNewTask.Operational_Catalog_Tier_2__c = problemRecord.Operational_Catalog_Tier_2__c ;
            eachNewTask.Product_Catalog_Tier_1__c = problemRecord.Product_Catalog_Tier_1__c ;     
            eachNewTask.Product_Catalog_Tier_2__c = problemRecord.Product_Catalog_Tier_2__c ;            
        }
        else if(eachNewTask.BMCServiceDesk__FKChange__c != null) {
            BMCServiceDesk__Change_Request__c changeRecord = changeMap.get(eachNewTask.BMCServiceDesk__FKChange__c);
            eachNewTask.Operational_Catalog_Tier_1__c = changeRecord.Operational_Catalog_Tier_1__c;
            eachNewTask.Operational_Catalog_Tier_2__c = changeRecord.Operational_Catalog_Tier_2__c ;
            eachNewTask.Product_Catalog_Tier_1__c = changeRecord.Product_Catalog_Tier_1__c ;     
            eachNewTask.Product_Catalog_Tier_2__c = changeRecord.Product_Catalog_Tier_2__c ;    
        }
    } 

}