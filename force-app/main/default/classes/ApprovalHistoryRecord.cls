public class ApprovalHistoryRecord {

    public ProcessInstance pi { get; set; }
    public List<ProcessInstanceHistory> pih { get; set; }
    
    public ApprovalHistoryRecord (ProcessInstance pi, List<ProcessInstanceHistory> pih) {
        this.pi = pi;
        this.pih = pih;
        System.debug('ProcessInstance :'+ pi + 'ProcessInstanceHistory :'+pih);
    }
}