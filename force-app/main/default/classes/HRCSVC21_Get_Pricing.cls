/*********************************************************************************************************************************************
* Trigger Name: HRCSVC21_Get_Pricing
* Author: Capgemini
* Date: Nov/21/2021
*********************************************************************************************************************************************/
public class HRCSVC21_Get_Pricing {
    public static  Boolean flag;
    public static List<Order_Line_Item__c> OliList=new List<Order_Line_Item__c>();
    public static  List<String> Message;
    public static  String orderID;
    public static  String passingIds(List<String> allIds){
        Message= new list<String>();
        try{
            flag=true;
            for(String record:allIds){
                if(record.length()==18){
                    system.debug('richa'+record.length());
                    system.debug(' before times????');
                    Order_Line_Item__c oli = new Order_Line_Item__c ();
                   oli = requestPricingitem((id)record,true);
                   if(oli != null)
                  OliList.add(oli);
                   // OliList.add(requestPricingitem((id)record,true));
                    system.debug('times????');
                } 
            }  if(!OliList.isEmpty()){
                update OliList;
                // Order_Line_Item__c oli=[select Order__c from Order_Line_Item__c where id=]
                if(Message.size() == 0){
                    Message.add(orderID);
                }            
                system.debug('Message'+Message);   
            }
        }catch(Exception e){
         Message.add('Error!');  
        }
        return Message[0];
    } 
    public static  Order_Line_Item__c requestPricingitem(Id oliId,Boolean isflag) {
        Order_Line_Item__c oli = new Order_Line_Item__c ();
      
        try{  
            //String orderid;
            Map<String, HRCSVC21_Parts_Order_Integration_Details__mdt> mapEd = HRCSVC21_Parts_Order_Integration_Details__mdt.getAll();
            oli = [Select id, Order__c, Order__r.HRCSVC20_Business_Unit__c,name, Order__r.HRCSVC20_Pricing_Processing_Version__c, Order__r.HRCSVC_Ship_To_Location__r.HRCFSL_Customer_ID__c,Product__r.HRCFSL_Parts_Number__c,
                   Order__r.HRCSVC20_Sold_To_Location__r.HRCFSL_Customer_ID__c,HRCSVC20_Unit_Price__c, HRCSVC21_Error_Message__c from Order_Line_Item__c where id = :oliId LIMIT 1];
            orderID=oli.Order__c;
            system.debug('sold to id: ' + oli.order__r.HRCSVC20_Sold_To_Location__r.HRCFSL_Customer_ID__c);
            Http http = new Http(); 
            HttpRequest request = new HttpRequest();
            request.setHeader('clientid',(String) mapEd.get('HRCSVC21_Get_Unit_Price').HRCSVC21_Client_Id__c);
            request.setHeader('clientsecret', mapEd.get('HRCSVC21_Get_Unit_Price').HRCSVC21_Client_Secret__c);
            request.setHeader('X-Correlation-ID', mapEd.get('HRCSVC21_Get_Unit_Price').HRCSVC21_X_Correlation_ID__c);
            request.setHeader('Content-Type',mapEd.get('HRCSVC21_Get_Unit_Price').HRCSVC21_Content_Type__c);
            String endpoint = mapEd.get('HRCSVC21_Get_Unit_Price').HRCSVC21_URL__c+'?soldToEntityId='+oli.Order__r.HRCSVC20_Sold_To_Location__r.HRCFSL_Customer_ID__c+'&businessUnit='+oli.Order__r.HRCSVC20_Business_Unit__c+'&processingVersion='+oli.Order__r.HRCSVC20_Pricing_Processing_Version__c+'&shipToEntityId='+oli.Order__r.HRCSVC_Ship_To_Location__r.HRCFSL_Customer_ID__c+'&partsNumber='+oli.Product__r.HRCFSL_Parts_Number__c+'';
            //system.debug('endpoint1'+endpoint);
           // String endpoint = mapEd.get('HRCSVC21_Get_Unit_Price').HRCSVC21_URL__c+'?soldToEntityId=600077&businessUnit=99635&processingVersion=HRC0005A&shipToEntityId=600077&partsNumber=P2217A';
            system.debug('endpoint'+endpoint);
            request.setEndpoint(endpoint);
            request.setMethod(mapEd.get('HRCSVC21_Get_Unit_Price').HRCSVC21_Method__c);
            request.setTimeout(120000);
            system.debug('setBody====>>>'+request.getBody());
            HttpResponse response = Http.send(request);
            String result=response.getBody();
            System.debug('resultresult'+JSON.serializePretty(result));
            if(response.getStatusCode() == 200){      
                Map<String, String> mapOrd = (Map<String, String>) JSON.deserialize(result, Map<String, String>.class);
                String unitprice= mapOrd.get('priceUnit');
                String curCode = mapOrd.get('currencyCode');
                oli.HRCSVC20_Unit_Price__c=decimal.valueOf(unitprice);
                oli.CurrencyIsoCode = curCode;
                if(oli.HRCSVC21_Error_Message__c != NULL){
                    oli.HRCSVC21_Error_Message__c = NULL;
                }              
            }
            else{
                Map<String, Object> mapJSON = (Map<String, Object>) JSON.deserializeUntyped(result);
                Map<String, Object> errors = (Map<String, Object>)mapJSON.get('error');
                String errorMessage = String.valueOf(errors.get('message'));
                oli.HRCSVC21_Error_Message__c = errorMessage;
                Message.add(oli.Id);
            }
            return oli;
            // oli.HRCSVC20_Unit_Price__c=decimal.valueOf('200');
            /*if(isflag){
                OliList.add(oli);
                }*/
        }catch(Exception e){
            system.debug('error'+e.getMessage()+e.getLineNumber()+e.getStackTraceString());
            oli=null;
            return oli;
        } 
        
    }
}