@isTest
global class HRC_CFR_CalloutTest implements HttpCalloutMock{
    
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        String username = '193da86ca9f3444d9f69c75c02f832f1';
        String password = '81260C39841246E7b750Ac67C0C2a269';
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' +
        EncodingUtil.base64Encode(headerValue);
        response.setHeader('Authorization', authorizationHeader);
        response.setHeader('Content-Type', 'application/json;charset=UTF-8');
        /*response.setHeader('client_id','8dbb30047f8c46428cf7511fc7c6f8c7');
        response.setHeader('client_secret','AD9429b1244342D6ba068c6B25085438');
        response.setHeader('X-Correlation-ID','ewrjklj3435');*/
        String endpoint= request.getEndpoint();
        response.setBody('{"status":"S","message":"Person responsible defaulted to 999. Correct the entry","projectNumber":"5000-CP-0094"}');
        response.setStatusCode(200);
        return response; 
    }
}