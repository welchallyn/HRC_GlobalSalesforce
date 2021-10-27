/***********************************************************************************************
* Name                             : HRCFSL_ServiceReportHelper_Mock
* Author                           : Capgemini
* Date                             : August/04/2020
* Requirement/Project Name         : Hill-Rom
* Requirement/Project Description  :  Class to
*                                   1. Test HRCFSL_ServiceReportHelper by using the mock class
* Revison                          :
/***********************************************************************************************/
public with sharing class HRCFSL_ServiceReportHelper_Mock implements HttpCalloutMock {
    /*******************************************************************************************************
    * Method Name: respond
    * Author: Capgemini
    * Date: August/04/2020
    * Params: request(HTTPRequest)
    * Return: HTTPResponse
    * Requirement : 1. Mock class for HRCFSL_ServiceReportHelper_Test test class that we will use to test
    *******************************************************************************************************/
    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        //setting expected response body
        response.setBody('[{"actionName":"createServiceReport","errors":null,"isSuccess":true,"outputValues":{"serviceReportId":"1SRL00000008PFWOA2","contentVersionId":"068L0000000fcMaIAI","entityId":"0WOL000000275BNOAY"}}]');
        response.setStatusCode(200);
        return response; 
    }
}