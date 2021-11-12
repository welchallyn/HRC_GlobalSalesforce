/*************************************************************************************************
 * Class Name                       : HRCFSL_SrviceTrtryMmbrTrgr_Hndlr_test 
 * Author                           : Capgemini
 * Date                             : 06/21/2019
 * Description                      : test class for Trigger HRCFSL_ServiceTerritoryMember_trigger and 
 *                                      HRCFSL_SrviceTeritryMmbrTrgr_Handler class
 *************************************************************************************************/
@isTest
public class HRCFSL_SrviceTrtryMmbrTrgr_Hndlr_test {
	 @testsetup
  public static void createTestData() {
     ServiceTerritory st=HRCFSL_TestUtilityClass.createServiceTerritory(true,'test India','Delhi');
     list<user> usrlst= HRCFSL_TestUtilityClass.createUsers(true,'HRC Field Service Engineer' , 2);
     list<ServiceResource> srlst=HRCFSL_TestUtilityClass.createServiceResources(true,usrlst);
  }
  
  @isTest
    static void testinsertnUpdateMembers(){
    	ServiceTerritory st = [select id,name from ServiceTerritory limit 1];
    	list<ServiceResource> srlst=[select id,Name,RelatedRecordId from ServiceResource order by createddate desc];
    	list<user> userlst = [select id,name from user order by createddate desc];
    	test.startTest();
    		ServiceTerritoryMember stm = new ServiceTerritoryMember();
    		stm.ServiceResourceId=srlst[0].id;
    		stm.ServiceTerritoryId=st.id;
    		stm.TerritoryType='P';
    		stm.HRCFSL_Paging_Team__c='DV;LV';
            stm.EffectiveStartDate=datetime.now().addDays(-2);
            //stm.HRCFSL_External_ID__c='test';
            insert stm;
            stm =[select id,HRCFSL_Paging_Team__c,HRCFSL_Service_Resource_User__c,HRCFSL_Paging_Team_Members__c,ServiceResource.RelatedRecordId from ServiceTerritoryMember where id=:stm.id];
            system.assertEquals(stm.HRCFSL_Paging_Team_Members__c,stm.HRCFSL_Paging_Team__c);
            system.assertEquals(stm.HRCFSL_Service_Resource_User__c,stm.ServiceResource.RelatedRecordId);
            stm.HRCFSL_Paging_Team__c='DV';
            //stm.ServiceResourceId=srlst[1].id;
            update stm;
            stm =[select id,HRCFSL_Paging_Team__c,HRCFSL_Service_Resource_User__c,HRCFSL_Paging_Team_Members__c,ServiceResource.RelatedRecordId from ServiceTerritoryMember where id=:stm.id];
            system.assertEquals(stm.HRCFSL_Paging_Team_Members__c,stm.HRCFSL_Paging_Team__c);

    	test.stopTest();
    }
  
}