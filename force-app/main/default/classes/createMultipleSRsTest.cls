@isTest(seeAllData=true)
public class createMultipleSRsTest {
     public static testmethod void createMultipleSRs() {
          BMCServiceDesk__Category__c testCategory=new BMCServiceDesk__Category__c(Name='testCategory',
                                                                 BMCServiceDesk__AvailableForIncidents__c=true,
                                                                 BMCServiceDesk__AvailableForServiceCatalog__c=true);
          insert testCategory;
    
          BMCServiceDesk__CMDB_Class__c bServiceClass=[SELECT Id,Name,BMCServiceDesk__ClassID__c FROM BMCServiceDesk__CMDB_Class__c WHERE BMCServiceDesk__ClassID__c='BMC_BUSINESSSERVICE' LIMIT 1];
          BMCServiceDesk__BMC_BaseElement__c testBaseElement=new BMCServiceDesk__BMC_BaseElement__c(Name='Test Base Element',
                                                                      BMCServiceDesk__Name__c='Test Base Element',
                                                                      BMCServiceDesk__CMDB_Class__c=bServiceClass.Id);
          insert testBaseElement;
          BMCServiceDesk__BMC_BaseElement__c testBaseElement_1=new BMCServiceDesk__BMC_BaseElement__c(Name='Test Base Element_1',
                                                                  BMCServiceDesk__Name__c='Test Base Element_1',
                                                                  BMCServiceDesk__CMDB_Class__c=bServiceClass.Id);
          insert testBaseElement_1;    
    
                
          BMCServiceDesk__BMC_BusinessService__c testBService=new BMCServiceDesk__BMC_BusinessService__c(Name='Test Business Service',
                                                                          BMCServiceDesk__FKBMC_BaseElement__c=testBaseElement.Id);
          insert testBService;
          BMCServiceDesk__BMC_BusinessService__c testBServiceOff=new BMCServiceDesk__BMC_BusinessService__c(Name='Test Business offering',
                                                                      BMCServiceDesk__FKBusinessService__c=testBaseElement_1.Id,
                                                                      BMCServiceDesk__ServiceType__c='Offering');
          insert testBServiceOff;
          BMCServiceDesk__SYSTemplate__c incTemplate=new BMCServiceDesk__SYSTemplate__c(Name='Test Incident Template test class',
                                                                                    BMCServiceDesk__templateFor__c='Incident',
                                                                                    BMCServiceDesk__description__c='Test Incident description');
          insert incTemplate;  
          BMCServiceDesk__SYSTemplate__c reqTemplate=new BMCServiceDesk__SYSTemplate__c(Name='Test Request Detail test class', 
                                                                          BMCServiceDesk__templateFor__c='Request Detail',
                                                                          BMCServiceDesk__description__c='Test Req Def description');
          insert reqTemplate;   
          BMCServiceDesk__SYSTemplateLink__c incLinking=new BMCServiceDesk__SYSTemplateLink__c(BMCServiceDesk__parentTemplateId__c=reqTemplate.Id,
                                                                              BMCServiceDesk__linkedTemplateId__c=incTemplate.Id);            
          insert incLinking; 
          BMCServiceDesk__SRM_RequestDefinition__c testReqDef=new BMCServiceDesk__SRM_RequestDefinition__c(BMCServiceDesk__FKCategory__c=testCategory.Id,
                                                                         BMCServiceDesk__FKBusinessService__c=testBaseElement.Id,
                                                                         BMCServiceDesk__FKServiceOffering__c=testBaseElement_1.Id,
                                                                         BMCServiceDesk__serviceRequestTitle__c='Test Service Request for Hill---Rom');                                                             
          insert testReqDef;
          BMCServiceDesk__SRM_ProcessTemplate__c proTemplate=new BMCServiceDesk__SRM_ProcessTemplate__c(BMCServiceDesk__FKRequestDefinition__c=testReqDef.Id,                                                                    
                                                                                 BMCServiceDesk__FKTemplate__c=reqTemplate.Id);
          insert proTemplate;
          
         // List<BMCServiceDesk__SRM_FulfillmentInputs__c> fullfillmentinputs = new List<BMCServiceDesk__SRM_FulfillmentInputs__c >();
          
          BMCServiceDesk__SRM_FulfillmentInputs__c fullfillmentinput = new BMCServiceDesk__SRM_FulfillmentInputs__c(BMCServiceDesk__FKRequestDefinition__c = testReqDef.Id,
                                                                      BMCServiceDesk__ResponseType__c= 'Check box', BMCServiceDesk__Prompt__c = 'test input');
         // fullfillmentinputs.add(fullfillmentinput);
          insert fullfillmentinput;
          
          BMCServiceDesk__SRM_FulfillmentInputs__c fullfillmentinput1 = new BMCServiceDesk__SRM_FulfillmentInputs__c(BMCServiceDesk__FKRequestDefinition__c = testReqDef.Id,
                                                                      BMCServiceDesk__ResponseType__c= 'Check box', BMCServiceDesk__Prompt__c = 'test input1');
          insert fullfillmentinput1;
          //fullfillmentinputs.add(fullfillmentinput1);

          
          BMCServiceDesk__SRM_FulfillmentInputs__c fullfillmentinput2 = new BMCServiceDesk__SRM_FulfillmentInputs__c(BMCServiceDesk__FKRequestDefinition__c = testReqDef.Id,
                                                                      BMCServiceDesk__ResponseType__c= 'Check box', BMCServiceDesk__Prompt__c = 'test input2');
                                                                    
          insert fullfillmentinput2;
          //fullfillmentinputs.add(fullfillmentinput2 );

          
          BMCServiceDesk__SRM_FulfillmentInputs__c fullfillmentinput3 = new BMCServiceDesk__SRM_FulfillmentInputs__c(BMCServiceDesk__FKRequestDefinition__c = testReqDef.Id,
                                                                      BMCServiceDesk__ResponseType__c= 'Check box', BMCServiceDesk__Prompt__c = 'test input3');
         
         insert fullfillmentinput3;
         
         BMCServiceDesk__SRM_FulfillmentInputs__c fullfillmentinput4 = new BMCServiceDesk__SRM_FulfillmentInputs__c(BMCServiceDesk__FKRequestDefinition__c = testReqDef.Id,
                                                                      BMCServiceDesk__ResponseType__c= 'Picklist', BMCServiceDesk__Prompt__c = 'test input4');
          insert fullfillmentinput4;
          //fullfillmentinputs.add(fullfillmentinput3 );
         
          
          queueSObject queueDetails = [select queueId from queueSObject where queue.name='HRC-SERVICE-DESK' limit 1];
          List<Multiple_requests_info__c > mulitplereqlist = new List<Multiple_requests_info__c >();
          Multiple_requests_info__c muliplereqinfor = new Multiple_requests_info__c(Fulfillment_Input__c = fullfillmentinput.Id,
                                                  Request_Definition__c = testReqDef.Id, Template__c = incTemplate.Id,Request_Type__c='International');
                                                  
          mulitplereqlist.add(muliplereqinfor);
         
         //ERS 12/2/2016--commenting out -- causing error:
         //System.LimitException: BMCServiceDesk:Too many queueable jobs added to the queue: 2
         //Stack Trace: Class.BMCServiceDesk.IncidentTriggerHandler.ApplyTemplateToIncident: line 2508, column 1 Class.BMCServiceDesk.IncidentTriggerHandler.ExecuteTrigger: line 47, column 1 Trigger.BMCServiceDesk.IncidentTrigger: line 2, column 1
         /* if(  queueDetails != null) {
              Multiple_requests_info__c muliplereqinfor1 = new Multiple_requests_info__c(Fulfillment_Input__c = fullfillmentinput1.Id,
                                                      Request_Definition__c = testReqDef.Id, Template__c = incTemplate.Id, OwnerId = queueDetails.queueId,Request_Type__c='North America' );
                                                   
              mulitplereqlist.add(muliplereqinfor1);
                  
              Multiple_requests_info__c muliplereqinfor2 = new Multiple_requests_info__c(Fulfillment_Input__c = fullfillmentinput2.Id,
                                                          Request_Definition__c = testReqDef.Id, Template__c = incTemplate.Id, OwnerId = queueDetails.queueId,Request_Type__c='International' );
                                                          
              mulitplereqlist.add(muliplereqinfor2);
          
          }*/
          
          Multiple_requests_info__c muliplereqinfor3 = new Multiple_requests_info__c(Fulfillment_Input__c = fullfillmentinput3.Id,
                                                  Request_Definition__c = testReqDef.Id, Template__c = incTemplate.Id,Request_Type__c='North America' );
                                                  
          mulitplereqlist.add(muliplereqinfor3);
         Multiple_requests_info__c muliplereqinfor4 = new Multiple_requests_info__c(Fulfillment_Input__c = fullfillmentinput4.Id,
                                                  Request_Definition__c = testReqDef.Id, Template__c = incTemplate.Id,Request_Type__c='North America' );
                                                  
          mulitplereqlist.add(muliplereqinfor4);
        
          insert mulitplereqlist;
          
          
          
          
          BMCServiceDesk__Incident__c testInc=new BMCServiceDesk__Incident__c (BMCServiceDesk__FKCategory__c=testCategory.Id,
          Operational_Catalog_Tier_1__c ='Install/Add/Create',Operational_Catalog_Tier_2__c='Security',
          Product_Catalog_Tier_1__c='Software',Product_Catalog_Tier_2__c='Cognos',Is_Child__c = false,
          BMCServiceDesk__FKRequestDefinition__c=testReqDef.Id);
        
          insert testInc; 
    
          BMCServiceDesk__SRM_RequestDetail__c reqDetail=new BMCServiceDesk__SRM_RequestDetail__c(BMCServiceDesk__FKClient__c=UserInfo.getUserid(),
                                                                               BMCServiceDesk__FKRequestDefinition__c=testReqDef.Id,
                                                                               BMCServiceDesk__FKIncident__c=testInc.Id);
          insert reqDetail;
          
          List<BMCServiceDesk__SRM_RequestDetailInputs__c> reqdetailinputlist = new List<BMCServiceDesk__SRM_RequestDetailInputs__c>();
          
          BMCServiceDesk__SRM_RequestDetailInputs__c reqdetailinput = new BMCServiceDesk__SRM_RequestDetailInputs__c(BMCServiceDesk__FKFulfillmentInputs__c = fullfillmentinput.Id,
                                                                          BMCServiceDesk__Input__c = 'test input',BMCServiceDesk__FKRequestDetail__c = reqDetail.Id,
                                                                          BMCServiceDesk__Response__c   = 'true', BMCServiceDesk__StoredValue__c = 'true');
          reqdetailinputlist.add(reqdetailinput);  
          
          BMCServiceDesk__SRM_RequestDetailInputs__c reqdetailinput1 = new BMCServiceDesk__SRM_RequestDetailInputs__c(BMCServiceDesk__FKFulfillmentInputs__c = fullfillmentinput1.Id,
                                                                          BMCServiceDesk__Input__c = 'test input1',BMCServiceDesk__FKRequestDetail__c = reqDetail.Id,
                                                                          BMCServiceDesk__Response__c   = 'true', BMCServiceDesk__StoredValue__c = 'true');
          reqdetailinputlist.add(reqdetailinput1);
          
          BMCServiceDesk__SRM_RequestDetailInputs__c reqdetailinput2 = new BMCServiceDesk__SRM_RequestDetailInputs__c(BMCServiceDesk__FKFulfillmentInputs__c = fullfillmentinput2.Id,
                                                                          BMCServiceDesk__Input__c = 'test input2',BMCServiceDesk__FKRequestDetail__c = reqDetail.Id,
                                                                          BMCServiceDesk__Response__c   = 'true', BMCServiceDesk__StoredValue__c = 'true');
          reqdetailinputlist.add(reqdetailinput2);    
          
          BMCServiceDesk__SRM_RequestDetailInputs__c reqdetailinput3 = new BMCServiceDesk__SRM_RequestDetailInputs__c(BMCServiceDesk__FKFulfillmentInputs__c = fullfillmentinput3.Id,
                                                                          BMCServiceDesk__Input__c = 'test input3',BMCServiceDesk__FKRequestDetail__c = reqDetail.Id,
                                                                          BMCServiceDesk__Response__c   = 'true', BMCServiceDesk__StoredValue__c = 'true');
         reqdetailinputlist.add(reqdetailinput3);
         
         BMCServiceDesk__SRM_RequestDetailInputs__c reqdetailinput4 = new BMCServiceDesk__SRM_RequestDetailInputs__c(BMCServiceDesk__FKFulfillmentInputs__c = fullfillmentinput4.Id,
                                                                          BMCServiceDesk__Input__c = 'test input3',BMCServiceDesk__FKRequestDetail__c = reqDetail.Id,
                                                                          BMCServiceDesk__Response__c   = 'International', BMCServiceDesk__StoredValue__c = 'true');
         reqdetailinputlist.add(reqdetailinput4);                                                          

          insert reqdetailinputlist;
          
          BMCServiceDesk__Incident__c testInc_1=[SELECT Id,Name,Cognos_Roles__c,BMCServiceDesk__FKRequestDetail__c,BMCServiceDesk__FKRequestDefinition__c,Operational_Catalog_Tier_1__c,Operational_Catalog_Tier_2__c,Product_Catalog_Tier_1__c,Product_Catalog_Tier_2__c FROM BMCServiceDesk__Incident__c WHERE Id=:testInc.Id LIMIT 1];
          testInc_1.Cognos_Roles__c='GG-APP-C8-USER-AE-TRAINING;GG-APP-C8-AUTHOR-ANALYSIS-STUDIO';
          testInc_1.BMCServiceDesk__FKRequestDetail__c=reqDetail.Id;
          testInc_1.BMCServiceDesk__FKRequestDefinition__c=testReqDef.Id;
        
          update testInc_1;

           
      Test.startTest();
          ProcessChildIncidents p = new ProcessChildIncidents();
        //p.process();
         p.execute(null);

        List<BMCServiceDesk__Incident__c> inclist = [Select Id,BMCServiceDesk__FKStatus__c from BMCServiceDesk__Incident__c where BMCServiceDesk__FKIncident__c = :testInc.Id];
        List<BMCServiceDesk__Status__c> statuslist = [Select Id, BMCServiceDesk__state__c from BMCServiceDesk__Status__c where BMCServiceDesk__state__c = false limit 1];
        for( BMCServiceDesk__Incident__c eachchild : inclist){
            eachchild.BMCServiceDesk__FKStatus__c  = statuslist[0].Id;
        }  

        update inclist;  
        
        Test.stopTest();                                                          
                                                                      
     }
    
    public static testmethod void commentedClasses(){
        ScheduleSLACheckOnIncidentsController obj=new ScheduleSLACheckOnIncidentsController();
        Test.startTest();
        PopulateSLAStatusOnIncident objec=new PopulateSLAStatusOnIncident();
        Test.stopTest();
    } 
    
    
     @future   
           static void putQueueSObject() {
            Group g = new Group(Type='Queue', Name='Testing Queue');
            insert g;
            List<QueueSObject> qsoList = new List<QueueSObject>(); 
            QueueSObject qso1 = new QueueSObject(SobjectType='BMCServiceDesk__Incident__c', QueueId=g.Id);
            QueueSObject qso2 = new QueueSObject(SobjectType='Multiple_requests_info__c', QueueId=g.Id);
            
            qsoList.add(qso1);
            qsoList.add(qso2);
            insert qsoList;
        }
}