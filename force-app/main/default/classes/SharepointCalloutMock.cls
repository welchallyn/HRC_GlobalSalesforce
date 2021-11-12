@isTest
global class SharepointCalloutMock implements HttpCalloutMock {
	global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(200);
        response.setStatus('OK');
        system.debug('response '+response);
        return response; 
    }
}