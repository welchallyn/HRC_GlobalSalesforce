//when an evaluation form is cloned, also clone the children product requests and build the appropriate linkage to new parent. 
trigger cloned on Evaluation_Form__c (After insert) {
    List<Products_Requested__c> prList = new List<Products_Requested__c>();
	For (Evaluation_Form__c ef1: trigger.new)
	{
        for (Products_Requested__c prs: [select Frame_Surface__c,Item_Description__c,Opportunity_Type_Pick__c,Product_Type__c,
        Quantity__c,External_Delivery__c,Serial_Number__c,Sold_Unit__c,Specifics__c,Work_Order_In__c,Work_Order_Out__c 
        from Products_Requested__c where Evaluation_Form__c =:ef1.record_id__c LIMIT 49500])
        {
            Products_Requested__c prod = new Products_Requested__c();
            prod.Frame_Surface__c = prs.Frame_Surface__c;
            prod.Item_Description__c = prs.Item_Description__c;
            prod.Opportunity_Type_Pick__c = prs.Opportunity_Type_Pick__c;
            prod.Product_Type__c= prs.Product_Type__c;
            prod.Quantity__c= prs.Quantity__c;
            prod.External_Delivery__c= prs.External_Delivery__c;
            prod.Serial_Number__c= prs.Serial_Number__c;
            prod.Sold_Unit__c= prs.Sold_Unit__c;
            prod.Specifics__c= prs.Specifics__c;
            prod.Work_Order_In__c= prs.Work_Order_In__c;
            prod.Work_Order_Out__c= prs.Work_Order_Out__c;
            prod.Evaluation_Form__c = ef1.id;
            prList.add(prod);
        }
    }
    try{
		insert prList;
	}
	catch(Exception e){
		system.debug('Exception Occured..'+e);
	}
}