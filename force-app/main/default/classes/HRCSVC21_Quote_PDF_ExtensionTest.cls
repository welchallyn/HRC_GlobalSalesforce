@isTest
public class HRCSVC21_Quote_PDF_ExtensionTest {

    
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
     Account_Team_Role__c  accTeamRoleObj = new Account_Team_Role__c(AccountId__c= acObj.id, UserId__c= uObj.id, Position__c='CCE');
        insert accTeamRoleObj;
        test.stopTest();
        
    }
     @isTest
    public static void QuotePDFExtensionTest() {
        try{
         Opportunity opp =[select id from Opportunity Limit 1];
             Schema.Location loc = HRCFSL_TestUtilityClass.createCustomer(true,'12345');
         //Location loc = new Location( Name='new loc', LocationType='Warehouse', HRCFSL_Customer_ID__c='676');
         //Location l = [select id from Location Limit 1];
         Quote q =new Quote(Name='Quote',HRCSVC21_Quote_Type__c='Parts Quote',OpportunityId=opp.id, HRCSVC21_Ship_to_location__c=loc.id);
         insert q;
        
      // Id aid= [select id from Quote where Quote.id=: q.id Limit 1][0].AccountId;
      // Account acc = [Select id, (select UserId__r.Name, UserId__r.MobilePhone, UserId__r.Email from Account_Team_Roles__r where Position__c='CCE' ORDER BY CreatedDate ASC LIMIT 1) FROM Account where id=:aid];
        ApexPages.StandardController sc =  new ApexPages.StandardController(q);
       HRCSVC21_Quote_PDF_Extension extObj= new HRCSVC21_Quote_PDF_Extension(sc);
            PageReference QuotePage = new ApexPages.StandardController(q).view();
            List<Account_Team_Role__c> teamList = new List<Account_Team_Role__c>();
            Test.setCurrentPage(QuotePage);
         Test.startTest();    
          // teamList = extObj.ListofAccountTeamRole();
            //teamList=extObj.getlistofAccountTeamRole();
           // extObj.HRCSVC21_Quote_PDF_Extension(sc);
           // QuotePage.HRCSVC21_Quote_PDF_Extension(sc);
          Test.stopTest();
        }
       catch(Exception e){}
    }
}