trigger APTS_ProposalLineTgr on Apttus_Proposal__Proposal_Line_Item__c (After insert, Before delete) {

if (Trigger.isBefore) {
    if (Trigger.isDelete) {
         APTS_ProposalLineTgrHelper.deleteBundlesandOption(trigger.oldMap);
    }
}

if (Trigger.isAfter){
   if (Trigger.isInsert) {
         APTS_ProposalLineTgrHelper.categorizeBundlesandOptions(trigger.newMap); 
    }
  }

}