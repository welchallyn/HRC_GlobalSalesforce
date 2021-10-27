/**************************************************************************************************************************
* Name                             :  HRCSVC_CreateOrderAndOrderLineItem
* Author                           :  Anchal Garg 
* Date                             :  November/04/20200
* Requirement/Project Name         :  Hill-Rom
* Requirement/Project Description  :  Controller class for HRCSVC_CreateOrderAndOrderLineItem Aura component.
*                                   1. HF-114 : to check if the order record entered by user is there in the system already.
*                                   2. HF-940 : 
*                                   3. HF-310 : 
* Revison                          :
/***************************************************************************************************************************/
public with sharing class HRCSVC_CreateOrderAndOrderLineItem {
    
    /*****************************************************************************************************************
* Method Name: FetchRentalOrder
* Author: Capgemini
* Date: 05 -JAN-2021
* Params: Order_Line_Item__c , String , String
* Return: boolean
* Requirement :SE-941 :  to get the customer rental
******************************************************************************************************************/
    @AuraEnabled 
    public static boolean FetchRentalOrder(Order_Line_Item__c oli,String OrderShipto,string OrderSoldto){
        //  ‘Customer Rental’ records where Location = OrderLineItem.Order.ShipToLocation AND Product = OrderLineItem.Product
        string productid=oli.Product__c;
        boolean RentalOrderFound=false;
        list<HRCSVC_Customer_Rental__c> cusRentalLst = new list<HRCSVC_Customer_Rental__c>();
        cusRentalLst = [select id from HRCSVC_Customer_Rental__c where HRCSVC_Location__c=:OrderShipto and HRCSVC_Product__c=:productid];
        RentalOrderFound = cusRentalLst.isEmpty() ? false : true;
        return RentalOrderFound;
    }
    
    /*****************************************************************************************************************
* Method Name: FetchOLIStandingPO
* Author: Capgemini
* Date: 30 -Dec-2020
* Params: Order_Line_Item__c , String , String,Sobject
* Return: String
* Requirement :SE-916 :  to get the standing PO rule based on ship to and Sold to account
******************************************************************************************************************/
    @AuraEnabled 
    public static string FetchOLIStandingPO(Order_Line_Item__c oli,String OrderShipto,string OrderSoldto,Sobject selectedRecord){
        string POnumber='';
        string proditemclass='';
        system.debug('the Order line item is'+oli);
        system.debug('the product is '+oli.product__c);
        system.debug('the OrderShipto is'+OrderShipto);
        system.debug('the OrderSoldto is'+OrderSoldto);
        list<Product2> prodlst=new list<Product2>();
        list<HRCSVC_Standing_PO_Rule__c> standingPoRuleReclst=new list<HRCSVC_Standing_PO_Rule__c>();
        prodlst=[select Id,Item_Class__c from product2 where id=:oli.Product__c limit 1];
        list<Account> acclst=new list<Account>();
        if(orderSoldTo!=null || orderSoldTo!=''){
            acclst=[select id,JDE_External_ID__c from account where id=:OrderSoldto limit 1];
        }
        if(prodlst.size()>0){
            proditemclass=prodlst[0].Item_Class__c;
        }      
        standingPoRuleReclst=[SELECT HRCSVC_Standing_PO__r.Name,HRCSVC_Agreement_Number__c,HRCSVC_Item_Class__c,HRCSVC_Product__c,HRCSVC_Standing_PO__c,HRCSVC_Valid_From__c,
                              HRCSVC_Valid_To__c,HRCSVC_Ward_Text__c,HRCSVC_Ward__c,Id,Name 
                              FROM HRCSVC_Standing_PO_Rule__c
                              WHERE HRCSVC_Valid_From__c <= Today AND HRCSVC_Valid_To__c >= Today and 
                              HRCSVC_Standing_PO__r.HRCSVC_Location__c=:OrderShipto and 
                              (HRCSVC_Agreement_Number__c<>null OR HRCSVC_Product__c=:oli.Product__c or HRCSVC_Item_Class__c=:proditemclass
                               OR HRCSVC_Ward__c=:oli.HRCSVC_Ward__c OR HRCSVC_Ward_Text__c=:oli.HRCSVC_Ward_Floor__c)                                                             
                              ORDER BY LastModifiedDate Desc LIMIT 1];
        
        if(standingPoRuleReclst.size()>0){
            POnumber=standingPoRuleReclst[0].HRCSVC_Standing_PO__r.Name;
        }else if(acclst.size()>0 ){
            standingPoRuleReclst=[SELECT HRCSVC_Standing_PO__r.Name,HRCSVC_Agreement_Number__c,HRCSVC_Item_Class__c,HRCSVC_Product__c,HRCSVC_Standing_PO__c,HRCSVC_Valid_From__c,
                                  HRCSVC_Valid_To__c,HRCSVC_Ward_Text__c,HRCSVC_Ward__c,Id,Name 
                                  FROM HRCSVC_Standing_PO_Rule__c
                                  WHERE HRCSVC_Valid_From__c <= Today AND HRCSVC_Valid_To__c >= Today and 
                                  HRCSVC_Standing_PO__r.HRCSVC_Location__r.HRCFSL_Customer_ID__c=:acclst[0].JDE_External_ID__c and 
                                  (HRCSVC_Agreement_Number__c<>null OR HRCSVC_Product__c=:oli.Product__c or HRCSVC_Item_Class__c=:proditemclass
                                   OR HRCSVC_Ward__c=:oli.HRCSVC_Ward__c OR HRCSVC_Ward_Text__c=:oli.HRCSVC_Ward_Floor__c)                                                             
                                  ORDER BY LastModifiedDate Desc LIMIT 1]; 
            if(standingPoRuleReclst.size()>0){
                POnumber=standingPoRuleReclst[0].HRCSVC_Standing_PO__r.Name;
            }                  
        }
        
        return POnumber;
    }        
    /*****************************************************************************************************************
* Method Name: checkDupOrderRecord
* Author: Capgemini
* Date: 04-Nov-2020
* Params: OrderRequestWrapper
* Return: OrderRequestWrapper
* Requirement :SE-114 :  to check if the order record entered by user is there in the system already.
******************************************************************************************************************/
    @AuraEnabled 
    public static OrderRequestWrapper checkDupOrderRecord(List<Order_Line_Item__c> oliRecList,Order__c orderRecord){
        System.debug(orderRecord.Id);
        OrderRequestWrapper oReqData = new OrderRequestWrapper();
        if(orderRecord.Id == null){           
            try{
            oReqData.ordRec = orderRecord;
            oReqData.oliRecList = oliRecList;
            
            Map<Id,Order__c> existingOrderRecmap = new map<Id,Order__c>();
            list<Order__c> existingOrderReclst=new list<order__c>();
            List<Order_Line_Item__c> existingoliRecList = new List<Order_Line_Item__c>(); 
            set<string> wardset = new set<string>();
            set<String> patientRoomnoSet = new set<string>();
            set<string> productset = new set<string>();
            list<HRCFSL_Organization_Settings__mdt> orgMetadatalist = new list<HRCFSL_Organization_Settings__mdt>();
            
            orgMetadatalist = [select id,developername,HRCFSL_Component_Detail__c from  HRCFSL_Organization_Settings__mdt
                               where DeveloperName = 'Duplicate_Order_Error_Message' limit 1]; 
            existingOrderRecmap = new Map<ID, Order__c>([select id,HRCSVC_Patient_First_Name__c,Name,HRCSVC_Patient_Last_Name__c,HRCSVC_Medical_Record_ID__c,
                                                         HRCSVC_Ship_To_Location__r.Name,Sold_To__r.Name from Order__c
                                                         where (HRCSVC_Patient_Last_Name__c =: oReqData.ordRec.HRCSVC_Patient_Last_Name__c or
                                                                HRCSVC_Medical_Record_ID__c =: oReqData.ordRec.HRCSVC_Medical_Record_ID__c )
                                                         and HRCSVC_Order_Type__c='Rental Order']);
            existingOrderReclst = existingOrderRecmap.values();
            for(Order_Line_Item__c oli : oReqData.oliRecList){
                if(oli.HRCSVC_Ward__c != null){
                    wardset.add(oli.HRCSVC_Ward__c);
                }
                if(oli.HRCSVC_Patient_Room__c != null){
                    patientRoomnoSet.add(oli.HRCSVC_Patient_Room__c);
                }
                if(oli.product__c != null){
                    productset.add(oli.product__c);
                }
            } 
            if(existingOrderReclst.size()>0){
                //11-02-2021 Commenting out the next three lines of code. as per the commetns on SE - 1538, we have to change the billing off date condition ((HRCSVC_End_Date__c != null) ---> (and HRCSVC_End_Date__c !== null))
                // existingoliRecList = [select id,HRCSVC_Ward__c,HRCSVC_Patient_Room__c,product__c,Order__c from Order_Line_Item__c 
                //                       where (HRCSVC_Ward__c in : wardset or HRCSVC_Patient_Room__c in : patientRoomnoSet) 
                //                       and (product__c in : productset and Order__c IN : existingOrderRecmap.keyset()) and HRCSVC_End_Date__c != null];
                
                //11-02-2021 the same code that was before making changes to the HRCSVC_End_Date__c != null condition on OLI 
                existingoliRecList = [select id,HRCSVC_Ward__c,HRCSVC_Patient_Room__c,product__c,Order__c from Order_Line_Item__c 
                                      where (HRCSVC_Ward__c in : wardset or HRCSVC_Patient_Room__c in : patientRoomnoSet) 
                                      and (product__c in : productset and Order__c IN : existingOrderRecmap.keyset()) and HRCSVC_End_Date__c = null];
                if(existingoliRecList.size() > 0){
                    oReqData.DupOrderErrormsg = orgMetadatalist.size() > 0 ? orgMetadatalist[0].HRCFSL_Component_Detail__c 
                        :' A duplicate order has been found. Are you sure you want to book a new order ? ';
                    Order__c ord = new Order__c();
                    ord = existingOrderRecmap.get(existingoliRecList[0].Order__c);
                    oReqData.DupOrderErrormsg += ' Details of the existing order : ';
                    oReqData.DupOrderErrormsg += ' Order Number : '+ord.Name + '\nShip To: '+ord.HRCSVC_Ship_To_Location__r.Name + 
                        '\nSold To: '+ord.Sold_To__r.Name+'\nPatient First Name: '+ ord.HRCSVC_Patient_First_Name__c +
                        '\nPatient Last Name: '+ord.HRCSVC_Patient_Last_Name__c + '\nMedical Record ID: '+ord.HRCSVC_Medical_Record_ID__c;
                }else {
                    oReqData.DupOrderErrormsg = ''; 
                }
            }else{
                oReqData.DupOrderErrormsg = '';
            }
            return oReqData;
            }catch(DmlException e){
            //throw all other exception message
            throw new AuraHandledException(e.getDmlMessage(0));
            }
        }
        else{
            oReqData.ordRec = orderRecord;
            oReqData.oliRecList = oliRecList;
            oReqData.DupOrderErrormsg = '';
            return oReqData;
        }
    }
    
    // wrapper class with @AuraEnabled
    public class OrderRequestWrapper{
        @AuraEnabled 
        public Order__c ordRec;
        @AuraEnabled 
        public sObject soldTo = new Account();
        @AuraEnabled 
        public sObject shipTo = new Schema.Location();
        @AuraEnabled 
        public List<Order_Line_Item__c> oliRecList;  // need to check if we need to use standard object
        @AuraEnabled 
        public  Additional_Account_Info__c addAccRec;
        @AuraEnabled 
        public String DupOrderErrormsg;
        @AuraEnabled
        public List < sObject > returnList;
        //Constructor
        public OrderRequestWrapper OrderRequestWrapper(){
            OrderRequestWrapper orw = new OrderRequestWrapper();
            orw.ordRec = new Order__c();
            orw.oliRecList = new List<Order_Line_Item__c>();
            orw.addAccRec = new Additional_Account_Info__c();
            orw.DupOrderErrormsg='';
            orw.returnList = new List < sObject >();
            return orw;
        }
    }
    /*
@AuraEnabled 
public static List<Additional_Account_Info__c> findAdditionalRecordInfo(SObject accountRecord){
Account protocol = (Account) accountRecord;
return [select HRCSVC_Account_Protocol__c from Additional_Account_Info__c where HRCSVC_Protocol_Category__c = 'Rental' and Account__r.ID =: protocol.ID limit 1];
}
*/
    
    /** this is a helper method to call the HRVCSVC_SLA_Management class to retrieve the due date for a particular Order Line Item
* this is built as part of SE-1195 where we need to calculate the due date for an order line item that is entered.
* it is called whenever a product is selected or unselected on an order line item in the component.
* 
*/ 
    @AuraEnabled
    public static DateTime getDueDate(Order_Line_Item__c oli, Order__c order)
    {
        //if no product, this means the product has been deselected and hence the value should revert to null
        if (oli.Product__c == null)
            return null;
        return HRCSVC_SLA_Management.getDueDate(oli, order);
        //return null;
    }
    @AuraEnabled 
    public static List<Additional_Account_Info__c> findAdditionalRecordInfo(SObject locationRecord){
        Id idval=(Id)locationRecord.get('ID');
        Sobject obj=[SELECT Id, HRCFSL_Account__c FROM Location where Id=:idval limit 1];
        idval=(Id)obj.get('HRCFSL_Account__c');
        List<Additional_Account_Info__c> obj2 = [select HRCSVC_Account_Protocol__c from Additional_Account_Info__c where HRCSVC_Protocol_Category__c = 'Rental' and Account__r.ID =: idval limit 1];
        return obj2;
    }
    
    /** helper method that returns the jde category code 39 given a product's id
* this is developed as part of se-1188 which includes logic that prepopulates certain attributes on a new order line item in the case of a substitution
*/ 
    @AuraEnabled
    public static string getSubstitutionCode(String productId)
    {
        if (productId == null || productId.length() == 0)
            return null;
        Product2 product = [select id, hrcsvc_jde_category_code_39__c from product2 where id =: productId];
        return product.hrcsvc_jde_category_code_39__c;
    }
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName,String filterCondition,String selectedShiptoId) {
        String searchKey = searchKeyWord + '%';
        string servterritoryid='';
        schema.location locationRecord;
        OrderRequestWrapper wrapper = new OrderRequestWrapper();
        wrapper.returnList = new List < sObject >();
        string sQuery='';
        
        
        if(ObjectName.equalsIgnorecase('Product2')){  
            sQuery =  'select id, Name,HRCFSL_Parts_Number__c from ' + ObjectName ;   
            sQuery+=' where ( Name LIKE: searchKey or HRCFSL_Parts_Number__c like : searchKey ) ';       
            if(selectedShiptoId!='' && selectedShiptoId!=null){
                locationRecord = [select id,HRCFSL_Service_Territory__c from location where id=:selectedShiptoId limit 1];
                servterritoryid = locationRecord.HRCFSL_Service_Territory__c;
                servterritoryid = (servterritoryid == null || servterritoryid=='') ? '' : servterritoryid;
            }
            if(filterCondition!=null && filterCondition!='' && selectedShiptoId!=null && selectedShiptoId!=''){
                //HRCSVC_Rental_Offering__c = true AND id not in (select hrcsvc_product__c from hrcsvc_service_territory_product_unavailability__c where hrcsvc_service_territory__c = [ST ID])
                filterCondition = filterCondition.replace('[ST ID]', ': servterritoryid');
                sQuery+='and '+filterCondition;
            }
        }
        else{
            sQuery =  'select id, Name from ' + ObjectName +' where Name LIKE: searchKey ' ;
        }    
        squery+=' order by createdDate DESC limit 5';
        system.debug(sQuery );
        List < sObject > lstOfRecords = Database.query(sQuery);
        for (sObject obj : lstOfRecords) {
            wrapper.returnList.add(obj);
        }
        return wrapper.returnList;
    }  
    /*  @AuraEnabled
public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName) {
String searchKey = searchKeyWord + '%';
OrderRequestWrapper wrapper = new OrderRequestWrapper();
wrapper.returnList = new List < sObject >();
String sQuery =  'select id, Name from ' + ObjectName + ' where Name LIKE: searchKey order by createdDate DESC limit 5';
system.debug(sQuery );
List < sObject > lstOfRecords = Database.query(sQuery);
for (sObject obj : lstOfRecords) {
wrapper.returnList.add(obj);
}
return wrapper.returnList;
}*/
    @AuraEnabled 
    public static String saveOrderandOLIRecord(List<Order_Line_Item__c> oliRecList,Order__c orderRecord,SObject selectedShipTo,SObject selectedSoldTo,SObject selectedContact){
        //orderRecord.Name = 'Test Order Record';
        try{
            string standingPO='';
            string POnum='';
            if(selectedSoldTo != null && selectedSoldTo.get('Id') != null){
                orderRecord.Sold_To__c = (Id) selectedSoldTo.get('Id');
            }
            if(selectedShipTo != null && selectedShipTo.get('Id') != null){
                orderRecord.HRCSVC_Ship_To_Location__c = (Id) selectedShipTo.get('Id');
            }
            if(selectedContact != null && selectedContact.get('Id') != null){
                orderRecord.HRCSVC_Contact__c = (Id) selectedContact.get('Id');
            }
            //orderRecord.HRCSVC_Order_Type__c = 'Rental Order';
            orderRecord.Recordtypeid = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Rental Order').getRecordTypeId();
            orderRecord.HRCSVC_Status__c = 'Requested Rental';
            if(String.isEmpty(orderRecord.Id)){
                insert orderRecord;
            }
            system.debug('oliRecList '+oliRecList);
            List<Order_Line_Item__c> insertOLI = new List<Order_Line_Item__c>();
            
            for(Order_Line_Item__c newOLI : oliRecList){
                if(String.isEmpty(newOLI.Id)){
                    //newOLI.Name = 'TEST ORDER LINE ITEM';
                    newOLI.Order__c = orderRecord.ID;
                    newOLI.HRCSVC_Contact_Name__c = newOLI.HRCSVC_Contact_Name__c;
                    // to disable the component from being edit
                    newOLI.Product__c = newOLI.Product__c;
                    newOLI.Recordtypeid = Schema.SObjectType.Order_Line_Item__c.getRecordTypeInfosByName().get('Rental Order Line Item').getRecordTypeId();
                }
                if(!String.isEmpty(newOLI.Id)){
                    newOLI.HRCSVC_Disable_Component_Edit__c = true;
                }
                system.debug('standing po is'+newOLI.HRCSVC_Standing_PO__c);
                system.debug(' po is'+newOLI.HRCSVC_PO_Number__c);
                standingPO = newOLI.HRCSVC_Standing_PO__c==null ? '' :string.valueOf(newOLI.HRCSVC_Standing_PO__c);
                POnum = newOLI.HRCSVC_PO_Number__c==null ? '' :string.valueOf(newOLI.HRCSVC_PO_Number__c);
                                /* if(!standingPO.equals(POnum) && POnum!='' && POnum!=null){
                System.debug('standing PO will be overridden');
                newOLI.HRCSVC_Standing_PO__c = newOLI.HRCSVC_PO_Number__c;
                }*/
                insertOLI.add(newOLI);
            }
            if(!insertOLI.isEmpty()){
                upsert insertOLI;
            }
            if(orderRecord != null && orderRecord.Id != null){
                return orderRecord.ID;
            }
        }catch(Exception e){
            system.debug(e);
            //throw all other exception message
            throw new AuraHandledException(e.getDmlMessage(0));
        }
        return null;
    }
    @AuraEnabled        
    public static Map<String, String> getPickListValuesIntoList(String selectedField,String objectName){
        if(String.isEmpty(ObjectName) || String.isEmpty(selectedField)){
            return null;
        }
        HRCFSL_Organization_Settings__mdt woSQActivityType = [Select HRCFSL_Component_Detail__c from HRCFSL_Organization_Settings__mdt where developerName='HRCSVC_WO_SQ_Activity_Type'];       
        
        Map<String, String> options = new Map<String, String>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(ObjectName);
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(selectedField).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            if(selectedField.equalsIgnoreCase('HRCSVC_Service_Activity_Type__c')){
                if((woSQActivityType.HRCFSL_Component_Detail__c).contains(pickListVal.getValue())){
                    options.put(pickListVal.getValue(), pickListVal.getLabel());
                }
            }else{
                options.put(pickListVal.getValue(), pickListVal.getLabel());
            }
            
        }     
        return options;
    }
    @AuraEnabled        
    public static Account checkCustomerEligibility(SObject selectedShipTo){
        if(selectedShipTo != null){
            Id locationId = (ID)selectedShipTo.get('Id');
            Schema.Location loc = [select HRCFSL_Account__c from location where id =: locationId];
            Id accountId;
            if(loc.HRCFSL_Account__c != null){
                accountId = loc.HRCFSL_Account__c;
                return [select HRCSVC_Customer_Type__c,Billing_Type__c,HRCSVC_Credit_Type__c from Account where Id =: accountId];
            }
            return null;
        }
        return null;
    }
    
    @AuraEnabled
    public static sobject getRecordById(String Id)
    {
        Id recordId = id;
        String objectAPIName = recordId.getSObjectType().getDescribe().getName();
        String query = 'select id, name from ' + objectAPIName + ' where id =\'' + id + '\' limit 1';
        return database.query(query);
    }
    @AuraEnabled
    public static OrderRequestWrapper getOrderAndOrderLineItems(Id orderRecordId){
        List<Additional_Account_Info__c> additionalInfo = new list<Additional_Account_Info__c>();
        location loc = new location();
        OrderRequestWrapper oReqData = new OrderRequestWrapper();
        oReqData.ordRec = [select Name,Sold_To__r.Name,HRCSVC_Ship_To_Location__c,HRCSVC_Ship_To_Location__r.HRCFSL_Account__r.name,HRCSVC_Ship_To_Location__r.HRCFSL_Account__c,HRCSVC_Ship_To_Location__r.Name,HRCSVC_Contact__c,HRCSVC_Status__c,HRCSVC_Patient_First_Name__c,HRCSVC_Patient_Last_Name__c,HRCSVC_Medical_Record_ID__c
                           from Order__c where Id =: orderRecordId];
        oReqData.oliRecList = [select Name,HRCSVC_Standing_PO__c,HRCSVC_Order_Line_Item_Status__c,HRCSVC_Disable_Component_Edit__c,HRCSVC_Contact_Name__c,HRCSVC_Service_Activity_Type__c,Quantity__c,HRCSVC_Serial_Number__c,HRCSVC_Start_Date__c,
                               HRCSVC_End_Date__c,HRCSVC_Equipment_On_Date__c,HRCSVC_Equipment_OFF_Date__c,HRCSVC_Patient_Room__c,HRCSVC_Ward__c,HRCSVC_Ward__r.Name,HRCSVC_Ward_Floor__c,Product__c,HRCSVC_Price_Method_Code__c,HRCSVC_PO_Number__c,HRCSVC_Paging_Team__c,
                               HRCSVC_Contact_Method__c,HRCSVC_Cancellation_Reason_Notes__c, HRCSVC_Contact_Name__r.FirstName, HRCSVC_Contact_Name__r.LastName
                               ,HRCSVC_PO_Expiration_Date__c,HRCSVC_Customer_Cost_Center__c,Cancel_Change_Reason_Code__c,HRCSVC_Cancelation_Approver__c,HRCSVC_Special_Instructions__c,
                               HRCSVC_Customer_Request_Date_Time__c,HRCSVC_Asset__c,HRCSVC_Default_Request_Date_and_Time__c, Order__c, Order__r.HRCSVC_Ship_To_Location__c,Order__r.HRCSVC_Medical_Record_ID__c ,Order__r.HRCSVC_Patient_First_Name__c, Order__r.HRCSVC_Patient_Last_Name__c
                               from Order_Line_Item__c where Order__c =: orderRecordId Order By HRCSVC_Start_Date__c DESC];
        Account accountProtocol = new Account();
                    /* if(oReqData.ordRec.Sold_To__c != null){
            accountProtocol.Id =  oReqData.ordRec.Sold_To__r.Id;
            accountProtocol.Name =  oReqData.ordRec.Sold_To__r.Name;
            oReqData.soldTo.put('Id',oReqData.ordRec.Sold_To__r.Id);
            oReqData.soldTo.put('Name',oReqData.ordRec.Sold_To__r.Name);
            }*/
        if(oReqData.ordRec.Sold_To__c!=null){
            oReqData.soldTo.put('Id',oReqData.ordRec.Sold_To__r.Id);
            oReqData.soldTo.put('Name',oReqData.ordRec.Sold_To__r.Name);
        }
        if(oReqData.ordRec.HRCSVC_Ship_To_Location__c != null){
            accountProtocol.Id =  oReqData.ordRec.HRCSVC_Ship_To_Location__r.HRCFSL_Account__c;
            accountProtocol.Name =  oReqData.ordRec.HRCSVC_Ship_To_Location__r.HRCFSL_Account__r.name;
            oReqData.shipTo.put('Id',oReqData.ordRec.HRCSVC_Ship_To_Location__r.Id);
            oReqData.shipTo.put('Name',oReqData.ordRec.HRCSVC_Ship_To_Location__r.Name);
            
            // List<Additional_Account_Info__c> additionalInfo = findAdditionalRecordInfo(accountProtocol);
            Sobject locc;
            locc=[SELECT ID, HRCFSL_Account__c FROM Location where id=:oReqData.ordRec.HRCSVC_Ship_To_Location__c limit 1];
            //loc=loclst[0];
            additionalInfo= findAdditionalRecordInfo(locc);
            if(!additionalInfo.isEmpty()){
                oReqData.addAccRec = additionalInfo[0];
            }
        }
        return oReqData;
    }
    @AuraEnabled
    public static string setDefaultTeamType(){
        system.debug(UserInfo.getLocale());
        return UserInfo.getLocale();
    }
    
    @AuraEnabled
    public static Order_Line_Item__c[] parseOrderLineItemId(String[] parseThisId){
        Order_Line_Item__c[] orderLineItem = new Order_Line_Item__c[]{};
            String[] organizedId = new String[]{};
                String orderId;
        System.debug(parseThisId.get(0));
        if(parseThisId.get(0).contains(',')){
            orderId = parseThisId.get(0).remove('[').remove(']').remove(' ');
            System.debug('organizedId in split'+orderId);
            List<id> orderIdList= orderId.split(',');
            String queryOrderLineItem = 'SELECT id,HRCSVC_Standing_PO__c, HRCSVC_Contact_Name__c, HRCSVC_Service_Activity_Type__c, Quantity__c, HRCSVC_Serial_Number__c, HRCSVC_Start_Date__c, HRCSVC_End_Date__c, HRCSVC_Equipment_On_Date__c, '+
                'HRCSVC_Equipment_OFF_Date__c, HRCSVC_Patient_Room__c, HRCSVC_Ward__c, Product__c, HRCSVC_Price_Method_Code__c, HRCSVC_PO_Number__c, HRCSVC_Paging_Team__c, HRCSVC_Contact_Method__c, '+
                'HRCSVC_Cancellation_Reason_Notes__c, HRCSVC_PO_Expiration_Date__c, HRCSVC_Customer_Cost_Center__c, Cancel_Change_Reason_Code__c, HRCSVC_Cancelation_Approver__c, HRCSVC_Special_Instructions__c, '+
                'HRCSVC_Customer_Request_Date_Time__c, HRCSVC_Asset__c,HRCSVC_Default_Request_Date_and_Time__c '+
                'FROM Order_Line_Item__c WHERE id = \''+orderIdList.get(0)+'\'';
            orderIdList.remove(0);
            for(Id oID :orderIdList){
                queryOrderLineItem += 'OR id = \''+oID+'\'';
            }
            orderLineItem = Database.query(queryOrderLineItem);
        } else {
            orderId = (Id)parseThisId.get(0).remove('[').remove(']');
            System.debug('organizedId'+orderId);
            orderLineItem = Database.query('SELECT id,HRCSVC_Standing_PO__c,HRCSVC_Contact_Name__c, HRCSVC_Service_Activity_Type__c, Quantity__c, HRCSVC_Serial_Number__c, HRCSVC_Start_Date__c, HRCSVC_End_Date__c, HRCSVC_Equipment_On_Date__c, '+
                                           'HRCSVC_Equipment_OFF_Date__c, HRCSVC_Patient_Room__c, HRCSVC_Ward__c, Product__c, HRCSVC_Price_Method_Code__c, HRCSVC_PO_Number__c, HRCSVC_Paging_Team__c, HRCSVC_Contact_Method__c, '+
                                           'HRCSVC_Cancellation_Reason_Notes__c, HRCSVC_PO_Expiration_Date__c, HRCSVC_Customer_Cost_Center__c, Cancel_Change_Reason_Code__c, HRCSVC_Cancelation_Approver__c, HRCSVC_Special_Instructions__c, '+
                                           'HRCSVC_Customer_Request_Date_Time__c, HRCSVC_Asset__c,HRCSVC_Default_Request_Date_and_Time__c '+
                                           'FROM Order_Line_Item__c WHERE id = \''+orderId+'\'');
        }
        System.debug('organizedId'+organizedId);
        System.debug(orderLineItem);
        return orderLineItem;
    }
    //SE-1008
    public static void createWOfromOLI(List<Order_Line_Item__c> oliRecList){
        List<WorkOrder> worecord = [Select Id,AssetId,WorkTypeId,HRCFSL_Doc_Type__c,HRCFSL_Activity_Type__c,HRCFSL_Paging_Team__c,LocationId,CreatedDate,HRCFSL_Work_Type_Name__c,HRCSVC_Order_Line_Item__r.HRCSVC_Ward_Floor__c from WorkOrder where HRCSVC_Order_Line_Item__c =:oliRecList AND HRCFSL_Work_Type_Name__c ='SQY' order by CreatedDate DESC Limit 1 ];
        //Query on oli
        List<WorkOrder> insertList = new List<WorkOrder>();
        for(Order_Line_Item__c oli :oliRecList){
            //for(WorkOrder wo :worecord){
            WorkOrder woOrd = new WorkOrder();
            woOrd.HRCFSL_Doc_Type__c = 'SQ';
            woOrd.HRCFSL_Activity_Type__c = 'Z';
            woOrd.HRCSVC_Order_Line_Item__c = oli.Id;
            woOrd.LocationId = oli.Order__r.HRCSVC_Ship_To_Location__r.HRCFSL_Service_Territory__c;
            woOrd.Status = 'SA';
            woOrd.StartDate = System.now();
            woOrd.HRCFSL_Ward_Text__c = oli.HRCSVC_Ward_Floor__c;
            woOrd.HRCFSL_Ward__c = oli.HRCSVC_Ward__c;
            woOrd.HRCFSL_JDE_Cost_Center__c = oli.HRCSVC_Customer_Cost_Center__c;
            woOrd.HRCFSL_PO__c = oli.HRCSVC_PO_Number__c;
            woOrd.HRCSV_Product__c = oli.HRCSVC_Product_Name__c;
            woOrd.AssetId = oli.HRCSVC_Asset__c;
            woOrd.HRCFSL_Extended_Instructions__c = oli.HRCSVC_Special_Instructions__c;
            woOrd.HRCFSL_Patient_on_date__c = oli.HRCSVC_Start_Date__c;
            woOrd.HRCFSL_Patient_Off_Date__c = oli.HRCSVC_End_Date__c;
            woOrd.HRCFSL_Contact_First_Name__c =oli.HRCSVC_Contact_Name__c;
            woOrd.HRCFSL_Contact_Last_Name__c = oli.HRCSVC_Contact_Name__c;
            //woOrd.HRCFSL_Contact_Department__c
            //woOrd.HRCFSL_Contact_Phone__c 
            //woOrd.HRCFSL_Contact_Email__c 
            //Actual Request Date (SLA calculated Date)
            //Actual Request Time (SLA calculated Time)
            //Service Activity Type 
            
            insertList.add(woOrd);
        }
        system.debug('insert List'+insertList);
        
        if(insertList.size()>0){
            insert insertList;
            system.debug(' afterinsert List'+insertList);
        }
        
    }
    @AuraEnabled
    public static void createWOByOLI(List<Order_Line_Item__c> oliRecList,String buttonType,List<WorkOrder> adminwos){
        List<WorkOrder> listofWOToInsert = new List<WorkOrder>();
        List<WorkOrder> listofSQYWO = new List<WorkOrder>();
        map<Id,WorkOrder> mapOfWOByOLIId = new map<Id,WorkOrder>();
        map<Id,Order_Line_Item__c> mapOfOLIByOLIId = new map<Id,Order_Line_Item__c>();
        map<Id,workorder> Woobjmap =new map<Id,workorder>();
        map<id,HRCSVC_Complaint_Qualification__c> WOComplainobjMap = new map<id,HRCSVC_Complaint_Qualification__c>();
        WorkOrder woRecord;
        //String docType;
        String activityType;
        Integer WOIndex=0;
        system.debug('buttonType '+buttonType);
        if(buttonType.equalsIgnoreCase('Admin Bed Move')){
            activityType = 'B';
        }
        system.debug('buttonType '+buttonType);
        if(buttonType.equalsIgnoreCase('Removal')){
            //docType = 'SQ';
            activityType = 'R';
            // activityType = 'Y';
        }
        else if(buttonType.equalsIgnoreCase('Non-Repair Swap')){
            activityType = '8'; 
        }
        else if(buttonType.equalsIgnoreCase('Sheet Change')){
            //docType = 'SQ';
            activityType = 'S';
        }
        else if (buttonType.equalsIgnoreCase('On-Site Repair')){
            //docType = 'SQ';
            activityType = 'Y';
        }else if(buttonType.equalsIgnoreCase('Repair Swap')){
            //docType = 'SQ';
            activityType = 'Z';
            // listofSQYWO = [Select Id,HRCFSL_PO__c,HRCFSL_Ward__c,HRCFSL_JDE_Cost_Center__c,HRCFSL_Ward_Text__c,HRCSVC_Order__c,AssetId,WorkTypeId,HRCFSL_Doc_Type__c,HRCFSL_Activity_Type__c,LocationId,CreatedDate,HRCFSL_Work_Type_Name__c,HRCSVC_Order_Line_Item__c,HRCSVC_Order_Line_Item__r.HRCSVC_Ward_Floor__c from WorkOrder where HRCSVC_Order_Line_Item__c =:oliRecList AND HRCFSL_Work_Type_Name__c ='SQY'and HRCSVC_Order_Line_Item__c != null order by CreatedDate DESC];
            Woobjmap = new Map<ID, WorkOrder>([select id,HRCFSL_Patient_Room__c,HRCFSL_Medical_Rec_No__c,HRCFSL_Doc_Type__c, HRCFSL_Activity_Type__c, HRCSVC_Order_Line_Item__c, HRCSVC_Order__c, LocationId, Status, HRCFSL_Ward_Text__c, HRCFSL_Ward__c, HRCFSL_JDE_Cost_Center__c, HRCFSL_PO__c, HRCSV_Product__c, AssetId, HRCFSL_Extended_Instructions__c, HRCFSL_Patient_on_date__c, HRCFSL_Patient_Off_Date__c, HRCFSL_Patient_First_Name__c, HRCFSL_Patient_Last_Name__c, ContactId, HRCFSL_Contact_First_Name__c, HRCFSL_Contact_Last_Name__c, 
                                               HRCFSL_Paging_Team__c   from WorkOrder where HRCSVC_Order_Line_Item__c =:oliRecList AND HRCFSL_Work_Type_Name__c ='SQY'and HRCSVC_Order_Line_Item__c != null order by CreatedDate DESC]);
            //HRCSVC_Related_Work_order_Id__c
            listofSQYWO= Woobjmap.values();           
           
            list<HRCSVC_Complaint_Qualification__c> complaintqualList= [SELECT HRCSVC_Account__c,HRCSVC_Asset__c, HRCSVC_Contact__c, HRCSVC_Second_Account__c,  HRC_Functioning_as_designed_post_repair__c, HRCSVC_Additional_Death_Questions__c, HRCSVC_Additional_Information__c,
                                                                        HRCSVC_Additional_Injury_Questions__c, HRCSVC_Additional_Malfunction_Questions__c, HRCSVC_Age__c,  HRCSVC_Aware_Date__c,
                                                                        HRCSVC_Case__c, HRCSVC_Cause_of_death_if_known__c, HRCSVC_Certification_Date__c,HRCSVC_Condition__c,HRCSVC_Date_of_the_Event__c,
                                                                        HRCSVC_Defined_Design_Life__c, HRCSVC_Delay_in_treatment_or_Procedure__c, HRCSVC_Describe_Malfunction_Event__c, HRCSVC_Design_Life_Exceeded__c,
                                                                        HRCSVC_Design_Life_Override_Justificatn__c, HRCSVC_Device_Age__c, HRCSVC_Device_Life_Override__c, HRCSVC_Device_Message_Alert__c, HRCSVC_Device_Used_On_With_Individual__c,
                                                                        HRCSVC_Document_troubleshooting__c, HRCSVC_ETQ_Complaint__c, HRCSVC_ETQ_Complaint_Number__c, HRCSVC_Existing_CQ_with_case__c, HRCSVC_Explain_if_No__c,
                                                                        HRCSVC_Gender__c, HRCSVC_Individual_s_Medical_Diagnosis__c, HRCSVC_Individual_s_Outcome__c, HRCSVC_Injury_or_Death__c, HRCSVC_Investigation_ID__c,
                                                                        HRCSVC_Last_Relevant_Date__c, HRCSVC_Medical_Treatment_or_Intervention__c, HRCSVC_Occurrence_Location__c, HRCSVC_Part_Serial_and_or_Revision__c,
                                                                        HRCSVC_Patient_Identifier__c, HRCSVC_PCMS_ID__c, HRCSVC_PM_sticker_date_if_present__c, HRCSVC_Problem__c, HRCSVC_Product_Feature_Component__c, HRCSVC_Product_Group__c, 
                                                                        HRCSVC_Product_Problem_Code__c, HRCSVC_Quantity__c,HRCSVC_Resolution__c, HRCSVC_Resolution_Complete__c, HRCSVC_Resolution_Status__c,
                                                                        HRCSVC_Return_Order_Line_Item__c,  HRCSVC_Second_device_relationship_Model__c, HRCSVC_Source_Of_Complaint__c, HRCSVC_Specific_Error_Message__c, 
                                                                        HRCSVC_Status__c,   HRCSVC_Test_performed_per_service_manual__c, HRCSVC_Upgrade_Date__c, HRCSVC_Weight__c,
                                                                        HRCSVC_What_was_the_Injury__c, HRCSVC_Work_Order__c, Name, CurrencyIsoCode
                                                                        FROM HRCSVC_Complaint_Qualification__c where HRCSVC_Work_Order__c in : Woobjmap.keyset()];
            
            for(HRCSVC_Complaint_Qualification__c cqual : complaintqualList){
                WOComplainobjMap.put(cqual.HRCSVC_Work_Order__c,cqual);
            }
            for(WorkOrder loopWO :  listofSQYWO){
                mapOfWOByOLIId.put(loopWO.HRCSVC_Order_Line_Item__c,loopWO);
            }
            /*  for(Order_Line_Item__c loopOLI : oliRecList){
mapOfOLIByOLIId.put(loopOLI.Id,loopOLI);
}*/
        }
        system.debug('oliRecList'+oliRecList);
        for(Order_Line_Item__c oli : oliRecList){
            woRecord = new WorkOrder();
            woRecord.HRCFSL_Doc_Type__c = 'SQ';
            woRecord.HRCFSL_Activity_Type__c = activityType; 
            woRecord.HRCSVC_Order_Line_Item__c = mapOfWOByOLIId.containskey(oli.Id) ? mapOfWOByOLIId.get(oli.Id).HRCSVC_Order_Line_Item__c : oli.Id;
            woRecord.HRCSVC_Order__c = mapOfWOByOLIId.containskey(oli.Id) ? mapOfWOByOLIId.get(oli.Id).HRCSVC_Order__c :oli.Order__c;
            woRecord.LocationId = mapOfWOByOLIId.containskey(oli.Id) ? mapOfWOByOLIId.get(oli.Id).LocationId : oli.Order__r.HRCSVC_Ship_To_Location__c;
            woRecord.Status = 'SA';
            woRecord.HRCFSL_Ward_Text__c = mapOfWOByOLIId.containskey(oli.Id) ? mapOfWOByOLIId.get(oli.Id).HRCFSL_Ward_Text__c :oli.HRCSVC_Ward_Floor__c;
            woRecord.HRCFSL_Ward__c = mapOfWOByOLIId.containskey(oli.Id) ? mapOfWOByOLIId.get(oli.Id).HRCFSL_Ward__c :oli.HRCSVC_Ward__c;
            woRecord.HRCFSL_JDE_Cost_Center__c = mapOfWOByOLIId.containskey(oli.Id) ? mapOfWOByOLIId.get(oli.Id).HRCFSL_JDE_Cost_Center__c :oli.HRCSVC_Customer_Cost_Center__c;
            woRecord.HRCFSL_PO__c = mapOfWOByOLIId.containskey(oli.Id) ? mapOfWOByOLIId.get(oli.Id).HRCFSL_PO__c :oli.HRCSVC_PO_Number__c;
            woRecord.HRCSV_Product__c = mapOfWOByOLIId.containskey(oli.Id) ? mapOfWOByOLIId.get(oli.Id).HRCSV_Product__c :oli.product__c;//oli.HRCSVC_Product_Name__c;
            woRecord.AssetId = mapOfWOByOLIId.containskey(oli.Id) ? mapOfWOByOLIId.get(oli.Id).AssetId :oli.HRCSVC_Asset__c;
            woRecord.HRCFSL_Paging_Team__c = mapOfWOByOLIId.containskey(oli.Id) ? mapOfWOByOLIId.get(oli.Id).HRCFSL_Paging_Team__c :oli.HRCSVC_Paging_Team__c;
            
            
            woRecord.HRCFSL_Extended_Instructions__c = mapOfWOByOLIId.containskey(oli.Id) ? mapOfWOByOLIId.get(oli.Id).HRCFSL_Extended_Instructions__c :oli.HRCSVC_WO_Extended_Instructions__c;
            
            if(buttonType.equalsIgnoreCase('Sheet Change')){
                woRecord.HRCFSL_Patient_on_date__c = mapOfWOByOLIId.containskey(oli.Id) ? mapOfWOByOLIId.get(oli.Id).HRCFSL_Patient_on_date__c :oli.HRCSVC_Start_Date__c;
                woRecord.HRCFSL_Patient_Off_Date__c = mapOfWOByOLIId.containskey(oli.Id) ? mapOfWOByOLIId.get(oli.Id).HRCFSL_Patient_Off_Date__c :oli.HRCSVC_End_Date__c;
                woRecord.HRCFSL_Patient_First_Name__c = mapOfWOByOLIId.containskey(oli.Id) ? mapOfWOByOLIId.get(oli.Id).HRCFSL_Patient_First_Name__c :oli.Order__r.HRCSVC_Patient_First_Name__c;
                woRecord.HRCFSL_Patient_Last_Name__c = mapOfWOByOLIId.containskey(oli.Id) ? mapOfWOByOLIId.get(oli.Id).HRCFSL_Patient_Last_Name__c :oli.Order__r.HRCSVC_Patient_Last_Name__c;
                woRecord.HRCFSL_Patient_Room__c = mapOfWOByOLIId.containskey(oli.Id) ? mapOfWOByOLIId.get(oli.Id).HRCFSL_Patient_Room__c :oli.HRCSVC_Patient_Room__c;
                
            } 
            
            if(buttonType.equalsIgnoreCase('Removal')){
                woRecord.HRCFSL_Patient_on_date__c = mapOfWOByOLIId.containskey(oli.Id) ? mapOfWOByOLIId.get(oli.Id).HRCFSL_Patient_on_date__c :oli.HRCSVC_Start_Date__c;
                woRecord.HRCFSL_Patient_Off_Date__c = mapOfWOByOLIId.containskey(oli.Id) ? mapOfWOByOLIId.get(oli.Id).HRCFSL_Patient_Off_Date__c :oli.HRCSVC_End_Date__c;
                woRecord.HRCFSL_Patient_First_Name__c = mapOfWOByOLIId.containskey(oli.Id) ? mapOfWOByOLIId.get(oli.Id).HRCFSL_Patient_First_Name__c :oli.Order__r.HRCSVC_Patient_First_Name__c;
                woRecord.HRCFSL_Patient_Last_Name__c = mapOfWOByOLIId.containskey(oli.Id) ? mapOfWOByOLIId.get(oli.Id).HRCFSL_Patient_Last_Name__c :oli.Order__r.HRCSVC_Patient_Last_Name__c;
                woRecord.HRCFSL_Patient_Room__c = mapOfWOByOLIId.containskey(oli.Id) ? mapOfWOByOLIId.get(oli.Id).HRCFSL_Patient_Room__c :oli.HRCSVC_Patient_Room__c;
                
            } 
            
            if(buttonType.equalsIgnoreCase('Admin Bed Move')){
                woRecord.HRCFSL_Actual_End__c=adminwos[WOIndex].HRCFSL_Actual_End__c;
                woRecord.HRCFSL_Actual_Start__c=adminwos[WOIndex].HRCFSL_Actual_Start__c;
                woRecord.assetid=adminwos[WOIndex].assetid;
                woRecord.HRCSVC_Admin_Completed__c = true;
                woRecord.Status='SC';
                WOIndex++;
                
                woRecord.HRCFSL_Patient_on_date__c = mapOfWOByOLIId.containskey(oli.Id) ? mapOfWOByOLIId.get(oli.Id).HRCFSL_Patient_on_date__c :oli.HRCSVC_Start_Date__c;
                woRecord.HRCFSL_Patient_Off_Date__c = mapOfWOByOLIId.containskey(oli.Id) ? mapOfWOByOLIId.get(oli.Id).HRCFSL_Patient_Off_Date__c :oli.HRCSVC_End_Date__c;
                woRecord.HRCFSL_Patient_First_Name__c = mapOfWOByOLIId.containskey(oli.Id) ? mapOfWOByOLIId.get(oli.Id).HRCFSL_Patient_First_Name__c :oli.Order__r.HRCSVC_Patient_First_Name__c;
                woRecord.HRCFSL_Patient_Last_Name__c = mapOfWOByOLIId.containskey(oli.Id) ? mapOfWOByOLIId.get(oli.Id).HRCFSL_Patient_Last_Name__c :oli.Order__r.HRCSVC_Patient_Last_Name__c;
                woRecord.HRCFSL_Patient_Room__c = mapOfWOByOLIId.containskey(oli.Id) ? mapOfWOByOLIId.get(oli.Id).HRCFSL_Patient_Room__c :oli.HRCSVC_Patient_Room__c;
                
            }
            
            //need to confirm this next line with matt ->
            //woRecord.AssetId =  mapOfWOByOLIId.containskey(oli.Id) ? mapOfWOByOLIId.get(oli.Id).AssetId :oli.Order__r.HRCSVC_Asset__c;    
            
            woRecord.HRCFSL_Medical_Rec_No__c =  mapOfWOByOLIId.containskey(oli.Id) ? mapOfWOByOLIId.get(oli.Id).HRCFSL_Medical_Rec_No__c :oli.Order__r.HRCSVC_Medical_Record_ID__c;
            
            if(buttonType.equalsIgnoreCase('Repair Swap')){
                woRecord.HRCFSL_Extended_Instructions__c ='';
                woRecord.HRCFSL_Medical_Rec_No__c = '';
            } 
            
            woRecord.ContactId = mapOfWOByOLIId.containskey(oli.Id) ? mapOfWOByOLIId.get(oli.Id).ContactId :oli.HRCSVC_Contact_Name__c;
            woRecord.HRCFSL_Contact_First_Name__c =mapOfWOByOLIId.containskey(oli.Id) ? mapOfWOByOLIId.get(oli.Id).HRCFSL_Contact_First_Name__c :oli.HRCSVC_Contact_Name__r.FirstName;
            woRecord.HRCFSL_Contact_Last_Name__c = mapOfWOByOLIId.containskey(oli.Id) ? mapOfWOByOLIId.get(oli.Id).HRCFSL_Contact_Last_Name__c :oli.HRCSVC_Contact_Name__r.LastName;
            woRecord.HRCSVC_Related_Work_order_Id__c=mapOfWOByOLIId.containskey(oli.Id) ? mapOfWOByOLIId.get(oli.Id).Id:null; 
            listofWOToInsert.add(woRecord);
        }
        if(buttonType.equalsIgnoreCase('Repair Swap')){
            for(Order_Line_Item__c oli : oliRecList){
                woRecord = new WorkOrder();
                woRecord.HRCFSL_Doc_Type__c = 'SQ';
                woRecord.HRCFSL_Activity_Type__c = '7'; 
                woRecord.HRCSVC_Order_Line_Item__c = oli.Id;
                woRecord.HRCSVC_Order__c =oli.Order__c;
                woRecord.LocationId = oli.Order__r.HRCSVC_Ship_To_Location__c;
                woRecord.Status = 'SA';
                woRecord.HRCFSL_Ward_Text__c = oli.HRCSVC_Ward_Floor__c;
                woRecord.HRCFSL_Ward__c = oli.HRCSVC_Ward__c;
                woRecord.HRCFSL_JDE_Cost_Center__c = oli.HRCSVC_Customer_Cost_Center__c;
                woRecord.HRCFSL_PO__c = oli.HRCSVC_PO_Number__c;
                woRecord.HRCSV_Product__c = oli.product__c;//oli.HRCSVC_Product_Name__c;
                woRecord.AssetId = oli.HRCSVC_Asset__c;
                woRecord.HRCFSL_Extended_Instructions__c = oli.HRCSVC_WO_Extended_Instructions__c;
                woRecord.HRCFSL_Patient_on_date__c =oli.HRCSVC_Start_Date__c;
                woRecord.HRCFSL_Patient_Off_Date__c = oli.HRCSVC_End_Date__c;
                woRecord.HRCFSL_Patient_First_Name__c = oli.Order__r.HRCSVC_Patient_First_Name__c;
                woRecord.HRCFSL_Patient_Last_Name__c = oli.Order__r.HRCSVC_Patient_Last_Name__c;
                woRecord.HRCFSL_Patient_Room__c = oli.HRCSVC_Patient_Room__c;
                woRecord.AssetId = oli.Order__r.HRCSVC_Asset__c;    
                woRecord.HRCFSL_Medical_Rec_No__c =  oli.Order__r.HRCSVC_Medical_Record_ID__c;
                woRecord.ContactId = oli.HRCSVC_Contact_Name__c;
                woRecord.HRCFSL_Contact_First_Name__c =oli.HRCSVC_Contact_Name__r.FirstName;
                woRecord.HRCFSL_Contact_Last_Name__c = oli.HRCSVC_Contact_Name__r.LastName;
                woRecord.HRCSVC_Related_Work_order_Id__c=null; 
                
                
                listofWOToInsert.add(woRecord);
            }
        }
        system.debug('listofWOToInsert '+listofWOToInsert);
        if(!listofWOToInsert.isEmpty()){
            try{
                insert listofWOToInsert;
                }
                catch(Exception e){
                    throw new AuraHandledException(''+e.getMessage());
                }
            if(!WOComplainobjMap.isempty()){
                HRCSVC_Complaint_Qualification__c cqualnew = new HRCSVC_Complaint_Qualification__c();
                list<HRCSVC_Complaint_Qualification__c> cqualListtobeinserted = new list<HRCSVC_Complaint_Qualification__c>();
                for(workorder wo :[select id,HRCSVC_Related_Work_order_Id__c from workorder where HRCSVC_Related_Work_order_Id__c in:Woobjmap.keyset()]){
                    cqualnew=WOComplainobjMap.containskey(wo.HRCSVC_Related_Work_order_Id__c) ? WOComplainobjMap.get(wo.HRCSVC_Related_Work_order_Id__c) : null ;
                    if(cqualnew!=null){
                        cqualnew.HRCSVC_Work_Order__c=wo.id;
                        cqualnew.id=null;
                        cqualListtobeinserted.add(cqualnew);  
                    }                       
                } 
                if(!cqualListtobeinserted.isEmpty()){
                    insert cqualListtobeinserted;
                } 
            }
        }
        system.debug('listofWOToInsert '+listofWOToInsert);
    }
    
    /** this is a helper method that returns the list of relevant work orders for the 'Admin Complete' scenario (SE-1303)
* the work orders will already exist in this situation because there is automation that generates a Work Order from a Removal or Delivery Order
* Line Item. The method is also responsibily for manually setting the Start and End time of the Work Order to the current system time since
* the story dictates that the value of the Start and Complete date should be defaulted to now.
* there is also a checkbox called 'Admin Completed' that will be set to true so that these work orders can be identified for reporting
*/ 
    
    @AuraEnabled
    public static List<WorkOrder> getWorkOrdersForOLIs (List<Order_Line_Item__c> olis)
    {
        List<WorkOrder> relatedWOs= [select id, hrcsvc_admin_completed__c, hrcfsl_activity_type__c, assetid, hrcfsl_actual_end__c, hrcfsl_actual_start__c, hrcsvc_order_line_item__r.name 
                                     from WorkOrder where HRCSVC_Order_Line_Item__c in: olis];
        for (WorkOrder wo: relatedWOs)
        {
            wo.HRCFSL_Actual_End__c = system.now();
            wo.HRCFSL_Actual_Start__c = system.now();
            wo.HRCSVC_Admin_Completed__c = true;
        }
        
        return relatedWOs;
    }
    
    /** this is a helper method that is used by the 'Admin Complete' (SE-1303) scenario that takes in a list of Order Line Items and determines 
* whether or not the Admin Complete action is allowed for the Order Lines in this set. The rule that is applied is that each and every
* Order Line Item in the list must:
* 1 - have an Activity Type of R or D
* 2 - have a null Asset OR if the asset is NOT null and the Activity Type is R, the Asset's status must be ST or SS. if the asset is NOT null
* and the Activity Type is D then the Asset's status must be in (ST, SS, SB, SI)
* 
*/ 
    
    @AuraEnabled
    public static boolean allowAdminComplete (List<Order_Line_Item__c> olis)
    {
        HRCFSL_Organization_Settings__mdt allowedActivityTypes = [select hrcfsl_component_detail__c from hrcfsl_organization_settings__mdt
                                                                  where developername =: 'Allowed_Activity_Types_Admin_Complete'];
        HRCFSL_Organization_Settings__mdt allowedStatusDelivery = [select hrcfsl_component_detail__c from hrcfsl_organization_settings__mdt
                                                                   where developername =: 'Allowed_Asset_Status_Admin_Delivery'];        
        HRCFSL_Organization_Settings__mdt allowedStatusRemoval = [select hrcfsl_component_detail__c from hrcfsl_organization_settings__mdt
                                                                  where developername =: 'Allowed_Asset_Status_Admin_Removal'];
        if (olis == null || olis.size() == 0)
            return false;
        for (Order_Line_Item__c oli : [select id, hrcsvc_asset__r.status, hrcsvc_asset__c, hrcsvc_service_activity_type__c
                                       from Order_Line_Item__c where id in: olis])
        {
            if (!allowedActivityTypes.hrcfsl_component_detail__c.contains(oli.HRCSVC_Service_Activity_Type__c))
                return false;
            if (oli.HRCSVC_Service_Activity_Type__c == 'R' && oli.HRCSVC_Asset__c != null &&
                !allowedStatusRemoval.HRCFSL_Component_Detail__c.contains(oli.HRCSVC_Asset__r.Status))
                return false;
            if (oli.HRCSVC_Service_Activity_Type__c == 'D' && oli.HRCSVC_Asset__c != null &&
                !allowedStatusDelivery.HRCFSL_Component_Detail__c.contains(oli.HRCSVC_Asset__r.Status))
                return false;
        }
        
        return true;
    }
    
    
    /** this is a helper method that updates the Work Orders for the 'Admin Complete' scenario (SE-1303)
* it is invoked when the user clicks the 'Save' button on the popup modal
* 
* Note that there are restrictions in terms of what assets are valid to be selected. If the asset status is not valid for the delivery or removal
* then the method will throw an error which will be surfaced to the user via the Lightning component
*/
    
    /*@AuraEnabled
    public static void updateWOs (List<WorkOrder> wos)
    {
        System.debug('updateWOs');
        System.debug(wos);
        HRCFSL_Organization_Settings__mdt allowedStatusDelivery = [select hrcfsl_component_detail__c from hrcfsl_organization_settings__mdt
                                                                   where developername =: 'Allowed_Asset_Status_Admin_Delivery'];        
        HRCFSL_Organization_Settings__mdt allowedStatusRemoval = [select hrcfsl_component_detail__c from hrcfsl_organization_settings__mdt
                                                                  where developername =: 'Allowed_Asset_Status_Admin_Removal'];
        Set<Id> assetIds = new Set<Id>();
        Set<Id> oliIds = new Set<Id>();
        for (WorkOrder wo: wos){
            assetIds.add(wo.AssetId);
            oliIds.add(wo.HRCSVC_Order_Line_Item__c);
        }
        
        List<Order_Line_Item__c> toUpdateOlis=new List<Order_Line_Item__c>();
        for (Order_Line_Item__c oli: [Select Id,HRCSVC_Paging_Team__c from Order_Line_Item__c where id in: oliIds]){
            oli.HRCSVC_Paging_Team__c='NP';
            toUpdateOlis.add(oli);
        }
        
        //  Map<String, Asset> assetMap = new Map<String, Asset>([select id, status from asset where id in: assetIds]);
        Map<String, Asset> assetMap = new Map<String, Asset>([select id, HRCFSL_Asset_Status__c from asset where id in: assetIds]);
        for (WorkOrder workOrder : wos)
        {
            if (workOrder.HRCFSL_Activity_Type__c == 'R' && workOrder.AssetId != null &&
                !allowedStatusRemoval.HRCFSL_Component_Detail__c.contains(assetMap.get(workOrder.AssetId).HRCFSL_Asset_Status__c))
            {
                InvalidParameterValueException e = new InvalidParameterValueException('foo', 'foo2');
                e.setMessage('Asset is not in a valid status to Admin Complete the Removal');
                throw e;
            }
            if (workOrder.HRCFSL_Activity_Type__c == 'D' && workOrder.AssetId != null &&
                !allowedStatusDelivery.HRCFSL_Component_Detail__c.contains(assetMap.get(workOrder.AssetId).HRCFSL_Asset_Status__c))
            {
                System.debug('D');
                System.debug(workOrder.AssetId);            
                System.debug(workOrder.Asset.HRCFSL_Asset_Status__c);    
                System.debug(assetMap.get(workOrder.AssetId).HRCFSL_Asset_Status__c);    
                InvalidParameterValueException e = new InvalidParameterValueException('foo', 'foo2');
                e.setMessage('Asset is not in a valid status to Admin Complete the Delivery');
                throw e;                
            }
            
        }
        update wos;
        update toUpdateOlis;
    }*/

    @AuraEnabled
    public static void updateWOs (List<WorkOrder> wos)
    {
        System.debug('updateWOs');
        System.debug(wos);
        
        Set<Id> oliIds = new Set<Id>();
        List<Order_Line_Item__c> toUpdateOlis=new List<Order_Line_Item__c>();
        for (Order_Line_Item__c oli: [Select Id,HRCSVC_Paging_Team__c from Order_Line_Item__c where id in: oliIds]){
            oli.HRCSVC_Paging_Team__c='NP';
            toUpdateOlis.add(oli);
        }
        
        update wos;
        update toUpdateOlis;
    }
    
    /** this is a helper method that is used by the 'Admin Bed Move' (SE-1030) 

*/ 
    @AuraEnabled
    public static List<WorkOrder> getWOAdminBedMove (List<Order_Line_Item__c> olis)
    {
        List<WorkOrder> relatedWOs= new List<WorkOrder>();
        for (Order_Line_Item__c oli: olis)
        {
            WorkOrder wo=new WorkOrder();
            wo.HRCFSL_Actual_End__c = system.now();
            wo.HRCFSL_Actual_Start__c = system.now(); 
            wo.HRCSVC_Order_Line_Item__c = oli.Id;
            wo.AssetId=oli.HRCSVC_Asset__c;
            wo.HRCSVC_Admin_Completed__c = true;
            wo.Status='SC';
            relatedWOs.add(wo);
        }
        
        return relatedWOs;
    }
    
}