global class ScheduleApprovalsController {

    public String message {get;set;}
    public Boolean isSuccessful {get;set;}
    
    public ScheduleApprovalsController() {
        isSuccessful = true;
    }
    
    public void scheduler() {
        message='';
        //ReplaceApprovers ra = new ReplaceApprovers();
        ProcessChildIncidents ra = new ProcessChildIncidents();

        String sch;
        try {
            sch = '0 0 * * * ? *';
            if(!Test.isRunningTest())
                System.schedule('Approvals Scheduler- 1', sch, ra);
                message += 'The background Approval process "Approvals Scheduler- 1" has been successfully scheduled';
            
            
            
            sch = '0 10 * * * ? *';
            if(!Test.isRunningTest())
                System.schedule('Approvals Scheduler- 2', sch, ra);
            message += '<br/>The background Approval process "Approvals Scheduler- 2" has been successfully scheduled';
            
        
            sch = '0 20 * * * ? *';
            if(!Test.isRunningTest())
                System.schedule('Approvals Scheduler- 3', sch, ra);
            message += '<br/>The background Approval process "Approvals Scheduler- 3" has been successfully scheduled';
            
       
            sch = '0 30 * * * ? *';
            if(!Test.isRunningTest())
                System.schedule('Approvals Scheduler- 4', sch, ra);
            message += '<br/>The background Approval process "Approvals Scheduler- 4" has been successfully scheduled';
            
        
            sch = '0 40 * * * ? *';
            if(!Test.isRunningTest())
                System.schedule('Approvals Scheduler- 5', sch, ra);
            message += '<br/>The background Approval process "Approvals Scheduler- 5" has been successfully scheduled';
            
       
            sch = '0 50 * * * ? *';
            if(!Test.isRunningTest())
                System.schedule('Approvals Scheduler- 6', sch, ra);
            message += '<br/>The background Approval process "Approvals Scheduler- 6" has been successfully scheduled';
            
        }
        catch(Exception ex) {
            System.debug('Exception occured:' + ex);
            System.debug('Exception message' + ex.getMessage());
            message += '<br/>' + ex.getMessage();
            isSuccessful = false;
        }
    }
}