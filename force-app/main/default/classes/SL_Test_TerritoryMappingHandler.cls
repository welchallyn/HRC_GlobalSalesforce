/**
	*  Trigger Name   : SL_Test_TerritoryMappingHandler
	*  CreatedOn      : 18/MAY/2015
	*  ModifiedBy     : Nrusingh 
	*  Description    : This is the test class for the trigger and the batch
*/
@isTest
private class SL_Test_TerritoryMappingHandler {

    static testMethod void TerritoryMappingHandler() 
    {
    	List <Account> lstInsertedAcc = new List <Account> (); 
    	Id AccountRecordTypeId;
        
        // Fetching the Customer RecordTypeId
        for (RecordType objRecordType : [SELECT Id FROM RecordType WHERE DeveloperName = 'Facility' AND sobjecttype='account' LIMIT 1])
  		{
  			AccountRecordTypeId = objRecordType.Id;
  		}
  		 Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User objUser = new User(Alias = 'newUsr', Email='new45421@hillrom.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='new125.325@hillrom.com');
        insert objUser;
        
  		SL_Integration_Settings__c objIntSettings = new SL_Integration_Settings__c(Integration_UserId__c = objUser.Id, Integration_Status__c = 'Active, Inactive');
        insert objIntSettings;
  		
  		// Inserting Postal Code Mapping for CA and Us
  		List <Postal_Code_Mapping__c> lstPostal_Code_Mapping = new List<Postal_Code_Mapping__c>{new Postal_Code_Mapping__c(Name = '00544', Acute_Region__c = 'AcuteRegion', 
  																		  Acute_Territory__c = 'Acute Territory',
  																		  Ambulatory_Territory__c = 'AmbulatoryTerritory',
  																		  Ambulatory_Region__c = 'AmbulatoryRegion',
  																		  Inside_Sales__c = 'InsideSales',
  																		  Solutions_Architect__c = 'TestSol'),
        																new Postal_Code_Mapping__c(Name = '005', Acute_Region__c = 'AcuteRegionCA', 
	  																		  Acute_Territory__c = 'Acute TerritoryCA',
	  																		  Ambulatory_Region__c = 'AmbulatoryRegionCA',	  																		  
	  																		  Inside_Sales__c = 'InsideSalesCA',
	  																		  Solutions_Architect__c = 'TestSolCA')};
        insert lstPostal_Code_Mapping;
        
        
  		// Insert Account
  		List <Account> lstAccount = new List<Account>{new Account(Name = 'test-1', Local_Account_Name__c = 'test-1', Billingcity = 'TestCity-01', BillingPostalCode = '00544', COT_1__c = 'UN', BillingCountry = 'US', BillingState = 'Alaska', recordtypeId = AccountRecordTypeId),
        											new Account(Name = 'test-2', Local_Account_Name__c = 'test-2', Billingcity = 'TestCity-01',BillingPostalCode = '00544', COT_1__c = 'WH', BillingCountry = 'CA', BillingState = 'Manitoba', recordtypeId = AccountRecordTypeId)};
        insert lstAccount;
  		
  		for(Account objAccount : [SELECT Region__c, Territory__c, Inside_Sales__c, Solution_Architect__c FROM Account WHERE Id IN: lstAccount])
  		{
  			lstInsertedAcc.add(objAccount);
  		}
  		
  		// Checking the value after the trigger fire
  		//system.assertEquals(lstInsertedAcc[0].Region__c, lstPostal_Code_Mapping[0].Ambulatory_Region__c);
  		//system.assertEquals(lstInsertedAcc[1].Inside_Sales__c, lstPostal_Code_Mapping[1].Inside_Sales__c);
  		
  		lstAccount[0].COT_1__c = 'XO ';
  		update lstAccount[0]; 
  		
  		// Checking the value after the trigger fire
  		//system.assertEquals([SELECT Region__c FROM Account WHERE Id=:lstAccount[0].Id].Region__c, 'Other');
  		
  		lstAccount[1].BillingPostalCode = '123456789 ';
  		update lstAccount[1]; 
  		/*SL_TerritoryMangRuleRlgnBatchProcess__c obj = new SL_TerritoryMangRuleRlgnBatchProcess__c(Name = 'Welchallyn--full', UserName__c = 'welchallyn@silverlinecrm.com.full',
                                                                                                    Password__c = 'silverline@860', Security_Token__c ='aOcvG50rnNtR631SJqT4wiGt1');
                                                                    
        insert obj;*/
        
        SL_App_Configuration__c obj = new SL_App_Configuration__c(Org_Password__c = 'silverline@860', Org_Security_Token__c ='aOcvG50rnNtR631SJqT4wiGt1', Org_Username__c = 'welchallyn@silverlinecrm.com.full' );
        insert obj;
        
        SL_App_Configuration__c objSL_App_Configiration = new SL_App_Configuration__c ();
        
  		Test.startTest();
  		System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
  		partnerSoapSforceCom.Soap objPartnerSoap = new partnerSoapSforceCom.Soap();
  		objPartnerSoap.AssignmentRuleHeader = null;
  		 
  		Database.executeBatch(new SL_Batch_TerritoryMapping(), 200);
  		Test.StopTest();
    }
  	
  	/*Creating Mock Response */
  	private class WebServiceMockImpl implements WebServiceMock 
    {
    	// Create mock response
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType) 
        {
        	if(request instanceof partnerSoapSforceCom.login_element)
            {
             	partnerSoapSforceCom.loginResponse_element obj = new partnerSoapSforceCom.loginResponse_element();
				partnerSoapSforceCom.LoginResult AsyncResult = new partnerSoapSforceCom.LoginResult();
				AsyncResult.serverUrl='test';
				AsyncResult.sessionId=String.valueOf(UserInfo.getSessionId());
				
				obj.result =  AsyncResult;
				response.put('response_x', obj);	
            }
            else if(request instanceof partnerSoapSforceCom.update_element)
            {
                partnerSoapSforceCom.updateResponse_element obj = new partnerSoapSforceCom.updateResponse_element();
				
				partnerSoapSforceCom.SaveResult AsyncResult = new partnerSoapSforceCom.SaveResult();
				AsyncResult.id='1';
				obj.result =  new List<partnerSoapSforceCom.SaveResult>{AsyncResult};
				response.put('response_x', obj);
            }
            else if(request instanceof partnerSoapSforceCom.logout_element)
            {
                partnerSoapSforceCom.logoutResponse_element obj = new partnerSoapSforceCom.logoutResponse_element();
				response.put('response_x', obj);
            }
    	}
    }
}