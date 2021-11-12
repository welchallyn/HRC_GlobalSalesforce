@isTest
public class ClosureQuestionnaireExtensionTest {
    
    public static testMethod void closureQuestionnaireTest(){
        BMCServiceDesk__Status__c status = new BMCServiceDesk__Status__c();
        status.Name = 'INITIATE';
        status.BMCServiceDesk__inactive__c = false;
        status.BMCServiceDesk__appliesToChange__c = true;        
        insert status;
        BMCServiceDesk__Change_Request__c brRequest = new BMCServiceDesk__Change_Request__c();
        brRequest.BMCServiceDesk__FKStatus__c = status.Id;
        brRequest.Is_this_an_Emergency_Change__c = 'Yes';
        insert brRequest;
        Test.StartTest(); 
			ApexPages.StandardController sc = new ApexPages.StandardController(brRequest);
            ClosureQuestionnaireExtension cq = new ClosureQuestionnaireExtension(sc);
            cq.saveAndRedirect();
		Test.StopTest();
    }

}