/*
 *  @author: Nimit Shah
 *  @date: 2014-07-09
 *  @description:
 *      Test class for APTS_SubmitRequest, APTS_Approver, APTS_SubmitApprovalTrigger
 *
 */
@isTest
public with sharing class APTS_SubmitRequestTest{
    
	// Start: Created by Nimit S on 07/09/14 Test class for APTS_SubmitRequest
    static testMethod void testMethod1() 
    {
        //Create Accounts
        Account account1 = new Account(Name = 'APTS TST Account 1');
        insert account1;

        //create Opportunity
        //Opportunity opportunity = new Opportunity(Name = 'APTS TST Opportunity 1', Account = account1, StageName = 'Lead/Inquiry', CloseDate = Date.today().addDays(365));
        //insert opportunity;
        
        Contact testcontact = new Contact(firstname='test', lastname = 'contact');
        insert testcontact;
        
        List<RecordType> rt = [select Id, Name from RecordType where SObjectType = 'Opportunity' limit 2];
        
        Opportunity opportunity = new Opportunity(AccountId=account1.id, Name='Test Opportunity123');
        opportunity.Return_Type__c = 'None';
        opportunity.StageName = 'Qualified Opportunity';
        opportunity.CloseDate = system.today();
        opportunity.RMA_Date_1__c = system.today();
        opportunity.RMA_Price_1__c = 100.00 ;
        opportunity.RMA_Product_1__c = 'test product' ;
        opportunity.RMA_Quantity_1__c = 10 ;
        opportunity.RecordTypeId = rt[0].Id; 
        opportunity.Order_Contact__c = testcontact.id;
  
        insert opportunity;
        
        //create price list
        Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c(Name = 'APTS TST PriceList 1', Apttus_Config2__Active__c = true);
        insert priceList;
        
        //Create Product
        Product2 product = new product2(Name = 'APTS TST Product 1', ProductCode = 'ATP 0001', Apttus_Config2__ConfigurationType__c = 'Standalone', IsActive = true); 
        insert product;
        
        //create price list items
        Apttus_Config2__PriceListItem__c priceListItem1 = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 1000, Apttus_Config2__ProductId__c = product.Id, Apttus_Config2__ChargeType__c = 'One Time Fee');
        insert priceListItem1;
        
        //create proposal
        Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c(Apttus_Proposal__Opportunity__c = opportunity.Id, Apttus_QPConfig__PriceListId__c = priceList.Id, Apttus_Proposal__Account__c = account1.Id);
        insert proposal;
        
        //create product configuration
        Apttus_Config2__ProductConfiguration__c configuration = new Apttus_Config2__ProductConfiguration__c(Name = 'APTS TST Configuration 1', Apttus_Config2__AccountId__c = account1.Id, Apttus_Config2__PriceListId__c = priceList.Id, Apttus_QPConfig__Proposald__c = proposal.Id, Apttus_Config2__Status__c = 'New', Apttus_Config2__VersionNumber__c = 1, Apttus_Config2__EffectivePriceListId__c = priceList.Id);
        insert configuration;
        
        //Create Product
        list<Product2> products = new list<Product2>();
        Product2 product1 = new product2(Name = 'APTS TST Product 1', ProductCode = 'ATP 0001', Apttus_Config2__ConfigurationType__c = 'Standalone', IsActive = true); 
        //insert product1;
        products.add(product1);
        
        Product2 product_2 = new product2(Name = 'APTS TST Product 2', ProductCode = 'ATP 0002', Apttus_Config2__ConfigurationType__c = 'Standalone', IsActive = true); 
        //insert product_2;
        products.add(product_2);
        
        insert products;
        
        //create proposal line items
        //create proposal line items
        list<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItems = new list<Apttus_Proposal__Proposal_Line_Item__c>();
        //solution lines
        Apttus_Proposal__Proposal_Line_Item__c proposalLineItem100 = new Apttus_Proposal__Proposal_Line_Item__c(APTPS_Approval_Status__c='Draft', Apttus_Proposal__Proposal__c = proposal.Id, Apttus_QPConfig__ConfigurationId__c = configuration.Id, Apttus_QPConfig__LineType__c = 'Product/Service', Apttus_QPConfig__PrimaryLineNumber__c = 1, Apttus_QPConfig__LineStatus__c = 'New', Apttus_QPConfig__OptionId__c = product1.Id, Apttus_Proposal__Product__c = product1.Id, Apttus_QPConfig__BasePrice__c = 1000, Apttus_QPConfig__ChargeType__c = 'One Time Fee',Apttus_QPConfig__Quantity2__c = 1);
        proposalLineItems.add(proposalLineItem100);
        
        Apttus_Proposal__Proposal_Line_Item__c proposalLineItem101 = new Apttus_Proposal__Proposal_Line_Item__c(APTPS_Approval_Status__c='Draft', Apttus_Proposal__Proposal__c = proposal.Id, Apttus_QPConfig__ConfigurationId__c = configuration.Id, Apttus_QPConfig__LineType__c = 'Product/Service', Apttus_QPConfig__PrimaryLineNumber__c = 2, Apttus_QPConfig__LineStatus__c = 'New', Apttus_QPConfig__OptionId__c = product1.Id, Apttus_Proposal__Product__c = product1.Id, Apttus_QPConfig__BasePrice__c = 1000, Apttus_QPConfig__ChargeType__c = 'One Time Fee',Apttus_QPConfig__Quantity2__c = 1);
        proposalLineItems.add(proposalLineItem101);
        
        insert proposalLineItems;
        
        test.startTest();
        
        APTS_SubmitRequest objSubmit = new APTS_SubmitRequest();
        objSubmit.objId = proposal.Id;
        objSubmit.submitRequest();
        objSubmit.redirectToProposal();
        
        proposalLineItems[0].APTPS_Approval_Status__c ='Pending Approval';
        proposalLineItems[1].APTPS_Approval_Status__c ='Rejected';
        
        update proposalLineItems;

        proposalLineItems[0].APTPS_Approval_Status__c ='Rejected';
        proposalLineItems[1].APTPS_Approval_Status__c ='Approved';
        
        update proposalLineItems;

        proposalLineItems[0].APTPS_Approval_Status__c ='Approved';
        proposalLineItems[1].APTPS_Approval_Status__c ='Approved';
        
        update proposalLineItems;

        test.stopTest();        
    }
    // End: Created by Nimit S on 07/09/14 Test class for APTS_SubmitRequest
}