/*
 *  @author: Nimit Shah
 *  @date: 2014-07-09
 *  @description:
 *      This trigger will check approval status of all the proposal line items.
 *      If any item is having status as pending approval, this will update proposal status
 *      as pending approval, if any item is having status as rejectd, this will update 
 *      proposal status as rejected and if all the line items are approved then proposal 
 *      status will be approved.
 */
trigger APTS_SubmitApprovalTrigger on Apttus_Proposal__Proposal_Line_Item__c (after update) {
    
    Map<Id,List<Apttus_Proposal__Proposal_Line_Item__c>> propLineMap = new Map<Id,List<Apttus_Proposal__Proposal_Line_Item__c>>();
    Set<Id> propIdSet = new Set<Id>();
    Map<Id,string> propIDStatusMap = new Map<Id,string>();
    string strStatus = '';
    for(Apttus_Proposal__Proposal_Line_Item__c propLine : Trigger.new)
    {
        propIdSet.add(propLine.Apttus_Proposal__Proposal__c);
    }    

    if(propIdSet.size()>0)
    {
        List<Apttus_Proposal__Proposal_Line_Item__c> propLineList = [Select Id,Apttus_QPConfig__LineType__c,APTPS_Approval_Status__c,Apttus_Proposal__Proposal__c from Apttus_Proposal__Proposal_Line_Item__c
                                                                     where Apttus_Proposal__Proposal__c in :propIdSet and Apttus_QPConfig__LineType__c = 'Product/Service'];
        for(Apttus_Proposal__Proposal_Line_Item__c propLine : propLineList)
        {
            List<Apttus_Proposal__Proposal_Line_Item__c> newLineList;
            if(propLineMap.containsKey(propLine.Apttus_Proposal__Proposal__c))
            {
                newLineList = propLineMap.get(propLine.Apttus_Proposal__Proposal__c);
            }
            else
            {
                newLineList = new List<Apttus_Proposal__Proposal_Line_Item__c>();
            }
            newLineList.add(propLine);
            propLineMap.put(propLine.Apttus_Proposal__Proposal__c,newLineList);
        }
        for(Id propId : propLineMap.keySet())
        {
            strStatus = '';
            for(Apttus_Proposal__Proposal_Line_Item__c propLine : propLineMap.get(propId))
            {
                strStatus = strStatus + ',' + propLine.APTPS_Approval_Status__c;      
            }
            if(strStatus.containsIgnoreCase('Pending Approval'))
            {    
                propIDStatusMap.put(propId, 'Pending Approval');
            }
            else if(strStatus.containsIgnoreCase('Rejected'))
            {
                propIDStatusMap.put(propId, 'Rejected');
            }
            else if(strStatus.containsIgnoreCase('Approved'))
            {
                propIDStatusMap.put(propId, 'Approved');
            }
        }
        if(propIDStatusMap.size()>0)
        {
            List<Apttus_Proposal__Proposal__c> updatedpropList = [select ID,Apttus_Proposal__Approval_Stage__c from Apttus_Proposal__Proposal__c where Id in:propIDStatusMap.keySet()];
            for(Apttus_Proposal__Proposal__c prop :  updatedpropList)
            {
                prop.Apttus_Proposal__Approval_Stage__c = propIDStatusMap.get(prop.Id);
            }
            update updatedpropList;
        }
    }    
}