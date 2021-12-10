/*****************************************************************************************************
* Name                             : HRCSVC21_InventoryCheckHandler
* Author                           : Capgemini
* Date                             : November/24/2021
* Requirement/Project Name         : Hill-Rom
* Requirement/Project Description  : Class to do apex callout to JDE to fetch product quantity from inventory 
                                     and parse the response to update Order_Line_Item__c.HRCSVC20_Available_Quantity__c 
                                     #SE-2780 (Service Cloud 2.1)
* Revison                          :
*****************************************************************************************************/

global class HRCSVC21_InventoryCheckHandler {
          
    global class inputValue
    {
        @InvocableVariable(required=true)
        global Id recordId;
        
    }
    global class returnmessage
    {
        @InvocableVariable
        global string succerrmsg;
    } 
    
    @InvocableMethod(label='Get Available Quantity' description='Get available quantity on oli')
    
    public static List<returnmessage>UpdateorderLines(List<Id> recordId)

    {   
        
        returnmessage returnresults = new returnmessage();
        List<returnmessage> Output =new  List<returnmessage>();
        try{
        List<Order_Line_Item__c> oliList = [SELECT Id,Product__c,HRCSVC20_Available_Quantity__c,order__r.id,Order__r.HRCSVC_Ship_To_Location__r.HRCFSL_Customer_ID__c,Order__r.HRCSVC20_Business_Unit__c,Order__r.HRCSVC20_Pricing_Processing_Version__c,Product__r.HRCFSL_Parts_Number__c FROM Order_Line_Item__c WHERE Order__r.id =:recordId]; 
        system.debug('olilist :---->>>>>>>' +oliList);
        
        List<Id> OLIId = new List<Id>();
       
        for( Order_Line_Item__c olc: oliList){
            if(olc.Product__c!=null){
                OLIId.add(olc.id);
            }
        }
        
        
        if(!OLIId.isEmpty()){
             
           returnresults = new returnmessage();
            returnresults.succerrmsg= getavailablequantity(OLIId);
            Output.add(returnresults);
           
        }  
      
        }
        catch(exception e){
            returnresults = new returnmessage();
            returnresults.succerrmsg='Processing Problem';
            Output.add(returnresults);
        }
        system.debug('output value' +Output);
        return Output;
        
    } 
    
    public static string getavailablequantity(List<Id> oliIdnew){
        
      String succerrmessage;
      String result; 
        try{
            List<Order_Line_Item__c> OliUpdatedList = New list <Order_Line_Item__c>();
            For(id OLI:oliIdnew ){
                Order_Line_Item__c olinew = new Order_Line_Item__c();
                olinew = requestavailablequantity(OLI);
                if(olinew !=null){
                    OliUpdatedList.add(olinew);
                }
                
             
            } 
            if(!OliUpdatedList.isEmpty()){
                update OliUpdatedList;
                result = System.label.HRCSVC20_product_availability_success_message;
            }
            else{
                result = System.label.HRCSVC20_product_nonavailability_error_message;
            }
            succerrmessage= result ;
        }
        
        catch(exception e)
        {
           
          result = System.label.HRCSVC20_product_nonavailability_error_message;
          succerrmessage = result;
            
        } 
        
        return succerrmessage;
    }
    
    public static Order_Line_Item__c requestavailablequantity(Id oliIdnew) {
        Order_Line_Item__c oli = new Order_Line_Item__c ();
        try{
        Map<String, HRCSVC21_Parts_Order_Integration_Details__mdt> mapEd = HRCSVC21_Parts_Order_Integration_Details__mdt.getAll();
        System.debug('MapEd values-->'+Json.serializePretty(mapEd.get('HRCSVC21_Inventory')));
        
        oli = [Select id,Product__c,HRCSVC20_Available_Quantity__c,order__r.id,Order__r.HRCSVC_Ship_To_Location__r.HRCFSL_Customer_ID__c,Order__r.HRCSVC20_Business_Unit__c,Order__r.HRCSVC20_Pricing_Processing_Version__c,Product__r.HRCFSL_Parts_Number__c,HRCSVC21_Error_Message__c from Order_Line_Item__c where id = :oliIdnew LIMIT 1];
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('client_id',(String) mapEd.get('HRCSVC21_Inventory').HRCSVC21_Client_Id__c);
        request.setHeader('client_secret', mapEd.get('HRCSVC21_Inventory').HRCSVC21_Client_Secret__c);
        request.setHeader('X-Correlation-ID', mapEd.get('HRCSVC21_Inventory').HRCSVC21_X_Correlation_ID__c);
        request.setHeader('Content-Type',mapEd.get('HRCSVC21_Inventory').HRCSVC21_Content_Type__c);
        //String endpoint = mapEd.get('HRCSVC21_Inventory').HRCSVC21_URL__c+'?businessUnit=99635&processingVersion=HRC0005A&shipToEntityId=3200864&partsNumber=159964';
        String endpoint = mapEd.get('HRCSVC21_Inventory').HRCSVC21_URL__c+'?shipToEntityId='+oli.Order__r.HRCSVC_Ship_To_Location__r.HRCFSL_Customer_ID__c+'&businessUnit='+oli.Order__r.HRCSVC20_Business_Unit__c+'&processingVersion='+oli.Order__r.HRCSVC20_Pricing_Processing_Version__c+'&partsNumber='+oli.Product__r.HRCFSL_Parts_Number__c+'';
        request.setEndpoint(endpoint);
            system.debug('Endpoint' +endpoint);
        request.setMethod(mapEd.get('HRCSVC21_Inventory').HRCSVC21_Method__c);
        request.setTimeout(120000); 
        
        
        system.debug('setBody====>>>'+request.getBody());
        HttpResponse response = Http.send(request);
        String result=response.getBody();
        System.debug('Recieved Body Data======>>>'+JSON.serializePretty(result));
                  
            if(response.getStatusCode() == 200){
                Map<String, String> mapOrd = (Map<String, String>) JSON.deserialize(result, Map<String, String>.class); //Deserializing using Map to fetch 'Available Quantity' value from the response body
                String AvailableQuantity = mapOrd.get('quantityAvailable');
                System.debug('quantity available: ' + AvailableQuantity); 
                System.debug('resultresult'+result);
                Integer AvailQuantity = Integer.valueOf(AvailableQuantity);
                if(AvailQuantity < 0){
                    AvailQuantity = 0;
                }
                oli.HRCSVC20_Available_Quantity__c = AvailQuantity;
                if(oli.HRCSVC21_Error_Message__c != NULL){
                    oli.HRCSVC21_Error_Message__c = NULL;
                }
            }
            else{
                Map<String, Object> mapJSON = (Map<String, Object>) JSON.deserializeUntyped(result);
                Map<String, Object> errors = (Map<String, Object>)mapJSON.get('error');
                String errorMessage = String.valueOf(errors.get('message'));
                oli.HRCSVC21_Error_Message__c = errorMessage;
            }
        return oli;
    }
    
    catch(exception e)
    {
        system.debug('error- '+e.getMessage()+e.getStackTraceString());
        oli = [Select Id, HRCSVC21_Error_Message__c FROM Order_Line_Item__c WHERE id = :oliIdnew];
        oli.HRCSVC21_Error_Message__c = e.getMessage();
        return oli;
    }
       
    } 
   
}