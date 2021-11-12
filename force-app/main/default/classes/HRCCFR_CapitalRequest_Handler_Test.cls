@isTest
public class HRCCFR_CapitalRequest_Handler_Test{
    //static ID LeaseRecordTypeID;
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
        
    }//End setup method
    
    /**
    * Test method to test capital record for remove duplicate  Approver when step criteria like Rental, IT, Safety and Facility are true 
    */
    static testMethod void test_CapitalRemoveDuplicateApprovers() {
        Approval.ProcessResult processResult;
        
        Map<string,id> GroupNameIdMap = new Map<string,id>();
        for(Group g: [select Id, name from Group where type= 'Queue']){
            GroupNameIdMap.put(g.name, g.id);
        }
        
        Id CapitalRecordTypeID = Schema.SObjectType.Capital_Requests__c.getRecordTypeInfosByName().get('CFR Capital').getRecordTypeId();
        User User1     = HRCCFR_TestSetupData.getUser('HRC CFR Fixed Asset');
        User User2     = HRCCFR_TestSetupData.getUser('HRC CFR Project Manager');
        User User3     = HRCCFR_TestSetupData.getUser('HRC CFR Financial Analyst');
        User User4     = HRCCFR_TestSetupData.getUser('HRC CFR System Admin');
        User User5     = HRCCFR_TestSetupData.getUser('ServiceDesk Staff');
        
        List<GroupMember> gmList = new List<GroupMember>();
        
        gmList.add(new GroupMember(GroupId=GroupNameIdMap.get('HRC CFR Project Manager'), UserOrGroupId=User2.Id )); 
        
        gmList.add(new GroupMember(GroupId=GroupNameIdMap.get('HRC CFR Fixed Asset Queue'), UserOrGroupId=User2.Id )); 
        gmList.add(new GroupMember(GroupId=GroupNameIdMap.get('HRC CFR Fixed Asset Queue'), UserOrGroupId=User3.Id )); 
        
        gmList.add(new GroupMember(GroupId=GroupNameIdMap.get('HRC CFR Cost Accounting Queue'), UserOrGroupId=User1.Id )); 
        gmList.add(new GroupMember(GroupId=GroupNameIdMap.get('HRC CFR Cost Accounting Queue'), UserOrGroupId=User2.Id )); 
        
        gmList.add(new GroupMember(GroupId=GroupNameIdMap.get('HRC CFR CIO Queue'), UserOrGroupId=User3.Id )); 
        
        gmList.add(new GroupMember(GroupId=GroupNameIdMap.get('HRC CFR Global Sourcing Queue'), UserOrGroupId=User4.Id )); 
        
        gmList.add(new GroupMember(GroupId=GroupNameIdMap.get('HRC CFR Safety Queue'), UserOrGroupId=User3.Id )); 
        gmList.add(new GroupMember(GroupId=GroupNameIdMap.get('HRC CFR Safety Queue'), UserOrGroupId=User5.Id )); 
        
        gmList.add(new GroupMember(GroupId=GroupNameIdMap.get('HRC CFR Facility Provider Queue'), UserOrGroupId=User5.Id )); 
        
        insert gmList;
        
        for(Group g: [SELECT Id, name, (SELECT groupId, UserOrGroupId FROM GroupMembers) FROM Group WHERE name = 'HRC CFR Fixed Asset Queue']){
            system.debug('----Group in Test----'+g+'---members--'+g.GroupMembers);
        }
        
        System.runAs(User1){  
            //Create CFR 
            Capital_Requests__c cr = HRCCFR_TestSetupData.createCapitalRequest(CapitalRecordTypeID,'CapitalDeDupApproverTEST');
            cr.Project_Manager__c  = User2.id;  
            cr.Financial_Analyst__c = User1.id;        //Approver 1
            cr.Op_Comp_CFO__c = User1.id;
            cr.Divisional_ELT__c = User1.id;
            cr.Project_Manager_Supervisor__c = User1.id;
            cr.Project_Objective__c = 'Rental';
            cr.Does_project_require_IT_asset_purc__c = true;
            cr.Is_a_Safety_Issue__c = true;
            cr.Facilities_Impact__c = true;
            CR.Finance_Division_Lead__c = User1.id;
            
            insert cr;
            
            //Create child Capital Item - to make the CFR eligible for approval
            Capital_Iem__c ci = HRCCFR_TestSetupData.createCapitalItem(cr.id, 1000000);
            insert ci;
            
            Test.startTest();
            // Submit the CFR for Approval
            Approval.ProcessSubmitRequest SubmitRequest = new Approval.ProcessSubmitRequest();
            SubmitRequest.setComments('Submitting request for approval.');
            SubmitRequest.setObjectId(cr.id);
            Approval.ProcessResult result = Approval.process(SubmitRequest);  // Submit for approval 
            
            // Verify the result
            System.assert(result.isSuccess());
            System.assertEquals('Pending', result.getInstanceStatus(), 'Instance Status'+result.getInstanceStatus());
            
            // Approve Step 1 by User1 (PM)
            // Instantiate the new ProcessWorkitemRequest object and populate it
            Approval.ProcessWorkitemRequest ApproveRequest1 = new Approval.ProcessWorkitemRequest();
            ApproveRequest1.setComments('Approving CFR');
            ApproveRequest1.setAction('Approve');
            ApproveRequest1.setWorkitemId((result.newWorkItemIds)[0]);
            
            Approval.ProcessResult processResult_1 =  Approval.process(ApproveRequest1);
            // Verify the results
            System.assert(processResult_1.isSuccess(), 'Result Status:'+processResult_1.isSuccess()); 
            
            Capital_Requests__c CFR_AfterApproval_1 = HRCCFR_TestSetupData.getCapitalRequest('CapitalDeDupApproverTEST');
            System.assertEquals('1', CFR_AfterApproval_1.Last_Approved_Step__c);            
            processResult = processResult_1;
            
            //Approve step 2 as User1
            Approval.ProcessWorkitemRequest ApproveRequest2 = new Approval.ProcessWorkitemRequest();
            ApproveRequest2.setComments('Approving CFR');
            ApproveRequest2.setAction('Approve');
            ApproveRequest2.setWorkitemId((processResult.newWorkItemIds)[0]);
            
            Approval.ProcessResult processResult_2 =  Approval.process(ApproveRequest2);
            // Verify the results
            System.assert(processResult_2.isSuccess(), 'Result Status:'+processResult_2.isSuccess());
            
            Capital_Requests__c CFR_AfterApproval_2 = HRCCFR_TestSetupData.getCapitalRequest('CapitalDeDupApproverTEST');
            System.assertEquals('2', CFR_AfterApproval_2.Last_Approved_Step__c);
            processResult =  processResult_2;          
            
            //Approve step 3 as User1           
            Approval.ProcessWorkitemRequest ApproveRequest3 = new Approval.ProcessWorkitemRequest();
            ApproveRequest3.setComments('Approving CFR');
            ApproveRequest3.setAction('Approve');
            ApproveRequest3.setWorkitemId((processResult.newWorkItemIds)[0]);
            
            Approval.ProcessResult processResult_3 =  Approval.process(ApproveRequest3);
            // Verify the results
            System.assert(processResult_3.isSuccess(), 'Result Status:'+processResult_3.isSuccess());
            
            Capital_Requests__c CFR_AfterApproval_3 = HRCCFR_TestSetupData.getCapitalRequest('CapitalDeDupApproverTEST');
            System.assertEquals('3', CFR_AfterApproval_3.Last_Approved_Step__c); 
            processResult =  processResult_3;                
            
            
            //Approve step 4 as User1             
            Approval.ProcessWorkitemRequest ApproveRequest4 = new Approval.ProcessWorkitemRequest();
            ApproveRequest4.setComments('Approving CFR');
            ApproveRequest4.setAction('Approve');
            ApproveRequest4.setWorkitemId((processResult.newWorkItemIds)[0]);
            
            Approval.ProcessResult processResult_4 =  Approval.process(ApproveRequest4);
            // Verify the results
            System.assert(processResult_4.isSuccess(), 'Result Status:'+processResult_4.isSuccess());
            
            Capital_Requests__c CFR_AfterApproval_4 = HRCCFR_TestSetupData.getCapitalRequest('CapitalDeDupApproverTEST');
            System.assertEquals('6', CFR_AfterApproval_4.Last_Approved_Step__c);        
            processResult =  processResult_4 ;        
        }
        
        //Approve step 5 as User4             
        System.runAs(User4){  
            Approval.ProcessWorkitemRequest ApproveRequest5 = new Approval.ProcessWorkitemRequest();
            ApproveRequest5.setComments('Approving CFR');
            ApproveRequest5.setAction('Approve');
            ApproveRequest5.setWorkitemId((processResult.newWorkItemIds)[0]);
            
            Approval.ProcessResult processResult_5 =  Approval.process(ApproveRequest5);
            // Verify the results
            System.assert(processResult_5.isSuccess(), 'Result Status:'+processResult_5.isSuccess());
            
            Capital_Requests__c CFR_AfterApproval_5 = HRCCFR_TestSetupData.getCapitalRequest('CapitalDeDupApproverTEST');
            System.assertEquals('8', CFR_AfterApproval_5.Last_Approved_Step__c);      
            processResult =  processResult_5 ;       
        }
        Test.stopTest();
        
    }//End Method test_CapitalRemoveDuplicateApprovers
    
    /**
    * Test method to test capital record for remove duplicate  Approver when step 4, 5 are skipped and Safety and Facility are true 
    */
    static testMethod void test_Capital_Safety_Facility() {
        Approval.ProcessResult processResult;
        
        Map<string,id> GroupNameIdMap = new Map<string,id>();
        for(Group g: [select Id, name from Group where type= 'Queue']){
            GroupNameIdMap.put(g.name, g.id);
        }
        
        Id CapitalRecordTypeID = Schema.SObjectType.Capital_Requests__c.getRecordTypeInfosByName().get('CFR Capital').getRecordTypeId();
        User User1     = HRCCFR_TestSetupData.getUser('HRC CFR Fixed Asset');
        User User2     = HRCCFR_TestSetupData.getUser('HRC CFR Project Manager');
        User User3     = HRCCFR_TestSetupData.getUser('HRC CFR Financial Analyst');
        User User4     = HRCCFR_TestSetupData.getUser('HRC CFR System Admin');
        User User5     = HRCCFR_TestSetupData.getUser('HRC CFR Fixed Asset');
        
        List<GroupMember> gmList = new List<GroupMember>();
        
        gmList.add(new GroupMember(GroupId=GroupNameIdMap.get('HRC CFR Project Manager'), UserOrGroupId=User2.Id )); 
        
        gmList.add(new GroupMember(GroupId=GroupNameIdMap.get('HRC CFR Fixed Asset Queue'), UserOrGroupId=User2.Id )); 
        gmList.add(new GroupMember(GroupId=GroupNameIdMap.get('HRC CFR Fixed Asset Queue'), UserOrGroupId=User3.Id ));   
        gmList.add(new GroupMember(GroupId=GroupNameIdMap.get('HRC CFR Global Sourcing Queue'), UserOrGroupId=User4.Id ));        
        gmList.add(new GroupMember(GroupId=GroupNameIdMap.get('HRC CFR Safety Queue'), UserOrGroupId=User3.Id )); 
        gmList.add(new GroupMember(GroupId=GroupNameIdMap.get('HRC CFR Safety Queue'), UserOrGroupId=User1.Id ));        
        gmList.add(new GroupMember(GroupId=GroupNameIdMap.get('HRC CFR Facility Provider Queue'), UserOrGroupId=User5.Id )); 
        
        insert gmList;
        
        for(Group g: [SELECT Id, name, (SELECT groupId, UserOrGroupId FROM GroupMembers) FROM Group WHERE name = 'HRC CFR Fixed Asset Queue']){
            system.debug('----Group in Test----'+g+'---members--'+g.GroupMembers);
        }
        
        System.runAs(User1){  
            //Create CFR 
            Capital_Requests__c cr = HRCCFR_TestSetupData.createCapitalRequest(CapitalRecordTypeID,'CapitalDeDupApproverTEST');
            cr.Project_Manager__c  = User2.id;  
            cr.Financial_Analyst__c = User1.id;        //Approver 1
            cr.Op_Comp_CFO__c = User1.id;
            cr.Divisional_ELT__c = User1.id;
            cr.Project_Manager_Supervisor__c = User1.id;
            cr.Project_Objective__c = 'Test';
            cr.Does_project_require_IT_asset_purc__c = false;
            cr.Is_a_Safety_Issue__c = true;
            cr.Facilities_Impact__c = true;
            CR.Finance_Division_Lead__c = User1.id;
            
            insert cr;
            
            //Create child Capital Item - to make the CFR eligible for approval
            Capital_Iem__c ci = HRCCFR_TestSetupData.createCapitalItem(cr.id, 1000000);
            insert ci;
            
            Test.startTest();
            // Submit the CFR for Approval
            Approval.ProcessSubmitRequest SubmitRequest = new Approval.ProcessSubmitRequest();
            SubmitRequest.setComments('Submitting request for approval.');
            SubmitRequest.setObjectId(cr.id);
            Approval.ProcessResult result = Approval.process(SubmitRequest);  // Submit for approval 
            
            // Verify the result
            System.assert(result.isSuccess());
            System.assertEquals('Pending', result.getInstanceStatus(), 'Instance Status'+result.getInstanceStatus());
            
            // Approve Step 1 by User1 (PM)
            // Instantiate the new ProcessWorkitemRequest object and populate it
            Approval.ProcessWorkitemRequest ApproveRequest1 = new Approval.ProcessWorkitemRequest();
            ApproveRequest1.setComments('Approving CFR');
            ApproveRequest1.setAction('Approve');
            ApproveRequest1.setWorkitemId((result.newWorkItemIds)[0]);
            
            Approval.ProcessResult processResult_1 =  Approval.process(ApproveRequest1);
            // Verify the results
            System.assert(processResult_1.isSuccess(), 'Result Status:'+processResult_1.isSuccess()); 
            
            Capital_Requests__c CFR_AfterApproval_1 = HRCCFR_TestSetupData.getCapitalRequest('CapitalDeDupApproverTEST');
            System.assertEquals('1', CFR_AfterApproval_1.Last_Approved_Step__c);            
            processResult = processResult_1;
            
            //Approve step 2 as User1
            Approval.ProcessWorkitemRequest ApproveRequest2 = new Approval.ProcessWorkitemRequest();
            ApproveRequest2.setComments('Approving CFR');
            ApproveRequest2.setAction('Approve');
            ApproveRequest2.setWorkitemId((processResult.newWorkItemIds)[0]);
            
            Approval.ProcessResult processResult_2 =  Approval.process(ApproveRequest2);
            // Verify the results
            System.assert(processResult_2.isSuccess(), 'Result Status:'+processResult_2.isSuccess());
            
            Capital_Requests__c CFR_AfterApproval_2 = HRCCFR_TestSetupData.getCapitalRequest('CapitalDeDupApproverTEST');
            System.assertEquals('2', CFR_AfterApproval_2.Last_Approved_Step__c);
            processResult =  processResult_2;          
        }
        //Approve step 3 as User4             
        System.runAs(User4){  
            Approval.ProcessWorkitemRequest ApproveRequest5 = new Approval.ProcessWorkitemRequest();
            ApproveRequest5.setComments('Approving CFR');
            ApproveRequest5.setAction('Approve');
            ApproveRequest5.setWorkitemId((processResult.newWorkItemIds)[0]);
            
            Approval.ProcessResult processResult_5 =  Approval.process(ApproveRequest5);
            // Verify the results
            System.assert(processResult_5.isSuccess(), 'Result Status:'+processResult_5.isSuccess());
            
            Capital_Requests__c CFR_AfterApproval_5 = HRCCFR_TestSetupData.getCapitalRequest('CapitalDeDupApproverTEST');
            System.assertEquals('3', CFR_AfterApproval_5.Last_Approved_Step__c);      
            processResult =  processResult_5 ;       
        }
        
        //Approve step 6 as User1 (FixedAsset)            
        System.runAs(User5){  
            Approval.ProcessWorkitemRequest ApproveRequest6 = new Approval.ProcessWorkitemRequest();
            ApproveRequest6.setComments('Approving CFR');
            ApproveRequest6.setAction('Approve');
            ApproveRequest6.setWorkitemId((processResult.newWorkItemIds)[0]);
            
            Approval.ProcessResult processResult_6 =  Approval.process(ApproveRequest6);
            // Verify the results
            System.assert(processResult_6.isSuccess(), 'Result Status:'+processResult_6.isSuccess());
            
            Capital_Requests__c CFR_AfterApproval_6 = HRCCFR_TestSetupData.getCapitalRequest('CapitalDeDupApproverTEST');
            System.assertEquals('9', CFR_AfterApproval_6.Last_Approved_Step__c);      
            
        }
        Test.stopTest();      
    }//End Method test_Capital_Safety_Facility
    

    /**
    * Test method to test capital record for remove duplicate  Approver when step 4, 5 are skipped and Safety is False(step 7) and Facility are true 
    */
    static testMethod void test_Capital_SafetyFalse_FacilityTrue() {
        Approval.ProcessResult processResult;
        
        Map<string,id> GroupNameIdMap = new Map<string,id>();
        for(Group g: [select Id, name from Group where type= 'Queue']){
            GroupNameIdMap.put(g.name, g.id);
        }
        
        Id CapitalRecordTypeID = Schema.SObjectType.Capital_Requests__c.getRecordTypeInfosByName().get('CFR Capital').getRecordTypeId();
        User User1     = HRCCFR_TestSetupData.getUser('HRC CFR Fixed Asset');
        User User2     = HRCCFR_TestSetupData.getUser('HRC CFR Project Manager');
        User User3     = HRCCFR_TestSetupData.getUser('HRC CFR Financial Analyst');
        User User4     = HRCCFR_TestSetupData.getUser('HRC CFR System Admin');
        User User5     = HRCCFR_TestSetupData.getUser('HRC CFR Fixed Asset');
        
        List<GroupMember> gmList = new List<GroupMember>();
        
        gmList.add(new GroupMember(GroupId=GroupNameIdMap.get('HRC CFR Project Manager'), UserOrGroupId=User2.Id ));  
        gmList.add(new GroupMember(GroupId=GroupNameIdMap.get('HRC CFR Fixed Asset Queue'), UserOrGroupId=User2.Id )); 
        gmList.add(new GroupMember(GroupId=GroupNameIdMap.get('HRC CFR Fixed Asset Queue'), UserOrGroupId=User3.Id ));        
        gmList.add(new GroupMember(GroupId=GroupNameIdMap.get('HRC CFR Global Sourcing Queue'), UserOrGroupId=User4.Id ));         
        gmList.add(new GroupMember(GroupId=GroupNameIdMap.get('HRC CFR Facility Provider Queue'), UserOrGroupId=User5.Id )); 
        
        insert gmList;
        
        for(Group g: [SELECT Id, name, (SELECT groupId, UserOrGroupId FROM GroupMembers) FROM Group WHERE name = 'HRC CFR Fixed Asset Queue']){
            system.debug('----Group in Test----'+g+'---members--'+g.GroupMembers);
        }
        
        System.runAs(User1){  
            //Create CFR 
            Capital_Requests__c cr = HRCCFR_TestSetupData.createCapitalRequest(CapitalRecordTypeID,'CapitalDeDupApproverTEST');
            cr.Project_Manager__c  = User2.id;  
            cr.Financial_Analyst__c = User1.id;        //Approver 1
            cr.Op_Comp_CFO__c = User1.id;
            cr.Divisional_ELT__c = User1.id;
            cr.Project_Objective__c = 'Test';
            cr.Project_Manager_Supervisor__c = User1.id;
            cr.Does_project_require_IT_asset_purc__c = false;
            cr.Is_a_Safety_Issue__c = false;
            cr.Facilities_Impact__c = true;
            CR.Finance_Division_Lead__c = User1.id;
            cr.Functional_Manager__c = User1.id;
            
            insert cr;
            
            //Create child Capital Item - to make the CFR eligible for approval
            Capital_Iem__c ci = HRCCFR_TestSetupData.createCapitalItem(cr.id, 1000000);
            insert ci;
            
           
            // Submit the CFR for Approval
            Approval.ProcessSubmitRequest SubmitRequest = new Approval.ProcessSubmitRequest();
            SubmitRequest.setComments('Submitting request for approval.');
            SubmitRequest.setObjectId(cr.id);
            Approval.ProcessResult result = Approval.process(SubmitRequest);  // Submit for approval 
            
            // Verify the result
            System.assert(result.isSuccess());
            System.assertEquals('Pending', result.getInstanceStatus(), 'Instance Status'+result.getInstanceStatus());
            
            // Approve Step 1 by User1 (PM)
            // Instantiate the new ProcessWorkitemRequest object and populate it
            Approval.ProcessWorkitemRequest ApproveRequest1 = new Approval.ProcessWorkitemRequest();
            ApproveRequest1.setComments('Approving CFR');
            ApproveRequest1.setAction('Approve');
            ApproveRequest1.setWorkitemId((result.newWorkItemIds)[0]);
            
            Approval.ProcessResult processResult_1 =  Approval.process(ApproveRequest1);
            // Verify the results
            System.assert(processResult_1.isSuccess(), 'Result Status:'+processResult_1.isSuccess()); 
            
            Capital_Requests__c CFR_AfterApproval_1 = HRCCFR_TestSetupData.getCapitalRequest('CapitalDeDupApproverTEST');
            System.assertEquals('1', CFR_AfterApproval_1.Last_Approved_Step__c);            
            processResult = processResult_1;
            
            //Approve step 2 as User1
            Approval.ProcessWorkitemRequest ApproveRequest2 = new Approval.ProcessWorkitemRequest();
            ApproveRequest2.setComments('Approving CFR');
            ApproveRequest2.setAction('Approve');
            ApproveRequest2.setWorkitemId((processResult.newWorkItemIds)[0]);
            
            Approval.ProcessResult processResult_2 =  Approval.process(ApproveRequest2);
            // Verify the results
            System.assert(processResult_2.isSuccess(), 'Result Status:'+processResult_2.isSuccess());
            
            Capital_Requests__c CFR_AfterApproval_2 = HRCCFR_TestSetupData.getCapitalRequest('CapitalDeDupApproverTEST');
            System.assertEquals('2', CFR_AfterApproval_2.Last_Approved_Step__c);
            processResult =  processResult_2;          
        }
        //Approve step 3 as User4             
        System.runAs(User4){  
            Approval.ProcessWorkitemRequest ApproveRequest5 = new Approval.ProcessWorkitemRequest();
            ApproveRequest5.setComments('Approving CFR');
            ApproveRequest5.setAction('Approve');
            ApproveRequest5.setWorkitemId((processResult.newWorkItemIds)[0]);
            
            Approval.ProcessResult processResult_5 =  Approval.process(ApproveRequest5);
            // Verify the results
            System.assert(processResult_5.isSuccess(), 'Result Status:'+processResult_5.isSuccess());
            
            Capital_Requests__c CFR_AfterApproval_5 = HRCCFR_TestSetupData.getCapitalRequest('CapitalDeDupApproverTEST');
            System.assertEquals('3', CFR_AfterApproval_5.Last_Approved_Step__c);      
            processResult =  processResult_5 ;       
        }
        
        //Approve step 6 as User5 (FixedAsset)            
        System.runAs(User5){  
            Approval.ProcessWorkitemRequest ApproveRequest6 = new Approval.ProcessWorkitemRequest();
            ApproveRequest6.setComments('Approving CFR');
            ApproveRequest6.setAction('Approve');
            ApproveRequest6.setWorkitemId((processResult.newWorkItemIds)[0]);
            
            Approval.ProcessResult processResult_6 =  Approval.process(ApproveRequest6);
            // Verify the results
            System.assert(processResult_6.isSuccess(), 'Result Status:'+processResult_6.isSuccess());
            
            Capital_Requests__c CFR_AfterApproval_6 = HRCCFR_TestSetupData.getCapitalRequest('CapitalDeDupApproverTEST');
            System.assertEquals('10', CFR_AfterApproval_6.Last_Approved_Step__c);      
            processResult =  processResult_6 ;   
        }
        
        //Approve step 8 as User5 (FixedAsset)            
        System.runAs(User5){  
            Approval.ProcessWorkitemRequest ApproveRequest7 = new Approval.ProcessWorkitemRequest();
            ApproveRequest7.setComments('Approving CFR');
            ApproveRequest7.setAction('Approve');
            ApproveRequest7.setWorkitemId((processResult.newWorkItemIds)[0]);
            
            Approval.ProcessResult processResult_7 =  Approval.process(ApproveRequest7);
            // Verify the results
            System.assert(processResult_7.isSuccess(), 'Result Status:'+processResult_7.isSuccess());
            
            Capital_Requests__c CFR_AfterApproval_7 = HRCCFR_TestSetupData.getCapitalRequest('CapitalDeDupApproverTEST');
            System.assertEquals('11', CFR_AfterApproval_7.Last_Approved_Step__c);      
            processResult =  processResult_7 ;
        }
             Test.startTest();
            //Approve step 9 as User5 (FixedAsset)            
        System.runAs(User5){  
            Approval.ProcessWorkitemRequest ApproveRequest9 = new Approval.ProcessWorkitemRequest();
            ApproveRequest9.setComments('Approving CFR');
            ApproveRequest9.setAction('Approve');
            ApproveRequest9.setWorkitemId((processResult.newWorkItemIds)[0]);
            
            Approval.ProcessResult processResult_9 =  Approval.process(ApproveRequest9);
            // Verify the results
            System.assert(processResult_9.isSuccess(), 'Result Status:'+processResult_9.isSuccess());
            
            Capital_Requests__c CFR_AfterApproval_9 = HRCCFR_TestSetupData.getCapitalRequest('CapitalDeDupApproverTEST');
            System.assertEquals('12', CFR_AfterApproval_9.Last_Approved_Step__c);      
            processResult =  processResult_9 ;
        }
            //Approve step 10 as User5 (FixedAsset)            
        System.runAs(User5){  
            Approval.ProcessWorkitemRequest ApproveRequest10 = new Approval.ProcessWorkitemRequest();
            ApproveRequest10.setComments('Approving CFR');
            ApproveRequest10.setAction('Approve');
            ApproveRequest10.setWorkitemId((processResult.newWorkItemIds)[0]);
            
            Approval.ProcessResult processResult_10 =  Approval.process(ApproveRequest10);
            // Verify the results
            System.assert(processResult_10.isSuccess(), 'Result Status:'+processResult_10.isSuccess());
            
            Capital_Requests__c CFR_AfterApproval_10 = HRCCFR_TestSetupData.getCapitalRequest('CapitalDeDupApproverTEST');
            System.assertEquals('13', CFR_AfterApproval_10.Last_Approved_Step__c);      
            processResult =  processResult_10 ;
        }
            //Approve step 11 as User5 (FixedAsset)            
        System.runAs(User5){  
            Approval.ProcessWorkitemRequest ApproveRequest11 = new Approval.ProcessWorkitemRequest();
            ApproveRequest11.setComments('Approving CFR');
            ApproveRequest11.setAction('Approve');
            ApproveRequest11.setWorkitemId((processResult.newWorkItemIds)[0]);
            
            Approval.ProcessResult processResult_11 =  Approval.process(ApproveRequest11);
            // Verify the results
            System.assert(processResult_11.isSuccess(), 'Result Status:'+processResult_11.isSuccess());
            
            Capital_Requests__c CFR_AfterApproval_11 = HRCCFR_TestSetupData.getCapitalRequest('CapitalDeDupApproverTEST');
            //System.assertEquals('15', CFR_AfterApproval_11.Last_Approved_Step__c);      
            processResult =  processResult_11 ;
        }
            // Step 12 is skipped as  'Related US field service/therapy fleet?'ckeckbox is unchecked.
            //Approve step 13 as User5 (FixedAsset)            
        //System.runAs(User5){  
            //Approval.ProcessWorkitemRequest ApproveRequest13 = new Approval.ProcessWorkitemRequest();
            //ApproveRequest13.setComments('Approving CFR');
            //ApproveRequest13.setAction('Approve');
            //ApproveRequest13.setWorkitemId((processResult.newWorkItemIds)[0]);
            
            //Approval.ProcessResult processResult_13 =  Approval.process(ApproveRequest13);
            // Verify the results
            //System.assert(processResult_13.isSuccess(), 'Result Status:'+processResult_13.isSuccess());
            
            //Capital_Requests__c CFR_AfterApproval_13 = HRCCFR_TestSetupData.getCapitalRequest('CapitalDeDupApproverTEST');
            //System.assertEquals('Null', CFR_AfterApproval_13.Last_Approved_Step__c);      
            
       // }
        
        Test.stopTest();      
    }//End Method test_Capital_SafetyFalse_FacilityTrue

    /**
    * Test method to test capital record for remove duplicate  Approver when step 4,6,7(IT,Safety and Facility are false) are skipped and Rental is true
    */
    static testMethod void test_CapitalRmvDuplIFRentalFalseITTrue() {
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
        
        
        List<GroupMember> gmList = new List<GroupMember>();
        gmList.add(new GroupMember(GroupId=GroupNameIdMap.get('HRC CFR Fixed Asset Queue'), UserOrGroupId=User2.Id )); 
        gmList.add(new GroupMember(GroupId=GroupNameIdMap.get('HRC CFR Fixed Asset Queue'), UserOrGroupId=User3.Id ));       
        gmList.add(new GroupMember(GroupId=GroupNameIdMap.get('HRC CFR Cost Accounting Queue'), UserOrGroupId=User1.Id )); 
        gmList.add(new GroupMember(GroupId=GroupNameIdMap.get('HRC CFR Cost Accounting Queue'), UserOrGroupId=User2.Id ));         
        gmList.add(new GroupMember(GroupId=GroupNameIdMap.get('HRC CFR Global Sourcing Queue'), UserOrGroupId=User3.Id ));    
        
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
            cr.Project_Manager_Supervisor__c = User1.id;
            cr.Project_Objective__c = 'Rental';
            cr.Is_a_Safety_Issue__c = false;
            cr.Facilities_Impact__c = false;
            CR.Finance_Division_Lead__c = User1.id;
            
            insert cr;
            
            //Create child Capital Item - to make the CFR eligible for approval
            Capital_Iem__c ci = HRCCFR_TestSetupData.createCapitalItem(cr.id, 1000000);
            insert ci;
            
            Test.startTest();
            // Submit the CFR for Approval
            Approval.ProcessSubmitRequest SubmitRequest = new Approval.ProcessSubmitRequest();
            SubmitRequest.setComments('Submitting request for approval.');
            SubmitRequest.setObjectId(cr.id);
            Approval.ProcessResult result = Approval.process(SubmitRequest);  // Submit for approval 
            
            // Verify the result
            System.assert(result.isSuccess());
            System.assertEquals('Pending', result.getInstanceStatus(), 'Instance Status'+result.getInstanceStatus());
            
            // Approve the submitted request as PM
            // Instantiate the new ProcessWorkitemRequest object and populate it
            Approval.ProcessWorkitemRequest ApproveRequest1 = new Approval.ProcessWorkitemRequest();
            ApproveRequest1.setComments('Approving CFR');
            ApproveRequest1.setAction('Approve');
            ApproveRequest1.setWorkitemId((result.newWorkItemIds)[0]);
            
            Approval.ProcessResult processResult_1 =  Approval.process(ApproveRequest1);
            // Verify the results
            System.assert(processResult_1.isSuccess(), 'Result Status:'+processResult_1.isSuccess()); 
            
            Capital_Requests__c CFR_AfterApproval_1 = HRCCFR_TestSetupData.getCapitalRequest('CapitalDeDupApproverTEST');
            System.assertEquals('1', CFR_AfterApproval_1.Last_Approved_Step__c);            
            processResult = processResult_1;
            
        }//END RunAs    
        
        //Approve step 2 as User1
        System.runAs(User1){
            Approval.ProcessWorkitemRequest ApproveRequest2 = new Approval.ProcessWorkitemRequest();
            ApproveRequest2.setComments('Approving CFR');
            ApproveRequest2.setAction('Approve');
            ApproveRequest2.setWorkitemId((processResult.newWorkItemIds)[0]);
            
            Approval.ProcessResult processResult_2 =  Approval.process(ApproveRequest2);
            // Verify the results
            System.assert(processResult_2.isSuccess(), 'Result Status:'+processResult_2.isSuccess());
            
            Capital_Requests__c CFR_AfterApproval_2 = HRCCFR_TestSetupData.getCapitalRequest('CapitalDeDupApproverTEST');
            System.assertEquals('2', CFR_AfterApproval_2.Last_Approved_Step__c);
            processResult =  processResult_2;          
        }
        
        //Approve step 3 as User3   
        System.runAs(User3){ 
            Approval.ProcessWorkitemRequest ApproveRequest3 = new Approval.ProcessWorkitemRequest();
            ApproveRequest3.setComments('Approving CFR');
            ApproveRequest3.setAction('Approve');
            ApproveRequest3.setWorkitemId((processResult.newWorkItemIds)[0]);
            
            Approval.ProcessResult processResult_3 =  Approval.process(ApproveRequest3);
            // Verify the results
            System.assert(processResult_3.isSuccess(), 'Result Status:'+processResult_3.isSuccess());
            
            Capital_Requests__c CFR_AfterApproval_3 = HRCCFR_TestSetupData.getCapitalRequest('CapitalDeDupApproverTEST');
            System.assertEquals('3', CFR_AfterApproval_3.Last_Approved_Step__c); 
            processResult =  processResult_3;          
        }      
        
        
        //Approve step 4 as User3             
        //System.runAs(User3){  
            //Approval.ProcessWorkitemRequest ApproveRequest5 = new Approval.ProcessWorkitemRequest();
            //ApproveRequest5.setComments('Approving CFR');
            //ApproveRequest5.setAction('Approve');
            //ApproveRequest5.setWorkitemId((processResult.newWorkItemIds)[0]);
            
            //Approval.ProcessResult processResult_5 =  Approval.process(ApproveRequest5);
            // Verify the results
            //System.assert(processResult_5.isSuccess(), 'Result Status:'+processResult_5.isSuccess());
            
            //Capital_Requests__c CFR_AfterApproval_5 = HRCCFR_TestSetupData.getCapitalRequest('CapitalDeDupApproverTEST');
            //System.assertEquals('6', CFR_AfterApproval_5.Last_Approved_Step__c);      
            //processResult =  processResult_5 ;       
        //}
        Test.stopTest();
    }
   
    /**
    * Test method to test capital record for remove duplicate  Approver when step 3,7(Rental and Facility are false) are skipped and IT  and Safety are True
    */
   
    static testMethod void test_CapitalRentalTrueITFalse() {
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
            cr.Project_Manager_Supervisor__c = User1.id;
            cr.Does_project_require_IT_asset_purc__c = true;
            cr.Is_a_Safety_Issue__c = true;
            cr.Facilities_Impact__c = false;
            CR.Finance_Division_Lead__c = User1.id;
            
            insert cr;
            
            //Create child Capital Item - to make the CFR eligible for approval
            Capital_Iem__c ci = HRCCFR_TestSetupData.createCapitalItem(cr.id, 1000000);
            insert ci;
            
            Test.startTest();
            // Submit the CFR for Approval
            Approval.ProcessSubmitRequest SubmitRequest = new Approval.ProcessSubmitRequest();
            SubmitRequest.setComments('Submitting request for approval.');
            SubmitRequest.setObjectId(cr.id);
            Approval.ProcessResult result = Approval.process(SubmitRequest);  // Submit for approval 
            
            // Verify the result
            System.assert(result.isSuccess());
            System.assertEquals('Pending', result.getInstanceStatus(), 'Instance Status'+result.getInstanceStatus());
            
            // Approve the submitted request as PM
            // Instantiate the new ProcessWorkitemRequest object and populate it
            Approval.ProcessWorkitemRequest ApproveRequest1 = new Approval.ProcessWorkitemRequest();
            ApproveRequest1.setComments('Approving CFR');
            ApproveRequest1.setAction('Approve');
            ApproveRequest1.setWorkitemId((result.newWorkItemIds)[0]);
            
            Approval.ProcessResult processResult_1 =  Approval.process(ApproveRequest1);
            // Verify the results
            System.assert(processResult_1.isSuccess(), 'Result Status:'+processResult_1.isSuccess()); 
            
            Capital_Requests__c CFR_AfterApproval_1 = HRCCFR_TestSetupData.getCapitalRequest('CapitalDeDupApproverTEST');
            System.assertEquals('1', CFR_AfterApproval_1.Last_Approved_Step__c);            
            processResult = processResult_1;
            
        }//END RunAs    
        
        //Approve step 2 as User1
        System.runAs(User1){
            Approval.ProcessWorkitemRequest ApproveRequest2 = new Approval.ProcessWorkitemRequest();
            ApproveRequest2.setComments('Approving CFR');
            ApproveRequest2.setAction('Approve');
            ApproveRequest2.setWorkitemId((processResult.newWorkItemIds)[0]);
            
            Approval.ProcessResult processResult_2 =  Approval.process(ApproveRequest2);
            // Verify the results
            System.assert(processResult_2.isSuccess(), 'Result Status:'+processResult_2.isSuccess());
            
            Capital_Requests__c CFR_AfterApproval_2 = HRCCFR_TestSetupData.getCapitalRequest('CapitalDeDupApproverTEST');
            System.assertEquals('2', CFR_AfterApproval_2.Last_Approved_Step__c);
            processResult =  processResult_2;          
        }
        
        //Approve step 4 as User3             
        System.runAs(User3){ 
             
            Approval.ProcessWorkitemRequest ApproveRequest4 = new Approval.ProcessWorkitemRequest();
            ApproveRequest4.setComments('Approving CFR');
            ApproveRequest4.setAction('Approve');
            ApproveRequest4.setWorkitemId((processResult.newWorkItemIds)[0]);
            
            Approval.ProcessResult processResult_4 =  Approval.process(ApproveRequest4);
            // Verify the results
            System.assert(processResult_4.isSuccess(), 'Result Status:'+processResult_4.isSuccess());
            
            Capital_Requests__c CFR_AfterApproval_4 = HRCCFR_TestSetupData.getCapitalRequest('CapitalDeDupApproverTEST');
            System.assertEquals('3', CFR_AfterApproval_4.Last_Approved_Step__c);        
            processResult =  processResult_4 ;        
        }
        
        //Approve step 5 as User4             
        System.runAs(User4){  
            Approval.ProcessWorkitemRequest ApproveRequest5 = new Approval.ProcessWorkitemRequest();
            ApproveRequest5.setComments('Approving CFR');
            ApproveRequest5.setAction('Approve');
            ApproveRequest5.setWorkitemId((processResult.newWorkItemIds)[0]);
            
            Approval.ProcessResult processResult_5 =  Approval.process(ApproveRequest5);
            // Verify the results
            System.assert(processResult_5.isSuccess(), 'Result Status:'+processResult_5.isSuccess());
            
            Capital_Requests__c CFR_AfterApproval_5 = HRCCFR_TestSetupData.getCapitalRequest('CapitalDeDupApproverTEST');
            System.assertEquals('8', CFR_AfterApproval_5.Last_Approved_Step__c);      
            processResult =  processResult_5 ;       
        }
     
       //Approve step 6 as User1 (FixedAsset)            
        //System.runAs(User5){  
            //Approval.ProcessWorkitemRequest ApproveRequest6 = new Approval.ProcessWorkitemRequest();
            //ApproveRequest6.setComments('Approving CFR');
            //ApproveRequest6.setAction('Approve');
            //ApproveRequest6.setWorkitemId((processResult.newWorkItemIds)[0]);
            
            //Approval.ProcessResult processResult_6 =  Approval.process(ApproveRequest6);
            // Verify the results
            //System.assert(processResult_6.isSuccess(), 'Result Status:'+processResult_6.isSuccess());
            
            //Capital_Requests__c CFR_AfterApproval_6 = HRCCFR_TestSetupData.getCapitalRequest('CapitalDeDupApproverTEST');
            //System.assertEquals('9', CFR_AfterApproval_6.Last_Approved_Step__c);      
            //processResult =  processResult_6 ;  
        //}   
              
        Test.stopTest();
    } 
    
     /**
     * Test Lease Approval Process by rejecting the record at step 2 to verify that all the approvers who grant access by apex sharing there access is revoked
     */
//    static testMethod void test_LeaseRemoveDuplicateApprovers() {
//        Approval.ProcessResult processResult;
//        
//        Map<string,id> GroupNameIdMap = new Map<string,id>();
//        for(Group g: [select Id, name from Group where type= 'Queue']){
//            GroupNameIdMap.put(g.name, g.id);
//        }
//        
//        Id LeaseRecordTypeID = Schema.SObjectType.Capital_Requests__c.getRecordTypeInfosByName().get('CFR Lease').getRecordTypeId();
//        User User1     = HRCCFR_TestSetupData.getUser('HRC CFR Fixed Asset');
//        User User2     = HRCCFR_TestSetupData.getUser('HRC CFR Project Manager');
//        User User3     = HRCCFR_TestSetupData.getUser('HRC CFR Fixed Asset');
//        
//        System.runAs(User1){  
//            //Create CFR 
//            Capital_Requests__c cr = HRCCFR_TestSetupData.createCapitalRequest(LeaseRecordTypeID,'LeaseDeDupApproverTEST');
//            cr.Project_Manager__c  = User1.id;  
//            cr.Finance__c = User3.id;
//            cr.Business_Finance_Director__c = User1.id;
//            cr.Facilities__c = User1.id;
//            cr.Operations_VP__c = User1.id;
//            cr.Finance_Lead__c = User1.id;
//            cr.Senior_VP__c = User1.id;
//            
//            insert cr;
//            
//            //Create child Capital Item - to make the CFR eligible for approval
//            Capital_Iem__c ci = HRCCFR_TestSetupData.createCapitalItem(cr.id, 1000000);
//            insert ci;
//            
//            Test.startTest();
//            //Submit the CFR for Approval
//            Approval.ProcessSubmitRequest SubmitRequest = new Approval.ProcessSubmitRequest();
//            SubmitRequest.setComments('Submitting request for approval.');
//            SubmitRequest.setObjectId(cr.id);
//            Approval.ProcessResult result = Approval.process(SubmitRequest);  // Submit for approval 
//            
//            // Verify the result
//            System.assert(result.isSuccess());
//            System.assertEquals('Pending', result.getInstanceStatus(), 'Instance Status'+result.getInstanceStatus());
//            
//            // Approve the submitted request as PM
//            // Instantiate the new ProcessWorkitemRequest object and populate it
//            Approval.ProcessWorkitemRequest ApproveRequest1 = new Approval.ProcessWorkitemRequest();
//            ApproveRequest1.setComments('Approving CFR');
//            ApproveRequest1.setAction('Approve');
//            ApproveRequest1.setWorkitemId((result.newWorkItemIds)[0]);
//            
//            processResult =  Approval.process(ApproveRequest1);
//            // Verify the results
//            System.assert(processResult.isSuccess(), 'Result Status:'+processResult.isSuccess()); 
//            
//            Capital_Requests__c CFR_AfterApproval_1 = HRCCFR_TestSetupData.getCapitalRequest('LeaseDeDupApproverTEST');
//            System.assertEquals('1', CFR_AfterApproval_1.Last_Approved_Step__c);
//            
//        }//END RunAs    
//        
//        //Approve step 2 as User2
//        System.runAs(User2){
//            //Test to cover revoke of Sharing access to step owners while Reject Action
//            Approval.ProcessWorkitemRequest ApproveRequest2 = new Approval.ProcessWorkitemRequest();
//            ApproveRequest2.setComments('Reject CFR');
//            ApproveRequest2.setAction('Reject');
//            ApproveRequest2.setWorkitemId((processResult.newWorkItemIds)[0]);
//            
//            Approval.ProcessResult result3 =  Approval.process(ApproveRequest2);
//            // Verify the results
//            System.assert(result3.isSuccess(), 'Result Status:'+result3.isSuccess());
//            
//            Capital_Requests__c CFR_AfterApproval_2 = HRCCFR_TestSetupData.getCapitalRequest('LeaseDeDupApproverTEST');
//            
//        }
//        Test.stopTest();
//    }//End Method test_LeaseRemoveDuplicateApprovers
    
     /**
     * Test Lease Approval Process by Setting Area AVP as null to skip step 2 and progress the approval process
     */
//    static testMethod void test_LeaseAreaAVP_As_Null() {
//        Approval.ProcessResult processResult;
//        
//        Map<string,id> GroupNameIdMap = new Map<string,id>();
//        for(Group g: [select Id, name from Group where type= 'Queue']){
//            GroupNameIdMap.put(g.name, g.id);
//        }
//        
//        Id LeaseRecordTypeID = Schema.SObjectType.Capital_Requests__c.getRecordTypeInfosByName().get('CFR Lease').getRecordTypeId();
//        User User1     = HRCCFR_TestSetupData.getUser('HRC CFR Fixed Asset');
//        User User2     = HRCCFR_TestSetupData.getUser('HRC CFR Project Manager');
//        User User3     = HRCCFR_TestSetupData.getUser('HRC CFR Fixed Asset');
//        
//        System.runAs(User1){  
//            //Create CFR 
//            Capital_Requests__c cr = HRCCFR_TestSetupData.createCapitalRequest(LeaseRecordTypeID,'LeaseDeDupApproverTEST');
//            cr.Project_Manager__c  = User1.id;
//            cr.Area_AVP__c = User2.id;  
//            cr.Finance__c = User3.id;
//            cr.Business_Finance_Director__c = User1.id;
//            cr.Facilities__c = User1.id;
//            cr.Operations_VP__c = User1.id;
//            cr.Finance_Lead__c = User1.id;
//            cr.Senior_VP__c = User1.id;
//            cr.Op_Comp_CFO__c = User1.id;
//            
//            insert cr;
//            
//            //Create child Capital Item - to make the CFR eligible for approval
//            Capital_Iem__c ci      = HRCCFR_TestSetupData.createCapitalItem(cr.id, 1000000);
//            insert ci;
//            
//            Test.startTest();
//            //Submit the CFR for Approval
//            Approval.ProcessSubmitRequest SubmitRequest = new Approval.ProcessSubmitRequest();
//            SubmitRequest.setComments('Submitting request for approval.');
//            SubmitRequest.setObjectId(cr.id);
//            Approval.ProcessResult result = Approval.process(SubmitRequest);  // Submit for approval 
//            
//            // Verify the result
//            System.assert(result.isSuccess());
//            System.assertEquals('Pending', result.getInstanceStatus(), 'Instance Status'+result.getInstanceStatus());
//            
//            // Approve the submitted request as PM
//            // Instantiate the new ProcessWorkitemRequest object and populate it
//            Approval.ProcessWorkitemRequest ApproveRequest1 = new Approval.ProcessWorkitemRequest();
//            ApproveRequest1.setComments('Approving CFR');
//            ApproveRequest1.setAction('Approve');
//            ApproveRequest1.setWorkitemId((result.newWorkItemIds)[0]);
//            
//            processResult =  Approval.process(ApproveRequest1);
//            // Verify the results
//            System.assert(processResult.isSuccess(), 'Result Status:'+processResult.isSuccess()); 
//            
//            Capital_Requests__c CFR_AfterApproval_1 = HRCCFR_TestSetupData.getCapitalRequest('LeaseDeDupApproverTEST');
//            System.assertEquals('1', CFR_AfterApproval_1.Last_Approved_Step__c);
//            
//        }//END RunAs    
//        
//        //Approve step 3 as User3, Area AVP is null to Step 2 is skipped 
//        System.runAs(User3){
//            
//            Approval.ProcessWorkitemRequest ApproveRequest2 = new Approval.ProcessWorkitemRequest();
//            ApproveRequest2.setComments('Approve CFR');
//            ApproveRequest2.setAction('Approve');
//            ApproveRequest2.setWorkitemId((processResult.newWorkItemIds)[0]);
//            
//            Approval.ProcessResult result3 =  Approval.process(ApproveRequest2);
//            // Verify the results
//            System.assert(result3.isSuccess(), 'Result Status:'+result3.isSuccess());
//            
//            Capital_Requests__c CFR_AfterApproval_2 = HRCCFR_TestSetupData.getCapitalRequest('LeaseDeDupApproverTEST');
//            System.assertEquals('3', CFR_AfterApproval_2.Last_Approved_Step__c);
//        }
//        Test.stopTest();
//    }//End Method test_LeaseAreaAVP_As_Null
    

    /**
    * Method to test Addition of PM into Group (HRC CFR Project Manager) if PM is different than owner of the record
    */
    static testMethod void test_AddPMToGroup() {
        Id LeaseRecordTypeID = Schema.SObjectType.Capital_Requests__c.getRecordTypeInfosByName().get('CFR Lease').getRecordTypeId();
        User user1 = HRCCFR_TestSetupData.getUser('HRC CFR Project Manager');
        Capital_Requests__c cr = HRCCFR_TestSetupData.createCapitalRequest(LeaseRecordTypeID,'LeaseAddPMToGroupTEST');
        cr.Project_Manager__c = user1.id;
        
        Test.StartTest();
        insert cr;
        Test.StopTest();
    }
    
    
}//End Class