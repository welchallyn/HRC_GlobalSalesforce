/*******************************************************************
 * Class Name: HRCSVC21_QuoteLineItemHandler
 * Author: Capgemini
 * Date: December/8/2021
********************************************************************/

public class HRCSVC21_QuoteLineItemHandler {
    public void onAfterInsert(List<QuoteLineItem> NewQuoteLines, Map<id,QuoteLineItem> OldQuoteLines){
        Set<id> QuoteLines = new Set<id>();
        for(QuoteLineItem q : NewQuoteLines){
            if(q.Product2Id != NULL){
                QuoteLines.add(q.id);
            }
        }
        if(!QuoteLines.isEmpty()){
            if(!system.isFuture()){
                GetPricing(QuoteLines);
            }
        }
    }
    //can we change product2id if not then this is unusable code.
    public void onAfterUpdate(List<QuoteLineItem> NewQuoteLines, Map<id,QuoteLineItem> OldQuoteLines){
        Set<id> QuoteLines = new Set<id>();
        for(QuoteLineItem q : NewQuoteLines){
            if(q.Product2Id != OldQuoteLines.get(q.id).Product2Id){
                QuoteLines.add(q.id);
            }
        }
        if(!QuoteLines.isEmpty()){
            if(!system.isFuture()){
                GetPricing(QuoteLines);
            }
        }
    }
    
    @future(callout=true)
    public static void GetPricing(set<id> qliIds){
        List<QuoteLineItem> updateQLIList = new List<QuoteLineItem>();
        for(id quoteId : qliIds){
            QuoteLineItem qli = new QuoteLineItem();
            qli = HRCSVC21_QuoteGetPricing.GetPricingItem(quoteId);
            if(qli != NULL){
                updateQLIList.add(qli);
            }
        }
        if(!updateQLIList.isEmpty()){
            database.update(updateQLIList);
        }
    }
}