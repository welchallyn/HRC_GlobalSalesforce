trigger PSP_BMC_Incident_BMCServiceDesk_Incident_cTrigger on BMCServiceDesk__Incident__c(after insert, after update, before delete) {
   persp.PSPLogger Logger = new persp.PSPLogger('PSP_BMC_Incident_BMCServiceDesk_Incident_cTrigger', false);
   String triggerWhere = 'KFZlbmRvcl9UaWNrZXRfTnVtYmVyX19jIExJS0UgJ0lOQyUnIE9SIEJNQ1NlcnZpY2VEZXNrX19xdWV1ZU5hbWVfX2MgPSAnSFJDLUNEVy1FQ0MnKQ==';
   String action = '';

   if (Trigger.isInsert)
      action = '.insert';
   else if (Trigger.isUpdate)
      action = + '.bulk';
   else if (Trigger.isDelete)
      action = + '.delete';

   List<SObject> objList = new List<SObject>();
   if (Trigger.isDelete)
      objList = Trigger.old;
   else
      objList = Trigger.new;

   if (objList.size() < Limits.getLimitQueries()) {
      objList = persp.PSPUtil.findSObjects('BMCServiceDesk__Incident__c', '-- ALL FIELDS --', EncodingUtil.base64Decode(triggerWhere).toString(), Logger, objList);
      persp.PSPUtil.createPspOutMessage('BMCServiceDesk__Incident__c', action, 'aBb0L000000Cv5vSAC', '-- ALL FIELDS --',  EncodingUtil.base64Decode(triggerWhere).toString(), false, '', '', Logger, 'CDWSN', '2', objList);
  
  // Now we want to loop through all the notes added to this incident and also send them out
      for (SObject obj : Trigger.new) {
         String myCorrID = (String)obj.get('Vendor_Ticket_Number__c');
         String myQueue = (String)obj.get('BMCServiceDesk__queueName__c');

         try{
            // If the notes parent incident matches out share criteria
            if ((myCorrID != null && myCorrID.startsWith('INC')) || (myQueue != null && myQueue.equals('HRC-CDW-ECC'))){
               // Then send all the recent notes out to the outbound table
               for (Note note : [SELECT Id,IsDeleted,IsPrivate,OwnerId,ParentId,Body,Title FROM Note WHERE ParentId = :obj.Id ORDER BY LastModifiedDate DESC LIMIT 3]) {
                  //persp.PSPUtil.createPspOutMessageAsync('Note','aBJ21000000CmDoGAK','Id,IsDeleted,IsPrivate,OwnerId,ParentId,Body,Title','', '.bulk',  '', '', note.Id, 'CDWSN');
                 persp.PSPUtil.createPspOutMessageAsync('Note','aBb0L000000Cv5vSAC','Id,IsDeleted,IsPrivate,OwnerId,ParentId,Body,Title','', '.bulk',  '', '', note.Id, 'CDWSN', '2');
               }
            }
         }
         catch(Exception e){
             //Logger.logDebug('Exception caught: ' + e);
         }
      }
   }
  
   
   else {
      Logger.logWarning('Dynamic Share size limit exceeded with the batch size of [' + objList.size() + ']. The following batch has been inserted as an apex job.');
      persp.PSPDynamicShareProcessor dynamicShareProcessor = new persp.PSPDynamicShareProcessor('BMCServiceDesk__Incident__c', action, 'aBb0L000000Cv5vSAC', '-- ALL FIELDS --', EncodingUtil.base64Decode(triggerWhere).toString(), false, '', '', Logger, 'CDWSN', '2', objList);
      Database.executeBatch(dynamicShareProcessor);
   }
   Logger.commitLog();
}