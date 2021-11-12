@IsTest (seeAllData=true)
public class ItemsToApproveControllerTest {

    public static testmethod void getApprovalItemsTest() {
        ItemsToApproveController itac = new ItemsToApproveController();

        BMCServiceDesk__Category__c newCategory = new BMCServiceDesk__Category__c(Name='testCategory',BMCServiceDesk__AvailableForIncidents__c=true);
        insert newCategory;
 
        /*BMCServiceDesk__Incident__c newIncident = new BMCServiceDesk__Incident__c(
            BMCServiceDesk__FKClient__c= UserInfo.getUserid() , BMCServiceDesk__FKCategory__c=newCategory.id);
        insert newIncident;*/
        
        BMCServiceDesk__Incident__c newIncident = new BMCServiceDesk__Incident__c(BMCServiceDesk__FKClient__c= UserInfo.getUserid() , BMCServiceDesk__FKCategory__c=newCategory.id, Operational_Catalog_Tier_1__c='Install/Add/Create',Operational_Catalog_Tier_2__c='Security',Product_Catalog_Tier_2__c='GEMINI', OwnerId=UserInfo.getUserid());
        insert newIncident;
        
    
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval automatically');
        req1.setObjectId(newIncident.id);
        req1.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        // Submit the approval request for the Incident
        Approval.ProcessResult result = Approval.process(req1);
        
      
        PaginationController pc = new PaginationController(itac);
        pc.nextPage();
    }

        

}