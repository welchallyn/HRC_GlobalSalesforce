/*******************************************************************
 * Class Name: HRCSVC21_QuoteLineItemHandlerTest
 * Author: Capgemini
 * Date: December/9/2021
********************************************************************/

@isTest
public class HRCSVC21_QuoteLineItemHandlerTest implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        String fullJson = 'your Json Response';
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'text/json');
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
        oppObj.WatchCare_on_Bed__c='No';
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
    @istest
    public static void GetPricingTest(){
          Test.setMock(HttpCalloutMock.class, new HRCSVC21_OLI_Handler_Test());
         Product2 product = HRCFSL_TestUtilityClass.createProduct(true, 'PS73B', 'PAO');
        Opportunity opp =[select id from Opportunity Limit 1];
             Schema.Location loc = HRCFSL_TestUtilityClass.createCustomer(true,'12345');
         //Location loc = new Location( Name='new loc', LocationType='Warehouse', HRCFSL_Customer_ID__c='676');
         //Location l = [select id from Location Limit 1];
         
         String StdPB = Test.getStandardPricebookId();
         Product2 product1 = new Product2(Name='TestProductCSVM', Seismic_Tag__c = 'CVSM', ProductCode='TestCVSM', CurrencyISOCode='USD', isActive=true, isGeneric__c=false);
       test.startTest();
        insert product1;
         PricebookEntry testStdPBE = new PricebookEntry(Product2Id=product1.Id, Pricebook2Id=StdPB, CurrencyISOCode='USD', isActive=true, UnitPrice=2.00);
        insert testStdPBE;
        Quote q =new Quote(Name='Quote',HRCSVC21_Quote_Type__c='Parts Quote',OpportunityId=opp.id, HRCSVC21_Ship_to_location__c=loc.id,Pricebook2Id=StdPB);
         insert q;
        QuoteLineItem qli= new QuoteLineItem(QuoteId=q.id,Product2Id=product1.id,Quantity=100,UnitPrice=100,PricebookEntryId=testStdPBE.id);
        insert qli;
       qli.Quantity=10;
        update qli;
        system.debug('quuiii'+qli);
        test.stopTest();
        
    }
}