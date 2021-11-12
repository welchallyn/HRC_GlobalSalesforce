global class DeleteErrorLogs implements Database.Batchable<Sobject>{
        //constructor
        global DeleteErrorLogs(){}
         //Method to get the data to be proceesed 

        global database.Querylocator start(Database.BatchableContext context){
            string query = 'Select id From Error_Log__C Where CreatedDate < LAST_N_DAYS:60';
            return Database.getQueryLocator(query);
        }
        //Method to execute the batch
        global void execute(Database.BatchableContext context , Sobject[] scope){
            

         try {
           delete Scope;
            } catch (system.dmlexception e) {
           System.debug('Errorlogs not Deleted: ' + e);
                 }
            
        }
         //Method to be called after the excute
         global void finish(Database.BatchableContext context){

             EmailHandler.sendEmail('start second batch');
         }
}