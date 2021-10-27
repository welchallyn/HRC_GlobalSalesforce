/**********************************************************************************************************************************************
* Name                             :  HRCSVC_UpdateChildWOHandler_Test
* Author                           :  Kushagra Bansal
* Date                             :  April/02/2021
* Requirement/Project Name         :  Hill-Rom
* Requirement/Project Description  :  Test class for the HRCSVC_UpdateChildWOHandler class, part of the components developed for SE-1848, SE-1980, SE-1956.
/**********************************************************************************************************************************************/
@isTest
public class HRCSVC_UpdateChildWOHandler_Test {
 @testSetup
    static void setupData() {
        worktype wtParent=HRCFSL_TestUtilityClass.createWorkTypewithSword(true,'SN_U','HRCFSL_Capital_Preventative');
        worktype wtChild=wtParent;
        ServiceTerritory stChild =  HRCFSL_TestUtilityClass.createServiceTerritory(true, 'test12345', 'My Place');
        ServiceTerritory stParent =  HRCFSL_TestUtilityClass.createServiceTerritory(true, 'test1245', 'Another Place');
        
        HRCFSL_TestUtilityClass.generateOrgExceptionCusSettingRec();
        HRCFSL_TestUtilityClass.generateAddress();
        List<WorkOrder> listOfWO = new List<WorkOrder>();
        Schema.Location locationNew = HRCFSL_TestUtilityClass.createCustomer(true, 'Customer1307');
        
        for(Integer i= 0; i < 5;i++){
            WorkOrder wo = new WorkOrder();
            wo.HRCFSL_Contact_First_Name__c = 'Test Contact';
            wo.HRCFSL_Contact_Last_Name__c = 'LastName';
            wo.HRCFSL_Contact_Phone__c = '0001001';
            wo.HRCFSL_Contact_Department__c = 'CON';
            wo.HRCFSL_Activity_Type__c = '4'; ////value before 20th Jan - M
            wo.Status = 'SC';
            wo.HRCFSL_Doc_Type__c = 'SE';//value before 20th Jan - SN
            wo.HRCFSL_Actual_End__c = System.now();
            wo.HRCFSL_PO__c = 'PO123';
            wo.HRCFSL_JDE_ID__c = 'EXT'+Math.random();
            wo.Priority = '1';
            wo.Location = locationNew;
            wo.HRCFSL_Patient_First_Name__c = 'John';
            wo.HRCFSL_Patient_Last_Name__c = 'Doe';
            wo.WorkTypeId = wtChild.ID;
            wo.ServiceTerritoryId = stChild.Id;
            wo.HRCFSL_Signee_Email__c = '';
            wo.HRCFSL_Signee_Name__c = '';
            wo.HRCFSL_Signee_Title__c = '';
            if(i==0){
                wo.ServiceTerritoryId=stParent.Id;
                wo.WorkTypeId = wtParent.Id;
                wo.HRCFSL_Signee_Email__c = 'temp@temp.com';
                wo.HRCFSL_Signee_Name__c = 'temp';
                wo.HRCFSL_Signee_Title__c = 'temp';
            }
            
            listOfWO.add(wo);
        }
        if(!listOfWO.isEmpty()){
            insert listOfWO;
        }
        
        List<WorkOrder> listOfWOUpd = new List<WorkOrder>();
        for(Integer i= 1; i < 5;i++){
            WorkOrder wo = new WorkOrder();
            wo = listOfWO[i];
            wo.ParentWorkOrderId = listOfWO[0].Id;
            wo.HRCFSL_Signee_Email__c = '';
            wo.HRCFSL_Signee_Name__c = '';
            wo.HRCFSL_Signee_Title__c = '';
            listOfWOUpd.add(wo);
        }
        
        update listOfWOUpd;
        
    }
    @isTest
    static void testupdateWoSTWT() {
        ServiceTerritory stChild = [select id from ServiceTerritory where name = 'My Place' LIMIT 1];
        List<WorkOrder> wosAllChild = [Select Id,ServiceTerritoryId,WorkTypeId from WorkOrder where ParentWorkOrderId != null];
        System.debug(wosAllChild );
        for(WorkOrder woAll: wosAllChild) {
            System.assertEquals(stChild.Id, woAll.ServiceTerritoryId, 'All children\'s ST should not be equal to parent\'s ST');
        }
        
        List<WorkOrder> wos = [Select Id from WorkOrder where ParentWorkOrderId = null]; 
        List<HRCSVC_UpdateChildWOHandler.UpdateChildWOInput> pbinput = new List<HRCSVC_UpdateChildWOHandler.UpdateChildWOInput>();
        HRCSVC_UpdateChildWOHandler.UpdateChildWOInput obj = new HRCSVC_UpdateChildWOHandler.UpdateChildWOInput();
        List<Id> woidlist = new List<Id>();
        for(WorkOrder wo:wos){
            woidlist.add(wo.Id);            
        }
        obj.ListparentWOID = woidlist;
        obj.pbtitle = 'woactions';
        pbinput.add(obj);
        Test.startTest();
        List<String> st =  HRCSVC_UpdateChildWOHandler.updateWorkOrders(pbinput);
        Test.stopTest();
        ServiceTerritory stParent = [select id from ServiceTerritory where name = 'Another Place' LIMIT 1];
        List<WorkOrder> wosAll = [Select Id,ServiceTerritoryId,WorkTypeId from WorkOrder];
        System.debug(wosAll);
        /*for(WorkOrder woAll: wosAll){
            System.assertEquals(stParent.Id, woAll.ServiceTerritoryId, 'All children\'s ST should be equal to parent\'s ST');
      }	*/	
    }
    
     @isTest
    static void testupdateWoChildWo() {
       
        List<WorkOrder> wos = [Select Id from WorkOrder where ParentWorkOrderId = null]; 
        List<HRCSVC_UpdateChildWOHandler.UpdateChildWOInput> pbinput = new List<HRCSVC_UpdateChildWOHandler.UpdateChildWOInput>();
        HRCSVC_UpdateChildWOHandler.UpdateChildWOInput obj = new HRCSVC_UpdateChildWOHandler.UpdateChildWOInput();
        List<Id> woidlist = new List<Id>();
        for(WorkOrder wo:wos){
            woidlist.add(wo.Id);            
        }
        obj.ListparentWOID = woidlist;
        obj.pbtitle = 'saonwo';
        pbinput.add(obj);
        Test.startTest();
        List<String> st =  HRCSVC_UpdateChildWOHandler.updateWorkOrders(pbinput);
        Test.stopTest();
       
        List<WorkOrder> wosAll = [Select Id,HRCFSL_Signee_Email__c from WorkOrder];
        System.debug(wosAll);
        /*for(WorkOrder woAll: wosAll){
            System.assertEquals('temp@temp.com', woAll.HRCFSL_Signee_Email__c, 'All children\'s signee email should be equal to parent\'s ST');
          }	*/	
    }

    @isTest
    static void testraiseChildWOEvents() {
        List<WorkOrder> wos = [Select Id from WorkOrder where ParentWorkOrderId = null]; 
        List<HRCSVC_UpdateChildWOHandler.UpdateChildWOInput> pbinput = new List<HRCSVC_UpdateChildWOHandler.UpdateChildWOInput>();
        HRCSVC_UpdateChildWOHandler.UpdateChildWOInput obj = new HRCSVC_UpdateChildWOHandler.UpdateChildWOInput();
        List<Id> woidlist = new List<Id>();
        for(WorkOrder wo:wos){
            woidlist.add(wo.Id);            
        }
        obj.ListparentWOID = woidlist;
        obj.pbtitle = 'saonwochild';
        pbinput.add(obj);
        Test.startTest();
        List<String> st =  HRCSVC_UpdateChildWOHandler.updateWorkOrders(pbinput);
        Test.stopTest();
       
    }
    
}