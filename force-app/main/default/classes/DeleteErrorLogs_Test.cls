@isTest
private class DeleteErrorLogs_Test{
public static testMethod void testBatch() { 
    list<Error_Log__c> logs1 = new list<Error_Log__c>();
        //Error_Log__c Logs = new Error_Log__c( Class_Name__c ='test', Error_Message__c='test');
        integer i;
        For ( i=10; i<0; i++)
        { 
        Error_Log__c Logs = new Error_Log__c( Class_Name__c ='test', Error_Message__c='test');
        logs1.add(Logs);
        }
        insert logs1;
        
    Test.StartTest();
        
        DeleteErrorLogs DeleteErrorLogs_Test = new DeleteErrorLogs();            
        Database.BatchableContext BC;
        
        deleteErrorLogs_Test.start(BC);
        
        DeleteErrorLogs_Test.execute(BC,logs1);
                DeleteErrorLogs_Test.finish(null);  
    
// Schedule the job
        DeleteErrorLogs obj1 = new DeleteErrorLogs();

        DeleteErrorLogsSchdule p = new DeleteErrorLogsSchdule();    
        String jobId = System.schedule('test','0 0 0 3 9 ? 2022', new DeleteErrorLogsSchdule());    
        
        Test.stopTest();
   }
}