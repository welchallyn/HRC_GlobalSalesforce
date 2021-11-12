/*
 *  ClassName    : ChangeRequestHandler
 *  CreatedOn    : 22nd Dec,2016
 *  ModifiedOn   : 23nd Dec,2016
 *  CreatedBy    : Jenish Shingala
 *  ModifiedBy   : Jenish Shingala
 *  Description  : Used for Handling all events for Change Request (Change_Request__c). 
 */
public with sharing class ChangeRequestHandler {
   
    //List<BMCServiceDesk__Change_Request__c> newChanges = Trigger.new;
    
    // Define 2 sets to hold the Id of the records to be fetched.
    Set<Id> changeIdSet = new Set<Id>();
    Set<Id> statusIDSet = new Set<Id>();
    
    // Map to associate tasks status with the tasks Open/Closed state
    Map<Id, Boolean> statusIdtoStateMap = new Map<Id, Boolean>();
    
    //Map to associate taks status id with status name
    Map<Id, String> statusIdtoNameMap = new Map<Id, String>();
    
    // Map to associate ChangeRequest with its associated list of tasks if it has some tasks, otherwise it will not have an entry
    Map<id, List<BMCServiceDesk__Task__c>> taskMap = new Map<id, List<BMCServiceDesk__Task__c>>();
    
    List<BMCServiceDesk__Task__c> t = new List<BMCServiceDesk__Task__c>();
    List<BMCServiceDesk__Task__c> taskList;
    List<BMCServiceDesk__Status__c> statusList = new List<BMCServiceDesk__Status__c>();
    String statusValue = null;
    String implementStatusValue = null;
    String planScheduleStatusValue = null;
    HillRom_Settings__c IN_PROGRESS_STATUS;
    HillRom_Settings__c IMPLEMENT_STATUS;
    Boolean flag;
    List<BMCServiceDesk__Task__c> associatedTasksList = new List<BMCServiceDesk__Task__c>();
    List<BMCServiceDesk__Task__c> tasksListtobeUnlocked = new List<BMCServiceDesk__Task__c>();
    List<Approval_Mapping__c> approvalMappingRecord=new List<Approval_Mapping__c>();
    
    
    
    
    /*
     * MethodName : onBeforeInsert
     * Param      : lstChangeRequestNew
     * Description: Triggers on before insert 
     */
    public void onBeforeInsert(List < BMCServiceDesk__Change_Request__c > lstChangeRequestNew,Map<id,BMCServiceDesk__Change_Request__c> oldMap,
                                        Map<id,BMCServiceDesk__Change_Request__c> newMap,Boolean isUpdate) {
            BeforeInsertUpdateLogic(lstChangeRequestNew,oldMap,newMap,isUpdate);
        }
        /*
         * MethodName : onAfterInsert
         * Param      : lstChangeRequestNew
         * Description: Triggers on after insert 
         */

    public void onAfterInsert(List < BMCServiceDesk__Change_Request__c > lstChangeRequestNew) {
        
        
    }

    /*
     * MethodName    : onBeforeUpdate
     * Param         : lstChangeRequestNew.
     * Description   : 
     */

    public void onBeforeUpdate(List<BMCServiceDesk__Change_Request__c> lstChangeRequestNew,Map<id,BMCServiceDesk__Change_Request__c> oldMap,
                                        Map<id,BMCServiceDesk__Change_Request__c> newMap,Boolean isUpdate) {
         BeforeUpdateLogic(lstChangeRequestNew);
         BeforeInsertUpdateLogic(lstChangeRequestNew,oldMap,newMap,isUpdate);
    }
    
    /*
     * MethodName    : BeforeUpdateLogic
     * Param         : newChanges.
     * Description   : Code from provious trigger 'PopulateActualStartDate' which will be deactivated.
                     : Line no 43 to 98.
     */
     
     public void BeforeUpdateLogic(List<BMCServiceDesk__Change_Request__c> newChanges){
          // Get the RecordID's of ChangeRequest and its Status into 2 sets  
            for(BMCServiceDesk__Change_Request__c each: newChanges) {
                changeIdSet.add(each.id);
                statusIDSet.add(each.BMCServiceDesk__FKStatus__c);
            }
            
            // Get only the tasks that are associated with the ChangeRequests in context    
            t = [Select Id,BMCServiceDesk__FKChange__c,BMCServiceDesk__state__c, BMCServiceDesk__FKStatus__c,BMCServiceDesk__Status_ID__c from BMCServiceDesk__Task__c  where BMCServiceDesk__FKChange__c = :changeIdSet limit 200];
           
            // Query the associated tasks and map them with the ChangeRequest. Also, add the task Status to StatusIdSet
            for(BMCServiceDesk__Task__c task: t) {
                // If an entry for this ChangeRequest exists in the map
                if(taskMap.get(task.BMCServiceDesk__FKChange__c) != null) {
                    taskList = taskMap.get(task.BMCServiceDesk__FKChange__c);    
                    taskList.add(task);
                    statusIDSet.add(task.BMCServiceDesk__FKStatus__c);
                    taskMap.put(task.BMCServiceDesk__FKChange__c,taskList);
                }
                // If this is a new entry for this ChangeRequest into the map
                else {
                    taskList= new List<BMCServiceDesk__Task__c>();
                    taskList.add(task);
                    statusIDSet.add(task.BMCServiceDesk__FKStatus__c);
                    taskMap.put(task.BMCServiceDesk__FKChange__c,taskList);
                }        
            }
        
            // Query the Status information pertaining to the Status of Changerequest and its associated tasks    
            statusList = [select Id, Name, BMCServiceDesk__state__c from BMCServiceDesk__Status__c where Id = :statusIDSet limit 100];
            for(BMCServiceDesk__Status__c  eachStatus : statusList) {
                statusIdtoStateMap.put(eachStatus.Id, eachStatus.BMCServiceDesk__state__c); 
            }
            
            for(BMCServiceDesk__Status__c status : [select Id, Name from BMCServiceDesk__Status__c limit 100]){
               statusIdtoNameMap.put(status.Id, status.Name);   
            }
            
            // Get the "InProgress" Status information from CustomSettings    
            
            IN_PROGRESS_STATUS = HillRom_Settings__c.getValues('IN_PROGRESS_STATUS');
            IMPLEMENT_STATUS = HillRom_Settings__c.getValues('IMPLEMENT_STATUS');
        
            
            if(IMPLEMENT_STATUS != null) {
                implementStatusValue = IMPLEMENT_STATUS.value__c;
                System.debug('implementStatusValue'+ implementStatusValue);
            }
     }
     
     /*
     * MethodName    : BeforeInsertUpdateLogic
     * Param         : newChanges.
     * Description   : Code from provious trigger 'PopulateActualStartDate' which will be deactivated.
                     : Line no 99 to 359.
     */
     
     public void BeforeInsertUpdateLogic(List<BMCServiceDesk__Change_Request__c> newChanges,Map<id,BMCServiceDesk__Change_Request__c> oldMap,
                                        Map<id,BMCServiceDesk__Change_Request__c> newMap,Boolean isUpdate){
           
           set<string> Operational_Catalog_Tier_1 = new set<string>();
           set<string> Operational_Catalog_Tier_2 = new set<string>();
           set<string> Product_Catalog_Tier_1 = new set<string>();
           set<string> Product_Catalog_Tier_2 = new set<string>();
           
           
           for(BMCServiceDesk__Change_Request__c each: newChanges){
               Operational_Catalog_Tier_1.add(each.Operational_Catalog_Tier_1__c);
               Operational_Catalog_Tier_2.add(each.Operational_Catalog_Tier_2__c);
               Product_Catalog_Tier_1.add(each.Product_Catalog_Tier_1__c);
               Product_Catalog_Tier_2.add(each.Product_Catalog_Tier_2__c);
           }
           approvalMappingRecord=[Select Operational_Catalog_Tier_1__c, Operational_Catalog_Tier_2__c, Product_Catalog_Tier_1__c, Product_Catalog_Tier_2__c, Support_Group_Name__c From Approval_Mapping__c Where 
                                        (Operational_Catalog_Tier_1__c IN :Operational_Catalog_Tier_1 AND Operational_Catalog_Tier_2__c IN :Operational_Catalog_Tier_2 AND Product_Catalog_Tier_1__c IN :Product_Catalog_Tier_1 AND Product_Catalog_Tier_2__c IN :Product_Catalog_Tier_2)
                                         OR (Operational_Catalog_Tier_1__c ='*' AND Operational_Catalog_Tier_2__c ='*' AND Product_Catalog_Tier_1__c ='*' AND Product_Catalog_Tier_2__c IN :Product_Catalog_Tier_2)
                                         
                                         OR (Operational_Catalog_Tier_1__c ='*' AND Operational_Catalog_Tier_2__c IN :Operational_Catalog_Tier_2 AND Product_Catalog_Tier_1__c ='*' AND Product_Catalog_Tier_2__c IN :Product_Catalog_Tier_2) 
                                         OR (Operational_Catalog_Tier_1__c IN :Operational_Catalog_Tier_1 AND Operational_Catalog_Tier_2__c ='*' AND Product_Catalog_Tier_1__c ='*' AND Product_Catalog_Tier_2__c IN :Product_Catalog_Tier_2) 
                                         OR (Operational_Catalog_Tier_1__c ='*' AND Operational_Catalog_Tier_2__c ='*' AND Product_Catalog_Tier_1__c IN :Product_Catalog_Tier_1 AND Product_Catalog_Tier_2__c IN :Product_Catalog_Tier_2) 
                                        
                                        OR (Operational_Catalog_Tier_1__c ='*' AND Operational_Catalog_Tier_2__c IN :Operational_Catalog_Tier_2 AND Product_Catalog_Tier_1__c IN :Product_Catalog_Tier_1 AND Product_Catalog_Tier_2__c IN :Product_Catalog_Tier_2)
                                        OR (Operational_Catalog_Tier_1__c IN :Operational_Catalog_Tier_1 AND Operational_Catalog_Tier_2__c ='*' AND Product_Catalog_Tier_1__c IN :Product_Catalog_Tier_1 AND Product_Catalog_Tier_2__c IN :Product_Catalog_Tier_2)
                                        OR (Operational_Catalog_Tier_1__c IN :Operational_Catalog_Tier_1 AND Operational_Catalog_Tier_2__c IN :Operational_Catalog_Tier_2 AND Product_Catalog_Tier_1__c ='*' AND Product_Catalog_Tier_2__c IN :Product_Catalog_Tier_2)];
           
                set<String> supportGroupsnamesSet = new set<String>();
                List<String> supportGroupsnamesList = new List<String>();
                if(approvalMappingRecord!=null && approvalMappingRecord.size()>0){
                    for(Approval_Mapping__c eachval:approvalMappingRecord){
                        supportGroupsnamesSet.add(eachval.Support_Group_Name__c);
                    }
                     supportGroupsnamesList.addall(supportGroupsnamesSet);
                }
                
           
           
            for(BMCServiceDesk__Change_Request__c each: newChanges) {
            //Getting Approval Mapping based on category combination
             try{
                each.Support_Group_Name__c = null;
                each.Support_Group_Name_2__c = null;
                each.Support_Group_Name_3__c = null;
                
               
                
                if(supportGroupsnamesList[0] != null)
                    each.Support_Group_Name__c = supportGroupsnamesList[0];
                
                if(supportGroupsnamesList[1] != null)  
                    each.Support_Group_Name_2__c = supportGroupsnamesList[1];
                
                if(supportGroupsnamesList[2] != null)
                    each.Support_Group_Name_3__c = supportGroupsnamesList[2];
                    
            } 
            catch(Exception e){
                System.debug('List has no rows for assigning to SObject');
            }
            
            
            //Checking if the status is changed correctly on the Change Request
            if(isUpdate){
            if(each.BMCServiceDesk__Change_Type__c == 'Emergency'){
                String oldStatusName = statusIdtoNameMap.get(oldMap.get(each.Id).BMCServiceDesk__FKStatus__c);
                String newStatusName = statusIdtoNameMap.get(newMap.get(each.Id).BMCServiceDesk__FKStatus__c);
                
                if(oldStatusName.equals('INITIATE') && (newStatusName.equals('PLAN+SCHEDULE') || newStatusName.equals('IMPLEMENT') || newStatusName.equals('COMPLETED')))
                    each.addError('You cant move to '+ newStatusName + ' Stage');
                    
                else if(oldStatusName.equals('REVIEW+AUTHORIZATION')){
                   if(each.Review_Approved__c == 1 && (newStatusName.equals('PLAN+SCHEDULE') || newStatusName.equals('IMPLEMENT') || newStatusName.equals('COMPLETED')))
                     each.addError('You cant move to '+ newStatusName + ' Stage');
                   else if(((each.Approver1__c == null && each.Approver2__c == null && each.Review_Approved__c == 2) || each.Approved1__c == true || each.Approved2__c == true) && (newStatusName.equals('IMPLEMENT') || newStatusName.equals('COMPLETED')))   
                     each.addError('You cant move to '+ newStatusName + ' Stage');
                   if(oldMap.get(each.Id).Review_Approved__c == 2 &&(newMap.get(each.Id).Support_Group_Name__c !=null)&&(newMap.get(each.Id).Support_Group_Name_2__c !=null) && (newMap.get(each.Id).Support_Group_Name_3__c !=null) && !((oldMap.get(each.Id).Approver1__c != newMap.get(each.Id).Approver1__c) || (oldMap.get(each.Id).Approver2__c != newMap.get(each.Id).Approver2__c) || (oldMap.get(each.Id).Approved1__c != newMap.get(each.Id).Approved1__c) || (oldMap.get(each.Id).Approved2__c != newMap.get(each.Id).Approved2__c)))
                     each.Review_Approved__c = 1;
                    
                }
                 else if(oldStatusName.equals('PLAN+SCHEDULE')){
                   if(each.Plan_Approved__c == 1 && (newStatusName.equals('IMPLEMENT') || newStatusName.equals('COMPLETED')))
                     each.addError('You cant move to '+ newStatusName + ' Stage');
                   else if(((each.Approver1__c == null && each.Approver2__c == null && each.Plan_Approved__c == 2) || each.Approved1__c == true || each.Approved2__c == true) && newStatusName.equals('COMPLETED'))   
                     each.addError('You cant move to '+ newStatusName + ' Stage');
                   if(oldMap.get(each.Id).Plan_Approved__c == 2 && (newMap.get(each.Id).Support_Group_Name__c !=null)&&(newMap.get(each.Id).Support_Group_Name_2__c !=null) && (newMap.get(each.Id).Support_Group_Name_3__c !=null) && !((oldMap.get(each.Id).Approver1__c != newMap.get(each.Id).Approver1__c) || (oldMap.get(each.Id).Approver2__c != newMap.get(each.Id).Approver2__c) || (oldMap.get(each.Id).Approved1__c != newMap.get(each.Id).Approved1__c) || (oldMap.get(each.Id).Approved2__c != newMap.get(each.Id).Approved2__c)))
                     each.Plan_Approved__c = 1;
                   
                }
                else if(oldStatusName.equals('IMPLEMENT')){
                   if(each.Implement_Approved__c == 1 && newStatusName.equals('COMPLETED'))
                     each.addError('You cant move to '+ newStatusName + ' Stage');
                     
                /*if(oldMap.get(each.Id).Implement_Approved__c == 2 &&(newMap.get(each.Id).Support_Group_Name__c !=null)&&(newMap.get(each.Id).Support_Group_Name_2__c !=null) && (newMap.get(each.Id).Support_Group_Name_3__c !=null) && !((oldMap.get(each.Id).RecordTypeId != newMap.get(each.Id).RecordTypeId)||(oldMap.get(each.Id).Approver1__c != newMap.get(each.Id).Approver1__c) || (oldMap.get(each.Id).Approver2__c != newMap.get(each.Id).Approver2__c) || (oldMap.get(each.Id).BMCServiceDesk__Actual_Start_Date__c!= newMap.get(each.Id).BMCServiceDesk__Actual_Start_Date__c) || (oldMap.get(each.Id).BMCServiceDesk__Actual_End_Date__c!= newMap.get(each.Id).BMCServiceDesk__Actual_End_Date__c) || (oldMap.get(each.Id).BMCServiceDesk__AllTaskCloseController__c!= newMap.get(each.Id).BMCServiceDesk__AllTaskCloseController__c)))
                      each.Implement_Approved__c = 1;*/
                  
                }
            }
            
            else if(each.BMCServiceDesk__Change_Type__c == 'Normal'){
                String oldStatusName = statusIdtoNameMap.get(oldMap.get(each.Id).BMCServiceDesk__FKStatus__c);
                String newStatusName = statusIdtoNameMap.get(newMap.get(each.Id).BMCServiceDesk__FKStatus__c);
                System.debug('oldStatusName'+oldStatusName);
                            System.debug('newStatusName'+newStatusName);
    
                if(oldStatusName!=null && oldStatusName.equals('INITIATE') && (newStatusName!=null && (newStatusName.equals('REVIEW+AUTHORIZATION')
                  || newStatusName.equals('IMPLEMENT') || newStatusName.equals('COMPLETED')))){
                    each.addError('You cant move to '+ newStatusName + ' Stage');
                  }
             
                else if(oldStatusName!=null && oldStatusName.equals('PLAN+SCHEDULE')){
                   if(each.Plan_Approved__c == 1 && (newStatusName!=null && (newStatusName.equals('IMPLEMENT') || newStatusName.equals('COMPLETED'))))
                     each.addError('You cant move to '+ newStatusName + ' Stage');
                   else if(((each.Approver1__c == null && each.Approver2__c == null && each.Plan_Approved__c == 2) || each.Approved1__c == true || each.Approved2__c == true)&& newStatusName.equals('CLOSED') )   
                     each.addError('You cant move to '+ newStatusName + ' Stage');
                   if(oldMap.get(each.Id).Plan_Approved__c == 2 &&(newMap.get(each.Id).Support_Group_Name__c !=null)&&(newMap.get(each.Id).Support_Group_Name_2__c !=null) && (newMap.get(each.Id).Support_Group_Name_3__c !=null) && !((oldMap.get(each.Id).Approver1__c != newMap.get(each.Id).Approver1__c) || (oldMap.get(each.Id).Approver2__c != newMap.get(each.Id).Approver2__c) || (oldMap.get(each.Id).Approved1__c != newMap.get(each.Id).Approved1__c) || (oldMap.get(each.Id).Approved2__c != newMap.get(each.Id).Approved2__c)))
                     each.Plan_Approved__c = 1;
                   
                }
                
                else if(oldStatusName!=null && oldStatusName.equals('IMPLEMENT')){
                      each.Enable_task_edit__c = true;
                      each.Implement_Approved__c = 2;
                      System.debug('imp app'+  each.Implement_Approved__c );
                if(each.Implement_Approved__c == 1 && newStatusName.equals('COMPLETED'))
                     each.addError('You cant move to '+ newStatusName + ' Stage');
                  
                }
                     
                /*if(oldMap.get(each.Id).Implement_Approved__c == 2 && !((oldMap.get(each.Id).RecordTypeId != newMap.get(each.Id).RecordTypeId)||(oldMap.get(each.Id).Approver1__c != newMap.get(each.Id).Approver1__c) || (oldMap.get(each.Id).Approver2__c != newMap.get(each.Id).Approver2__c) || (oldMap.get(each.Id).BMCServiceDesk__Actual_Start_Date__c!= newMap.get(each.Id).BMCServiceDesk__Actual_Start_Date__c) || (oldMap.get(each.Id).BMCServiceDesk__Actual_End_Date__c!= newMap.get(each.Id).BMCServiceDesk__Actual_End_Date__c) || (oldMap.get(each.Id).BMCServiceDesk__AllTaskCloseController__c!= newMap.get(each.Id).BMCServiceDesk__AllTaskCloseController__c)))
                      each.Implement_Approved__c = 1;
                else
                     each.Implement_Approved__c = 2;*/
        
                System.debug('imp app'+  each.Implement_Approved__c );
                System.debug('true or false'+ each.Implement_Approved__c );
                System.debug('true or false'+ newStatusName.equals('COMPLETED'));   
                
                
               if(newStatusName.equals('REVIEW+AUTHORIZATION'))
                  each.addError('You cant move to '+ newStatusName + ' Stage');
            }
            
            else if(each.BMCServiceDesk__Change_Type__c == 'Standard'){
                String oldStatusName = statusIdtoNameMap.get(oldMap.get(each.Id).BMCServiceDesk__FKStatus__c);
                String newStatusName = statusIdtoNameMap.get(newMap.get(each.Id).BMCServiceDesk__FKStatus__c);
                
                if(oldStatusName.equals('INITIATE') && (newStatusName.equals('PLAN+SCHEDULE') || newStatusName.equals('IMPLEMENT') || newStatusName.equals('COMPLETED') || newStatusName.equals('CLOSED')))
                    each.addError('You cant move to '+ newStatusName + ' Stage');
                    
                else if(oldStatusName.equals('REVIEW+AUTHORIZATION')){
                   if(each.Review_Approved__c == 1 && (newStatusName.equals('PLAN+SCHEDULE') || newStatusName.equals('IMPLEMENT') || newStatusName.equals('COMPLETED') || newStatusName.equals('CLOSED')))
                     each.addError('You cant move to '+ newStatusName + ' Stage');
                   else if(((each.Approver1__c == null && each.Approver2__c == null && each.Review_Approved__c == 2) || each.Approved1__c == true || each.Approved2__c == true) && (newStatusName.equals('IMPLEMENT') || newStatusName.equals('COMPLETED') || newStatusName.equals('CLOSED')))   
                     each.addError('You cant move to '+ newStatusName + ' Stage');
                   if(oldMap.get(each.Id).Review_Approved__c == 2 &&(newMap.get(each.Id).Support_Group_Name__c !=null)&&(newMap.get(each.Id).Support_Group_Name_2__c !=null) && (newMap.get(each.Id).Support_Group_Name_3__c !=null) && !((oldMap.get(each.Id).Approver1__c != newMap.get(each.Id).Approver1__c) || (oldMap.get(each.Id).Approver2__c != newMap.get(each.Id).Approver2__c) || (oldMap.get(each.Id).Approved1__c != newMap.get(each.Id).Approved1__c) || (oldMap.get(each.Id).Approved2__c != newMap.get(each.Id).Approved2__c)))
                     each.Review_Approved__c = 1;
                    
                }
                 else if(oldStatusName.equals('PLAN+SCHEDULE')){
                   if(each.Plan_Approved__c == 1 && (newStatusName.equals('IMPLEMENT') || newStatusName.equals('COMPLETED') || newStatusName.equals('CLOSED')))
                     each.addError('You cant move to '+ newStatusName + ' Stage');
                   else if(((each.Approver1__c == null && each.Approver2__c == null && each.Plan_Approved__c == 2) || each.Approved1__c == true || each.Approved2__c == true) && (newStatusName.equals('COMPLETED') || newStatusName.equals('CLOSED')))   
                     each.addError('You cant move to '+ newStatusName + ' Stage');
                   if(oldMap.get(each.Id).Plan_Approved__c == 2 &&(newMap.get(each.Id).Support_Group_Name__c !=null)&&(newMap.get(each.Id).Support_Group_Name_2__c !=null) && (newMap.get(each.Id).Support_Group_Name_3__c !=null) && !((oldMap.get(each.Id).Approver1__c != newMap.get(each.Id).Approver1__c) || (oldMap.get(each.Id).Approver2__c != newMap.get(each.Id).Approver2__c) || (oldMap.get(each.Id).Approved1__c != newMap.get(each.Id).Approved1__c) || (oldMap.get(each.Id).Approved2__c != newMap.get(each.Id).Approved2__c)))
                     each.Plan_Approved__c = 1;
                   
                }
                else if(oldStatusName.equals('IMPLEMENT')){
                   if(each.Implement_Approved__c == 1 && (newStatusName.equals('COMPLETED') || newStatusName.equals('CLOSED')))
                     each.addError('You cant move to '+ newStatusName + ' Stage');
                   else if(((each.Approver1__c == null && each.Approver2__c == null && each.Implement_Approved__c == 2) || each.Approved1__c == true || each.Approved2__c == true) && newStatusName.equals('CLOSED'))   
                     each.addError('You cant move to '+ newStatusName + ' Stage');  
                 /* if(oldMap.get(each.Id).Implement_Approved__c == 2 &&(newMap.get(each.Id).Support_Group_Name__c !=null)&&(newMap.get(each.Id).Support_Group_Name_2__c !=null) && (newMap.get(each.Id).Support_Group_Name_3__c !=null) && !((oldMap.get(each.Id).RecordTypeId != newMap.get(each.Id).RecordTypeId)||(oldMap.get(each.Id).Approver1__c != newMap.get(each.Id).Approver1__c) || (oldMap.get(each.Id).Approver2__c != newMap.get(each.Id).Approver2__c) || (oldMap.get(each.Id).BMCServiceDesk__Actual_Start_Date__c!= newMap.get(each.Id).BMCServiceDesk__Actual_Start_Date__c) || (oldMap.get(each.Id).BMCServiceDesk__Actual_End_Date__c!= newMap.get(each.Id).BMCServiceDesk__Actual_End_Date__c) || (oldMap.get(each.Id).BMCServiceDesk__AllTaskCloseController__c!= newMap.get(each.Id).BMCServiceDesk__AllTaskCloseController__c)))
                      each.Implement_Approved__c = 1;*/
                 
                }
                else if(oldStatusName.equals('COMPLETED')){
                   System.debug('each.Completed_Approved__c'+each.Completed_Approved__c);
                   if(each.Completed_Approved__c == 1 && newStatusName.equals('CLOSED'))
                     each.addError('You cant move to '+ newStatusName + ' Stage');
                     
                   if(oldMap.get(each.Id).Completed_Approved__c == 2 && !((oldMap.get(each.Id).Approver1__c != newMap.get(each.Id).Approver1__c) || (oldMap.get(each.Id).Approver2__c != newMap.get(each.Id).Approver2__c)))
                      each.Completed_Approved__c = 1;
                      
                      
                   System.debug('each.Completed_Approved__c'+each.Completed_Approved__c);
                 
                }
            }
            else if(each.BMCServiceDesk__Change_Type__c == 'Normal' || each.BMCServiceDesk__Change_Type__c == 'Normal with Close Down'){
                String oldStatusName = statusIdtoNameMap.get(oldMap.get(each.Id).BMCServiceDesk__FKStatus__c);
                String newStatusName = statusIdtoNameMap.get(newMap.get(each.Id).BMCServiceDesk__FKStatus__c);
                System.debug('oldStatusName'+oldStatusName);
                            System.debug('newStatusName'+newStatusName);
    
                if(oldStatusName.equals('INITIATE') && (newStatusName.equals('REVIEW+AUTHORIZATION')|| newStatusName.equals('IMPLEMENT') || newStatusName.equals('COMPLETED')))
                    each.addError('You cant move to '+ newStatusName + ' Stage');
             
                else if(oldStatusName.equals('PLAN+SCHEDULE')){
                   if(each.Plan_Approved__c == 1 && (newStatusName.equals('IMPLEMENT') || newStatusName.equals('COMPLETED')))
                     each.addError('You cant move to '+ newStatusName + ' Stage');
                   else if(((each.Approver1__c == null && each.Approver2__c == null && each.Plan_Approved__c == 2) || each.Approved1__c == true || each.Approved2__c == true)&& newStatusName.equals('CLOSED') )   
                     each.addError('You cant move to '+ newStatusName + ' Stage');
                   if(oldMap.get(each.Id).Plan_Approved__c == 2 &&(newMap.get(each.Id).Support_Group_Name__c !=null)&&(newMap.get(each.Id).Support_Group_Name_2__c !=null) && (newMap.get(each.Id).Support_Group_Name_3__c !=null) && !((oldMap.get(each.Id).Approver1__c != newMap.get(each.Id).Approver1__c) || (oldMap.get(each.Id).Approver2__c != newMap.get(each.Id).Approver2__c) || (oldMap.get(each.Id).Approved1__c != newMap.get(each.Id).Approved1__c) || (oldMap.get(each.Id).Approved2__c != newMap.get(each.Id).Approved2__c)))
                     each.Plan_Approved__c = 1;
                   
                }
                
                else if(oldStatusName.equals('IMPLEMENT')){
                      each.Enable_task_edit__c = true;
                      each.Implement_Approved__c = 2;
                      System.debug('imp app'+  each.Implement_Approved__c );
                if(each.Implement_Approved__c == 1 && newStatusName.equals('COMPLETED'))
                     each.addError('You cant move to '+ newStatusName + ' Stage');
                  
                }
                     
                /*if(oldMap.get(each.Id).Implement_Approved__c == 2 && !((oldMap.get(each.Id).RecordTypeId != newMap.get(each.Id).RecordTypeId)||(oldMap.get(each.Id).Approver1__c != newMap.get(each.Id).Approver1__c) || (oldMap.get(each.Id).Approver2__c != newMap.get(each.Id).Approver2__c) || (oldMap.get(each.Id).BMCServiceDesk__Actual_Start_Date__c!= newMap.get(each.Id).BMCServiceDesk__Actual_Start_Date__c) || (oldMap.get(each.Id).BMCServiceDesk__Actual_End_Date__c!= newMap.get(each.Id).BMCServiceDesk__Actual_End_Date__c) || (oldMap.get(each.Id).BMCServiceDesk__AllTaskCloseController__c!= newMap.get(each.Id).BMCServiceDesk__AllTaskCloseController__c)))
                      each.Implement_Approved__c = 1;
                else
                     each.Implement_Approved__c = 2;*/
       
                System.debug('imp app'+  each.Implement_Approved__c );
                System.debug('true or false'+ each.Implement_Approved__c );
                System.debug('true or false'+ newStatusName.equals('COMPLETED'));   
                
                
               if(newStatusName.equals('REVIEW+AUTHORIZATION'))
                  each.addError('You cant move to '+ newStatusName + ' Stage');
            }
            
            flag=true;
            if(taskMap.get(each.id)!= null) {
                associatedTasksList = taskMap.get(each.id);
                for(BMCServiceDesk__Task__c t1 : associatedTasksList) {
                    if(statusIdtoStateMap.get(t1.BMCServiceDesk__FKStatus__c) != false ) {
                        flag=false;
                        break;
                    }
                }
            }    
            System.debug('Flag: '+flag);
            
            //Populate Actual StartDate if Status is Implement
            if(each.BMCServiceDesk__Status__c == implementStatusValue && (each.BMCServiceDesk__Actual_Start_Date__c == null || oldMap.get(each.Id).BMCServiceDesk__Actual_Start_Date__c == each.BMCServiceDesk__Actual_Start_Date__c  ))  {
                if(oldMap.get(each.Id).BMCServiceDesk__Actual_Start_Date__c == each.BMCServiceDesk__Actual_Start_Date__c)
                each.BMCServiceDesk__Actual_End_Date__c = null;
                each.BMCServiceDesk__Actual_Start_Date__c = System.now();
                
                system.debug('implementtttttt');
                each.Enable_task_edit__c = true;
                if(associatedTasksList!=null) {
                system.debug('task listtttt'+associatedTasksList);
                    for(BMCServiceDesk__Task__c t1 : associatedTasksList) {        
                        if(t1.BMCServiceDesk__state__c == true){
                        t1.Enable_Editing__c = true;
                        tasksListtobeUnlocked.add(t1);
                        }
                    }            
                }
            }
            
    
           //Populate ActualEndDate if Status of ChangeRequest is closed, no open Tasks and it has an Actual StartDate
            if(flag == true && statusIdtoStateMap.get(each.BMCServiceDesk__FKStatus__c) == false && (each.BMCServiceDesk__Actual_Start_Date__c != null && each.BMCServiceDesk__Actual_End_Date__c == null || oldMap.get(each.Id).BMCServiceDesk__Actual_End_Date__c == each.BMCServiceDesk__Actual_End_Date__c))
                each.BMCServiceDesk__Actual_End_Date__c = System.now();
        }
        
       
        }
         if(tasksListtobeUnlocked != null && tasksListtobeUnlocked.size()>0) {
            try{
                update tasksListtobeUnlocked;
            }
            catch(Exception e){
                system.debug('Excecption Occured..'+e);
            }
        }
         
     }

 
}