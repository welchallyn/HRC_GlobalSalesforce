/*******************************************************************************************************
* Name                             : HRCSVC_BatchToSendServiceEstimate
* Author                           : Capgemini
* Date                             : August/25/2020
* Requirement/Project Name         : Hill-Rom
* Requirement/Project Description  : 1.Class to send service estimate to customers based on the quote
                                       status and customer response in work order
                                       Created for #SE-46
* Revison                          :
/*******************************************************************************************************/
public with sharing class HRCSVC_BatchToSendServiceEstimate implements Schedulable, Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext bc) {
        HRCFSL_Organization_Settings__mdt quoteStatusSent = [Select HRCFSL_Component_Detail__c from HRCFSL_Organization_Settings__mdt where developerName='HRCSVC_Quote_Status_Sent'];    	
        HRCFSL_Organization_Settings__mdt quoteStatusFollowUpOne = [Select HRCFSL_Component_Detail__c from HRCFSL_Organization_Settings__mdt where developerName='HRCSVC_Quote_Status_Follow1'];    	
        HRCFSL_Organization_Settings__mdt numberOfDays = [Select HRCFSL_Component_Detail__c from HRCFSL_Organization_Settings__mdt where developerName='HRCSVC_Number_of_days_for_sending_email'];    	
		String query = 'Select id,Asset.SerialNumber,HRCFSL_Contact_Email__c,HRCSVC_Quote_Status__c from workorder where (HRCSVC_Quote_Status__c  = \''+quoteStatusSent.HRCFSL_Component_Detail__c + '\'' +' OR HRCSVC_Quote_Status__c  = \''+quoteStatusFollowUpOne.HRCFSL_Component_Detail__c + '\'' + ') and HRCSVC_Customer_Not_Responded_Since__c >='+numberOfDays.HRCFSL_Component_Detail__c + ' and HRCFSL_Contact_Email__c != NULL';
        system.debug('query == > '+[ Select id,Asset.SerialNumber,HRCFSL_Contact_Email__c,HRCSVC_Quote_Status__c from workorder where (HRCSVC_Quote_Status__c  = 'Quote Sent' OR HRCSVC_Quote_Status__c  = 'Quote Follow-Up 1') and HRCSVC_Customer_Not_Responded_Since__c >=10 and HRCFSL_Contact_Email__c != NULL]);
        system.debug('getQueryLocator == > '+Database.getQueryLocator(query));
        return Database.getQueryLocator(query);      
    }
    public void execute(Database.BatchableContext bc, List<WorkOrder> listWorkOrders){
        List<Id> listOfWOId = new List<Id>();
        Map<Id,ServiceReport> mapOfSRByWOId = new Map<Id,ServiceReport>();
        HRCFSL_Organization_Settings__mdt quoteTemplate = [Select HRCFSL_Component_Detail__c from HRCFSL_Organization_Settings__mdt where developerName='HRCSVC_QuoteTemplate'];    	
		System.debug('Component ID' + quoteTemplate.HRCFSL_Component_Detail__c);
        //iterate to get list of work order id
		list<servicereportlayout> srlayoutlist = new list<servicereportlayout>();
        srlayoutlist= [select id,developername from servicereportlayout where developername=:quoteTemplate.HRCFSL_Component_Detail__c];
        string srtemplateid = srlayoutlist.isEmpty() ? '' : srlayoutlist[0].id;
        for(WorkOrder wo : listWorkOrders){
            listOfWOId.add(wo.ID);
        }
        
        //Get the last modified service report related to work order
        list<ServiceReport> listofsr = [Select DocumentBody,ServiceReportLanguage,DocumentName,ParentId,Template from servicereport where parentID IN :listOfWOId and Template =: srtemplateid Order by LastModifiedDate Desc];
        for(ServiceReport sr : listofsr){
            //as order by is desc
            
            
            if(!mapOfSRByWOId.containsKey(sr.ParentId)) {
                mapOfSRByWOId.put(sr.ParentId,sr);
            }
        }
        //send email to work order contact
        sendEmailAndUpdateWO(listWorkOrders,mapOfSRByWOId);
    }
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
        System.debug('HRCSVC_BatchToSendServiceEstimate Executed');
    }
    /*************************************************************************************
    * Method Name: execute
    * Author: Capgemini
    * Date: August/25/2020
    * Params: SchedulableContext SC
    * Return: void
    * Requirement : To schedule this batch class HRCSVC_BatchToSendServiceEstimate
    **************************************************************************************/
    public void execute(SchedulableContext sc) {
        HRCSVC_BatchToSendServiceEstimate sendServiceEstimate = new HRCSVC_BatchToSendServiceEstimate();
        //Batch Size based on the email limit
        database.executebatch(sendServiceEstimate,9);
    }
     /*************************************************************************************
    * Method Name: execute
    * Author: Capgemini
    * Date: August/25/2020
    * Params: SchedulableContext SC
    * Return: void
    * Requirement : to send email to cutomers and update work orders
    **************************************************************************************/
    public static void sendEmailAndUpdateWO(List<WorkOrder> listOfWorkOrders,Map<Id,ServiceReport> mapOfSRByWOId){
        //Query Metadata
        HRCFSL_Organization_Settings__mdt noReplyEmail =  [select HRCFSL_Component_Detail__c from HRCFSL_Organization_Settings__mdt where developerName='No_Reply_Email'];

        //Follow up one description and subject
        HRCFSL_Organization_Settings__mdt templateOneDescription = [Select HRCFSL_Component_Detail_Long__c from HRCFSL_Organization_Settings__mdt where developerName='HRCSVC_QuoteEmailTemplateOneDescription'];    	
        HRCFSL_Organization_Settings__mdt templateOneSubject = [Select HRCFSL_Component_Detail__c from HRCFSL_Organization_Settings__mdt where developerName='HRCSVC_QuoteEmailTemplateOneSubject'];    	
        //Follow up two description and subject
        HRCFSL_Organization_Settings__mdt templateTwoDescription = [Select HRCFSL_Component_Detail_Long__c from HRCFSL_Organization_Settings__mdt where developerName='HRCSVC_QuoteEmailTemplateTwoDescription'];    	
        HRCFSL_Organization_Settings__mdt templateTwoSubject = [Select HRCFSL_Component_Detail__c from HRCFSL_Organization_Settings__mdt where developerName='HRCSVC_QuoteEmailTemplateTwoSubject'];    	
        //Quote status
        HRCFSL_Organization_Settings__mdt quoteStatusSent = [Select HRCFSL_Component_Detail__c from HRCFSL_Organization_Settings__mdt where developerName='HRCSVC_Quote_Status_Sent'];
        HRCFSL_Organization_Settings__mdt quoteStatusFollow1 = [Select HRCFSL_Component_Detail__c from HRCFSL_Organization_Settings__mdt where developerName='HRCSVC_Quote_Status_Follow1'];
        HRCFSL_Organization_Settings__mdt quoteStatusFollow2 = [Select HRCFSL_Component_Detail__c from HRCFSL_Organization_Settings__mdt where developerName='HRCSVC_Quote_Status_Follow2'];
		//task
		HRCFSL_Organization_Settings__mdt taskStatus = [Select HRCFSL_Component_Detail__c from HRCFSL_Organization_Settings__mdt where developerName='HRCSVC_Task_Status'];
        HRCFSL_Organization_Settings__mdt taskSubject = [Select HRCFSL_Component_Detail__c from HRCFSL_Organization_Settings__mdt where developerName='HRCSVC_Task_Subject'];
        HRCFSL_Organization_Settings__mdt taskPriority = [Select HRCFSL_Component_Detail__c from HRCFSL_Organization_Settings__mdt where developerName='HRCSVC_Task_Priority'];

        //variable declaration
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        Messaging.EmailFileAttachment emailAttachment;
        Messaging.SingleEmailMessage message;
        List<WorkOrder> updateWorkOrders = new List<WorkOrder>();
        //Iterate workorder records with service report
        for(WorkOrder wo : listOfWorkOrders){
            if(mapOfSRByWOId.get(wo.ID) != null){
                ServiceReport sr = mapOfSRByWOId.get(wo.ID);
                emailAttachment = new Messaging.EmailFileAttachment();
                message = new Messaging.SingleEmailMessage();
                emailAttachment.setContentType('application/pdf');
                emailAttachment.setBody(sr.documentbody);
  				//check status
                if(quoteStatusSent.HRCFSL_Component_Detail__c.equalsIgnoreCase(wo.HRCSVC_Quote_Status__c)){
                    message.setSubject(templateOneSubject.HRCFSL_Component_Detail__c.replace('{#AssetSerialNumber}', wo != null && wo.AssetId != null && wo.Asset.SerialNumber != null ?  wo.Asset.SerialNumber : ' '));
                    message.setPlainTextBody(templateOneDescription.HRCFSL_Component_Detail_Long__c.replace('{#AssetSerialNumber}', wo != null && wo.AssetId != null && wo.Asset.SerialNumber != null ?  wo.Asset.SerialNumber : ' '));
                    wo.HRCSVC_Quote_Status__c = quoteStatusFollow1.HRCFSL_Component_Detail__c;
                }else if(quoteStatusFollow1.HRCFSL_Component_Detail__c.equalsIgnoreCase(wo.HRCSVC_Quote_Status__c)){
                    message.setSubject(templateTwoSubject.HRCFSL_Component_Detail__c.replace('{#AssetSerialNumber}', wo != null && wo.AssetId != null && wo.Asset.SerialNumber != null ?  wo.Asset.SerialNumber : ' '));
                    message.setPlainTextBody(templateTwoDescription.HRCFSL_Component_Detail_Long__c.replace('{#AssetSerialNumber}', wo != null && wo.AssetId != null && wo.Asset.SerialNumber != null ?  wo.Asset.SerialNumber : ' '));
                    wo.HRCSVC_Quote_Status__c = quoteStatusFollow2.HRCFSL_Component_Detail__c;
                }
                emailAttachment.setFileName(sr.DocumentName+'.pdf');
                message.setToAddresses(new List<String>{wo.HRCFSL_Contact_Email__c});
                message.setSaveAsActivity(true);
                message.setReplyTo(noReplyEmail.HRCFSL_Component_Detail__c);
                //attach pdf to email
                message.setFileAttachments(new List<Messaging.EmailFileAttachment>{emailAttachment});
                messages.add(message);
                //add work order to update
                updateWorkOrders.add(wo);
            }
        }
        if(!messages.isEmpty()){
            //send email if messages is not empty
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            List<Task> listOfActivity = new List<Task>();
            for(Id workOrderId : mapOfSRByWOId.keySet()){
                If(mapOfSRByWOId.get(workOrderId) != null){
                    Task newTask = new Task();
                    newTask.Subject  = taskSubject.HRCFSL_Component_Detail__c;
                    newTask.Status = taskStatus.HRCFSL_Component_Detail__c;
                    newTask.Priority = taskPriority.HRCFSL_Component_Detail__c;
                    newTask.WhatId = workOrderId;
                    listOfActivity.add(newTask);
                }
            }
            //Create activity records related to work order 
            Database.insert(listOfActivity,false);
            //update work order quote status 
            Database.update(updateWorkOrders,false);
        }
    }
}