/*************************************************************************************************************
* Class Name                       : HRCSVC21_SoldToJDEIntegrationTest
* Author						   : Capgemini
* Date                             : Dec/03/2021
* Requirement/Project Name         : Hill-Rom
* Requirement/Project Description  : Test class for HRCSVC21_SoldToJDEIntegration
***************************************************************************************************************/
@isTest
public class HRCSVC21_SoldToJDEIntegrationTest implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        String fullJson = '{\n  \"soldToCustomerId\": 600077\n}';
        HTTPResponse res = new HTTPResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(fullJson);
        res.setStatusCode(200);
        return res;
    }
     
	@isTest
	static void testCallout() {
        try{
    	     
		// Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new HRCSVC21_SoldToJDEIntegrationTest());
        Test.startTest();
        Schema.Location loc = HRCFSL_TestUtilityClass.createCustomer(true, 'Customer1234');  
        List<Id> ordList= new List<Id>();
    	order__c ord1 = new Order__c(Name='CG',HRCSVC_ERP_Order_Number__c='CG',Proposal_Date__c=system.today(),
                                         HRCSVC_Proposal_Date__c=system.today(),HRCSVC_Ship_To_Location__c=loc.id,HRCSVC_Patient_First_Name__c='John',HRCSVC_Patient_Last_Name__c='Mrak');
        insert ord1;
        ordList.add(ord1.Id);
            
        HRCSVC21_SoldToJDEIntegration.soldToFetch(ordList);

        //HttpResponse res1 = http.send(res);
        //String result=res.getBody();
       /* if(res.getStatusCode() == 200){
        Map<String, String> mapOrd = (Map<String, String>) JSON.deserialize(res, Map<String, String>.class);
            
        }else{
                Map<String, Object> mapJSON = (Map<String, Object>) JSON.deserializeUntyped(result);
                Map<String, Object> errors = (Map<String, Object>)mapJSON.get('error');
                String errorMessage = String.valueOf(errors.get('message'));
            }
         */
	    Test.stopTest();      
        }catch(Exception e){
            system.debug('Error In Line'+e.getLineNumber()+'Cause-'+e.getCause()+e.getStackTraceString());
        }
    }
        
 }