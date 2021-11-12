@isTest (seeAllData=true)
public class testProductDeepClone {
    private static final String LINE_TYPE_PRODUCT_SERVICE = 'Product/Service';
    private static final String LINE_TYPE_OPTION = 'Option';
    private static final String LINE_STATUS_NEW = 'New';
    static testMethod void myTest() {

        String selects = '';
        String objectName = 'product2';
        String whereClause = 'Id =:productID';
        
        
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable() && fd.getName() != 'APTS_Ext_ID__c'){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        } 
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
             
        }
        
        System.assertNotEquals(null, APTSCU_productDeepCloneController.getQueryStringWithAllFields(objectName, null));
        System.assertEquals('SELECT ' + selects + ' FROM ' + objectName, APTSCU_productDeepCloneController.getQueryStringWithAllFields(objectName, null));
        System.assertNotEquals(null, APTSCU_productDeepCloneController.getQueryStringWithAllFields(objectName, whereClause));
        System.assertEquals('SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause, APTSCU_productDeepCloneController.getQueryStringWithAllFields(objectName, whereClause));

        
        //TEST REDIRECT
        
         //Price List Entry        
        Apttus_Config2__PriceList__c priceList = new Apttus_Config2__PriceList__c(Name = 'US Price List Test', Apttus_Config2__Active__c = true);
        insert priceList;
        
        system.debug('start testAccount');
        //Account
        Account testAccount = new Account(Name = 'test Account', Site = 'www.apttus.com',BillingCountry='United States');
        insert testAccount;
        
        Pricing_Contract__c objPricingContract = new Pricing_Contract__c();
        objPricingContract.Account__c = testAccount.id;
        objPricingContract.Contract__c = '14501';
        objPricingContract.Contract_Description__c = 'Test Pricing Contract1';
        objPricingContract.Contract_Start_Date__c = Date.Today();
        objPricingContract.Contract_End_Date__c =  Date.Today().addDays(365);
        insert objPricingContract;

        system.debug('start productsList');
        //Product
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

        //Insert Apttus_Config2__ClassificationName__c
        Apttus_Config2__ClassificationName__c cnSO = new Apttus_Config2__ClassificationName__c(
            Apttus_Config2__Active__c = true,
            APTS_Ext_ID__c = '55555',
            APTS_ID_from_Sandbox__c = '77757',
            Apttus_Config2__HierarchyLabel__c = 'Test Label',
            Apttus_Config2__Type__c = 'Option Group');
        insert cnSO;

        //Insert Apttus_Config2__ClassificationHierarchy__c
        Apttus_Config2__ClassificationHierarchy__c chSO = new Apttus_Config2__ClassificationHierarchy__c(
            APTS_Ext_ID__c = '7382982',
            APTS_ID_from_Sandbox__c = '7748329',
            Apttus_Config2__DefaultSearchCategory__c = true,
            Apttus_Config2__Description__c = 'Test',
            Apttus_Config2__ExpandedByDefault__c = true,
            Apttus_Config2__HierarchyId__c = cnSO.Id,
            Apttus_Config2__Label__c = 'Test Label');
            //,Apttus_Config2__ProductAttributeGroupId__c = );
        insert chSO;

        //Insert Apttus_Config2__ProductClassification__c
        Apttus_Config2__ProductClassification__c pcSO = new Apttus_Config2__ProductClassification__c(
            APTS_Ext_ID__c = '99115',
            //APTS_ID_from_Sandbox__c = '55588',
            Apttus_Config2__ClassificationId__c  = chSO.Id,
            Apttus_Config2__Default__c = false,
            //Apttus_Config2__DefaultQuantity__c,
            //Apttus_Config2__MaxQuantity__c,
            //Apttus_Config2__MinQuantity__c,
            Apttus_Config2__Modifiable__c = true,
            Apttus_Config2__ProductId__c = product1.Id);
        insert pcSO;

        //Insert Apttus_Config2__ProductOptionGroup__c
        Apttus_Config2__ProductOptionGroup__c poSO = new Apttus_Config2__ProductOptionGroup__c(
            Apttus_Config2__OptionGroupId__c = chSO.Id,
            Apttus_Config2__ProductId__c = product1.Id,
            Apttus_Config2__Sequence__c = 1);
        insert poSO;

        Apttus_Config2__ProductOptionComponent__c prodOptionCompSO = new Apttus_Config2__ProductOptionComponent__c(
            Apttus_Config2__AllowCloning__c = true,
            Apttus_Config2__ParentProductId__c = product1.Id,
            Apttus_Config2__ProductOptionGroupId__c = poSO.Id,
            Apttus_Config2__Sequence__c = 1);
        insert prodOptionCompSO;

        Apttus_Config2__ProductGroup__c prodGroupSO = new Apttus_Config2__ProductGroup__c(
            Name = 'Test Name',
            Apttus_Config2__Description__c = 'Test Product');
        insert prodGroupSO;

        Apttus_Config2__ProductGroupMember__c prodGMSO = new Apttus_Config2__ProductGroupMember__c(
            Apttus_Config2__ProductId__c = product1.Id,
            Apttus_Config2__ProductGroupId__c = prodGroupSO.Id,
            Apttus_Config2__Sequence__c = 1);
        insert prodGMSO;

        Apttus_Config2__ProductConstraint__c prodConstraintSO = new Apttus_Config2__ProductConstraint__c(
            Apttus_Config2__Active__c = true,
            Apttus_Config2__Description__c = 'Test Descrip',
            Apttus_Config2__ProductId__c = product1.Id,
            Apttus_Config2__ProductGroupId__c = prodGroupSO.Id,
            Apttus_Config2__Sequence__c = 1,
            Apttus_Config2__ProductCategory__c = 'Test');
        insert prodConstraintSO;

        Apttus_Config2__ProductConstraintEntry__c prodConstEntrySO = new Apttus_Config2__ProductConstraintEntry__c(
            Apttus_Config2__IncludeProductId__c = product1.Id,
            Apttus_Config2__ProductConstraintId__c = prodConstraintSO.Id,
            Apttus_Config2__SelectedProduct1Id__c = product3.Id,
            //Apttus_Config2__SelectedProductGroupId__c = prodGroupSO,
            Apttus_Config2__Sequence__c = 1);
        insert prodConstEntrySO;

        //Attribute Group
        Apttus_Config2__ProductAttributeGroup__c attGroupSO = new Apttus_Config2__ProductAttributeGroup__c();
            attGroupSO.Apttus_Config2__BusinessObject__c = 'Apttus_Config2__ProductAttributeValue__c';
        insert attGroupSO;

        //Product Attribute Group
        Apttus_Config2__ProductAttribute__c paSO = new Apttus_Config2__ProductAttribute__c();
            paSO.Apttus_Config2__AttributeGroupId__c = attGroupSO.Id;
            paSO.Apttus_Config2__Field__c = 'APTPS_Accent_Color__c';
            paSO.Apttus_Config2__Sequence__c = 1;
        insert paSO;

        //Insert Price Dimension
        Apttus_Config2__PriceDimension__c pdSO = new Apttus_Config2__PriceDimension__c(
            Apttus_Config2__AttributeId__c = paSO.Id,
            Apttus_Config2__BusinessObject__c = 'Apttus_Config2__LineItem__c',
            Apttus_Config2__Type__c = 'Standard',
            Apttus_Config2__Datasource__c = 'Test Data Source');
        insert pdSO;

        //Insert Price Matrix
        Integer dimentions = 0;
        Apttus_Config2__PriceMatrix__c priceMatrix = new Apttus_Config2__PriceMatrix__c();
            priceMatrix.Apttus_Config2__PriceListItemId__c = priceListItem1.Id;
            priceMatrix.Apttus_Config2__Sequence__c = 1;
            priceMatrix.Apttus_Config2__Dimension1Id__c = pdSO.Id;
        insert priceMatrix;

        //Insert Price Matrix Entry
        Apttus_Config2__PriceMatrixEntry__c priceMatrixEntry = new Apttus_Config2__PriceMatrixEntry__c(
            Apttus_Config2__AdjustmentAmount__c = 100,
            Apttus_Config2__AdjustmentType__c = 'List Price Override',
            Apttus_Config2__Dimension1Value__c = 'APTPS_Accent_Color__c',
            Apttus_Config2__PriceMatrixId__c = priceMatrix.Id,
            Apttus_Config2__Sequence__c = 1);
        insert priceMatrixEntry;

        //Insert Product Information
        Apttus_Config2__ProductInformation__c prodInfoSO = new Apttus_Config2__ProductInformation__c(
            Apttus_Config2__ClassificationId__c = chSO.Id,
            Apttus_Config2__Description__c = 'Test Description',
            Apttus_Config2__ProductId__c = product1.Id);
        insert prodInfoSO;
        
        //Constraint Rule
        Apttus_Config2__ConstraintRule__c crSO = new Apttus_Config2__ConstraintRule__c(
            Apttus_Config2__Active__c = true,
            Apttus_Config2__Sequence__c = 1);
        insert crSO;
        
        //Constraint Rule Condition
        Apttus_Config2__ConstraintRuleCondition__c crcSO = new Apttus_Config2__ConstraintRuleCondition__c(
            Apttus_Config2__ConstraintRuleId__c = crSO.Id,
            Apttus_Config2__ProductId__c = product1.Id,
            Apttus_Config2__MatchInOptions__c = true,
            //Apttus_Config2__ProductGroupId__c = prodGroupSO.Id,
            Apttus_Config2__ProductScope__c = 'Product',
            Apttus_Config2__Sequence__c = 1);
        insert crcSO;

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

        Apttus_Config2__SearchAttributeValue__c searchAttValSO = new Apttus_Config2__SearchAttributeValue__c(
            Apttus_Config2__BaseProductId__c = product1.Id,
            Apttus_Config2__CategoryId__c = cnSO.Id,
            Apttus_Config2__ConfigurationId__c = configuration.Id,
            Apttus_Config2__ValueType__c = 'Product');
        insert searchAttValSO;
        
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
        
        /*
         //Insert Apttus_Config2__ClassificationName__c
        Apttus_Config2__ClassificationName__c cnSO = new Apttus_Config2__ClassificationName__c(
          Apttus_Config2__Active__c = true,
          APTS_Ext_ID__c = '55555',
          APTS_ID_from_Sandbox__c = '77757',
          Apttus_Config2__HierarchyLabel__c = 'Test Label',
          Apttus_Config2__Type__c = 'Option Group');

        //Insert Apttus_Config2__ClassificationHierarchy__c
        Apttus_Config2__ClassificationHierarchy__c chSO = new Apttus_Config2__ClassificationHierarchy__c(
          APTS_Ext_ID__c = '7382982',
          APTS_ID_from_Sandbox__c = '7748329',
          Apttus_Config2__DefaultSearchCategory__c = true,
          Apttus_Config2__Description__c = 'Test',
          Apttus_Config2__ExpandedByDefault__c = true,
          Apttus_Config2__HierarchyId__c = cnSO.Id,
          Apttus_Config2__Label__c = 'Test Label');
          //,Apttus_Config2__ProductAttributeGroupId__c = );
        insert chSO;

        //Insert Apttus_Config2__ProductClassification__c
        Apttus_Config2__ProductClassification__c pcSO = new Apttus_Config2__ProductClassification__c(
          APTS_Ext_ID__c = '99115',
          APTS_ID_from_Sandbox__c = '55588',
          Apttus_Config2__ClassificationId__c   = cnSO.Id,
          Apttus_Config2__Default__c = false,
          //Apttus_Config2__DefaultQuantity__c,
          //Apttus_Config2__MaxQuantity__c,
          //Apttus_Config2__MinQuantity__c,
          Apttus_Config2__Modifiable__c = true,
          Apttus_Config2__ProductId__c = product1.Id);
        insert pcSO;
        */
        
     PageReference pageRef = Page.APTSCU_productDeepCloning;
     Test.setCurrentPage(pageRef);
     
     ApexPages.currentPage().getParameters().put('id', product1.Id);
        
        
     APTSCU_productDeepCloneController controller = new APTSCU_productDeepCloneController();
     PageReference nextpage = controller.redirect();
     System.assertNotEquals(null, nextpage);
     }
}