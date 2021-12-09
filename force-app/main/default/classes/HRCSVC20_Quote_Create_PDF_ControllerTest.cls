@isTest
public class HRCSVC20_Quote_Create_PDF_ControllerTest {

    @testsetup
    public static void setTestData(){
   
        RecordType recordTypeRequired = [SELECT Id from RecordType WHERE sObjectType = 'Account' AND Name = 'Facility'];
            Account accountForValidation = new Account(Name = 'Test Acc', BillingCity = 'Pune', BillingCountry = 'India', BillingPostalCode = '411057', RecordTypeId = recordTypeRequired.id);
            insert accountForValidation;
            RecordType recordForContactValidation = [SELECT Id from RecordType WHERE sObjectType = 'Contact' AND Name = 'HRC Contact'];
            Contact contactForEmailValidation = new Contact(LastName = 'Max', Role__c = 'Administrator', Email = 'test.user@cap.com', Department_UK__c = 'Finance', AccountId = accountForValidation.id, RecordTypeId = recordForContactValidation.id);
            insert contactForEmailValidation;
        Test.startTest();
            RecordType recordForCaseValidation = [SELECT Id from RecordType WHERE sObjectType = 'Case' AND Name = 'Scaletronix Service'];
            Case caseForValidation = new Case(Status = 'In Process', Type = 'Inquiry',  SlaStartDate = system.today(), Origin = 'Email', RecordTypeId = recordForCaseValidation.id, ContactId = contactForEmailValidation.Id);            
           Schema.Location loc = HRCFSL_TestUtilityClass.createCustomer(true,'12345');
           loc.HRCFSL_Country__c = 'US';
           update loc;
        caseForValidation.HRCSVC_Location__c = loc.Id; 
        caseForValidation.AccountId = accountForValidation.id;
            insert caseForValidation;
        Opportunity testOpp = new Opportunity(AccountId=accountForValidation.id, Name='Test Opportunity234343');
        testOpp.Return_Type__c = 'None';
        testOpp.StageName = 'Qualified Opportunity';
        testOpp.CloseDate = system.today();
        testOpp.RMA_Date_1__c = system.today();
        testOpp.RMA_Price_1__c = 100.00 ;
        testOpp.RMA_Product_1__c = 'test product' ;
        testOpp.RMA_Quantity_1__c = 10 ;
        //testOpp.Order_Contact__c = testcontact.id;
        insert testOpp;
            test.stopTest();
    }
    
    @isTest
    public static void QuoteCreatePDFControllerTest() {
        try{
            Schema.Location loc =[select id from Location limit 1];  
            Opportunity opp =[select id from Opportunity Limit 1];
            Case c =[Select id from case Limit 1];
            Quote q =new Quote(Name='Quote',HRCSVC21_Quote_Type__c='Parts Quote',OpportunityId=Opp.id,HRCSVC21_Ship_to_location__c=loc.id);
          insert q;
         system.debug('qnhumtum'+q);    
           ApexPages.StandardController sc =  new ApexPages.StandardController(q);
       HRCSVC20_Quote_Create_PDF_Controller pdf= new HRCSVC20_Quote_Create_PDF_Controller(sc);
            PageReference QuotePage = new ApexPages.StandardController(q).view();
        QuotePage.getParameters().put('id', String.valueOf(q.Id));
        Test.setCurrentPage(QuotePage);
           Test.startTest();
            pdf.savePDF();
            pdf.getquoteId();
            pdf.setquoteId(q.id);
            pdf.returnurl='';
        PageReference ref=pdf.initialize(q.id);
            test.stopTest();
      // HRCSVC20_Quote_Create_PDF_Controller pdf= new  HRCSVC20_Quote_Create_PDF_Controller();
            } 
        catch(Exception e){}
    }
}