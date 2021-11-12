/**
* @author Dan Nakonieczny, Model Metrics
* @date 11/9/2011

* @description This class is scheduled to run every night and evaluate all the sharing for Opportunities, so that each Opportunity Account's
                Team Member will have a Read Only access to all the Opportunities under the Account
*/

global without sharing class OpportunitySharingBatchJob implements Database.Batchable<sObject>{
    private string query;
    private DateTime startDateTime;
    
    public OpportunitySharingBatchJob(string q) {
        this.query = q;
        this.startDateTime = System.Now();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        List<Account> sList = (List<Account>)scope;
        
        List<AccountShare> atms = [select AccountId, AccountAccessLevel, OpportunityAccessLevel, RowCause, UserOrGroupId from AccountShare 
                                    where AccountId in :sList
                                    and (RowCause = 'Sales Team' or RowCause = 'Team')
                                    and OpportunityAccessLevel = 'None'];
        
        for (AccountShare a : atms) {
            a.OpportunityAccessLevel = 'Edit';  //going to give all team members full access, but restrict via the trigger.
        }
        
        list<Database.Saveresult> results = Database.update(atms, false);
        //Error Logging
        list<Error_Log__c> logs = new list<Error_Log__c>();
        for(Database.Saveresult res : results)
        {
            if(!res.isSuccess())
            {
                Error_Log__c log = new Error_Log__c(Class_name__c = 'OpportunitySharingBatchJob'
                                                   ,Date_time_started__c = startDateTime
                                                   ,Date_time_ended__c = System.now()
                                                   ,Error_message__c = res.getErrors()[0].getMessage()
                                                   ,Record_Id__c = res.getId());
                logs.add(log);
            }
        }
        
        //insert log files when there are errors
        if(logs.size() > 0)
          insert logs;
        
   }

   global void finish(Database.BatchableContext BC){

   }
}