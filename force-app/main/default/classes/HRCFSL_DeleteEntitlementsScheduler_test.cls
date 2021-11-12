/***********************************************************************************************
 * Name                             : HRCFSL_DeleteEntitlementsScheduler_test
 s
 * Author                           : Anchal Garg 
 * Date                             : August/13/2019
 * Requirement/Project Name         : Hill-Rom
 * Requirement/Project Description  :  Test class for Scheduled apex
 *                                   1. HF-251 that runs nightly at 3am Amsterdam time that deletes all Entitlements
 *                                      such that EndDate < (TODAY - 90) && RecordType = HRC Service Entitlement
 * Revison                          :
/***********************************************************************************************/
@isTest
public class HRCFSL_DeleteEntitlementsScheduler_test {
	 @testsetup
  public static void createTestData() {
     account acc = new account();
      acc.name='test Account9843';
      acc.jde_external_id__c='342133';
     insert acc;
      Entitlement ent = new Entitlement();
       ent=HRCFSL_TestUtilityClass.createEntitlement(true,'test Entitlement',date.today()-130,date.today()-120 ,acc.id);
      ent = new Entitlement();
     ent=HRCFSL_TestUtilityClass.createEntitlement(true,'test Entitlement 11',date.today()-40,date.today()-30 ,acc.id);
     /*Entitlement ent = new Entitlement();
     ent.name='test Entitlement';
     ent.startdate=date.today()-130;
     ent.enddate=date.today()-120;
     ent.accountid=acc.id;
     insert ent;
     ent = new Entitlement();
     ent.name='test Entitlement 11';
     ent.startdate=date.today()-40;
     ent.enddate=date.today()-30;
     ent.accountid=acc.id;
     insert ent;*/
  }

  @isTest
    static void testinsertnUpdateMembers(){
    	list<entitlement> entlst =[select id from entitlement where name like 'test%'];
        system.assertEquals(entlst.size(), 2);
        HRCFSL_DeleteEntitlementsScheduler DES = new HRCFSL_DeleteEntitlementsScheduler();
        des.execute(null);
        entlst =[select id from entitlement where name like 'test%'];
        system.assertEquals(entlst.size(), 1);

    }
}