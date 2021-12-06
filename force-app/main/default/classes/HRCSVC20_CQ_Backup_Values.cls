/***********************************************************************************************************************************************
* Name                             :  HRCSVC20_CQ_Backup_Values
* Author                           :  Capgemini
* Date                             :  November'21
* Purpose                          :  This Trigger will update the translated value to the Parent Complaint Qualification record, 
									  All the logic is handled in the HRCSV21_CQ_Original_Values_Handler Apex Class
									  This event only happens on the AfterUpdate trigger
* Requirement/Project Name         :  Hill-Rom
* Requirement/Project Description  :  SE-2620
/***********************************************************************************************************************************************/
global class HRCSVC20_CQ_Backup_Values
{
public static Id RecordId;
public static boolean isSuccess;
public static String SobjectName;
public static String FsetName; 
public static List<HRCSVC20_CQ_Original_Values__c> CQOriginalValues;    
public static List<HRCSVC20_CQ_Original_Values__c> DeleteCQOriginalValues;        
public static Schema.FieldSet Fset;
public static Map<String,HRCSVC20_CQ_Original_Values__c> Map_CQ_Backup;          
    
global class BackupCQValues
{ 
    
@InvocableVariable(required=true)
global Id recId;
    
@InvocableVariable(required=true)
global String fldsetname;

}

global class returnmessage
{ 
@InvocableVariable
global String succerrmsg;
}

@InvocableMethod(label='Update CQ Original Values' description='Update CQ Original Values' category='Account')
public static list<returnmessage> HRCSVC20_CQ_Backup_Values(List<BackupCQValues> InputValues)    

{    
returnmessage returnresults = new returnmessage();    
list<returnmessage> succerrmessage = new list<returnmessage>();
try
{
Map_CQ_Backup = new Map<String,HRCSVC20_CQ_Original_Values__c>();    
RecordId = InputValues[0].recId;
FsetName =  InputValues[0].fldsetname;
Id RecordTypeId = Schema.SObjectType.HRCSVC20_CQ_Original_Values__c.getRecordTypeInfosByName().get('CQ Original').getRecordTypeId();
Schema.FieldSet Fset;
CQOriginalValues = new List<HRCSVC20_CQ_Original_Values__c>();      
DeleteCQOriginalValues = new List<HRCSVC20_CQ_Original_Values__c>();      
SobjectName = RecordId.getSObjectType().getDescribe().getName();
Fset = HRCSVC_Complaint_Qualification__c.sObjectType.getDescribe().fieldSets.getMap().get(FsetName);

HRCSVC_Complaint_Qualification__c a = (HRCSVC_Complaint_Qualification__c) HRCSVC20_Dynamic_Fetch_Field_Values.fetchSobjectRecValues(RecordId, Fset);

for(HRCSVC_Complaint_Qualification__c val : [select id,(select id,HRCSVC20_CQ__c,HRCSVC20_CQ_Key__c,HRCSVC20_CQ_Value__c,HRCSVC20_CQ_API_Name__c,HRCSVC21_CQ_Translation__c,CQ_External_Id__c from CQ_Original_Values__r) from HRCSVC_Complaint_Qualification__c where id = :RecordId])
{
for(HRCSVC20_CQ_Original_Values__c bkuprec : val.CQ_Original_Values__r)    
{
Map_CQ_Backup.put(bkuprec.HRCSVC20_CQ_API_Name__c,bkuprec);    
}
}

for(String s : HRCSVC20_Dynamic_Fetch_Field_Values.ReturnFieldsetFields(FsetName,fset).keyset())
{    
HRCSVC20_CQ_Original_Values__c cqorgrec = new HRCSVC20_CQ_Original_Values__c();
if(s != 'Name')
{
if(Map_CQ_Backup.containsKey(s) && (string)a.get(s) != null && (Map_CQ_Backup.get(s).HRCSVC20_CQ_Value__c != null || Map_CQ_Backup.get(s).HRCSVC21_CQ_Translation__c != null) && (((string)a.get(s)) != (Map_CQ_Backup.get(s).HRCSVC20_CQ_Value__c)) && ((string)a.get(s) != (Map_CQ_Backup.get(s).HRCSVC21_CQ_Translation__c)))    
{
cqorgrec = Map_CQ_Backup.get(s);
cqorgrec.HRCSVC20_CQ_Value__c=(string)a.get(s);
cqorgrec.HRCSVC21_CQ_Translation__c='';    
CQOriginalValues.add(cqorgrec);
}

if(!String.isblank((String)a.get(s)) && !Map_CQ_Backup.containskey(s))
{    
cqorgrec.HRCSVC20_CQ__c= a.id;   
cqorgrec.Name= a.name;       
cqorgrec.CQ_External_Id__c = a.name+'-'+s;
cqorgrec.HRCSVC20_CQ_Key__c= (HRCSVC20_Dynamic_Fetch_Field_Values.ReturnFieldsetFields(FsetName,fset).get(s)).getlabel();    
cqorgrec.HRCSVC20_CQ_API_Name__c =s; 
cqorgrec.recordtypeid = RecordTypeId;
cqorgrec.HRCSVC20_CQ_Value__c=(string)a.get(s);
CQOriginalValues.add(cqorgrec);
}
    
if(Map_CQ_Backup.containsKey(s) && (string)a.get(s) == null)
{
cqorgrec = Map_CQ_Backup.get(s);       
DeleteCQOriginalValues.add(cqorgrec);  
}
} // Name field ignore    
}
   
if(DeleteCQOriginalValues.size() >0)
{   
system.debug('DeleteCQOriginalValues ==>'+DeleteCQOriginalValues);
delete DeleteCQOriginalValues;
}
    
if(CQOriginalValues.size() >0)
{   
system.debug('CQOriginalValues ==>'+CQOriginalValues);
upsert CQOriginalValues CQ_External_Id__c;   
}

   returnresults = new returnmessage();
   returnresults.succerrmsg = System.label.HRCSVC20_CQ_backup_success_message;
   succerrmessage.add(returnresults);

    }   
   catch(exception e)
   {
   returnresults = new returnmessage();
   returnresults.succerrmsg = System.label.HRCSVC20_CQ_backup_error_message;
   succerrmessage.add(returnresults);
   system.debug('e '+e.getStackTraceString());    
   }

  return succerrmessage; 

}
}