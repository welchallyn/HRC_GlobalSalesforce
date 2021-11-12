public with sharing class HRC_TerritoryInfoRedirect {
	
	public Integer userLevel {
		get {
            if(userLevel == null) {
            	if(HRC_Util.getIsAVPUser() || HRC_Util.getIsRVPUser() || HRC_Util.getIsVPUser()) {
            		userLevel = 2;
            	} else {
            		userLevel = 1;
            	}
            } 
            return userLevel; 
        }
        set;
	}
	
	public PageReference redirect() {
		
		String keyPrefix = Territory_Info__c.SObjectType.getDescribe().getKeyPrefix();
		PageReference pr = new PageReference('/' + keyPrefix + '?fcf=' + Label.HRC_TerritoryInfoRedirect );
		if(userLevel == 1) {
			List<Territory_Info__c> ti = [select Id from Territory_Info__c where OwnerId = :UserInfo.getUserId() limit 1];
			
			if(ti.size() > 0) {
				pr = new PageReference('/' + ti[0].Id);
				List<Attachment> a = [Select Id from Attachment where ParentId = :ti[0].Id limit 1];
				
				if(a.size() > 0) {
					pr = new PageReference('/' + a[0].Id);
				}
			}
		}
		
		return pr;
	}
}