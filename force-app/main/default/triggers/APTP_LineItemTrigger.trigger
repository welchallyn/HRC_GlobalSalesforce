trigger APTP_LineItemTrigger on Apttus_Config2__LineItem__c (before insert, before update) {
    /**
     * 7/8/2014
     * APTPS_ProposalLineItemTriggerHandler.afterInsert 
     * PRE SET contract year for pricing
     **/
	List<Adjustment_Schedule__c> ListOfDscnts = new List<Adjustment_Schedule__c>();
	private static Boolean isNotCtrctYrNet;
	private static string ContractYear;	
	private String PricingContract;
	private static Decimal Tier = 1;
		    
    if (Trigger.isBefore) {

        //12/29 change for SOQL optimization sv
        List<string> listofRepriceCode = new List<String>();
        List<string> listofContractNumber = new List<String>();
        List<Decimal> listofTier = new List<Decimal>();
        List<string> listofOrderYear = new List<String>();
        List<string> listofProdCode = new List<String>();

        //get the list of values to be queried for 
        for ( Apttus_Config2__LineItem__c lineItem : trigger.new ){
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
        
        //12/29 end of soql optimization


        //if (Trigger.isInsert) {
          // using this variable so we don't have to create yet another one

            Adjustment_Schedule__c Dscnt = null;

			for ( Apttus_Config2__LineItem__c lineItem : trigger.new ) {
	            Dscnt = null;
	            
				PricingContract = lineItem.Contract_Number__c;  
					if ( lineItem.Override_Contract_Number__c != null ) 
						PricingContract = lineItem.Override_Contract_Number__c;
					/*ListOfDscnts = [SELECT  Reprice_Code__c,		   									
												Name,
												Order_Year__c,
												Contract_Year__c,
												Tier__c,
												Discount__c
									FROM	Adjustment_Schedule__c WHERE Pricing_Contract__c = :PricingContract 
									AND 	Reprice_Code__c  = :lineItem.Line_Item_Reprice_Group_Code__c
									AND		Tier__c = :Tier
									AND     Order_Year__c = :lineItem.Order_Price_Year__c LIMIT 1];
                    */
                    
                    adjSchdKey = PricingContract+'_'+lineItem.Line_Item_Reprice_Group_Code__c+'_'+Tier +'_'+ lineItem.Order_Price_Year__c;
                    if(mapOfAdjSchd != null && mapOfAdjSchd.get(adjSchdKey) != null)
                        Dscnt = mapOfAdjSchd.get(adjSchdKey);
                    
					//if ( ListOfDscnts.size() > 0 ){
					if(Dscnt != null){
						//for (Adjustment_Schedule__c Dscnt : ListOfDscnts ){
							isNotCtrctYrNet = (Dscnt.Contract_Year__c == 'NET' ? false : true );
							ContractYear = (isNotCtrctYrNet) ? Dscnt.Contract_Year__c : Dscnt.Order_Year__c ;
							lineItem.Contract_Price_Year__c = ContractYear;
							lineItem.Apttus_Config2__BasePriceOverride__c  = null;
						//}

					}
			// }
        }
    }
}