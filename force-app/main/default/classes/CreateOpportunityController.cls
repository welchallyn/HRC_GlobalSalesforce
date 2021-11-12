public with sharing class CreateOpportunityController{
    
    @AuraEnabled
    public static JDE_Prop__c getJDEprop(Id propid) {
        system.debug('ID-->'+propid);
        JDE_Prop__c objJde = [SELECT Id, Name,Ship_To__c,Ship_To__r.Name FROM JDE_Prop__c WHERE Id = :propid];
        return objJde;
    }
    
    @AuraEnabled
    public static Order__c getOrder(Id orderid) {
        system.debug('ID-->'+orderid);
        Order__c objOrder = [SELECT Id, Name,Account__c,Account__r.Name FROM Order__c WHERE Id = :orderid];
        return objOrder;
    }
    
    @AuraEnabled
    public static string getrecordtypeid(string test){
        string recordtypeid;
        string defaultrecordtypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Capital').getRecordTypeId();
        Map<string,string> mapRecordTypeNameId = new Map<string,string>();
        Map<string,string> mapProfileRecordType = new Map<string,string>();
        for(Recordtype objRec:[SELECT Id,Name FROM RecordType where sobjecttype='Opportunity']){
            mapRecordTypeNameId.put(objRec.Name,objRec.id);
        }
        system.debug('mapRecordTypeNameId-->'+mapRecordTypeNameId);
        
        List<Profile_Recordtype_Mapping__mdt> lstMetaData = [select label,Record_Type__c from Profile_Recordtype_Mapping__mdt];
        if(lstMetaData!=null && lstMetaData.size()>0){
            for(Profile_Recordtype_Mapping__mdt objMeta:lstMetaData){
                mapProfileRecordType.put(objMeta.label,objMeta.Record_Type__c);
            }
        }
        system.debug('mapProfileRecordType-->'+mapProfileRecordType);
        User objUser = [SELECT ProfileId FROM User where id = :userinfo.getuserid() LIMIT 1];
        profile objProfile = [select id,name from profile where id=:objUser.profileid LIMIT 1];
        
        system.debug('Profile name-->'+objProfile.name);
        
        if(mapProfileRecordType.containsKey(objProfile.name)){
            if(mapRecordTypeNameId.containsKey(mapProfileRecordType.get(objProfile.name))){
                recordtypeid = mapRecordTypeNameId.get(mapProfileRecordType.get(objProfile.name));
            }
            else
                recordtypeid = defaultrecordtypeid;
        }
        else
            recordtypeid = defaultrecordtypeid;
        
        
        return recordtypeid;
    }

}