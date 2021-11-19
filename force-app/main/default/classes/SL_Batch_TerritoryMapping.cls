/**
    *  Class Name     : SL_Batch_TerritoryMapping
    *  Test Class     : SL_RunBatchController_test
    *  Ticket No.     : WADVDSC-3,7
    *  CreatedBy      : Nrusingh
    *  ModifiedBy     : ESiewert
    *  ModifiedOn     : 18/Dec/2018
    *  Description    : The batch is used used for Territory Mapping
    *  Modification   : By Doug Lecher on April 2020, Edited for Merged Org fields/settings
    *  Modification   : By Srishti Goyal on 13th May 2020, Org Merge changes    
*/
global with sharing class SL_Batch_TerritoryMapping implements Schedulable, Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts
{
    global List<Account> lstAccountToCallout = new List<Account>(); 
    global  Set <Id> setAccId = new Set <Id> ();
    global List<Account> lstMergedAccount = new List<Account>();
    /* Start - Constructor */
    global SL_Batch_TerritoryMapping()
    {
        //Do Nothing
    }
    /* End - Constructor */


    global static String scheduleTerritoryMapping(String scheduleString) {

        String schedString = '0 0 23 * * ?';
        if (String.isNotEmpty(scheduleString)){
            schedString = scheduleString;
        }
        

        SL_Batch_TerritoryMapping scjob = new SL_Batch_TerritoryMapping(); 
        return System.schedule('Territory Mapping Batch', schedString, scjob);

    }
     
    /*!
        * MethodName : start
        * param      : Database.BatchableContext
        * Description: This is the start method to pass the query records to execute method
    */
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {   
        Id AccountRecordTypeId;
        // Fetching Customer Record type
        for (RecordType objRecordType : [SELECT Id FROM RecordType WHERE DeveloperName = 'Facility' AND sobjecttype='Account' LIMIT 1])
        {
            AccountRecordTypeId = objRecordType.Id;
        }      
        //COMMENTOUT-ERS-09012015-String strQuery = 'SELECT Id, ShippingPostalCode, Market_Segment__c, ShippingCountry, Region__c, Territory__c, Inside_Sales__c, Solution_Architect__c FROM Account WHERE (RecordTypeId =: AccountRecordTypeId AND ShippingPostalCode !=null AND(ShippingCountry IN (\'US\',\'CA\')  AND  Market_Segment__c IN (\'Acute\',\'Ambulatory\')))';
        String strQuery = 'SELECT Id, BillingPostalCode, Market_Segment_WA__c, Market_Segments__c, Type, BillingCountry, Region__c, Territory__c, Inside_Sales__c, Solution_Architect__c, Acute_Mortara_Territory__c FROM Account WHERE (RecordTypeId =: AccountRecordTypeId AND BillingPostalCode !=null AND(BillingCountry IN(\'US\',\'United States\') AND  Market_Segment_WA__c IN (\'Acute\',\'Ambulatory\',\'System\')))';
        
        return Database.getQueryLocator(strQuery);      
    }
    
     global void execute(SchedulableContext SC) 
     {
        Database.executeBatch(new SL_Batch_TerritoryMapping(),20); 
     }

     /*!
        * MethodName : execute
        * param      : Database.BatchableContext and list of sobject records
        * Description: Call SL_AccountMappingFromPostalCode for mapping
    */
     global void execute(Database.BatchableContext BC, List<Account> scope) 
     {
        
        List<Account> lstAccount = new List<Account>();//list of Account records that needs to be iterated
        lstAccount.addAll((List<Account>) scope);
        Set <String> setBillingPostalCode = new Set <String> ();
        List <Account> lstAccountToBeUpdated = new List <Account> (); 
        
        // Iterating through the list of account
        for(Account objAccount : lstAccount)
        {
            if(objAccount.BillingCountry == 'US' || objAccount.BillingCountry =='United States')// || objAccount.ShippingCountry == 'CA') //**Canada no longer in WA Org
            {
                setBillingPostalCode.add(objAccount.BillingCountry == 'CA' && objAccount.BillingPostalCode.length()>= 3 ? objAccount.BillingPostalCode.substring(0,3): objAccount.BillingCountry == 'United States' && objAccount.BillingPostalCode!= null && objAccount.BillingPostalCode.length() >= 5? objAccount.BillingPostalCode.substring(0,5):  objAccount.BillingCountry == 'US' && objAccount.BillingPostalCode!= null && objAccount.BillingPostalCode.length() >= 5? objAccount.BillingPostalCode.substring(0,5) : null );
            }
        }
        
        // Calling SL_AccountMappingFromPostalCode class for mapping to Account From Postal code
        lstAccountToBeUpdated = SL_AccountMappingFromPostalCode.fetchPostalCode(setBillingPostalCode, lstAccount);
        
        // Upating Account
        if(!lstAccountToBeUpdated.isEmpty())
        {
            Database.SaveResult[] lstDBSaveResult = Database.update(lstAccountToBeUpdated, false);//updating the existing Accounts*/
            
            /* updates for WADVDSC-7*/
            for(Database.SaveResult sr :lstDBSaveResult)
            {
                if(sr.isSuccess())
                    lstAccountToCallout.add(new Account(Id = sr.getId()));
            }
            
        }
     }
     
     /*!
        * MethodName : finish
        * param      : Database.BatchableContext
        * Description: This is the finish method of this batch process
    */
     global void finish(Database.BatchableContext BC)
     {
        if(!lstAccountToCallout.isEmpty())
        {
            // Calling SL_Batch_TerritoryRuleRealignment batch with 200 chunks
            Database.executeBatch(new SL_Batch_TerritoryRuleRealignment(lstAccountToCallout),20);
        }
    }
}