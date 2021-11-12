/**
 * This batch class is used to Auto Aprrove the Incident if Role does not require approval
 * 
 */
global class AutoApproveIncBasedOnRole implements Database.Batchable<sObject>, Database.Stateful {

    Map<Id,BMCServiceDesk__Incident__c> incidentMap;
    Map<String,Id> rolesNoApprovalRequired;
    List<String> incList;
    public Map<Id,List<ProcessInstanceWorkItem>> piwiMap = new Map<Id,List<ProcessInstanceWorkItem>>();
    Set<ProcessInstanceWorkItem> tobeAutoApprovedList= new Set<ProcessInstanceWorkItem>();
   
    String cognosValue = null;
    String jdedwardsValue = null;
    String cognosValue2 = null;
    String jdedwardsValue2 = null;
    String cognosgenericapprovalvalue = null;
    String sapRolesValue= null;

    HillRom_Settings__c COGNOS_CATEGORY;
    HillRom_Settings__c JDEDWARDS_CATEGORY;
    HillRom_Settings__c COGNOS2_CATEGORY;
    HillRom_Settings__c JDEDWARDS2_CATEGORY;
    HillRom_Settings__c CognosGenericApr;
    HillRom_Settings__c SAP_ROLES;
    
    /*
     * The constructor is called from UpdateApprovers batch class
     */
    global AutoApproveIncBasedOnRole(Map<Id,BMCServiceDesk__Incident__c> incidentMap, List<String> incList, Map<String,Id> rolesNoApprovalRequired) {
        this.incidentMap=incidentMap;
        this.rolesNoApprovalRequired=rolesNoApprovalRequired;
        this.incList=incList;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        String query = 'select Id, ProcessInstanceId, ActorId, Actor.Name, Createddate, ProcessInstance.TargetObjectId, ProcessInstance.Status, ProcessInstance.CreatedDate from ProcessInstanceWorkItem Where isDeleted = false and ProcessInstance.Status = \'Pending\' and ProcessInstance.TargetObjectId in '+incList +' Order By Createddate,ActorId';
       	System.debug('######query'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,  List<ProcessInstanceWorkItem> scope) {
        
        List<ProcessInstanceWorkItem> piwiList;
        Map<Id,List<Id>> incAutoApprovalMap=new Map<Id,List<Id>>();
        List<Id> tempList = new List<Id>();
            
        String requestCategoryString;
        String [] requestCategories;
        //Setting the api names for Cognos, JDE, Agile, SAP roles fields
        COGNOS_CATEGORY = HillRom_Settings__c.getValues('COGNOS');
        JDEDWARDS_CATEGORY = HillRom_Settings__c.getValues('JD EDWARDS');
        COGNOS2_CATEGORY = HillRom_Settings__c.getValues('COGNOS2');
        JDEDWARDS2_CATEGORY = HillRom_Settings__c.getValues('JD EDWARDS2');
        CognosGenericApr = HillRom_Settings__c.getValues('Cognos Generic Approval');
        SAP_ROLES= HillRom_Settings__c.getValues('SAP ROLES');
        
        System.debug('CognosGenericApr :::'+CognosGenericApr );
        if(COGNOS_CATEGORY != null){
        cognosValue = COGNOS_CATEGORY.value__c;
        }
        if(COGNOS2_CATEGORY != null){
        cognosValue2 = COGNOS2_CATEGORY.value__c;
        }
        if(JDEDWARDS_CATEGORY != null){
        jdedwardsValue = JDEDWARDS_CATEGORY .value__c;
        }
        if(JDEDWARDS2_CATEGORY != null){
        jdedwardsValue2 = JDEDWARDS2_CATEGORY.value__c;
        }
        if(CognosGenericApr != null){
        cognosgenericapprovalvalue = CognosGenericApr.value__c;
        }
        if(SAP_ROLES != null){
            sapRolesValue = SAP_ROLES.value__c;
        }
        System.debug('scope'+scope);
     	//creating map for each incident and their approvals list
        for(ProcessInstanceWorkItem eachpiwi:scope){
            piwiList = piwiMap.get(eachpiwi.ProcessInstance.TargetObjectId);
            if(piwiList == null){
                piwiList = new List<ProcessInstanceWorkItem>();
            }
            piwiList.add(eachpiwi);
            piwiMap.put(eachpiwi.ProcessInstance.TargetObjectId, piwiList);
            System.debug('piwiMap'+piwiMap);
            
        }
        if(!incidentMap.isEmpty()){
     
         for(Id eachIncidentId: incidentMap.keySet()) {
             //Getting the selected roles in requestCategoryString
             BMCServiceDesk__Incident__c eachIncident = incidentMap.get(eachIncidentId);
             if(eachIncident.Product_Catalog_Tier_2__c == cognosValue && eachIncident.Cognos_Roles__c!= null)
                     requestCategoryString = String.valueOf(eachIncident.Cognos_Roles__c);
                 else if(eachIncident.Product_Catalog_Tier_2__c == jdedwardsValue && eachIncident.JD_Edwards_Roles__c != null)
                     requestCategoryString = String.valueOf(eachIncident.JD_Edwards_Roles__c); 
                 else if(eachIncident.Product_Catalog_Tier_1__c == jdedwardsValue2 && eachIncident.JD_Edwards_Roles2__c!= null)
                     requestCategoryString = String.valueOf(eachIncident.JD_Edwards_Roles2__c);
                 else if(eachIncident.Product_Catalog_Tier_2__c == cognosValue2 && eachIncident.Cognos_Roles_2__c   != null)
                     requestCategoryString = String.valueOf(eachIncident.Cognos_Roles_2__c  );
                 else if(eachIncident.Product_Catalog_Tier_2__c == sapRolesValue && eachIncident.SAP_Roles__c != null)
                     requestCategoryString = String.valueOf(eachIncident.SAP_Roles__c );
                
                System.debug('Roles selected full string'+requestCategoryString );        
                if(requestCategoryString != null){
                    requestCategories = requestCategoryString.split(';');
                    System.debug('requestCategories '+requestCategories);   
                 }
                else
                    requestCategories = null;
             System.debug('####rolesNoApprovalRequired'+rolesNoApprovalRequired);
             
             //Creating the map of incident and the selected role that does not require approval
             if(requestCategories != null){
                 for(String rc:requestCategories){
                     if(rolesNoApprovalRequired.containsKey(rc)){
                         
                         tempList = incAutoApprovalMap.get(eachIncidentId);
                            if(tempList == null){
                                tempList = new List<Id>();
                            }
                            tempList.add(rolesNoApprovalRequired.get(rc));
                            incAutoApprovalMap.put(eachIncidentId, tempList);
                         
                         System.debug('incAutoApprovalMap'+incAutoApprovalMap);
                     }
                 }
             }
                    
         }
        }
        
        //Creating a list of ProcessInstanceWorkItem for roles to be auto approved for incident
        if(!incAutoApprovalMap.isEmpty()){
            for(Id incId:incAutoApprovalMap.keyset()){
                List<ProcessInstanceWorkItem> piwiIncList=piwiMap.get(incId);
                for(ProcessInstanceWorkItem pi:piwiIncList){
                    for(Id idInstance : incAutoApprovalMap.get(incId)){
                    if(pi.ActorId == idInstance){
                        tobeAutoApprovedList.add(pi);
                    }
                        System.debug('tobeAutoApprovedList'+tobeAutoApprovedList);
                    }
                }
        	}
        }
    }
    
    global void finish( Database.BatchableContext BC ) {
        
        //Calling the queueable job to auto approve the ProcessInstanceWorkItem
        try{
        	If( !Test.isRunningTest()) { 
        		System.enqueueJob(new AutoApproveIncidentQueueable(tobeAutoApprovedList));
        	}
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
    }
}