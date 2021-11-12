@isTest(seeAllData=false)
public class ProcessChildIncidentsTest {
    
      public static testmethod void processChildIncidentsTest() {
               
         /*BMCServiceDesk__Impact__c impact = new BMCServiceDesk__Impact__c(Name = 'High');
         BMCServiceDesk__Urgency__c urgency = new BMCServiceDesk__Urgency__c(Name = 'High');
         insert impact;
         insert urgency;*/
        /* BMCServiceDesk__Category__c testCategory=new BMCServiceDesk__Category__c(Name='testCategory',
                                                                 BMCServiceDesk__AvailableForIncidents__c=true,
                                                                 BMCServiceDesk__AvailableForServiceCatalog__c=true);
          insert testCategory;
      
         BMCServiceDesk__SRM_RequestDefinition__c testReqDef=new BMCServiceDesk__SRM_RequestDefinition__c(BMCServiceDesk__FKCategory__c=testCategory.Id,
                                                                      //   BMCServiceDesk__FKBusinessService__c=testBaseElement.Id,
                                                                      //   BMCServiceDesk__FKServiceOffering__c=testBaseElement_1.Id,
                                                                         BMCServiceDesk__serviceRequestTitle__c='Test Service Request for Hill---Rom');                                                             
          insert testReqDef;
          
          
          
          
          BMCServiceDesk__Incident__c inctest1 = new BMCServiceDesk__Incident__c (Operational_Catalog_Tier_1__c ='Install/Add/Create',Operational_Catalog_Tier_2__c='Security',
      		Product_Catalog_Tier_1__c='Software',Product_Catalog_Tier_2__c='Cognos',
             Cognos_Roles__c='GG-APP-C8-USER-AE-TRAINING;GG-APP-C8-AUTHOR-ANALYSIS-STUDIO'
           ,Approval_required__c=true
           ,Role_Based_Approval__c=true);
           inctest1.Is_Child__c = false;
           inctest1.BMCServiceDesk__FKClient__c = UserInfo.getUserId(); 
           //inctest1.BMCServiceDesk__FKImpact__c = impact.Id;
           //inctest1.BMCServiceDesk__FKUrgency__c = urgency.Id;
           
           insert inctest1;
           
           BMCServiceDesk__SRM_RequestDetail__c nreqDetail1=new BMCServiceDesk__SRM_RequestDetail__c(BMCServiceDesk__FKClient__c=UserInfo.getUserid(),
                                                                               BMCServiceDesk__FKRequestDefinition__c=testReqDef.Id,
                                                                               BMCServiceDesk__FKIncident__c=inctest1.Id);
           insert nreqDetail1;
           
           inctest1.BMCServiceDesk__FKRequestDetail__c = nreqDetail1.Id;
           update inctest1;
           

         BMCServiceDesk__Incident__c inctest = new BMCServiceDesk__Incident__c (Operational_Catalog_Tier_1__c ='Install/Add/Create',Operational_Catalog_Tier_2__c='Security',
      		Product_Catalog_Tier_1__c='Software',Product_Catalog_Tier_2__c='Cognos' 
           ,Cognos_Roles__c='GG-APP-C8-USER-AE-TRAINING;GG-APP-C8-AUTHOR-ANALYSIS-STUDIO',
			Approval_required__c=true,
            Role_Based_Approval__c=true
           );
           inctest.Is_Child__c = true;
           inctest.BMCServiceDesk__FKClient__c = UserInfo.getUserId(); 
           inctest.Request_detail_text__c = nreqDetail1.Id;
           
          // inctest.BMCServiceDesk__FKImpact__c = impact.Id;
           //inctest.BMCServiceDesk__FKUrgency__c = urgency.Id;
           
           insert inctest;
           
                      
           BMCServiceDesk__SRM_RequestDetail__c nreqDetail=new BMCServiceDesk__SRM_RequestDetail__c(BMCServiceDesk__FKClient__c=UserInfo.getUserid(),
                                                                               BMCServiceDesk__FKRequestDefinition__c=testReqDef.Id,
                                                                               BMCServiceDesk__FKIncident__c=inctest.Id);
           insert nreqDetail;
           
          
           
          Test.startTest(); 
    
          ProcessChildIncidents p = new ProcessChildIncidents();
        //p.process();
        //p.execute(null);
        
        /*Approval.ProcessSubmitRequest approvalReq = new Approval.ProcessSubmitRequest();
      	approvalReq.setComments('Automatic Submitting of Incident for approval');
      	approvalReq.setObjectId(inctest.Id);
        Approval.ProcessResult appResult_1 = Approval.process(approvalReq);*/
        
        
       // Test.stopTest();
       }
       
    
     }