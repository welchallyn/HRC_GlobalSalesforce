global class HRC_CapitalRequestAPI{
    @AuraEnabled@future(Callout=true)
    webservice static void apexcallout(string status,string projectName,Id capitalReqId){
        system.debug('status====>>'+status+'    projectName======>>>'+projectName+'   capitalReqId===>>'+capitalReqId);
        Http http = new Http();
        Capital_Requests__c cfr = new Capital_Requests__c();
        List<Capital_Requests__c> cfrList = new List<Capital_Requests__c>();
        List<Capital_Requests__c> cfrList1 = new List<Capital_Requests__c>();
       // String body = 'ricefwId=""RI156"&projectName=projectName';
        HttpRequest request = new HttpRequest();
        /* Production Login Credentials
           String username = '193da86ca9f3444d9f69c75c02f832f1';
           String password = '81260C39841246E7b750Ac67C0C2a269';*/
        
        /* Commented on 25/10/2020
           QA Login Credentials*/
           String username = '8d8d92dd6eb44b6f9af7ca8039718381';
           String password = 'f858Ca1256bd4F3c8397715f4b852aBB';
        /*Commented on 25/10/2020*/
        
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' +
        EncodingUtil.base64Encode(headerValue);
        request.setHeader('Authorization', authorizationHeader);
        
        //Production URL
        //request.setEndpoint('https://api.hillrom.com/interfacetrigger-prc-api/api/interface');
        //request.setEndpoint('https://api-test.hillrom.com/interfacetrigger-prc-api-prd/api/interface');
        /*QA URL*/
          request.setEndpoint('https://api-test.hillrom.com/interfacetrigger-prc-api-qa/api/interface');
         // request.setEndpoint('callout:Mulesoft_Integration/interfacetrigger-prc-api/api/interface');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        
        
        /* Commented on 14/9/2020
        request.setEndpoint('https://anypoint.mulesoft.com/mocking/api/v1/links/35fcc72a-b9e4-43a7-b0bd-8960b69ba070/interface');
        request.setEndpoint('https://api-test.hillrom.com/interfacetrigger-prc-api/api/interface');
        request.setHeader('client_id','wer234353');
        request.setHeader('client_secret','wek345345');  
        request.setHeader('X-Correlation-ID','ewrjklj3435');
        request.setHeader('client_id','8dbb30047f8c46428cf7511fc7c6f8c7');
        request.setHeader('client_secret','AD9429b1244342D6ba068c6B25085438');
        request.setBody('{"ricefwId":"RI156","projectName":"'+projectName+'"}');
        Commented on 14/9/2020 */
      
        request.setBody('{"interface-action":"projectCreation","ID":"'+capitalReqId+'","projectName":"'+projectName+'"}');
        system.debug('setBody====>>>'+request.getBody());
        HttpResponse res = http.send(request);
        String result=res.getBody();
        System.debug('Recieved Body Data======>>>'+result);
        ResponseWrapper resW = (ResponseWrapper)JSON.deserializeStrict(result, ResponseWrapper.class);
        system.debug('resW===>>'+resW); 
        String intMessage = resW.message;
        String projNum = resW.projectNumber;
        String responseStatus = resW.status;
        system.debug('projNum===>>'+projNum);   
        system.debug('intMessage===>>'+intMessage);
        System.debug('responseStatus====>>'+responseStatus);
        cfrList = [Select Id,SAP_CFR_Number__c,SAP_Integration_Message__c,SAP_Integration_Status__c from Capital_Requests__c where ID=:capitalReqId];
        
        for(Capital_Requests__c cfrData:cfrList){
            cfrData.SAP_CFR_Number__c = projNum;
            cfrData.SAP_Integration_Message__c = intMessage;
            if(responseStatus=='S'){
                cfrData.SAP_Integration_Status__c = 'Success';
            }else{
                cfrData.SAP_Integration_Status__c = responseStatus;
            }
            system.debug('cfrData.SAP_CFR_Number__c===>>>'+cfrData.SAP_CFR_Number__c);
            system.debug('cfrData.SAP_Integration_Message__c===>>>'+cfrData.SAP_Integration_Message__c);
            system.debug('cfrData.SAP_Integration_Status__c===>>>'+cfrData.SAP_Integration_Status__c);
            cfrList1.add(cfrData);
        }
        update cfrList1;
    }
    
    
    
    
    @future(Callout=true)
    public static void apexcalloutSupplemental(Boolean isSupplemental,string projectName,Id capitalReqId){
        system.debug('Supplemental__c====>>'+isSupplemental+'projectName======>>>'+projectName+'capitalReqId===>>'+capitalReqId);
        // Instantiate a new http object
        Http http = new Http();
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        Capital_Requests__c cfr = new Capital_Requests__c();
        List<Capital_Requests__c> cfrList = new List<Capital_Requests__c>();
        List<Capital_Requests__c> cfrList1 = new List<Capital_Requests__c>();
        HttpRequest request = new HttpRequest();
        /* Production Credentials
        String username = '193da86ca9f3444d9f69c75c02f832f1';
        String password = '81260C39841246E7b750Ac67C0C2a269';*/
        
        /* Commented on 25/10/2020
         * QA Login Credentials*/
           String username = '8d8d92dd6eb44b6f9af7ca8039718381';
           String password = 'f858Ca1256bd4F3c8397715f4b852aBB';
        /*Commented on 25/10/2020*/
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' +
        EncodingUtil.base64Encode(headerValue);
        request.setHeader('Authorization', authorizationHeader);
        /*Commented on 25/10/2020
         * request.setEndpoint('https://anypoint.mulesoft.com/mocking/api/v1/links/35fcc72a-b9e4-43a7-b0bd-8960b69ba070/interface');
         * Dev URL-->> request.setEndpoint('https://api-test.hillrom.com/interfacetrigger-prc-api/api/interface');
         * QA URL-->>*/ request.setEndpoint('https://api-test.hillrom.com/interfacetrigger-prc-api-qa/api/interface');
         /*Commented on 25/10/2020*/
        
        //Production URL
        //request.setEndpoint('https://api.hillrom.com/interfacetrigger-prc-api/api/interface');
        //request.setEndpoint('https://api-test.hillrom.com/interfacetrigger-prc-api-prd/api/interface');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        
        /* Commented on 14/9/2020
           request.setHeader('client_id','8dbb30047f8c46428cf7511fc7c6f8c7');
           request.setHeader('client_secret','AD9429b1244342D6ba068c6B25085438');
           request.setBody('{"ricefwId":"RI154","projectName":"'+projectName+'"}');
           request.setHeader('client_id','wer234353');
           request.setHeader('client_secret','wek345345');
        Commented on 14/9/2020*/
        
        request.setBody('{"interface-action":"budgetUpdate","ID":"'+capitalReqId+'","projectName":"'+projectName+'"}');
        // Send the request, and return a response
        HttpResponse res = http.send(request);
        String result=res.getBody();
        System.debug('Recieved Body Data======>>>'+result);
        ResponseWrapper resW = (ResponseWrapper)JSON.deserializeStrict(result, ResponseWrapper.class);
        system.debug('resW===>>'+resW); 
        String intMessage = resW.message;
        String responseStatus = resW.status;
        //String projNum = resW.projectNumber;
        //system.debug('projNum===>>'+projNum);   
        system.debug('intMessage===>>'+intMessage);
        
        cfrList = [Select Id,SAP_Suppl_Integration_message__c,SAP_Suppl_Integration_status__c from Capital_Requests__c where ID=:capitalReqId];
        
        for(Capital_Requests__c cfrData:cfrList){
            cfrData.SAP_Suppl_Integration_message__c = intMessage;
            if(responseStatus=='S'){
                cfrData.SAP_Suppl_Integration_status__c = 'Success';
            }else{
                cfrData.SAP_Suppl_Integration_status__c = 'F';//res.getStatus();
                cfrData.Supplemental__c = false;
            }
            //system.debug('cfrData.SAP_CFR_Number__c===>>>'+cfrData.SAP_CFR_Number__c);
            system.debug('cfrData.SAP_Suppl_Integration_message__c===>>>'+cfrData.SAP_Suppl_Integration_message__c);
            system.debug('cfrData.SAP_Suppl_Integration_status__c===>>>'+cfrData.SAP_Suppl_Integration_status__c);
            system.debug('cfrData+++++>>>'+cfrData);
            cfrList1.add(cfrData);
            system.debug('cfrList1=====>>>'+cfrList1);
        }
        update cfrList1;
    }
    
}