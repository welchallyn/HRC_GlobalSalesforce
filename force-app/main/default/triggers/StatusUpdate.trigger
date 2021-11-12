//if status is updated, update the evaluation form.
trigger StatusUpdate on Products_Requested__c (After Insert, After Update) {
    list<id> efid = new list<id>();
    list<Evaluation_Form__c> efsToUpdate = new list<Evaluation_Form__c>();
    list<Products_Requested__c> ProReq1 = new list<Products_Requested__c>();
    For (Products_Requested__c PR: Trigger.new)
    {
        list<Products_Requested__c> ProReq = [select id,Serial_Number__c,Evaluation_Form__c,Evaluation_Form__r.Serial_number_is_not_null__c from Products_Requested__c where Evaluation_Form__c =: pr.Evaluation_form__c LIMIT 49500];
        system.debug('*********'+ProReq.size());
        efid.add(pr.Evaluation_Form__c);
        system.debug('*********'+efid);
        for (integer i=0; i<ProReq.size(); i++)
        { 
            if (ProReq[i].Serial_Number__c == null)
            ProReq1.add(ProReq[i]);
        }
        if (ProReq1.size()== 0 && ProReq[0].Evaluation_Form__r.Serial_number_is_not_null__c != True ){
            list<Evaluation_Form__c> ef1 = [select id,Serial_number_is_not_null__c from Evaluation_Form__c where id in: efid LIMIT 49500];
            system.debug('*********'+ef1);
            ef1[0].Serial_number_is_not_null__c= True;
            efsToUpdate.add(ef1[0]);
		}  
    }
	try{
		update (efsToUpdate);
	}
	catch(Exception e){
		system.debug('Exception Occured..'+e);
	}
}