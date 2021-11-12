@isTest(SeeAllData=true)
public with sharing class PopulateActualStartDateEndDateTest {
    
    public static testMethod void TestTrigger() {
        
        Test.startTest();
        
        Id PlanID = [select id from BMCServiceDesk__Status__c where Name='PLAN+SCHEDULE' LIMIT 1].Id;
        Id ImplementID = [select id from BMCServiceDesk__Status__c where Name='IMPLEMENT' LIMIT 1].Id;
        Id ReviewId= [select id from BMCServiceDesk__Status__c where Name='REVIEW+AUTHORIZATION' LIMIT 1].Id;
        Id CompletedId = [select id from BMCServiceDesk__Status__c where Name='COMPLETED' LIMIT 1].Id;
        Id ClosedId = [select id from BMCServiceDesk__Status__c where Name='CLOSED' LIMIT 1].Id;
        
        BMCServiceDesk__Change_Request__c newCR = new BMCServiceDesk__Change_Request__c(BMCServiceDesk__FKStatus__c = PlanID, Plan_Approved__c = 2, BMCServiceDesk__FKInitiator__c=UserInfo.getUserid(), BMCServiceDesk__Change_Type__c = 'Emergency', Product_Catalog_Tier_1__c = 'Server', Product_Catalog_Tier_2__c = 'Unix');
        insert newCR; 
        BMCServiceDesk__Task__c newTask = new  BMCServiceDesk__Task__c(BMCServiceDesk__FKChange__c=newCR.id);
        insert newTask;
        newCR.BMCServiceDesk__FKStatus__c = ImplementID;
        newCR.Approver1__c = UserInfo.getUserid();
        update newCR;
        newCR.BMCServiceDesk__FKStatus__c = ReviewId;
      	update newCR;      
        BMCServiceDesk__Change_Request__c newCR6 = new BMCServiceDesk__Change_Request__c(BMCServiceDesk__FKStatus__c = ReviewId, Plan_Approved__c = 2, Review_Approved__C=2, BMCServiceDesk__FKInitiator__c=UserInfo.getUserid(), BMCServiceDesk__Change_Type__c = 'Emergency', Product_Catalog_Tier_1__c = 'Server', Product_Catalog_Tier_2__c = 'Unix');
        insert newCR6; 
        BMCServiceDesk__Task__c newTask5 = new  BMCServiceDesk__Task__c(BMCServiceDesk__FKChange__c=newCR6.id);
        insert newTask5;
        newCR6.Approver1__c = UserInfo.getUserid();
        newCR6.BMCServiceDesk__FKStatus__c = CompletedID;
        update newCR6;
        
        
         BMCServiceDesk__Change_Request__c newCR3 = new BMCServiceDesk__Change_Request__c(BMCServiceDesk__FKStatus__c = PlanID, Plan_Approved__c = 2, BMCServiceDesk__FKInitiator__c=UserInfo.getUserid(), BMCServiceDesk__Change_Type__c = 'Normal', Product_Catalog_Tier_1__c = 'Server', Product_Catalog_Tier_2__c = 'Unix');
        insert newCR3; 
        
        BMCServiceDesk__Task__c newTask1 = new  BMCServiceDesk__Task__c(BMCServiceDesk__FKChange__c=newCR3.id);
        insert newTask1;
  
        newCR3.BMCServiceDesk__FKStatus__c = ImplementID;
		newCR3.Approver1__c = UserInfo.getUserid();
        update newCR3;
        newCR3.Implement_Approved__c=1;
     	newCR3.BMCServiceDesk__FKStatus__c = CompletedId;
        update newCR3;
        
        BMCServiceDesk__Change_Request__c newCR1 = new BMCServiceDesk__Change_Request__c(BMCServiceDesk__FKStatus__c = PlanID, Plan_Approved__c = 2, BMCServiceDesk__FKInitiator__c=UserInfo.getUserid(), BMCServiceDesk__Change_Type__c = 'Standard', Product_Catalog_Tier_1__c = 'Server', Product_Catalog_Tier_2__c = 'Unix');
        insert newCR1; 
         BMCServiceDesk__Task__c newTask2 = new  BMCServiceDesk__Task__c(BMCServiceDesk__FKChange__c=newCR1.id);
        insert newTask2;
       
        newCR1.Approver1__c = UserInfo.getUserid();
        newCR1.BMCServiceDesk__FKStatus__c = ImplementID;
        update newCR1;
      
        BMCServiceDesk__Change_Request__c newCR4 = new BMCServiceDesk__Change_Request__c(BMCServiceDesk__FKStatus__c = ImplementID, Plan_Approved__c = 2, Implement_Approved__c=2, BMCServiceDesk__FKInitiator__c=UserInfo.getUserid(), BMCServiceDesk__Change_Type__c = 'Standard', Product_Catalog_Tier_1__c = 'Server', Product_Catalog_Tier_2__c = 'Unix');
        insert newCR4; 
         BMCServiceDesk__Task__c newTask3 = new  BMCServiceDesk__Task__c(BMCServiceDesk__FKChange__c=newCR4.id);
        insert newTask3;
        
        newCR4.Approver1__c = UserInfo.getUserid();
        newCR4.BMCServiceDesk__FKStatus__c = CompletedId;
        update newCR4;
        
        BMCServiceDesk__Change_Request__c newCR5 = new BMCServiceDesk__Change_Request__c(BMCServiceDesk__FKStatus__c = PlanID, Plan_Approved__c = 2, BMCServiceDesk__FKInitiator__c=UserInfo.getUserid(), BMCServiceDesk__Change_Type__c = 'Normal with Close Down', Product_Catalog_Tier_1__c = 'Server', Product_Catalog_Tier_2__c = 'Unix');
        insert newCR5; 
         BMCServiceDesk__Task__c newTask4 = new  BMCServiceDesk__Task__c(BMCServiceDesk__FKChange__c=newCR5.id);
        insert newTask4;
        
        newCR5.BMCServiceDesk__FKStatus__c = ImplementID;
		newCR5.Approver1__c = UserInfo.getUserid();
        update newCR5;
        newCR5.Implement_Approved__c=1;
     	newCR5.BMCServiceDesk__FKStatus__c = CompletedId;
        update newCR5;
        
        BMCServiceDesk__Change_Request__c newCR7 = new BMCServiceDesk__Change_Request__c(BMCServiceDesk__FKStatus__c = ReviewId, Plan_Approved__c = 2, Review_Approved__C=2, BMCServiceDesk__FKInitiator__c=UserInfo.getUserid(), BMCServiceDesk__Change_Type__c = 'Standard', Product_Catalog_Tier_1__c = 'Server', Product_Catalog_Tier_2__c = 'Unix');
        insert newCR7; 
        BMCServiceDesk__Task__c newTask6 = new  BMCServiceDesk__Task__c(BMCServiceDesk__FKChange__c=newCR7.id);
        insert newTask6;
        newCR7.Approver1__c = UserInfo.getUserid();
        newCR7.BMCServiceDesk__FKStatus__c = CompletedID;
        update newCR7;
        newCR7.Completed_Approved__c=2;
        newCR7.BMCServiceDesk__FKStatus__c = ClosedId;
        update newCR7;
        
        BMCServiceDesk__Change_Request__c newCR2 = [select Id, BMCServiceDesk__Actual_Start_Date__c from BMCServiceDesk__Change_Request__c where Id=:newCR.Id limit 1];
        DateTime actualStartDateTime = newCR2.BMCServiceDesk__Actual_Start_Date__c;
        Date actualStartDate= Date.newInstance(actualStartDateTime.year(),actualStartDateTime.month(),actualStartDateTime.day());
        System.assertEquals(actualStartDate, System.today()); 
        
      /* //Closing the associated task
        BMCServiceDesk__Status__c taskClosedStatus= [Select id from BMCServiceDesk__Status__c where BMCServiceDesk__state__c = FALSE and BMCServiceDesk__appliesToTask__c=true and BMCServiceDesk__inactive__c=false limit 1];
        newTask.BMCServiceDesk__FKStatus__c = taskClosedStatus.Id;
        update newTask;
        
        BMCServiceDesk__Status__c status2 = [Select id from BMCServiceDesk__Status__c where BMCServiceDesk__state__c = FALSE and BMCServiceDesk__appliesToChange__c=true and BMCServiceDesk__inactive__c=false limit 1];
        
        newCR1.BMCServiceDesk__FKStatus__c = status2.id;
        update newCR1;
        
        newCR1 = [select Id, BMCServiceDesk__Actual_Start_Date__c, BMCServiceDesk__Actual_End_Date__c from BMCServiceDesk__Change_Request__c where Id=:newCR1.Id limit 1];
        DateTime actualEndDateTime = newCR1.BMCServiceDesk__Actual_End_Date__c;
        Date actualEndDate= Date.newInstance(actualEndDateTime.year(),actualEndDateTime.month(),actualEndDateTime.day());
        System.assertEquals(actualEndDate, System.today()); */
        Test.stopTest();

    }    
    
      
}