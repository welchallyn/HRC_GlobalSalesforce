@isTest(seeAllData=true)
public class NextStageLightningControllerTest{

  //Test for ChangeType Normal
  public static testmethod void NextStageTest() {
     test.StartTest();
     BMCServiceDesk__Change_Request__c changeRecord = new BMCServiceDesk__Change_Request__c(BMCServiceDesk__FKInitiator__c=UserInfo.getUserid(), BMCServiceDesk__Change_Type__c = 'Normal', Support_Group_Name__c = 'HRC-DBA-CHGMGR');
     insert changeRecord; 
     try {
     NextStageLightningController ns1 = new NextStageLightningController();
     BMCServiceDesk__Change_Request__c cr1 = NextStageLightningController.getChangeRequest(changeRecord.Id);
     } catch(Exception e) {
         System.debug('Exception '+e);
     }
     
     test.StopTest();
    }
}