@isTest(seealldata=true)
private class ApproverUpdate_Test {


    static testMethod void runTest() {
    Date MyDate = date.newinstance(2012,11,17);
    //string name = [SELECT name FROM Userrole WHERE parentroleid != null and name like 'Account Exe%' limit 1].name;
    //User u1 = [SELECT Id FROM User WHERE Userrole.name=:name limit 1];
    User u1 = [SELECT Id FROM User WHERE Profile.name = 'HRC Account Executive' and isactive = true and userrole.parentroleid != null and createddate < last_n_months:3 limit 1];
            
       // Run As U1
        System.RunAs(u1){
    id newid = [select id from contact limit 1].id;
    system.debug('contactid'+newid);
   id oppid = [select id from opportunity where CRS_OMS_CA__c != null limit 1].id;
       Evaluation_Form__c ef 
         = new Evaluation_Form__c(RDC_location__c = 'Pennsauken',opportunity__c = oppid, Deliver_To__c = 'Customer', N_C_PO_required__c = 'no', Evaluation_Blanket_Agreement_Completed__c = 'yes', 
                                          Rqst_Date_of_Delivery_to_Service_Center__c = mydate,Primary_Contact__c = newid);
       insert ef;   
       
        Products_Requested__c  pr
         = new Products_Requested__c (evaluation_form__C = ef.id, Product_type__C = 'frames',quantity__c = 10);                
       insert pr;
              Evaluation_Form__c ef1 
         = new Evaluation_Form__c(RDC_location__c = 'Chicago',opportunity__c = oppid, Deliver_To__c = 'Customer', N_C_PO_required__c = 'no', Evaluation_Blanket_Agreement_Completed__c = 'yes', 
                                          Rqst_Date_of_Delivery_to_Service_Center__c = mydate,Primary_Contact__c = newid,record_id__c = ef.id);
       insert ef1; 
       ef.RDC_location__c = 'Atlanta';
       update ef;
       ef1.RDC_location__c = 'Dallas';
       update ef1;
      /** Account a = new Account(Name = 'x', JDE_Record_Type__c = 'FACx');
       try{
          insert a;
       }
       catch(Exception e){}**/
    }
}
}