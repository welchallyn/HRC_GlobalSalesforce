/***********************************************************************************************************************************************
* Name                             :  HRCSVC20_CQ_Backup_Values
* Author                           :  Capgemini
* Date                             :  November'21
* Requirement/Project Name         :  Hill-Rom
* Requirement/Project Description  :  SE-2620
/***********************************************************************************************************************************************/
global class HRCSVC20_CQ_Backup_Values
{
public static Id RecordId;
public static boolean isSuccess;
public static String SobjectName;
public static String FsetName; 
public static List<String> Allfields;
public static map<string,String> AllfieldLabels;    
public static List<HRCSVC20_CQ_Original_Values__c> CQOriginalValues;    
public static Map<String,String> KeyValuepairs;
public static Schema.FieldSet Fset;

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
RecordId = InputValues[0].recId;
FsetName =  InputValues[0].fldsetname;
       
Schema.FieldSet Fset;
KeyValuepairs = new Map<String,String>();
CQOriginalValues = new List<HRCSVC20_CQ_Original_Values__c>();      
SobjectName = RecordId.getSObjectType().getDescribe().getName();
Allfields = new List<String>();
AllfieldLabels = new map<string,String>();
Fset = HRCSVC_Complaint_Qualification__c.sObjectType.getDescribe().fieldSets.getMap().get(FsetName);

HRCSVC_Complaint_Qualification__c a = (HRCSVC_Complaint_Qualification__c) HRCSVC20_Dynamic_Fetch_Field_Values.fetchSobjectValues(RecordId, FsetName,Fset);

AllfieldLabels = HRCSVC20_Dynamic_Fetch_Field_Values.ReturnFieldsetLabels();
for(String s : HRCSVC20_Dynamic_Fetch_Field_Values.ReturnFieldsetFields(FsetName,fset))
{    
HRCSVC20_CQ_Original_Values__c cqorgrec = new HRCSVC20_CQ_Original_Values__c();
if(!String.isblank((String)a.get(s)))
{    
cqorgrec.HRCSVC20_CQ__c= a.id;   
cqorgrec.HRCSVC20_CQ_Key__c= AllfieldLabels.get(s);
system.debug('AllfieldLabels.get(s) ==>'+AllfieldLabels.get(s));    
cqorgrec.HRCSVC20_CQ_Value__c=(string)a.get(s);
CQOriginalValues.add(cqorgrec);
KeyValuepairs.put(s,(string)a.get(s));
}
}
   
   //delete existing cq backup values
   if(recordid != null)
   {
   list<HRCSVC20_CQ_Original_Values__c> deletion = new list<HRCSVC20_CQ_Original_Values__c>([select id from HRCSVC20_CQ_Original_Values__c where HRCSVC20_CQ__c = :recordid]);
   system.debug('deletion ==> '+deletion);
   Delete deletion;
   }
    
   //insert new cq backup values
   Insert CQOriginalValues;
   a.HRCSVC20_Requires_Translation__c = true;
   update a;
   returnresults = new returnmessage();
   returnresults.succerrmsg = System.label.HRCSVC20_CQ_backup_success_message;
   succerrmessage.add(returnresults);

    }   
   catch(exception e)
   {
   returnresults = new returnmessage();
   returnresults.succerrmsg = System.label.HRCSVC20_CQ_backup_error_message;
   succerrmessage.add(returnresults);
   system.debug('e '+e.getMessage());    
   }

  return succerrmessage; 

}
}