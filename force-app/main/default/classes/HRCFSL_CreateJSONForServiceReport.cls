/***********************************************************************************************
* Name                             : HRCFSL_CreateJSONForServiceReport
* Author                           : Capgemini
* Date                             : August/05/2020
* Requirement/Project Name         : Hill-Rom
* Requirement/Project Description  : Class to create JSON for service report for #SE-590
* Revison                          :
/***********************************************************************************************/
public with sharing class HRCFSL_CreateJSONForServiceReport {
    public List<Inputs> inputs;
    
    public  HRCFSL_CreateJSONForServiceReport(){
        //initialize input list
        inputs = new List<Inputs>();
    }
    
    public class Inputs {
        public String entityId;        
        public String templateId;
    }
    /******************************************************************************
    * Method Name: createJSONForServiceReport
    * Author: Capgemini
    * Date: August/5/2020
    * Params: List<Id> listOfId,List<String> listOfTemplate
    * Return: void
    * Requirement : to create JSON for service report with the given parameters
    ******************************************************************************/
    public static String createJSONForServiceReport(List<Id> listOfId,List<String> listOfTemplate) {
        HRCFSL_CreateJSONForServiceReport varJSON = new HRCFSL_CreateJSONForServiceReport();
        HRCFSL_CreateJSONForServiceReport.Inputs varInput;
        //HRCFSL_CreateJSONForServiceReport.Signatures varSignature;
        ServiceReportLayout templateID;
        String metaDataName = !listOfTemplate.isEmpty() ? listOfTemplate[0] : 'Master_Label_Service_Report_Layout';
        //Query custom metadata to get the template name
        HRCFSL_Organization_Settings__mdt customMeta = [select HRCFSL_Component_Detail__c from HRCFSL_Organization_Settings__mdt where developerName=: metaDataName];
        if(customMeta != null){
            templateID = [select id from ServiceReportLayout where developerName=: customMeta.HRCFSL_Component_Detail__c];
        }
        HRCFSL_Organization_Settings__mdt signatureData = [select HRCFSL_Component_Detail__c from HRCFSL_Organization_Settings__mdt where developerName='SignatureData'];
        HRCFSL_Organization_Settings__mdt signatureContentType = [select HRCFSL_Component_Detail__c from HRCFSL_Organization_Settings__mdt where developerName='SignatureContentType'];
        HRCFSL_Organization_Settings__mdt signatureType = [select HRCFSL_Component_Detail__c from HRCFSL_Organization_Settings__mdt where developerName='SignatureType'];
        //Loop through all records to create JSON entity and template ID
        for(Integer i=0;i < listOfId.size() ; i++){
            varInput = new HRCFSL_CreateJSONForServiceReport.Inputs();
            if(String.isNotBlank(listOfId[i]) && String.isNotBlank(templateID.ID)){
                varInput.entityId = listOfId[i];
                varInput.templateId = templateID.ID;
                varJSON.inputs.add(varInput);
            }
        }
        //if input is not empty create JSON
        if(!varJSON.inputs.isEmpty()){
            String JSONString = JSON.serialize(varJSON);
            return JSONString;
        }
        return null;
    }
}