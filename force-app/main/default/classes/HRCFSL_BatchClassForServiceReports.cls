/*******************************************************************************************************
* Name                             : HRCFSL_BatchClassForServiceReports
* Author                           : Birlasoft Ops Excellence
* Date                             : November/13/2020
* Requirement/Project Name         : Hill-Rom
* Requirement/Project Description  : 1. Class to query Service Reports created by Batch Class HRCFSL_SchedulableBatchClassForSA
                                     2. Call the Flow that sends these Reports to ImageNow
* Revision                         : 
/*******************************************************************************************************/

public with sharing class HRCFSL_BatchClassForServiceReports implements Schedulable,Database.Batchable<sObject> {
    
    public HRCFSL_Organization_Settings__mdt limitSetting;
    public HRCFSL_Organization_Settings__mdt reportEmailAddress;
    public HRCFSL_Organization_Settings__mdt serviceReportDelimiter;
    public HRCFSL_Organization_Settings__mdt reportTemplate;
        
    //Get records from service appointment
    public Database.QueryLocator start(Database.BatchableContext bc) {
        //Query the service appointment records 
        String status = system.label.HRCFSL_Work_Order_Status_Category;
        
        limitSetting = [SELECT hrcfsl_component_detail__c FROM HRCFSL_Organization_Settings__mdt WHERE developername = 'HRCFSL_Max_Appointments_per_Batch'];        
        String batchLimit = limitSetting.HRCFSL_Component_Detail__c;
        String query = 'Select id from ServiceAppointment where HRCFSL_Is_Service_Report_Generated__c = true';
        query = query + ' and HRCFSL_Service_Report_Generated_byBatch__c = true and HRCFSL_SendTo_ImageNow__c = false';
        query = query + ' and HRCFSL_Work_Order_Status_Category__c = \'' + status + '\'' + ' and LastModifiedDate >=YESTERDAY';
        return Database.getQueryLocator(query);
    }
    
    //Process fetched records 
    public void execute(Database.BatchableContext bc, List<ServiceAppointment> serviceAppointmentRecords){
        
        Set<Id> serAppIDSet =  new Set<Id>();
        system.debug('serAppIDSet-->'+ serAppIDSet);
       
        list<ID> successReportIds = new list<ID>();
        list<ServiceAppointment> UpdateSAIds = new list<ServiceAppointment>();
        
        if(!serviceAppointmentRecords.isEmpty()){
            for(ServiceAppointment serApp : serviceAppointmentRecords){
                serAppIDSet.add(serApp.Id);
            }
        }
        
        List<ServiceReport> lstServiceReport = new list<ServiceReport>([Select id, parentid, Template from ServiceReport where parentid in: serAppIDSet]);
        List<Id> lstTemplateIds = new List<Id>();       
     
        system.debug('lstServiceReport-->'+ lstServiceReport.size());
        
        reportEmailAddress     = [SELECT HRCFSL_Component_Detail__c FROM HRCFSL_Organization_Settings__mdt WHERE DeveloperName = 'HRCFSL_Service_Report_Email_Address'];
        serviceReportDelimiter = [SELECT HRCFSL_Component_Detail__c FROM HRCFSL_Organization_Settings__mdt WHERE DeveloperName = 'HRCFSL_Service_Report_Delimiter'];
        reportTemplate         = [SELECT HRCFSL_Component_Detail__c FROM HRCFSL_Organization_Settings__mdt WHERE DeveloperName = 'HRCFSL_Emailable_Service_Report_Template'];
        
        ServiceReportLayout srlayout = [Select id, DeveloperName from ServiceReportLayout where DeveloperName=: reportTemplate.HRCFSL_Component_Detail__c];
        list<HRCFSL_EmailServiceReport.emailParams> lstemailParams =  new list<HRCFSL_EmailServiceReport.emailParams>();

        for (ServiceReport varReport : lstServiceReport){
            if(varReport.Template == srlayout.Id){                
                lstemailParams.add(new HRCFSL_EmailServiceReport.emailParams(reportEmailAddress.HRCFSL_Component_Detail__c, varReport.Id, serviceReportDelimiter.HRCFSL_Component_Detail__c));  
            } 
        }
        
        system.debug('lstemailParams-->'+ lstemailParams.size());
        
        if(!lstemailParams.isempty())
           successReportIds = HRCFSL_EmailServiceReport.emailServiceReport(lstemailParams);
        
        list<ServiceReport> lstsuccessSR = [Select Id, ParentId from ServiceReport where Id in:successReportIds];
        
        list<Id> SAIds = new list<Id>();
        
        for(ServiceReport SR:lstsuccessSR){
            SAIds.add(SR.ParentId);
        }
        
        list<ServiceAppointment> lstsuccessSA  = [Select Id, HRCFSL_SendTo_ImageNow__c,HRCFSL_Is_Signed__c from ServiceAppointment where Id in:SAIds];
        
        for(ServiceAppointment SA:lstsuccessSA){
           SA.HRCFSL_Is_Signed__c =true;
           SA.HRCFSL_SendTo_ImageNow__c = true;
           UpdateSAIds.add(SA);
        }
        system.debug('UpdateSAIds>>'+UpdateSAIds);
        
        if(!UpdateSAIds.isempty()) 
        update UpdateSAIds;        
    } 
       
    //Execute after records process is complete
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
    /******************************************************************************
    * Method Name: execute
    * Author: Birlasoft Ops Excellence
    * Date: November/24/2020
    * Params: SchedulableContext SC
    * Return: void
    * Requirement : to schedule this batch class HRCFSL_BatchClassForServiceReports
    ******************************************************************************/
    public void execute(SchedulableContext SC) {
        HRCFSL_BatchClassForServiceReports serviceReportBatchcls = new HRCFSL_BatchClassForServiceReports();
        database.executebatch(serviceReportBatchcls,20);
        
    }
    
}