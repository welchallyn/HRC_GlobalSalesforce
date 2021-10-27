/*******************************************************************************************************
* Name                             : HRCFSL_SchedulableBatchClassForSA
* Author                           : Capgemini
* Date                             : August/05/2020
* Requirement/Project Name         : Hill-Rom
* Requirement/Project Description  : 1.Class to schedule this batch class or run as a batch to create
*                                      service report record for service appointment based on the query.
                                       Created for #SE-590
* Revison                          : Added HRCFSL_Service_Report_Generated_byBatch__c = true by Ops Excellence
* Revision                         : Added logic to skip if Service Report already exists by Ops Excellence
/*******************************************************************************************************/
public with sharing class HRCFSL_SchedulableBatchClassForSA implements Schedulable,Database.Batchable<sObject>,Database.AllowsCallouts  {
    //Get records from service appointment
    public Database.QueryLocator start(Database.BatchableContext bc) {
        //Query the service appointment records
        String status = system.label.HRCFSL_Work_Order_Status_Category;
        HRCFSL_Organization_Settings__mdt limitSetting = [select hrcfsl_component_detail__c from HRCFSL_Organization_Settings__mdt
                                                          where developername = 'HRCFSL_Max_Appointments_per_Batch'];
        String batchLimit = limitSetting.HRCFSL_Component_Detail__c;
        return Database.getQueryLocator('Select id, HRCFSL_Work_Order__c, HRCFSL_Work_Order__r.ServiceAppointmentCount from ServiceAppointment where HRCFSL_Work_Order__r.ParentWorkOrderId = null and HRCFSL_Work_Order__r.HRCFSL_Multisign__c = false and HRCFSL_Is_Service_Report_Generated__c = false and HRCFSL_Work_Order_Status_Category__c = \'' + status + '\'' + ' and LastModifiedDate >=YESTERDAY');
    }
    //Process fetched records 
    public void execute(Database.BatchableContext bc, List<ServiceAppointment> serviceAppointmentRecords){
    
        System.debug(serviceAppointmentRecords.size()+'serviceAppointmentRecords>>');
        
        list<HRCFSL_ServiceReportHelper.FlowInputWrapper> listOfWrapper = new List<HRCFSL_ServiceReportHelper.FlowInputWrapper>();
        List<ServiceAppointment> lstMultipleSAs = new List<ServiceAppointment>();
        HRCFSL_ServiceReportHelper.FlowInputWrapper wrapper;
        Set<Id> setWorkOrderIds = new Set<Id>();
        Set<Id> setWorkOrderIdsWithReports = new Set<Id>();
        //send for report generation if there is only one Service Appointment. In case of multiple, check if report already exists.
        for(ServiceAppointment loopSA : serviceAppointmentRecords){         
            if(loopSA.HRCFSL_Work_Order__r.ServiceAppointmentCount == 1){
                wrapper = new HRCFSL_ServiceReportHelper.FlowInputWrapper();
                wrapper.parentRecordID = loopSA.ID;
                listOfWrapper.add(wrapper);
            }else if (loopSA.HRCFSL_Work_Order__r.ServiceAppointmentCount > 1){
                setWorkOrderIds.add(loopSA.HRCFSL_Work_Order__c);
            }       
        }
        //fetch all the service appointments for the Work Orders with multiple Service Appointments
        if(!setWorkOrderIds.isEmpty()){
            for(ServiceAppointment serApt : [select Id from ServiceAppointment where HRCFSL_Work_Order__c in: setWorkOrderIds]){
                lstMultipleSAs.add(serApt);
            }
        }
        //fetch all those Work Orders where Service Report already exists       
        if(!lstMultipleSAs.isEmpty()){
            for(ServiceAppointment serApt : [Select Id, HRCFSL_Work_Order__c 
                                            From ServiceAppointment 
                                            Where Id IN (Select ParentId From ServiceReport Where ParentId In: lstMultipleSAs)]){
                setWorkOrderIdsWithReports.add(serApt.HRCFSL_Work_Order__c);
            }
        }
        System.debug('setWorkOrderIdsWithReports-->>' + setWorkOrderIdsWithReports);
        
        //Remove those Work Orders where Service Report has already been generated                
        setWorkOrderIds.removeAll(setWorkOrderIdsWithReports);              
        System.debug('setWorkOrderIds-->>' + setWorkOrderIds);
        
        //fetch all completed Service Appointments for which Service Report does not exist
        if(!setWorkOrderIds.isEmpty()){
            for(ServiceAppointment serApt : [Select Id From ServiceAppointment Where HRCFSL_Work_Order__c IN: setWorkOrderIds And StatusCategory = 'Completed']){
                wrapper = new HRCFSL_ServiceReportHelper.FlowInputWrapper();
                wrapper.parentRecordID = serApt.ID;
                listOfWrapper.add(wrapper);
            }
        }       
      
        List<string> status = new List<string>();
        //send service appointments to create service report
        if(!listOfWrapper.isEmpty()){
            status = HRCFSL_ServiceReportHelper.createServiceReport(listOfWrapper);
        }
        if(!status.isEmpty() && status.contains('success')){
            List<ServiceAppointment> updateSA = new List<ServiceAppointment>();
            for(ServiceAppointment iterateSA : serviceAppointmentRecords){
                
                system.debug('iterateSA>>'+iterateSA);
                iterateSA.HRCFSL_Is_Service_Report_Generated__c = true;
                /**Added below line by Ops Excellence on 13th Nov 20
                Purpose: Mark the Service Appointment where Service Report is generated from this Batch Class**/
                iterateSA.HRCFSL_Service_Report_Generated_byBatch__c = true;
                updateSA.add(iterateSA);
            }
            if(!updateSA.isEmpty()){
                update updateSA;
            }
        }
        
    }    
    //Execute after records process is complete
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
    /******************************************************************************
    * Method Name: execute
    * Author: Capgemini
    * Date: August/3/2020
    * Params: SchedulableContext SC
    * Return: void
    * Requirement : to schedule this batch class HRCFSL_BatchToCreateServiceReportForSA
    ******************************************************************************/
    public void execute(SchedulableContext SC) {
        HRCFSL_SchedulableBatchClassForSA serviceReportBatch = new HRCFSL_SchedulableBatchClassForSA();
        database.executebatch(serviceReportBatch,20);
        
    }
}