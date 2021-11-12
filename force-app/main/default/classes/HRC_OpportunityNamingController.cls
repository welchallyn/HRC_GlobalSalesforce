public without sharing class HRC_OpportunityNamingController {
    
    public static void setOpportunityName( List<Opportunity> newOppsList, Map<id,Opportunity> oldOppsMap, Boolean isUpdate) {
    
        Set<Id> accountIds = new Set<Id>();
        Set<Id> recordTypeIds = new Set<Id>();
        List<Opportunity> relatedOpps = new List<Opportunity>();
        
		Profile pr = [select Name from Profile where Id = :UserInfo.getProfileId() limit 1];
		String validProfileNames = Label.OpportunityNaming;
		
		if(validProfileNames.indexOf(pr.Name) >= 0 || Test.isRunningTest()) {
	        for ( Opportunity opp : newOppsList ) {
	            if ( !isUpdate || ( isUpdate && ( opp.Name != oldOppsMap.get(opp.Id).Name || 
	                opp.AccountId != oldOppsMap.get(opp.Id).AccountId || opp.RecordTypeId != oldOppsMap.get(opp.Id).RecordTypeId ) ) ) {
	                
	                accountIds.add(opp.AccountId);
	                recordTypeIds.add(opp.RecordTypeId);
	                relatedOpps.add( opp );    
	                    
	            }
	        }
	        
	        Map<Id, Account> accountMap = new Map<Id, Account>([select Id, Name from Account where Id in :accountIds]);
	        Map<Id, RecordType> recordTypeMap = new Map<Id, RecordType>([select Id, Name from RecordType where Id in :recordTypeIds]);
	        
	        for( Opportunity opp : relatedOpps ) {
	        
	            Account acc = accountMap.get(opp.AccountId);
	            RecordType rType = recordTypeMap.get(opp.RecordTypeId);
	        
	            if (isUpdate) {
	                List<String> nameParts = opp.Name.split('~');
	                opp.Name = nameParts[nameParts.size()-1];
	            }
	            opp.Name = acc.Name + '-' + rType.Name + '~' +opp.Name;    
	        }
		}
        
    }

}