/* e neiman, Apttus PS, 6/13/2014
*   Hill-Rom contract based discounting
SELECT  Name,Reprice_Code__c,Order_Year__c,Contract_Year__c,Tier__c,Discount__c FROM Adjustment_Schedule__c WHERE Name = '14501' AND Reprice_Code__c = 'BBD'
AND Pricing_Contract__c = '14501' AND Tier__c = 1 AND Order_Year__c = '2014'   

Revision History: Venkata R Sabbella
0314                   
04/12      
*/
//Nimit Shah Apttus PS, 6/25/2014 Changed code to add Tier based pricing
//Nimit Shah Apttus PS, 6/30/2014 Changed code to change manual discount to decimal instead of integer
global with sharing class APTPS_CallbackFactory {
    List<Adjustment_Schedule__c> ListOfDscnts = new List<Adjustment_Schedule__c>();
    List<Apttus_Config2__PriceListItem__c> ListOfNets = new List<Apttus_Config2__PriceListItem__c>();
    private static Decimal Tier = 1;
    private static Boolean isNotCtrctYrNet;
    private static string ContractYear;
    //private String lastRGC = '';
    private Decimal TierTotal = 0;
    private Decimal AdjustedTotal = 0;
    private String PricingContract,PrimaryPricingContract;

    global void hillRomBasePricing(Apttus_Config2.ProductConfiguration.LineItemColl itemColl, map<Id,Apttus_Config2__PriceListItem__c> plitemMap) { 
        system.debug('!!..hillRomBasePricing');

        //12/29/15 changes for SOQl optimization SV
        List<string> listofRepriceCode = new List<String>();
        List<string> listofContractNumber = new List<String>();
        List<Decimal> listofTier = new List<Decimal>();
        List<string> listofOrderYear = new List<String>();
        List<string> listofProdCode = new List<String>();

        //get the list of values to be queried for 
        for(Apttus_Config2.LineItem liWrapper : itemColl.getAllLineItems()){
            Apttus_Config2__LineItem__c lineItem = liWrapper.getLineItemSO();
            listofRepriceCode.add(lineItem.Line_Item_Reprice_Group_Code__c);
            listofContractNumber.add(lineItem.Override_Contract_Number__c);
            listofContractNumber.add(lineItem.Contract_Number__c);
            listofTier.add( (lineItem.Tier__c == null) ? 1 : decimal.valueOf(lineItem.Tier__c));
            listofOrderYear.add(lineItem.Order_Price_Year__c);
            listofProdCode.add(lineItem.APTS_Product_Code__c);
        }
        
        system.debug('listofRepriceCode:::'+listofRepriceCode);
        system.debug('listofContractNumber:::'+listofContractNumber);
        system.debug('listofContractNumber:::+'+listofOrderYear);
        
        ListOfDscnts = [SELECT  Reprice_Code__c,                                            
                                            Name,
                                            Order_Year__c,
                                            Contract_Year__c,
                                            Pricing_Contract__c,
                                            Tier__c,
                                            Discount__c
                                    FROM    Adjustment_Schedule__c WHERE Pricing_Contract__c in :listofContractNumber 
                                    AND     Reprice_Code__c  in :listofRepriceCode
                                    AND     Tier__c in :listofTier
                                    AND     Order_Year__c in :listofOrderYear];
        Map<String, Adjustment_Schedule__c> mapOfAdjSchd = new Map <String, Adjustment_Schedule__c> ();
        String adjSchdKey = '';
        if(ListOfDscnts != null && ListOfDscnts.size() >0){
            for( Adjustment_Schedule__c adjSchd: ListOfDscnts){
                //use the combination of the 4 criteria as key in the map and the record as values
                adjSchdKey = adjSchd.Pricing_Contract__c+'_'+ adjSchd.Reprice_Code__c+'_'+adjSchd.Tier__c+'_'+adjSchd.Order_Year__c;
                mapOfAdjSchd.put(adjSchdKey, adjSchd);
            }
        }
        
        system.debug('!!... ListOfDscnts ' + ListOfDscnts ); 

       // system.debug('!!... Tier Price ' + :listofTier); 


        List<Net_Pricing__c> ListOfNets = [ SELECT Id, Lead_Contract__c, Pricing_Product__c, Reprice_Code__c,Value__c  
                                                    FROM Net_Pricing__c 
                                                    WHERE Pricing_Product__c IN :listOfProdCode AND  
                                                    Reprice_Code__c IN :listOfRepriceCode ];

        Map<String, Net_Pricing__c> mapOfNetPricing = new Map <String, Net_Pricing__c> ();
        String netPricingKey = '';
        if(ListOfNets != null && ListOfNets.size() >0){
            for( Net_Pricing__c netPricing: ListOfNets){
                //use the combination of the 2 criteria as key in the map and the record as values
                netPricingKey = netPricing.Pricing_Product__c+'_'+ netPricing.Reprice_Code__c+'_'+netPricing.Lead_Contract__c;
                mapOfNetPricing.put(netPricingKey, netPricing);
            }
        }
        

        //12/29 end of changes for soql optimization
        Adjustment_Schedule__c Dscnt = null;
        Net_Pricing__c pric = null;
                                    
        for(Apttus_Config2.LineItem liWrapper : itemColl.getAllLineItems()){
            Dscnt = null;
            pric = null;
            Apttus_Config2__LineItem__c lineItem = liWrapper.getLineItemSO();
            
            
              system.debug('!!... Line Item' + lineItem.Apttus_Config2__LineType__c );
              system.debug('!!... Line_Item_Reprice_Group_Code__c ' + lineItem.Line_Item_Reprice_Group_Code__c);
  
            if ( lineItem.Line_Item_Reprice_Group_Code__c != null ) {               
    
                //sorting out the primary or override pricing contract
                
                PricingContract = lineItem.Contract_Number__c;
                if ( lineItem.Override_Contract_Number__c != null ) 
                    PricingContract = lineItem.Override_Contract_Number__c;
                    
                system.debug('!!..PricingContract ' + PricingContract );
                system.debug('!!..lineItem.APTS_Product_Code__c ' + lineItem.APTS_Product_Code__c );

                Decimal Discount = lineItem.Manual_Discount__c;
                
                if ( Discount == null)
                    Discount = 0.00;
                
                // SQL call unused, optimization no longer applicable
                //if ( lastRGC != lineItem.Line_Item_Reprice_Group_Code__c ) {//LIMITING SOQL CALLS! e neiman
                /* e neiman:  eventually, to service large numbers of products with different RGCs
                    we are going to want to push this to a map of RGCs to Schedule records.
                    Map<String,Adjustment_Schedule__c> rgcToSchedule = new Map<String, Adjustment_Schedule__c>([Select Reprice_Code__c,... From Adjustment_Schedule__c... LIMIT 1]);
                    This is downstream, however, until we can determine if there are "exceptions"
                */
                    //Start Changes Nimit Shah Dt. 06/25/14
                
                    if(lineItem.Tier__c == null)
                        lineItem.Tier__c = '1';
                    Tier = decimal.valueOf(lineItem.Tier__c);
                    //End Changes Nimit Shah Dt. 06/25/14
                    
                    /*ListOfDscnts = [SELECT  Reprice_Code__c,                                            
                                            Name,
                                            Order_Year__c,
                                            Contract_Year__c,
                                            Tier__c,
                                            Discount__c
                                    FROM    Adjustment_Schedule__c WHERE Pricing_Contract__c = :PricingContract 
                                    AND     Reprice_Code__c  = :lineItem.Line_Item_Reprice_Group_Code__c
                                    AND     Tier__c = :Tier
                                    AND     Order_Year__c = :lineItem.Order_Price_Year__c LIMIT 1];                    
                    */
                    adjSchdKey = PricingContract+'_'+lineItem.Line_Item_Reprice_Group_Code__c+'_'+Tier +'_'+ lineItem.Order_Price_Year__c;
                                        
                    if(mapOfAdjSchd != null && mapOfAdjSchd.get(adjSchdKey) != null)
                        Dscnt = mapOfAdjSchd.get(adjSchdKey);
                    
                        
                //}
                
                               

                //lastRGC = lineItem.Line_Item_Reprice_Group_Code__c;
                if ( Dscnt != null)
                {
                    // 12/09/2015 - Luis Arismendy / Raul Mora - String to capture the value Lead Contract depending of the Adjustmen Schedule Contract Year
                    String strLeadContract;
                    // 12/09/2015 - Luis Arismendy / Raul Mora - Loop the Adjustmen Schedule to verify the Contract_Year__c
                    //for (Adjustment_Schedule__c Dscnt : ListOfDscnts )
                    //{     
                        system.debug(' ..Dscnt.Contract_Year__c ' + Dscnt.Contract_Year__c);
                        
                        Discount = Discount + (Dscnt.Discount__c * -1);
                        isNotCtrctYrNet = (Dscnt.Contract_Year__c == 'NET' ? false : true );
                        ContractYear = (isNotCtrctYrNet) ? Dscnt.Contract_Year__c : Dscnt.Order_Year__c ;
                        lineItem.Contract_Price_Year__c = ContractYear;
                        strLeadContract = isNotCtrctYrNet ? Dscnt.Contract_Year__c : Dscnt.Name;
                    //}
                     
                    if ( isNotCtrctYrNet ) 
                    {                    
                        //lineItem.Apttus_Config2__AdjustmentType__c = '% Discount off CONTRACT';//VNS commented
                        lineItem.Apttus_Config2__AdjustmentType__c = '% Discount';//VNS added
                        lineItem.Apttus_Config2__AdjustmentAmount__c = Discount; 
                        lineItem.Tier__c = String.valueOf(Tier);
                    }
                    system.debug( '!!.. strLeadContract '+strLeadContract );
                    // 12/09/2015 - Luis Arismendy / Raul Mora - moved the Net pricing query inside the has ListOfDscnts block
                   
                    /*for(List<Net_Pricing__c> ListOfNets : [ SELECT Id, Lead_Contract__c, Pricing_Product__c, Reprice_Code__c,Value__c  
                                                            FROM Net_Pricing__c 
                                                            WHERE Pricing_Product__c= :lineItem.APTS_Product_Code__c AND  
                                                            Reprice_Code__c = :lineItem.Line_Item_Reprice_Group_Code__c AND 
                                                            Lead_Contract__c = :strLeadContract  LIMIT 1]) 
                    {
                    */
                        //for ( Net_Pricing__c pric : ListOfNets )
                        
                        netPricingKey = lineItem.APTS_Product_Code__c+'_'+ lineItem.Line_Item_Reprice_Group_Code__c+'_'+strLeadContract;
                                            
                        if(mapOfNetPricing != null && mapOfNetPricing.get(netPricingKey)!= null)
                        {         
                            pric = mapOfNetPricing.get(netPricingKey);
                            //Changed by Mansi Mehta (9-8-2016) - Updated baseoverride field instead of base price to avoid pricing issue while repricing first time Previously we had to reprice twice to get the excepted result.
                            //lineItem.Apttus_Config2__BasePrice__c = pric.Value__c;
                            lineItem.Apttus_Config2__BasePriceOverride__c = pric.Value__c;
                            lineItem.Apttus_Config2__BasePrice__c = lineItem.Apttus_Config2__BasePriceOverride__c;
                            // #ApttusLabs 08/02/16 - Updated to price option products on individual top level line items  
                            //lineItem.Current_Price__c = pricingElementList(lineItem.Apttus_Config2__OptionId__c,plitemMap);
                            Id pricingProductId=(lineItem.Apttus_config2__LineType__c=='Product/Service')?lineItem.Apttus_config2__ProductId__c:lineItem.Apttus_config2__OptionId__c; 
                            lineItem.Current_Price__c = pricingElementList(pricingProductId,plitemMap);
                            
                            lineItem.Apttus_Config2__AdjustmentAmount__c = Discount;
                            lineItem.Tier__c = '1';
                            //Changed by Mansi Mehta (9-8-2016) - Updated baseoverride field instead of base price to avoid pricing issue while repricing first time Previously we had to reprice twice to get the excepted result.
                            //lineItem.Apttus_Config2__ExtendedPrice__c = (lineItem.Apttus_Config2__BasePrice__c!=null?lineItem.Apttus_Config2__BasePrice__c:0) * lineItem.Apttus_Config2__Quantity__c;
                            lineItem.Apttus_Config2__ExtendedPrice__c = (lineItem.Apttus_Config2__BasePriceOverride__c!=null?lineItem.Apttus_Config2__BasePriceOverride__c:0) * lineItem.Apttus_Config2__Quantity__c;
                            Decimal listPrice=lineItem.Apttus_Config2__ListPrice__c!=null?lineItem.Apttus_Config2__ListPrice__c:0;
                            //lineItem.Extended_List_Price__c = listPrice * lineItem.Apttus_Config2__Quantity__c;
                            
                            lineItem.Apttus_Config2__NetPrice__c = lineItem.Apttus_Config2__ExtendedPrice__c;
                            lineItem.APTS_Final_Net_Price__c=lineItem.Apttus_Config2__NetPrice__c; 
                            system.debug( '!!.. lineItem.Current_Price__c '+lineItem.Current_Price__c );
                            system.debug(' Extended Price-->'+lineItem.Apttus_Config2__ExtendedPrice__c);
                            system.debug( '!!.. isNotCtrctYrNet '+isNotCtrctYrNet );
                            system.debug( '!!.. pric.Value__c '+pric.Value__c );
                            system.debug( '!!.. Discount '+Discount );
                            // 12/09/2015 - Luis Arismendy / Raul Mora - Verify that the List price is not 0
                            if( lineItem.Current_Price__c != 0 )
                            {
                                // 12/09/2015 - Luis Arismendy / Raul Mora - Depending if the Adjustment Schedules contract year is NET or not it will calculate the Net Adjustment Percent 
                                lineItem.NetAdjustmentPercent2__c = isNotCtrctYrNet ? ( ( ( lineItem.Current_Price__c - ( pric.Value__c * ( ( 100 - Discount ) / 100 ) ) ) / pric.Value__c ) * 100 ) : ( 100 - ( ( pric.Value__c * 100 ) / lineItem.Current_Price__c ) ) ;
                            }
                            lineItem.NetAdjustmentPercent2__c = lineItem.NetAdjustmentPercent2__c * ( -1 );
                            system.debug('!!..Net Price' + lineItem.Apttus_Config2__NetPrice__c );
                            system.debug('!!..Net Adjustment Percent' + lineItem.NetAdjustmentPercent2__c );
                        } else{
                            
                            // #ApttusLabs 08/02/16 - Updated to price option products on individual top level line items 
                            system.debug('!!..No discount found for netPricingKey: ' + netPricingKey);
                                                        
                        }
                    //}               
                
                    //if (ListOfNets.size()==0)
                    if(pric == null){
                        // #ApttusLabs 08/02/16 - Updated to price option products on individual top level line items 
                        //lineItem.Current_Price__c = pricingElementList(lineItem.Apttus_Config2__OptionId__c,plitemMap);
                        Id pricingProductId=(lineItem.Apttus_config2__LineType__c=='Product/Service')?lineItem.Apttus_config2__ProductId__c:lineItem.Apttus_config2__OptionId__c; 
                        lineItem.Current_Price__c = pricingElementList(pricingProductId,plitemMap);
                    }                   
                } else{
                    
                    // #ApttusLabs 08/02/16 - Updated to price option products on individual top level line items 
                    system.debug('!!..No discount found for adjSchdKey: ' + adjSchdKey);
                    
                }   
            }
        }
    }
    
    global void hillRomAdjusting(Apttus_Config2.ProductConfiguration.LineItemColl itemColl,map<Id,Apttus_Config2__PriceListItem__c> plitemMap) {  
     
            
       
       //12/29/15 changes for SOQl optimization SV
        List<string> listofRepriceCode = new List<String>();
        List<string> listofContractNumber = new List<String>();
        List<Decimal> listofTier = new List<Decimal>();
        List<string> listofOrderYear = new List<String>();
        List<string> listofProdCode = new List<String>();

        //get the list of values to be queried for 
        for(Apttus_Config2.LineItem liWrapper : itemColl.getAllLineItems()){
            Apttus_Config2__LineItem__c lineItem = liWrapper.getLineItemSO();
            system.debug('lineItemApttus_Config2__ExtendedPrice__c3:::**'+lineItem.Apttus_Config2__ExtendedPrice__c);
            listofRepriceCode.add(lineItem.Line_Item_Reprice_Group_Code__c);
            listofContractNumber.add(lineItem.Override_Contract_Number__c);
            listofContractNumber.add(lineItem.Contract_Number__c);
            listofTier.add( (lineItem.Tier__c == null) ? 1 : decimal.valueOf(lineItem.Tier__c));
            listofOrderYear.add(lineItem.Order_Price_Year__c);
            listofProdCode.add(lineItem.APTS_Product_Code__c);
        }

        ListOfDscnts = [SELECT  Reprice_Code__c,                                            
                                            Name,
                                            Order_Year__c,
                                            Contract_Year__c,
                                            Pricing_Contract__c,
                                            Tier__c,
                                            Discount__c
                                    FROM    Adjustment_Schedule__c WHERE Pricing_Contract__c in :listofContractNumber 
                                    AND     Reprice_Code__c  in :listofRepriceCode
                                    AND     Tier__c in :listofTier
                                    AND     Order_Year__c in :listofOrderYear];
        Map<String, Adjustment_Schedule__c> mapOfAdjSchd = new Map <String, Adjustment_Schedule__c> ();
        String adjSchdKey = '';
        if(ListOfDscnts != null && ListOfDscnts.size() >0){
            for( Adjustment_Schedule__c adjSchd: ListOfDscnts){
                //use the combination of the 4 criteria as key in the map and the record as values
                adjSchdKey = adjSchd.Pricing_Contract__c+'_'+ adjSchd.Reprice_Code__c+'_'+adjSchd.Tier__c+'_'+adjSchd.Order_Year__c;
                mapOfAdjSchd.put(adjSchdKey, adjSchd);
            }
        }
        


        List<Net_Pricing__c> ListOfNets = [ SELECT Id, Lead_Contract__c, Pricing_Product__c, Reprice_Code__c,Value__c  
                                                    FROM Net_Pricing__c 
                                                    WHERE Pricing_Product__c IN :listOfProdCode AND  
                                                    Reprice_Code__c IN :listOfRepriceCode ];

        Map<String, Net_Pricing__c> mapOfNetPricing = new Map <String, Net_Pricing__c> ();
        String netPricingKey = '';
        if(ListOfNets != null && ListOfNets.size() >0){
            for( Net_Pricing__c netPricing: ListOfNets){
                //use the combination of the 2 criteria as key in the map and the record as values
                netPricingKey = netPricing.Pricing_Product__c+'_'+ netPricing.Reprice_Code__c+'_'+netPricing.Lead_Contract__c;
                mapOfNetPricing.put(netPricingKey, netPricing);
            }
        }
        

        for(Apttus_Config2.LineItem liWrapper : itemColl.getAllLineItems()){
            Apttus_Config2__LineItem__c lineItem = liWrapper.getLineItemSO();
            system.debug('!!lineItem:'+lineItem.Apttus_Config2__LineType__c+'ExtendedPrice4:::***'+lineItem.Apttus_Config2__ExtendedPrice__c);
            if ( lineItem.Line_Item_Reprice_Group_Code__c != null ) {
                
                 Adjustment_Schedule__c Dscnt;
                /* e neiman:  in theory there will be a high level condition to switch off to a higher tier.  So if TierTotal > break level,
                    then Tier = 2,3 or 4
                    */
                //Changed by Mansi Mehta (9-8-2016) - Updated baseoverride field instead of base price to avoid pricing issue while repricing first time Previously we had to reprice twice to get the excepted result.
                // if (lineItem.Apttus_Config2__BasePrice__c != null)
                //     TierTotal += lineItem.Apttus_Config2__BasePrice__c;
                if (lineItem.Apttus_Config2__BasePriceOverride__c != null)
                    TierTotal += lineItem.Apttus_Config2__BasePriceOverride__c;
                if (lineItem.Apttus_Config2__NetPrice__c != null)
                    AdjustedTotal += lineItem.Apttus_Config2__NetPrice__c;
                //sorting out the primary or override pricing contract
                PricingContract = lineItem.Contract_Number__c;
                if ( lineItem.Override_Contract_Number__c != null ) 
                    PricingContract = lineItem.Override_Contract_Number__c;

                system.debug('!!..PricingContract hillRomAdjusting ' + PricingContract );
                system.debug('!!..lineItem.Line_Item_Reprice_Group_Code__c hillRomAdjusting ' + lineItem.Line_Item_Reprice_Group_Code__c );
                system.debug('!!..lineItem.APTS_Product_Code__c hillRomAdjusting ' + lineItem.APTS_Product_Code__c );
                
                Decimal Discount = lineItem.Manual_Discount__c;
                if ( Discount == null)
                    Discount = 0.00;
                /*if ( lastRGC != lineItem.Line_Item_Reprice_Group_Code__c ) {//LIMITING SOQL CALLS! e neiman
                   // e neiman:  eventually, to service large numbers of products with different RGCs
                   // we are going to want to push this to a map of RGCs to Schedule records.
                   // Map<String,Adjustment_Schedule__c> rgcToSchedule = new Map<String, Adjustment_Schedule__c>([Select Reprice_Code__c,... From Adjustment_Schedule__c... LIMIT 1]);
                   // This is downstream, however, until we can determine if there are "exceptions"
                
                    //Start Changes Nimit Shah Dt. 06/25/14
                    if(lineItem.Tier__c == null)
                        lineItem.Tier__c = '1';
                    Tier = decimal.valueOf(lineItem.Tier__c);
                    //End Changes Nimit Shah Dt. 06/25/14
                    //
                    ListOfDscnts = [SELECT  Reprice_Code__c,                                            
                                            Name,
                                            Order_Year__c,
                                            Contract_Year__c,
                                            Tier__c,
                                            Discount__c
                                    FROM    Adjustment_Schedule__c WHERE Pricing_Contract__c = :PricingContract                         
                                    AND     Reprice_Code__c  = :lineItem.Line_Item_Reprice_Group_Code__c
                                    AND     Tier__c = :Tier
                                    AND     Order_Year__c = :lineItem.Order_Price_Year__c LIMIT 1];                      
                                    
                }*/

                adjSchdKey = PricingContract+'_'+lineItem.Line_Item_Reprice_Group_Code__c+'_'+Tier +'_'+ lineItem.Order_Price_Year__c;  
                
               // if(mapOfAdjSchd.ContainsKey(adjSchdKey) )
               //    Dscnt = mapOfAdjSchd.get(adjSchdKey);
  
                
                //lastRGC = lineItem.Line_Item_Reprice_Group_Code__c;
                //ListOfNets = [SELECT Apttus_Config2__ListPrice__c FROM Apttus_Config2__PriceListItem__c WHERE Apttus_Config2__ProductId__c = :lineItem.Apttus_Config2__OptionId__c];
                
                                            
                if ( mapOfAdjSchd.ContainsKey(adjSchdKey))
                {
                    Dscnt = mapOfAdjSchd.get(adjSchdKey);
                    // 12/09/2015 - Luis Arismendy / Raul Mora - String to capture the value Lead Contract depending of the Adjustmen Schedule Contract Year
                    String strLeadContract;
                    // 12/09/2015 - Luis Arismendy / Raul Mora - Loop the Adjustmen Schedule to verify the Contract_Year__c
                    //for (Adjustment_Schedule__c Dscnt : ListOfDscnts )
                    //{ }   
                        system.debug(' ..Dscnt.Contract_Year__c hillRomAdjusting ' + Dscnt.Contract_Year__c);
                        
                        Discount = Discount + (Dscnt.Discount__c * -1);
                        isNotCtrctYrNet = (Dscnt.Contract_Year__c == 'NET' ? false : true );
                        ContractYear = (isNotCtrctYrNet) ? Dscnt.Contract_Year__c : Dscnt.Order_Year__c ;
                        lineItem.Contract_Price_Year__c = ContractYear;
                        strLeadContract = isNotCtrctYrNet ? Dscnt.Contract_Year__c : Dscnt.Name;
                    
                    
                    if ( isNotCtrctYrNet ) {
                        //lineItem.Apttus_Config2__AdjustmentType__c = '% Discount off CONTRACT';//VNS Commented
                        lineItem.Apttus_Config2__AdjustmentType__c = '% Discount';//VNS added
                        lineItem.Apttus_Config2__AdjustmentAmount__c = Discount; 
                        lineItem.Tier__c = String.valueOf(Tier);
                    }
                    system.debug( '!!.. strLeadContract hillRomAdjusting '+strLeadContract );
                    // 12/09/2015 - Luis Arismendy / Raul Mora - moved the Net pricing query inside the has ListOfDscnts block
                   /* for(List<Net_Pricing__c> ListOfNets : [SELECT  Lead_Contract__c, Pricing_Product__c, Reprice_Code__c,Value__c  FROM Net_Pricing__c 
                                                                    WHERE Pricing_Product__c= :lineItem.APTS_Product_Code__c AND  
                                                                    Reprice_Code__c = :lineItem.Line_Item_Reprice_Group_Code__c AND  
                                                                    Lead_Contract__c = :strLeadContract  LIMIT 1]) 
                    {
     
                        for ( Net_Pricing__c pric : ListOfNets ) 
                        {      }
                    }*/

                        netPricingKey = lineItem.APTS_Product_Code__c+'_'+ lineItem.Line_Item_Reprice_Group_Code__c+'_'+strLeadContract;
                    system.debug('mapOfNetPricing.keyset:::'+ mapOfNetPricing.keySet());
                    system.debug('netPricingKey:::'+netPricingKey);
                       if( mapOfNetPricing.ContainsKey(netPricingKey))
                        { 
                            Net_Pricing__c pric=mapOfNetPricing.get(netPricingKey); 
                            //Changed by Mansi Mehta (9-8-2016) - Updated baseoverride field instead of base price to avoid pricing issue while repricing first time Previously we had to reprice twice to get the excepted result
                            //lineItem.Apttus_Config2__BasePrice__c = pric.Value__c;
                            lineItem.Apttus_Config2__BasePriceOverride__c = pric.Value__c;
                            lineItem.Apttus_Config2__BasePrice__c = lineItem.Apttus_Config2__BasePriceOverride__c;
                            // #ApttusLabs 08/02/16 - Updated to price option products on individual top level line items 
                            //lineItem.Current_Price__c = pricingElementList(lineItem.Apttus_Config2__OptionId__c,plitemMap);
                            Id pricingProductId=(lineItem.Apttus_config2__LineType__c=='Product/Service')?lineItem.Apttus_config2__ProductId__c:lineItem.Apttus_config2__OptionId__c; 
                            lineItem.Current_Price__c = pricingElementList(pricingProductId,plitemMap);                         
                            
                            lineItem.Apttus_Config2__AdjustmentAmount__c = Discount;
                            lineItem.Tier__c = '1';
                            //Changed by Mansi Mehta (9-8-2016) - Updated baseoverride field instead of base price to avoid pricing issue while repricing first time Previously we had to reprice twice to get the excepted result
                           // lineItem.Apttus_Config2__ExtendedPrice__c = lineItem.Apttus_Config2__BasePrice__c * lineItem.Apttus_Config2__Quantity__c;
                            lineItem.Apttus_Config2__ExtendedPrice__c = lineItem.Apttus_Config2__BasePriceOverride__c * lineItem.Apttus_Config2__Quantity__c;
                            system.debug('lineItem.Apttus_Config2__ExtendedPrice__c:::'+lineItem.Apttus_Config2__ExtendedPrice__c);
                           Decimal listPrice=lineItem.Apttus_Config2__ListPrice__c!=null?lineItem.Apttus_Config2__ListPrice__c:0;
                           //lineItem.Extended_List_Price__c = lineItem.Apttus_Config2__ListPrice__c * lineItem.Apttus_Config2__Quantity__c;
                            lineItem.Apttus_Config2__NetPrice__c = lineItem.Apttus_Config2__ExtendedPrice__c;
                            lineItem.APTS_Final_Net_Price__c=lineItem.Apttus_Config2__NetPrice__c* lineItem.Apttus_Config2__Quantity__c; 
                            system.debug( '!!.. lineItem.Current_Price__c hillRomAdjusting '+lineItem.Current_Price__c );
                            system.debug( '!!.. isNotCtrctYrNet hillRomAdjusting '+isNotCtrctYrNet );
                            system.debug( '!!.. pric.Value__c hillRomAdjusting '+pric.Value__c );
                            system.debug( '!!.. Discount hillRomAdjusting '+Discount ); 
                            // 12/09/2015 - Luis Arismendy / Raul Mora - Verify that the List price is not 0
                            if( lineItem.Current_Price__c != 0 )
                            {
                                // 12/09/2015 - Luis Arismendy / Raul Mora - Depending if the Adjustment Schedules contract year is NET or not it will calculate the Net Adjustment Percent 
                                lineItem.NetAdjustmentPercent2__c = isNotCtrctYrNet ? ( ( ( lineItem.Current_Price__c - ( pric.Value__c * ( ( 100 - Discount ) / 100 ) ) ) / pric.Value__c ) * 100 ) : ( 100 - ( ( pric.Value__c * 100 ) / lineItem.Current_Price__c ) ) ;
                            }
                            lineItem.NetAdjustmentPercent2__c = lineItem.NetAdjustmentPercent2__c * ( -1 );
                            system.debug('!!..Net Price hillRomAdjusting ' + lineItem.Apttus_Config2__NetPrice__c );
                            system.debug('!!..Net Adjustment Percent hillRomAdjusting ' + lineItem.NetAdjustmentPercent2__c ); 
                        } else{
                            // #ApttusLabs 08/02/16 - Updated to price option products on individual top level line items 
                            system.debug('!!..No discount found for netPricingKey hillRomAdjusting: ' + netPricingKey);

                        }
                  
                }

                else {
                        
                    // #ApttusLabs 08/02/16 - Updated to price option products on individual top level line items 
                    //lineItem.Current_Price__c = pricingElementList(lineItem.Apttus_Config2__OptionId__c,plitemMap); 
                    system.debug('!!..No discount found for adjSchdKey hillRomAdjusting: ' + adjSchdKey);

                    
                }
                
            }
        }
    }   
    
    // To be called only in rolldown mode
    //Option Discounts % to be re-calculated.
    //Calcualte the discounts given at the summary group level and show a net % value in Net Adjustment2%
    /*public Static void DistributeGroupLevelDiscounts(Apttus_Config2.ProductConfiguration.LineItemColl itemColl, Apttus_Config2.LineItem lineItemMO)
    {
      //get all lineitems
      List<Apttus_Config2.LineItem> allLines = itemColl.getAllLineItems();      
      for(Apttus_Config2.LineItem lineItemMObj : allLines) {
      // get the main product line item sobject      
      Apttus_Config2__LineItem__c lineItemSO = lineItemMObj.getLineItemSO();
      System.debug('@APTS_Final_Net_Price__c:'+lineItemSO.APTS_Final_Net_Price__c+': Ext Price'+lineItemSO.Apttus_Config2__ExtendedPrice__c);
      if(lineItemSO.Apttus_Config2__ExtendedPrice__c >0 && lineItemSO.Apttus_Config2__NetPrice__c >0) 
      lineItemSO.NetAdjustmentPercent2__c= 100 * (lineItemSO.Apttus_Config2__ExtendedPrice__c - lineItemSO.Apttus_Config2__NetPrice__c)/lineItemSO.Apttus_Config2__ExtendedPrice__c;
      
      }

      //Apttus_Config2__LineItem__c lineItemSO = lineItemMO.getLineItemSO();
      
     
    } */

    // Aggregate the listprice of all the option over to the bundle in the cart.
    public static void ListPriceAggregation(Apttus_Config2.ProductConfiguration.LineItemColl itemColl, Apttus_Config2.LineItem lineItemMO)
    {
     //get all lineitems
       
       if( lineItemMO.getLineItemSO().Apttus_Config2__LineType__c!='Product/Service')
          return;

       List<Apttus_Config2.LineItem> allLines = itemColl.getAllLineItems();
      
       Decimal basePrice=0;
       Decimal AdjustedPrice=0;
       Decimal ListPriceAggregation=0.0;
       Decimal finalNetPrice=0.0;
       Decimal ExtendedListPrice=0.0;
      for(Apttus_Config2.LineItem lineItemMObj : allLines) {
      // get the main product line item sobject
      Apttus_Config2__LineItem__c lineItemSO = lineItemMObj.getLineItemSO();
      
      if(lineItemSO.Apttus_Config2__LineType__c.equals('Product/Service'))
         continue;
        
      System.debug('lineItemSO:::before'+lineItemSO);    
        
      ListPriceAggregation+= lineItemSO.Apttus_Config2__ListPrice__c!=null?lineItemSO.Apttus_Config2__ListPrice__c:0;
      finalNetPrice+= lineItemSO.APTS_Final_Net_Price__c!=null?lineItemSO.APTS_Final_Net_Price__c:0;   
      //Changed by Mansi Mehta (9-8-2016) - Updated baseoverride field instead of base price to avoid pricing issue while repricing first time Previously we had to reprice twice to get the excepted result
      //basePrice+= lineItemSO.Apttus_Config2__BasePrice__c!=null?lineItemSO.Apttus_Config2__BasePrice__c:0;
      basePrice+= lineItemSO.Apttus_Config2__BasePriceOverride__c!=null?lineItemSO.Apttus_Config2__BasePriceOverride__c:lineItemSO.Apttus_Config2__BasePrice__c;
      AdjustedPrice+=  lineItemSO.Apttus_Config2__AdjustedPrice__c!=null?lineItemSO.Apttus_Config2__AdjustedPrice__c:0; 
      ExtendedListPrice+=(lineItemSO.Apttus_Config2__ListPrice__c!=null)?lineItemSO.Apttus_Config2__ListPrice__c*lineItemSO.Apttus_Config2__Quantity__c:0;
      }

      Apttus_Config2__LineItem__c lineItemSO = lineItemMO.getLineItemSO();
      // #ApttusLabs 08/02/16 - Updated to price option products on individual top level line items 
      //if(lineItemSO.APTS_Product_Code__c == null)
      // #Sreekanth 08/11/2016 - changed condition to use configuration type instead of product code
      //Apttus_Config2__LineItem__c lineItemSO1 = [select Id, Configuration_Type__c from Apttus_Config2__LineItem__c where Id = :lineItemSO.Id];
      
      if(lineItemSO.Configuration_Type__c == 'Bundle' && lineItemSO.Apttus_Config2__LineType__c.equals('Product/Service'))
      {
          System.debug('lineItemSO:::before bundleApttus_Config2__ExtendedPrice__c'+lineItemSO.Apttus_Config2__ExtendedPrice__c);
          lineItemSO.Apttus_Config2__ListPrice__c=ListPriceAggregation; 
          system.debug('finalNetPrice::'+finalNetPrice+'::Apttus_Config2__Quantity__c::'+lineItemSO.Apttus_Config2__Quantity__c);
          lineItemSO.APTS_Final_Net_Price__c=finalNetPrice*lineItemSO.Apttus_Config2__Quantity__c; 
          //Changed by Mansi Mehta (9-8-2016) - Updated baseoverride field instead of base price to avoid pricing issue while repricing first time Previously we had to reprice twice to get the excepted result
          //lineItemSO.Apttus_Config2__BasePrice__c=basePrice;
          lineItemSO.Apttus_Config2__BasePriceOverride__c=basePrice;
          lineItemSO.Apttus_Config2__BasePrice__c = lineItemSO.Apttus_Config2__BasePriceOverride__c;
          lineItemSO.Apttus_Config2__AdjustedPrice__c = adjustedPrice*lineItemSO.Apttus_Config2__Quantity__c; 
          lineItemSO.Extended_List_Price__c=ExtendedListPrice * lineItemSO.Apttus_Config2__Quantity__c;
          lineItemSO.Apttus_Config2__ExtendedPrice__c=lineItemSO.Apttus_Config2__BasePrice__c * lineItemSO.Apttus_Config2__Quantity__c;
          
          System.debug('lineItemSO:::'+lineItemSO);
      }
     
    }

    //To be called in adjustment Mode in after pricing method
    /*public static void applyDiscretionaryDiscount(Apttus_Config2.ProductConfiguration.LineItemColl itemColl) 
    { 
       //get all lineitems
      //if(lineItemMO.getLineItemSO().Apttus_Config2__LineType__c=='Product/Service'){}
      List<Apttus_Config2.LineItem> allLines = itemColl.getAllLineItems();
      
      for(Apttus_Config2.LineItem lineItemMObj : allLines) {
      // get the main product line item sobject
      Apttus_Config2__LineItem__c lineItemSO = lineItemMObj.getLineItemSO();
      lineItemSO.APTS_Final_Net_Price__c=lineItemSO.Apttus_Config2__NetPrice__c;
      if(lineItemSO.APTS_Discretionary_Discount__c>0)
        { 
            string discountType=!string.isBlank(lineItemSO.Discretionary_Discount_Type__c)?lineItemSO.Discretionary_Discount_Type__c:'default';
            if(discountType.equalsIgnoreCase('% Discount off CONTRACT'))
            lineItemSO.APTS_Final_Net_Price__c= lineItemSO.Apttus_Config2__NetPrice__c -( lineItemSO.Apttus_Config2__NetPrice__c * lineItemSO.APTS_Discretionary_Discount__c * 0.01);
            else if(discountType.equalsIgnoreCase('Discount Amount')) 
            lineItemSO.APTS_Final_Net_Price__c= lineItemSO.Apttus_Config2__NetPrice__c -lineItemSO.APTS_Discretionary_Discount__c; 
            else if(discountType.equalsIgnoreCase('Price Override'))
            lineItemSO.APTS_Final_Net_Price__c= lineItemSO.APTS_Discretionary_Discount__c;    
            
            
        }

        //if(lineItemSO.Apttus_Config2__ExtendedPrice__c >0 && lineItemSO.APTS_Final_Net_Price__c >0) 
          //lineItemSO.NetAdjustmentPercent2__c= (lineItemSO.Apttus_Config2__ExtendedPrice__c - lineItemSO.APTS_Final_Net_Price__c)/lineItemSO.APTS_Final_Net_Price__c;
      


      } 
     
 
    }*/
 

    private decimal pricingElementList(ID ProductId,map<Id,Apttus_config2__PriceListItem__c> plimap){
        decimal netPrice = 0;

         Apttus_Config2__PriceListItem__c pli=plimap.containsKey(ProductId)?plimap.get(ProductId)
                                                                              :new Apttus_Config2__PriceListItem__c(Apttus_Config2__ListPrice__c=0); 
                        
          netPrice =pli.Apttus_Config2__ListPrice__c;  
        /*for(List<Apttus_Config2__PriceListItem__c> ListOfNets : [SELECT Apttus_Config2__ListPrice__c FROM Apttus_Config2__PriceListItem__c WHERE Apttus_Config2__ProductId__c = :ProductId LIMIT 1]) {
            for ( Apttus_Config2__PriceListItem__c pric : ListOfNets ) {
                netPrice = pric.Apttus_Config2__ListPrice__c != null ? pric.Apttus_Config2__ListPrice__c : 0;
            }           
        } */        

        return netPrice; 
    } 
    
    // set the quantity of product  '3101055 - End Cover H70, white' added by rule to 2 * count of option from rails group
    public static void updateEndCoverOptionQuantity(Apttus_Config2.ProductConfiguration.LineItemColl  itemColl)
    {
       
       set<Id> railsGroupProductIds=new set<Id>();
       set<string> productGroupSet= new set<string>{'H70 Rails - White',
                                                    'H70 Rails - Natural',
                                                    'H100 Rails - White',
                                                    'H100 Rails - Natural',
                                                    'H140 Rails - Natural',
                                                    'H140 Rails - White',
                                                    'H160 Rails - Natural',
                                                    'H160 Rails - White' 
                                                   };
       for(Apttus_Config2__ProductGroupMember__c pgm:[select id,Apttus_Config2__ProductId__c 
                                                      from Apttus_Config2__ProductGroupMember__c 
                                                      where Apttus_Config2__ProductGroupId__r.name In:productGroupSet ]) 
       {
           railsGroupProductIds.add(pgm.Apttus_Config2__ProductId__c);
       }
        
       if(railsGroupProductIds.size()==0)
          return;
       
       system.debug('** product group contains members');
       Apttus_Config2__LineItem__c EndCoverlineItem;
       map<Id,Apttus_config2__lineItem__c> LineItem_productIdMap=new map<Id,Apttus_config2__lineItem__c>();
       List<Apttus_Config2__LineItem__c> lineItemSOList=new List<Apttus_Config2__LineItem__c>();
       Decimal count=0;
       for( Apttus_Config2.LineItem lineItemMO: itemColl.getAllLineItems())
       {
           Apttus_Config2__LineItem__c lineItemSO=lineItemMO.getLineItemSO();
           
           Id ProductId=(lineItemSO.Apttus_config2__LineType__c=='Product/Service')?lineItemSO.Apttus_config2__ProductId__c:lineItemSO.Apttus_config2__OptionId__c;           
           if(railsGroupProductIds.contains(ProductId))
           count+=lineItemSO.Apttus_Config2__Quantity__c; 
           
           if(lineItemSO.Apttus_Config2__AddedBy__c=='Constraint Rule'){               
               LineItem_productIdMap.put(ProductId,lineItemSO);               
           }
           lineItemSOList.add(lineItemSO);
       }
       
       
       if(LineItem_productIdMap.keyset().size()==0)
         return;
       
        system.debug('Product added by constraint rule');
       for(product2 p:[select id,name from product2 where Id in:LineItem_productIdMap.keyset()])
       {
         if(p.name=='3101055 - End Cover H70, white')  
           if(!LineItem_productIdMap.containsKey(p.id)) 
             return;
           else{
                system.debug('Updating the quantity of end cover line');
                EndCoverlineItem=LineItem_productIdMap.get(p.Id);
                EndCoverlineItem.Apttus_Config2__Quantity__c=2*count; 
           }
           
       }
      }
    
    public static void cascadeTheDiscountfromBundle(List<Apttus_Config2__LineItem__c> lineItems, Apttus_Config2__LineItem__c bundleLine )
    {
     system.debug('CascadeDiscountfromBundle method started'+ bundleLine.Apttus_Config2__LineType__c);
     // #ApttusLabs 08/02/16 - Updated to price option products on individual top level line items 
      //if(optLine.Apttus_Config2__LineType__c=='Product/Service')
     if(bundleLine.Apttus_Config2__LineType__c!='Product/Service')
        return;
     
     if(bundleLine.APTS_Discretionary_Discount__c==0 || bundleLine.APTS_Discretionary_Discount__c==null)
        return;
     decimal descretionarydisc=bundleLine.APTS_Discretionary_Discount__c!=null?bundleLine.APTS_Discretionary_Discount__c:0;
     decimal discountpercent;
     if(bundleLine.Discretionary_Discount_Type__c=='% Discount off CONTRACT' || bundleLine.Discretionary_Discount_Type__c=='% Discount off LIST')
        discountpercent=descretionarydisc/100;
     else if(bundleLine.Discretionary_Discount_Type__c=='Discount Amount') 
         discountpercent= (bundleLine.APTS_Discretionary_Discount__c)/((bundleLine.Apttus_Config2__Quantity__c > 0) ? (bundleLine.Apttus_Config2__AdjustedPrice__c / bundleLine.Apttus_Config2__Quantity__c) : bundleLine.Apttus_Config2__AdjustedPrice__c); // Changed by Harsh Shah 11/17/2016
     else if(bundleLine.Discretionary_Discount_Type__c=='Price Override') 
         discountpercent= (((bundleLine.Apttus_Config2__Quantity__c > 0) ? (bundleLine.Apttus_Config2__AdjustedPrice__c / bundleLine.Apttus_Config2__Quantity__c) : bundleLine.Apttus_Config2__AdjustedPrice__c) - bundleLine.APTS_Discretionary_Discount__c)/((bundleLine.Apttus_Config2__Quantity__c > 0) ? (bundleLine.Apttus_Config2__AdjustedPrice__c / bundleLine.Apttus_Config2__Quantity__c) : bundleLine.Apttus_Config2__AdjustedPrice__c); //Changed by Harsh Shah 11/17/2016
     
     system.debug('***discountpercent:::'+discountpercent+':::bundleLine.Apttus_Config2__AdjustedPrice__c:::'+bundleLine.Apttus_Config2__AdjustedPrice__c+':::bundleLine.APTS_Discretionary_Discount__c:::'+bundleLine.APTS_Discretionary_Discount__c);
     
     Decimal AggregatedPrice=0.0;   
     system.debug('CascadeDiscountfromBundle'+lineItems.size());
     for(Apttus_Config2__LineItem__c optLine: lineItems)
     {
      if(optLine.Apttus_Config2__LineType__c=='Product/Service') 
         continue;
      //Changed by Harsh Shah 11/17/2016
      if(bundleLine.Discretionary_Discount_Type__c!='% Discount off LIST') {
        optLine.APTS_Final_Net_Price__c= optLine.Apttus_Config2__AdjustedPrice__c-(discountpercent* optLine.Apttus_Config2__AdjustedPrice__c);  
      }
      else {
        Decimal listPrice=optLine.Apttus_Config2__ListPrice__c!=null?optLine.Apttus_Config2__ListPrice__c:0;
        Decimal quantity = optLine.Apttus_Config2__Quantity__c!=null?optLine.Apttus_Config2__Quantity__c:0;
        optLine.APTS_Final_Net_Price__c= (listPrice*quantity)-(discountpercent* (listPrice*quantity));
      }
      
      AggregatedPrice+=optLine.APTS_Final_Net_Price__c;
      
     }

     if(bundleLine.Apttus_Config2__LineType__c=='Product/Service' && (bundleLine.Configuration_Type__c == 'Standalone' || bundleLine.Configuration_Type__c == 'Option')) {
            //Changed by Harsh Shah 11/17/2016
          if(bundleLine.Discretionary_Discount_Type__c!='% Discount off LIST') {
            bundleLine.APTS_Final_Net_Price__c= bundleLine.Apttus_Config2__AdjustedPrice__c-(discountpercent* bundleLine.Apttus_Config2__AdjustedPrice__c);  
          }
          else {
            Decimal listPrice=bundleLine.Apttus_Config2__ListPrice__c!=null?bundleLine.Apttus_Config2__ListPrice__c:0;
            Decimal quantity = bundleLine.Apttus_Config2__Quantity__c!=null?bundleLine.Apttus_Config2__Quantity__c:0;
            bundleLine.APTS_Final_Net_Price__c= (listPrice*quantity)-(discountpercent* (listPrice*quantity));
          }
          system.debug('APTS_Final_Net_Price__c Standlone '+bundleLine.APTS_Final_Net_Price__c);
     }
     else {
        //added quantity to the calculation date:09/17/2016
        bundleLine.APTS_Final_Net_Price__c=AggregatedPrice*bundleLine.Apttus_Config2__Quantity__c;
        system.debug('APTS_Final_Net_Price__c bundle '+bundleLine.APTS_Final_Net_Price__c);
     }

     
    }
    
    public static void assignFinalNetPrice(List<Apttus_Config2__LineItem__c> lineItems, Apttus_Config2__LineItem__c bundleLine )
    {

     if(bundleLine.Apttus_Config2__LineType__c!='Product/Service')
        return;
      for(Apttus_Config2__LineItem__c optLine: lineItems)
      {
                                                                    //changed condition to use configuration type instead of product code
        if(optLine.Apttus_Config2__LineType__c=='Product/Service' && optLine.Configuration_Type__c == 'Bundle' ) 
           continue;
        
        // #ApttusLabs 08/02/16 - Updated to price option products on individual top level line items 
        optLine.APTS_Final_Net_Price__c= optLine.Apttus_Config2__AdjustedPrice__c;
                    
        Decimal listPrice=optLine.Apttus_Config2__ListPrice__c!=null?optLine.Apttus_Config2__ListPrice__c:0;
        optLine.Extended_List_Price__c =  listPrice * optLine.Apttus_Config2__Quantity__c;

        decimal descretionarydisc=optLine.APTS_Discretionary_Discount__c!=null?optLine.APTS_Discretionary_Discount__c:0;
         decimal discountpercent = 0.0;
         if(optLine.Discretionary_Discount_Type__c=='% Discount off CONTRACT' || optLine.Discretionary_Discount_Type__c=='% Discount off LIST')
            discountpercent=descretionarydisc/100;
         else if(optLine.Discretionary_Discount_Type__c=='Discount Amount') 
             discountpercent= (descretionarydisc)/optLine.Apttus_Config2__AdjustedPrice__c; 
         else if(optLine.Discretionary_Discount_Type__c=='Price Override') 
             discountpercent= (optLine.Apttus_Config2__AdjustedPrice__c- descretionarydisc)/optLine.Apttus_Config2__AdjustedPrice__c; 
         optLine.APTS_Final_Net_Price__c = optLine.Apttus_Config2__AdjustedPrice__c-(discountpercent* optLine.Apttus_Config2__AdjustedPrice__c);

        system.debug('***discountpercent:::'+discountpercent+':::optLine.Apttus_Config2__AdjustedPrice__c:::'+optLine.Apttus_Config2__AdjustedPrice__c+':::optLine.APTS_Discretionary_Discount__c:::'+optLine.APTS_Discretionary_Discount__c);
     

      }
    
        
    }
    
}
/*
// if(optline.APTS_Discretionary_Discount__c!=null)
     //    Continue;
      optline.Discretionary_Discount_Type__c=bundleLine.Discretionary_Discount_Type__c;
      optline.APTS_Discretionary_Discount__c =bundleLine.APTS_Discretionary_Discount__c ; 
*/