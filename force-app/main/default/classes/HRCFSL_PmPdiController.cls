/*******************************************************************************************************
* Name                             : HRCFSL_PmPdiController
* Author                           : Capgemini
* Date                             : August/05/2020
* Requirement/Project Name         : Hill-Rom
* Requirement/Project Description  : 1.Class to be used with Lightning Web component pmPdi for creating WO
*                                     to be used by bar code scanner.   
                                      Created for #SE-346
* Revison                          : Changed HRCFSL_Auto_Generate_SA__c from false true by Pietro D
*                                    Added HRCSL_PM_PDI checkbox by Pietro D
/*******************************************************************************************************/
public class HRCFSL_PmPdiController {
    @AuraEnabled(cacheable=true)
    public static List<HRCFSL_Inspection_Step__c> getPmPdiSteps(String workOrderId) {
            List<HRCFSL_Inspection_Step__c> steps = [ select Id, Name, HRCFSL_Input__c, HRCFSL_Sequence__c,HRCFSL_Short_Description__c,  HRCFSL_Description__c
                                                  from HRCFSL_Inspection_Step__c where HRCFSL_Work_Order__c =: workOrderId order by HRCFSL_Sequence__c asc]; 
        return steps; 
    }
       
    @AuraEnabled(cacheable=true)
    public static String getWorkOrderId(String serialNumber) {
        List<WorkOrder> wos = 
            [ select Id from WorkOrder where HRCFSL_Asset_Name__c =: serialNumber order by CreatedDate desc limit 1]; 
        if (wos.size() > 0) {
            return wos[0].Id;
        }
        return null; 
    }
    
    @AuraEnabled(cacheable=true)
    public static Asset getAsset(String serialNumber) {
        List<Asset> assets = 
            [ select Id, SerialNumber, HRCFSL_Model_Description__c, Location.Name, HRCFSL_Asset_Type__c, HRCFSL_Next_PM_DT__c, toLabel(Status) from Asset where SerialNumber =: serialNumber AND HRCFSL_Eq_Class__c != '022']; 
        
        return assets[0];
    }
    
    @AuraEnabled
    public static User getTechnician(String jdeId) {
        User user = 
            [ select Id, Name from User where JDE_External_Id__c =: jdeId ]; 
        return user; 
    }
    
    @AuraEnabled
    public static String createWorkOrder(String assetId, String userId, String technicianName, String disinfectantUsed, String infectionType) {
        Asset thisAsset = [Select Id, HRCFSL_Asset_Status__c, HRCFSL_Next_PM_DT__c, LocationId from Asset where Id =: assetId];
        User thisUser = [Select Id,HRCFSL_Service_Territory__c From User WHERE Id =: userId];
        ServiceTerritory st = [Select Id,HRCFSL_External_ID__c From ServiceTerritory Where HRCFSL_External_ID__c =: thisUser.HRCFSL_Service_Territory__c];
        WorkOrder wo = new WorkOrder();
        wo.LocationId = thisAsset.LocationId; 
        //wo.ServiceTerritoryId = st.Id;
        wo.Status = 'SA';
        wo.HRCFSL_Doc_Type__c = 'SQ';
        wo.AssetId = thisAsset.Id; 
        wo.HRCFSL_Assigned_Engineer__c = userId; 
        //wo.HRCFSL_Auto_Generate_SA__c = false;
        //Changed HRCFSL_Auto_Generate_SA__c to true to generate a Service Appointment
        //to allow completion of work orders via an action
        //Changes made by Pietro Delfrati on March 25, 2021
        wo.HRCFSL_Auto_Generate_SA__c = true;
        wo.HRCFSL_PM_PDI__c = true;
        wo.HRCFSL_Sync_with_ERP__c = true;
        
        //Find Work Order Location based on User's Service Territory
        //Schema.Location loc = [Select Id From Location WHERE HRCFSL_Customer_ID__c =: thisUser.HRCFSL_Service_Territory__c];
        //wo.LocationId = loc.Id;
        
             
        //We create a new SQ-U Work Order and leave it Open if the Asset's Next PM due date <= TODAY + 30 else create a SQ-P. 
        Date dueDate = system.today().addDays(30);
        if (thisAsset.HRCFSL_Next_PM_DT__c <= dueDate) { 
            wo.HRCFSL_Activity_Type__c = 'U';    
                    }
        else {
            wo.HRCFSL_Activity_Type__c = 'P';
                    }
        
        List<WorkOrder> OpenWOs =
            [ select Id from WorkOrder where Status = 'SA' AND HRCFSL_Doc_Type__c = 'SQ' AND HRCFSL_Activity_Type__c = :wo.HRCFSL_Activity_Type__c AND AssetId = :wo.AssetId
             order by CreatedDate desc limit 1]; 
        
        if(OpenWOs.size() > 0){
            //Another open work order of the same type for the same Asset exists
            //Set duplicate flag which will trigger a validation rule and prevent WO creation
            wo.HRCFSL_Duplicate_PM_PDI__c = true;  
        }
        
        
        insert wo;
        
        List<HRCFSL_Inspection_Step__c> steps = new List<HRCFSL_Inspection_Step__c>();
        HRCFSL_Inspection_Step__c step = new HRCFSL_Inspection_Step__c();
        step.Name = 'Technician Name';
        step.HRCFSL_Short_Description__c = 'Technician Name';
        step.HRCFSL_Sequence__c = 151;
        step.HRCFSL_Input__c = technicianName;
        step.HRCFSL_Work_Order__c = wo.Id;
        steps.add(step);
        
        step = new HRCFSL_Inspection_Step__c();
        step.Name = 'Disinfectant Used';
        step.HRCFSL_Short_Description__c = 'Disinfectant Used';
        step.HRCFSL_Sequence__c = 152;
        step.HRCFSL_Input__c = disinfectantUsed;
        step.HRCFSL_Work_Order__c = wo.Id;
        steps.add(step);
        
        step = new HRCFSL_Inspection_Step__c();
        step.Name = 'Infection Type';
        step.HRCFSL_Short_Description__c = 'Infection Type';
        step.HRCFSL_Sequence__c = 153;
        step.HRCFSL_Input__c = infectionType;
        step.HRCFSL_Work_Order__c = wo.Id;
        steps.add(step);
        
        insert steps; 
        
        wo = [select WorkOrderNumber from WorkOrder where Id =: wo.Id];
        
        return wo.WorkOrderNumber; 
        
         
    }
    
    
}