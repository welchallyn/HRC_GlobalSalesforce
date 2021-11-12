/*
 *  ClassName    : ProposalLineItemSummaryControllerTest
 *  CreatedOn    : 24/Jan/2017
 *  ModifiedOn   : 26/Oct/2017
 *  CreatedBy    : Jenish Shingala
 *  ModifiedBy   : Chang Liu
 *  Description  : Test class for ProposalLineItemSummaryController
 */
@isTest
public with sharing class ProposalLineItemSummaryControllerTest {
    
    @isTest
    public static void test() {
        
        //Insert User.
        Profile p = [SELECT Id FROM Profile WHERE Name='HRC CFR Project Manager']; 
        User userObj  = new User(Alias = 'standt', Email='financialreviewertest@example.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='financialreviewer@testorg.com',jde_external_id__c = 'test33');
        
        insert userObj;
        
        //Insert an Account.
        Account objAccount= new Account();
        objAccount.name = 'Test Account';
        objAccount.BillingCity = 'Pune';
        objAccount.BillingCountry = 'India';
        objAccount.BillingPostalCode = '411033';
       // objAccount.LIKO_Level_2_Emp_Num__c = 'test44';
       // objAccount.LIKO_Level_3_Emp_Num__c = 'test33';
        insert objAccount;
        
        //Insert a Contact.
        Contact objContact = new Contact();
        objContact.FirstName = 'test first name';
        objContact.lastname = 'test last name';
        objContact.accountid = objAccount.id;
        objContact.Email = 'testname@apttus.com';
        objContact.Department_UK__c = 'Finance';
        objContact.Role__c = 'Administrator';
        insert objContact;
        
        //Insert Opportunity.
        Opportunity objOpp = new Opportunity();
        objOpp.accountid = objAccount.id;
        objOpp.name = 'Test name';
        objOpp.StageName = 'Developing Opportunity';
        objOpp.CloseDate = Date.today().adddays(1);
        objOpp.Project_Type_Rental__c = 'Asset Advantage';
        objOpp.Order_Contact__c = objContact.id;
        insert objOpp;
        
        Pricing_Contract__c objContract = new Pricing_Contract__c();
        objContract.Account__c = objAccount.id;
        insert objContract;
        
        //Create PriceList
        Apttus_Config2__PriceList__c ApttusTestPriceList = new Apttus_Config2__PriceList__c(
            Name = 'Commercial Price List', 
            Apttus_Config2__Active__c = True
        );
        insert ApttusTestPriceList;
        
        //Insert Apttus_Proposal__Proposal__c.
        Apttus_Proposal__Proposal__c objProp = new Apttus_Proposal__Proposal__c();
        objProp.Apttus_Proposal__Proposal_Name__c = 'Test Proposal name';
        objProp.Apttus_Proposal__Opportunity__c = objOpp.Id;
        objProp.APTPS_End_User_Country__c = 'IN - INDIA';
        objProp.Apttus_Proposal__Account__c = objAccount.id;
        objProp.APTS_Override_Contract__c = objContract.id;
        //objProp.Apttus_QPConfig__PriceListId__c = ApttusTestPriceList.id;
        insert objProp;
        
        //Insert Product2.
        Product2 objProduct = new Product2();
        objProduct.name = 'Test Product';
        objProduct.ProductCode = 'TTTTT001';
        objProduct.Description = 'Test Description';
        objProduct.GBU__c = 'FLC';
        objProduct.Brand__c = 'Hill-Rom';
        insert objProduct;
        
        //Insert ProductConfiguration
        Apttus_Config2__ProductConfiguration__c configSO = APTS_TestDataFactoryUtil.createProductConfiguration('Pricing Callback Test',
            1,
            objProp.Id,
            'Proposal',
            'Ad Hoc',
            ApttusTestPriceList.id,//proposalSO.Apttus_QPConfig__PriceListId__c,
            null,
            'Finalized',
            null,
            Datetime.now(),
            true,
            'Pricing Callback Test'
        );
        //insert configSO;
        
        //Insert LineItem
        Apttus_Config2__LineItem__c LineItem1 =new Apttus_Config2__LineItem__c(
            Apttus_Config2__ConfigurationId__c = configSO.id,
            Apttus_Config2__Quantity__c = 1,
            Apttus_Config2__ItemSequence__c = 1,
            Apttus_Config2__LineNumber__c = 1,
            APTS_Final_Net_Price__c = 100
            //Extended_List_Price__c = 150
        );
        insert LineItem1;
        
        //Insert Apttus_Proposal__Proposal_Line_Item__c.
        Apttus_Proposal__Proposal_Line_Item__c objLineItem = new Apttus_Proposal__Proposal_Line_Item__c();
        objLineItem.Apttus_Proposal__Proposal__c = objProp.id;
        objLineItem.Apttus_QPConfig__LineType__c = 'Option';
        objLineItem.Apttus_QPConfig__OptionId__c = objProduct.id;
        objLineItem.Apttus_QPConfig__ListPrice__c = 1000;
        objLineItem.Apttus_QPConfig__Quantity2__c = 2;
        objLineItem.Apttus_QPConfig__PrimaryLineNumber__c = 1;
        objLineItem.Apttus_QPConfig__DerivedFromId__c = LineItem1.id;
        //objLineItem.Apttus_QPConfig__HasOptions__c = true;
        //set it to true will bypass the DJF code #143, decrease controller coverage from 85% to 34%, increase DFJ from 0 to 43%
        
        //Extended_Net_Price_template__c
        //it is a formula: Apttus_QPConfig__Quantity2__c * Unit_Net_Price__c. 
        //formula of Unit_Net_Price__c: Apttus_QPConfig__DerivedFromId__r.Unit_Net_Price__c. Apttus_QPConfig__DerivedFromId__r is a look up to Line Item
        //on Line Item, Unit_Net_Price__c is a formula: APTS_Final_Net_Price__c / Apttus_Config2__Quantity__c
        
        //Extended_List_Price__c
        //it is a formula: Apttus_QPConfig__DerivedFromId__r.Extended_List_Price__c
        
        insert objLineItem;
        
        ApexPages.StandardController con = new ApexPages.StandardController(objProp);
        ApexPages.currentPage().getParameters().put('id',objProp.id);
        ProposalLineItemSummaryController ext = new ProposalLineItemSummaryController(con);
        ext.backToOpportunity();
        ext.ExportResults();
        ProposalLineItemSummaryControllerDJF extDJF = new ProposalLineItemSummaryControllerDJF(con);
        extDJF.backToOpportunity();
        extDJF.ExportResults();
        
        system.assertEquals(objProduct.name,'Test Product');
        
        
    }

}