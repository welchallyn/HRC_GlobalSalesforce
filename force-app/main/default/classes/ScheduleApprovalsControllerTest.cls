@isTest(seeAllData=true)
public class ScheduleApprovalsControllerTest{

    public static testmethod void ScheduleApprovals() {
        ScheduleApprovalsController s = new ScheduleApprovalsController ();
        s.scheduler();
        
        ProcessChildIncidents p = new ProcessChildIncidents();
        p.process();
    }
}