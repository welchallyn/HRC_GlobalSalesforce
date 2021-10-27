/***********************************************************************************************
* Name                             : HRCFSL_ServiceReportHelper
* Author                           : Capgemini
* Date                             : August/3/2020
* Requirement/Project Name         : Hill-Rom
* Requirement/Project Description  : Class to Create service report record related to a parent object
*                                      with the help of callout and queuable class when called from flows.
                                       This class is also called from batch class HRCFSL_SchedulableBatchClassForSA.
                                       Created for #SE-590
* Revison                          :
/***********************************************************************************************/
public with sharing class HRCFSL_ServiceReportHelper implements Queueable,Database.AllowsCallouts{
    //class variable to hold flow wrapper value
    private FlowInputWrapper flowWrapper;
    //paramaterised constructor 
    public HRCFSL_ServiceReportHelper(FlowInputWrapper flowWrapper){
        this.flowWrapper = flowWrapper;
    }
    /************************************************************************************************
    * Method Name: createServiceReport
    * Author: Capgemini
    * Date: August/3/2020
    * Params: list<FlowInputWrapper> flowInputs
    * Return: void
    * Requirement : to create service report with the help of JSON 
    *               we can also execute this class with flow and send email to the customers
    ************************************************************************************************/
    @InvocableMethod
    public static list<string> createServiceReport(list<FlowInputWrapper> flowInputs) {
        list<string> statusResponse = new list<string>();
        List<Id> listOfParentId = new List<Id>();
        List<String> listOfLayout = new List<String>();
        HRCFSL_Organization_Settings__mdt serviceReportURL = [select HRCFSL_Component_Detail__c from HRCFSL_Organization_Settings__mdt where developerName='WebServiceURLForSR'];
        for(FlowInputWrapper flowWrapper: flowInputs){
            listOfParentId.add(flowWrapper.parentRecordID);
            if(!String.isEmpty(flowWrapper.serviceReportLayout)){
                listOfLayout.add(flowWrapper.serviceReportLayout);
            }
        }
        //create json from parentID
        String jsonToCreateRecord = HRCFSL_CreateJSONForServiceReport.createJSONForServiceReport(listOfParentId,listOfLayout); 
        if(!system.isBatch()){
            flowInputs[0].jsonRecord = jsonToCreateRecord;
            System.enqueueJob(new HRCFSL_ServiceReportHelper(flowInputs[0]));
            return null;
        }else{
            HttpResponse response = serviceReportCallout(jsonToCreateRecord);
            if (response.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' +
                             response.getStatusCode() + ' ' + response.getStatus());
                //status if error occures
                statusResponse.add('error');
                return statusResponse;
            } else {
                //status if success
                statusResponse.add('success');
                return statusResponse;
            }
        }
    }
    /************************************************************************************************
    * Method Name: sendEmailToCustomersWithAttachment
    * Author: Capgemini
    * Date: August/3/2020
    * Params: FlowInputWrapper flow_wrap
    * Return: void
    * Requirement : To send email if SendEmailConfirmation is true.
    ************************************************************************************************/
    public static void sendEmailToCustomersWithAttachment(FlowInputWrapper flow_wrap){
        List<String> userEmail = new List<String>();
        userEmail.add(UserInfo.getUserEmail());
        if(flow_wrap.EmailRecipient != null && flow_wrap.sendEmailConfirmation ){
            List<WorkOrder> workOrderRecords = [select id,Asset.SerialNumber from workOrder where ID =: flow_wrap.parentRecordID ];
            HRCFSL_Organization_Settings__mdt emailSubject = [select HRCFSL_Component_Detail__c from HRCFSL_Organization_Settings__mdt where developerName='HRCFSL_Service_Report_Email_Subject'];
            HRCFSL_Organization_Settings__mdt emailBody = [select HRCFSL_Component_Detail_Long__c from HRCFSL_Organization_Settings__mdt where developerName='HRCFSL_Service_Report_Email_Body'];
            HRCFSL_Organization_Settings__mdt QuoteServiceReport = [select HRCFSL_Component_Detail__c from HRCFSL_Organization_Settings__mdt where developerName='QuoteServiceReport'];
            HRCFSL_Organization_Settings__mdt noReplyEmail =  [select HRCFSL_Component_Detail__c from HRCFSL_Organization_Settings__mdt where developerName='No_Reply_Email'];
            workorder wo = workOrderRecords.isempty() ? new workorder() : workOrderRecords[0];
            String subject = emailSubject.HRCFSL_Component_Detail__c.replace('{#serialNumber}', wo != null && wo.AssetId != null && wo.Asset.SerialNumber != null ?  wo.Asset.SerialNumber : ' ');
            string body = emailBody.HRCFSL_Component_Detail_Long__c.replace('{#serialNumber}', wo != null && wo.AssetId != null && wo.Asset.SerialNumber != null ?  wo.Asset.SerialNumber : ' ');
            
            List<ServiceReport> listOfServiceRT = [select parentid,documentbody from ServiceReport where parentid =:flow_wrap.parentRecordID ORDER BY createdDate DESC Limit 1];
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
            emailAttachment.setContentType('application/pdf');
            if(listOfServiceRT.isEmpty()){
                emailAttachment.setBody(Blob.valueOf('No Service Report Content is there'));
            }else{
                emailAttachment.setBody(listOfServiceRT[0].documentbody);
            }
            emailAttachment.setFileName(QuoteServiceReport.HRCFSL_Component_Detail__c.replace('{#serialNumber}', wo != null && wo.AssetId != null && wo.Asset.SerialNumber != null ?  wo.Asset.SerialNumber : ' '));
            message.setToAddresses(flow_wrap.EmailRecipient);
            message.setCcAddresses(userEmail);
            message.setReplyTo(noReplyEmail.HRCFSL_Component_Detail__c);
            message.subject = subject;
            message.plainTextBody = body;
            message.setFileAttachments(new List<Messaging.EmailFileAttachment>{emailAttachment});
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            
            if (results[0].success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: ' + results[0].errors[0].message);
            }
        }
    }
    /***************************************************************************************************
    * Method Name: serviceReportCallout
    * Author: Capgemini
    * Date: August/3/2020
    * Params: String serviceReportJSON
    * Return: void
    * Requirement : callout method to create service report
    *****************************************************************************************************/
      public static HttpResponse serviceReportCallout(String serviceReportJSON){
        HRCFSL_Organization_Settings__mdt serviceReportURL = [Select HRCFSL_Component_Detail__c from HRCFSL_Organization_Settings__mdt where developerName='WebServiceURLForSR'];
        
        //API for creation of service reportHttpResponse
        String url = System.Url.getSalesforceBaseURL().toExternalForm() + serviceReportURL.HRCFSL_Component_Detail__c;
        // Create HTTP request
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
        //maximum timeout set
        request.setTimeout(120000);
        // Set the body as a JSON object
        request.setBody(serviceReportJSON);
        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug(response);
        return response;
    }
    /***************************************************************************************************
    * Method Name: execute
    * Author: Capgemini
    * Date: August/3/2020
    * Params: QueueableContext context
    * Return: void
    * Requirement : callout method to create service report
    *****************************************************************************************************/
    public void execute(QueueableContext context) {
        FlowInputWrapper wrapper = this.flowWrapper;
        HttpResponse response = serviceReportCallout(wrapper.jsonRecord);
        if (response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' +response.getStatusCode() + ' ' + response.getStatus());
        }else {
            System.debug(response.getBody());
            //email should be sent through flow only
            if(wrapper.sendEmailConfirmation != null && wrapper.sendEmailConfirmation){
                sendEmailToCustomersWithAttachment(wrapper);
            }
        }
    }
    /****************************************************
    Wrapper class for holding Flow Input variables   
    *****************************************************/
    public class FlowInputWrapper{
        //parentID to attach service report
        @InvocableVariable(label='ParentRecordID')
        public String parentRecordID;
        //service report layout (for furture use)
        @InvocableVariable(label='ServiceReportLayout')
        public String serviceReportLayout;
        //send email when true
        @InvocableVariable(label='SendEmail')
        public Boolean SendEmailConfirmation;   
        //email recipient
        @InvocableVariable(label='EmailRecipient')
        public String[] EmailRecipient;
        //to store json value of service report
        public String jsonRecord;
    }
}