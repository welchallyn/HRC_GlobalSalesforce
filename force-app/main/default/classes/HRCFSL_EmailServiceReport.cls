/***********************************************************************************************
* Class Name                       : HRCFSL_EmailServiceReport
* Author                           : Matt Prorok
* Date                             : 2019-08-06
* Requirement/Project Name         : Hill-Rom
* Requirement/Project Description  : Invocable apex class to
*                                  1. send the FSL service report to ImageNow (HF-109)
*                                  
* Revision                         : 1. Created a parameterised constructor for wrapper emailParams by Ops Excellence on 13th Nov 2020
************************************************************************************************/
public class HRCFSL_EmailServiceReport 
{
    public class emailParams
    {
        @InvocableVariable(label='Email To')
        public String emailAddress;
        @InvocableVariable(label = 'Service Report Id')
        public string srId;
        @InvocableVariable(label= 'File Delimiter')
        public string delimiter;
        
        public emailParams(){
        }
        
        /**Below code was added by Birlasoft Ops Excellence on 13th Nov 2020
        Purpose: Use the wrapper in Batch Apex - HRCFSL_BatchClassForServiceReports
        **/
        public emailParams(String emailAddress, String srId, String delimiter){
            this.emailAddress = emailAddress;
            this.srId         = srId;
            this.delimiter    = delimiter;
        }
    }
     
    @InvocableMethod (label='Email Service Report')
    public static list<ID> emailServiceReport(List<emailParams> params)
    {
        
        //get the list of fields which should be included in the service report file name
        HRCFSL_Organization_Settings__mdt ServiceReportNameFields = [select HRCFSL_Component_Detail__c from HRCFSL_Organization_Settings__mdt
                                                                     where DeveloperName = 'HRCFSL_Service_Report_File_Name'];
      HRCFSL_Organization_Settings__mdt reportEmailAddress     = [SELECT HRCFSL_Component_Detail__c FROM HRCFSL_Organization_Settings__mdt WHERE DeveloperName = 'HRCFSL_Service_Report_Email_Address'];
       HRCFSL_Organization_Settings__mdt serviceReportDelimiter = [SELECT HRCFSL_Component_Detail__c FROM HRCFSL_Organization_Settings__mdt WHERE DeveloperName = 'HRCFSL_Service_Report_Delimiter'];
        list<ID> successReportIds = new list<ID>();
        List<Messaging.SingleEmailMessage> emails = new List<messaging.SingleEmailMessage>();
        List<HRCFSL_Service_Report_Event__e> srEvents = new List<HRCFSL_Service_Report_Event__e>();
        String fromEmail = UserInfo.getUserEmail();
      map<Id,String> mapSAfieldName = new map<Id,String>();
     
      
        list<serviceReport> lssr = new list<serviceReport>();
        list<Id> lssrIds = new list<Id>();
        for (emailParams e: params){
            
            lssrIds.add(e.srId);
            
        }
       lssr = [select id, parentid, documentbody from ServiceReport where id in: lssrIds];
       list<Id> lssaIds = new list<Id>();
       Map<Id,Id> mapSRSA= new Map<Id,Id>();
        for(ServiceReport sr:lssr){
             lssaIds.add(sr.ParentId);
            mapSRSA.put(sr.ParentId,sr.Id);
        }
        list<serviceAppointment> lssa = new list<serviceAppointment>();
         List<String> fieldNames1 = ServiceReportNameFields.HRCFSL_Component_Detail__c.split(',');
        String WOfieldNames='';
        for(String fn:fieldNames1){
            WOfieldNames += 'HRCFSL_Work_Order__r.'+fn+',';
        }
        String invIds='';
        if (lssaIds <> null && !lssaIds.isEmpty()){
                     invIds = '(';
                    for(String invId : lssaIds){
                        if(invIds == '('){
                            invIds = invIds + '\'' + invId + '\'';
                        }else{
                            invIds = invIds + ',\'' + invId + '\'';
                        }
                    }
                    invIds = invIds + ')';               
                    }                   
                    String whereclause = ' WHERE Id IN ' + invIds;
        System.debug('WOfieldNames>>>'+WOfieldNames);
        WOfieldNames = WOfieldNames.removeEnd(',');
        String SAquery  = 'Select Id,' + WOfieldNames + ' from ServiceAppointment'+whereclause;
        
        system.debug('SAquery>>'+SAquery);
        List<sObject> sobjs = database.query(SAquery);
        for (sObject sobj: sobjs)
                {
                    String fileName = '';
                    Map<String, Object> fieldsMap1 = sobj.getPopulatedFieldsAsMap();
                    
                    workOrder obj = (workOrder)fieldsMap1.get('HRCFSL_Work_Order__r');
                    Map<String, Object> fieldsMap  = obj.getPopulatedFieldsAsMap();
                    system.debug('fieldsMap>>'+fieldsMap);
                    List<String> fieldNames = ServiceReportNameFields.HRCFSL_Component_Detail__c.split(',');
                    
                    //iterate over each field which was defined in the initial list of fields in the custom metadata
                    for (String fieldName : fieldNames)
                    {
                        //if the field is present in the list of values returned from the query then append it to the filename string which is being built. NOTE: if a 
                        //field is blank/null, this field will NOT exist in the fieldsMap object. only fields which are populated will exist
                        if (fieldsMap.containsKey(fieldName))
                        {
                            //separate logic for the date field
                            if (fieldName.contains('Actual_End'))
                            {
                                DateTime d = (DateTime) Obj.get(fieldName);
                                fileName += d.format('yyyy-MM-dd').replaceAll('-', '\\$');
                            }
                            else
                                fileName += (Obj.get(fieldName) + serviceReportDelimiter.HRCFSL_Component_Detail__c);
                        }
                        //if the field doesn't exist in the map of populated fields, we still need to insert a lone delimiter   
                        else fileName += serviceReportDelimiter.HRCFSL_Component_Detail__c;
                    
         
    } 
                      System.debug('fileName>>'+fileName);
                          fileName = fileName.replaceAll('[\\\\/:*?\"<>\\|]', '');
                     
         System.debug('fileName>>'+fileName);
            mapSAfieldName.put(sobj.Id,fileName);
                }
         
        for(ID SA:lssaIds) {   
        HRCFSL_Service_Report_Event__e sre = new HRCFSL_Service_Report_Event__e();
            
            String Servicereport='';
           Servicereport= mapSAfieldName.get(SA)+'.pdf';
         
                    sre.HRCFSL_Email_Body__c = 'Here is a new Service Report';
                    sre.HRCFSL_Email_Subject__c = 'New Service Report';
                    
                    successReportIds.add(mapSRSA.get(SA));
                    sre.HRCFSL_To_Address__c = reportEmailAddress.HRCFSL_Component_Detail__c;
                    sre.HRCFSL_Service_Report_Id__c = mapSRSA.get(SA);
                    sre.HRCFSL_File_Name__c = Servicereport;
                    sre.HRCFSL_From_Address__c = 'mulesoft@hillrom.com';
                    srEvents.add(sre);
        }
        
        List<Database.SaveResult> results = EventBus.publish(srEvents);
        system.debug('resultssize>>'+results.size());
  
         system.debug('results>>'+results);
       
                     
        System.debug('successReportIds>>'+successReportIds);
            
                
        return successReportIds;
}
}