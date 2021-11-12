/*******************************************************************************************************
* Name                             : HRCFSL_PmPdiControllerTest
* Author                           : Capgemini
* Date                             : August/30/2020
* Requirement/Project Name         : Hill-Rom
* Requirement/Project Description  : 1.test class for HRCFSL_PmPdiController which is used with Lightning Web component
*									  pmPdi for creating WO to be used by bar code scanner.	
									  Created for #SE-346
* Revison                          :
/*******************************************************************************************************/
@isTest
public with sharing class HRCFSL_PmPdiControllerTest {
    @testSetUp
    public static void createTestData(){
        //create user
        List<User> usrList = HRCFSL_TestUtilityClass.createUsers(true,'System Administrator',1);   
        usrList[0].JDE_External_Id__c = 'EXTERNAL8796009';
        update usrList[0];
        //create Asset along with location
        Schema.Location loc = HRCFSL_TestUtilityClass.createCustomer(true, 'EXT-7474');
        Asset createAsset = HRCFSL_TestUtilityClass.createAsset(true);
        createAsset.Name = '234567';
        createAsset.SerialNumber = '234567';
        createAsset.HRCFSL_Model_Description__c = 'Text Asset';
        createAsset.HRCFSL_Next_PM_DT__c = System.today();
        createAsset.LocationId = loc.Id;
        createAsset.HRCFSL_Active__c = true;
        update createAsset;
        //create worktype + sword rule
        worktype wt=HRCFSL_TestUtilityClass.createWorkTypewithSword(true,'SQ_U','HRCFSL_Capital_Other');
     }
	@isTest
    public static void testMethodToCoverALl(){
        list<Asset> createAssetlist = new list<Asset>();
        List<workorder> wolist=new list<workorder>();
        createAssetlist=[select id from asset order by createddate desc limit 1];
        list<user> userlist=new list<user>();
        userlist = [select id from user where JDE_External_Id__c='EXTERNAL8796009' limit 1];
        test.startTest();        	
            Asset ast = HRCFSL_PmPdiController.getAsset('234567');
            system.assertequals(ast.SerialNumber,'234567');
            User usr=HRCFSL_PmPdiController.getTechnician('EXTERNAL8796009');
            system.assertequals(usr.id,userlist[0].id);
            string woid=HRCFSL_PmPdiController.getWorkOrderId('234567');
             system.assertequals(woid,null);
            string wonum=HRCFSL_PmPdiController.createWorkOrder(createAssetlist[0].ID,userlist[0].ID, 'best tech', 'Apec', 'Inspection Type');
             wolist = [Select id,WorkOrderNumber from workorder order by createddate desc limit 1];
             system.assertequals(wonum,wolist[0].WorkOrderNumber);
            List<HRCFSL_Inspection_Step__c> stepslist=HRCFSL_PmPdiController.getPmPdiSteps(wolist[0].Id);
            system.assertequals(stepslist.size(),3);
        test.stopTest();        
    }
}