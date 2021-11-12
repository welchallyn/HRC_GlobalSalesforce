@isTest(seeAllData=false)
private class HRCCFRSendEmailRemainderHelperTest{
    static List<Capital_Requests__c> crInitList;
    static User userObj;
    static void initData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='HRC CFR Project Manager']; 
        userObj = new User(Alias = 'standt', Email='financialreviewertest@example.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='financialreviewer@testorg.com');
        
        insert userObj;
        
        List<RecordType> r = [select id from RecordType where SobjectType = 'Capital_Requests__c' and name='CFR Capital' limit 1];
        
        crInitList = new List<Capital_Requests__c>();
        
        
        for(integer i=0; i<5; i++){
            Capital_Requests__c crObj = new Capital_Requests__c();
            crObj.Status__c = 'Draft';
            crObj.Key_Assumptions__c = 'test';
            crObj.Project_Name__c = 'test name';  
            crObj.RecordTypeId = r[0].id;
            crObj.Financial_Analyst__c = userObj.id;
            crObj.Rejection_Comments_Required__c = 'Test';//Added Sindhu
            crInitList.add(crObj);
        }
        //Inserting list by user object
        System.runAs(userObj){
            insert crInitList;
        }
        
        
        List<Expense_Item__c> EIList = new List<Expense_Item__c>();
        for(Capital_Requests__c cr:crInitList){
            Expense_Item__c expenseItem =  new Expense_Item__c();
            expenseItem.Original__c = 50000;
            //expenseItem.CurrencyIsoCode = 'USD - U.S. Dollar';
            expenseItem.Expense_Item__c = 'Expense Item';
            expenseItem.Capital_Request__c = cr.id;
            EIList.add(expenseItem);
        }
        //Inserting list by user object
        System.runAs(userObj){
            insert EIList;
        }
    }
    
    static void RejectSubmittedRequest(Approval.ProcessResult Result)
    {
        List<Id> newWorkItemIds = result.getNewWorkitemIds();
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments('Rejected');
        req.setAction('Reject');
        req.setWorkitemId(newWorkItemIds[0]);
        // Submit the request for approval
        Approval.ProcessResult result2 =  Approval.process(req);
        
    }
    
    static testMethod void remEmailHelperTriggerTest() {
        
        initData();
        Test.startTest();
        List<Approval.ProcessResult> resultList = new List<Approval.ProcessResult>();
        for(Capital_Requests__c crObj: crInitList) {
            Approval.ProcessSubmitRequest crObjRequest = new Approval.ProcessSubmitRequest(); 
            crObjRequest.setObjectId(crObj.ID);  
            Approval.ProcessResult Result = Approval.Process(crObjRequest);
            resultList.add(Result);
            System.assert(Result.isSuccess());
            System.assertEquals('Pending', Result.getInstanceStatus(),'Instance Status : '+Result.getInstanceStatus());
        }
        
        System.runAs(userObj){
            for(Approval.ProcessResult r:resultList){
                RejectSubmittedRequest(r);
            }
        }
        
        Test.stopTest();
    }
}