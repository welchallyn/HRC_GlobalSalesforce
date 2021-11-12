/**
    *  Class Name     : SL_AccountMappingFromPostalCode
    *  CreatedOn      : 15/MAY/2015
    *  ModifiedBy     : ESiewert, 6/18/2018
    *  Description    : The class is used used for Territory Mapping
    *  Changed        : Market_Segment__c to Market_Segments__c
    *  Modification   : Srishti Goyal on 13th May 2020; Org Merge Related changes
*/

public with sharing class SL_AccountMappingFromPostalCode 
{
    /* Start - Constructor */
    public SL_AccountMappingFromPostalCode()
    {
        // Do Nothing
    }
    /* End - Constructor */
    
    /*!
        * MethodName : fetchPostalCode
        * param      : setBillingPostalCode, lstAccount
        * Description: This will fetch the Postal Code Mapping based on the Account shipping Postal Code as well as call the fieldMapAccountFromPostalCode method for mapping
    */
    public static List <Account> fetchPostalCode(Set <String> setBillingPostalCode, List <Account> lstAccount)
    {
        Map <String, Postal_Code_Mapping__c> mapPostalCodeNameToPostalCode = new Map <String, Postal_Code_Mapping__c>(); 
        List <Account> lstAccountToBeUpdated = new List <Account> ();
         
        if(!setBillingPostalCode.isEmpty())
        {
            for(Postal_Code_Mapping__c objPostalCode : [SELECT Name,
                                                               Acute_Region__c,
                                                               Acute_Territory__c,
                                                               Ambulatory_Region__c,
                                                               Ambulatory_Territory__c,
                                                               Inside_Sales__c,
                                                               Solutions_Architect__c,
                                                               Acute_Mortara_Territory__c,
                                                               Vision_Care_Terr__c,
                                                               Vision_Care_Region__c
                                                        FROM Postal_Code_Mapping__c
                                                        WHERE Name IN : setBillingPostalCode])
            {
                // mapping Postal Code Name and Postal Code
                mapPostalCodeNameToPostalCode.put(objPostalCode.Name, objPostalCode);
            }
        }
        
        // Iterating through the list of Account and mapping based on the Billing country and Market Segment
        for(Account objAccount : lstAccount)
        {
            //if((objAccount.Market_Segments__c != 'Acute' && objAccount.Market_Segments__c != 'Ambulatory'))
            if((objAccount.Market_Segment_WA__c != 'Acute' && objAccount.Market_Segment_WA__c != 'Ambulatory' && objAccount.Market_Segment_WA__c != 'System')) {
                lstAccountToBeUpdated.add(fieldMapAccountFromPostalCode(objAccount, null));
            }   
            //else if((objAccount.BillingCountry == 'US' || objAccount.BillingCountry == 'CA') && (objAccount.Market_Segments__c == 'Acute' || objAccount.Market_Segments__c == 'Ambulatory')
            //&& objAccount.BillingPostalCode != null && !mapPostalCodeNameToPostalCode.isEmpty() && mapPostalCodeNameToPostalCode != null)
            else if((objAccount.BillingCountry == 'US' || objAccount.BillingCountry == 'United States' || objAccount.BillingCountry == 'CA')
            && objAccount.BillingPostalCode != null && !mapPostalCodeNameToPostalCode.isEmpty() && mapPostalCodeNameToPostalCode != null && objAccount.Type !='Strategic')
            {
                if(((objAccount.BillingCountry == 'US'||objAccount.BillingCountry == 'United States') && objAccount.BillingPostalCode != null && objAccount.BillingPostalCode.length()>=5 && mapPostalCodeNameToPostalCode.containsKey(objAccount.BillingPostalCode.substring(0,5)))
                || (objAccount.BillingCountry == 'CA' && objAccount.BillingPostalCode != null && objAccount.BillingPostalCode.length()>=3 
                && mapPostalCodeNameToPostalCode.containsKey(objAccount.BillingPostalCode.substring(0,3)))) {
                    lstAccountToBeUpdated.add(fieldMapAccountFromPostalCode(objAccount, mapPostalCodeNameToPostalCode));
                }
                else if(((objAccount.BillingCountry == 'US'|| objAccount.BillingCountry=='United States') && objAccount.BillingPostalCode != null  && objAccount.BillingPostalCode.length()>=5 && !mapPostalCodeNameToPostalCode.containsKey(objAccount.BillingPostalCode.substring(0,5)))
                || (objAccount.BillingCountry == 'CA' && objAccount.BillingPostalCode != null && objAccount.BillingPostalCode.length()>=3 
                && !mapPostalCodeNameToPostalCode.containsKey(objAccount.BillingPostalCode.substring(0,3))))
                {
                    lstAccountToBeUpdated.add(fieldMapAccountFromPostalCode(objAccount, null));
                }
            }
            else if((objAccount.Market_Segment_WA__c == 'Acute' || objAccount.Market_Segment_WA__c == 'Ambulatory' || objAccount.Market_Segment_WA__c == 'System') && (objAccount.BillingPostalCode == null || (mapPostalCodeNameToPostalCode.isEmpty() || mapPostalCodeNameToPostalCode == null)))
                lstAccountToBeUpdated.add(fieldMapAccountFromPostalCode(objAccount, null));
        }
        return lstAccountToBeUpdated;
    }
    
    /*!
        * MethodName : fieldMapAccountFromPostalCode
        * param      : account, mapPostalCodeNameToPostalCode
        * Description: This will map the Account from Postal Code
    */
    public static Account fieldMapAccountFromPostalCode(Account objAccount, Map <String, Postal_Code_Mapping__c> mapPostalCodeNameToPostalCode) 
    {
        String strPostalCode;
        Account objAccountMappedFromPostalCode = new Account();
        
        // Storing the shipping Postal Code in a String
        if(objAccount.BillingPostalCode != null)
        {
            // Checking if the Shiping country is Us store the BillingPostalCode
            if((objAccount.BillingCountry == 'US' || objAccount.BillingCountry =='United States') && objAccount.BillingPostalCode.length()>=5)
                strPostalCode = objAccount.BillingPostalCode.substring(0,5);
            // Checking if the Shiping country is CA store the first three characters of BillingPostalCode
            else if(objAccount.BillingCountry == 'CA' && objAccount.BillingPostalCode.length()>= 3)
                strPostalCode = objAccount.BillingPostalCode.substring(0,3);
        }
        
        // if  the Account.Market_Segments__c not equals Acute and Ambulatory
        if(mapPostalCodeNameToPostalCode == null)
            objAccountMappedFromPostalCode = new Account(Id = objAccount.Id, Region__c = (objAccount.Market_Segment_WA__c != 'Acute' && objAccount.Market_Segment_WA__c != 'Ambulatory')?objAccount.Market_Segment_WA__c:null, Territory__c = null, Inside_Sales__c = null, Solution_Architect__c = null);
        
        // Field mapping based on the Market Segment Acute or Ambulatory
        if(mapPostalCodeNameToPostalCode != null && strPostalCode != null)
            objAccountMappedFromPostalCode = new Account(Id = objAccount.Id, 
                                                         Region__c =  (objAccount.Market_Segment_WA__c == 'Acute')
                                                                      ?mapPostalCodeNameToPostalCode.get(strPostalCode).Acute_Region__c
                                                                      : objAccount.Market_Segment_WA__c == 'System'
                                                                      ?mapPostalCodeNameToPostalCode.get(strPostalCode).Acute_Region__c
                                                                      : objAccount.Market_Segment_WA__c == 'Ambulatory' 
                                                                      ? mapPostalCodeNameToPostalCode.get(strPostalCode).Ambulatory_Region__c
                                                                      :null,
                                                    
                                                        Territory__c =  (objAccount.Market_Segment_WA__c == 'Acute')
                                                                        ?mapPostalCodeNameToPostalCode.get(strPostalCode).Acute_Territory__c
                                                                        : objAccount.Market_Segment_WA__c == 'System'
                                                                        ?mapPostalCodeNameToPostalCode.get(strPostalCode).Acute_Territory__c
                                                                        : objAccount.Market_Segment_WA__c == 'Ambulatory' 
                                                                        ? mapPostalCodeNameToPostalCode.get(strPostalCode).Ambulatory_Territory__c
                                                                        :null,
                                                         
                                                        Vision_Care_Territory__c =  mapPostalCodeNameToPostalCode.get(strPostalCode).Vision_Care_Terr__c,
                                                        Vision_Care_Region__c = mapPostalCodeNameToPostalCode.get(strPostalCode).Vision_Care_Region__c,
                                                         Inside_Sales__c = mapPostalCodeNameToPostalCode.get(strPostalCode).Inside_Sales__c,
                                                        Solution_Architect__c = mapPostalCodeNameToPostalCode.get(strPostalCode).Solutions_Architect__c,
                                                        Acute_Mortara_Territory__c = mapPostalCodeNameToPostalCode.get(strPostalCode).Acute_Mortara_Territory__c );                                
                                                     
        return objAccountMappedFromPostalCode;
    }
}