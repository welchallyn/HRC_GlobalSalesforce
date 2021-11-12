//Nim it Shah Apttus PS, 6/25/2014 Changed code to add Effective Total Discount
/*
 Revision History:
 Venkata R Sabbella   
 04/12/2016. 
*/
global with sharing class APTPS_CustomPricingCallBack implements Apttus_Config2.CustomClass.IPricingCallback2 {

    private Id proposalId = null;
    private Id cartId = null;
    private List<Apttus_Config2__LineItem__c> lineItemsToUpdate = null;
    private Apttus_Config2.ProductConfiguration cart = null;
    private Apttus_Config2.CustomClass.PricingMode mode = null;
    
    //Start Changes Nimit Shah Dt. 06/25/14
    private Double extendedPrice = 0.00;
    private Double currentTotal = 0.00;
    private Double adjustedPrice = 0.00;
    private Double manualDiscount = 0.00;
    private Double basePrice = 0.00;
    //End Changes Nimit Shah Dt. 06/25/14
    
    global void start(Apttus_Config2.ProductConfiguration cart) {
    /**
     * Callback at the beginning of the pricing call.
     * Use the start method to initialize state
     * @param cart the cart object
     */     
        system.debug('into start method:::***');
        this.cart = cart;
        this.proposalId = cart.getConfigSO().Apttus_QPConfig__Proposald__c;
        this.cartId = cart.getConfigSO().id;
        this.lineItemsToUpdate = new List<Apttus_Config2__LineItem__c>();
    }
  
    global void setMode(Apttus_Config2.CustomClass.PricingMode mode) {
     /**
      * Callback to indicate the pricing mode
      * @param mode the pricing mode
      */             
        this.mode = mode;
    }
    
    
    global void beforePricing(Apttus_Config2.ProductConfiguration.LineItemColl itemColl) {
     /**
     * Callback before pricing the line item collection
     * Use this method to do all required pre-processing to prepare the line items for pricing.
     * @param itemColl the line item collection to pre-process
     */         
        Map<Decimal,String> PrimarylinesTier = new Map<Decimal,String>();
        Map<Decimal,Decimal> PrimarylinesManualDiscount = new Map<Decimal,Decimal>();
        Map<Decimal,Decimal> PrimarylinesQuantity = new Map<Decimal,Decimal>();
        list<Apttus_Config2__LineItem__c> lineItems = new list<Apttus_Config2__LineItem__c>();
        list<Apttus_Config2__LineItem__c> lineItems1 = new list<Apttus_Config2__LineItem__c>();
        
        boolean Changeoptions=false;
        list<Apttus_Config2.LineItem> allLines1 = itemColl.getAllLineItems();
        lineItems.addAll(getLineItems(allLines1));  
        for(Apttus_Config2__LineItem__c lineItem : lineItems) {
            system.debug('lineItemApttus_Config2__ExtendedPrice__c1:::**'+lineItem.Apttus_Config2__ExtendedPrice__c);
            if(lineItem.Apttus_Config2__LineType__c.equalsIgnoreCase('Product/Service')) {
                PrimarylinesTier.put(lineItem.Apttus_Config2__PrimaryLineNumber__c,lineItem.Tier__c);
                PrimarylinesManualDiscount.put(lineItem.Apttus_Config2__PrimaryLineNumber__c,lineItem.Manual_Discount__c);
                PrimarylinesQuantity.put(lineItem.Apttus_Config2__PrimaryLineNumber__c,lineItem.Apttus_Config2__Quantity__c);
            }
        }
        
        if(lineItems != null && lineItems.size() > 0) {            
            list<Apttus_Config2__LineItem__c> updateLineItemsABC = new list<Apttus_Config2__LineItem__c>(); 
            for(Apttus_Config2__LineItem__c lineItem : lineItems) {
                //set 'Tier And Manual Discount and Quantity'
                system.debug('lineItemApttus_Config2__ExtendedPrice__c2:::**'+lineItem.Apttus_Config2__ExtendedPrice__c);
                if(lineItem.Apttus_Config2__ParentBundleNumber__c != null && lineItem.Apttus_Config2__LineType__c.equalsIgnoreCase('Option')) {
                    lineItem.Tier__c = PrimarylinesTier.get(lineItem.Apttus_Config2__ParentBundleNumber__c);
                    lineItem.Manual_Discount__c = PrimarylinesManualDiscount.get(lineItem.Apttus_Config2__ParentBundleNumber__c);
                   // lineItem.Apttus_Config2__Quantity__c = PrimarylinesQuantity.get(lineItem.Apttus_Config2__ParentBundleNumber__c);
                }
            }
        } 


         // Price List Item Query Optimization 
        list<Id> optionIdList=new list<Id>();
        for(Apttus_Config2__LineItem__c  lineItem:lineItems)
        {
          // #ApttusLabs 08/02/16 - Updated to price option products on individual top level line items 
          if(lineItem.Apttus_Config2__OptionId__c != null)
            optionIdList.add(lineItem.Apttus_Config2__OptionId__c); 
          else
            optionIdList.add(lineItem.Apttus_Config2__ProductId__c); 
 
        }
        map<Id,Apttus_Config2__PriceListItem__c> priceListItemMap=new Map<Id, Apttus_Config2__PriceListItem__c>([SELECT Apttus_Config2__ListPrice__c 
                                                                                                                 FROM Apttus_Config2__PriceListItem__c 
                                                                                                                 WHERE Apttus_Config2__ProductId__c = :optionIdList
                                                                                                                 ]);
        system.debug('this.mode::::'+this.mode);
        
        if(Apttus_Config2.CustomClass.PricingMode.BASEPRICE == this.mode)
        {  system.debug('!!..CALLING FROM BASEPRICE MODE');
            APTPS_CallbackFactory config = new APTPS_CallbackFactory();
            config.hillRomBasePricing(itemColl,priceListItemMap);   
        }
        if(Apttus_Config2.CustomClass.PricingMode.ADJUSTMENT == this.mode) 
        {   system.debug('!!..CALLING FROM ADJUSTEMENT MODE');         
            APTPS_CallbackFactory config = new APTPS_CallbackFactory();
            config.hillRomAdjusting(itemColl,priceListItemMap);
            
        }
        
        
        // to update the quantity of the rails group of option products with the quantity of options
        if(Apttus_Config2.CustomClass.PricingMode.BASEPRICE == this.mode) 
          {              
              APTPS_CallbackFactory.updateEndCoverOptionQuantity(itemColl);    
          } 
           
    }  
    
    
    
    global void beforePricingLineItem(Apttus_Config2.ProductConfiguration.LineItemColl itemColl, 
                                                  Apttus_Config2.LineItem lineItemMO) {
        
       /* Apttus_Config2__LineItem__c bundle=lineItemMO.getLineItemSO();
        
        system.debug('Before Pricing Line Item1');
        if(bundle.Apttus_Config2__LineType__c!='Product/Service')
           return;
         system.debug('Before Pricing Line Item2');  
        
         List<Apttus_Config2__LineItem__c> optionList=new List<Apttus_Config2__LineItem__c>();
         for(Apttus_Config2.LineItem liWrapper : itemColl.getAllLineItems()){
             optionList.add(liWrapper.getLineItemSO());
         }
        
        APTPS_CallbackFactory.cascadeTheDiscountfromBundle(optionList,bundle); */
    }   
    
    global void afterPricing(Apttus_Config2.ProductConfiguration.LineItemColl itemColl) {
    /**
     * Callback after pricing the line item collection
     * Use this method to do all required post-processing after line items are priced.
     * @param itemColl the line item collection to post-process
     */ 
     //if(Apttus_Config2.CustomClass.PricingMode.ADJUSTMENT == this.mode)
        //APTPS_CallbackFactory.applyDiscretionaryDiscount(itemColl); 
        
       /* if(Apttus_Config2.CustomClass.PricingMode.Adjustment == this.mode)
        {
         
         Apttus_Config2__LineItem__c bundle=new Apttus_Config2__LineItem__c();
         List<Apttus_Config2__LineItem__c> optionList=new List<Apttus_Config2__LineItem__c>();
         for(Apttus_Config2.LineItem liWrapper : itemColl.getAllLineItems()){
             Apttus_Config2__LineItem__c lineItemSO=liWrapper.getLineItemSO();
             if(lineItemSO.Apttus_Config2__LineType__c=='Product/Service')
                bundle=lineItemSO;
             else
             optionList.add(lineItemSO);
         }
        
        APTPS_CallbackFactory.cascadeTheDiscountfromBundle(optionList,bundle); 
         
        }*/
    }     

    global void afterPricingLineItem(Apttus_Config2.ProductConfiguration.LineItemColl itemColl, Apttus_Config2.LineItem lineItemMO) 
    {
        
        system.debug('into after pricing line item method::::****');
        Map<Decimal,Apttus_Config2__LineItem__c> bundleId_LineItemMap=new Map<Decimal,Apttus_Config2__LineItem__c>();
        Map<Decimal,list<Apttus_Config2__LineItem__c>> optionNumber_LineItemMap=new Map<Decimal,List<Apttus_Config2__LineItem__c>>();
        
        
        //Start Changes Nimit Shah Dt. 06/25/14 
        /* if(Apttus_Config2.CustomClass.PricingMode.ROLLDOWN == this.mode)
        {
            currentTotal = 0.00;      
            adjustedPrice = 0.00;
            manualDiscount = 0.00;
            extendedPrice = 0.00;
            basePrice=0;
                                    
           for(Apttus_Config2.LineItem liWrapper : itemColl.getAllLineItems()){
                Apttus_Config2__LineItem__c lineItem = liWrapper.getLineItemSO();
                if (lineItem.Apttus_Config2__LineType__c.equalsIgnoreCase('Product/Service'))
                    bundleId_LineItemMap.put(lineItem.Apttus_Config2__LineNumber__c,lineItem);
                 else if(lineItem.Apttus_Config2__LineType__c.equalsIgnoreCase('Option')){
                     if(optionNumber_LineItemMap.containsKey(lineItem.Apttus_Config2__LineNumber__c))
                       optionNumber_LineItemMap.get(lineItem.Apttus_Config2__LineNumber__c).add(lineItem);
                     else{
                       optionNumber_LineItemMap.put(lineItem.Apttus_Config2__LineNumber__c,new list<Apttus_Config2__LineItem__c>{lineItem});
                     }
                 }
                
            }
            
            for(decimal d:optionNumber_LineItemMap.keyset())
            {
               list<Apttus_Config2__LineItem__c>  OptionlineItemList =  optionNumber_LineItemMap.get(d); 
              //  system.debug('!!.. ' + lineItem.Apttus_Config2__ChargeType__c + ' ' + lineItem.Current__c + ' ' + currentTotal );

              //  system.debug('!!.. ' + lineItem.Apttus_Config2__ChargeType__c + ' ' + lineItem.Apttus_Config2__AdjustedPrice__c + ' ' + adjustedPrice );
             
              if(OptionlineItemList.size()==0)
                 continue;
              Apttus_Config2__LineItem__c bundleLine=bundleId_LineItemMap.get(d);
              
                
              for(Apttus_Config2__LineItem__c lineItem:OptionlineItemList){ 
                
                    if(lineItem.Current__c != null)
                    {
                        lineItem.Current_Total__c = lineItem.Current__c * lineItem.Apttus_Config2__Quantity__c;
                        currentTotal += lineItem.Current__c * lineItem.Apttus_Config2__Quantity__c;
                    }
                    if(lineItem.Apttus_Config2__BasePrice__c != null)
                        basePrice += lineItem.Apttus_Config2__BasePrice__c;
                    if(lineItem.Apttus_Config2__AdjustedPrice__c != null)
                        adjustedPrice += lineItem.Apttus_Config2__AdjustedPrice__c;
                  ///  if(lineItem.Apttus_Config2__ExtendedPrice__c != null)
                  ///      extendedPrice += lineItem.Apttus_Config2__ExtendedPrice__c;
                
              }
              bundleLine.Apttus_Config2__BasePrice__c=basePrice;
              bundleLine.Apttus_Config2__AdjustedPrice__c = adjustedPrice;
              bundleLine.Current_Total__c = currentTotal;
                             
            } 
            */
            
            /*for(Apttus_Config2.LineItem liWrapper : itemColl.getAllLineItems())
            {
                Apttus_Config2__LineItem__c lineItem = liWrapper.getLineItemSO();
              //  system.debug('!!PS.. ' +  lineItem.Apttus_Config2__ChargeType__c + ' ' + currentTotal );
                system.debug('!!PS.. ' +  lineItem.Apttus_Config2__OptionId__r.name + ' ' + basePrice );
              //  system.debug('!!PS.. ' +  lineItem.Apttus_Config2__ChargeType__c + ' ' + adjustedPrice );                
                if (lineItem.Apttus_Config2__LineType__c.equalsIgnoreCase('Product/Service'))
                {
                    if(currentTotal > 0)
                        lineItem.Effective_Discount_Total__c = ((currentTotal - adjustedPrice) / currentTotal) * 100;
                 //   lineItem.Apttus_Config2__ExtendedPrice__c = extendedPrice;
                    lineItem.Apttus_Config2__AdjustedPrice__c = adjustedPrice;
                    lineItem.Current_Total__c = currentTotal;
                    lineItem.Apttus_Config2__BasePrice__c = basePrice;
                    break;
                }
            }
        }*/
        //End Changes Nimit Shah Dt. 06/25/14 

        // Enhancements by Venkata R Sabbella
        if(Apttus_Config2.CustomClass.PricingMode.Adjustment == this.mode){
            list<Apttus_Config2__LineItem__c> itemCollSOList=new list<Apttus_Config2__LineItem__c>();
            Apttus_Config2__LineItem__c LineItemSO=lineItemMO.getLineItemSO();
            List<Apttus_Config2.LineItem> allLines = itemColl.getAllLineItems();      
             for(Apttus_Config2.LineItem lineItemMObj : allLines) {
             // get the main product line item sobject      
             Apttus_Config2__LineItem__c lineItemSObj = lineItemMObj.getLineItemSO();
             itemCollSOList.add(lineItemSObj);
             }
             
             system.debug('LineItemSO in Adjustment:::'+LineItemSO);
             APTPS_CallbackFactory.assignFinalNetPrice( itemCollSOList, LineItemSO);  
            
            
        }
        if(Apttus_Config2.CustomClass.PricingMode.Adjustment == this.mode)
        {
            list<Apttus_Config2__LineItem__c> itemCollSOList=new list<Apttus_Config2__LineItem__c>();
            Apttus_Config2__LineItem__c LineItemSO=lineItemMO.getLineItemSO();
            List<Apttus_Config2.LineItem> allLines = itemColl.getAllLineItems();      
             for(Apttus_Config2.LineItem lineItemMObj : allLines) {
             // get the main product line item sobject      
             Apttus_Config2__LineItem__c lineItemSObj = lineItemMObj.getLineItemSO();
             itemCollSOList.add(lineItemSObj);
             }
             
             //system.debug('LineItemSO in Adjustment:::'+LineItemSO);
             APTPS_CallbackFactory.cascadeTheDiscountfromBundle( itemCollSOList, LineItemSO);   
        }
        
        if(Apttus_Config2.CustomClass.PricingMode.Adjustment == this.mode)
        {
         //APTPS_CallbackFactory.ListPriceAggregation(itemColl, lineItemMO); 
        }
        
        
        if(Apttus_Config2.CustomClass.PricingMode.RollDOWN == this.mode)  
        { system.debug('!!..CALLING FROM RollDOWN MODE');
          //APTPS_CallbackFactory.applyDiscretionaryDiscount(itemColl); 
          //APTPS_CallbackFactory.DistributeGroupLevelDiscounts(itemColl, lineItemMO);

          APTPS_CallbackFactory.ListPriceAggregation(itemColl, lineItemMO); 
            list<Apttus_Config2__LineItem__c> itemCollSOList=new list<Apttus_Config2__LineItem__c>();
            Apttus_Config2__LineItem__c LineItemSO=lineItemMO.getLineItemSO();
            List<Apttus_Config2.LineItem> allLines = itemColl.getAllLineItems();      
             for(Apttus_Config2.LineItem lineItemMObj : allLines) {
             // get the main product line item sobject      
             Apttus_Config2__LineItem__c lineItemSObj = lineItemMObj.getLineItemSO();
             itemCollSOList.add(lineItemSObj);
             }
 
             APTPS_CallbackFactory.cascadeTheDiscountfromBundle( itemCollSOList, LineItemSO);          
         
        }
        
        
      
    }
    
    global void finish() {
    /**
     * Callback after all batches of line items are processed
     */  
     /*
     List<Apttus_Config2.LineItem> allLines= cart.getLineItems();
     for(Apttus_Config2.LineItem lineItemMObj : allLines) {
      Apttus_Config2__LineItem__c lineItemSO = lineItemMObj.getLineItemSO();
      
      if(lineItemSO.Apttus_Config2__ExtendedPrice__c - lineItemSO.Apttus_Config2__NetPrice__c>0
          && lineItemSO.Apttus_Config2__ExtendedPrice__c>0 &&
             lineItemSO.Apttus_Config2__ExtendedPrice__c>0)
      lineItemSO.NetAdjustmentPercent2__c=100 * (lineItemSO.Apttus_Config2__ExtendedPrice__c - lineItemSO.APTS_Final_Net_Price__c)/lineItemSO.Apttus_Config2__ExtendedPrice__c;
       
     }*/
       
    } 

    private static List<Apttus_Config2__LineItem__C> getLineItems(List<Apttus_Config2.LineItem> allLines) {
     /**
     * Gets the list of product line items 
     * @param cart the cart object
     * @return the list of line item objects
     */        
        List<Apttus_Config2__LineItem__C> lineItems = new List<Apttus_Config2__LineItem__C>();
        for (Apttus_Config2.LineItem lineItemMO : allLines) {
            lineItems.add(lineItemMO.getLineItemSO());
        }        
        return lineItems;
    }  
    
}