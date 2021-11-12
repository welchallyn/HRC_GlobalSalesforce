/**
*  Trigger Name   : SL_TerritoryMappingHandler
*  CreatedOn      : 15/MAY/2015
*  ModifiedBy     : Nrusingh 
*  Description    : The handler is used for Territory Mapping
*  Changed        : Market_Segment__c to Market_Segments__c

*/

public with sharing class SL_TerritoryMappingHandler 
{
    /* Constructor */
    public SL_TerritoryMappingHandler(){}
    
    /*
    * MethodName   : onAfterInsert 
    * param        : trigger.newMap
    * Description  : Method called on After Insert of Account. 
                    fetchPostalCodeMapping method is called to fetch the Postal_Code_Mapping objects based on the Account shipping Postal Code and map certain fields to Account
    */
    public void OnAfterInsert(Map<Id, Account> mapAccount_New)
    {
        // Calling fetchPostalCode_MappingToAccount method
        fetchPostalCode_MappingToAccount(mapAccount_New,null);
    }
    
    /*
    * MethodName   : OnAfterUpdate 
    * param        : trigger.newMap, trigger.oldMap
    * Description  : Method called on After update of Account. 
                    fetchPostalCodeMapping method is called to fetch the Postal_Code_Mapping objects based on the Account shipping Postal Code and map certain fields to Account
    */
    public void OnAfterUpdate(Map<Id, Account> mapAccount_New, Map<Id, Account> mapAccount_Old)
    {
        // Calling fetchPostalCode_MappingToAccount method
        fetchPostalCode_MappingToAccount(mapAccount_New,mapAccount_Old);
    }
    
    /*
    * MethodName   : fetchPostalCode_MappingToAccount 
    * param        : trigger.newMap, trigger.oldMap
    * Description  : Method called from OnAfterInsert and OnAfterUpdate
                    Fetch the Postal_Code_Mapping objects based on the Account shipping Postal Code and call fieldMapAccountFromPostalCode method
    */
    private void fetchPostalCode_MappingToAccount(Map<Id, Account> mapAccount_New, Map<Id, Account> mapAccount_Old)
    {
        Set <String> setBillingPostalCode = new Set <String> ();
        List <Account> lstAccount = new List <Account> (); 
        List <Account> lstAccountToBeUpdated = new List <Account> (); 
        Id AccountRecordTypeId;
        
        // Fetching Customer Record type
        for (RecordType objRecordType : [SELECT Id FROM RecordType WHERE DeveloperName = 'Facility' AND sobjecttype='account' LIMIT 1])
        {
            AccountRecordTypeId = objRecordType.Id;
        }
        
        if(AccountRecordTypeId == null) return;
        
        // Checking if it is insert or update case and if it is update then checking Billing Postal code or Market Segment is updated 
        for(Account objAccount : mapAccount_New.values())
        {
            if(objAccount.RecordTypeId == AccountRecordTypeId && (Trigger.isInsert ||(Trigger.isUpdate && (mapAccount_Old.get(objAccount.Id).BillingPostalCode != objAccount.BillingPostalCode 
            || mapAccount_Old.get(objAccount.Id).Market_Segment_WA__c != objAccount.Market_Segment_WA__c))))
            {
                lstAccount.add(objAccount);
                if(objAccount.BillingPostalCode != null && (objAccount.BillingCountry == 'CA' || objAccount.BillingCountry == 'US'|| objAccount.BillingCountry == 'United States'))
                {
                    setBillingPostalCode.add(objAccount.BillingCountry == 'CA' && objAccount.BillingPostalCode.length()>= 3 
                    ? objAccount.BillingPostalCode.substring(0,3): objAccount.BillingCountry == 'US' && objAccount.BillingPostalCode.length() >= 5? objAccount.BillingPostalCode.substring(0,5) : objAccount.BillingCountry == 'United States' && objAccount.BillingPostalCode.length() >= 5? objAccount.BillingPostalCode.substring(0,5) : null);
                }
            }
        }
        
        if(lstAccount.isEmpty()) return;
        
        // Calling SL_AccountMappingFromPostalCode class for mapping
        lstAccountToBeUpdated = SL_AccountMappingFromPostalCode.fetchPostalCode(setBillingPostalCode, lstAccount);
        
        // Update Account
        if (!lstAccountToBeUpdated.isEmpty() && lstAccountToBeUpdated != null)
            update lstAccountToBeUpdated;
    }
}