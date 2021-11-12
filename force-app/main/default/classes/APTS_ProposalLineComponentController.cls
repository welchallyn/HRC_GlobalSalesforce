public class APTS_ProposalLineComponentController {
    public String proposalId;
    
    public List<Apttus_Proposal__Proposal_Line_Item__c> proposalLines{get; set;}
    public APTS_ProposalLineComponentController() {
        proposalLines = [Select Id,Name,Apttus_Proposal__Description__c,Apttus_QPConfig__Quantity2__c,Apttus_Proposal__Proposal_Line_Item__c.Extended_List_Price__c,Apttus_Proposal__Proposal_Line_Item__c.Extended_Net_Price_template__c,Apttus_QPConfig__SellingTerm__c,Product_or_Option_Name__c,APTPS_Quantity__c,APTPS_Extended_Price__c,Net_Price_Short__c,APTPS_Effective_Disocunt__c from Apttus_Proposal__Proposal_Line_Item__c where Apttus_Proposal__Proposal__c = :proposalId];
        proposalId = '123';
    }
    
    public void setProposalId (String s) {
       proposalId = s;
       proposalLines = [Select Id,Name,Apttus_Proposal__Description__c,Apttus_QPConfig__Quantity2__c,Apttus_Proposal__Proposal_Line_Item__c.Extended_List_Price__c,Apttus_Proposal__Proposal_Line_Item__c.Extended_Net_Price_template__c,Apttus_QPConfig__SellingTerm__c,Product_or_Option_Name__c,APTPS_Quantity__c,Net_Price_Short__c,APTPS_Effective_Disocunt__c from Apttus_Proposal__Proposal_Line_Item__c where Apttus_Proposal__Proposal__c = :proposalId];
    }
        
    public String getProposalId() {
       return proposalId;
    } 
}