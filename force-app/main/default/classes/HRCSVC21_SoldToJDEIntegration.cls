/*****************************************************************************************************
* Name                             : HRCSVC21_SoldToJDEIntegration
* Author                           : Capgemini
* Date                             : November/24/2021
* Requirement/Project Name         : Hill-Rom
* Requirement/Project Description  : Class to do apex callout to JDE to fetch Customer/soldTo value 
                                     and parse the response to update Order.HRCSVC20_Sold_To_Location__c 
                                     #SE-2784 (Service Cloud 2.1)
* Revison                          :
*****************************************************************************************************/
public class HRCSVC21_SoldToJDEIntegration{
    @InvocableMethod
	public static void soldToFetch (List<Id> orderIds){
    
    updateSoldTo(orderIds[0]);
    } 
    
    @future(callout=true)
    public static void updateSoldTo (Id orderIds){
      
        try
        {
        System.debug(orderIds);
        Order__c order = new Order__c();
	    order = [Select id, HRCSVC20_Sold_To_Location__c, HRCSVC_Ship_To_Location__r.HRCFSL_Customer_ID__c from Order__c where id =:orderIds LIMIT 1];
		
		Map<String, HRCSVC21_Parts_Order_Integration_Details__mdt> mapEd = HRCSVC21_Parts_Order_Integration_Details__mdt.getAll();
        System.debug('MapEd values-->'+Json.serializePretty(mapEd.get('HRCSVC21_Sold_To_Integration')));
        
		Http http = new Http();
        HttpRequest request = new HttpRequest();
        System.debug('----->'+mapEd.get('HRCSVC21_Sold_To_Integration').HRCSVC21_Client_Id__c);
        request.setHeader('clientid',(String) mapEd.get('HRCSVC21_Sold_To_Integration').HRCSVC21_Client_Id__c);
        request.setHeader('clientsecret', mapEd.get('HRCSVC21_Sold_To_Integration').HRCSVC21_Client_Secret__c);
        request.setHeader('X-Correlation-ID', mapEd.get('HRCSVC21_Sold_To_Integration').HRCSVC21_X_Correlation_ID__c);
        request.setHeader('Content-Type',mapEd.get('HRCSVC21_Sold_To_Integration').HRCSVC21_Content_Type__c);
        String endpoint = mapEd.get('HRCSVC21_Sold_To_Integration').HRCSVC21_URL__c+order.HRCSVC_Ship_To_Location__r.HRCFSL_Customer_ID__c;
        request.setEndpoint(endpoint);
        system.debug('endpoint'+endpoint);
	    request.setMethod(mapEd.get('HRCSVC21_Sold_To_Integration').HRCSVC21_Method__c);
        request.setTimeout(12000);
            
        HttpResponse res = http.send(request);
        String result=res.getBody();
        System.debug('Recieved Body Data======>>>'+JSON.serializePretty(result));            
        Map<String, String> mapOrd = (Map<String, String>) JSON.deserialize(result, Map<String, String>.class); //Deserializing using Map to fetch 'Sold To' value from the response body
        String soldTo = mapOrd.get('soldToCustomerId');
        System.debug('SoldToCustomer Response Value===>'+soldTo); 
        Id SoldToCustomer = [Select Id FROM Location WHERE HRCFSL_Customer_ID__c = :soldTo LIMIT 1].Id; //Sold To customer Id returned from JDE integration needs to be matched on location customer Id
	    System.debug('SoldToCustomerId======>>>'+soldToCustomer);
        order.HRCSVC20_Sold_To_Location__c = soldToCustomer;
            
	    update order;
        }
        Catch(exception e)
        {
          System.debug('Error In Line'+e.getLineNumber()+'Cause-'+e.getCause()+e.getStackTraceString()); 
        }
     }
}