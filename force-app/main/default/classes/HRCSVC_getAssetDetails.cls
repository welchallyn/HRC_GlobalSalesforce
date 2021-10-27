/********************
Created on             06-Jan-20211
Created By             Kushagra Bansal - Capgemini 
@description           Class for getting WorkOrder records to correctiveActionMODPM Lightning web component
********************/
public with sharing class HRCSVC_getAssetDetails {
    @AuraEnabled (cacheable=true)
    public static List<WorkOrder> retrieveWorkOrders(){
        return [SELECT Id,WorkOrderNumber,HRCFSL_Work_Type_Name__c,Description,HRCFSL_Next_PM_DT__c,
        HRCFSL_Asset_Product_Description__c,MaintenancePlan.Id, MaintenancePlan.Frequency,MaintenancePlan.FrequencyType, 
        MaintenancePlan.MaintenancePlanNumber, MaintenancePlan.ServiceContractId ,
         ServiceContractId , ServiceContract.Name ,
         AssetId, Asset.Name,
         HRCFSL_Location_Name__c  , Location.HRCFSL_Description__c,
         ServiceTerritoryId, ServiceTerritory.Name,
         EndDate,
         Account.Name,MaintenancePlan.WorkType.Name,
         HRCFSL_ModList__r.Name,HRCFSL_ModList__c
        FROM WorkOrder 
        WHERE  MaintenancePlan.Id!=null
        ORDER BY HRCFSL_Next_PM_DT__c ASC];
    }

       
}