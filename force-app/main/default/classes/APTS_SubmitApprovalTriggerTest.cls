@isTest
public with sharing class APTS_SubmitApprovalTriggerTest
{
    private static final String LINE_TYPE_PRODUCT_SERVICE = 'Product/Service';
    private static final String LINE_TYPE_OPTION = 'Option';
    private static final String LINE_STATUS_NEW = 'New';
    
    static testMethod void testMethod1()
    {
        //pricelist entry        
        Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c(Name = 'US Price List Test', Apttus_Config2__Active__c = true);
        insert priceList;
        
        system.debug('start testAccount');
        //create account
        Account testAccount = new Account(Name = 'test Account', Site = 'www.apttus.com');
        insert testAccount;
        
        Pricing_Contract__c objPricingContract = new Pricing_Contract__c();
        objPricingContract.Account__c = testAccount.id;
        objPricingContract.Contract__c = '14501';
        objPricingContract.Contract_Description__c = 'Test Pricing Contract1';
        objPricingContract.Contract_Start_Date__c = Date.Today();
        objPricingContract.Contract_End_Date__c =  Date.Today().addDays(365);
        insert objPricingContract;

        system.debug('start productsList');
        //Create Product
        list<Product2> productsList = new list<Product2>();
        Product2 product1 = new Product2(Name = 'APTS TST Product 1', ProductCode = 'ATP 0001', Apttus_Config2__ConfigurationType__c = 'Standalone', IsActive = true);
        productsList.add(product1);
        
        Product2 product_2 = new Product2(Name = 'APTS TST Product 2', ProductCode = 'ATP 0002', Apttus_Config2__ConfigurationType__c = 'Standalone', IsActive = true);
        productsList.add(product_2);
        
        Product2 product3 = new Product2(Name = 'APTS TST Product 3', ProductCode = 'ATP 0003', Apttus_Config2__ConfigurationType__c = 'Standalone', IsActive = true);
        productsList.add(product3);
        
        insert productsList;

        system.debug('start priceListItem1');
        //create price list items
        Apttus_Config2__PriceListItem__c priceListItem1 = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__PriceType__c='One Time', Apttus_Config2__PriceUom__c ='Each', Apttus_Config2__ChargeType__c ='Standard Price', Apttus_Config2__ProductId__c = product1.Id);
        insert priceListItem1;
        
        Apttus_Config2__PriceListItem__c priceListItem2 = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__PriceType__c='One Time', Apttus_Config2__PriceUom__c ='Each', Apttus_Config2__ChargeType__c ='Standard Price', Apttus_Config2__ProductId__c = product3.Id);
        insert priceListItem2;

        system.debug('start Opportunity');
        //insert Opportunity
        Opportunity TestOpp=new Opportunity();
        TestOpp.Name='TestOpp';
        TestOpp.AccountId=testAccount.id;
        TestOpp.CloseDate=date.today().addYears(1);
        TestOpp.StageName='TestStage';
        insert TestOpp;
        
        system.debug('start proposal');
        
        Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c(Apttus_Proposal__Account__c = testAccount.Id, Apttus_Proposal__Opportunity__c=TestOpp.id, Apttus_QPConfig__PriceListId__c = priceList.Id, Apttus_Proposal__Approval_Stage__c = 'Draft',
                                                                                APTPS_End_User_Country__c = 'US - UNITED STATES');
        insert proposal;
      
        //create Agreement
        Apttus__APTS_Agreement__c Agreement = new Apttus__APTS_Agreement__c();
        Agreement.Apttus__Account__c = testAccount.id;
        Agreement.Apttus__Subtype__c='PD';
        Agreement.Apttus__Status__c='Request';
        insert Agreement;
        
        //create product configuration
        Apttus_Config2__ProductConfiguration__c configuration = new Apttus_Config2__ProductConfiguration__c(Name = 'APTS TST Configuration 1', 
                                                                                                  Apttus_QPConfig__Proposald__c = proposal.id, Apttus_Config2__AccountId__c = testAccount.Id, Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__Status__c = LINE_STATUS_NEW, Apttus_Config2__VersionNumber__c = 1, Apttus_Config2__EffectivePriceListId__c = priceList.Id
                                                                                               );
        insert configuration;
        
        system.debug('start lineItems');
        //create line item
        list<Apttus_Config2__LineItem__c> lineItems = new list<Apttus_Config2__LineItem__c>();
        Apttus_Config2__LineItem__c lineItem1 = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = configuration.Id, Apttus_Config2__LineType__c = LINE_TYPE_PRODUCT_SERVICE, Apttus_Config2__LineStatus__c = LINE_STATUS_NEW, Apttus_Config2__ProductId__c = product1.Id, Apttus_Config2__BasePrice__c = 1000, Apttus_Config2__ChargeType__c = 'Standard Price', Apttus_Config2__Quantity__c = 1, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1, Apttus_Config2__PrimaryLineNumber__c = 1,
                                                                               Apttus_Config2__ContractNumbers__c = '14501', Contract_Price_Year__c = '2014');
        lineItems.add(lineItem1);
     
        Apttus_Config2__LineItem__c lineItem3 = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = configuration.Id, Apttus_Config2__LineType__c = LINE_TYPE_PRODUCT_SERVICE, Apttus_Config2__LineStatus__c = LINE_STATUS_NEW, Apttus_Config2__ProductId__c = product3.Id, Apttus_Config2__BasePrice__c = 1000, Apttus_Config2__ChargeType__c = 'Standard Price', Apttus_Config2__Quantity__c = 1, Apttus_Config2__ItemSequence__c = 1, Apttus_Config2__LineNumber__c = 1, Apttus_Config2__PrimaryLineNumber__c = 1,
                                                                               Apttus_Config2__ContractNumbers__c = '14501', Contract_Price_Year__c = '2014');
        lineItems.add(lineItem3);

        insert lineItems;
        
        list<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItems = new list<Apttus_Proposal__Proposal_Line_Item__c>();
        Apttus_Proposal__Proposal_Line_Item__c proposalLineItem1 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = proposal.Id, APTPS_Approval_Status__c = 'Draft');
        proposalLineItems.add(proposalLineItem1);
     
        Apttus_Proposal__Proposal_Line_Item__c proposalLineItem3 = new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = proposal.Id, APTPS_Approval_Status__c = 'Draft');
        proposalLineItems.add(proposalLineItem3);
        
        insert proposalLineItems;
        
        proposalLineItems[0].APTPS_Approval_Status__c = 'Pending Approval';
        
        proposalLineItems[1].APTPS_Approval_Status__c = 'Rejected';
        
        update proposalLineItems;
        
        proposalLineItems[0].APTPS_Approval_Status__c = 'Rejected';
        
        proposalLineItems[1].APTPS_Approval_Status__c = 'Approved';
        
        update proposalLineItems;
        
        proposalLineItems[0].APTPS_Approval_Status__c = 'Approved';
        
        proposalLineItems[1].APTPS_Approval_Status__c = 'Approved';
        
        update proposalLineItems;        
                
        Apttus_Config2__ProductAttributeValue__c objAttribute = new Apttus_Config2__ProductAttributeValue__c();
        objAttribute.APTS_101_End_User_Country__c = 'US - UNITED STATES';        
        objAttribute.Apttus_Config2__LineItemId__c = lineItems[0].id;
        insert objAttribute;
        
    }
}