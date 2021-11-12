/**
 * @author Nathan Shinn, Model Metrics
 * @date 05/16/2012
 * @description Grants access to patient and physician accounts based on relationships loaded into the junction objects by ETL (data loader) processes.
 */

global without sharing class AccountSharingBatchJob implements Database.Batchable<sObject>{
	private string query;
	
	public AccountSharingBatchJob(string q) {
		this.query = q;
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
		
		update atms;
   }

   global void finish(Database.BatchableContext BC){

   }
}