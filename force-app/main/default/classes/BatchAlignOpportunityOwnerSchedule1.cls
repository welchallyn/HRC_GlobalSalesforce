global class BatchAlignOpportunityOwnerSchedule1  implements Schedulable {
    global void execute(SchedulableContext sc) {
           
           BatchAlignOpportunityOwner1 b = new BatchAlignOpportunityOwner1();
             
           Database.executeBatch(b);
             
   }
   
   static testmethod void testSchedule() {
   Test.startTest();
      String jobId = System.schedule('test',
      '0 0 0 3 9 ? 2022', 
         new BatchAlignOpportunityOwnerSchedule1());

      CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];
         
      System.assertEquals('0 0 0 3 9 ? 2022', 
         ct.CronExpression);
      System.assertEquals(0, ct.TimesTriggered);
      
      System.assertEquals('2022-09-03 00:00:00', 
         String.valueOf(ct.NextFireTime));

     Test.stopTest();
   }
}