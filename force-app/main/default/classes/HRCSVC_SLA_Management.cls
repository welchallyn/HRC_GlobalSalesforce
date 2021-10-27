/*******************************************************************************************************
* Name                             : HRCSVC_SLA_Management
* Author                           : Capgemini
* Date                             : Novmber/25/2020
* Requirement/Project Name         : Hill-Rom
* Requirement/Project Description  : 1.Class to calculate SLA response time based on SLA rule.
                                       Created for #SE-54
* Revison                          :
/*******************************************************************************************************/
public class HRCSVC_SLA_Management  
{
    @testvisible private static List<HRCSVC_Work_Order_SLA__c> mySLAs;
    @testvisible private Enum SLA_PRIORITY {PRODUCT_MODEL_CUSTOMER, PRODUCT_MODEL_PRICING_GROUP, PRODUCT_MODEL_SUPER_GROUP, PRODUCT_MODEL, 
                               PRODUCT_FAMILY_CUSTOMER, PRODUCT_FAMILY_PRICING_GROUP, PRODUCT_FAMILY_SUPER_GROUP, PRODUCT_FAMILY, 
                               CUSTOMER, PRICING_GROUP, SUPER_GROUP, WORK_TYPE}
    @testvisible private static Map<Id, ServiceTerritory> myServiceGeolocation;
    @testvisible private static Map<Id, Schema.Address> myLocationGeolocation;
    @testvisible private static List<Id> myLocations;
    @testvisible private static List<Id> myServiceTerritories;
    @testvisible private static List<Id> myWorkTypes;
    @testvisible private static List<String> myCountries;
    
    /** inner class that is responsible for storing a calculated SLA time. the class contains an early start and due date,
     * as well as an SLA Priority Type. The SLA Priority Type is used so that comparisons can be made between different calculated SLAs
     * and the right SLA can be chosen among different SLAs which are all qualified
     */ 
    public class SLATime
    {
        private datetime myEarlyStart;
        private datetime myDueDate;
        private SLA_PRIORITY myCustomerType {get; set;}
        public SLATime(Datetime earlyStart, DateTime dueDate)
        {
            myEarlyStart = earlyStart;
            myDueDate = dueDate;
        }
        
        public SLATime(DateTime earlyStart, DateTime dueDate, SLA_PRIORITY type)
        {
            myEarlyStart = earlyStart;
            myDueDate = dueDate;
            myCustomerType = type;
        }
        
        public DateTime getEarlyStart()
        {
            return myEarlyStart;
        }
    }
    
    public class SLAParams
    {
        private String myCountry {get; set;}
        private String mySuperGroup {get; set;}
        private String myPricingGroup {get; set;}
        private String myCustomerId {get; set;}
        private String myProductModel {get; set;}
        private String myProductFamily {get; set;}
        private String myWorkType {get; set;}
        private String myServiceTerritory {get; set;}
        private datetime myLastmodifiedDate {get;set;}
        public SLAParams(WorkOrder wo)
        {
            myWorkType = wo.WorkTypeId;
            myCountry = wo.Country;
            myCustomerId = wo.LocationId;
            myPricingGroup = myLocationGeolocation.containskey(wo.LocationId) ? myLocationGeolocation.get(wo.LocationId).Parent.HRCFSL_Account__r.IDN_1__c : '';
            mySuperGroup = myLocationGeolocation.containskey(wo.LocationId)? myLocationGeolocation.get(wo.LocationId).Parent.HRCFSL_Account__r.GPO__c : '';
            myProductFamily = wo.HRCFSL_Asset_Product_Family__c;
            myProductModel = wo.HRCFSL_Asset_Product_Model__c;
            myServiceTerritory = wo.ServiceTerritoryId;
            myLastmodifiedDate = wo.lastmodifieddate;
            
        }
        
        public SLAParams(Order_Line_Item__c oli, Order__c order)
        {
            String computedWorkType = 'SQ_' + oli.HRCSVC_Service_Activity_Type__c;
            myWorkType = [select id from worktype where HRCFSL_JDE_Id__c =: computedWorkType limit 1]?.Id;
            myCountry = myLocationGeolocation.containskey(order.HRCSVC_Ship_To_Location__c) ? myLocationGeolocation.get(order.HRCSVC_Ship_To_Location__c).Parent.HRCFSL_Country__c : '';
            myServiceTerritory = myLocationGeolocation.containskey(order.HRCSVC_Ship_To_Location__c) ? myLocationGeolocation.get(order.HRCSVC_Ship_To_Location__c).Parent.HRCFSL_Service_Territory__c : '';
            myCustomerId = order.HRCSVC_Ship_To_Location__c;
            myPricingGroup = myLocationGeolocation.containsKey(order.HRCSVC_Ship_To_Location__c) ? myLocationGeolocation.get(order.HRCSVC_Ship_To_Location__c).Parent.HRCFSL_Account__r.IDN_1__c : '';
            mySuperGroup = myLocationGeolocation.containskey(order.HRCSVC_Ship_To_Location__c) ? myLocationGeolocation.get(order.HRCSVC_Ship_To_Location__c).Parent.HRCFSL_Account__r.GPO__c : '';
            list<Product2> productlist=new list<Product2>();
            productlist = [select family, productcode from product2 where id =: oli.Product__c limit 1];
            //the below need to be updated with the correct mapping once we figure out what the right fields for product model and product family are
            myProductFamily = productlist.isEmpty() ? '' : productlist[0].family;
            myProductModel = productlist.isEmpty()  ? '' : productlist[0].productcode;
           // myLastmodifiedDate = oli.lastmodifieddate;    
           myLastmodifiedDate = Datetime.now();         
        }
    }
    @AuraEnabled
    public static DateTime getDueDate(Order_Line_Item__c oli, Order__c order)
    {
        myLocations = new List<Id>();
        myWorkTypes = new List<Id>();
        myLocations.add(order.HRCSVC_Ship_To_Location__c);
        String computedWorkType = 'SQ_' + oli.HRCSVC_Service_Activity_Type__c;
        String workType = [select id from worktype where HRCFSL_JDE_Id__c =: computedWorkType limit 1]?.Id;
        myWorkTypes.add(workType);
        populateMaps();
        SLAParams oliParam = new SLAParams(oli, order);
        SLATime oliSLA = getSLA(oliParam);
        return oliSLA.myDueDate;
    }
    
    @InvocableMethod(label='Get Work Order SLAs' description='Returns the list of Integers of matching work order sla\'s responsehours corresponding to the specified Work Order.' category='workOrder')
    public static void execute (List<workOrder> workOrder){
        List<workOrder> toUpdateWorkOrder = new List<workOrder>();
        Location loc1;
        Location loc2;
        double dist = -1;
        Time earlyTime = null;
        Time lateTime = null;
        List<Integer> responseHours;
        List<Id> locations = new List<Id>();
        List<String> country = new List<String>();
        myWorkTypes = new List<Id>();
        myLocations = new List<Id>();
        for(workOrder work: workOrder){
            if(work.country == 'United States'){
                country.add('US');
            } else if(work.country == 'Ireland'){
                country.add('IE');
            } else {
                country.add(work.country);
            }
            myWorkTypes.add(work.workTypeId);
            myLocations.add(work.LocationId);
        }        
        populateMaps();  
        
            for(workOrder work: workOrder){
                SLATime workOrderSLA = getSLA(new SLAParams(work));
                WorkOrder updateWO = new WorkOrder(Id = work.id);
                updateWO.EndDate = workOrderSLA.myDueDate;
                updateWO.StartDate = workOrderSLA.myEarlyStart;
                toUpdateWorkOrder.add(updateWO);            
            }
        update toUpdateWorkOrder; 
    }
     
    @AuraEnabled
    public static Map<SLA_PRIORITY, SLATime> handleSlaMap(Map<SLA_PRIORITY, SLATime> slaMap,SLA_PRIORITY sl,SLAParams param,HRCSVC_Work_Order_SLA__c sla ){
        if (slaMap.containsKey(sl)){
            SLATime currentSLA = slaMap.get(sl);
            if (replaceSLA(currentSLA, getSLA(sla,param))){
                slaMap.put(sl, getSLA(sla,param));
            }               
        }
        else{
            slaMap.put(sl, getSLA(sla, param));
        }
      return slaMap;     
    }

    @AuraEnabled
    public static SLATime getSLA(SLAParams param){
        Map<SLA_PRIORITY, SLATime> slaMap = new Map<SLA_PRIORITY, SLATime>();     
        for (HRCSVC_Work_Order_SLA__c sla : mySLAs){
            if (isMatch(param, sla)) { 
                if (sla.HRCSVC_Product_Model__c != null && sla.HRCSVC_Customer__c != null ){
                 slaMap = handleSlaMap(slaMap,SLA_PRIORITY.PRODUCT_MODEL_CUSTOMER,param,sla);   
                }
                else if (sla.HRCSVC_Product_Model__c != null && sla.HRCSVC_Pricing_Group__c != null ){
                 slaMap = handleSlaMap(slaMap,SLA_PRIORITY.PRODUCT_MODEL_PRICING_GROUP,param,sla);   
                }
                else if (sla.HRCSVC_Product_Model__c != null && sla.HRCSVC_Super_Group__c != null ){
                 slaMap = handleSlaMap(slaMap,SLA_PRIORITY.PRODUCT_MODEL_SUPER_GROUP,param,sla); 
                }
                else if (sla.HRCSVC_Product_Model__c != null ){
                 slaMap = handleSlaMap(slaMap,SLA_PRIORITY.PRODUCT_MODEL,param,sla);
                }
                else if (sla.HRCSVC_Product_Family__c != null && sla.HRCSVC_Customer__c != null ){
                 slaMap = handleSlaMap(slaMap,SLA_PRIORITY.PRODUCT_FAMILY_CUSTOMER,param,sla);  
                }
                else if (sla.HRCSVC_Product_Family__c != null && sla.HRCSVC_Pricing_Group__c != null ){
                 slaMap = handleSlaMap(slaMap,SLA_PRIORITY.PRODUCT_FAMILY_PRICING_GROUP,param,sla);      
                }
                else if (sla.HRCSVC_Product_Family__c != null && sla.HRCSVC_Super_Group__c != null ){
                 slaMap = handleSlaMap(slaMap,SLA_PRIORITY.PRODUCT_FAMILY_SUPER_GROUP,param,sla);      
                }
                else if (sla.HRCSVC_Product_Family__c != null ){
                 slaMap = handleSlaMap(slaMap,SLA_PRIORITY.PRODUCT_FAMILY,param,sla);        
                }                
                else if (sla.HRCSVC_Customer__c != null ){
                 slaMap = handleSlaMap(slaMap,SLA_PRIORITY.CUSTOMER,param,sla);       
                }                
                else if (sla.HRCSVC_Pricing_Group__c != null ){
                 slaMap = handleSlaMap(slaMap,SLA_PRIORITY.PRICING_GROUP,param,sla);        
                }                
                else if (sla.HRCSVC_Super_Group__c != null ){
                  slaMap = handleSlaMap(slaMap,SLA_PRIORITY.SUPER_GROUP,param,sla);        
                }                
                else if (sla.HRCSVC_Work_Type__c != null ){
                  slaMap = handleSlaMap(slaMap,SLA_PRIORITY.WORK_TYPE,param,sla);      
                }                
            }
        }        
        return discernAppropriateSLA(slaMap);
    }
    
    /** helper method that is responsible for taking all the SLAs that are qualified (i.e. they match the Work Order or Order Line)
     * and determing which of those is the highest priority and hence the right SLA to use. The method iterates over the list of enums and 
     * when it finds a match stops and returns that value
     */ 
    private static SLATime discernAppropriateSLA (Map<SLA_PRIORITY, SLATime> slaMap)
    {
  
        for (SLA_PRIORITY currentPriority : SLA_PRIORITY.values())
            if (slaMap.containsKey(currentPriority))
            	return slaMap.get(currentPriority);
        return new SLATime(system.now(), system.now().addDays(3));
    }
    
    public static SLATime getSLA (HRCSVC_Work_Order_SLA__c sla, SLAParams qualifiedRecord)
    {
        SLATime calcSLA = null;
        DateTime earlyStart, dueDate;
        //if there is no early start and late start explicitly provided for the SLA record, then add the response hours to the current time
        if (sla.HRCSVC_Early_Start_Time__c == null && sla.HRCSVC_Late_Start_Time__c == null)
        {
            earlyStart = system.now();
            dueDate = system.now().addHours((integer)sla.HRCSVC_Response_Hours__c);
        }
        //otherwise if an explicit early start and late start is supplied, use that
        else
        {
            DateTime convertedDT = getConvertedDateTime(system.now(), myLocationGeolocation.get(qualifiedRecord.myCustomerId).Parent.TimeZone);
            Time convertedTime = Time.newInstance(convertedDT.hour(), convertedDT.minute(),0,0);
         
            /* So there are two scenarios to consider. 
             * Scenario 1: the explicitly defined early start time is AFTER the current time and hence we should set the 
             * SLA calculated DAY as today (example: there is a defined early start time of 17:00 and it is currently 13:00 )
             * Scenario 2: the explicitly defined early start time is BEFORE the current time and hence we should set the 
             * SLA calculated DAY as tomorrow (example: there is a defined early start time of 09:00 and it is currently 13:00)
             * 
             */ 
            //scenario 1 - use today
            if (sla.HRCSVC_Early_Start_Time__c >= convertedTime)
            {
                earlyStart = 
                    createInTimeZone(DateTime.newInstanceGMT(convertedDT.year(), convertedDT.month(), convertedDT.day(), sla.HRCSVC_Early_Start_Time__c.hour(), sla.HRCSVC_Early_Start_Time__c.minute(), 0),
                                     myLocationGeolocation.get(qualifiedRecord.myCustomerId).Parent.TimeZone);
                dueDate =
                    createInTimeZone(DateTime.newInstanceGMT(convertedDT.year(), convertedDT.month(), convertedDT.day(), sla.HRCSVC_Late_Start_Time__c.hour(), sla.HRCSVC_Late_Start_Time__c.minute(), 0),
                                     myLocationGeolocation.get(qualifiedRecord.myCustomerId).Parent.TimeZone);         
                
            }
            //scenario 2 - use tomorrow
            else
            {
                DateTime tomorrow = convertedDT.addDays(1);
                system.debug('tomorrow is ' + tomorrow);
                earlyStart = 
                    createInTimeZone(DateTime.newInstanceGMT(tomorrow.year(), tomorrow.month(), tomorrow.day(), sla.HRCSVC_Early_Start_Time__c.hour(), sla.HRCSVC_Early_Start_Time__c.minute(), 0),
                                     myLocationGeolocation.get(qualifiedRecord.myCustomerId).Parent.TimeZone);
                dueDate =
                    createInTimeZone(DateTime.newInstanceGMT(tomorrow.year(), tomorrow.month(), tomorrow.day(), sla.HRCSVC_Late_Start_Time__c.hour(), sla.HRCSVC_Late_Start_Time__c.minute(), 0),
                                     myLocationGeolocation.get(qualifiedRecord.myCustomerId).Parent.TimeZone);
                
            }
                
        }
        SLA_PRIORITY slaType;
        if (sla.HRCSVC_Customer__c != null)
            slaType = SLA_PRIORITY.CUSTOMER;
        else if (sla.HRCSVC_Pricing_Group__c != null)
            slaType = SLA_PRIORITY.PRICING_GROUP;
        else if (sla.HRCSVC_Super_Group__c != null)
            slaType = SLA_PRIORITY.SUPER_GROUP;
        calcSLA = new SLATime(earlyStart, dueDate, slaType);
        system.debug(calcSLA);
        return calcSLA;
    }
    private static boolean isMatch(SLAParams recordToQualify, HRCSVC_Work_Order_SLA__c sla)
    {
        Location loc1 = location.newInstance(myLocationGeolocation.get(recordToQualify.myCustomerId).Latitude,myLocationGeolocation.get(recordToQualify.myCustomerId).Longitude);
        Location loc2 = location.newInstance(myServiceGeolocation.get(recordToQualify.myServiceTerritory).latitude,myServiceGeolocation.get(recordToQualify.myServiceTerritory).longitude);
        
        double dist = location.getDistance(loc1,loc2,'mi');
        //system.debug('work order visitor address is: ' + myLocationGeolocation.get(wo.LocationId));
        //system.debug('calculated distance for the work order ' + wo.WorkOrderNumber + ' is: ' + dist);
        return (sla.HRCSVC_Customer__c == recordToQualify.myCustomerId || sla.HRCSVC_Customer__c == null)
            && (sla.HRCSVC_Product_Model__c == recordToQualify.myProductModel || sla.HRCSVC_Product_Model__c == null)
            && (sla.HRCSVC_Product_Family__c == recordToQualify.myProductFamily || sla.HRCSVC_Product_Family__c == null)
            && (sla.HRCSVC_Pricing_Group__c == recordToQualify.myPricingGroup || sla.HRCSVC_Pricing_Group__c == null)
            && (sla.HRCSVC_Super_Group__c == recordToQualify.mySuperGroup || sla.HRCSVC_Super_Group__c == null)
            && (sla.HRCSVC_Country__c == recordToQualify.myCountry && sla.HRCSVC_Work_Type__c == recordToQualify.myWorkType)
            && (sla.HRCSVC_Time_From__c <= (recordToQualify.myLastmodifiedDate).time() || sla.HRCSVC_Time_From__c == null)
            && (sla.HRCSVC_Time_To__c >= (recordToQualify.myLastmodifiedDate.time()) || sla.HRCSVC_Time_To__c == null)
            && ((sla.HRCSVC_Miles_From__c <= dist && dist <= sla.HRCSVC_Miles_To__c) || sla.HRCSVC_Miles_From__c == null || sla.HRCSVC_Miles_To__c == null);
    }
    /** helper method to create a datetime ina  specified time zone
     * https://developer.salesforce.com/forums/?id=906F00000008zv0IAA
     */
    private static DateTime createInTimeZone(DateTime dt, String timeZone){
        string dateTimeStr = dt.format('yyyy-MM-dd HH:mm:ss',  timeZone);
        string dateGmtStr  = dt.formatGMT('yyyy-MM-dd HH:mm:ss');
        Datetime localDateTime = DateTime.valueOf(dateTimeStr);
        Datetime baseGMTTime = DateTime.valueOf(dateGMTStr);
        Long milliSecDiff =  baseGMTTime.getTime() - localDateTime.getTime();
        Long minDiff = milliSecDiff / 1000 / 60;
        Datetime outDateTime = dt.addMinutes(minDiff.intValue());
        return outDateTime;
    }
    /** helper method that is used whenever multiple WorkOrderSLA records are qualified for the same product model or product family
     * the logic we implement is that Customer has the first priority followed by Pricing Group and then Super Group.
     * So for example, if there are three records which relate to the same Product Model AND:
     * Record A matches the product model and Customer on the Work Order
     * Record B matches the product model and Pricing Group on the Work Order
     * Record C matches the product model and Super Group on the Work Order
     * 
     * Our logic per the business rules is that Record A has the highest preference and will be selected.
     * If we only had Record B and Record C, Record B would have the highest preference and would be selected
     * 
     * This logic is only applicable for Work Order SLA records which have EITHER a product model OR a product family specified
     * 
     */ 
    @testVisible private static boolean replaceSLA(SLATime current, SLATime next){        
       /* if (current.myCustomerType != SLA_PRIORITY.CUSTOMER){
            if (next.myCustomerType == SLA_PRIORITY.CUSTOMER || current.myCustomerType == null)
                return true;
            if (next.myCustomerType == SLA_PRIORITY.PRICING_GROUP && current.myCustomerType == SLA_PRIORITY.SUPER_GROUP)
                return true;
        }*/
        //updated as per the last update , will give priority to lower response time WO SLA if more than one record found with same priority
            if(current.myDueDate > next.myDueDate){
                return true;
            }
        return false;
    }
    
    private static void populateMaps()
    {
        List<Schema.Address> addresses = 
            [SELECT id, latitude, longitude, parent.hrcfsl_country__c, parent.HRCFSL_Account__r.GPO__c, parent.hrcfsl_service_territory__c, parent.hrcfsl_account__r.IDN_1__c, timezone, parentid, parent.timezone 
             FROM Address 
             where parentid IN :myLocations];
        myServiceGeolocation = new Map<Id, ServiceTerritory>();
        myLocationGeolocation = new Map<Id, Schema.Address>();
        myServiceTerritories = new List<Id>();
        myCountries = new List<String>();
        for (Schema.Address ad: addresses)
        {
            myLocationGeolocation.put(ad.parentId, ad);
            myServiceTerritories.add(ad.parent.hrcfsl_service_territory__c);
            myCountries.add(ad.parent.hrcfsl_country__c);
        }
            
        List<ServiceTerritory> serviceTerritory = 
            [SELECT id, latitude, longitude FROM ServiceTerritory where id IN :myServiceTerritories];
        

        for(ServiceTerritory st:serviceTerritory)        
            myServiceGeolocation.put(st.id, st);
        
         mySLAs =
            [SELECT Name, HRCSVC_Country__c, HRCSVC_Work_Type__c, HRCSVC_Customer__c, HRCSVC_Pricing_Group__c, HRCSVC_Super_Group__c, 
             HRCSVC_Item_Number__c, HRCSVC_Product_Model__c, HRCSVC_Cat_Code_31__c, HRCSVC_Miles_From__c, HRCSVC_Miles_To__c,
             HRCSVC_Time_From__c, HRCSVC_Time_To__c, HRCSVC_Response_Hours__c, HRCSVC_Early_Start_Time__c, HRCSVC_Late_Start_Time__c,
             HRCSVC_Product_Family__c
             FROM HRCSVC_Work_Order_SLA__c 
             WHERE HRCSVC_Country__c IN :myCountries AND HRCSVC_Work_Type__c IN : myWorkTypes];
        
    }
    private static DateTime getConvertedDateTime(DateTime timeInGMT, String timeZone)
    {
        return DateTime.valueof(timeInGMT.format('yyyy-MM-dd HH:mm:ss', timeZone));
    }
}