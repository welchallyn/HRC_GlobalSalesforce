/*************************************************************************************************************
* Class Name                       : HRCSVC21_QuoteSoldToJDEIntegrationTest
* Author						   : Capgemini
* Date                             : Dec/03/2021
* Requirement/Project Name         : Hill-Rom
* Requirement/Project Description  : Test class for HRCSVC21_QuoteSoldToJDEIntegration
***************************************************************************************************************/
@isTest
public class HRCSVC21_QuoteSoldToJDEIntegrationTest implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        String fullJson = '{\n  \"soldToCustomerId\": 600077\n}';
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(fullJson);
        res.setStatusCode(200);
        return res;
    }
    @testsetup
        public static void setTestData(){
        RecordType recordTypeRequired = [SELECT Id from RecordType WHERE sObjectType = 'Account' AND Name = 'Facility'];
        Account acObj = new Account(Name = 'Sampletest Acc', BillingCity = 'Hyderabad', BillingCountry = 'India', BillingPostalCode = '222656', RecordTypeId = recordTypeRequired.id);
        insert acObj;
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        Opportunity oppObj = new Opportunity(AccountId= acObj.id, Name='Test Opportunity234');
        oppObj.Return_Type__c = 'None';
        oppObj.StageName = 'Qualified Opportunity';
        oppObj.CloseDate = system.today();
        oppObj.RMA_Date_1__c = system.today();
        oppObj.RMA_Price_1__c = 200.00 ;
        oppObj.RMA_Product_1__c = 'test product' ;
        oppObj.RMA_Quantity_1__c = 10 ;
        Test.startTest();
        insert oppObj;
        User uObj = new User(LastName = 'Shaik',
        FirstName='Tasneem',
        Alias = 'stas',
        Email = 'shaik.tasneemfirthose@capgemini.com',
        Username = 'shaik.tasneemfirthose@capgemini.com',
        ProfileId = profileId.id,
        TimeZoneSidKey = 'GMT',
        LanguageLocaleKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        LocaleSidKey = 'en_US',
        MobilePhone = '918500079787'
        );
        insert uObj;
        test.stopTest();
        
        }
     
	@isTest
	static void testCallout() {
        try{
    	     
		// Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new HRCSVC21_QuoteSoldToJDEIntegrationTest());
        Test.startTest();
        Schema.Location loc = HRCFSL_TestUtilityClass.createCustomer(true, 'Customer1234');
        //Account acc = new Account (name ='Test Account', CurrencyIsoCode = 'USD - U.S. Dollar');
        //Opportunity opp = new Opportunity(Name = 'sample Opp for Quote',AccountId = acc.Id,StageName = 'Identify', 
           //                              Opportunity_Type__c = 'Distributor Sell Out', Expected_Order_Date__c = System.today(),
        //                                 CloseDate = System.today());
        Opportunity opp = [Select Id from Opportunity LIMIT 1];
        List<Id> quoteList = new List<Id>();
    	Quote quote = new Quote(Name='CG',HRCSVC21_Quote_Type__c='Parts Quote',ExpirationDate=system.today(),
                                         HRCSVC21_Ship_To_Location__c=loc.id,OpportunityId = opp.Id);
        insert quote;
        quoteList.add(quote.Id);
            
        HRCSVC21_QuoteSoldToJDEIntegration.GetSoldTo(quoteList);
           
	    Test.stopTest();      
        }catch(Exception e){
            system.debug('Error In Line'+e.getLineNumber()+'Cause-'+e.getCause()+e.getStackTraceString());
        }
    }
        
 }