trigger PSP_BMC_CMDB_Gold_BMCServiceDesk_BMC_BaseElement_cTrigger on BMCServiceDesk__BMC_BaseElement__c(after insert, after update, before delete) {
   persp.PSPLogger Logger = new persp.PSPLogger('PSP_BMC_CMDB_Gold_BMCServiceDesk_BMC_BaseElement_cTrigger', false);
   String triggerWhere = 'TGV2ZWxfb2ZfU2VydmljZV9fYz0nR29sZCc=';
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
      objList = persp.PSPUtil.findSObjects('BMCServiceDesk__BMC_BaseElement__c', 'Id,Name', EncodingUtil.base64Decode(triggerWhere).toString(), Logger, objList);
      persp.PSPUtil.createPspOutMessage('BMCServiceDesk__BMC_BaseElement__c', action, 'aBb0L000000Cv5vSAC', 'Id,Name',  EncodingUtil.base64Decode(triggerWhere).toString(), false, '', '', Logger, 'CDWSN', '2', objList);
   }
   else {
      Logger.logWarning('Dynamic Share size limit exceeded with the batch size of [' + objList.size() + ']. The following batch has been inserted as an apex job.');
      persp.PSPDynamicShareProcessor dynamicShareProcessor = new persp.PSPDynamicShareProcessor('BMCServiceDesk__BMC_BaseElement__c', action, 'aBb0L000000Cv5vSAC', 'Id,Name', EncodingUtil.base64Decode(triggerWhere).toString(), false, '', '', Logger, 'CDWSN', '2', objList);
      Database.executeBatch(dynamicShareProcessor);
   }
   Logger.commitLog();
}