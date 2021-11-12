public class HRC_CFR_SupplementalInvokeAPI {
	@InvocableMethod
    public static void invokeapexcallout(list<Capital_Requests__c> capitalReqData) {
        system.debug('capitalReqData====>>>'+capitalReqData);
        //if(!System.isFuture() && !System.isBatch()){
           //HRC_CapitalRequestAPI.apexcalloutSupplemental(capitalReqData[0].Supplemental__c,capitalReqData[0].Project_Name__c,capitalReqData[0].id);
           HRC_CapitalRequestAPI.apexcalloutSupplemental(capitalReqData[0].Supplemental_Check__c,capitalReqData[0].Project_Name__c,capitalReqData[0].id);
        //}
    }
}