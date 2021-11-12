public class HRC_CapitaRequestInvokeAPI {
	@InvocableMethod
    public static void invokeapexcallout(list<Capital_Requests__c> capitalReqData) {
      system.debug('capitalReqData====>>>'+capitalReqData);
      HRC_CapitalRequestAPI.apexcallout(capitalReqData[0].Status__c,capitalReqData[0].Project_Name__c,capitalReqData[0].id);
    }
}