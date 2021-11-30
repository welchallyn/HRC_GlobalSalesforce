/**
    *  Class Name     : SL_Batch_TerritoryRuleRealignment
    *  Test Class     : SL_RunBatchController_test
    *  Modification   : By Srishti Goyal on 5th June 2020, Removed Database.Stateful interface

**/
global with sharing class SL_Batch_TerritoryRuleRealignment implements Database.Batchable<sObject> , Database.AllowsCallouts {
    
    String query;
    //initialised below class
    global partnerSoapSforceCom.Soap objPartnerSoap = new partnerSoapSforceCom.Soap(); 

    global Set<Id> lstAccountToCallout = new Set<Id>();
    
    /* Start - Constructor */
    global SL_Batch_TerritoryRuleRealignment(Set<Id> accountLIst) 
    {
        lstAccountToCallout = accountLIst;
    }
    /* End - Constructor */
    
    /*!
        * MethodName : start
        * param      : Database.BatchableContext
        * Description: This is the start method to pass the query records to execute method
    */
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        // Calling login method from Start
        loginViaToPartnerWSDLAPI();
        //Set<Id> accIDSet = new Set<Id>();
        
        /*for(Account acc : lstAccountToCallout)
        {
            accIDSet.add(acc.id);
        }*/
        return Database.getQueryLocator([select Id from Account where Id in :lstAccountToCallout]);
    }
    
    /*!
        * MethodName : execute
        * param      : Database.BatchableContext and list of sobject records
        * Description: Call territoryManageRuleRealignmet method for update operation
    */
    global void execute(Database.BatchableContext BC, List<Account> scope)
    {
        // Calling territoryManageRuleRealignmet method for update operation 
        territoryManageRuleRealignmet(scope);
    }
    
    /*!
        * MethodName : finish
        * param      : Database.BatchableContext 
        * Description: Call Logout method
    */
    global void finish(Database.BatchableContext BC) 
    {
        // Calling Logout method from the finish method
        if(!Test.isRunningTest())
            objPartnerSoap.logout();
    }
    
    /*!
        * MethodName : loginViaToPartnerWSDLAPI
        * param      : none
        * Description: Call Webservice callout login method 
    */
    global void loginViaToPartnerWSDLAPI()
    {
        //partnerSoapSforceCom.Timeout =  60000;
        objPartnerSoap = new partnerSoapSforceCom.Soap(); 
        objPartnerSoap.timeout_x = 120000;

        
        SL_App_Configuration__c objSLAppConfiguration =  SL_App_Configuration__c.getOrgDefaults();
        
        if(objSLAppConfiguration != null)
        {
            partnerSoapSforceCom.LoginResult loginResult;
            
            if(Test.isRunningTest())
            {
                loginResult = new partnerSoapSforceCom.LoginResult();
            }
            else
            {
                loginResult = objPartnerSoap.login(objSLAppConfiguration.Org_Username__c,objSLAppConfiguration.Org_Password__c+objSLAppConfiguration.Org_Security_Token__c);
            }

            objPartnerSoap.SessionHeader = new partnerSoapSforceCom.SessionHeader_element();
            objPartnerSoap.endpoint_x = loginResult.ServerUrl;
            objPartnerSoap.Sessionheader.sessionid = loginResult.sessionid;

            partnerSoapSforceCom.AssignmentRuleHeader_element  objPartnerSoapAssignRule = new partnerSoapSforceCom.AssignmentRuleHeader_element();
            objPartnerSoapAssignRule.useDefaultRule = true;
            objPartnerSoap.AssignmentRuleHeader = objPartnerSoapAssignRule;
        }
    }
    
    /*!
        * MethodName : territoryManageRuleRealignmet
        * param      : list of 200 chunks Accounts
        * Description: Call Webservice callout update method 
    */ 
    private void territoryManageRuleRealignmet(List <Account> lstAccount)
    {  
        partnerSoapSforceCom.SaveResult[] lstPartnerSoapSaveResult;
        List<sobjectPartnerSoapSforceCom.sObject_x> lstSobject_x = new List<sobjectPartnerSoapSforceCom.sObject_x>();
        if(lstAccount!=null && !lstAccount.isEmpty()) {        
            for(Account ac:lstAccount)
            { 
                sobjectPartnerSoapSforceCom.sObject_x tmpObj = new sobjectPartnerSoapSforceCom.sObject_x();
                tmpObj.type_x = 'Account';
                tmpObj.Id = ac.Id;
                lstSobject_x.add(tmpObj);
            }
        }
        if(!Test.isRunningTest())
            lstPartnerSoapSaveResult = objPartnerSoap.update_x(lstSobject_x);
    }
}