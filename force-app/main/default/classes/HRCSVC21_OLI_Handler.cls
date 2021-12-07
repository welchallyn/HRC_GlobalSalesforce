/*********************************************************************************************************************************************
* Class Name: HRCSVC21_OLI_Handler
* Author: Capgemini
* Date: Nov/21/2021
*******************************************************************************************************************/
global class HRCSVC21_OLI_Handler {
  
    @InvocableVariable(required=true)
    global List<Id> recordIds;
    
    public void onAfterInsert(List<Order_Line_Item__c> NewOrderLineItemList,Map<id,Order_Line_Item__c> oldOrderLineItemMap){
        Id recordTypeId = Schema.SObjectType.Order_Line_Item__c.getRecordTypeInfosByName().get('Parts Order Line Item').getRecordTypeId();
        Set<id> allOLIId= new Set<id>();
        for( Order_Line_Item__c olc: NewOrderLineItemList){
            if(olc.recordTypeId==recordTypeId){
            if(olc.Product__c!=null){
                 allOLIId.add(olc.id);
            }
            }
        }if(!allOLIId.isEmpty()){
            if(!system.isFuture()){
             getPricingitem(allOLIId) ;
            }   
        } 
    }
    public void onAfterUpdate(List<Order_Line_Item__c> NewOrderLineItemList, Map<id,Order_Line_Item__c> oldOrderLineItemMap){ 
        Id recordTypeId = Schema.SObjectType.Order_Line_Item__c.getRecordTypeInfosByName().get('Parts Order Line Item').getRecordTypeId();
        Set<id> allOLIId= new Set<id>();
        for( Order_Line_Item__c olc: NewOrderLineItemList){
            if(olc.RecordTypeId==recordTypeId){
                if(olc.Product__c!=oldOrderLineItemMap.get(olc.id).Product__c){
                //oliList.add(olc);
                allOLIId.add(olc.id);
                }
            }
        } if(!allOLIId.isEmpty()){
             if(!system.isFuture()){
             getPricingitem(allOLIId) ;
             }
        }
    }
     @future(callout=true)
    public static void getPricingitem(set<id> oliId){
        List<Order_Line_Item__c> updateOLIList=new List<Order_Line_Item__c>();
        for(id recordId:oliId){
        Order_Line_Item__c oli = new Order_Line_Item__c ();
            oli=HRCSVC21_Get_Pricing.requestPricingitem(recordId,false);
            if(oli!=null){
                updateOLIList.add(oli);
            }
            system.debug('updateOLIList>>>'+updateOLIList);
        } if(!updateOLIList.isEmpty()){
            database.update(updateOLIList);
        }
    }
    @InvocableMethod(label='Get OLI IDs' description='Returns the list of OLI' category='Order_Line_Item__c')
    public static List<String> getPricing(List<List<String>>oliId) {
         List<String> message=new List<String>();
        try{
        List<String> ids =oliId[0];
        system.debug('Size of id????'+ids.size());
            
        String strLimitOnOLIsToSelect = Label.HRCSVC21_Max_Order_Line_Count_for_selection;
        Integer iLimit = strLimitOnOLIsToSelect == '' ? 50 : Integer.valueOf(strLimitOnOLIsToSelect);
            
        if(ids.size()==1){
              message.add('Please select at least one record');
        }
       else if(ids.size()> iLimit){
              message.add('Please select 50 or less records!');
       }
        else{
              message.add(HRCSVC21_Get_Pricing.passingIds(ids));
            system.debug('???????&&&&&');
        }
        }catch(Exception e){
           
           system.debug('e '+e.getStackTraceString());
             message.add('error???');
                   
        }
       
        return message;
    }    
}