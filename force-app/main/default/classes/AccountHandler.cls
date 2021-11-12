/*
 *  ClassName    : AccountHandler
 *  CreatedOn    : 18/Oct/2016
 *  ModifiedOn   : 25/Jul/2019
 *  CreatedBy    : Jenish Shingala
 *  ModifiedBy   : Doug Lecher
 *  Description  : Used for Handling all events for Accounts (Account).
 *  Modified On 2/Dec/2017 By Erik Siewert: added back in logic for not evaluating person accounts
 *  Modified On 25/Jul/2019 By Doug Lecher: added on Delete method to add entry to Delete_Audit__c Custom object   
 *  Modified On 01/Jun/2020 by Srishti Goyal: To remove CC360 dependencies, replaced DSE__DS_Country_ISO_Code__c with BillingCountry
 */
public with sharing class AccountHandler {
    /* Start Variables */
    private static Map <Id, Account> mapDeletedAccIdToAccount;
    /* End Variables */

    /* constructor */
    public AccountHandler() {
        //Do Nothing
    } 

    /*
     * MethodName : onBeforeInsert
     * Param      : lstAccountNew
     * Description: Triggers on before insert 
     */
    public void onBeforeInsert(List < Account > lstAccountNew) {
            assignAccountRecordTypeFromJDE(lstAccountNew);
             updateRegionalLevels(lstAccountNew);
        }
        /*
         * MethodName : onAfterInsert
         * Param      : lstAccountNew
         * Description: Triggers on after insert 
         */

    public void onAfterInsert(List < Account > lstAccountNew) {
        
        noteAttachInfo(lstAccountNew);
        createEntitlementObjectRecord(lstAccountNew);
    }

    /*
     * MethodName    : onBeforeUpdate
     * Param         : lstAccountNew.
     * Description   : 
     */

    public void onBeforeUpdate(List<Account> lstAccountNew) {
         assignAccountRecordTypeFromJDE(lstAccountNew);
         updateRegionalLevels(lstAccountNew);
    }       
    
    /*
     * MethodName    : onBeforeDelete
     * Param         : lstAccountOld.
     * Description   : 
     */
     
    public void onBeforeDelete(List<Account> lstAccountOld) {
        deleteEntitlementObjectRecord(lstAccountOld);
    }
    /*
     * MethodName    : onAfterDelete
     * Param         : lstAccountOld.
     * Description   : 
     */
     
    public void onAfterDelete(List<Account> lstAccountOld) {
        deleteAuditLog(lstAccountOld);
    }
      
    /*  
        Code from previous trigger(Trigger Name:noteAttachInfo).
    */
    public void noteAttachInfo(List < Account > lstAccountNew) {
        List < Additional_Info__c > natToInsert = new List < Additional_Info__c > ();
        for (Account a: lstAccountNew) {
            if (a.Name != '') {
                Additional_Info__c objAdditionalInfo = new Additional_Info__c();
                objAdditionalInfo.Account__c = a.id;
                objAdditionalInfo.Name = 'Notes and Attachments';
                natToInsert.add(objAdditionalInfo);
            }
        }
        try {
            insert natToInsert;
        } catch (system.Dmlexception e) {
            system.debug(e);
        }
    }

    /*  
        Code from previous trigger(Trigger Name:assignAccountRecordTypeFromJDE).
        updated Clayton config, "FromJDE" in method name should now be a Warning not an Error. 
    */
    public void assignAccountRecordTypeFromJDE(List < Account > lstAccountNew) {
        string logedInUser = UserInfo.getName();
        string usersName = 'Data FromJDE';
        for (Account a: lstAccountNew){
            try{
            if (a.JDE_Record_Type__c != null && Account_Record_Type_Ids__c.getInstance(a.JDE_Record_Type__c) != null && logedInUser == usersName){
                a.recordTypeId = Account_Record_Type_Ids__c.getInstance(a.JDE_Record_Type__c).RecordTypeId__c;
            }
                
            }
            catch(Exception e){
                system.debug('Exception Occurred..'+e);
                a.addError(e);
            }
        }
    }
    
        /*Code to map Regional_Level_1__c and Regional_Level_2__c according to DSE__DS_Country_ISO_Code__c*/
        //Modified below code by Srishti on 01/Jun/2020 to use BilingCountry instead of DSE__DS_Country_ISO_Code__c
        
        public void updateRegionalLevels(List <Account> lstAccountNew){
            try{
                Map<string,string> mapOfCountryCodeRegion = new Map<string,string>();
                List<International_Country_Code_Mapping__mdt> lstOfCountryCodeMapping = [SELECT DeveloperName,Label,Region_and_Area__c FROM International_Country_Code_Mapping__mdt LIMIT 250];
                if(lstOfCountryCodeMapping!=null && lstOfCountryCodeMapping.size()>0){
                    for(International_Country_Code_Mapping__mdt objCountryCode:lstOfCountryCodeMapping){
                        mapOfCountryCodeRegion.put(objCountryCode.Label,objCountryCode.Region_and_Area__c);
                    }
                }
                ID personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
                
                for(Account objAccount:lstAccountNew){
                        system.debug('Map of Country Codes-->'+mapOfCountryCodeRegion);
                        //don't map person accounts
                        if(personAccountRecordTypeId!=null && mapOfCountryCodeRegion!=null && objAccount.BillingCountry!=null 
                           && objAccount.recordtypeid!=personAccountRecordTypeId){
                            String regionAndArea = mapOfCountryCodeRegion.get(objAccount.BillingCountry);
                            if(regionAndArea!=null && regionAndArea!=''){
                                List<String> lstRegionAndArea = regionAndArea.split(';');
                                if(lstRegionAndArea!=null && lstRegionAndArea.size()>0){
                                        system.debug('Region And Area-->'+lstRegionAndArea);
                                        objAccount.Regional_Level_1__c = lstRegionAndArea[0];
                                        objAccount.Regional_Level_2__c = lstRegionAndArea[1];
                                        system.debug(objAccount.Regional_Level_1__c+'----'+objAccount.Regional_Level_2__c);
                                  
                                }
                            }
                        }
                    
                }
            }
            catch(Exception e){
                system.debug('EXCEPTION===>'+e.getmessage());
            }
            
        }
        
    public void validation(List<Account> lstaccount){
        Profile p=[select id, name from Profile where name='WA Standard User'];
        User Usr=new User();
        Usr = [SELECT  Id,ProfileId FROM User WHERE Id = : UserInfo.getUserId()];
        for(account a:lstaccount){
            if(Usr.ProfileId==p.Id){
                
            }
        }
    }
        /* Code to create an Entitlement Object Record after the insert of an Account Object Record.*/
     
        public void createEntitlementObjectRecord(List < Account > lstAccountNew)
        {
            SlaProcess entitlementProcessRecord = [SELECT Id FROM SlaProcess where name='Standard Hill-Rom Support' limit 1];
            BusinessHours businessHoursRecord = [SELECT Id FROM BusinessHours where name = 'Hill-Rom Batesville, IN'];
            List< Entitlement > entitlementRecordsToInsert = new List< Entitlement > ();
            String personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            
            for(Account objAccount: lstAccountNew)
            {
              if(personAccountRecordTypeId!=null && personAccountRecordTypeId!='' && objAccount.recordtypeid!=personAccountRecordTypeId){
                   Entitlement createNewEntitlementRecord = new Entitlement();
                   createNewEntitlementRecord.StartDate = Date.today();
                   createNewEntitlementRecord.EndDate = null;
                   createNewEntitlementRecord.Type = 'Email Support';
                   createNewEntitlementRecord.Name = 'Standard Hill-Rom Entitlement';
                   if(businessHoursRecord!=null)
                     createNewEntitlementRecord.BusinessHoursId = businessHoursRecord.Id;
                   if(entitlementProcessRecord!=null)
                       createNewEntitlementRecord.SlaProcessId = entitlementProcessRecord.Id;
                   createNewEntitlementRecord.accountid = objAccount.id;
                   entitlementRecordsToInsert.add(createNewEntitlementRecord);
              }
               
                
            }
            try
            {   
                if(entitlementRecordsToInsert!=null && entitlementRecordsToInsert.size()>0)
                    insert entitlementRecordsToInsert;
            }
            catch(system.Dmlexception bulkDMLexception)
            {
                system.debug('DML Exception -' +bulkDMLexception.getmessage());
            }
            
        }
        
        /* Code to delete all corresponding Entitlement Object Records when their respective Account Object Records are deleted.*/
        
        public void deleteEntitlementObjectRecord(List < Account > lstAccountOld)
        {
            List< Entitlement > entitlementRecordsToDelete = new List<Entitlement>();
            Set<id> parentIds = new Set<id>();
            
            for(Account objAccount:lstAccountOld){
                parentIds.add(objAccount.id);
            }
            
            entitlementRecordsToDelete = [SELECT Id from Entitlement where AccountId in :parentIds];
            
            try
            {
                if(entitlementRecordsToDelete!=null && entitlementRecordsToDelete.size()>0)
                    delete entitlementRecordsToDelete;
            }
            catch(system.Dmlexception bulkDMLexception)
            {
                system.debug('DML Exception -' +bulkDMLexception.getmessage());
            }
        }
    /*
        * MethodName : createdeleteAuditLog
        * Param      : Audit Type
        * Description: Create new Delete_Audit__c record when an Account is delted
    */
    public void deleteAuditLog(List <Account> lstAccountold)
    {
        List <delete_audit__c> lstAcct = new list <delete_audit__c>();
        for (Account toReltio:lstAccountold){
            delete_audit__c objdeleteaudit = new delete_audit__c();
            objdeleteaudit.Deleted_SFDCID__c = toReltio.id;
            objdeleteaudit.name = toReltio.name;
            objdeleteaudit.shippingstreet__c = toReltio.BillingStreet;
            objdeleteaudit.shippingcity__c = toReltio.BillingCity;
            objdeleteaudit.shippingstatecode__c = toreltio.billingstate;
            objdeleteaudit.shippingpostalcode__c = toreltio.BillingPostalCode;
            objdeleteaudit.shippingcountrycode__c = toreltio.billingcountry;
            lstAcct.add(objdeleteaudit);
        }
    
        try {
            insert lstAcct;
        } catch (system.Dmlexception err) {
            system.debug(err);
        }
    }
}