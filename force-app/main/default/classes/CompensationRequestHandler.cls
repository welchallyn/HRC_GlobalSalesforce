/*
    *  ClassName    : CompensationRequestHandler
    *  CreatedOn    : 29/June/2016
    *  ModifiedOn   : 29/June/2016
    *  CreatedBy    : Erik Siewert (& Salesforce Team!)
    *  ModifiedBy   : Erik Siewert (& Salesforce Team!)
    *  Description  : Used for Handling all events for Compensation Requests (Compensation_Request__c). 
*/
public class CompensationRequestHandler 
{
    /* Start Variables */
    //private static Map<Id, List<CompensationRequestHandler>> mapCR;
    //public static Datetime testDatetimeNow;
    
    /* End Variables */
    
    /* start - constructor */ 
    public CompensationRequestHandler()
    {
        //Do Nothing
    }
    /* end - constructor */ 
    
    /*
        * MethodName : onBeforeInsert
        * Param      : (nothing)
        * Description: Triggers on before insert 
    */  
    
    public void onBeforeInsert(List<Compensation_Request__c> lstCRNew)
    {
        //Do Nothing
    }
    /*
        * MethodName : onAfterInsert
        * Param      : (nothing)
        * Description: Triggers on after insert 
    */  
    
    public void onAfterInsert(map<Id , Compensation_Request__c> mapIdToCRNew)
    {
		
        //call setCRSharingRules
        setCRSharingRules(mapIdToCRNew);
    }
    
    /*
        * MethodName    : onBeforeUpdate
        * Param         :  
        * Description   : 
    */ 
    
    public void onBeforeUpdate(map<Id , Compensation_Request__c> mapIdToCROld , List<Compensation_Request__c> lstCRNew)    
    {
      //Do Nothing
    }
    
    /*
        * MethodName : onAfterUpdate
        * Param      : 
        * Description: 
    */ 
    public void onAfterUpdate(map<Id , Compensation_Request__c> mapIdToCRNew)
    {
    	List<Compensation_Request__Share> sharesToDelete = [SELECT Id FROM Compensation_Request__Share 
        	WHERE ParentId IN :trigger.newMap.keyset() 
            AND RowCause = :Schema.Compensation_Request__Share.rowCause.Approver_Access__c];
		if(!sharesToDelete.isEmpty()){
    		Database.Delete(sharesToDelete, false);
	    }

        //call setCRSharingRules
        setCRSharingRules(mapIdToCRNew);
  
    }
    
    /*
        * MethodName : onBeforeDelete
        * Param      :  
        * Description: Triggers on before delete 
    */ 
    
    public void onBeforeDelete(map<Id , Compensation_Request__c> mapIdToCROld)
    {
        //Do Nothing
    }
    
    /*
        * MethodName : onAfterDelete
        * Param      :  
        * Description: Triggers on after delete 
    */  
    public void onAfterDelete(map<Id , Compensation_Request__c> mapIdToCROld)
    {
        //Do Nothing
    }
    
    public void setCRSharingRules(map<Id , Compensation_Request__c> mapIdToCRNew)
    {     
        //insert shares
        // Create a new list of sharing objects for Job
        List<Compensation_Request__Share> cafShrs  = new List<Compensation_Request__Share>();
        // Declare variables for recruiting and hiring manager sharing
        Compensation_Request__Share managerShr;
        Compensation_Request__Share nextmanagerShr;
        Compensation_Request__Share gmShr;
        Compensation_Request__Share hrmanagerShr;
        Compensation_Request__Share sltShr;
        Compensation_Request__Share cbShr;
        Compensation_Request__Share svpShr;
        Compensation_Request__Share execdirShr;
        Compensation_Request__Share vphrShr;
        
        for(Compensation_Request__c caf : mapIdToCRNew.values()){
            // Instantiate the sharing objects
            managerShr = new Compensation_Request__Share();
            nextmanagerShr = new Compensation_Request__Share();
            gmShr = new Compensation_Request__Share();
            hrmanagerShr = new Compensation_Request__Share();
            sltShr = new Compensation_Request__Share();
            cbShr = new Compensation_Request__Share();
            svpShr = new Compensation_Request__Share();
            execdirShr = new Compensation_Request__Share();
            vphrShr = new Compensation_Request__Share();
            
            // Set the ID of record being shared
            managerShr.ParentId = caf.Id;
            nextmanagerShr.ParentId = caf.Id;
            gmShr.ParentId = caf.Id;
            hrmanagerShr.ParentId = caf.Id;
            sltShr.ParentId = caf.Id;
            cbShr.ParentId = caf.Id;
            svpShr.ParentId = caf.Id;
            execdirShr.ParentId = caf.Id;
            vphrShr.ParentId = caf.Id;
            
            
            // Set the ID of user or group being granted access
            managerShr.UserOrGroupId = caf.Employee_s_Manager__c;
            nextmanagerShr.UserOrGroupId = caf.Next_Level_Manager__c;
            gmShr.UserOrGroupId = caf.GM_VP__c;
            hrmanagerShr.UserOrGroupId = caf.HR_Manager_Director__c;
            sltShr.UserOrGroupId = caf.SLT_ELT__c;
            cbShr.UserOrGroupId = caf.Sr_Comp_Ben_Manager__c;
            svpShr.UserOrGroupId = caf.SVP_HR__c;
            execdirShr.UserOrGroupId = caf.Total_Rewards_Exec_Director__c;
            vphrShr.UserOrGroupId = caf.VP_HR_International__c;
            
                        
            // Set the access level
            managerShr.AccessLevel = 'Edit';
            nextmanagerShr.AccessLevel = 'Edit';
            gmShr.AccessLevel = 'Edit';
            hrmanagerShr.AccessLevel = 'Edit';
            sltShr.AccessLevel = 'Edit';
            cbShr.AccessLevel = 'Edit';
            svpShr.AccessLevel = 'Edit';
            execdirShr.AccessLevel = 'Edit';
            vphrShr.AccessLevel = 'Edit';
               
            // Set the Apex sharing reason for hiring manager and recruiter
            managerShr.RowCause = Schema.Compensation_Request__Share.RowCause.Approver_Access__c;
            nextmanagerShr.RowCause = Schema.Compensation_Request__Share.RowCause.Approver_Access__c;
            gmShr.RowCause = Schema.Compensation_Request__Share.RowCause.Approver_Access__c;
            hrmanagerShr.RowCause = Schema.Compensation_Request__Share.RowCause.Approver_Access__c;
            sltShr.RowCause = Schema.Compensation_Request__Share.RowCause.Approver_Access__c;
            cbShr.RowCause = Schema.Compensation_Request__Share.RowCause.Approver_Access__c;
            svpShr.RowCause = Schema.Compensation_Request__Share.RowCause.Approver_Access__c;
            execdirShr.RowCause = Schema.Compensation_Request__Share.RowCause.Approver_Access__c;
            vphrShr.RowCause = Schema.Compensation_Request__Share.RowCause.Approver_Access__c;
            
            // Add objects to list for insert
            cafShrs.add(managerShr);
            cafShrs.add(nextmanagerShr);
            cafShrs.add(gmShr);
            cafShrs.add(hrmanagerShr);
            cafShrs.add(sltShr);
            cafShrs.add(cbShr);
            cafShrs.add(svpShr);
            cafShrs.add(execdirShr);
            cafShrs.add(vphrShr);
            
        }
        
        // Insert sharing records and capture save result 
        // The false parameter allows for partial processing if multiple records are passed 
        // into the operation 
        Database.SaveResult[] lsr = Database.insert(cafShrs,false);
        
    }
}