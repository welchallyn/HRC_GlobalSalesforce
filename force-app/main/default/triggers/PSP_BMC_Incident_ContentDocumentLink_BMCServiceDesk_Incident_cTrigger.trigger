trigger PSP_BMC_Incident_ContentDocumentLink_BMCServiceDesk_Incident_cTrigger on ContentDocumentLink(after insert, after update, before delete) {
   persp.PSPLogger Logger = new persp.PSPLogger('PSP_BMC_Incident_ContentDocumentLink_BMCServiceDesk_Incident_cTrigger', false);
   String fieldsToShare = 'LinkedEntityId, ContentDocumentId';
   String triggerWhere = 'TGlua2VkRW50aXR5SWQgaW4gKHNlbGVjdCBJZCBmcm9tIEJNQ1NlcnZpY2VEZXNrX19JbmNpZGVudF9fYyk=';

   String action = '';

   if (Trigger.isInsert)
      action = '.insert';
   else if (Trigger.isUpdate)
      action = + '.bulk';
   else if (Trigger.isDelete) {
      action = + '.delete';
      return;
   }
   if (!Trigger.isDelete) {
      List<Id> linkedEntityIds = new List<Id>();
      List<Id> contentDocumentIds = new List<Id>();
      for (Integer i = 0; i < Trigger.new.size(); i++) {
         ContentDocumentLink obj = Trigger.new.get(i);
            if (!( Trigger.new.size() > i+1 && obj.ContentDocumentId == Trigger.new.get(i+1).ContentDocumentId
               && obj.LinkedEntityId.getSObjectType().getDescribe().getName() == 'User')) {
               linkedEntityIds.add(obj.LinkedEntityId);
               contentDocumentIds.add(obj.ContentDocumentId);
            }
      }

      List<BMCServiceDesk__Incident__c> find = [SELECT Id FROM BMCServiceDesk__Incident__c WHERE Id IN :linkedEntityIds AND (Vendor_Ticket_Number__c LIKE 'INC%' OR BMCServiceDesk__queueName__c = 'HRC-CDW-ECC') LIMIT 1];
      if (find.size() == 0)
         return;

      List<ContentVersion> attachments = [select Title, VersionData, ContentDocumentId, Description, OwnerId, FileType, FileExtension from ContentVersion where ContentDocumentId IN :contentDocumentIds];
      for (Integer i = 0; i < linkedEntityIds.size(); i++) {
         for (ContentVersion attachment : attachments) {
            persp.PSPUtil.createFile(EncodingUtil.base64Encode(attachment.VersionData), JSON.serialize(attachment), '', 'aBb0L000000Cv5vSAC', 'CDWSN', 'ContentVersion', '', String.valueOf(linkedEntityIds.get(i)));
         }
      }
   }
   else {
      List<SObject> objList = persp.PSPUtil.findSObjects('ContentDocumentLink', 'aBb0L000000Cv5vSAC', EncodingUtil.base64Decode(triggerWhere).toString(), Logger, Trigger.old);
      Logger.logWarning('Dynamic Share size limit exceeded with the batch size of [' + objList.size() + ']. The following batch has been inserted as an apex job.');
      persp.PSPUtil.createPspOutMessage('ContentDocumentLink', action, 'aBb0L000000Cv5vSAC', fieldsToShare, EncodingUtil.base64Decode(triggerWhere).toString(), true, '', '', Logger, 'CDWSN', '2', Trigger.old);
   }
   Logger.commitLog();
}