public class PendingApprovalRecord {

        public ProcessInstanceWorkItem piwi {get;set;}
        public String TargetObjectLabel {get;set;}
        public String TargetObjectName {get;set;}

        public PendingApprovalRecord(ProcessInstanceWorkItem piwi) {
            
            this.piwi=piwi;
            
            Schema.SObjectType token = piwi.ProcessInstance.TargetObjectId.getSObjectType();
            Schema.DescribeSObjectResult dr = token.getDescribe();
            TargetObjectLabel = dr.getLabel();
            TargetObjectName = dr.getName();
        }
}