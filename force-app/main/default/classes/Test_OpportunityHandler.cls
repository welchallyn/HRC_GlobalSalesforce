/*
    *  ClassName    : Test_OpportunityHandler
    *  CreatedOn    : 08/Oct/2015
    *  CreatedBy    : ESiewert
    *  ModifiedBy   : ESiewert
    *  Description  : Test class for Opportunity Handler
*/

@isTest
private class Test_OpportunityHandler
{
    @isTest static void hasGenericsTest() 
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User objUser = new User(Alias = 'newUsr', Email='new45421@welchallyn.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='new125.325@welchallyn.com');
        insert objUser;
        
        SL_Integration_Settings__c objIntSettings = new SL_Integration_Settings__c(Integration_UserId__c = objUser.Id, Integration_Status__c = 'Active, Inactive');
        insert objIntSettings;    
    
    
        String USPB = '';//'01sj0000003eksL';
        PriceBook2 pb = new PriceBook2();
            pb.name = 'USPB';
            pb.isActive=true;
            insert pb;
        USPB=pb.id;
        String StdPB = Test.getStandardPricebookId();//'01sj0000002LQMI';
        //---Products---
        //create a non generic product
        Product2 testProduct = new Product2(Name='TestProductCSVM', Seismic_Tag__c = 'CVSM', ProductCode='TestCVSM', CurrencyISOCode='USD', isActive=true, isGeneric__c=false);
        //create a generic product        
        Product2 testGenericProduct = new Product2(Name='CRM-TestProductCSVM', Seismic_Tag__c = 'CVSM',ProductCode='CRM-TestCVSM', CurrencyISOCode='USD', isActive=true, isGeneric__c=true);
        //create an RVN Camera product
        Product2 testRVNProduct = new Product2(Name='CRM-TestRVNCamera',Seismic_Tag__c = 'RetinaVue',  ProductCode='RV100-B', CurrencyISOCode='USD', isActive=true, isGeneric__c=false);
        insert testProduct;
        insert testGenericProduct;
        insert testRVNProduct;
        system.assertEquals(true,testGenericProduct.isGeneric__c, 'generic product is generic');
        
        //---PricebookEntries---
        //create a non-generic standard pricebookentry
        PricebookEntry testStdPBE = new PricebookEntry(Product2Id=testProduct.Id, Pricebook2Id=StdPB, CurrencyISOCode='USD', isActive=false, UnitPrice=2.00);
        //create a generic standard pricebookentry
        PricebookEntry testStdGenericPBE = new PricebookEntry(Product2Id=testGenericProduct.Id, Pricebook2Id=StdPB, CurrencyISOCode='USD', isActive=false, UnitPrice=2.00);
        //create a non-generic pricebookentry in US PB
        PricebookEntry testPBE = new PricebookEntry(Product2Id=testProduct.Id, Pricebook2Id=USPB, CurrencyISOCode='USD', isActive=true, UnitPrice=1.75);
        //create a generic pricebookentry in US PB
        PricebookEntry testGenericPBE = new PricebookEntry(Product2Id=testGenericProduct.Id, Pricebook2Id=USPB, CurrencyISOCode='USD', isActive=true, UnitPrice=1.80);
        //create a RVN pricebookentry in STD PB
        PricebookEntry testRVNSTDPBE = new PricebookEntry(Product2Id=testRVNProduct.Id, Pricebook2Id=StdPB, CurrencyISOCode='USD', isActive=true, UnitPrice=1.75);
        //create a RVN pricebookentry in US PB
        PricebookEntry testRVNUSPBE = new PricebookEntry(Product2Id=testRVNProduct.Id, Pricebook2Id=USPB, CurrencyISOCode='USD', isActive=true, UnitPrice=1.80);
        
        insert testStdPBE;
        insert testStdGenericPBE;
        insert testPBE;
        insert testGenericPBE;
        insert testRVNSTDPBE;
        insert testRVNUSPBE;
       
        
        //---Account---
        List<Account> AcctList = new List<Account>();
        Account testAccount = new Account(OwnerId=objUser.id, Name='TestAcct-OppHandler', ShippingStreet='111 test rd', ShippingCity='Burlington', BillingState='VT', ShippingPostalCode='05401',BillingCity='test',BillingPostalCode='12345', RecordTypeid=Schema.SObjectType.account.getRecordTypeInfosByName().get('Customer').getRecordTypeId());
        AcctList.Add(testAccount);
        insert AcctList; 
        
        //---Opportunity---
        //create the opp
        Date todaysDate = date.parse(date.today().format());
        Opportunity testOpp = new Opportunity(HasGenerics__c=false,hasRVNCamera__c=false, OwnerId=objUser.Id, Name='TestGenericsOpp', StageName='Prospecting', CloseDate=todaysDate, AccountId=testAccount.Id, Type='Upgrade Existing Users');
        insert testOpp;
        //assert HasGenerics = false
        system.assertEquals(false,testOpp.HasGenerics__c, 'hasGenerics false with no line items');
        //assert hasRVNCamera__c = false
        system.assertEquals(false,testOpp.hasRVNCamera__c, 'hasRVNCamera__c false, no camera on opportunity');
        
        
        //---OpportunityLineItems
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        //add a line item that is not generic
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId=testOpp.Id, PricebookEntryId=testPBE.Id, Quantity=1,TotalPrice=50); 
        //add a line item that is generic
        OpportunityLineItem oliGeneric = new OpportunityLineItem(OpportunityId=testOpp.Id, PricebookEntryId=testGenericPBE.Id, Quantity=1,TotalPrice=60); 
        //add a line item that is a camera
        OpportunityLineItem oliRVN = new OpportunityLineItem(OpportunityId=testOpp.Id, PricebookEntryId=testRVNUSPBE.Id, Quantity=2,TotalPrice=100); 
        oliList.add(oli);
        oliList.add(oliGeneric);
        oliList.add(oliRVN);
        //insert all 3 line items
        insert oliList;
        //because we inserted a generic line item on the opp, HasGenerics__c on the Opp should now be true.
        Integer genericsCount = 0;
        integer cameraCount = 0;
        //assert hasRVNCamera is now true
        cameraCount = [SELECT COUNT() FROM Opportunity WHERE Id =:testOpp.Id AND hasRVNCamera__c=true];
        system.assertEquals(1,cameraCount, '1 camera line item found');
        //query for the count of generic opportunity line items
        genericsCount = [SELECT COUNT() FROM Opportunity WHERE Id =:testOpp.Id AND hasGenerics__c=true];
      //  system.assertEquals(1,genericsCount, '1 generic found');
        //Delete the generic oppLineItem;
        delete oliGeneric;
        //delete camera line item
        delete oliRVN;
        genericsCount = [SELECT COUNT() FROM Opportunity WHERE Id =:testOpp.Id AND hasGenerics__c=true];
        //because we deleted the generic line item on the opp, HasGenerics__c on the Opp should now be false.
     //   system.assertEquals(0,genericsCount, 'no generics now that the Generic line item has been deleted');
		cameraCount = [SELECT COUNT() FROM Opportunity WHERE Id =:testOpp.Id AND hasRVNCamera__c=true];
        //because we deleted the camera line item on the opp, hasRVNCamera__c on the Opp should now be false.
     //   system.assertEquals(0,cameraCount, 'no camera now that the camera line item has been deleted');
        
    }   
}