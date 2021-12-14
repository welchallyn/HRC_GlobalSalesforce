/********************************************************************
 * Class Name: HRCSVC21_QuoteGetPricing
 * Author: Capgemini
 * Date: December/8/2021
********************************************************************/

public class HRCSVC21_QuoteGetPricing {
    public static QuoteLineItem GetPricingItem(Id QuoteId){
        QuoteLineItem qli = new QuoteLineItem();
        try{
            Map<String, HRCSVC21_Parts_Order_Integration_Details__mdt> mapEd = HRCSVC21_Parts_Order_Integration_Details__mdt.getAll();
            qli = [Select id, Quote.HRCSVC21_Ship_to_location__r.HRCFSL_Customer_ID__c, Quote.HRCSVC21_Business_Unit__c, Quote.HRCSVC21_Pricing_Processing_Version__c, 
                   Product2.ProductCode, Quote.HRCSVC21_Sold_to_location__r.HRCFSL_Customer_ID__c, UnitPrice, HRCSVC21_Error_Message__c from QuoteLineItem where Id = :QuoteId];
            Http http = new Http(); 
            HttpRequest request = new HttpRequest();
            request.setHeader('client_id',(String) mapEd.get('HRCSVC21_Get_Unit_Price').HRCSVC21_Client_Id__c);
            request.setHeader('client_secret', mapEd.get('HRCSVC21_Get_Unit_Price').HRCSVC21_Client_Secret__c);
            request.setHeader('X-Correlation-ID', mapEd.get('HRCSVC21_Get_Unit_Price').HRCSVC21_X_Correlation_ID__c);
            request.setHeader('Content-Type',mapEd.get('HRCSVC21_Get_Unit_Price').HRCSVC21_Content_Type__c);
            //String endpoint = mapEd.get('HRCSVC21_Get_Unit_Price').HRCSVC21_URL__c+'?soldToEntityId=600077&businessUnit=99635&processingVersion=HRC0005A&shipToEntityId=600077&partsNumber=P2217A';
            String endpoint = mapEd.get('HRCSVC21_Get_Unit_Price').HRCSVC21_URL__c+'?soldToEntityId='+qli.Quote.HRCSVC21_Sold_to_location__r.HRCFSL_Customer_ID__c+'&businessUnit='+qli.Quote.HRCSVC21_Business_Unit__c+'&processingVersion='+qli.Quote.HRCSVC21_Pricing_Processing_Version__c+'&shipToEntityId='+qli.Quote.HRCSVC21_Ship_to_location__r.HRCFSL_Customer_ID__c+'&partsNumber='+qli.Product2.ProductCode+'';
            system.debug('endpoint'+endpoint);
            request.setEndpoint(endpoint);
            request.setMethod(mapEd.get('HRCSVC21_Get_Unit_Price').HRCSVC21_Method__c);
            request.setTimeout(120000);
            HttpResponse response = Http.send(request);
            String result=response.getBody();
            System.debug(result);
            if(response.getStatusCode() == 200){      
                Map<String, String> mapOrd = (Map<String, String>) JSON.deserialize(result, Map<String, String>.class);
               	qli.UnitPrice=decimal.valueOf(mapOrd.get('priceUnit'));
                if(qli.HRCSVC21_Error_Message__c != NULL){
                    qli.HRCSVC21_Error_Message__c = NULL;
                }              
            }
            else{
                Map<String, Object> mapJSON = (Map<String, Object>) JSON.deserializeUntyped(result);
                Map<String, Object> errors = (Map<String, Object>)mapJSON.get('error');
               // String errorMessage = String.valueOf(errors.get('message'));
                qli.HRCSVC21_Error_Message__c =String.valueOf(errors.get('message'));
            }
            return qli;
        }
        Catch(Exception e){
            system.debug('error'+e.getMessage()+e.getLineNumber()+e.getStackTraceString());
            qli = [Select Id, HRCSVC21_Error_Message__c FROM QuoteLineItem WHERE id = :QuoteId];
        	qli.HRCSVC21_Error_Message__c = e.getMessage(); //update error message field with exception message
            return qli;
        }
    }
}