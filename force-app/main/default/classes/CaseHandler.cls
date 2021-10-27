/*
    *  ClassName    : CaseHandler
    *  CreatedOn    : 23/Oct/2017
    *  ModifiedOn   : 4/Dec/2017
    *  CreatedBy    : Erik Siewert
    *  ModifiedBy   : Jenish Shingala
    *  Description  : Used for Handling all events for Case. 
*/
public with sharing class CaseHandler {
    /*
        * MethodName : onBeforeInsert
        * Param      : (nothing)
        * Description: Triggers on before insert 
    */  
    public static boolean isTriggerRun = true;
    
    public void onBeforeInsert(List<Case> lstCaseNew)
    {
        //system.debug('before insert - call defaultEntitlement');
        //defaultEntitlement(lstCaseNew);
      
    }
    
    public void onAfterInsert(List<Case> lstCaseNew)
    {
        
        defaultEntitlement(lstCaseNew);
        closeResolutionTimeOnComplete(lstCaseNew);
      
    }
    /*
        * MethodName : onBeforeUpdate
        * Param      : (nothing)
        * Description: Triggers on before update 
    */
    public void onBeforeUpdate(List<Case> lstCaseNew, Map<id,Case> oldCaseMap)
    {
        //if the record type or origin changes, re-evaluate entitlement.
        //defaultEntitlement(lstCaseNew);
        
    }
    
     /*
        * MethodName : onAfterUpdate
        * Param      : 
        * Description: Triggers on After update 
    */
    
    public void onAfterUpdate(List<Case> lstCaseNew, Map<id,Case> oldCaseMap){
        defaultEntitlement(lstCaseNew);
        onCloseMarkCompleteMilestone(lstCaseNew,oldCaseMap);
        closeResolutionTimeOnComplete(lstCaseNew);
    }
    
    
    /*
        * MethodName : defaultEntitlement
        * Param      : (List<Case>)
        * Description: When a case is created, it isn’t automatically associated with
        *  an entitlement. When a case’s Entitlement field is empty,this code checks 
        * whether the case account has an active entitlement. If the case account has 
        * an active entitlement, the entitlement is added to the case. The trigger 
        * helps ensure that cases are resolved according to your customer support agreements.
    */ 
    public void defaultEntitlement(List<Case> lstCaseNew) {
        List<Case> lstCasesToUpdate = new List<case>();
        Set<Id> AccountIds = new Set<Id>();
        List <Entitlement> entls = new List<Entitlement>();
        Map<string,string> mapTypeEntitlementId = new Map<string,string>();
        //for each case
        for(Case objCase:lstCaseNew){
            //get every accountId
            if(objCase.accountid!=null)
                AccountIds.add(objCase.accountid);
        }
        //query entitlements given the list of accountIds (that are active)  
            if(accountids!=null){
               entls = [Select e.StartDate, e.Id, e.EndDate, 
                    e.AccountId, e.AssetId,e.SlaProcess.Name, e.Name,e.type
                    From Entitlement e Where e.AccountId in :accountids And e.StartDate <= Today];
                system.debug(entls);
              //add all of the entitlements to a map.   
              if(entls!=null && entls.size()>0){
                  for(Entitlement objEntitle:entls){
                      mapTypeEntitlementId.put(objEntitle.type,objEntitle.id);
                  }
              }
            }
            
            List<case> lstNewCases = [select EntitlementId,AccountId,Origin,id,type from case where id in :trigger.newmap.keyset()];
            
            if(entls.isEmpty()==false){
                for(Case c : lstNewCases){
                    //if There is no entitlement assigned to the case and there is an account Id, 
                    if(c.AccountId != null){
                              //for each entitlement in the list
                                system.debug('MAP-->'+mapTypeEntitlementId);
                //if the case origin is email, assign email support entitlement
                                if(c.Origin =='Email'){
                                    if(mapTypeEntitlementId.containsKey('Email Support')){
                                        c.EntitlementId = mapTypeEntitlementId.get('Email Support');
                                    }
                                }
                //if the case origin is phone, assign phone support entitlement
                                if(c.Origin =='Phone'){
                                    if(mapTypeEntitlementId.containsKey('Phone Support')){
                                        c.EntitlementId = mapTypeEntitlementId.get('Phone Support');
                                    }
                                     system.debug('entitlement-->'+c.EntitlementId);
                                }
                             lstCasesToUpdate.add(c);
                    }
                } 
           
                if(lstCasesToUpdate!=null && lstCasesToUpdate.size()>0){
                     isTriggerRun = false;
             try {
                 //update cases. 
                    update lstCasesToUpdate;
                 } catch (system.Dmlexception e) {
                        system.debug(e);
                }
                   
                   
                }
            }
        
    }
    
    //This method completes the milestone while closing the case and its contact name is noreply or system or no reply.
    
    public void onCloseMarkCompleteMilestone(List<case> lstCaseNew,Map<id,case> mapOldCase){
        List<Id> updateCases = new List<Id>();
        Set<Id> caseIds = new Set<id>();
        Set<Id> parentCaseIds = new Set<id>();
        Map<id,case> mapOfCase = new Map<id,case>([select id,contact.name from case where id in :lstCaseNew]);
       
        for(case objCase:lstCaseNew){
             system.debug('name@@@'+mapOfCase.get(objCase.id).contact.name);
            if(objCase.status=='Closed'  && objCase.contactid!=null && (mapOfCase.get(objCase.id).contact.name.equalsIgnoreCase('noreply') || mapOfCase.get(objCase.id).contact.name.equalsIgnoreCase('no reply') || mapOfCase.get(objCase.id).contact.name.equalsIgnoreCase('system'))){
                updateCases.add(objCase.id);
            }
            caseIds.add(objCase.id);
        }
        List<EmailMessage> lstEmails = [SELECT parentid FROM EmailMessage where parentid in :caseIds];
        List<Task> lstTasks = [select whatid from task where whatid in :caseIds and type='Call'];
        system.debug('Tasks-->'+lstTasks);
        if(lstTasks!=null && lstTasks.size()>0){
            for(Task objTask:lstTasks){
                parentCaseIds.add(objTask.whatid);
            }
        }
        
        if(lstEmails!=null && lstEmails.size()>0){
            for(EmailMessage objEmail:lstEmails){
                parentCaseIds.add(objEmail.parentid);
            }
        }
        
        for(Case objCase:lstCaseNew){
            if(objCase.status=='Closed' && parentCaseIds.contains(objCase.id)){
                updateCases.add(objCase.id);
                system.debug('In if-->'+updateCases);
            }
        }
        
        if(updateCases!=null && updateCases.size()>0){
             milestoneUtils.completeMilestone(updateCases, 'First Response', system.now());
        }
        
        
    }
    
    //This method completes the 'Resolution Time' milestone on completion of case.
    public void closeResolutionTimeOnComplete(List<case> lstCaseNew){
         List<Id> casesToUpdate = new List<Id>();
         for(case objCase:lstCaseNew){
              if(objCase.status=='Closed'){
                  casesToUpdate.add(objCase.id);
              }
         }
          if(casesToUpdate!=null && casesToUpdate.size()>0){
             milestoneUtils.completeMilestone(casesToUpdate, 'Resolution Time', system.now());
        }
    }
}