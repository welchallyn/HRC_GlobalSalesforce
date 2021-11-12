@isTest
public class APTS_PricingCallback_Test {
    
    static testMethod void pricingCallbackTest(){
        
        //create config custom class properties
        Apttus_Config2__ConfigCustomClasses__c cccProp = new Apttus_Config2__ConfigCustomClasses__c();
        cccProp.Name = 'Config Custom Classes';
        cccProp.Apttus_Config2__PricingCallbackClass__c = 'APTPS_CustomPricingCallBack';
        insert cccProp;
        
        Apttus_Config2__ConfigSystemProperties__c custom = new Apttus_Config2__ConfigSystemProperties__c();
        custom.Name = 'System Properties';
        custom.Apttus_Config2__ViewCartCustomFields__c = 'Tier__c, Manual_Discount__c,Order_Price_Year__c,Contract_Number__c,Line_Item_Reprice_Group_Code__c,Override_Contract_Number__c';
        insert custom;
        
            
        //create account
        Account ApttusTestAccount = new Account(
                                                Name = 'Test Account'
                                                 
                                               );
        insert ApttusTestAccount;
        
        //Create 
        
        /*Opportunity ApttusTestOpportunity = new Opportunity(
                                                            Name = 'Test Opportunity', 
                                                            Account = ApttusTestAccount, 
                                                            StageName = 'Working', 
                                                             RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HITS').getRecordTypeId(),
                                                            CloseDate = date.today().addyears(1)
                                                           );
        insert ApttusTestOpportunity;*/
        
        //Create Product
        List<Product2> prods = new List<Product2>();
        Product2 prod1 = new product2(
                                        Name = 'eSS', 
                                        ProductCode = 'eSS', 
                                        Apttus_Config2__ConfigurationType__c = 'Bundle', 
                                        IsActive = true
                                        ); 
        prods.add(prod1);
        
        Product2 prod2 = new product2(
                                        Name = 'WTS-P', 
                                        ProductCode = 'WTS-P', 
                                        Apttus_Config2__ConfigurationType__c = 'Bundle', 
                                        IsActive = true
                                        ); 
        prods.add(prod2);
        
        Product2 prod3 = new product2(
                                        Name = 'WTSP1', 
                                        ProductCode = 'WTSP1', 
                                        Apttus_Config2__ConfigurationType__c = 'Bundle', 
                                        IsActive = true
                                        ); 
        prods.add(prod3);
        
        Product2 prod4 = new product2(
                                Name = 'WTSP2', 
                                ProductCode = 'WTSP2', 
                                Apttus_Config2__ConfigurationType__c = 'Bundle', 
                                IsActive = true
                               ); 
        prods.add(prod4);
        
        Product2 prod5 = new product2(
                                Name = 'WTSP3', 
                                ProductCode = 'WTSP3', 
                                Apttus_Config2__ConfigurationType__c = 'Bundle', 
                                IsActive = true
                               ); 
        
        prods.add(prod5);
        
        Product2 bundle1 = getProduct('Apttus Test 1', 'IN600AF', 'Support', 'Bundle', '','');
        prods.add(bundle1);
        Product2 meterPackageProd = getProduct('Apttus Test 4', 'IN600AFAI', 'Support', 'Bundle', 'IN600AB','Meter Package');
        prods.add(meterPackageProd);
        Product2 meterPhysicalProd = getProduct('Apttus Test 5', '112', 'Support', 'Option', 'IN600AB','Meter Physical Item');
        prods.add(meterPhysicalProd);
        
        insert prods;
        
        //Create PriceList
        
        Apttus_Config2__PriceList__c ApttusTestPriceList = new Apttus_Config2__PriceList__c(
                                                                                            Name = 'Commercial Price List', 
                                                                                            Apttus_Config2__Active__c = True
                                                                                            );
        insert ApttusTestPriceList;
        
        //create price list items
        List<Apttus_Config2__PriceListItem__c> plistItems = new List<Apttus_Config2__PriceListItem__c>();
        Apttus_Config2__PriceListItem__c pLI1 = new Apttus_Config2__PriceListItem__c(
                                                                                     Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id,
                                                                                     Apttus_Config2__ListPrice__c = 100, 
                                                                                     Apttus_Config2__ProductId__c = prod1.Id, 
                                                                                     Apttus_Config2__ChargeType__c = 'Standard Price'
                                                                                    );
        plistItems.add(pLI1);
                
        Apttus_Config2__PriceListItem__c pLI2 = new Apttus_Config2__PriceListItem__c(
                                                                                     Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id, 
                                                                                     Apttus_Config2__ListPrice__c = 200, 
                                                                                     Apttus_Config2__ProductId__c = prod2.Id, 
                                                                                     Apttus_Config2__ChargeType__c = 'Subscription Fee'
                                                                                    );
        plistItems.add(pLI2);
        
        Apttus_Config2__PriceListItem__c pLI3 = new Apttus_Config2__PriceListItem__c(
                                                                                     Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id, 
                                                                                     Apttus_Config2__ListPrice__c = 200, 
                                                                                     Apttus_Config2__ProductId__c = prod3.Id, 
                                                                                     Apttus_Config2__ChargeType__c = 'Subscription Fee'
                                                                                    );
        plistItems.add(pLI3);
        
        Apttus_Config2__PriceListItem__c pLI4 = new Apttus_Config2__PriceListItem__c(
                                                                             Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id, 
                                                                             Apttus_Config2__ListPrice__c = 250, 
                                                                             Apttus_Config2__ProductId__c = prod4.Id, 
                                                                             Apttus_Config2__ChargeType__c = 'Subscription Fee'
                                                                            );
        plistItems.add(pLI4);
        
        Apttus_Config2__PriceListItem__c pLI5 = new Apttus_Config2__PriceListItem__c(
                                                                             Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id, 
                                                                             Apttus_Config2__ListPrice__c = 500, 
                                                                             Apttus_Config2__ProductId__c = prod5.Id, 
                                                                             Apttus_Config2__ChargeType__c = 'Subscription Fee'
                                                                            );
        plistItems.add(pLI5);
        
         Apttus_Config2__PriceListItem__c pliBundle1 =getPriceListItem(ApttusTestPriceList.Id, bundle1.Id,
        'Standard Price', 'Per Unit', 'Each', 5500, null, null, null);
        plistItems.add(pliBundle1);
        
        Apttus_Config2__PriceListItem__c pliMeterPackage = getPriceListItem(ApttusTestPriceList.Id, meterPackageProd.Id,
        'Meter Rental/ iMeter Apps', 'Per Unit', 'Each', 94, null, null, null);
        pliMeterPackage.Apttus_Config2__Frequency__c = 'Monthly';
        pliMeterPackage.Apttus_Config2__PriceType__c = 'Recurring';
        plistItems.add(pliMeterPackage);
        
        Apttus_Config2__PriceListItem__c pliMeterPhysical = getPriceListItem(ApttusTestPriceList.Id, meterPhysicalProd.Id,
        'Meter Rental/ iMeter Apps', 'Per Unit', 'Each', 0, null, null, null);
        pliMeterPhysical.Apttus_Config2__Frequency__c = 'Monthly';
        pliMeterPhysical.Apttus_Config2__PriceType__c = 'Recurring';
        plistItems.add(pliMeterPhysical);
        
        insert plistItems;
        
        //create proposal
        Apttus_Proposal__Proposal__c testProposal = new Apttus_Proposal__Proposal__c(
                                                                                     Apttus_Proposal__Account__c = ApttusTestAccount.id,
                                                                                     //Apttus_Proposal__Opportunity__c = ApttusTestOpportunity.Id,
                                                                                     Apttus_QPConfig__PriceListId__c = ApttusTestPriceList.id,
                                                                                     Apttus_QPConfig__ConfigurationFinalizedDate__c = date.today()
                                                                                    );
        insert testProposal;
        
        //create product configuration
        Apttus_Config2__ProductConfiguration__c ProdConfig = new Apttus_Config2__ProductConfiguration__c(
                                                                                                         Name = 'APTTUS Test Config', 
                                                                                                         Apttus_Config2__AccountId__c = ApttusTestAccount.Id, 
                                                                                                         Apttus_Config2__PriceListId__c = ApttusTestPriceList.Id, 
                                                                                                         Apttus_QPConfig__Proposald__c = testProposal.Id, 
                                                                                                         Apttus_Config2__Status__c = 'Finalized', 
                                                                                                         Apttus_Config2__VersionNumber__c = 1, 
                                                                                                         Apttus_Config2__EffectivePriceListId__c = ApttusTestPriceList.Id
                                                                                                        );
        insert ProdConfig;
        
        //Create Line Items
        list<Apttus_Config2__LineItem__c> allLineItems = new List<Apttus_Config2__LineItem__c>();
        Apttus_Config2__LineItem__c LineItem1 =new Apttus_Config2__LineItem__c(
                                                                                Tier__c = '1',
                                                                                Manual_Discount__c = 10,
                                                                               Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
                                                                               Apttus_Config2__ItemSequence__c = 1,
                                                                               Apttus_Config2__LineNumber__c = 1,
                                                                               Apttus_Config2__IsPrimaryLine__c = True,
                                                                               Apttus_Config2__LineStatus__c='New',
                                                                               Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
                                                                               Apttus_Config2__ChargeType__c = 'Standard Type',
                                                                               Apttus_Config2__LineType__c = 'Product/Service',
                                                                               Apttus_Config2__ProductId__c = prod1.Id,
                                                                               Apttus_Config2__PriceListItemId__c = pLI1.id,
                                                                               Apttus_Config2__PriceType__c = 'One Time',
                                                                               Apttus_Config2__PriceMethod__c = 'Per Unit',
                                                                               Apttus_Config2__Frequency__c = 'One Time',
                                                                               Apttus_Config2__SellingFrequency__c = 'One Time',
                                                                               Apttus_Config2__ListPrice__c = 100,
                                                                               Apttus_Config2__Quantity__c = 1,
                                                                               Apttus_Config2__SellingTerm__c = 1,
                                                                               Apttus_Config2__PrimaryLineNumber__c = 1
                                                                               );
        allLineItems.add(LineItem1);
        
        Apttus_Config2__LineItem__c LineItem2 =new Apttus_Config2__LineItem__c(
            Tier__c = '1',
                                                                                Manual_Discount__c = 20,
                                                                               Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
                                                                               Apttus_Config2__ItemSequence__c=1,
                                                                               Apttus_Config2__LineNumber__c = 2,
                                                                               Apttus_Config2__IsPrimaryLine__c = True,
                                                                               Apttus_Config2__LineStatus__c='New',
                                                                               Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
                                                                               Apttus_Config2__ChargeType__c = 'Standard Type',
                                                                               Apttus_Config2__ProductId__c = prod2.Id,
                                                                               Apttus_Config2__LineType__c = 'Product/Service',
                                                                               Apttus_Config2__PriceListItemId__c = pLI2.id,
                                                                               Apttus_Config2__PriceType__c = 'One Time',
                                                                               Apttus_Config2__PriceMethod__c = 'Per Unit',
                                                                               Apttus_Config2__Frequency__c = 'One Time',
                                                                               Apttus_Config2__SellingFrequency__c = 'One Time',
                                                                               Apttus_Config2__ListPrice__c = 200,
                                                                               Apttus_Config2__Quantity__c = 1,
                                                                               Apttus_Config2__SellingTerm__c = 1,
                                                                               Apttus_Config2__PrimaryLineNumber__c = 2
                                                                               );
        allLineItems.add(LineItem2);
        
        Apttus_Config2__LineItem__c LineItem3 =new Apttus_Config2__LineItem__c(
            Tier__c = '1',
                                                                                Manual_Discount__c = 10,
                                                                               Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
                                                                               Apttus_Config2__ItemSequence__c=1,
                                                                               Apttus_Config2__LineNumber__c = 2,
                                                                               Apttus_Config2__IsPrimaryLine__c = True,
                                                                               Apttus_Config2__LineStatus__c='New',
                                                                               Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
                                                                               Apttus_Config2__ChargeType__c = 'Subscription Fee',
                                                                               Apttus_Config2__ProductId__c = prod3.Id,
                                                                               Apttus_Config2__LineType__c = 'Product/Service',
                                                                               Apttus_Config2__PriceListItemId__c = pLI3.id,
                                                                               Apttus_Config2__PriceType__c = 'Recurring',
                                                                               Apttus_Config2__PriceMethod__c = 'Per Unit',
                                                                               Apttus_Config2__Frequency__c = 'One Time',
                                                                               Apttus_Config2__SellingFrequency__c = 'One Time',
                                                                               Apttus_Config2__ListPrice__c = 200,
                                                                               Apttus_Config2__Quantity__c = 1,
                                                                               Apttus_Config2__SellingTerm__c = 1,
                                                                               Apttus_Config2__PrimaryLineNumber__c = 3
                                                                               );
        allLineItems.add(LineItem3);
        
        Apttus_Config2__LineItem__c LineItem4 =new Apttus_Config2__LineItem__c(
            Tier__c = '1',
                                                                                Manual_Discount__c = 10,
                                                                       Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
                                                                       Apttus_Config2__ItemSequence__c=1,
                                                                       Apttus_Config2__LineNumber__c = 2,
                                                                       Apttus_Config2__IsPrimaryLine__c = True,
                                                                       Apttus_Config2__LineStatus__c='New',
                                                                       Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
                                                                       Apttus_Config2__ChargeType__c = 'Subscription Fee',
                                                                       Apttus_Config2__ProductId__c = prod4.Id,
                                                                       Apttus_Config2__LineType__c = 'Product/Service',
                                                                       Apttus_Config2__PriceListItemId__c = pLI4.id,
                                                                       Apttus_Config2__PriceType__c = 'Recurring',
                                                                       Apttus_Config2__PriceMethod__c = 'Per Unit',
                                                                       Apttus_Config2__Frequency__c = 'One Time',
                                                                       Apttus_Config2__SellingFrequency__c = 'One Time',
                                                                       Apttus_Config2__ListPrice__c = 200,
                                                                       Apttus_Config2__Quantity__c = 1,
                                                                       Apttus_Config2__SellingTerm__c = 1,
                                                                       Apttus_Config2__PrimaryLineNumber__c = 3
                                                                       );
        allLineItems.add(LineItem4);
        
        Apttus_Config2__LineItem__c LineItem5 =new Apttus_Config2__LineItem__c(
            Tier__c ='1',
                                                                                Manual_Discount__c = 10,
                                                                       Apttus_Config2__ConfigurationId__c=ProdConfig.Id,
                                                                       Apttus_Config2__ItemSequence__c=1,
                                                                       Apttus_Config2__LineNumber__c = 2,
                                                                       Apttus_Config2__IsPrimaryLine__c = True,
                                                                       Apttus_Config2__LineStatus__c='New',
                                                                       Apttus_Config2__PriceListId__c = ApttusTestPriceList.id,
                                                                       Apttus_Config2__ChargeType__c = 'Subscription Fee',
                                                                       Apttus_Config2__ProductId__c = prod5.Id,
                                                                       Apttus_Config2__LineType__c = 'Product/Service',
                                                                       Apttus_Config2__PriceListItemId__c = pLI5.id,
                                                                       Apttus_Config2__PriceType__c = 'Recurring',
                                                                       Apttus_Config2__PriceMethod__c = 'Per Unit',
                                                                       Apttus_Config2__Frequency__c = 'One Time',
                                                                       Apttus_Config2__SellingFrequency__c = 'One Time',
                                                                       Apttus_Config2__ListPrice__c = 200,
                                                                       Apttus_Config2__Quantity__c = 1,
                                                                       Apttus_Config2__SellingTerm__c = 1,
                                                                       Apttus_Config2__PrimaryLineNumber__c = 3
                                                                       );
        allLineItems.add(LineItem5);
        
        Apttus_Config2__LineItem__c bundleLine = getConfigLineItem(ProdConfig.Id, null, 1, true,//Config Id, grpId, LineNum, isPrimary
        1, 'Product/Service', bundle1.Id, true, null,//ItemSeq, lineType, bundleId, customizable, productOptionId
        null, null, null, 1, true,//optionId, class Id, class hierarchy, qty, qty Modifiable 
        'Each', 1, ApttusTestPriceList.Id, pliBundle1.Id,//Uom, term, priceList, Pli,
        'One Time', 'Per Unit', 'Standard Price', 'One Time',//priceType, priceMethod, chargeType, frequency
        true, true, 5500, 5500, 'Per Unit',//allowManualAdj, allocateGroupAdj, listPrice, basePrice, basePriceMethod, 
        5500, 0, 5500, 'TestaPTTUS');//baseExtPrice, optionPrice, extendedPrice, lineDesc
        bundleLine.Apttus_Config2__NetPrice__c = 5500;
        bundleLine.Apttus_Config2__PrimaryLineNumber__c = 1;
        allLineItems.add(bundleLine);

        Apttus_Config2__LineItem__c meterPackageLine = getConfigLineItem(ProdConfig.Id, null, 1, true,//Config Id, grpId, LineNum, isPrimary
        4, 'Option', bundle1.Id, true, null,//ItemSeq, lineType, bundleId, customizable, productOptionId
        meterPackageProd.Id, null, null, 1, true,//optionId, class Id, class hierarchy, qty, qty Modifiable 
        'Each', 1, ApttusTestPriceList.Id, pliMeterPackage.Id,//Uom, term, priceList, Pli,
        'Recurring', 'Per Unit', 'Meter Rental/ iMeter Apps', 'Monthly',//priceType, priceMethod, chargeType, frequency
        false, false, 94, 94, 'Per Unit',//allowManualAdj, allocateGroupAdj, listPrice, basePrice, basePriceMethod, 
        94, 0, 94, 'TestaPTTUS');//baseExtPrice, optionPrice, extendedPrice, lineDesc
        meterPackageLine.Apttus_Config2__ParentBundleNumber__c = 1;
        meterPackageLine.Apttus_Config2__NetPrice__c = 94;
        meterPackageLine.Apttus_Config2__PrimaryLineNumber__c = 4;
        allLineItems.add(meterPackageLine);
        
        Apttus_Config2__LineItem__c meterPhysicalLine = getConfigLineItem(ProdConfig.Id, null, 1, false,//Config Id, grpId, LineNum, isPrimary
        5, 'Option', meterPackageProd.Id, true, null,//ItemSeq, lineType, bundleId, customizable, productOptionId
        meterPhysicalProd.Id, null, null, 1, true,//optionId, class Id, class hierarchy, qty, qty Modifiable 
        'Each', 1, ApttusTestPriceList.Id, pliMeterPhysical.Id,//Uom, term, priceList, Pli,
        'Recurring', 'Per Unit', 'Meter Rental/ iMeter Apps', 'Monthly',//priceType, priceMethod, chargeType, frequency
        false, false, 0, 0, 'Per Unit',//allowManualAdj, allocateGroupAdj, listPrice, basePrice, basePriceMethod, 
        0, 0, 0, 'TestaPTTUS');//baseExtPrice, optionPrice, extendedPrice, lineDesc
        meterPhysicalLine.Apttus_Config2__ParentBundleNumber__c = 4;
        meterPhysicalLine.Apttus_Config2__NetPrice__c = 0;
        meterPhysicalLine.Apttus_Config2__PrimaryLineNumber__c = 5;
        allLineItems.add(meterPhysicalLine);
        
        
        
        insert allLineItems;
        
        
        for(list<apttus_config2__LineItem__c> lilist:[select id,name,APTS_Discretionary_Discount__c from apttus_config2__LineItem__c where Id in:allLineItems]){
           for(apttus_config2__LineItem__c li: lilist)
               li.APTS_Discretionary_Discount__c=1; 
            
            update lilist;
        
        }
            
        
        

        test.startTest();       
        
       Boolean result = Apttus_Config2.PricingWebService.computeBasePriceForItemColl(ProdConfig.Id, 1);
        /*result = Apttus_Config2.PricingWebService.computeNetPriceForItemColl(ProdConfig.Id, 1);
        Apttus_Config2.PricingWebService.computeBasicPriceForItemColl(ProdConfig, allLineItems);*/
        
       Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO request = new Apttus_CPQApi.CPQ.ComputeNetPriceRequestDO();
        request.CartId = ProdConfig.Id;        
        request.LineNumber = 1;        
        //Apttus_CPQApi.CPQWebService.computeNetPriceForBundle(request);     

        test.stopTest();        
    }
    
       public static User getUser(String profileId){
        User mike = new User();
        mike.Username= 'mike@apttus.com';
        mike.Email = 'mike@apttus.com';
        mike.Lastname = 'mike';
        mike.Firstname = 'Apttus';
        mike.Alias = 'mApttus';
        mike.CommunityNickname = 'Don';
        mike.ProfileID = profileId;
        //mike.CurrencyIsoCode = 'USD';
        mike.TimeZoneSidKey = 'GMT';
        mike.LocaleSidKey = 'en_US';
        mike.EmailEncodingKey = 'ISO-8859-1';
        mike.LanguageLocaleKey = 'en_US';
        mike.UserPermissionsMobileUser = false;
        
        return mike;
    }
    
    public  static Account getAccount(String accName){
        
        Account acc = new Account(Name = accName);
        return acc;
    }
    
    public  static Contact getContact(String accId){
        
        Contact con = new Contact(AccountId = accId, FirstName = 'Apttus', LastName = 'User');
        return con;
    }
    
    public  static Opportunity getOpportunity(String accId, String optyName, String stage){
        
        Opportunity opty = new Opportunity(AccountId = accId, Name = optyName, StageName = stage,
        CloseDate = System.today().addYears(1),
        ForecastCategoryName = 'Closed');
        return opty;
    }
    
    public  static Product2 getProduct(String prodName, String prodCode, String prodFamily, String configType, String meterBaseCode,
    String meterIdentifier){
    
        Product2 product = new Product2(Name= prodName);
        product.ProductCode = prodCode;
        product.Family = prodFamily;
        product.Apttus_Config2__ConfigurationType__c = configType;
        product.IsActive = true;
        return product;
    }
    
    public   static Apttus_Config2__PriceList__c getPriceList(String pliName){
        
        Apttus_Config2__PriceList__c pli = new Apttus_Config2__PriceList__c(Apttus_Config2__Active__c = true, Name = pliName);
        return pli;
    }
    
    public  static Apttus_Config2__PriceListItem__c getPriceListItem(Id plId, Id prodId,String chargeType,String priceType,String priceMethod,Decimal listPrice, Decimal minPrice, Decimal maxPrice, String minMaxPriceAppliesTo){
        
        Apttus_Config2__PriceListItem__c itemSO = new Apttus_Config2__PriceListItem__c(Apttus_Config2__PriceListId__c = plId);
        itemSO.Apttus_Config2__ProductId__c = prodId;
        itemSO.Apttus_Config2__ChargeType__c = chargeType;
        itemSO.Apttus_Config2__PriceType__c = priceType;
        itemSO.Apttus_Config2__PriceMethod__c = priceMethod;
        itemSO.Apttus_Config2__ListPrice__c = listPrice;
        itemSO.Apttus_Config2__MinPrice__c = minPrice;
        itemSO.Apttus_Config2__MaxPrice__c = maxPrice;
        itemSO.Apttus_Config2__MinMaxPriceAppliesTo__c = minMaxPriceAppliesTo;
        itemSO.Apttus_Config2__EffectiveDate__c = Date.today().addDays(-100);
        itemSO.Apttus_Config2__ExpirationDate__c = Date.today().addDays(365);
        return itemSO;
    }
    
    public  static Apttus_Proposal__Proposal__c getQuoteProposal(String accId, String optyId, String quoteName, String recordTypeName, String pli, String priceList, String priceType){
        
        Apttus_Proposal__Proposal__c quote = new Apttus_Proposal__Proposal__c(Apttus_Proposal__Proposal_Name__c = quoteName,
        Apttus_Proposal__Opportunity__c = optyId,
        Apttus_Proposal__Account__c = accId,
        RecordTypeId = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId(),
        Apttus_QPConfig__PriceListId__c = pli);
        
        return quote;
    }
    
    
    public  static Apttus_Config2__ProductConfiguration__c getProductConfiguration(String configName,
                                                                                  Integer versionNbr,
                                                                                  ID bObjectId,
                                                                                  String bObjectType,
                                                                                  String groupType,
                                                                                  ID priceListId, 
                                                                                  ID ancestorId, 
                                                                                  String status, 
                                                                                  Datetime finalizedDate, 
                                                                                  Datetime effectiveDate, 
                                                                                  Boolean isTransient){
        
        Apttus_Config2__ProductConfiguration__c configSO = new Apttus_Config2__ProductConfiguration__c(Name = configName, OwnerId = UserInfo.getUserId());
        configSO.Apttus_Config2__VersionNumber__c = versionNbr;
        configSO.Apttus_Config2__SummaryGroupType__c = groupType;
        configSO.Apttus_Config2__BusinessObjectId__c = bObjectId;
        configSO.Apttus_Config2__BusinessObjectType__c = bObjectType;
        configSO.Apttus_QPConfig__Proposald__c = bObjectId;
        configSO.Apttus_Config2__PriceListId__c = priceListId;
        configSO.Apttus_Config2__AncestorId__c = ancestorId;
        configSO.Apttus_Config2__Status__c = status;
        configSO.Apttus_Config2__IsTransient__c = isTransient;
        configSO.Apttus_Config2__FinalizedDate__c = finalizedDate;
        configSO.Apttus_Config2__EffectiveDate__c = effectiveDate; 
        return configSO;
    }
    
    public  static Apttus_Config2__LineItem__c getConfigLineItem(ID configId,
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
                                                                     lineItemSO.Tier__c = '1';
                                                                                lineItemSO.Manual_Discount__c = 10;
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
    
    public  static Apttus_Proposal__Proposal_Line_Item__c getProposalLineItem(String quoteId, String lineId, String pliId, String lineType, 
                                                                            Decimal listPrice, Decimal basePrice, Decimal optionPrice, 
                                                                            Decimal netPrice, Boolean isRollupLine,
                                                                            Boolean isPrimaryLine,String chargeType, String prodId, 
                                                                            String optionId, Decimal qty, Decimal primaryLineNum, 
                                                                            Decimal parentBndlNum, Decimal lineNum, String priceFreq, 
                                                                            String priceUom, Decimal adjustmentAmt){
        
        Apttus_Proposal__Proposal_Line_Item__c propLineItem = new Apttus_Proposal__Proposal_Line_Item__c(
        Apttus_Proposal__Proposal__c = quoteId,
        Apttus_QPConfig__DerivedFromId__c = lineId,
        Apttus_QPConfig__PriceListItemId__c = pliId);
        propLineItem.Apttus_QPConfig__ListPrice__c = listPrice;
        propLineItem.Apttus_QPConfig__BasePrice__c = basePrice;
        propLineItem.Apttus_QPConfig__OptionPrice__c = optionPrice;
        propLineItem.Apttus_QPConfig__NetPrice__c = netPrice;
        propLineItem.Apttus_QPConfig__IsOptionRollupLine__c = isRollupLine;
        propLineItem.Apttus_QPConfig__ChargeType__c = chargeType;
        propLineItem.Apttus_Proposal__Product__c = prodId;
        propLineItem.Apttus_QPConfig__OptionId__c = optionId;
        propLineItem.Apttus_QPConfig__Quantity2__c = qty;
        propLineItem.Apttus_QPConfig__PrimaryLineNumber__c = primaryLineNum;
        propLineItem.Apttus_QPConfig__ParentBundleNumber__c = parentBndlNum;
        propLineItem.Apttus_QPConfig__LineNumber__c = lineNum;
        propLineItem.Apttus_QPConfig__Frequency__c = priceFreq;
        propLineItem.Apttus_QPConfig__PriceUom__c = priceUom;
        propLineItem.Apttus_QPConfig__AdjustmentAmount__c = adjustmentAmt;
        propLineItem.Apttus_QPConfig__IsPrimaryLine__c = isPrimaryLine;
        propLineItem.Apttus_QPConfig__LineType__c = lineType;
        return propLineItem;
    }
    
    public  static Attachment getAttachment(String parentId, String aName){
        
        Attachment att = new Attachment(Name = aName, ParentId = parentId, Body = Blob.valueOf('Apttus Test Attachment.'), IsPrivate = false);
        return att;
    }
    
    
    //Price List Category - Junction between - Category and Price list
    public  static Apttus_Config2__PriceListCategory__c insertPriceListCategoryJunction(String hierarchyId, String priceListId){
        Apttus_Config2__PriceListCategory__c priceListCat = new Apttus_Config2__PriceListCategory__c(Apttus_Config2__HierarchyId__c = hierarchyId, Apttus_Config2__PriceListId__c = priceListId);
        insert priceListCat;
        return priceListCat;
    }
    
    //Product Classification - Junction between Product and Category Hierarchy
    public  static Apttus_Config2__ProductClassification__c getProductClassification(String categoryHierarchyId, String productId){
        
        return new Apttus_Config2__ProductClassification__c(Apttus_Config2__ClassificationId__c = categoryHierarchyId, 
        Apttus_Config2__ProductId__c = productId,
        Apttus_Config2__MinQuantity__c = 0,
        Apttus_Config2__MaxQuantity__c = 1,
        Apttus_Config2__DefaultQuantity__c = 0);
    }
    
    //Product Option Group - Junction to link Category with Bundle - Parent to Option Component - build relationship between Option and Bundle
    public  static Apttus_Config2__ProductOptionGroup__c getProductOptionGroup(String categoryHierarchyId, String bundleId, String parentGrpId, String rootOptGrpId,
    Decimal seq){
        
        Apttus_Config2__ProductOptionGroup__c prodOptGroup = new Apttus_Config2__ProductOptionGroup__c(
        Apttus_Config2__OptionGroupId__c = categoryHierarchyId,
        Apttus_Config2__ParentOptionGroupId__c = parentGrpId,
        Apttus_Config2__RootOptionGroupId__c = rootOptGrpId,
        Apttus_Config2__ProductId__c = bundleId,
        Apttus_Config2__Sequence__c = seq,
        Apttus_Config2__MinOptions__c = 1,
        Apttus_Config2__MaxOptions__c = 100
        );
        
        return prodOptGroup;
    }
    
    //Product Option Component - 
    public  static Apttus_Config2__ProductOptionComponent__c getProductOptionComponent(String optionGrpId, String prodId, 
    String optionId, Decimal seq){
        
        return new Apttus_Config2__ProductOptionComponent__c(
        Apttus_Config2__ProductOptionGroupId__c = optionGrpId,
        Apttus_Config2__ParentProductId__c = prodId,
        Apttus_Config2__MinQuantity__c = 0,
        Apttus_Config2__MaxQuantity__c = 25,
        Apttus_Config2__RelationshipType__c = 'Option',
        Apttus_Config2__Sequence__c = seq,
        Apttus_Config2__ComponentProductId__c = optionId
        );
    }
    
    public  static Apttus_Config2__ProductAttributeValue__c GetAttributeValue(Id lineItemId,string maintenanceLevel,boolean isNeoship,boolean isOnlinePostalExpenseManager,boolean isPostalRate)
    {
        Apttus_Config2__ProductAttributeValue__c obj = new Apttus_Config2__ProductAttributeValue__c();
        obj.Apttus_Config2__LineItemId__c = lineItemId;
        return obj;
    }
    
    
    
}