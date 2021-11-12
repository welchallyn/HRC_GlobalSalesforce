global class DeleteErrorLogsSchdule  implements Schedulable {

    global void execute(SchedulableContext sc) {
           
           DeleteErrorLogs b = new DeleteErrorLogs();
             
           Database.executeBatch(b, 1000);
  }         
 /** global Static testmethod void testSchedule() {
   Test.StartTest();  
    
// Schedule the job
        DeleteInacitveUserRoles obj1 = new DeleteInacitveUserRoles();
      obj1.RunTestMetod = false;
   //obj1.query='SELECT id, UserRoleId, isActive FROM User WHERE isActive = false LIMIT=200';
   //obj1.ParentUserRoles = [Select id, ParentRoleId From UserRole Where ParentRoleId IN :RolesToDelete];
    //ID batchprocessid = Database.executeBatch(obj1,1);
   // OrderTransactionUpdate obj = new OrderTransactionUpdate();
  //  database.executebatch(obj);
  DeleteInacitveUserRolesSchedule p = new DeleteInacitveUserRolesSchedule();    
  String jobId = System.schedule('test',
      '0 0 0 3 9 ? 2022', 
         new BatchAlignOpportunityOwnerSchedule());    
   //String sch = '0 0 8 13 2 ?';        
  //system.schedule('Schedule Test', sch, p);
  
 Test.stopTest();
   }**/
}