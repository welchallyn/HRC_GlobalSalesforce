/*
 *  @author: Nimit Shah
 *  @date: 2014-07-02
 *  @description:
 *      Submit approval request for proposal line items 
 *      from proposal level.
 */
public class APTS_SubmitRequest{
    
    public Id objId {get;set;}
    public Boolean bValidated {get;set;}
    
    public void submitRequest()
    {
        List<Apttus_Proposal__Proposal__c> lstProposal = [Select Name,Apttus_Proposal__Approval_Stage__c from Apttus_Proposal__Proposal__c where Id=: objId limit 1];
        
        Integer iApprovalNotRequired = 0;
        if(lstProposal.size()> 0)
        {
            List<Apttus_Proposal__Proposal_Line_Item__c> lstProposalLines = [Select Id,Apttus_QPConfig__LineType__c from Apttus_Proposal__Proposal_Line_Item__c
                                                                            where APTPS_Quote_Id__c=: lstProposal[0].Name and Apttus_QPConfig__LineType__c = 'Product/Service'];

            for(Apttus_Proposal__Proposal_Line_Item__c objProposalLine : lstProposalLines)
            {
                try
                {
                    Approval.ProcessSubmitRequest objProposalSubmitReq = new Approval.ProcessSubmitRequest();
                    objProposalSubmitReq.setComments('Submitting request for approval from Proposal.');
                    objProposalSubmitReq.setObjectId(objProposalLine.id);
                    Approval.ProcessResult objProcessResult = Approval.process(objProposalSubmitReq);
                }
                catch(Exception ex)
                {
                    system.debug('Exception from ProcessSubmitRequest: '+ ex.getMessage());
                    iApprovalNotRequired++;
                }                    
            }
            
            if(iApprovalNotRequired == lstProposalLines.size())
            {
                lstProposal[0].Apttus_Proposal__Approval_Stage__c = 'Approved';
                update lstProposal;
            }
        }
        
        bValidated = true;
    }
 
    public pageReference redirectToProposal()
    {
        bValidated = false;
        PageReference pageRef = new PageReference('/' + objId);
        pageRef.setRedirect(false);
        return pageRef;
    }
    
    public APTS_SubmitRequest()
    {
        
    }
    
    public APTS_SubmitRequest(ApexPages.StandardController controller) 
    {
        bValidated = false;
        objId = ApexPages.currentPage().getParameters().get('id');
    }
}