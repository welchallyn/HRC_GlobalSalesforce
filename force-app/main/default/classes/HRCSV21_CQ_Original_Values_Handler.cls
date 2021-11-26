/***********************************************************************************************************************************************
* Name                             :  HRCSV21_CQ_Original_Values_Handler
* Author                           :  Capgemini
* Date                             :  November'21
* Purpose                          :  This class handles updates to the Translated values to the corresponding field to the 
									  Parent Complaint Qualification record									  
* Requirement/Project Name         :  Hill-Rom
* Requirement/Project Description  :  SE-2620
/***********************************************************************************************************************************************/

public class HRCSV21_CQ_Original_Values_Handler extends TriggerHandler 
{
public static Schema.FieldSet Fset;

public override void afterupdate()
{
system.debug('HRCSV21_CQ_Original_Values_Handler trigger.newmap '+trigger.newmap.values());    
list<string> fieldapinames = new list<string>();
HRCSVC_Complaint_Qualification__c parentcqrecord; // = new HRCSVC_Complaint_Qualification__c  ();
try{    
        
for (HRCSVC20_CQ_Original_Values__c fldsupdated : [select id,name,HRCSVC20_CQ__c,HRCSVC20_CQ_Key__c,HRCSVC20_CQ_Value__c,HRCSVC20_CQ_API_Name__c,HRCSVC21_CQ_Translation__c from HRCSVC20_CQ_Original_Values__c where id in :trigger.newmap.keyset()])
{
system.debug('PARENT ID '+fldsupdated.HRCSVC20_CQ__c);
Fset = HRCSVC_Complaint_Qualification__c.sObjectType.getDescribe().fieldSets.getMap().get('HRCSVC20_CQ_Translation');
if(parentcqrecord == null)
{
parentcqrecord = new HRCSVC_Complaint_Qualification__c  ();
parentcqrecord = (HRCSVC_Complaint_Qualification__c) HRCSVC20_Dynamic_Fetch_Field_Values.fetchSobjectRecValues(fldsupdated.HRCSVC20_CQ__c,fset);
}
system.debug('parentcqrecord '+parentcqrecord);    
if(!String.isblank(fldsupdated.HRCSVC21_CQ_Translation__c) && (fldsupdated.HRCSVC21_CQ_Translation__c != parentcqrecord.get(fldsupdated.HRCSVC20_CQ_API_Name__c)))
{
system.debug('Field API Name ----> '+fldsupdated.HRCSVC20_CQ_API_Name__c);    
system.debug('Original CQ Field Value ----> '+parentcqrecord.get(fldsupdated.HRCSVC20_CQ_API_Name__c));
parentcqrecord.put(fldsupdated.HRCSVC20_CQ_API_Name__c,fldsupdated.HRCSVC21_CQ_Translation__c);   
system.debug('New Translated Value ------> '+fldsupdated.HRCSVC21_CQ_Translation__c);
system.debug('CQ Backup value -----> '+fldsupdated.HRCSVC20_CQ_Value__c);                
}
}
update parentcqrecord;
}
catch(exception e)
{
 system.debug('Exception in HRCSV21_CQ_Original_Values_Handler --->'+e.getStackTraceString());
}
}

}