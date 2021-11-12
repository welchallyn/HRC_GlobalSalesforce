@isTest(seeAllData=true)
public class RecallOldApprovalsTest {

    public static Id testReqDefId;
    public static Id testCategoryId;
        
    public static void createTestData(){
      BMCServiceDesk__Category__c testCategory=new BMCServiceDesk__Category__c(Name='testCategory',
                                                             BMCServiceDesk__AvailableForIncidents__c=true,
                                                             BMCServiceDesk__AvailableForServiceCatalog__c=true);
      insert testCategory;
    testCategoryId=testCategory.Id;
        
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
       
      BMCServiceDesk__BMC_BusinessService__c testBService_1=[SELECT Id,Name FROM BMCServiceDesk__BMC_BusinessService__c WHERE Name='Test Business Service' LIMIT 1];                                                                                                        
      BMCServiceDesk__BMC_BusinessService__c testBServiceOff_1=[Select Id,Name from BMCServiceDesk__BMC_BusinessService__c where Name='Test Business offering' Limit 1];

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
      testReqDefId=testReqDef.Id;
        
      BMCServiceDesk__SRM_ProcessTemplate__c proTemplate=new BMCServiceDesk__SRM_ProcessTemplate__c(BMCServiceDesk__FKRequestDefinition__c=testReqDef.Id,                                                                    
                                                                                 BMCServiceDesk__FKTemplate__c=reqTemplate.Id);
      insert proTemplate;
                     
      
    }
    public static testmethod void recallOldApprovals() {
       
      createTestData();
        
      BMCServiceDesk__Incident__c testInc=new BMCServiceDesk__Incident__c (BMCServiceDesk__FKCategory__c=testCategoryId,
      Operational_Catalog_Tier_1__c ='Install/Add/Create',Operational_Catalog_Tier_2__c='Security',
      Product_Catalog_Tier_1__c='Software',Product_Catalog_Tier_2__c='Agile', Cognos_Roles_2__c='Agile Capa creator',
      BMCServiceDesk__FKRequestDefinition__c=testReqDefId,
      Approval_Required__c=true,Approval_Processed__c=false,
      Role_Based_Approval__c=true);
      insert testInc;  

      BMCServiceDesk__SRM_RequestDetail__c reqDetail=new BMCServiceDesk__SRM_RequestDetail__c(BMCServiceDesk__FKClient__c=UserInfo.getUserid(),
                                                                           BMCServiceDesk__FKRequestDefinition__c=testReqDefId,
                                                                           BMCServiceDesk__FKIncident__c=testInc.Id);
      insert reqDetail;
      BMCServiceDesk__Incident__c testInc_1=[SELECT Id,Name,Cognos_Roles_2__c,BMCServiceDesk__FKRequestDetail__c,BMCServiceDesk__FKRequestDefinition__c,Operational_Catalog_Tier_1__c,Operational_Catalog_Tier_2__c,Product_Catalog_Tier_1__c,Product_Catalog_Tier_2__c FROM BMCServiceDesk__Incident__c WHERE Id=:testInc.Id LIMIT 1];
      testInc_1.Cognos_Roles_2__c='Agile Capa creator;Agile PDP Creator;Document Control Approver, MCO Approver';
      testInc_1.BMCServiceDesk__FKRequestDetail__c=reqDetail.Id;
      update testInc_1;
         UpdateSLAStausOnIncident u=new UpdateSLAStausOnIncident();
        try{
      Approval.ProcessSubmitRequest approvalReq = new Approval.ProcessSubmitRequest();
      approvalReq.setComments('Automatic Submitting of Incident for approval');
      approvalReq.setObjectId(testInc_1.Id);
      Approval.ProcessResult appResult_1 = Approval.process(approvalReq);
        }
        catch(Exception e){
            System.debug('Exception  :'+e);
        }
       

      Test.startTest();
      CheckRecursive.setValueForTest();
      testInc_1.Cognos_Roles_2__c='Agile Ap Workflow CA;MCO Approver';
      update testInc_1;
      
        try{
        Approval.ProcessSubmitRequest approvalReq2 = new Approval.ProcessSubmitRequest();
        approvalReq2.setComments('Automatic Submitting of Incident for approval');
     	approvalReq2.setObjectId(testInc_1.Id);
      
        Approval.ProcessResult appResult_2 = Approval.process(approvalReq2); 
        ReplaceApprovers ra = new ReplaceApprovers();
        Database.executeBatch(ra,2000);
        }
        catch(Exception e){
            System.debug('Exception :'+e);
        }
      
      Test.stopTest(); 
      
  
    } 
    
    public static testmethod void recallOldApprovalsUpdateInc(){
      
      createTestData();
        
      BMCServiceDesk__Incident__c testInc=new BMCServiceDesk__Incident__c (BMCServiceDesk__FKCategory__c=testCategoryId,
      Operational_Catalog_Tier_1__c ='Install/Add/Create',Operational_Catalog_Tier_2__c='Security',
      Product_Catalog_Tier_1__c='Software',Product_Catalog_Tier_2__c='Agile', Cognos_Roles_2__c='Agile Capa creator',
      BMCServiceDesk__FKRequestDefinition__c=testReqDefId,
      Approval_Required__c=true,
       Approval_Processed__c=false,
      Role_Based_Approval__c=true);
      insert testInc;  

      BMCServiceDesk__SRM_RequestDetail__c reqDetail=new BMCServiceDesk__SRM_RequestDetail__c(BMCServiceDesk__FKClient__c=UserInfo.getUserid(),
                                                                           BMCServiceDesk__FKRequestDefinition__c=testReqDefId,
                                                                           BMCServiceDesk__FKIncident__c=testInc.Id);
      insert reqDetail;
      BMCServiceDesk__Incident__c testInc_1=[SELECT Id,Name,Cognos_Roles_2__c,BMCServiceDesk__FKRequestDetail__c,BMCServiceDesk__FKRequestDefinition__c,Operational_Catalog_Tier_1__c,Operational_Catalog_Tier_2__c,Product_Catalog_Tier_1__c,Product_Catalog_Tier_2__c FROM BMCServiceDesk__Incident__c WHERE Id=:testInc.Id LIMIT 1];
      testInc_1.Cognos_Roles_2__c='Agile Capa creator;Agile PDP Creator';
      testInc_1.BMCServiceDesk__FKRequestDetail__c=reqDetail.Id;
      update testInc_1;
       
        try{
            Approval.ProcessSubmitRequest approvalReq = new Approval.ProcessSubmitRequest();
            approvalReq.setComments('Automatic Submitting of Incident for approval');
            approvalReq.setObjectId(testInc_1.Id);
         
            
         	Approval.ProcessResult appResult_1 = Approval.process(approvalReq);
        }
        catch(Exception e){
            System.debug('Exception :'+e);
        }
      Test.startTest();
      CheckRecursive.setValueForTest();
      testInc_1.Cognos_Roles_2__c='Agile Ap Workflow CA';
      update testInc_1;
       
        
      Test.stopTest();
        
    }
    
    public static testmethod void approvalHistoryTest(){
        createTestData();
        
           BMCServiceDesk__Incident__c testInc3=new BMCServiceDesk__Incident__c (BMCServiceDesk__FKCategory__c=testCategoryId,
      Operational_Catalog_Tier_1__c ='Remove',Operational_Catalog_Tier_2__c='Security',
      Product_Catalog_Tier_1__c='Software',Product_Catalog_Tier_2__c='JD EDWARDS',
      BMCServiceDesk__FKRequestDefinition__c=testReqDefId,
      Approval_Processed__c=false, JD_Edwards_Roles__c='t',
      Role_Based_Approval__c=true);
      insert testInc3; 
        
        try{
      Approval.ProcessSubmitRequest approvalReq = new Approval.ProcessSubmitRequest();
      approvalReq.setComments('Automatic Submitting of Incident for approval');
      approvalReq.setObjectId(testInc3.Id);
      Approval.ProcessResult appResult_1 = Approval.process(approvalReq);
      ApexPages.currentpage().getParameters().put('objectId',testInc3.Id);
      ApprovalHistoryController appHistory = new ApprovalHistoryController();
        
      appHistory.recallApprovalRequest();
    }catch(Exception e){
            System.debug('Exception:'+e);
        
    } 
        
    }
       public static testmethod void replaceApprovers(){
        createTestData();
        BMCServiceDesk__Incident__c testInc4=new BMCServiceDesk__Incident__c (BMCServiceDesk__FKCategory__c=testCategoryId,
      Operational_Catalog_Tier_1__c ='Remove',Operational_Catalog_Tier_2__c='Security',
      Product_Catalog_Tier_1__c='Software',Product_Catalog_Tier_2__c='JD EDWARDS',
      BMCServiceDesk__FKRequestDefinition__c=testReqDefId,
      Approval_Processed__c=false, JD_Edwards_Roles__c='t',
      Role_Based_Approval__c=true);
      insert testInc4; 
        
        try{
      Approval.ProcessSubmitRequest approvalReq = new Approval.ProcessSubmitRequest();
      approvalReq.setComments('Automatic Submitting of Incident for approval');
      approvalReq.setObjectId(testInc4.Id);
      Approval.ProcessResult appResult_1 = Approval.process(approvalReq);
      ReplaceApprovers ra = new ReplaceApprovers();
      Database.executeBatch(ra,2000);
    }catch(Exception e){
            System.debug('Exception:'+e);
        
    } 
        
      
    }
}