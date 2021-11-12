/*
*  APTS_TestDataFactoryUtil - Utility class to generate test data 
* Author: Axaykumar Varu (avaru@apttus.com) - 15.DEC.2014
* Apttus Inc (c) 2014 All Rights reserved.
*/
@isTest
public with sharing class APTS_TestDataFactoryUtil {  
	
	public static Account getAccount(String rtName, String aType){
		
		ID rtID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(rtName).getRecordTypeID();
		Account acc = new Account(name = 'testApttusAcc', RecordTypeId = rtID, Type = aType);
		return acc;
	}
	
	public static Opportunity getOpportunity(Account acc, String rtName, String stageName, String oType, String oWorkService, String oLeadSrc, Decimal oListPrice){
		
		ID rtID = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(rtName).getRecordTypeID();
		Opportunity opty = new Opportunity(AccountId = acc.Id, Name = 'test Apttus Opty');
		opty.StageName = stageName;
		opty.CloseDate = Date.today().addDays(100);
		opty.Type = oType;
		
		opty.LeadSource = oLeadSrc;
		
		return opty;
    }
	 
	
	/**
     * Creates a product for the given user
     * @param productName the product name
     * @param productCode the product code
     * @param productFamily the product family
     * @param productDesc the product description
     * @param configType the configuration type
     * @param unitOfMeasure the unit of measure
     * @param customizable the product customizable indicator
     * @param effectiveDate the product effective date
     * @param expirationDate the product expiration date
     * @return the product
     */ 
    public static Product2 createProduct(String productName, 
                                   String productCode, 
                                   String productFamily, 
                                   String productDesc,
                                   String configType,
                                   String unitOfMeasure,
                                   Boolean customizable,
                                   Date effectiveDate,
                                   Date expirationDate) {
        
        // create a new product
        Product2 product = new Product2(Name=productName);
        
        // setup product data
        
        // product code
        
        product.ProductCode = productCode;
        // product family
        product.Family = productFamily;
        // description
        product.Description = productDesc;
        // configuration type
        product.Apttus_Config2__ConfigurationType__c = configType;
        // unit of measure
        product.Apttus_Config2__Uom__c = unitOfMeasure;
        // customizable
        product.Apttus_Config2__Customizable__c = customizable;
        // effective date
        product.Apttus_Config2__EffectiveDate__c = effectiveDate;
        // expiration date
        product.Apttus_Config2__ExpirationDate__c = expirationDate;
        
        // insert product
        insert product;
        
        System.assert(product.Id != null, 'Failed to create the product for owner ' + UserInfo.getUserId());
            
        return product;
        
    } 
    
    /**
     * Creates a price list for the given user
     * @param priceListName the price list name
     * @param priceListDesc the price list description
     * @param effectiveDate the price list effective date
     * @param expirationDate the price list expiration date
     * @return the price list
     */
    public static Apttus_Config2__PriceList__c createPriceList(String priceListName, 
                                                         String priceListDesc,
                                                         Date effectiveDate,
                                                         Date expirationDate) {
        
        // create a new pricelist
        Apttus_Config2__PriceList__c priceListSO = new Apttus_Config2__PriceList__c(Name = priceListName, OwnerId = UserInfo.getUserId());
        
        // setup price list data
        
        // description
        priceListSO.Apttus_Config2__Description__c = priceListDesc;
        // effective date
        priceListSO.Apttus_Config2__EffectiveDate__c = effectiveDate;
        // expiration date
        priceListSO.Apttus_Config2__ExpirationDate__c = expirationDate;
        // active
        priceListSO.Apttus_Config2__Active__c = true;
        
         
        
        // insert price list
        insert priceListSO;
        
        System.assert(priceListSO.Id != null, 'Failed to create the price list for owner ' + UserInfo.getUserId());
            
        return priceListSO;
        
    } 
    
    /**
     * Creates a price list item for the given user
     * @param priceListId the price list Id
     * @param productId the product Id
     * @param chargeType the charge type
     * @param priceType the price type
     * @param priceMethod the price method
     * @param listPrice the list price
     * @param minPrice the minimum price
     * @param maxPrice the maximum price
     * @param minMaxPriceAppliesTo the minmax price applies to
     * @param effectiveDate the entry effective date
     * @param expirationDate the entry expiration date
     * @return the price list item
     */
    public static Apttus_Config2__PriceListItem__c createPriceListItem(ID priceListId,
                                                                 ID productId, 
                                                                 String chargeType,
                                                                 String priceType,
                                                                 String priceMethod,
                                                                 Decimal listPrice,
                                                                 Decimal minPrice,
                                                                 Decimal maxPrice,
                                                                 String minMaxPriceAppliesTo,
                                                                 Date effectiveDate,
                                                                 Date expirationDate,
                                                                 boolean active) {
        
        // create a new pricelist item
        Apttus_Config2__PriceListItem__c itemSO = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = priceListId);
        
        // setup price list entry data
        
        // product id
        itemSO.Apttus_Config2__ProductId__c = productId;
        // charge type
        itemSO.Apttus_Config2__ChargeType__c = chargeType;
        // price type
        itemSO.Apttus_Config2__PriceType__c = priceType;
        // price method
        itemSO.Apttus_Config2__PriceMethod__c = priceMethod;
        // list price
        itemSO.Apttus_Config2__ListPrice__c = listPrice;
        // min price
        itemSO.Apttus_Config2__MinPrice__c = minPrice;
        // max price
        itemSO.Apttus_Config2__MaxPrice__c = maxPrice;
        // max price
        itemSO.Apttus_Config2__MinMaxPriceAppliesTo__c = minMaxPriceAppliesTo;
        // effective date
        itemSO.Apttus_Config2__EffectiveDate__c = effectiveDate;
        // expiration date
        itemSO.Apttus_Config2__ExpirationDate__c = expirationDate;
        
        itemSO.Apttus_Config2__Active__c =  active;
        
        // insert price list item
        insert itemSO;
        
        System.assert(itemSO.Id != null, 'Failed to create the price list item for owner ' + UserInfo.getUserId());
            
        return itemSO;
        
    } 
    
    /**
     * Creates a quote/proposal for the given user
     * @param qpName the quote/proposal name
     * @param opptyId the related opportunity id
     * @param approvalDate the quote/proposal approval date
     * @param expirationDate the quote/proposal expiration date
     * @param priceListId the price list id
     * @param pricingDate the pricing date
     * @param maintDuration the maintenance duration
     * @return the quote/proposal
     */
    public static Apttus_Proposal__Proposal__c createQuoteOrProposal(String qpName,
                                                               ID opptyId,
                                                               Date approvalDate, 
                                                               Date expirationDate, 
                                                               ID priceListId,
                                                               Date pricingDate,
                                                               String maintDuration,
                                                               boolean stubyearquote, Id accountId) {

        //RecordType Rt=[select id,name,developername from recordType where sobjectType='Apttus_Proposal__Proposal__c' and DeveloperName='AMS_Proposal'];
        
        // create a new quote/proposal
        Apttus_Proposal__Proposal__c proposalSO = new Apttus_Proposal__Proposal__c(OwnerId = UserInfo.getUserId());
        // setup proposal data
        
        // proposal name
        proposalSO.Apttus_Proposal__Proposal_Name__c = qpName;
        //proposalSO.RecordTypeId = Rt.Id;
        // opportunity
        proposalSO.Apttus_Proposal__Opportunity__c = opptyId;
        // approval date
        proposalSO.Apttus_Proposal__Proposal_Approval_Date__c = approvalDate;
        // expiration date
        proposalSO.Apttus_Proposal__Proposal_Expiration_Date__c = date.today().addMonths(8);
        // expected start date
        proposalSO.Apttus_Proposal__ExpectedStartDate__c = Date.today();
        // expected end date
        proposalSO.Apttus_Proposal__ExpectedEndDate__c = Date.today().addMonths(12);
        // price list id
        proposalSO.Apttus_QPConfig__PriceListId__c = priceListId;
        // pricing date
        proposalSO.Apttus_QPConfig__PricingDate__c = pricingDate;
        
       
        proposalSO.Apttus_Proposal__Account__c = accountId;  
         
        insert proposalSO; 
        
        system.assert(proposalSO.Id != null, 'Failed to create the quote/proposal for owner ' + UserInfo.getUserId());
            
        return proposalSO;
        
    } 
    
    /**
     * Creates a product configuration for the given user
     * @param configName the configuration name
     * @param versionNbr the version number
     * @param bObjectId the business object id
     * @param bObjectType the business object type
     * @param groupType the summary group type
     * @param priceListId the price list Id
     * @param ancestorId the ancestor id
     * @param status the configuration status
     * @param finalizedDate the finalized date
     * @param effectiveDate the effective date
     * @param isTransient the transient configuration indicator
     * @param configDesc the configuration description
     * @return the product configuration group
     */
    public static Apttus_Config2__ProductConfiguration__c createProductConfiguration(String configName,
                                                                               Integer versionNbr,
                                                                               ID bObjectId,
                                                                               String bObjectType,
                                                                               String groupType,
                                                                               ID priceListId, 
                                                                               ID ancestorId, 
                                                                               String status, 
                                                                               Datetime finalizedDate, 
                                                                               Datetime effectiveDate, 
                                                                               Boolean isTransient,
                                                                               String configDesc) {
        
        // create a new classification name
        Apttus_Config2__ProductConfiguration__c configSO = new Apttus_Config2__ProductConfiguration__c(Name = configName, OwnerId = UserInfo.getUserId());
        
        // setup product configuration data
        
        // version number
        configSO.Apttus_Config2__VersionNumber__c = versionNbr;
        // summary group type
        configSO.Apttus_Config2__SummaryGroupType__c = groupType;
        // business object 
        configSO.Apttus_Config2__BusinessObjectId__c = bObjectId;
        // business object type
        configSO.Apttus_Config2__BusinessObjectType__c = bObjectType;
        // proposal id
        configSO.Apttus_QPConfig__Proposald__c = bObjectId;
        // price list id
        configSO.Apttus_Config2__PriceListId__c = priceListId;
        // ancestor id
        configSO.Apttus_Config2__AncestorId__c = ancestorId;
        // status 
        configSO.Apttus_Config2__Status__c = status;
        // is transient
        configSO.Apttus_Config2__IsTransient__c = isTransient;
        // finalized date
        configSO.Apttus_Config2__FinalizedDate__c = finalizedDate;
        // effective date
        configSO.Apttus_Config2__EffectiveDate__c = effectiveDate; 
        // description
        configSO.Apttus_Config2__Description__c = configDesc;
        
        // insert product configuration
        insert configSO;
        
        System.assert(configSO.Id != null, 'Failed to create the product configuration for owner ' + UserInfo.getUserId());
            
        return configSO;
        
    } 
    
    
          
    /**
     * Creates a proposal line item for the given user
     * @param configId the product configuration Id
     * @param groupId the summary group id
     * @param lineNumber the line number
     * @param isPrimaryLine the primary line indicator
     * @param itemSeq the item sequence
     * @param lineType the line type
     * @param productId the product Id
     * @param customizable the product customizable indicator
     * @param productOptionId the product option Id
     * @param optionId the option Id
     * @param classId the leaf classification id
     * @param classHierarchy the classification hierarchy
     * @param quantity the line quantity
     * @param isQtyModifiable the quantity modifiable indicator
     * @param uom the unit of measure
     * @param term the term
     * @param priceListId the price list Id
     * @param plItemId the price list item id
     * @param priceType the price type
     * @param priceMethod the price method
     * @param chargeType the charge type
     * @param frequency the frequency
     * @param allowManualAdj the manual adjustment indicator
     * @param allocateGroupAdj the allocate group adjustment indicator
     * @param listPrice the list price
     * @param basePrice the base price
     * @param basePriceMethod the base price method
     * @param baseExtPrice the base extended price
     * @param optionPrice the option price
     * @param extPrice the extended price
     * @param lineDesc the line item description
     * @return the line item
     */
    public static Apttus_Proposal__Proposal_Line_Item__c createProposalLineItem(ID configId,
                                                       ID groupId,
                                                       Integer lineNumber,
                                                       Boolean isPrimaryLine,
                                                       Integer itemSeq,
                                                       String lineType,
                                                       ID productId,                                                      
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
                                                       String lineDesc,
                                                       integer primarylineNumber,
                                                       //integer year
                                                       ID proposalid) {
        System.debug('in');
        // create a new line item
        Apttus_Proposal__Proposal_Line_Item__c proposallineItemSO = new Apttus_Proposal__Proposal_Line_Item__c();//Apttus_QPConfig__ConfigurationId__c= configId);
        
        // setup line item data
        proposallineItemSO.Apttus_QPConfig__ConfigurationId__c = configId;
        // line number
        proposallineItemSO.Apttus_QPConfig__LineNumber__c = lineNumber;
        // primary line
        proposallineItemSO.Apttus_QPConfig__IsPrimaryLine__c = isPrimaryLine;
        // item sequence
        proposallineItemSO.Apttus_QPConfig__PrimaryLineNumber__c=primarylineNumber;
        proposallineItemSO.Apttus_QPConfig__ItemSequence__c = itemSeq;
        // summary group id
        proposallineItemSO.Apttus_QPConfig__SummaryGroupId__c = groupId;
        // line type
        proposallineItemSO.Apttus_QPConfig__LineType__c = lineType;
        // product id
        proposallineItemSO.Apttus_Proposal__Product__c = productId;
        // product option id
        proposallineItemSO.Apttus_QPConfig__ProductOptionId__c = productOptionId;
        // option id
        proposallineItemSO.Apttus_QPConfig__OptionId__c = optionId;
        // classification id
        proposallineItemSO.Apttus_QPConfig__ClassificationId__c = classId;
        // classification hierarchy
        proposallineItemSO.Apttus_QPConfig__ClassificationHierarchy__c = classHierarchy;
        // quantity
        proposallineItemSO.Apttus_Proposal__Quantity__c= quantity;
        // quantity modifiable
        //proposallineItemSO.Apttus_QPConfig__IsQuantityModifiable__c = isQtyModifiable;
        // uom
        proposallineItemSO.Apttus_QPConfig__Uom__c = uom;
        // term
        proposallineItemSO.Apttus_QPConfig__Term__c = term;
        // price list id
        proposallineItemSO.Apttus_QPConfig__PriceListId__c = priceListId;
        // price list item id
        proposallineItemSO.Apttus_QPConfig__PriceListItemId__c = plItemId;
        // price type
        proposallineItemSO.Apttus_QPConfig__PriceType__c = priceType;
        // price method
        proposallineItemSO.Apttus_QPConfig__PriceMethod__c = priceMethod;
        // charge type
        proposallineItemSO.Apttus_QPConfig__ChargeType__c = chargeType;
        // frequency
        proposallineItemSO.Apttus_QPConfig__Frequency__c = frequency;
        // allow manual adjustment
        //proposallineItemSO.Apttus_QPConfig__AdjustmentAmount__c= allowManualAdj;
        // allocate group adjustment
        //proposallineItemSO.Apttus_QPConfig__PriceAdjustment__c= allocateGroupAdj;
        // list price
        proposallineItemSO.Apttus_QPConfig__ListPrice__c = listPrice;
        // base price
        proposallineItemSO.Apttus_QPConfig__BasePrice__c = basePrice;
        // base price mthod
        proposallineItemSO.Apttus_QPConfig__BasePriceMethod__c = basePriceMethod;
        // base extended price
        proposallineItemSO.Apttus_QPConfig__BaseExtendedPrice__c = baseExtPrice;
        // option price
        proposallineItemSO.Apttus_QPConfig__OptionPrice__c = optionPrice;
        // extended price
        proposallineItemSO.Apttus_QPConfig__ExtendedPrice__c = extPrice;
        // description
        proposallineItemSO.Apttus_Proposal__Description__c= lineDesc;        
        proposallineItemSO.Apttus_Proposal__Proposal__c = proposalid;               
        proposallineItemSO.apttus_qpconfig__isprimaryrampline__c = true;    
        proposallineItemSO.apttus_qpconfig__isusagetiermodifiable__c = true;
        proposallineItemSO.Apttus_QPConfig__HasAttributes__c = true;
        proposallineItemSO.apttus_qpconfig__hasoptions__c = true;
        proposallineItemSO.apttus_qpconfig__hideinvoicedisplay__c = true;
        proposallineItemSO.apttus_qpconfig__isassetpricing__c = true;  
        proposallineItemSO.apttus_qpconfig__iscustompricing__c  = true;                                                                                                                                                                                                  
        proposallineItemSO.Apttus_QPConfig__IsOptionRollupLine__c = true;
        proposallineItemSO.apttus_qpconfig__priceincludedinbundle__c = true;
        proposallineItemSO.apttus_qpconfig__taxinclusive__c = true;
        proposallineItemSO.apttus_qpconfig__taxable__c = true;
        proposallineItemSO.Apttus_QPConfig__ChargeType__c  ='Rental Fee';
        // insert line itemtest
        insert proposallineItemSO;
        
       // System.assert(proposallineItemSO.Id != null, 'Failed to create the line item for owner ' + UserInfo.getUserId());
            
        return proposallineItemSO;        
    } 
    
    /**
     * Creates a line item for the given user
     * @param configId the product configuration Id
     * @param groupId the summary group id
     * @param lineNumber the line number
     * @param isPrimaryLine the primary line indicator
     * @param itemSeq the item sequence
     * @param lineType the line type
     * @param productId the product Id
     * @param customizable the product customizable indicator
     * @param productOptionId the product option Id
     * @param optionId the option Id
     * @param classId the leaf classification id
     * @param classHierarchy the classification hierarchy
     * @param quantity the line quantity
     * @param isQtyModifiable the quantity modifiable indicator
     * @param uom the unit of measure
     * @param term the term
     * @param priceListId the price list Id
     * @param plItemId the price list item id
     * @param priceType the price type
     * @param priceMethod the price method
     * @param chargeType the charge type
     * @param frequency the frequency
     * @param allowManualAdj the manual adjustment indicator
     * @param allocateGroupAdj the allocate group adjustment indicator
     * @param listPrice the list price
     * @param basePrice the base price
     * @param basePriceMethod the base price method
     * @param baseExtPrice the base extended price
     * @param optionPrice the option price
     * @param extPrice the extended price
     * @param lineDesc the line item description
     * @return the line item
     */
    public static Apttus_Config2__LineItem__c createLineItem(ID configId,
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
                                                       String lineDesc,
                                                       integer primarylineNumber
                                                       //integer year
                                                       ) {
        
        // create a new line item
        Apttus_Config2__LineItem__c lineItemSO = new Apttus_Config2__LineItem__c(Apttus_Config2__ConfigurationId__c = configId);
        
        // setup line item data
        
        // line number
        lineItemSO.Apttus_Config2__LineNumber__c = lineNumber;
        // primary line
        lineItemSO.Apttus_Config2__IsPrimaryLine__c = isPrimaryLine;
        // item sequence
        lineItemSO.Apttus_Config2__PrimaryLineNumber__c=primarylineNumber;
        lineItemSO.Apttus_Config2__ItemSequence__c = itemSeq;
        // summary group id
        lineItemSO.Apttus_Config2__SummaryGroupId__c = groupId;
        // line type
        lineItemSO.Apttus_Config2__LineType__c = lineType;
        // product id
        lineItemSO.Apttus_Config2__ProductId__c = productId;
        // customizable
        lineItemSO.Apttus_Config2__Customizable__c = customizable;
        // product option id
        lineItemSO.Apttus_Config2__ProductOptionId__c = productOptionId;
        // option id
        lineItemSO.Apttus_Config2__OptionId__c = optionId;
        // classification id
        lineItemSO.Apttus_Config2__ClassificationId__c = classId;
        // classification hierarchy
        lineItemSO.Apttus_Config2__ClassificationHierarchy__c = classHierarchy;
        // quantity
        lineItemSO.Apttus_Config2__Quantity__c = quantity;
        // quantity modifiable
        lineItemSO.Apttus_Config2__IsQuantityModifiable__c = isQtyModifiable;
        // uom
        lineItemSO.Apttus_Config2__Uom__c = uom;
        // term
        lineItemSO.Apttus_Config2__Term__c = term;
        // price list id
        lineItemSO.Apttus_Config2__PriceListId__c = priceListId;
        // price list item id
        lineItemSO.Apttus_Config2__PriceListItemId__c = plItemId;
        // price type
        lineItemSO.Apttus_Config2__PriceType__c = priceType;
        // price method
        lineItemSO.Apttus_Config2__PriceMethod__c = priceMethod;
        // charge type
        lineItemSO.Apttus_Config2__ChargeType__c = chargeType;
        // frequency
        lineItemSO.Apttus_Config2__Frequency__c = frequency;
        // allow manual adjustment
        lineItemSO.Apttus_Config2__AllowManualAdjustment__c = allowManualAdj;
        // allocate group adjustment
        lineItemSO.Apttus_Config2__AllocateGroupAdjustment__c = allocateGroupAdj;
        // list price
        lineItemSO.Apttus_Config2__ListPrice__c = listPrice;
        // base price
        lineItemSO.Apttus_Config2__BasePrice__c = basePrice;
        // base price mthod
        lineItemSO.Apttus_Config2__BasePriceMethod__c = basePriceMethod;
        // base extended price
        lineItemSO.Apttus_Config2__BaseExtendedPrice__c = baseExtPrice;
        // option price
        lineItemSO.Apttus_Config2__OptionPrice__c = optionPrice;
        // extended price
        lineItemSO.Apttus_Config2__ExtendedPrice__c = extPrice;
        // description
        lineItemSO.Apttus_Config2__Description__c = lineDesc;
        
        lineItemSO.Apttus_Config2__Term__c = 1;
        lineItemSO.Apttus_Config2__PricingStatus__c = 'Pending';
        lineItemSO.Apttus_Config2__SyncStatus__c = 'Pending';  
      
        insert lineItemSO;
        
            
        return lineItemSO;
        
    } 
    
	/**
     * Creates an ad hoc group for the given user
     * @param groupName the group name
     * @param configId the product configuration Id
     * @param groupDesc the group description
     * @return the ad hoc group
     */
    public static Apttus_Config2__AdHocGroup__c createAdHocGroup(String groupName,
                                                           ID configId,
                                                           String groupDesc) {
        
        // create a new ad hoc group
        Apttus_Config2__AdHocGroup__c groupSO = new Apttus_Config2__AdHocGroup__c(Name = groupName, Apttus_Config2__ConfigurationId__c = configId);
    
        // setup ad hoc group data
        
        // description
        groupSO.Apttus_Config2__Description__c = groupDesc;
        
        // insert ad hoc group 
        insert groupSO;
        
        System.assert(groupSO.Id != null, 'Failed to create the ad hoc group for owner ' + UserInfo.getUserId());
            
        return groupSO;
        
    } 
    public static Apttus_Config2__TempObject__c getTempObjCPQ(Id configId){
		Apttus_Config2__TempObject__c tempObj = new Apttus_Config2__TempObject__c();
		tempObj.Apttus_Config2__ConfigurationId__c = configId;
		String tdata = '<?xml version="1.0" encoding="UTF-8"?><ConfigRequest><BusinessObjectId>a6VS00000004EnOMAU</BusinessObjectId><BusinessObjectType>Proposal</BusinessObjectType><BusinessObjectTitle>e neiman 11/10/2014 Testing</BusinessObjectTitle><PriceListId>a7VS00000001nbzMAA</PriceListId><AccountId>001S000000mKebeIAC</AccountId><FinalizePage>Apttus_QPConfig__ProposalFinalize</FinalizePage><FinalizeClass>Apttus_QPConfig.ProposalActionCallback</FinalizeClass><CallerPackageNS>Apttus_QPConfig</CallerPackageNS><UseAdvancedApproval>false</UseAdvancedApproval><UseDealOptimizer>false</UseDealOptimizer><Fields><Field><Name>Name</Name><Value>Product Config - e neiman 11/10/2014 Testing</Value></Field><Field><Name>Apttus_QPConfig__Proposald__c</Name><Value>a6VS00000004EnOMAU</Value></Field><Field><Name>Apttus_Config2__EffectivePriceListId__c</Name><Value>a7VS00000001nbzMAA</Value></Field><Field><Name>CurrencyIsoCode</Name><Value>USD</Value></Field></Fields><Params><Param><Name>id</Name><Value>a6VS00000004EnO</Value></Param></Params><IsDynamicProductSearchFilter>true</IsDynamicProductSearchFilter><IsDynamicAssetSearchFilter>true</IsDynamicAssetSearchFilter></ConfigRequest>';
		tempObj.Apttus_Config2__Data__c = tdata;
        
        insert tempObj;
        
		return tempObj;
	}
	
    public static Apttus_Config2__ProductAttributeValue__c CreateProductAttribureValue(Id lineItemId)
    {
        Apttus_Config2__ProductAttributeValue__c productAttributevalue=new Apttus_Config2__ProductAttributeValue__c();        
        productAttributevalue.Apttus_Config2__LineItemId__c=lineItemId; 
        insert productAttributevalue;        
        system.assertNotEquals(productAttributevalue.id,null);
        
        return productAttributevalue;
        
       
    }
    
   
    
    public static Apttus_Config2__ClassificationName__c getCategory(String categoryName, String categoryLabel, String categoryType) {
		Apttus_Config2__ClassificationName__c newCategory = new Apttus_Config2__ClassificationName__c();
		
		newCategory.Name = categoryName;
		newCategory.Apttus_Config2__HierarchyLabel__c = categoryLabel;
		newCategory.Apttus_Config2__Type__c = categoryType;
		newCategory.Apttus_Config2__Active__c = true;
		
		return newCategory;
	}
	
	public static Apttus_Config2__ClassificationHierarchy__c getCategoryHierarchy(String catHierarchyName, String catHierarchyLabel, Apttus_Config2__ClassificationName__c categoryRec) {
		Apttus_Config2__ClassificationHierarchy__c newCategoryHierarchy = new Apttus_Config2__ClassificationHierarchy__c();
		
		newCategoryHierarchy.Name = catHierarchyName;
		newCategoryHierarchy.Apttus_Config2__Label__c = catHierarchyLabel;
		newCategoryHierarchy.Apttus_Config2__Left__c = 1;
		newCategoryHierarchy.Apttus_Config2__Right__c = 2;
		newCategoryHierarchy.Apttus_Config2__Level__c = 0;
		newCategoryHierarchy.Apttus_Config2__HierarchyId__c = categoryRec.Id;
		newCategoryHierarchy.Apttus_Config2__Modifiable__c = true;
		newCategoryHierarchy.Apttus_Config2__MinOptions__c = 1;
		newCategoryHierarchy.Apttus_Config2__MaxOptions__c = 1;
		newCategoryHierarchy.Apttus_Config2__IncludeInTotalsView__c = true;
		
		return newCategoryHierarchy;
	}
	
	public static Apttus_Config2__ProductOptionGroup__c getProductOptionGroup(Apttus_Config2__ClassificationHierarchy__c categoryHierarchy, Product2 bundleProduct) {
		Apttus_Config2__ProductOptionGroup__c prodOptionGroup = new Apttus_Config2__ProductOptionGroup__c();
		
		prodOptionGroup.Apttus_Config2__Sequence__c = 0;
		prodOptionGroup.Apttus_Config2__ModifiableType__c = 'Variable';
		prodOptionGroup.Apttus_Config2__Left__c = 1;
		prodOptionGroup.Apttus_Config2__Right__c = 2;
		prodOptionGroup.Apttus_Config2__Level__c = 0;
		prodOptionGroup.Apttus_Config2__IsLeaf__c = true;
		prodOptionGroup.Apttus_Config2__RootOptionGroupId__c = categoryHierarchy.Id;
		prodOptionGroup.Apttus_Config2__RootSequence__c = 1;
		prodOptionGroup.Apttus_Config2__OptionGroupId__c = categoryHierarchy.Id;
		prodOptionGroup.Apttus_Config2__ProductId__c = bundleProduct.Id;
		prodOptionGroup.Apttus_Config2__MinOptions__c = 0;
		prodOptionGroup.Apttus_Config2__MaxOptions__c = 999;
		
		return prodOptionGroup;
	}
     public static Apttus_Config2__ProductOptionComponent__c CreateOptionComponents(Id OptionGroupId,
                                                                                    Id OptionId,
                                                                                    Id parentProductId,
                                                                                    string relationshipType, 
                                                                                    integer sequence) 
    {
        Apttus_Config2__ProductOptionComponent__c prodOptionComp=new Apttus_Config2__ProductOptionComponent__c(Apttus_Config2__RelationshipType__c=relationshipType,
                                                                                                               Apttus_Config2__ProductOptionGroupId__c=OptionGroupId,
                                                                                                               Apttus_Config2__ParentProductId__c=parentProductId,
                                                                                                               Apttus_Config2__ComponentProductId__c=OptionId,
                                                                                                               Apttus_Config2__InclusionCriteria__c=null,
                                                                                                               Apttus_Config2__Sequence__c=sequence,
                                                                                                               Apttus_Config2__Default__c=true,
                                                                                                               Apttus_Config2__MinQuantity__c=1,
                                                                                                               Apttus_Config2__MaxQuantity__c=1,
                                                                                                               Apttus_Config2__DefaultQuantity__c=1
                                                                                                               
        
        );
        
        insert prodOptionComp;
        
        system.assertNotEquals(prodOptionComp.id,null);
        
        return prodOptionComp;
    
    } 
    
    public static User getUserObj(Id profileId){
			Decimal counter = Math.random();
			User us = new User();
			us.ProfileId = profileId;
			us.IsActive = TRUE;
			us.LastName = 'Test User: '+counter;
			us.Alias = 'ut'+(String.valueof(counter)).left(5);
			us.Email = 'noreply@email.com';
			us.Username = 'unittester'+counter+'@testerpro.com';
			us.CommunityNickname = 'unittester'+counter;
			us.TimeZoneSidKey = 'America/Los_Angeles';
			us.LocaleSidKey = 'en_US';
			us.EmailEncodingKey = 'UTF-8';
			us.LanguageLocaleKey = 'en_US';
			return us;
	}
    
    public static Apttus_Config2__ProductAttributeGroup__c getProdAttrGroup() {
		Apttus_Config2__ProductAttributeGroup__c prodAttrGroup = new Apttus_Config2__ProductAttributeGroup__c();
		
		prodAttrGroup.Name = 'Worker Type';
		prodAttrGroup.Apttus_Config2__Description__c = 'Attributes to capture Worker Types for each option product.';
		prodAttrGroup.Apttus_Config2__BusinessObject__c = 'Apttus_Config2__ProductAttributeValue__c';
			
		return prodAttrGroup;
	}
	
	public static Apttus_Config2__ProductAttributeGroupMember__c getProdAttrValueMember(Id productId, Id attributeGroupId) {
		Apttus_Config2__ProductAttributeGroupMember__c prodAttrGroupMember = new Apttus_Config2__ProductAttributeGroupMember__c();
		
		prodAttrGroupMember.Name = 'Worker Type';
		prodAttrGroupMember.Apttus_Config2__Sequence__c = 1;
		prodAttrGroupMember.Apttus_Config2__ProductId__c = productId;
		prodAttrGroupMember.Apttus_Config2__AttributeGroupId__c = attributeGroupId;
			
		return prodAttrGroupMember;
	}
	
	public static List<Apttus_Config2__ProductAttribute__c> getProductAttributeList(Id prodAttrGroupId) {
		List<Apttus_Config2__ProductAttribute__c> productAttributeList = new List<Apttus_Config2__ProductAttribute__c>();
		
		Apttus_Config2__ProductAttribute__c salariedWorkerAttr = new Apttus_Config2__ProductAttribute__c();
		salariedWorkerAttr.Apttus_Config2__Sequence__c = 1;
		salariedWorkerAttr.Apttus_Config2__Field__c = 'Salaried_Workers__c';
		salariedWorkerAttr.Apttus_Config2__AttributeGroupId__c = prodAttrGroupId;
		
		productAttributeList.add(salariedWorkerAttr);
		
		Apttus_Config2__ProductAttribute__c hourlyWorkerAttr = new Apttus_Config2__ProductAttribute__c();
		hourlyWorkerAttr.Apttus_Config2__Sequence__c = 2;
		hourlyWorkerAttr.Apttus_Config2__Field__c = 'Hourly_Workers__c';
		hourlyWorkerAttr.Apttus_Config2__AttributeGroupId__c = prodAttrGroupId;
		
		productAttributeList.add(hourlyWorkerAttr);
		
		Apttus_Config2__ProductAttribute__c partTimeWorkerAttr = new Apttus_Config2__ProductAttribute__c();
		partTimeWorkerAttr.Apttus_Config2__Sequence__c = 3;
		partTimeWorkerAttr.Apttus_Config2__Field__c = 'Part_Time_Workers__c';
		partTimeWorkerAttr.Apttus_Config2__AttributeGroupId__c = prodAttrGroupId;
		
		productAttributeList.add(partTimeWorkerAttr);
		
		Apttus_Config2__ProductAttribute__c contingentWorkerAttr = new Apttus_Config2__ProductAttribute__c();
		contingentWorkerAttr.Apttus_Config2__Sequence__c = 4;
		contingentWorkerAttr.Apttus_Config2__Field__c = 'Contingent_Workers__c';
		contingentWorkerAttr.Apttus_Config2__AttributeGroupId__c = prodAttrGroupId;
		
		productAttributeList.add(contingentWorkerAttr);
		
		Apttus_Config2__ProductAttribute__c seasonalWorkerAttr = new Apttus_Config2__ProductAttribute__c();
		seasonalWorkerAttr.Apttus_Config2__Sequence__c = 5;
		seasonalWorkerAttr.Apttus_Config2__Field__c = 'Seasonal_Workers__c';
		seasonalWorkerAttr.Apttus_Config2__AttributeGroupId__c = prodAttrGroupId;
		
		productAttributeList.add(seasonalWorkerAttr);
		
		Apttus_Config2__ProductAttribute__c formerWorkersWorkerAttr = new Apttus_Config2__ProductAttribute__c();
		formerWorkersWorkerAttr.Apttus_Config2__Sequence__c = 6;
		formerWorkersWorkerAttr.Apttus_Config2__Field__c = 'Former_Workers_with_Access__c';
		formerWorkersWorkerAttr.Apttus_Config2__AttributeGroupId__c = prodAttrGroupId;
		
		productAttributeList.add(formerWorkersWorkerAttr);
		
		return productAttributeList;
	}
    
    public static Apttus_QPConfig__ProposalProductAttributeValue__c getProposalProductAttributeValue(Id lineId) {
		Apttus_QPConfig__ProposalProductAttributeValue__c propProdAttrVal= new Apttus_QPConfig__ProposalProductAttributeValue__c(Apttus_QPConfig__LineItemId__c = lineId);
		insert propProdAttrVal;
        
        return propProdAttrVal;
	}
    
    public static Apttus_Config2__ConfigSystemProperties__c populateConfigSystemProperties() {
        Apttus_Config2__ConfigSystemProperties__c configSystemProperties = new Apttus_Config2__ConfigSystemProperties__c();
        
        configSystemProperties.Name = 'System Properties';
        configSystemProperties.Apttus_Config2__ViewCartPage__c = 'Apttus_Config2__CartDetailView';
		
		insert configSystemProperties;
        return configSystemProperties;
	}
    
    public static Apttus_Config2__ConfigCustomClasses__c populateConfigCustomClasses(){
        
        Apttus_Config2__ConfigCustomClasses__c custSetting = new Apttus_Config2__ConfigCustomClasses__c();
		custSetting.Apttus_Config2__PricingCallbackClass__c = 'APTS_PricingCallBack';
		custSetting.Name = 'System Properties';
		insert custSetting;
        
        return custSetting;
    } 
}