public class CompanyCarRequestHandler {
 /* Start Variables */
    //private static Map<Id, List<CompanyCarRequestHandler>> mapCR;
    //public static Datetime testDatetimeNow;
    
    /* End Variables */
    
    /* start - constructor */ 
    public CompanyCarRequestHandler()
    {
        //Do Nothing
    }
    /* end - constructor */ 
    
    /*
        * MethodName : onBeforeInsert
        * Param      : (nothing)
        * Description: Triggers on before insert 
    */  
    
    public void onBeforeInsert(List<Company_Car_Request__c> lstCRNew)
    {
        //Do Nothing
    }
    /*
        * MethodName : onAfterInsert
        * Param      : (nothing)
        * Description: Triggers on after insert 
    */  
    
    public void onAfterInsert(map<Id , Company_Car_Request__c> mapIdToCRNew)
    {
    
        //call setCRSharingRules
        setCRSharingRules(mapIdToCRNew);
    }
    
    /*
        * MethodName    : onBeforeUpdate
        * Param         :  
        * Description   : 
    */ 
    
    public void onBeforeUpdate(map<Id , Company_Car_Request__c> mapIdToCROld , List<Company_Car_Request__c> lstCRNew)    
    {
      //Do Nothing
    }
    
    /*
        * MethodName : onAfterUpdate
        * Param      : 
        * Description: 
    */ 
    public void onAfterUpdate(map<Id , Company_Car_Request__c> mapIdToCRNew)
    {
      List<Company_Car_Request__Share> sharesToDelete = [SELECT Id FROM Company_Car_Request__Share 
          WHERE ParentId IN :trigger.newMap.keyset() 
            AND RowCause = :Schema.Company_Car_Request__Share.rowCause.Approver_Access__c];
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
    
    public void onBeforeDelete(map<Id , Company_Car_Request__c> mapIdToCROld)
    {
        //Do Nothing
    }
    
    /*
        * MethodName : onAfterDelete
        * Param      :  
        * Description: Triggers on after delete 
    */  
    public void onAfterDelete(map<Id , Company_Car_Request__c> mapIdToCROld)
    {
        //Do Nothing
    }
    
    public void setCRSharingRules(map<Id , Company_Car_Request__c> mapIdToCRNew)
    {     
        //insert shares
        // Create a new list of sharing objects for Job
        List<Company_Car_Request__Share> compCarShrs  = new List<Company_Car_Request__Share>();
        // Declare variables for recruiting and hiring manager sharing
        Company_Car_Request__Share managerShr;
        Company_Car_Request__Share hrmanagerShr;
        Company_Car_Request__Share cbShr;
        Company_Car_Request__Share fleetmanagerShr;
        
        for(Company_Car_Request__c compCar : mapIdToCRNew.values()){
            // Instantiate the sharing objects
           managerShr = new Company_Car_Request__Share();
            hrmanagerShr = new Company_Car_Request__Share();
            cbShr = new Company_Car_Request__Share();
            fleetmanagerShr = new Company_Car_Request__Share();
            
            // Set the ID of record being shared
            managerShr.ParentId = compCar.Id;
            hrmanagerShr.ParentId = compCar.Id;
            cbShr.ParentId = compCar.Id;
            fleetmanagerShr.ParentId = compCar.Id;
            
            
            // Set the ID of user or group being granted access
            managerShr.UserOrGroupId = compCar.Direct_Supervisor__c;
            hrmanagerShr.UserOrGroupId = compCar.HR_Manager__c;
            cbShr.UserOrGroupId = compCar.C_B_International__c;
            fleetmanagerShr.UserOrGroupId = compCar.Car_Fleet_Manager__c;
            
                        
            // Set the access level
            managerShr.AccessLevel = 'Edit';
            hrmanagerShr.AccessLevel = 'Edit';
            cbShr.AccessLevel = 'Edit';
            fleetmanagerShr.AccessLevel = 'Edit';
               
            // Set the Apex sharing reason for hiring manager and recruiter
            managerShr.RowCause = Schema.Company_Car_Request__Share.RowCause.Approver_Access__c;
            hrmanagerShr.RowCause = Schema.Company_Car_Request__Share.RowCause.Approver_Access__c;
            cbShr.RowCause = Schema.Company_Car_Request__Share.RowCause.Approver_Access__c;
            fleetmanagerShr.RowCause = Schema.Company_Car_Request__Share.RowCause.Approver_Access__c;
            
            // Add objects to list for insert
            compCarShrs.add(managerShr);
            compCarShrs.add(hrmanagerShr);
            compCarShrs.add(cbShr);
            compCarShrs.add(fleetmanagerShr);
            
        }
        
        // Insert sharing records and capture save result 
        // The false parameter allows for partial processing if multiple records are passed 
        // into the operation 
        Database.SaveResult[] lsr = Database.insert(compCarShrs,false);
        
    }
}