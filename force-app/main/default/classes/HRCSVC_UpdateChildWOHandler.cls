/***********************************************************************************************************************************************
* Name                             :  HRCSVC_UpdateChildWOHandler
* Author                           :  Capgemini
* Date                             :  April/02/2021
* Requirement/Project Name         :  Hill-Rom
* Requirement/Project Description  :  Class invoked by the HRCSVC Work Order actions PB and HRCFSL_Service Appointment on Work Order PB
part of the components developed for SE-1848, SE - 1980, SE - 1956.
/***********************************************************************************************************************************************/
public class HRCSVC_UpdateChildWOHandler {
    
    /*********************************************************************************************************************************************
* Method Name: updateWorkOrders
* Author: Prasad Vudi
* Date: March/22/2021
* Params: List<WorkOrder>  
* Return: List<String>
* Requirement :SE-1848 :  getks invoked by the PB, accepts parent work orders , calls a future method which updates child work orders.
*********************************************************************************************************************************************/
    @InvocableMethod(label='Handle Child WO updates' description='Updates all the child wos.' category='WorkOrder')
    public static List<String> updateWorkOrders(List<UpdateChildWOInput> pbinput) {
        List<Id> parentWOs = pbinput[0].ListparentWOID;
        String pbname = pbinput[0].pbtitle;
        if(System.isFuture()){
            system.debug('future calling future');
            return null;   
        }  
        system.debug(parentWOs);
        if(pbname == 'woactions'){              
            updateWorkOrdersTerritoryAndWorkTypeInFuture(parentWOs);	           
        }
        if(pbname == 'saonwo'){
            updateWorkOrdersFields(parentWOs);	
        }
        if(pbname == 'saonwochild'){//To raise child platform events
            raiseChildWOEvents(parentWOs);
        }
        
        
        return null;
    }
    
    /*********************************************************************************************************************************************
* Method Name: updateWorkOrdersTerritoryAndWorkTypeInFuture
* Author: Prasad Vudi
* Date: March/22/2021
* Params: Id 
* Return: Void
* Requirement :SE-1848 :  accepts parent work order Id , queries and updates child work orders.
*********************************************************************************************************************************************/
    @Future
    public static void updateWorkOrdersTerritoryAndWorkTypeInFuture(List<Id> parentWOs){
        system.debug('updateWorkOrdersTerritoryAndWorkTypeInFuture-BEGIN');
        List<WorkOrder> childWOs = [Select Id, ServiceTerritoryId, WorkTypeId, ContactId, 
                                    HRCFSL_Contact_Title__c , HRCFSL_Contact_First_Name__c,
                                    HRCFSL_Contact_Last_Name__c, HRCFSL_Contact_Phone__c,
                                    HRCFSL_Contact_Department__c, HRCFSL_Contact_Email__c,
                                    HRCFSL_Ph_No__c, ParentWorkOrderId, ParentWorkOrder.ServiceTerritoryId, 
                                    ParentWorkOrder.WorkTypeId,ParentWorkOrder.ContactId, 
                                    ParentWorkOrder.HRCFSL_Contact_Title__c ,ParentWorkOrder.HRCFSL_Contact_First_Name__c,
                                    ParentWorkOrder.HRCFSL_Contact_Last_Name__c, ParentWorkOrder.HRCFSL_Contact_Phone__c,
                                    ParentWorkOrder.HRCFSL_Contact_Department__c, ParentWorkOrder.HRCFSL_Contact_Email__c,
                                    ParentWorkOrder.HRCFSL_Ph_No__c from WorkOrder where ParentWorkOrderId IN :parentWOs];
        system.debug('childWOs queried'+childWOs);

        for(WorkOrder wo : childWOs){
            if(wo.ServiceTerritoryId != null) wo.ServiceTerritoryId = wo.ParentWorkOrder.ServiceTerritoryId;
            wo.WorkTypeId = wo.ParentWorkOrder.WorkTypeId;
            wo.ContactId = wo.ParentWorkOrder.ContactId;            
            wo.HRCFSL_Contact_Title__c = wo.ParentWorkOrder.HRCFSL_Contact_Title__c;
            wo.HRCFSL_Contact_First_Name__c = wo.ParentWorkOrder.HRCFSL_Contact_First_Name__c;
            wo.HRCFSL_Contact_Last_Name__c = wo.ParentWorkOrder.HRCFSL_Contact_Last_Name__c;
            wo.HRCFSL_Contact_Phone__c = wo.ParentWorkOrder.HRCFSL_Contact_Phone__c;
            wo.HRCFSL_Contact_Department__c = wo.ParentWorkOrder.HRCFSL_Contact_Department__c;
            wo.HRCFSL_Contact_Email__c = wo.ParentWorkOrder.HRCFSL_Contact_Email__c;
            wo.HRCFSL_Ph_No__c = wo.ParentWorkOrder.HRCFSL_Ph_No__c;        
        }
        system.debug('childWOs before update'+childWOs);
        if(childWOs.size()>0){
            update childWOs;
            system.debug('childWOs updated'+childWOs);
        }
        system.debug('updateWorkOrdersTerritoryAndWorkTypeInFuture-END');        
    }
    
    /*********************************************************************************************************************************************
* Method Name: updateWorkOrdersFields
* Author: Capgemini
* Date: April/01/2021
* Params: Id 
* Return: Void
* Requirement :SE-1956 :  accepts parent work order Id , queries and updates child work orders.
*********************************************************************************************************************************************/
    @Future
    public static void updateWorkOrdersFields(List<Id> parentWOs){
        system.debug('updateWorkOrdersFields-BEGIN');
        List<WorkOrder> childWOs = [Select Id, ParentWorkOrderId, ContactId, ParentWorkOrder.ContactId, HRCFSL_Assigned_Engineer__c ,
                                    ParentWorkOrder.HRCFSL_Assigned_Engineer__c , HRCFSL_Actual_Start__c , ParentWorkOrder.HRCFSL_Actual_Start__c ,
                                    HRCFSL_Actual_End__c , ParentWorkOrder.HRCFSL_Actual_End__c , HRCFSL_Contact_Title__c , ParentWorkOrder.HRCFSL_Contact_Title__c ,
                                    HRCFSL_Contact_First_Name__c , ParentWorkOrder.HRCFSL_Contact_First_Name__c , HRCFSL_Contact_Last_Name__c ,    
                                    ParentWorkOrder.HRCFSL_Contact_Last_Name__c ,  HRCFSL_Contact_Department__c , ParentWorkOrder.HRCFSL_Contact_Department__c ,
                                    HRCFSL_Contact_Phone__c , ParentWorkOrder.HRCFSL_Contact_Phone__c , HRCFSL_Ph_No__c , ParentWorkOrder.HRCFSL_Ph_No__c ,
                                    HRCFSL_Ward__c , ParentWorkOrder.HRCFSL_Ward__c , HRCFSL_Signee_Email__c , ParentWorkOrder.HRCFSL_Signee_Email__c ,
                                    HRCFSL_Signee_Name__c , ParentWorkOrder.HRCFSL_Signee_Name__c , HRCFSL_Signee_Title__c , ParentWorkOrder.HRCFSL_Signee_Title__c ,
                                    HRCFSL_PO__c , ParentWorkOrder.HRCFSL_PO__c , HRCFSL_Patient_Off_Date__c , ParentWorkOrder.HRCFSL_Patient_Off_Date__c ,
                                    HRCFSL_Patient_Room__c , ParentWorkOrder.HRCFSL_Patient_Room__c 
                                    from WorkOrder where ParentWorkOrderId IN :parentWOs];
        Set<Id> parentWOIDs = new Set<Id>();
        for(WorkOrder wo : childWOs){
            wo.ContactId = wo.ParentWorkOrder.ContactId;
            wo.HRCFSL_Assigned_Engineer__c = wo.ParentWorkOrder.HRCFSL_Assigned_Engineer__c ;
            wo.HRCFSL_Actual_Start__c = wo.ParentWorkOrder.HRCFSL_Actual_Start__c ;            
            wo.HRCFSL_Actual_End__c = wo.ParentWorkOrder.HRCFSL_Actual_End__c ;            
            wo.HRCFSL_Contact_Title__c = wo.ParentWorkOrder.HRCFSL_Contact_Title__c ;            
            wo.HRCFSL_Contact_First_Name__c = wo.ParentWorkOrder.HRCFSL_Contact_First_Name__c ;            
            wo.HRCFSL_Contact_Last_Name__c  = wo.ParentWorkOrder.HRCFSL_Contact_Last_Name__c     ;            
            wo.HRCFSL_Contact_Department__c = wo.ParentWorkOrder.HRCFSL_Contact_Department__c ;            
            wo.HRCFSL_Contact_Phone__c = wo.ParentWorkOrder.HRCFSL_Contact_Phone__c ;            
            wo.HRCFSL_Ph_No__c = wo.ParentWorkOrder.HRCFSL_Ph_No__c ;            
            wo.HRCFSL_Ward__c = wo.ParentWorkOrder.HRCFSL_Ward__c ;            
            wo.HRCFSL_Signee_Email__c = wo.ParentWorkOrder.HRCFSL_Signee_Email__c ;            
            wo.HRCFSL_Signee_Name__c = wo.ParentWorkOrder.HRCFSL_Signee_Name__c ;            
            wo.HRCFSL_Signee_Title__c = wo.ParentWorkOrder.HRCFSL_Signee_Title__c ;            
            wo.HRCFSL_PO__c = wo.ParentWorkOrder.HRCFSL_PO__c ;            
            wo.HRCFSL_Patient_Off_Date__c = wo.ParentWorkOrder.HRCFSL_Patient_Off_Date__c ;            
            wo.HRCFSL_Patient_Room__c = wo.ParentWorkOrder.HRCFSL_Patient_Room__c ;  
            parentWOIDs.add(wo.ParentWorkOrderId);   
        }
        if(childWOs.size()>0){
            update childWOs;
            system.debug('childWOs updated'+childWOs); 
            /**** Raise Platform Event after child records get updated *****/
            system.debug('create platform event - '+parentWOs);
            List<HRCFSL_Outbound_JDE_Work_Order__e> publishEvents = new List<HRCFSL_Outbound_JDE_Work_Order__e>();        
            HRCFSL_Outbound_JDE_Work_Order__e temp = new HRCFSL_Outbound_JDE_Work_Order__e();
            for(Id parentWO: parentWOIDs ){
                temp = new HRCFSL_Outbound_JDE_Work_Order__e();
                temp.HRCFSL_Work_Order__c = parentWO;
                temp.HRCFSL_IsEventForChildWO__c = true; 
                publishEvents.add(temp);
            }
            EventBus.publish(publishEvents);     
        }    
        system.debug('updateWorkOrdersFields-END');        
    }
    
    /*********************************************************************************************************************************************
* Method Name: raiseChildWOEvents
* Author: Capgemini
* Date: April/30/2021
* Params: Id 
* Return: Void
* Requirement :SE-2118 :  accepts parent work order Id , queries and send events for child work orders.
*********************************************************************************************************************************************/
    @Future
    public static void raiseChildWOEvents(List<Id> parentWOs){
        system.debug('raiseChildWOEvents-BEGIN');
        List<WorkOrder> childWOs = [Select Id, ParentWorkOrderId 
                                    from WorkOrder where ParentWorkOrderId IN :parentWOs];
        Set<Id> parentWOIDs = new Set<Id>();
        for(WorkOrder wo : childWOs){
            parentWOIDs.add(wo.ParentWorkOrderId); 
        }
        if(childWOs.size()>0){
            system.debug('childWOs updated'+childWOs);      
            
            /**** Raise Platform Event after child records get updated *****/
            system.debug('create platform event - '+parentWOs);
            List<HRCFSL_Outbound_JDE_Work_Order__e> publishEvents = new List<HRCFSL_Outbound_JDE_Work_Order__e>();        
            HRCFSL_Outbound_JDE_Work_Order__e temp = new HRCFSL_Outbound_JDE_Work_Order__e();
            for(Id parentWO: parentWOIDs ){
                temp = new HRCFSL_Outbound_JDE_Work_Order__e();
                temp.HRCFSL_Work_Order__c = parentWO;
                temp.HRCFSL_IsEventForChildWO__c = true; 
                publishEvents.add(temp);
            }
            EventBus.publish(publishEvents);          
        }    
        system.debug('raiseChildWOEvents-END');        
    }    
    
    /***********************************************************************************************************************************************
* Name                             :  UpdateChildWOInput
* Author                           :  Capgemini
* Date                             :  April/02/2021
* Requirement/Project Name         :  Hill-Rom
* Requirement/Project Description  :  Wrapper class to take input from PB.
/***********************************************************************************************************************************************/
    
    public class UpdateChildWOInput{
        @InvocableVariable 
        public List<Id> ListparentWOID;
        @InvocableVariable 
        public String pbtitle;
        
    }
    
}