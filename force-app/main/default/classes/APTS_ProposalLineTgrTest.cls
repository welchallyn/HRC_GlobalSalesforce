@isTest
public class APTS_ProposalLineTgrTest
{
    static testMethod void testProposalLineItemTgr()
    {
        Account acc = new Account(Name = 'APTS TST Account 1');
        insert acc;
        
        system.debug('*****************************2');
        
        //create Opportunity
        Opportunity opp = new Opportunity(AccountId=acc.id, Name='Test Opportunity234343'); 
        opp.Return_Type__c = 'None';
        opp.StageName = 'Qualified Opportunity';
        opp.CloseDate = system.today();
        opp.RMA_Date_1__c = system.today();
        opp.RMA_Price_1__c = 100.00 ;
        opp.RMA_Product_1__c = 'test product' ;
        opp.RMA_Quantity_1__c = 10 ;
        //testOpp.Order_Contact__c = testcontact.id;
        insert opp;  
        
        // STEP I - Create a product
        Product2 productSO = APTS_TestDataFactoryUtil.createProduct('BundleProduct1',
                                           'BundleProduct1',
                                           'TEST Apttus',
                                           'TestApttus',
                                           'Bundle',
                                           'Each',
                                           true,
                                           Date.today(), 
                                           Date.today().addMonths(12));
                                           
       
         Product2 productSO3 = APTS_TestDataFactoryUtil.createProduct('OptionProduct1',
                                            'OptionProduct1',
                                            'TestApttus3',
                                            'TestApttus3',
                                            'Option',
                                            'Each',
                                            true,
                                            Date.today(), 
                                            Date.today().addMonths(12));
        
         // STEP II - Create a new price list
        Apttus_Config2__PriceList__c priceListSO = APTS_TestDataFactoryUtil.createPriceList('Professional Software Price List', 
                                                                   'Price list for Apttus',
                                                                   Date.today(), 
                                                                   Date.today().addMonths(12));   
        
        // STEP III - Create price list items
        Apttus_Config2__PriceListItem__c plItemSO = APTS_TestDataFactoryUtil.createPriceListItem(priceListSO.Id,
                                                                        productSO.Id,
                                                                        'Subscription Fee', 
                                                                        'Recurring',
                                                                        'Per Unit',
                                                                        9485,
                                                                        9000,
                                                                        10000,
                                                                        'Unit Price',
                                                                        Date.today(), 
                                                                        Date.today().addMonths(12),
                                                                        true);   
        
        Apttus_Config2__ClassificationName__c newCategory = APTS_TestDataFactoryUtil.getCategory('LEOptionGrp', 'LEOptionGrp', 'Option Group');
		insert newCategory;
		
		Apttus_Config2__ClassificationHierarchy__c newCategoryHierarchy = APTS_TestDataFactoryUtil.getCategoryHierarchy('LEOptionGrp', 'Larger Enterprise Options', newCategory);
		insert newCategoryHierarchy;
		
		Apttus_Config2__ProductOptionGroup__c prodOptionGroup = APTS_TestDataFactoryUtil.getProductOptionGroup(newCategoryHierarchy, productSO);
		insert prodOptionGroup;
        
        
        Apttus_Config2__ProductOptionComponent__c prodOptComp_pso3= APTS_TestDataFactoryUtil.CreateOptionComponents(prodOptionGroup.id,//Id OptionGroupId,
                                                                                       productSO3.id,//Id OptionId,
                                                                                       productSO.id,//Id parentProductId,
                                                                                       'Option',//string relationshipType
                                                                                       1
                                                                                       );           
                                                                                                                                       
            
        // STEP IV - Create a new quote/proposal
        Apttus_Proposal__Proposal__c proposalSO = APTS_TestDataFactoryUtil.createQuoteOrProposal('Test Configure', 
                                                                        opp.id,
                                                                        Date.today(), 
                                                                        Date.today().addMonths(12), 
                                                                        priceListSO.Id,
                                                                        Date.today(),
                                                                        '3 Years',
                                                                        true,acc.id); 
        
        
         proposalSO.Apttus_QPConfig__PriceListId__c=priceListSO.Id;
                                                                   
         
        
        
         // STEP V - create a new configuration object
        Apttus_Config2__ProductConfiguration__c configSO = APTS_TestDataFactoryUtil.createProductConfiguration('Pricing Callback Test',
                                                                                      1,
                                                                                      proposalSO.Id,
                                                                                      'Proposal',
                                                                                      'Ad Hoc',
                                                                                      priceListSO.Id,//proposalSO.Apttus_QPConfig__PriceListId__c,
                                                                                      null,
                                                                                      'Finalized',
                                                                                      null,
                                                                                      Datetime.now(),
                                                                                      true,
                                                                                      'Pricing Callback Test');
        
         Apttus_Proposal__Proposal_Line_Item__c proposalLineItem = APTS_TestDataFactoryUtil.createProposalLineItem(configSO.Id,//configId
                                                                null,//groupId
                                                                3,//line number
                                                                true,//Is primary line
                                                                1,//itemseq
                                                                'Product/Service',//linetype
                                                                productSO.id,//product Id                                                                
                                                                prodOptComp_pso3.id,//productOptionId
                                                                null,//OptionId,
                                                                null,//classid
                                                                null,//string classhierarchy
                                                                1,//qty
                                                                true,//isQtymodifiable
                                                                'Each',//UOM
                                                                1,//term
                                                                priceListSO.Id,//pricelistId
                                                                plItemSO.Id,//price list item
                                                                'Recurring',//price type
                                                                'Per Unit',// price method
                                                                'Subscription Fee', // charge type
                                                                null,//frequency
                                                                true,//allow manual adj
                                                                true,//allocate group adj
                                                                9485,//listprice
                                                                9485,//baseprice
                                                                'Per Unit',//baserpricemethod,
                                                                100.0,//baseextprice                                                   
                                                                9485,//optionprice
                                                                null,//extprice                                                                
                                                                'TestaPTTUS',//desc
                                                                2,//primarylinenumber
                                                                proposalSO.id// proposalId
                                                                );  
                                                      
            
        Apttus_Proposal__Proposal_Line_Item__c proposalLineItem2 = APTS_TestDataFactoryUtil.createProposalLineItem(configSO.Id,//configId
                                                                null,//groupId
                                                                3,//line number
                                                                true,//Is primary line
                                                                1,//itemseq
                                                                'Option',//linetype
                                                                productSO.id,//product Id                                                                
                                                                prodOptComp_pso3.id,//productOptionId 
                                                                productSO3.id,//OptionId,
                                                                null,//classid
                                                                null,//string classhierarchy
                                                                1,//qty
                                                                true,//isQtymodifiable
                                                                'Each',//UOM
                                                                1,//term
                                                                priceListSO.Id,//pricelistId
                                                                plItemSO.Id,//price list item
                                                                'Recurring',//price type
                                                                'Per Unit',// price method
                                                                'Subscription Fee', // charge type
                                                                null,//frequency
                                                                true,//allow manual adj
                                                                true,//allocate group adj
                                                                9485,//listprice
                                                                9485,//baseprice
                                                                'Per Unit',//baserpricemethod,
                                                                100.0,//baseextprice                                                   
                                                                9485,//optionprice
                                                                null,//extprice                                                                
                                                                'TestaPTTUS',//desc
                                                                2,//primarylinenumber
                                                                proposalSO.id// proposalId
                                                                );         
    
    	delete proposalLineItem2;
    } 
}