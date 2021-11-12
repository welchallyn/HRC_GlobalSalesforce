@isTest (seealldata=false)
public with sharing class APTPS_CallbackFactoryTest
{
    private static final String LINE_TYPE_PRODUCT_SERVICE = 'Product/Service';
    private static final String LINE_TYPE_OPTION = 'Option';
    private static final String LINE_STATUS_NEW = 'New';
    
    static testMethod void testMethod1() {
        
        //create config custom class properties
        Apttus_Config2__ConfigCustomClasses__c configCustomClassesProperty = new Apttus_Config2__ConfigCustomClasses__c();
        configCustomClassesProperty.Name = 'Config Custom Classes';
        configCustomClassesProperty.Apttus_Config2__PricingCallbackClass__c = 'APTPS_CustomPricingCallBack';
        insert configCustomClassesProperty;
        
        system.debug('*****************************1');
        
        Account account = new Account(Name = 'APTS TST Account 1', BillingCountryDescription__c   = 'USA');
        insert account;
        
        system.debug('*****************************2');
        
        //create Opportunity
        Opportunity opportunity = new Opportunity(AccountId=account.id, Name='Test Opportunity234343');
        opportunity.Return_Type__c = 'None';
        opportunity.StageName = 'Qualified Opportunity';
        opportunity.CloseDate = system.today();
        opportunity.RMA_Date_1__c = system.today();
        opportunity.RMA_Price_1__c = 100.00 ;
        opportunity.RMA_Product_1__c = 'test product' ;
        opportunity.RMA_Quantity_1__c = 10 ;
        //testOpp.Order_Contact__c = testcontact.id;
        insert opportunity;
        
        system.debug('*****************************3');
        
        //create price list
        Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c(Name = 'APTS TST PriceList 1', Apttus_Config2__Active__c = true);
        insert priceList;

        //Create Product
        list<Product2> productsList = new list<Product2>();
        Product2 product1 = new product2(Name = 'AF 400', ProductCode = 'ATP 0001', Apttus_Config2__ConfigurationType__c = 'Bundle', IsActive = true,
                                        RDTSV3__c='BBD', Reprice_Group_Code__c = 'BBD'); 
        productsList.add(product1);
        
        Product2 product2 = new product2(Name = 'Afinity', ProductCode = 'ATP 0002', Apttus_Config2__ConfigurationType__c = 'Bundle', IsActive = true,
                                        RDTSV3__c='BBD', Reprice_Group_Code__c = 'BBD'); 
        productsList.add(product2);

        Product2 product3 = new product2(Name = 'Fistula Needles (CarePak)', ProductCode = 'ATP 0003', Apttus_Config2__ConfigurationType__c = 'Bundle', IsActive = true,
                                        RDTSV3__c='BBD', Reprice_Group_Code__c = 'BBD'); 
        productsList.add(product3);

        Product2 product4 = new product2(Name = 'Fistula Needles (Non-CarePak)', ProductCode = 'ATP 0004', Apttus_Config2__ConfigurationType__c = 'Bundle', IsActive = true,
                                        RDTSV3__c='BBD', Reprice_Group_Code__c = 'BBD'); 
        productsList.add(product4);

        Product2 product5 = new product2(Name = 'Combiset BVM', ProductCode = 'ATP 0005', Apttus_Config2__ConfigurationType__c = 'Option', IsActive = true,
                                        RDTSV3__c='BBD', Reprice_Group_Code__c = 'BBD'); 
        productsList.add(product5);
        
        Product2 product6 = new product2(Name = 'Combiset, Twister (for use with Transonics)', ProductCode = 'ATP 0006', Apttus_Config2__ConfigurationType__c = 'Option', IsActive = true,
                                        RDTSV3__c='BBD', Reprice_Group_Code__c = 'BBD'); 
        productsList.add(product6);
        
        insert productsList;
        
        system.debug('*****************************4');

        //Create Category
        Apttus_Config2__ClassificationName__c Category= new Apttus_Config2__ClassificationName__c();
        Category.Apttus_Config2__Active__c=true;
        Category.Name='Test';
        Category.Apttus_Config2__Type__c='Offering';
        Category.Apttus_Config2__HierarchyLabel__c='Test';
        insert Category;
        
        system.debug('*****************************5');
        // Create Category Hiearchy
        
        Apttus_Config2__ClassificationHierarchy__c Cth= new Apttus_Config2__ClassificationHierarchy__c();
        Cth.Name='Bloodlines';
        Cth.Apttus_Config2__HierarchyId__c=Category.id;
        Cth.Apttus_Config2__Label__c='Bloodlines';
        insert Cth;


        Apttus_Config2__ProductOptionGroup__c ProductOptionGroup25 = new Apttus_Config2__ProductOptionGroup__c();
        ProductOptionGroup25.CurrencyIsoCode = 'CHF';
        ProductOptionGroup25.Apttus_Config2__OptionGroupId__c = Cth.Id;
        ProductOptionGroup25.Apttus_Config2__ContentType__c = 'Options';
        ProductOptionGroup25.Apttus_Config2__IsHidden__c = false;
        ProductOptionGroup25.Apttus_Config2__IsLeaf__c = true;
        ProductOptionGroup25.Apttus_Config2__IsPicklist__c = false;
        ProductOptionGroup25.Apttus_Config2__Left__c = 2;
        ProductOptionGroup25.Apttus_Config2__Level__c = 1;
        ProductOptionGroup25.Apttus_Config2__MaxTotalQuantityExpressionId__c = null;
        ProductOptionGroup25.Apttus_Config2__MinTotalQuantityExpressionId__c = null;
        ProductOptionGroup25.Apttus_Config2__ModifiableType__c = 'Variable';
        ProductOptionGroup25.Apttus_Config2__ParentOptionGroupId__c = Cth.Id;
        ProductOptionGroup25.Apttus_Config2__ProductAttributeGroupMemberId__c = null;
        ProductOptionGroup25.Apttus_Config2__ProductId__c = product1.Id;
        ProductOptionGroup25.Apttus_Config2__Right__c = 3;
        ProductOptionGroup25.Apttus_Config2__RootOptionGroupId__c = Cth.Id;
        ProductOptionGroup25.Apttus_Config2__RootSequence__c = 1;
        ProductOptionGroup25.Apttus_Config2__Sequence__c = 0;
        ProductOptionGroup25.APTS_Ext_ID__c = 'a6M1100000003ZyEAI';
        insert ProductOptionGroup25;
        
        Apttus_Config2__ProductOptionComponent__c ProductOptionComponent24 = new Apttus_Config2__ProductOptionComponent__c();
        ProductOptionComponent24.CurrencyIsoCode = 'CHF';
        ProductOptionComponent24.Apttus_Config2__AllowCloning__c = false;
        ProductOptionComponent24.Apttus_Config2__AutoUpdateQuantity__c = false;
        ProductOptionComponent24.Apttus_Config2__ComponentProductId__c = product5.Id;
        ProductOptionComponent24.Apttus_Config2__DefaultQuantityExpressionId__c = null;
        ProductOptionComponent24.Apttus_Config2__DefaultQuantity__c = 1.00000;
        ProductOptionComponent24.Apttus_Config2__Default__c = false;
        ProductOptionComponent24.Apttus_Config2__MaxQuantityExpressionId__c = null;
        ProductOptionComponent24.Apttus_Config2__MaxQuantity__c = 1.00000;
        ProductOptionComponent24.Apttus_Config2__MinQuantityExpressionId__c = null;
        ProductOptionComponent24.Apttus_Config2__MinQuantity__c = 0.00000;
        ProductOptionComponent24.Apttus_Config2__Modifiable__c = true;
        ProductOptionComponent24.Apttus_Config2__ParentProductId__c = product1.Id;
        ProductOptionComponent24.Apttus_Config2__ProductOptionGroupId__c = ProductOptionGroup25.Id;
        ProductOptionComponent24.Apttus_Config2__RelationshipType__c = 'Option';
        ProductOptionComponent24.Apttus_Config2__Required__c = false;
        ProductOptionComponent24.Apttus_Config2__Sequence__c = 1;
        ProductOptionComponent24.APTS_Ext_ID__c = 'a6L110000004KDKEA2';
        insert ProductOptionComponent24;
        
        // Create Custom Settings

        system.debug('*****************************6');
        
        Apttus_Proposal__Proposal__c prop = new Apttus_Proposal__Proposal__c();
        prop.Apttus_Proposal__Account__c = account.Id;
        prop.Apttus_Proposal__Proposal_Name__c = 'TestProposal';
        prop.Apttus_Proposal__Opportunity__c = opportunity.Id;
        prop.APTPS_End_User_Country__c = 'US - UNITED STATES';
        prop.Order_Price_Year__c = '2014';
        prop.Override_Contract_Number__c='10150';
        insert prop;

        //create price list items
        list<Apttus_Config2__PriceListItem__c> priceListItems = new list<Apttus_Config2__PriceListItem__c>();

        Apttus_Config2__PriceListItem__c priceListItem1 = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 1000, Apttus_Config2__ProductId__c = product1.Id, Apttus_Config2__ChargeType__c = 'Standard Price');
        priceListItems.add(priceListItem1);
        
        Apttus_Config2__PriceListItem__c priceListItem2 = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 1000, Apttus_Config2__ProductId__c = product2.Id, Apttus_Config2__ChargeType__c = 'Standard Price');
        priceListItems.add(priceListItem2);
        
        Apttus_Config2__PriceListItem__c priceListItem3 = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 1000, Apttus_Config2__ProductId__c = product3.Id, Apttus_Config2__ChargeType__c = 'Standard Price');
        priceListItems.add(priceListItem3);
        
        Apttus_Config2__PriceListItem__c priceListItem4 = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 1000, Apttus_Config2__ProductId__c = product4.Id, Apttus_Config2__ChargeType__c = 'Standard Price');
        priceListItems.add(priceListItem4);
        
        Apttus_Config2__PriceListItem__c priceListItem5 = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 1000, Apttus_Config2__ProductId__c = product5.Id, Apttus_Config2__ChargeType__c = 'Standard Price');
        priceListItems.add(priceListItem5);
        
        Apttus_Config2__PriceListItem__c priceListItem6 = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceList.Id, Apttus_Config2__ListPrice__c = 1000, Apttus_Config2__ProductId__c = product6.Id, Apttus_Config2__ChargeType__c = 'Subscription Fee');
        priceListItems.add(priceListItem6);
        insert priceListItems;
        
        system.debug('*****************************7');

        //create Agreement
        Apttus__APTS_Agreement__c Agreement = new Apttus__APTS_Agreement__c();
        Agreement.Apttus__Account__c=account.id;
        Agreement.Apttus__Subtype__c='PD';
        Agreement.Apttus__Status__c='Request';
        insert Agreement;
        
        system.debug('*****************************8');
        
        //create product configuration
        Apttus_Config2__ProductConfiguration__c configuration = new Apttus_Config2__ProductConfiguration__c(Name = 'APTS TST Configuration 1', 
                                                                                                            Apttus_QPConfig__Proposald__c = prop.id, Apttus_Config2__AccountId__c = account.Id, Apttus_Config2__PriceListId__c = priceList.Id,  Apttus_Config2__Status__c = LINE_STATUS_NEW, Apttus_Config2__VersionNumber__c = 1, Apttus_Config2__EffectivePriceListId__c = priceList.Id
                                                                                               );
        insert configuration;
        
        

        //Add Products to cart
        Apttus_CPQApi.CPQ.AddBundleRequestDO bundleRequest = new Apttus_CPQApi.CPQ.AddBundleRequestDO();
        bundleRequest.CartId = configuration.Id;
        bundleRequest.SelectedBundle = new Apttus_CPQApi.CPQ.SelectedBundleDO();
        bundleRequest.SelectedBundle.SelectedProduct = new Apttus_CPQApi.CPQ.SelectedProductDO();
        bundleRequest.SelectedBundle.SelectedProduct.ProductId = product1.Id;
        bundleRequest.SelectedBundle.SelectedProduct.Quantity = 1;
        Apttus_CPQApi.CPQ.AddBundleResponseDO bunleResponse = Apttus_CPQApi.CPQWebService.addBundle(bundleRequest);


        List<Apttus_CPQApi.CPQ.SelectedOptionDO> selectedOptDOList = new List<Apttus_CPQApi.CPQ.SelectedOptionDO>();
        Apttus_CPQApi.CPQ.SelectedOptionDO selectedOptDO1 = new Apttus_CPQApi.CPQ.SelectedOptionDO();
        selectedOptDO1.ComponentId = ProductOptionComponent24.Id;
        selectedOptDO1.ComponentProductId = ProductOptionComponent24.Apttus_Config2__ComponentProductId__c;
        selectedOptDO1.Quantity = 1;
        selectedOptDOList.add(selectedOptDO1);
        Apttus_CPQApi.CPQ.AddOptionsResponseDO addOptRespDO = Apttus_CPQApi.CPQWebService.addOptions(configuration.Id,Integer.valueOf(bunleResponse.LineNumber), selectedOptDOList);  

        
        
        List<Net_Pricing__c> listPricing = new List<Net_Pricing__c>();
        
        Net_Pricing__c objPricing1 = new Net_Pricing__c(Lead_Contract__c = '2014',
                                                        Pricing_Product__c = 'ATP 0005', 
                                                        Reprice_Code__c = 'BBD',
                                                        Value__c = 20000);
        listPricing.add(objPricing1);
        Net_Pricing__c objPricing2 = new Net_Pricing__c(Lead_Contract__c = '2014',
                                                        Pricing_Product__c = 'ATP 0006', 
                                                        Reprice_Code__c = 'BBD',
                                                        Value__c = 18000);
        listPricing.add(objPricing2);
        Net_Pricing__c objPricing3 = new Net_Pricing__c(Lead_Contract__c = '2014',
                                                        Pricing_Product__c = 'ATP 0001', 
                                                        Reprice_Code__c = 'BBD',
                                                        Value__c = 35000);
        listPricing.add(objPricing3);        
        
        insert listPricing;
        
        List<Adjustment_Schedule__c> listSchedule = new List<Adjustment_Schedule__c>();
        Adjustment_Schedule__c objSchedule1 = new Adjustment_Schedule__c(
        Reprice_Code__c ='BBD',
        Pricing_Contract__c='10150',
        Tier__c =1,
        Order_Year__c ='2014',
            Contract_Year__c ='2014',
        Discount__c = 20.00,
        Name ='Schedule1');
        listSchedule.add(objSchedule1);
        
        Adjustment_Schedule__c objSchedule2 = new Adjustment_Schedule__c(
        Reprice_Code__c ='BBD',
        Pricing_Contract__c='10150',
        Tier__c =1,
        Order_Year__c ='2014',
            Contract_Year__c ='2014',
        Discount__c = 20.00,
        Name ='Schedule2');
        listSchedule.add(objSchedule2);
        
        insert listSchedule;
        
        Apttus_Config2__LineItem__c lineItemSO = getLineItem(configuration.Id, null, 1, true,
                                                                    1, 'Product/Service', product1.Id, true, null,
                                                                    product1.Id, null, null, 1, true,
                                                                    'Each', 1, priceList.Id, priceListItem1.Id,
                                                                    'One Time', 'Per Unit', 'Year 1', null,
                                                                    true, true, 9485, 9485, 'Per Unit',
                                                                    9485, null, 9485, 'TestaPTTUS');
        insert lineItemSO;
        
        test.startTest();
        
        Boolean result = Apttus_Config2.PricingWebService.computeBasePriceForItemColl(configuration.Id, 1);

        List<Apttus_Config2__LineItem__c> productServiceLine = [SELECT Id,Discretionary_Discount_Type__c,APTS_Discretionary_Discount__c from Apttus_Config2__LineItem__c where Apttus_Config2__LineType__c = :LINE_TYPE_PRODUCT_SERVICE];

        productServiceLine[0].Discretionary_Discount_Type__c = 'Price Override';
        productServiceLine[0].APTS_Discretionary_Discount__c = 10000.00;
        update productServiceLine[0];

        result = Apttus_Config2.PricingWebService.computeNetPriceForItemColl(configuration.Id, 1);

        Apttus_Config2.PricingWebService.computeBasicPriceForItemColl(configuration, new List<Apttus_Config2__LineItem__c>{lineItemSO});
        
        
        test.stopTest();
    }
    
    public static Apttus_Config2__LineItem__c getLineItem(ID configId,
                                                         ID groupId,
                                                         Integer lineNumber,
                                                         Boolean isPrimaryLine,
                                                         Integer itemSeq,
                                                         String lineType,
                                                         ID productId,
                                                         Boolean customizable,
                                                         ID productOptionId,
                                                         ID optionId,
                                                         ID classId,
                                                         String classHierarchy,
                                                         Decimal quantity,
                                                         Boolean isQtyModifiable,
                                                         String uom,
                                                         Integer term,
                                                         ID priceListId,
                                                         ID plItemId,
                                                         String priceType,
                                                         String priceMethod,
                                                         String chargeType,
                                                         String frequency,
                                                         Boolean allowManualAdj,
                                                         Boolean allocateGroupAdj,
                                                         Decimal listPrice,
                                                         Decimal basePrice,
                                                         String basePriceMethod,
                                                         Decimal baseExtPrice,
                                                         Decimal optionPrice,
                                                         Decimal extPrice,
                                                         String lineDesc){
        
        Apttus_Config2__LineItem__c lineItemSO = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = configId);
        lineItemSO.Apttus_Config2__LineNumber__c = lineNumber;
        lineItemSO.Apttus_Config2__IsPrimaryLine__c = isPrimaryLine;
        lineItemSO.Apttus_Config2__PrimaryLineNumber__c = 1;
        lineItemSO.Apttus_Config2__ItemSequence__c = itemSeq;
        lineItemSO.Apttus_Config2__SummaryGroupId__c = groupId;
        lineItemSO.Apttus_Config2__LineType__c = lineType;
        lineItemSO.Apttus_Config2__ProductId__c = productId;
        lineItemSO.Apttus_Config2__Customizable__c = customizable;
        lineItemSO.Apttus_Config2__ProductOptionId__c = productOptionId;
        lineItemSO.Apttus_Config2__OptionId__c = optionId;
        lineItemSO.Apttus_Config2__ClassificationId__c = classId;
        lineItemSO.Apttus_Config2__ClassificationHierarchy__c = classHierarchy;
        lineItemSO.Apttus_Config2__Quantity__c = quantity;
        lineItemSO.Apttus_Config2__IsQuantityModifiable__c = isQtyModifiable;
        lineItemSO.Apttus_Config2__Uom__c = uom;
        lineItemSO.Apttus_Config2__Term__c = term;
        lineItemSO.Apttus_Config2__PriceListId__c = priceListId;
        lineItemSO.Apttus_Config2__PriceListItemId__c = plItemId;
        lineItemSO.Apttus_Config2__PriceType__c = priceType;
        lineItemSO.Apttus_Config2__PriceMethod__c = priceMethod;
        lineItemSO.Apttus_Config2__ChargeType__c = chargeType;
        lineItemSO.Apttus_Config2__Frequency__c = frequency;
        lineItemSO.Apttus_Config2__AllowManualAdjustment__c = allowManualAdj;
        lineItemSO.Apttus_Config2__AllocateGroupAdjustment__c = allocateGroupAdj;
        lineItemSO.Apttus_Config2__ListPrice__c = listPrice;
        lineItemSO.Apttus_Config2__BasePrice__c = basePrice;
        lineItemSO.Apttus_Config2__BasePriceMethod__c = basePriceMethod;
        lineItemSO.Apttus_Config2__BaseExtendedPrice__c = baseExtPrice;
        lineItemSO.Apttus_Config2__OptionPrice__c = optionPrice;
        lineItemSO.Apttus_Config2__ExtendedPrice__c = extPrice;
        lineItemSO.Apttus_Config2__Description__c = lineDesc;
        lineItemSO.Apttus_Config2__AdjustedPrice__c = 0;

        return lineItemSO;
    }
}