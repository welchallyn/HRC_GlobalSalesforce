trigger APTS_Approvers on Apttus_Proposal__Proposal_Line_Item__c (before insert) {
    
    Set<Id> quoteIds = new Set<Id>();
    
    for(Apttus_Proposal__Proposal_Line_Item__c proLine : Trigger.New){
        
        quoteIds.add(proLine.Apttus_Proposal__Proposal__c);
    }
    
    if(!quoteIds.isEmpty()){
        
        Map<Id, Apttus_Proposal__Proposal__c> mapIdQuote = new Map<Id, Apttus_Proposal__Proposal__c>([SELECT Id,OwnerId, 
        APTPS_Level_2_Approver__c,APTPS_Level_3_Approver__c,APTPS_Level_4_Approver__c FROM Apttus_Proposal__Proposal__c 
        WHERE Id IN :quoteIds]);
        
        for(Apttus_Proposal__Proposal_Line_Item__c proLine : Trigger.New){
            
            proLine.APTS_Level_1_Approver__c = mapIdQuote.get(proLine.Apttus_Proposal__Proposal__c).OwnerId;
            proLine.APTS_Level_2_Approver__c = mapIdQuote.get(proLine.Apttus_Proposal__Proposal__c).APTPS_Level_2_Approver__c;
            proLine.APTS_Level_3_Approver__c = mapIdQuote.get(proLine.Apttus_Proposal__Proposal__c).APTPS_Level_3_Approver__c;
            proLine.APTS_Level_4_Approver__c = mapIdQuote.get(proLine.Apttus_Proposal__Proposal__c).APTPS_Level_4_Approver__c; 
        }
    }
}