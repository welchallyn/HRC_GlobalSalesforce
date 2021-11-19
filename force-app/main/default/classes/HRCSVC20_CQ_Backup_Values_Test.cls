/***********************************************************************************************************************************************
* Name                             :  HRCSVC20_CQ_Backup_Values_Test
* Author                           :  Capgemini
* Date                             :  November'21
* Requirement/Project Name         :  Hill-Rom
* Requirement/Project Description  :  SE-2620 test class for HRCSVC20_CQ_Backup_Values and HRCSVC20_Dynamic_Fetch_Field_Values
/***********************************************************************************************************************************************/


@isTest
public class HRCSVC20_CQ_Backup_Values_Test {

    @isTest
    public static void backupValueandDynamicValueTest(){
       HRCSVC20_CQ_Backup_Values baValues= new HRCSVC20_CQ_Backup_Values() ;
        HRCSVC_Complaint_Qualification__c cq= new HRCSVC_Complaint_Qualification__c(HRCSVC_Aware_Date__c=system.today(),HRCSVC_Status__c='Qualified Complaint',HRCSVC_Injury_or_Death__c='Death');
        /*cq.HRCSVC_Aware_Date__c=system.today();
        cq.HRCSVC_Status__c='Qualified Complaint';
        cq.HRCSVC_Injury_or_Death__c='Death';*/
        insert cq;
       List< HRCSVC20_CQ_Backup_Values.BackupCQValues> bcqList= new List<HRCSVC20_CQ_Backup_Values.BackupCQValues>();
            HRCSVC20_CQ_Backup_Values.BackupCQValues bcq= new HRCSVC20_CQ_Backup_Values.BackupCQValues();
        HRCSVC20_CQ_Backup_Values.returnmessage rm = new  HRCSVC20_CQ_Backup_Values.returnmessage();
        rm.succerrmsg='';
           bcq.recId=cq.id;
            bcq.fldsetname='HRCSVC20_CQ_Translation';
           bcqList.add(bcq);
        HRCSVC20_CQ_Backup_Values.HRCSVC20_CQ_Backup_Values(null);
        HRCSVC20_CQ_Backup_Values.HRCSVC20_CQ_Backup_Values(bcqList);
    }
    
    
}