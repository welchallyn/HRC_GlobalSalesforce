/************************************************************************************************
 * Name								: HRCSVC21_QuoteSoldToJDEIntegration
 * Author							: Capgemini
 * Date								: December/8/2021
 * Requirement/Project Name			: Hill-Rom
 * Requirement/Project Description	: Class to do apex callout to JDE to fetch Customer/SoldTo value from a Quote.
*************************************************************************************************/

public class HRCSVC21_QuoteSoldToJDEIntegration {
	@InvocableMethod
    public static void GetSoldTo(List<Id> Ids){
        UpdateSoldTo(Ids[0]);
    }
    
    @future(callout=true)
    public static void UpdateSoldTo(Id QuoteId){
        Quote quote = new Quote();
        try{           
            quote = [Select Id, HRCSVC21_Sold_to_location__c, HRCSVC21_Ship_to_location__r.HRCFSL_Customer_ID__c, HRCSVC21_Error_Message__c from Quote where Id = :QuoteId];
            Map<String, HRCSVC21_Parts_Order_Integration_Details__mdt> mapEd = HRCSVC21_Parts_Order_Integration_Details__mdt.getAll();
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setHeader('clientid',(String) mapEd.get('HRCSVC21_Sold_To_Integration').HRCSVC21_Client_Id__c);
        	request.setHeader('clientsecret', mapEd.get('HRCSVC21_Sold_To_Integration').HRCSVC21_Client_Secret__c);
            request.setHeader('X-Correlation-ID', mapEd.get('HRCSVC21_Sold_To_Integration').HRCSVC21_X_Correlation_ID__c);
            request.setHeader('Content-Type',mapEd.get('HRCSVC21_Sold_To_Integration').HRCSVC21_Content_Type__c);
            String endpoint = mapEd.get('HRCSVC21_Sold_To_Integration').HRCSVC21_URL__c+quote.HRCSVC21_Ship_to_location__r.HRCFSL_Customer_ID__c;
            request.setEndpoint(endpoint);
            system.debug('endpoint'+endpoint);
            request.setMethod(mapEd.get('HRCSVC21_Sold_To_Integration').HRCSVC21_Method__c);
            request.setTimeout(120000);
            HttpResponse res = http.send(request);
            String result = res.getBody();
            if(res.getStatusCode() == 200){
                System.debug('Recieved Body Data======>>>'+JSON.serializePretty(result));
            	Map<String, String> mapOrd = (Map<String, String>) JSON.deserialize(result, Map<String, String>.class); //Deserializing using Map to fetch 'Sold To' value from the response body
                String soldTo = mapOrd.get('soldToCustomerId');
               	Id SoldToCustomer = [Select Id FROM Location WHERE HRCFSL_Customer_ID__c = :soldTo LIMIT 1].Id;
                quote.HRCSVC21_Sold_to_location__c = SoldToCustomer;
                if(quote.HRCSVC21_Error_Message__c!= NULL){
                    quote.HRCSVC21_Error_Message__c = NULL;
                }
            }
            else{
                Map<String, Object> mapJSON = (Map<String, Object>) JSON.deserializeUntyped(result);
                Map<String, Object> errors = (Map<String, Object>)mapJSON.get('error');
               String errorMessage = String.valueOf(errors.get('message'));
                quote.HRCSVC21_Error_Message__c = errorMessage;
            }
            update quote;
        }
        Catch(exception e){
            quote = [Select Id, HRCSVC21_Error_Message__c from quote where Id = :QuoteId];
            quote.HRCSVC21_Error_Message__c = e.getMessage();
            System.debug('Error In Line'+e.getLineNumber()+'Cause-'+e.getCause()+e.getStackTraceString());
            update quote;
        }
    }
}