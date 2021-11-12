/*
 Update: 
vrs
Approvers population to 
Level_1_Approver__c
Level_2_Approver__c

Level_1_ApproverLevel_1_Approver__c
Level_2_Approver__c_ID__c
Level_2_Approver_ID__c  

*/
trigger APTPS_QuoteProposalMasterTrigger on Apttus_Proposal__Proposal__c (after insert, after update, before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) 
            APTPS_QuoteProposalTriggerHandler.setNewProposal(Trigger.new);
        
        if (Trigger.isUpdate)    
        {
            for (Apttus_Proposal__Proposal__c objProposal : Trigger.new)
            {
                Apttus_Proposal__Proposal__c oldProposal = Trigger.oldMap.get(objProposal.Id);
                if(oldProposal.Is_Expired__c == true && objProposal.Is_Expired__c == true)
                {
                     Trigger.new[0].addError('Proposal is expired. You can not make changes to expired proposal.');
                }
            }
            APTPS_QuoteProposalTriggerHandler.resetContract(Trigger.new, Trigger.oldMap);            
            APTPS_QuoteProposalTriggerHandler.populateApprovers(trigger.new);
        }
            
    }
}