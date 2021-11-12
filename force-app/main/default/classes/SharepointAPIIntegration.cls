public class SharepointAPIIntegration {
	@AuraEnabled
    public static String doCallout(String accountId){
        List<Additional_Account_Info__c> existingAccountInfoList = new List<Additional_Account_Info__c>();
        existingAccountInfoList = [Select Id from Additional_Account_Info__c where Account__c = :accountId AND Document_Store_Link__c !=null ];
        if(existingAccountInfoList.size() > 0){
            return 'Sharepoint link already exist';
        }
        String returnValue = '';
        try{
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:Document_Store?parentFolder='+accountId+'&childFolder='+System.Label.Sharepoint_Child_Folders);
            req.setHeader('X-Correlation-ID', '1234');
            req.setHeader('client_id', '{!$Credential.UserName}');
            req.setHeader('client_secret', '{!$Credential.Password}');
            req.setHeader('Content-Type', 'application/json;charset=UTF-8');
            req.setMethod('GET');
            req.setTimeout(120000); //120000
            Http http = new Http();
            HTTPResponse res = http.send(req);
            STring documentTypeId = Schema.SObjectType.Additional_Account_Info__c.getRecordTypeInfosByName().get('Document Store').getRecordTypeId();
            if(res.getStatus() == 'OK' && res.getStatusCode() == 200){
                List<Additional_Account_Info__c> accountInfoList = [Select id from Additional_Account_Info__c where Document_Store_Link__c = null AND Account__c = :accountId AND Name = 'Document Store Error' And recordTypeId = :documentTypeId];
                if(accountInfoList.size() > 0){
                    delete accountInfoList;
                }
                Additional_Account_Info__c accountInfo = new Additional_Account_Info__c();
                if(!Test.isRunningTest()){
                	accountInfo.Account__c = accountId;
                }
                accountInfo.Name = 'Document Store';
                accountInfo.RecordTypeId = Schema.SObjectType.Additional_Account_Info__c.getRecordTypeInfosByName().get('Document Store').getRecordTypeId();
                accountInfo.Document_Store_Link__c = System.Label.Sharepoint_Link + accountId;
                
                insert accountInfo;
                returnValue = 'success';
            }
            else if(res.getStatusCode() != 200){
                Additional_Account_Info__c accountInfo = new Additional_Account_Info__c();
                accountInfo.Account__c = accountId;
                accountInfo.Name = 'Document Store Error';
                accountInfo.RecordTypeId = Schema.SObjectType.Additional_Account_Info__c.getRecordTypeInfosByName().get('Document Store').getRecordTypeId();
                accountInfo.Document_Store_Error__c = 'Response Status: ' + res.getStatus() + 'Response code : '+res.getStatusCode() + ' ' + res.getBody();
                insert accountInfo;
                returnValue = 'error';
            }
            return returnValue;
        }
        catch(Exception e){
            Additional_Account_Info__c accountInfo = new Additional_Account_Info__c();
            accountInfo.Account__c = accountId;
            accountInfo.Name = 'Document Store Error';
            accountInfo.RecordTypeId = Schema.SObjectType.Additional_Account_Info__c.getRecordTypeInfosByName().get('Document Store').getRecordTypeId();
            accountInfo.Document_Store_Error__c = 'Error Message: ' + e.getMessage();
            insert accountInfo;
            returnValue = 'error';
            return returnValue;
        }
    }
}