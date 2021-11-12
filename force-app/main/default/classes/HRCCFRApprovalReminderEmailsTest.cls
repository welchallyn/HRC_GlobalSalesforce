@isTest(seeAllData=false)
private class HRCCFRApprovalReminderEmailsTest {
      //static ID LeaseRecordTypeID;
    public static Capital_Requests__c CFRAfterApproval;
    /*
    *   This method creates common test data which can be accessed by all test methods in this class 
    */
    @testSetup 
    static void setup() {
        Profile SysAdProfile           = HRCCFR_TestSetupData.getProfile('System Administrator');
        Profile FixedAssetProfile      = HRCCFR_TestSetupData.getProfile('HRC CFR Fixed Asset');
        Profile systemAdminProfile     = HRCCFR_TestSetupData.getProfile('HRC CFR System Admin');
        Profile ProjManagerProfile     = HRCCFR_TestSetupData.getProfile('HRC CFR Project Manager');
        Profile FinanceProfile         = HRCCFR_TestSetupData.getProfile('HRC CFR Financial Analyst');
        Profile StaffProfile           = HRCCFR_TestSetupData.getProfile('ServiceDesk Staff');
        
        list<Sobject> dmlSobjectList   = new list<Sobject>();
        User User1            = HRCCFR_TestSetupData.createUser(FixedAssetProfile, '1');
        User User2            = HRCCFR_TestSetupData.createUser(systemAdminProfile, '2');
        User User3            = HRCCFR_TestSetupData.createUser(ProjManagerProfile, '3');
        User User4            = HRCCFR_TestSetupData.createUser(FinanceProfile, '4');
        User User5            = HRCCFR_TestSetupData.createUser(StaffProfile, '5');
        User User6            = HRCCFR_TestSetupData.createUser(SysAdProfile, '6');
                
        dmlSobjectList.add((Sobject)User1);
        dmlSobjectList.add((Sobject)User2);
        dmlSobjectList.add((Sobject)User3);
        dmlSobjectList.add((Sobject)User4);
        dmlSobjectList.add((Sobject)User5);
        dmlSobjectList.add((Sobject)User6);
        
        insert dmlSobjectList;
        
        //Create Custom Setting Data
        List<HRCCFR_Lease_ApprovalStep_Queue_pair__c> LeaseCustomSetting = new list<HRCCFR_Lease_ApprovalStep_Queue_pair__c>();
        List<HRCCFR_Capital_ApprovalStep_Queue_pair__c> CapitalCustomSetting = new list<HRCCFR_Capital_ApprovalStep_Queue_pair__c>();
                
        LeaseCustomSetting.add(new HRCCFR_Lease_ApprovalStep_Queue_pair__c(Step_Number__c = 7,Name = 'HRC CFR Lease Op Comp CFO Queue'));
        LeaseCustomSetting.add(new HRCCFR_Lease_ApprovalStep_Queue_pair__c(Step_Number__c = 8,Name = 'HRC CFR Finance Approver CFO Queue'));
        LeaseCustomSetting.add(new HRCCFR_Lease_ApprovalStep_Queue_pair__c(Step_Number__c = 9,Name = 'HRC CFR Finance Approver COO Queue'));
        LeaseCustomSetting.add(new HRCCFR_Lease_ApprovalStep_Queue_pair__c(Step_Number__c =10,Name = 'HRC CFR Finance Approver CEO Queue'));

        CapitalCustomSetting.add(new HRCCFR_Capital_ApprovalStep_Queue_pair__c(Step_Number__c = 2,Name = 'HRC CFR Fixed Asset Queue'));
        CapitalCustomSetting.add(new HRCCFR_Capital_ApprovalStep_Queue_pair__c(Step_Number__c = 3,Name = 'HRC CFR Cost Accounting Queue'));
        CapitalCustomSetting.add(new HRCCFR_Capital_ApprovalStep_Queue_pair__c(Step_Number__c = 4,Name = 'HRC CFR CIO Queue'));
        CapitalCustomSetting.add(new HRCCFR_Capital_ApprovalStep_Queue_pair__c(Step_Number__c = 5,Name = 'HRC CFR Global Sourcing Queue'));
        CapitalCustomSetting.add(new HRCCFR_Capital_ApprovalStep_Queue_pair__c(Step_Number__c = 6,Name = 'HRC CFR Safety Queue'));
        CapitalCustomSetting.add(new HRCCFR_Capital_ApprovalStep_Queue_pair__c(Step_Number__c = 7,Name = 'HRC CFR Facility Provider Queue'));
        CapitalCustomSetting.add(new HRCCFR_Capital_ApprovalStep_Queue_pair__c(Step_Number__c = 12,Name = 'HRC CFR Finance Approver CFO Queue'));
        CapitalCustomSetting.add(new HRCCFR_Capital_ApprovalStep_Queue_pair__c(Step_Number__c = 13,Name = 'HRC CFR Finance Approver COO Queue'));
        CapitalCustomSetting.add(new HRCCFR_Capital_ApprovalStep_Queue_pair__c(Step_Number__c = 14,Name = 'HRC CFR Finance Approver CEO Queue'));
        
        
        insert LeaseCustomSetting;
        insert CapitalCustomSetting;                
        
        
   //     LeaseRecordTypeID = Schema.SObjectType.Capital_Requests__c.getRecordTypeInfosByName().get('CFR Lease').getRecordTypeId();

        
    }//End setup method


     static testMethod void remEmailOnlyQueueTest() {
        Approval.ProcessResult processResult;
        
        Map<string,id> GroupNameIdMap = new Map<string,id>();
        for(Group g: [select Id, name from Group where type= 'Queue']){
            GroupNameIdMap.put(g.name, g.id);
        }
        
        Id CapitalRecordTypeID = Schema.SObjectType.Capital_Requests__c.getRecordTypeInfosByName().get('CFR Capital').getRecordTypeId();
        User User1     = HRCCFR_TestSetupData.getUser('HRC CFR Fixed Asset');
        User User2     = HRCCFR_TestSetupData.getUser('HRC CFR Project Manager');
        User User3     = HRCCFR_TestSetupData.getUser('HRC CFR Fixed Asset');
        User User4     = HRCCFR_TestSetupData.getUser('HRC CFR System Admin');
        User User5     = HRCCFR_TestSetupData.getUser('HRC CFR System Admin');
        
        
        List<GroupMember> gmList = new List<GroupMember>();
        gmList.add(new GroupMember(GroupId=GroupNameIdMap.get('HRC CFR Fixed Asset Queue'), UserOrGroupId=User3.Id ));        
        gmList.add(new GroupMember(GroupId=GroupNameIdMap.get('HRC CFR Cost Accounting Queue'), UserOrGroupId=User1.Id )); 
        gmList.add(new GroupMember(GroupId=GroupNameIdMap.get('HRC CFR Cost Accounting Queue'), UserOrGroupId=User2.Id ));  
        
          
        gmList.add(new GroupMember(GroupId=GroupNameIdMap.get('HRC CFR CIO Queue'), UserOrGroupId=User3.Id ));       
        //gmList.add(new GroupMember(GroupId=GroupNameIdMap.get('HRC CFR Global Sourcing Queue'), UserOrGroupId=User4.Id ));              
           
        insert gmList;
        
        for(Group g: [SELECT Id, name, (SELECT groupId, UserOrGroupId FROM GroupMembers) FROM Group WHERE name = 'HRC CFR Fixed Asset Queue']){
            system.debug('----Group in Test----'+g+'---members--'+g.GroupMembers);
        }
        
        System.runAs(User1){  
            //Create CFR 
            Capital_Requests__c cr = HRCCFR_TestSetupData.createCapitalRequest(CapitalRecordTypeID,'CapitalDeDupApproverTEST');
            cr.Project_Manager__c  = User1.id;  
            cr.Financial_Analyst__c = User1.id;        //Approver 1
            cr.Op_Comp_CFO__c = User1.id;
            cr.Divisional_ELT__c = User1.id;
            cr.Does_project_require_IT_asset_purc__c = true;
            cr.Is_a_Safety_Issue__c = true;
            cr.Facilities_Impact__c = false;
            CR.Finance_Division_Lead__c = User1.id;
            
            insert cr;
            
            //Create child Capital Item - to make the CFR eligible for approval
            Capital_Iem__c ci = HRCCFR_TestSetupData.createCapitalItem(cr.id, 1000000);
            insert ci;
                     
              main(cr,User1);
            }
     }
    static void SubmittedRequest(Approval.ProcessResult Result,String Comments,String Action)
    {
        List<Id> newWorkItemIds = result.getNewWorkitemIds();
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments(Comments);
        req.setAction(Action);
        req.setWorkitemId(newWorkItemIds[0]);
        // Submit the request for approval
        Approval.ProcessResult result2 =  Approval.process(req);
        
    }

     static void main(Capital_Requests__c crObj,User User1) {

      List<Approval.ProcessResult> resultList = new List<Approval.ProcessResult>();
      //submiting records for approval   
      System.runAs (User1) { 
      //  for(Capital_Requests__c crObj: crInitList) {
            Approval.ProcessSubmitRequest crObjRequest = new Approval.ProcessSubmitRequest(); 
            crObjRequest.setObjectId(crObj.ID);  
            Approval.ProcessResult Result = Approval.Process(crObjRequest);
            resultList.add(Result);
            System.assert(Result.isSuccess());
            System.assertEquals('Pending', Result.getInstanceStatus(),'Instance Status : '+Result.getInstanceStatus());
      //  }
        }
        Test.startTest();
        List<Capital_Requests__c> tempCRList = new List<Capital_Requests__c>();
      //  for(Capital_Requests__c crObj : crInitList){
            crObj.SendEmailHelper__c = true;
            //crObj.Rejection_Comments_Required__c = 'Rejected';
            tempCRList.add(crObj);
     //   }
        try{//Added Sindhu
            update tempCRList;
        }catch(Exception e){ 
            system.debug('in catch');
        }
        
        System.runAs(User1){
            Integer i=0;
            for(Approval.ProcessResult r:resultList){
                if(Math.mod(i,2)==0)
                    SubmittedRequest(r,'Rejected','Reject');
                else
                    SubmittedRequest(r,'Approved','Approve');
                i++;
            }
        }
        update tempCRList;
        //To cover the EmailTemplate method which is not been used in the class.
        List<EmailTemplate> emails = [select id,name,DeveloperName from EmailTemplate limit 1];
        if(!emails.isEmpty())
            HRCCFRApprovalReminderEmails.findEmailTemplateIDByDeveloperName(emails[0].DeveloperName);
        Test.stopTest();
    }
 
}