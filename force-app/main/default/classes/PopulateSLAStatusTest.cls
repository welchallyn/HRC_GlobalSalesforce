@isTest
public class PopulateSLAStatusTest {

    public static testmethod void populateStatusTest() {    
      /*  BMCServiceDesk__Category__c newCategory = new BMCServiceDesk__Category__c(Name='testCategory',BMCServiceDesk__AvailableForIncidents__c=true);
        insert newCategory;
        
        BMCServiceDesk__Status__c newstatus = new BMCServiceDesk__Status__c(Name='CLOSED',BMCServiceDesk__state__c = false, BMCServiceDesk__appliesToIncident__c= true);
        BMCServiceDesk__Status__c newstatus1 = new BMCServiceDesk__Status__c(Name='OPENED',BMCServiceDesk__state__c = true, BMCServiceDesk__appliesToIncident__c= true,BMCServiceDesk__defaultStatus__c=true);
        List<BMCServiceDesk__Status__c > statuses = new List<BMCServiceDesk__Status__c >();
        statuses.add(newstatus) ;
        statuses.add(newstatus1) ;
        insert statuses;
     
        BMCServiceDesk__BMC_BusinessService__c newService = new BMCServiceDesk__BMC_BusinessService__c(Name ='Test Service1');
        insert newService;
        
        BMCServiceDesk__BMC_BaseElement__c newService1 = new BMCServiceDesk__BMC_BaseElement__c(Name ='Test Service1',BMCServiceDesk__Name__c = 'Test Service1');
        insert newService1;
        
        BMCServiceDesk__BMC_BaseElement__c service = [Select Id from BMCServiceDesk__BMC_BaseElement__c where Name ='Test Service1' Limit 1];
        
        BMCServiceDesk__ServiceLevelAgreement__c newSLA = new BMCServiceDesk__ServiceLevelAgreement__c(BMCServiceDesk__AgreementTitle__c = 'Test Agreement1',
                                                     BMCServiceDesk__AgreementType__c = 'Service Level Agreement', BMCServiceDesk__FKBusinessService__c = Service.Id,
                                                     BMCServiceDesk__EffectiveFrom__c = System.NOW(), BMCServiceDesk__EffectiveUntil__c = System.NOW() + 200);                   
        insert newSLA;
        
        BMCServiceDesk__Incident__c newIncident1 = new BMCServiceDesk__Incident__c(
            BMCServiceDesk__FKClient__c= UserInfo.getUserid(), BMCServiceDesk__FKCategory__c=newCategory.id, OwnerId=UserInfo.getUserid(),BMCServiceDesk__FKBusinessService__c=service.Id);
        insert newIncident1;
        
        BMCServiceDesk__Incident__c newIncident2 = new BMCServiceDesk__Incident__c(
            BMCServiceDesk__FKClient__c= UserInfo.getUserid(), BMCServiceDesk__FKCategory__c=newCategory.id, OwnerId=UserInfo.getUserid(),BMCServiceDesk__FKBusinessService__c=service.Id);
        insert newIncident2;

        BMCServiceDesk__Incident_Service_Target__c incServiceTarget1=new BMCServiceDesk__Incident_Service_Target__c(BMCServiceDesk__FKIncident__c=newIncident1.Id,BMCServiceDesk__TargetEndDate__c=System.now().addDays(4),BMCServiceDesk__EndDate__c=System.now().addDays(6));
        BMCServiceDesk__Incident_Service_Target__c incServiceTarget2=new BMCServiceDesk__Incident_Service_Target__c(BMCServiceDesk__FKIncident__c=newIncident1.Id,BMCServiceDesk__TargetEndDate__c=System.now().addDays(1),BMCServiceDesk__EndDate__c=System.now().addDays(2));
        BMCServiceDesk__Incident_Service_Target__c incServiceTarget3=new BMCServiceDesk__Incident_Service_Target__c(BMCServiceDesk__FKIncident__c=newIncident1.Id,BMCServiceDesk__TargetEndDate__c=System.now().addDays(1),BMCServiceDesk__EndDate__c=System.now().addDays(3));
        List<BMCServiceDesk__Incident_Service_Target__c> incServieTargets=new List<BMCServiceDesk__Incident_Service_Target__c>{incServiceTarget1,incServiceTarget2,incServiceTarget3};
        insert incServieTargets;
        
        newIncident2.BMCServiceDesk__responseDateTime__c = System.now();
        update newIncident2;
        
        Test.startTest();        
        PopulateSLAStatusOnIncident p = new PopulateSLAStatusOnIncident();
         Database.executeBatch(p,1000);
        
        //p.execute(null);
        
        List<BMCServiceDesk__Incident_Service_Target__c> serviceTargets = new List<BMCServiceDesk__Incident_Service_Target__c>();
        serviceTargets = [Select Id, BMCServiceDesk__Status__c,BMCServiceDesk__FKIncident__c from BMCServiceDesk__Incident_Service_Target__c where BMCServiceDesk__FKIncident__c =: newIncident1.Id];
          
        if(serviceTargets!=null && serviceTargets.size()>0) {
             Integer countOfMet = 0;
             Integer countOfMissed = 0;     
             for(BMCServiceDesk__Incident_Service_Target__c each: serviceTargets) {
                     System.debug('Target Status' +each.BMCServiceDesk__Status__c ); 
                     if(each.BMCServiceDesk__Status__c.equalsIgnoreCase('Met')) {
                         countOfMet += 1;
                     } else if(each.BMCServiceDesk__Status__c.equalsIgnoreCase('Missed')) {
                         countOfMissed += 1;
                     }
             }
             System.debug('CountOfMissed'+countOfMissed);
             System.debug('CountOfMet'+countOfMet );
             if(countOfMet > 0 && countOfMissed > 0) {
                System.assertEquals(newIncident1.SLA_Status__c ,'ServiceTarget Breached'); 
             } else if(countOfMet > 0 && countOfMissed == 0) {
                 System.assertEquals(newIncident1.SLA_Status__c ,'Within ServiceTarget');
             } else {
                 System.assertEquals(newIncident1.SLA_Status__c ,null);
             }
        }
        Test.stopTest();   */                                                                 
    }
}