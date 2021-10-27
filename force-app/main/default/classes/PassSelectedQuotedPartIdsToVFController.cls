public class PassSelectedQuotedPartIdsToVFController {
    
    public string[] SelectedQuotedPartIDs{get;set;}
    
    public PassSelectedQuotedPartIdsToVFController(ApexPages.StandardSetController listcontroller){
        SelectedQuotedPartIDs = new string[]{};
        for(HRCFSL_Quoted_Part__c qps : (HRCFSL_Quoted_Part__c[])listcontroller.getSelected()){
            SelectedQuotedPartIDs.add(qps.Id);
        }
    }
}