/**
    *  Controller        : SL_Account_Hierarchy
    *  CreatedOn         : 19/MAY/2015
    *  ModifiedBy        : Nrusingh 
    *  Description       : This the account Hierarchy page Controller 
    *  Changed           : Market_Segment__c to Market_Segments__c
*/
public with sharing class SL_Account_Hierarchy
{
    /*Global Variables*/
    public List <AccountWrapper> lstAccountWrapper                  {   get;set;    }
    public Map<String, String> mapAccountToSpace_indicatingLevel    {   get;set;    }
    public String strAccountName                                    {   get;set;    }       
    public String strCurrentAccountId;                              
    
    /*!
        * Wrapper Class : AccountWrapper
        * Description: This contains Account and unique level Id
    */
    public class AccountWrapper
    {
        public Account objAccount                       {   get;set;    }
        public String strUniqueLevel                    {   get;set;    }
        public AccountWrapper(Account objAccount, String strUniqueLevel)
        {
            this.objAccount = objAccount;
            this.strUniqueLevel = strUniqueLevel;
        }
    }
    
    /* Start - Constructor */ 
    public SL_Account_Hierarchy()
    {
        // Checking if the page Url contains Id
        if(isValidParam())
        {
            // Calling initializeGlobalVariables method to initialize the global variables
            initializeGlobalVariables();
            
            // Calling CreateAccountStructure method to create the structure and display it in page
            CreateAccountStructure(strCurrentAccountId);
        }
        else
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'The URL is invalid. Please pass the Account Id '));
    }
    /* End - Constructor */
    
    /*!
        * MethodName : isValidParam
        * param      : none
        * Description: validate the page Url
    */
    private boolean isValidParam()
    {
        Map <String, String> mapCurrentPageParameter = new Map <String, String>(); 
        mapCurrentPageParameter = System.currentPageReference().getParameters();
        
        if(mapCurrentPageParameter.containsKey('Id'))
        {
            strCurrentAccountId = mapCurrentPageParameter.get('Id');
            return true;
        }
        else
            return false;
    }
    
    /*!
        * MethodName : initializeGlobalVariables
        * param      : none
        * Description: To initialize the global variables
    */
    private void initializeGlobalVariables()
    {
        lstAccountWrapper = new List<AccountWrapper>();
        mapAccountToSpace_indicatingLevel = new Map<String, String>();
    }
    
    /*!
        * MethodName : CreateAccountStructure
        * param      : Context Account Id
        * Description: fetching ultimate parent and calling setAccountHirerchyLevel method for structrd data displaying in the page
    */
    private void CreateAccountStructure(String strCurrentAccId)
    {
        Set <Id> setUltimateParentId = new Set <Id> (); 
        Account objContextAccount;
        // Fetching the Account based on the Id provided in the URL
        for(Account objAccount : [Select Id,Name, Meta_Parent__c,Market_Segments__c, ShippingState, ShippingCity FROM Account WHERE Id =: strCurrentAccId])
        {
            objContextAccount = objAccount;
        }
        
        if(objContextAccount != null)
        {
            strAccountName = objContextAccount.Name;
            setUltimateParentId.add(objContextAccount.Meta_Parent__c != null ? objContextAccount.Meta_Parent__c : objContextAccount.Id);
            
            // Calling setAccountHirerchyLevel method
            setAccountHirerchyLevel(setUltimateParentId);
        }
        else
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Currently the Account is not present. Please check the Account Id present in the URL.'));
    }
    
    /*!
        * MethodName : setAccountHirerchyLevel
        * param      : Ultimate Parent Id
        * Description: Cretae the structured data for displaying in page
    */
    private void setAccountHirerchyLevel(Set <Id> setCurrentParentId)
    {
        List <Account> lstAllAccount = new List <Account> ();
        List<String> lstNode   = new List<String>();
        
        Map<ID, String> mapAccIdToUniqueNodeId =  new Map<Id, String>{};
        Map <String, AccountWrapper> mapNodeIdToAccount = new Map <String, AccountWrapper> (); 
        
        String strUniqueNodeId;
        Integer intLevel = 0;
        Boolean endOfStructure = false;
        
        while ( !endOfStructure )
        {
            if( intLevel == 0 )
                
                // Fetchong the Account if the level is zero 
                lstAllAccount = [SELECT Id, Name, Total_Amount_Open_Opps__c, Total_Number_Open_Opps__c, ParentId, Market_Segments__c, ShippingState, ShippingCity FROM Account WHERE Id IN : setCurrentParentId ORDER BY Name];
                
            else
                // Fetching the Account based on the parent id set below
                lstAllAccount = [SELECT Id, Name, Total_Amount_Open_Opps__c, Total_Number_Open_Opps__c, ParentId, Market_Segments__c, ShippingState, ShippingCity FROM Account WHERE ParentID IN : setCurrentParentId ORDER BY Name];
            
            if( lstAllAccount.isEmpty())
                endOfStructure = true;
            else
            {
                setCurrentParentId.clear();
                
                for ( Integer index = 0 ; index < lstAllAccount.size(); index++ )
                {
                    // Set the unique row id based on each level
                     strUniqueNodeId = ( intLevel > 0 ) ? mapAccIdToUniqueNodeId.get( lstAllAccount[index].ParentId )+String.valueOf( index )+'_0' : String.valueOf( index );
                     //map of node id and Account wrapper class
                     mapNodeIdToAccount.put(strUniqueNodeId, new AccountWrapper(lstAllAccount[index],strUniqueNodeId ));
                     
                     setCurrentParentId.add(lstAllAccount[index].Id);
                     mapAccIdToUniqueNodeId.put(lstAllAccount[index].Id, strUniqueNodeId);
                     lstNode.add(strUniqueNodeId);
                }
                intLevel++;
            }
        }
        
        // Sorting the List
        lstNode.sort();
        
        // Iterating through the list of node       
        for(String strNodeId : lstNode)
        {
            Integer intCount = 0;
            String strSpace ;
            if(strNodeId.contains('_'))
            {
                for (String str1 : strNodeId.split('_'))
                {
                    intCount++;
                }
                for(Integer managePaddingBasedOnLevel=0; managePaddingBasedOnLevel<intCount; managePaddingBasedOnLevel++)
                {
                   strSpace = 'padding-left:'+ 38*managePaddingBasedOnLevel+'px';
                }
                mapAccountToSpace_indicatingLevel.put(strNodeId,strSpace);
            }
            
            if(!strNodeId.contains('_'))
                mapAccountToSpace_indicatingLevel.put(strNodeId,''); 
            
           if(!mapNodeIdToAccount.isEmpty() && mapNodeIdToAccount.containsKey(strNodeId))
           {    
                lstAccountWrapper.add(mapNodeIdToAccount.get(strNodeId));
           }
        }
    }
}