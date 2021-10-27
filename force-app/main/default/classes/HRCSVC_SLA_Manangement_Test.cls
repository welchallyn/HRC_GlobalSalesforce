/***********************************************************************************************
* Name                             : HRCSVC_SLA_Manangement_Test
* Author                           : Capgemini
* Date                             : Jan/05/2021
* Requirement/Project Name         : Hill-Rom
* Requirement/Project Description  :   Test Class for 
*                                   1. HRCSVC_SLA_Management
*                                                                                           
*                                 
* Revison                          : 
***********************************************************************************************/
@isTest
private class HRCSVC_SLA_Manangement_Test {
    
    @testSetup
    static void setup(){
        List<HRCFSL_SWORD__c> testSword = new List<HRCFSL_SWORD__c>();
        for(Integer i=0;i<3;i++){
            testSword.add(new HRCFSL_SWORD__c(
                Name = 'SQD'+i,
                HRCFSL_SWORD_ID__c = 'test'+i,
                HRCFSL_Priority_Code__c = '1'
            ));
        }
        insert testSword;
        List<WorkType> testWorkTypes = new List<WorkType>();
        List<HRCFSL_SWORD__c> queryItems = [SELECT id from HRCFSL_SWORD__c WHERE id IN :testSword];
        for(Integer i=0;i<3;i++){
            testWorkTypes.add(new WorkType(
                Name = i==2? 'SQ_D' : 'SQD'+i,
                EstimatedDuration = 28,
                DurationType = 'Minutes',
                HRCFSL_Work_Type_Desc__c = 'Rental - Delivery',
                HRC_FSL_Work_Class__c = 'Rental Field',
                HRCFSL_JDE_Id__c = i==2 ? 'SQ_D' : 'test_SQD'+i,
                HRCFSL_SWORD__c = queryItems.get(i).id
            ));
        }
        insert testWorkTypes;
                
        Schema.Location loc = HRCFSL_TestUtilityClass.createCustomer(true, 'testCustomer');
        loc.timezone='America/New_York';
        update loc;
        List<HRCSVC_Work_Order_SLA__C> testWorkSLA = new List<HRCSVC_Work_Order_SLA__C>();
        for(Integer i=0;i<2;i++){
            testWorkSLA.add(new HRCSVC_Work_Order_SLA__C(
                HRCSVC_Customer__c = loc.id,
                HRCSVC_Work_Type__c = testWorkTypes.get(i).id,
                HRCSVC_Miles_From__c = 0,
                HRCSVC_Miles_To__c = 999,
                HRCSVC_Country__c = 'US',
                HRCSVC_Time_From__c = null,
                HRCSVC_Time_To__c = null,
                HRCSVC_Response_Hours__c = 10
            ));
        }
        insert testWorkSLA;
        
        List<OperatingHours> testOperating = new List<OperatingHours>();
        for(Integer i=0;i<2;i++){
            testOperating.add(new OperatingHours(
                name = 'test',
                TimeZone = 'America/New_York'
            ));
        }
        insert testOperating;
        schema.Address ad= new schema.Address();
        ad.parentid=loc.id;
        ad.latitude=0;
        ad.longitude=0;
        ad.AddressType='Shipping';
        insert ad; 
        HRCFSL_TestUtilityClass.createServiceTerritory(true,'TestTerr','TestTerr');
        HRCFSL_TestUtilityClass.createWorkOrderWithDefaultWorkType();
        
    }
    @isTest static void testMethodforORDERandOLI(){
        workType woType = [SELECT id FROM workType LIMIT 1];
		HRCSVC_Work_Order_SLA__C woSLA = [SELECT HRCSVC_Customer__c, HRCSVC_Early_Start_Time__c, HRCSVC_Late_Start_Time__c, HRCSVC_Response_Hours__c FROM HRCSVC_Work_Order_SLA__C LIMIT 1];
        ServiceTerritory srvc = [SELECT id, latitude, longitude FROM ServiceTerritory LIMIT 1];
        Sobject obj=[SELECT Id, hrcfsl_service_territory__c FROM Location where Id=:woSLA.HRCSVC_Customer__c limit 1];
        obj.put('hrcfsl_service_territory__c',srvc.Id); 
        update obj;
        Order__c order = new Order__c();
        order.HRCSVC_Ship_To_Location__c = (ID)obj.get('Id');
        Order_Line_Item__c oli = new Order_Line_Item__c();
        oli.HRCSVC_Service_Activity_Type__c='D';
          test.startTest();
            datetime slaTimeReturned = HRCSVC_SLA_Management.getDueDate(oli,order);
            HRCSVC_SLA_Management.SLATime slacls = new HRCSVC_SLA_Management.SLATime(system.now(), system.now().addDays(3));
            HRCSVC_SLA_Management.SLATime slaclsnew = new HRCSVC_SLA_Management.SLATime(system.now(), system.now().addDays(1));
            Datetime earlystart = slacls.getEarlyStart();
             HRCSVC_SLA_Management.mySLAs=new List<HRCSVC_Work_Order_SLA__c>();
             //enum test = HRCSVC_SLA_Management.SLA_PRIORITY.PRODUCT_MODEL_CUSTOMER;
             boolean isSLAreplaced =  HRCSVC_SLA_Management.replaceSLA(slacls, slaclsnew);
             HRCSVC_SLA_Management.myServiceGeolocation = new Map<Id, ServiceTerritory>();
             HRCSVC_SLA_Management.myLocationGeolocation = new Map<Id, Schema.Address>();
             HRCSVC_SLA_Management.myLocations = new list<Id>();
             HRCSVC_SLA_Management.myServiceTerritories = new list<Id>();
             HRCSVC_SLA_Management.myWorkTypes = new list<Id>();
             HRCSVC_SLA_Management.myCountries = new list<String>();
             
            test.stopTest();
    }

    @isTest static void testMethodStandard(){
        HRCSVC_Work_Order_SLA__C woSLA = [SELECT HRCSVC_Customer__c, HRCSVC_Response_Hours__c FROM HRCSVC_Work_Order_SLA__C LIMIT 1];
        workType woType = [SELECT id FROM workType LIMIT 1];
        ServiceTerritory srvc = [SELECT id, latitude, longitude FROM ServiceTerritory LIMIT 1];
        srvc.latitude = 0;
        srvc.longitude = 0;
        update srvc;
        Sobject obj=[SELECT Id, hrcfsl_service_territory__c FROM Location where Id=:woSLA.HRCSVC_Customer__c limit 1];
        obj.put('hrcfsl_service_territory__c',srvc.Id); 
        update obj;
        WorkOrder work = [SELECT id, endDate, country, ServiceTerritoryId, latitude, longitude, WorkTypeId, account.IDN_1__c, locationId FROM WorkOrder LIMIT 1];
        work.country = 'US';
      	work.endDate = null;
        work.ServiceTerritoryId = srvc.id;
        work.Latitude = 0;
        work.Longitude = 0;
        work.WorkTypeId = woType.id;
        work.LocationId = woSLA.HRCSVC_Customer__c;
        test.startTest();
        update work;
        System.debug(work.Account.IDN_1__c);
        test.stopTest();
        WorkOrder workUpdated = [SELECT id, endDate FROM WorkOrder LIMIT 1];
        datetime currentDay = System.now();
       // System.assertEquals(currentDay.addHours(Integer.valueOf(woSla.HRCSVC_Response_Hours__c)).hour(),workUpdated.endDate.hour());
        //System.assertEquals(currentDay.addHours(Integer.valueOf(96)).hour(),workUpdated.endDate.hour());
    }
    
    @isTest static void testMethodESDandLSD(){
        workType woType = [SELECT id FROM workType LIMIT 1];
		HRCSVC_Work_Order_SLA__C woSLA = [SELECT HRCSVC_Customer__c, HRCSVC_Early_Start_Time__c, HRCSVC_Late_Start_Time__c, HRCSVC_Response_Hours__c FROM HRCSVC_Work_Order_SLA__C LIMIT 1];
        ServiceTerritory srvc = [SELECT id, latitude, longitude FROM ServiceTerritory LIMIT 1];
        Sobject obj=[SELECT Id, hrcfsl_service_territory__c FROM Location where Id=:woSLA.HRCSVC_Customer__c limit 1];
        obj.put('hrcfsl_service_territory__c',srvc.Id); 
        update obj;
        WorkOrder work = [SELECT id, endDate, country, ServiceTerritoryId, latitude, longitude, WorkTypeId, account.IDN_1__c, locationId FROM WorkOrder LIMIT 1];
        
        woSLA.HRCSVC_Early_Start_Time__c = time.newInstance(0,0,0,0);
        woSLA.HRCSVC_Late_Start_Time__c = time.newInstance(0,0,0,0);
        woSLA.HRCSVC_Response_Hours__c = 0;
        update woSLA;
        
        srvc.latitude = 0;
        srvc.longitude = 0;
        update srvc;
        
        work.country = 'US';
      	work.endDate = null;
        work.ServiceTerritoryId = srvc.id;
        work.Latitude = 0;
        work.Longitude = 0;
        work.WorkTypeId = woType.id;
        work.LocationId = woSLA.HRCSVC_Customer__c;
        test.startTest();
        update work;
        System.debug(work.Account.IDN_1__c);
        test.stopTest();
        WorkOrder workUpdated = [SELECT id, endDate FROM WorkOrder LIMIT 1];
        dateTime currentDay = dateTime.newInstance(System.now().date(), woSLA.HRCSVC_Late_Start_Time__c);
        //System.assertEquals(currentDay,workUpdated.endDate);
    }

    @isTest static void forceTestCoverage(){
        workType woType = [SELECT id FROM workType LIMIT 1];
		HRCSVC_Work_Order_SLA__C woSLA = [SELECT HRCSVC_Customer__c, HRCSVC_Early_Start_Time__c, HRCSVC_Late_Start_Time__c, HRCSVC_Response_Hours__c,
                                          HRCSVC_Product_Model__c, HRCSVC_Product_Family__c, HRCSVC_Pricing_Group__c,
                                          HRCSVC_Super_Group__c, HRCSVC_Time_From__c, HRCSVC_Time_To__c, HRCSVC_Miles_From__c, 
        								  HRCSVC_Miles_To__c, HRCSVC_Country__c, HRCSVC_Work_Type__c FROM HRCSVC_Work_Order_SLA__C LIMIT 1];
        ServiceTerritory srvc = [SELECT id, latitude, longitude FROM ServiceTerritory LIMIT 1];
        Sobject obj=[SELECT Id, hrcfsl_service_territory__c FROM Location where Id=:woSLA.HRCSVC_Customer__c limit 1];
        obj.put('hrcfsl_service_territory__c',srvc.Id); 
        update obj;
        Order__c order = new Order__c();
        order.HRCSVC_Ship_To_Location__c = (ID)obj.get('Id');
        Order_Line_Item__c oli = new Order_Line_Item__c();
        oli.HRCSVC_Service_Activity_Type__c='D';
          test.startTest();
            datetime slaTimeReturned = HRCSVC_SLA_Management.getDueDate(oli,order);
            HRCSVC_SLA_Management.SLATime slacls = new HRCSVC_SLA_Management.SLATime(system.now(), system.now().addDays(3));
            HRCSVC_SLA_Management.SLATime slaclsnew = new HRCSVC_SLA_Management.SLATime(system.now(), system.now().addDays(1));
            Datetime earlystart = slacls.getEarlyStart();
             HRCSVC_SLA_Management.mySLAs=new List<HRCSVC_Work_Order_SLA__c>();
             //enum test = HRCSVC_SLA_Management.SLA_PRIORITY.PRODUCT_MODEL_CUSTOMER;
             boolean isSLAreplaced =  HRCSVC_SLA_Management.replaceSLA(slacls, slaclsnew);

        	WorkOrder work = [SELECT id, endDate, country, ServiceTerritoryId, latitude, longitude, WorkTypeId, account.IDN_1__c, locationId, 
                              HRCFSL_Asset_Product_Family__c, HRCFSL_Asset_Product_Model__c, lastmodifieddate FROM WorkOrder LIMIT 1];
        
        	
        	HRCSVC_SLA_Management.SLAParams slaParamswo = new  HRCSVC_SLA_Management.SLAParams(work);
        	

        	HRCSVC_SLA_Management.SLAParams slaParams = new  HRCSVC_SLA_Management.SLAParams(oli,order);	
            HRCSVC_SLA_Management.getSLA(slaParams);
        	woSLA.HRCSVC_Early_Start_Time__c = null;
        	woSLA.HRCSVC_Late_Start_Time__c = null;
        	HRCSVC_SLA_Management.getSLA(woSLA, slaParams);
        	woSLA.HRCSVC_Early_Start_Time__c = time.newInstance(17,0,0,0);
        	woSLA.HRCSVC_Late_Start_Time__c = time.newInstance(0,0,0,0); 
        	woSLA.HRCSVC_Customer__c = null;
        	woSLA.HRCSVC_Pricing_Group__c = '';
        	HRCSVC_SLA_Management.getSLA(woSLA, slaParams);
        	woSLA.HRCSVC_Early_Start_Time__c = time.newInstance(0,0,0,0);
        	woSLA.HRCSVC_Late_Start_Time__c = time.newInstance(9,0,0,0);
        	woSLA.HRCSVC_Pricing_Group__c = null;
        	woSLA.HRCSVC_Super_Group__c = '';
        	HRCSVC_SLA_Management.getSLA(woSLA, slaParams);

        	woSLA.HRCSVC_Product_Family__c = null;
        	woSLA.HRCSVC_Pricing_Group__c = null;
        	woSLA.HRCSVC_Super_Group__c = null;
        	woSLA.HRCSVC_Time_From__c = null;
        	woSLA.HRCSVC_Time_To__c = null;
            woSLA.HRCSVC_Miles_From__c = null;
        	woSLA.HRCSVC_Miles_To__c = null;
			HRCSVC_SLA_Management.mySLAs.add(woSLA);
        	HRCSVC_SLA_Management.getSLA(slaParams);
        
        
            test.stopTest();
    }

    
    @isTest static void testMethodIreland(){
        HRCSVC_Work_Order_SLA__C woSLA = [SELECT HRCSVC_Customer__c FROM HRCSVC_Work_Order_SLA__C LIMIT 1];
        workType woType = [SELECT id FROM workType LIMIT 1];
        ServiceTerritory srvc = [SELECT id, latitude, longitude FROM ServiceTerritory LIMIT 1];
        srvc.latitude = 0;
        srvc.longitude = 0;
        update srvc;
        Sobject obj=[SELECT Id, hrcfsl_service_territory__c FROM Location where Id=:woSLA.HRCSVC_Customer__c limit 1];
        obj.put('hrcfsl_service_territory__c',srvc.Id); 
        update obj;
        WorkOrder work = [SELECT id, endDate, country, ServiceTerritoryId, latitude, longitude, WorkTypeId, account.IDN_1__c, locationId FROM WorkOrder LIMIT 1];
        work.country = 'Ireland';
      	work.endDate = null;
        work.ServiceTerritoryId = srvc.id;
        work.Latitude = 0;
        work.Longitude = 0;
        work.WorkTypeId = woType.id;
        work.LocationId = woSLA.HRCSVC_Customer__c;
        test.startTest();
        update work;
        test.stopTest();
        WorkOrder workUpdated = [SELECT id, endDate FROM WorkOrder LIMIT 1];
        datetime currentDay = System.now();
       // System.assertEquals(currentDay.addHours(Integer.valueOf(72)).hour(),workUpdated.endDate.hour());
    }
    
     @isTest static void testMiscScenario(){
        list<WorkOrder> worklist = [SELECT id,lastmodifieddate,HRCFSL_Asset_Product_Model__c,HRCFSL_Asset_Product_Family__c, endDate, country, ServiceTerritoryId, latitude, longitude, WorkTypeId, account.IDN_1__c, locationId FROM WorkOrder LIMIT 1];
        test.startTest();
         HRCSVC_SLA_Management.execute(worklist);
         test.stopTest();
     }
}