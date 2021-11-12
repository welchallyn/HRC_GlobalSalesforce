/*
 *  ClassName    : BatchAlignOpportunityOwnerTest
 *  CreatedOn    : 31/Oct/2017
 *  ModifiedOn   : 31/Oct/2017
 *  CreatedBy    : Jenish Shingala
 *  ModifiedBy   : Jenish Shingala
 *  Description  : Test class for BatchAlignOpportunityOwner Batch Class.
 */
@isTest
public with sharing class BatchAlignOpportunityOwnerTest{

    public static testMethod void test() {
        //Insert an Account.
        Account objAccount= new Account();
        objAccount.name = 'Test Account';
        objAccount.BillingCity = 'Pune';
        objAccount.BillingCountry = 'India';
        objAccount.BillingPostalCode = '411033';
       // objAccount.LIKO_Level_2_Emp_Num__c = 'test44';
        // objAccount.LIKO_Level_3_Emp_Num__c = 'test33';
        
        insert objAccount;
        
        //Insert a Contact.
        Contact objContact = new Contact();
        objContact.FirstName = 'test first name';
        objContact.lastname = 'test last name';
        objContact.accountid = objAccount.id;
        objContact.Email = 'testname@apttus.com';
        objContact.Department_UK__c = 'Finance';
        objContact.Role__c = 'Administrator';
        insert objContact;
        
        string opprecordtypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CWS').getRecordTypeId();
        
        //Insert Opportunity.
        Opportunity objOpp = new Opportunity();
        objOpp.accountid = objAccount.id;
        objOpp.name = 'Test name';
        objOpp.StageName = 'Developing Opportunity';
        objOpp.CloseDate = Date.today().adddays(1);
        objOpp.Project_Type_Rental__c = 'Asset Advantage';
        objOpp.Order_Contact__c = objContact.id;
        objOpp.recordtypeid = opprecordtypeid;
        insert objOpp;
        
        //Insert Custom setting.
        
        Opportunity_Record_Type_Position_Map__c objMapTest = new Opportunity_Record_Type_Position_Map__c();
        objMapTest.Name = 'HITS';
        objMapTest.Positions__c = 'ITSE,CN-WFPM,AM,CM,ACM,ESSS01,ESSS02';
        insert objMapTest;
        
        //Insert User.
        Profile p = [SELECT Id FROM Profile WHERE Name='HRC CFR Project Manager']; 
        User userObj  = new User(Alias = 'standt', Email='financialreviewertest@example.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='financialreviewer@testorg.com',jde_external_id__c = 'test33');
        
        insert userObj;
        
        //Insert Account Team Role.
        Account_Team_Role__c objAccountTeamRole = new Account_Team_Role__c();
        objAccountTeamRole.AccountId__c = objAccount.id;
        objAccountTeamRole.UserId__c = userObj.id;
        objAccountTeamRole.Position__c = 'ITSE';
        insert objAccountTeamRole;
        
        Test.StartTest();
        BatchAlignOpportunityOwner objCls = new BatchAlignOpportunityOwner();
        ID batchprocessid = Database.executeBatch(objCls);
        Test.StopTest();
        
        system.assertEquals('ITSE',objAccountTeamRole.Position__c);


    }

}