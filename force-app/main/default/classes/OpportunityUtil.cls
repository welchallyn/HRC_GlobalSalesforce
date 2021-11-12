/**
* @author Dan Nakonieczny, Model Metrics
* @date 11/9/2011

* @description This class contains a method that is called from the Opportunity trigger, to make sure that every time an Opportunity 
				is inserted or updated, the Opportunity's Account Team gets a Read Only access to the Opportunity
*/

public without sharing class OpportunityUtil {
	
	public static void evaluateOpportunitySharing(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap, Boolean isUpdate) {
		List<OpportunityShare> oppShares = new List<OpportunityShare>();
		Set<Id> accountIDs = new Set<Id>();
		Map<Id, Id> accountToOpportunityMap = new Map<Id, Id>();
		 
		
		for (Opportunity o : newMap.values()) {
			if (isUpdate) {
			//	if (oldMap.get(o.Id).AccountId != o.AccountId) {
					accountIds.add(o.AccountId);
					accountToOpportunityMap.put(o.AccountId, o.Id);
				//}
			} else {
				accountIds.add(o.AccountId);
				accountToOpportunityMap.put(o.AccountId, o.Id);
				
				
			}
		}

		List<AccountShare> atms = [select AccountId, AccountAccessLevel, OpportunityAccessLevel, RowCause, UserOrGroupId 
		                             from AccountShare 
									where AccountId in :accountIds
									  and (RowCause = 'Sales Team' or RowCause = 'Team')
									  and OpportunityAccessLevel = 'None'];
		
		for (AccountShare a : atms) {
			//throw new TestException('!!!');
			a.OpportunityAccessLevel = 'Edit';
		}
		
		update atms;
	}
	
}