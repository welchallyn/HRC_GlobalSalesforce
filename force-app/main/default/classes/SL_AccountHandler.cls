/*
    *  ClassName    : SL_AccountHandler 
    *  JIRATicket   : WADVDSC-2,WADVDSC-4 ,WADVDSC-5
    *  CreatedOn    : 15/May/2015
    *  ModifiedOn   : 03/Oct/2017
    *  CreatedBy    : Nrusingh
    *  ModifiedBy   : Erik Siewert
    *  Description  : Handler for trigger on Account of Populating Meta_Parent__c feild with the Ultimate Parent of its heirarchy
    *  Modified 27/Dec/2019 Doug Lecher to check for new Reltio MDM fields instead of Gaine fields
    *  Modified 06/Apr/2020 Doug Lecher, changed Shipping Address fields to Billing for OrgMerge, disabled delete_audit as it is covered by alreadyexisting class in HRC org
*/
public class SL_AccountHandler 
{
    /* Start Variables */
    private static Map<Id, List<Account>> mapParentIdToLstAccount;
    private static Map<Id, Set<Id>> mapParentIdToSetChildId;
    private static Map <Id, Account> mapDeletedAccIdToAccount;
    public static Datetime testDatetimeNow;
    
    /* End Variables */
    
    /* start - constructor */ 
    public SL_AccountHandler()
    {
        //Do Nothing
    }
    /* end - constructor */ 
    
    /*
        * MethodName : onBeforeInsert
        * Param      : List<Account>(Trigger.new) 
        * Description: Triggers on before insert of Account record to Update Meta_Parent__c with its Ultimate Parent
    */  
    
    public void onBeforeInsert(List<Account> lstAccountNew)
    {
        //commented method (updateUltimateParentOnInsert) to remove meta parent logic-CR00031056
        //updateUltimateParentOnInsert(lstAccountNew);
        manageIntegrationDate(new Map<Id , Account>(), lstAccountNew);
    }
    
    /*
        * MethodName    : onBeforeUpdate
        * Param         : map<Id , Account>(Trigger.oldMap) and List<Account>(Trigger.new) 
        * JIRATicket    : WADVDSC-5
        * Description   : Triggers on before update of Account record to Update integration date on account.
    */  
    
    public void onBeforeUpdate(map<Id , Account> mapIdToAccountOld , List<Account> lstAccountNew)
    {
        manageIntegrationDate(mapIdToAccountOld, lstAccountNew);
    }
    
    /*
        * MethodName : onAfterUpdate
        * Param      : map<Id , Account>(Trigger.newMap) , map<Id , Account>(Trigger.oldMap)  
        * Description: Triggers on after update of Account to update Meta_Parent__c with its Ultimate Parent and respective OLI
    */ 
    
    public void onAfterUpdate(map<Id , Account> mapIdToAccountOld , map<Id , Account> mapIdToAccountNew)
    {
        //commented method (updateUltimateParentOnUpdate) to remove meta parent logic-CR00031056
        //updateUltimateParentOnUpdate(mapIdToAccountOld , mapIdToAccountNew);
        //updateOLIs(mapIdToAccountNew , mapIdToAccountOld);/* Added for WADVDSC-4   */
    }
    
    /*
        * MethodName : onBeforeDelete
        * Param      : map<Id , Account>(Trigger.oldMap)  
        * Description: Triggers on before delete of Account to update Meta_Parent__c with its Ultimate Parent
    */ 
    
    public void onBeforeDelete(map<Id , Account> mapIdToAccountOld)
    {	//commented method (updateUltimateParentOnBeforeDelete) to remove meta parent logic-CR00031056
        //updateUltimateParentOnBeforeDelete(mapIdToAccountOld);
    }
    
    /*
        * MethodName : onAfterDelete
        * Param      : map<Id , Account>(Trigger.oldMap)  
        * Description: Triggers on after delete of Account record to Update Meta_Parent__c with its Ultimate Parent
    */  
    public void onAfterDelete(map<Id , Account> mapIdToAccountOld)
    {
        //commented method (updateUltimateParentOnAfterDelete) to remove meta parent logic-CR00031056
        //updateUltimateParentOnAfterDelete(mapIdToAccountOld);
    }
    
    /*
        * MethodName    : manageIntegrationDate
        * Param         : map<Id , Account>(Trigger.oldMap) and list<Account>(Trigger.new) 
        * JIRATicket    : WADVDSC-5
        * Description   : To manage integration date on account on insert and update of account
    */  
    private void manageIntegrationDate(map<Id , Account> mapIdToAccountOld, List<Account> lstAccountNew)
    {
        //Getting the org default value from custom setting
        SL_Integration_Settings__c objIntSetting=new SL_Integration_Settings__c(); 
        if(test.isRunningTest()){
          objIntSetting.Integration_UserId__c=userinfo.getUserId();
          objIntSetting.Integration_Status__c='Active, Inactive';  
        }
        else{
         objIntSetting = SL_Integration_Settings__c.getOrgDefaults();
        }    
        Id integrationUserId = objIntSetting.Integration_UserId__c;
        String setAccountStatus = objIntSetting.Integration_Status__c;
        List<String> statusParts = setAccountStatus.split('\\,');
        for(Integer i=0;i<statusParts.size();i++){
            statusParts[i] = statusParts[i].trim();
        }
        Set<String> setStatusParts = new Set<String>(statusParts);
        
        for(Account objNewAccount : lstAccountNew)
        {
            Account objOldAccount = mapIdToAccountOld.get(objNewAccount.Id);
            
            if(((mapIdToAccountOld.isEmpty() || (
                objNewAccount.PARTY_MK__c != objOldAccount.PARTY_MK__c 
               || objNewAccount.Status__c != objOldAccount.Status__c 
               || objNewAccount.Name != objOldAccount.Name 
               || objNewAccount.Local_Account_Name__c != objOldAccount.Local_Account_Name__c 
               || objNewAccount.BillingStreet != objOldAccount.BillingStreet 
               || objNewAccount.BillingCity != objOldAccount.BillingCity
               || objNewAccount.BillingState != objOldAccount.BillingState 
               || objNewAccount.BillingPostalCode != objOldAccount.BillingPostalCode
               || objNewAccount.BillingCountry != objOldAccount.BillingCountry 
               || objNewAccount.COT_1__c != objOldAccount.COT_1__c
               || objNewAccount.COT_2__c != objOldAccount.COT_2__c 
               || objNewAccount.Parent_ID__c != objOldAccount.Parent_ID__c
               || objNewAccount.Parent_Name__c != objOldAccount.Parent_Name__c
               || objNewAccount.ParentID != objOldAccount.ParentID 
               || objNewAccount.Ultimate_Parent_Id__c != objOldAccount.Ultimate_Parent_Id__c
               || objNewAccount.ECC_USE_ID__c != objOldAccount.ECC_USE_ID__c 
               || objNewAccount.WA_ID__c != objOldAccount.WA_ID__c
               || objNewAccount.SKA_ID__c != objOldAccount.SKA_ID__c
               || objNewAccount.JDE_External_ID__c  != objOldAccount.JDE_External_ID__c 
               //adding more values to list per CR00018574 
               || objNewAccount.Hospital_Ownership_Description__c != objOldAccount.Hospital_Ownership_Description__c
               || objNewAccount.Code5_Value__c != objOldAccount.Code5_Value__c
               || objNewAccount.Teaching_Hospital__c != objOldAccount.Teaching_Hospital__c
               || objNewAccount.EMR_Brand__c != objOldAccount.EMR_Brand__c
               || objNewAccount.Website != objOldAccount.Website
               || objNewAccount.of_Beds__c != objOldAccount.of_Beds__c
               || objNewAccount.of_Doctors__c != objOldAccount.of_Doctors__c
               || objNewAccount.Patients_Per_Day__c != objOldAccount.Patients_Per_Day__c
               || objNewAccount.OneKeyID__c != objOldAccount.OneKeyID__c
              )) 
                && (setStatusParts.contains(objNewAccount.Status__c))))
            {
                objNewAccount.IC_Date__c = DateTime.now();
                testDatetimeNow = DateTime.now();
            }
        }
    }
          
    /* 
        * MethodName : updateOLIs
        * Param      : List<Account>(Trigger.new) 
        * Description: Updates OLI for Opportunities related to Accounts 
    */
                
    /*private void updateOLIs(map<Id , Account> mapIdToAccountOld , map<Id , Account> mapIdToAccountNew)
    {
        Set<Id> setAccountId = new set<Id>();
        for(Account objAccount : mapIdToAccountNew.values())
        {
            if(objAccount.ShippingCountry != mapIdToAccountOld.get(objAccount.Id).ShippingCountry || 
               objAccount.Market_Segment__c != mapIdToAccountOld.get(objAccount.Id).Market_Segment__c)
            {
                setAccountId.add(objAccount.Id);
            }
        }
        if(!setAccountId.isEmpty())
        {
            List<OpportunityLineItem> lstOpportunityLineItem =  [Select Id , Product2Id , OpportunityId , 
                                                                        Category_Type__c , SAP_ProfitCenter__c , SAP_Product_Group__c,Strategic_Product__c,
                                                                        SAP_ProfitGroupCenter__c from OpportunityLineItem 
                                                                        where Opportunity.AccountId IN :setAccountId AND Opportunity.isWon = false]; 
            if(!lstOpportunityLineItem.isEmpty() && lstOpportunityLineItem!=null)
                SL_StrategicProduct_calulator.fetchValuesToUpdateOLI(lstOpportunityLineItem , true , null);
        }    
    }*/

    /*
        * MethodName : updateUltimateParentOnInsert
        * Param      : List<Account>(Trigger.new) 
        * Description: Update ultimate parent field on child records
    */
    //commented method to remove meta parent logic-CR00031056
    /*private void updateUltimateParentOnInsert(List<Account> lstAccount)
    {
        Set<Id> setParentId = new Set<Id>(); //Set for parent Id of account record.
        
        for(Account objAccount : lstAccount)
        {
            if(objAccount.ParentId != null) //To check if whether the Account contains ParentId.
                setParentId.add(objAccount.ParentId);
        }
        //Map used to store filter Account 
        Map<Id, Account> mapIdToAccount = new Map<Id, Account>([SELECT Id, Meta_Parent__c FROM Account WHERE Id IN:setParentId]);
        for(Account objAccount : lstAccount)
        {
            if(objAccount.ParentId != null && mapIdToAccount.containsKey(objAccount.ParentId))
            {
                //If Ultimate Parent Id is null then update the Child with its Parent Account Id as Ultimate Parent.
                objAccount.Meta_Parent__c = (mapIdToAccount.get(objAccount.ParentId).Meta_Parent__c != null)
                                                ? mapIdToAccount.get(objAccount.ParentId).Meta_Parent__c 
                                                : objAccount.ParentId;
            }
        }
    }*/
    
     /*
        * MethodName : updateUltimateParentOnUpdate
        * Param      : map<Id , Account>(Trigger.newMap) , map<Id , Account>(Trigger.oldMap)  
        * Description: Update ultimate parent field on child records
    */
    //commented method to remove meta parent logic-CR00031056
    /*private void updateUltimateParentOnUpdate(Map<Id, Account> mapIdToAccountOld, Map<Id, Account> mapIdToAccountNew)
    {
        Set<Id> setParentId = new Set<Id>(); //Set Parent Account Id to Updated Account record.
        Set<Id> setUltimateParentId = new Set<Id>();//Set of Ultimate Parent Id of the Updated Account record.
        mapParentIdToLstAccount = new Map<Id, List<Account>>();//Map to contains Parent Id ans List of Account.
        Map<Id, Account> mapIdToAccount = new Map<Id, Account>();//Map to contain Account Id to Object Account.

        //getting the utimate id to get all the related child records.
        for(Account objAccount : mapIdToAccountNew.values())
        {
            if((objAccount.ParentId != mapIdToAccountOld.get(objAccount.Id).ParentId))
            {
                if(objAccount.ParentId == null)
                    setParentId.add(objAccount.Id);
                else if(objAccount.ParentId != null && !mapIdToAccountNew.containsKey(objAccount.ParentId))
                    setParentId.add(objAccount.ParentId);
                
                if(mapIdToAccountOld.get(objAccount.Id).Meta_Parent__c != null)
                    setUltimateParentId.add(mapIdToAccountOld.get(objAccount.Id).Meta_Parent__c);
                else if(mapIdToAccountOld.get(objAccount.Id).ParentId == null)
                    setUltimateParentId.add(objAccount.Id);
                    
                if(objAccount.ParentId  != null && mapParentIdToLstAccount.containsKey(objAccount.ParentId))
                    mapParentIdToLstAccount.get(objAccount.ParentId).add(objAccount);
                else if(objAccount.ParentId  != null)
                    mapParentIdToLstAccount.put(objAccount.ParentId, new List<Account>{objAccount});
                    
                mapIdToAccount.put(objAccount.Id, objAccount);
            }
        }
        //calling method to update utimate parent Id.
        if(!mapIdToAccount.isEmpty())
            updateUltimateParent(mapIdToAccount, setParentId, setUltimateParentId);
    }*/
    
     /*
        * MethodName : updateUltimateParent
        * Param      : map<Id ,Account> , Set<Account>ParentIds , Set<Account>UltimateParents
        * Description: Update ultimate parent field on child records
    */
    //commented method to remove meta parent logic-CR00031056
    /*private void updateUltimateParent(Map<Id, Account> mapIdToAccount, Set<Id> setParentId, Set<Id> setUltimateParentId)
    {
        List<Account> lstTopParentAccount = [SELECT Id, Meta_Parent__c, ParentId FROM Account WHERE Id IN: setParentId ];
        List<Account> lstAccountToUpdate = new List<Account>(); //List to Update the updated Account
        for(Account objAccount : [SELECT Id, 
                                         Meta_Parent__c, 
                                         ParentId 
                                    FROM Account 
                                   WHERE Meta_Parent__c IN: setUltimateParentId 
                                     AND Id NOT IN: mapIdToAccount.keySet()])
        {
            mapIdToAccount.put(objAccount.Id, objAccount);
            if(objAccount.ParentId != null)
            {
                if(mapParentIdToLstAccount.containsKey(objAccount.ParentId))
                    mapParentIdToLstAccount.get(objAccount.ParentId).add(objAccount);
                else
                    mapParentIdToLstAccount.put(objAccount.ParentId, new List<Account>{objAccount});
            }
        }
        
        //Iterate on updated Account records and calls the method to get the child record to update with Ultimate Parent and Parent Id.
        for(Account objAccount : lstTopParentAccount)
        {
            if(objAccount.ParentId != null && mapParentIdToLstAccount.containsKey(objAccount.Id))
            {
                lstAccountToUpdate.addAll(updateChildRecordUltimateParent(mapParentIdToLstAccount.get(objAccount.Id),
                                                                          setParentId, 
                                                                          objAccount.Meta_Parent__c));
            }
            else if(objAccount.ParentId == null && mapParentIdToLstAccount.containsKey(objAccount.Id))
            {
                lstAccountToUpdate.add(new Account(Id = objAccount.Id, Meta_Parent__c = null));
                lstAccountToUpdate.addAll(updateChildRecordUltimateParent(mapParentIdToLstAccount.get(objAccount.Id), 
                                                                          setParentId, 
                                                                          objAccount.Id));
            }
            else if(objAccount.ParentId == null)
            {
                lstAccountToUpdate.add(new Account(Id = objAccount.Id, Meta_Parent__c = null));
            }
        }
        //Update the Account and its child record with the Ultimate Parent Id and its Parent Id.
        if(!lstAccountToUpdate.isEmpty())
            update lstAccountToUpdate;
    }*/
    
     /*
        * MethodName : updateChildRecordUltimateParent
        * Param      : List<Account> , set<Id> ParentId , Id UltimateParent
        * Description: Update ultimate parent field on child records
    */
    //commented method to remove meta parent logic-CR00031056
    /*private List<Account> updateChildRecordUltimateParent(List<Account> lstAccount, Set<Id> setParentChangeId, Id ultimateId)
    {
        List<Account> lstAccountToUpdate = new List<Account>();//List to return child Account records to update.
        //getting the utimate id to get all the related child records.
        for(Account objAccount : lstAccount)
        {
            //check if Account Record contains any child records
            if(!setParentChangeId.contains(objAccount.Id))
            {
                if(objAccount.ParentId != null && mapParentIdToLstAccount.containsKey(objAccount.Id))
                {
                    lstAccountToUpdate.add(new Account(Id = objAccount.Id, Meta_Parent__c = ultimateId));
                    //calls the method itself in recursion till it gets all its child 
                    lstAccountToUpdate.addAll(updateChildRecordUltimateParent(mapParentIdToLstAccount.get(objAccount.Id), setParentChangeId, ultimateId));
                }
                else if(objAccount.ParentId != null)
                {
                    lstAccountToUpdate.add(new Account(Id = objAccount.Id, Meta_Parent__c = ultimateId));
                }
            }
        }
        return lstAccountToUpdate;//return list of child Accounts of particular parents to update its Ultimate Parent and its Parent
    }*/
    
     /*
        * MethodName : updateUltimateParentOnBeforeDelete
        * Param      : map<Id , Account>(Trigger.OldMap) 
        * Description: Update ultimate parent field on child records
    */
    //commented method to remove meta parent logic-CR00031056
    /*private void updateUltimateParentOnBeforeDelete(Map<Id, Account> mapIdToAccountOld)
    {
        mapParentIdToLstAccount = new Map<Id, List<Account>>();//Map to contains Parent Id ans List of Account.
        mapParentIdToSetChildId = new Map<Id, Set<Id>>();
        Set<Id> setUltimateParentId = new Set<Id>();//Set of Ultimate Parent Id before delete.
        List<Account> lstAccountDeleteUpdate = new List<Account>();
        
        mapDeletedAccIdToAccount = new Map <Id, Account> ();
        
        for(Account objAccount : mapIdToAccountOld.values())
        {
            lstAccountDeleteUpdate.add(new Account(Id=objAccount.Id , ParentId = null));
             // Updated By Nrusingh for WADVDSC-6. 
            // Checking if the PARTY_MK__c is not null
            
            if(objAccount.PARTY_MK__c != null)
                mapDeletedAccIdToAccount.put(objAccount.Id,objAccount);        
        }
        
        // Updated By Nrusingh for WADVDSC-6. 
        if(!lstAccountDeleteUpdate.isEmpty())
        {
            Database.update (lstAccountDeleteUpdate, false);
        }
        
        //getting the utimate id to get all the related child records.
        for(Account objAccount : mapIdToAccountOld.values())
        {
            //checks to set ultimate Id if not null else assigns the Parent Id as the Ultimate Id
            if(objAccount.Meta_Parent__c != null)
                setUltimateParentId.add(objAccount.Meta_Parent__c);
            else 
                setUltimateParentId.add(objAccount.Id);
        }
        for(Account objAccount : [SELECT Id, 
                                         ParentId, 
                                         Meta_Parent__c 
                                    FROM Account 
                                    WHERE ParentId IN: mapIdToAccountOld.keySet() 
                                    AND Id NOT IN: mapIdToAccountOld.keySet()])
        {
            if(mapParentIdToSetChildId.containsKey(objAccount.ParentId))
                mapParentIdToSetChildId.get(objAccount.ParentId).add(objAccount.Id);
            else
                mapParentIdToSetChildId.put(objAccount.ParentId, new Set<Id>{objAccount.Id});
        }
        for(Account objAccount : [SELECT Id, 
                                         Meta_Parent__c, 
                                         ParentId 
                                    FROM Account 
                                   WHERE Meta_Parent__c IN: setUltimateParentId 
                                     AND Id NOT IN: mapIdToAccountOld.keySet()])
        {
            if(mapParentIdToLstAccount.containsKey(objAccount.ParentId))
                mapParentIdToLstAccount.get(objAccount.ParentId).add(objAccount);
            else
                mapParentIdToLstAccount.put(objAccount.ParentId, new List<Account>{objAccount});
        }
        
    }*/
   
     /*
        * MethodName : updateUltimateParentOnAfterDelete
        * Param      : map<Id , Account>(Trigger.odlMap) 
        * Description: Update ultimate parent field on child records
    */
    //commented method to remove meta parent logic-CR00031056
    /*private void updateUltimateParentOnAfterDelete(Map<Id, Account> mapIdToAccountOld)
    {
        List<Account> lstAccountToUpdate = new List<Account>();//List to update the Account after delete of any Account Record
        String strAuditType;
        for(Account objAccount : mapIdToAccountOld.values())
        {
             // Updated By Nrusingh for WADVDSC-6. 
            // Checking if Merge Operation or simple delete operation is performed 
            strAuditType = objAccount.MasterRecordId != null ? 'MERGE' : 'DELETE';
           
            if(mapParentIdToSetChildId.containsKey(objAccount.Id) )
            {
                for(Id childId : mapParentIdToSetChildId.get(objAccount.Id))
                {
                    lstAccountToUpdate.add(new Account(Id = childId, Meta_Parent__c = null));
                    if(mapParentIdToLstAccount.containsKey(childId))//Check whether Parent Id is present in the List of Account in Map to update particular Child Records.
                    {
                        lstAccountToUpdate.addAll(updateChildRecordUltimateParent(mapParentIdToLstAccount.get(childId), mapIdToAccountOld.keySet(), childId));
                    }
                }
            }
        }
        
        // Updated By Nrusingh for WADVDSC-6
        // Calling createDeleteAuditAfterDelete method to create Delete Audit based on the Account Deletion
        // Doug Lecher 06 Apr 2020 - No longer calling createDeleteAuditAfterDelete because of existing class
        //createDeleteAuditAfterDelete(strAuditType);
        
        // Updated By Nrusingh for WADVDSC-6. 
        //Update the Account and its child record with the Ultimate Parent Id  
        if(!lstAccountToUpdate.isEmpty())
        {
          Database.update (lstAccountToUpdate,false);
        }
    }*/
    
    /*
        * MethodName : createDeleteAuditAfterDelete
        * Param      : Audit Type
        * Description: Create new Delete_Audit__c record when an Account is delted or merged
                        Added by Nrusingh
    */
    /* Doug Lecher 06 Apr 2020 No longer needed after orgmerge
       private void createDeleteAuditAfterDelete(String strAuditType)
    {
        List <Delete_Audit__c> lstDeleteAuditToBeCreated = new List <Delete_Audit__c> ();
        String newStatus = 'Inactive';
        String strDeleteAuditName = '';
        
        // Fetching the Custom Label value. which is PMK- for now
        String strFilterCharacter =  Label.SL_PMK_Account;
        String strAccountName = '';
        
        // Iterating through the list of Accounts those are deleted
        if(!mapDeletedAccIdToAccount.isEmpty())
        {
            // Creating Delete_Audit__c based on the Audi Type.
            for(Account objAccount : mapDeletedAccIdToAccount.values())
            {
              strAccountName = objAccount.Name; 
              
                lstDeleteAuditToBeCreated.add(new Delete_Audit__c(
                                                                    COT_1__c = objAccount.COT_1__c,
                                                                    COT_2__c = objAccount.COT_2__c,
                                                                    Deleted_SFDCID__c = objAccount.Id,
                                                                    ECC_USE_ID__c = objAccount.ECC_USE_ID__c,
                                                                    Parent_ID__c = String.valueOf(objAccount.Parent_ID__c),
                                                                    Parent_Name__c = objAccount.Parent_Name__c,
                                                                    Local_Account_Name__c = objAccount.Local_Account_Name__c,                                                                           
                                                                    ParentID__c = objAccount.ParentId,
                                                                    PARTY_MK__c = objAccount.PARTY_MK__c,
                                                                    ShippingCity__c = objAccount.BillingCity,
                                                                    ShippingCountryCode__c = objAccount.BillingCountry,
                                                                    ShippingPostalCode__c = objAccount.BillingPostalCode,
                                                                    ShippingStateCode__c = objAccount.BillingState,
                                                                    ShippingStreet__c = objAccount.BillingStreet,
                                                                    SKA_ID__c = objAccount.SKA_ID__c,
                                                                    Status__c = newStatus,
                                                                    WA_ID__c = objAccount.WA_ID__c,
                                                                    
                                                                    //mapping Name of the Delete Audit depends upon the Account Name containing PMK- or not
                                                                    Name = (strAccountName.startsWith(strFilterCharacter)) 
                                                                        ? 
                                                                          (strAccountName.contains(':')
                                                                          ?
                                                                            (strAccountName.substring(strAccountName.IndexOf(':')+1,strAccountName.length()))
                                                                          :
                                                                            objAccount.Name)
                                                                        :
                                                                          objAccount.Name,
                                                                    Type__c = strAuditType
                    ));
                } 
                
                // Insert Delete_Audit__c record
                insert lstDeleteAuditToBeCreated;
            }
        }*/
}