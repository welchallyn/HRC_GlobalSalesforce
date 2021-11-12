/* Class:       Constants
** Created by:  OpFocus (Jason Curry) on 2021-06-21
** Description: System constants file
*/

public class Constants {

    @TestVisible
    private Constants() { /* Singleton */}

    // Lead Constants

    public static final String PARDOT_USERNAME = 'pardot@system.id.%';

    public static User PARDOT_USER {
        get {
            if (PARDOT_USER == null) {
                PARDOT_USER = [SELECT Id, Username, Name FROM User WHERE Username LIKE :PARDOT_USERNAME LIMIT 1];
            }
            return PARDOT_USER;
        }
        set;
    }

    public static final String LEAD_PLD_LEAD_TYPE_PARENT = 'Parent Lead';
    public static final String LEAD_PLD_LEAD_TYPE_CHILD = 'Child Lead';

    public static final Map<Id, RecordTypeInfo> LEAD_RECORD_TYPES_BY_ID {
        get {
            if (LEAD_RECORD_TYPES_BY_ID == null) {
                LEAD_RECORD_TYPES_BY_ID = Schema.Lead.getSObjectType().getDescribe().getRecordTypeInfosById();
            }
            return LEAD_RECORD_TYPES_BY_ID;
        }
        private set;
    }

    public static final Map<String, RecordTypeInfo> LEAD_RECORD_TYPES_BY_DEVELOPER_NAME {
        get {
            if (LEAD_RECORD_TYPES_BY_DEVELOPER_NAME == null) {
                LEAD_RECORD_TYPES_BY_DEVELOPER_NAME = Schema.Lead.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName();
            }
            return LEAD_RECORD_TYPES_BY_DEVELOPER_NAME;
        }
        private set;
    }

    // PLD Constants
    public static final Map<String, PLD_Record_Type__mdt> PLD_RECORD_TYPES {
        get {
            if (PLD_RECORD_TYPES == null) {
                List<PLD_Record_Type__mdt> recordTypes = [SELECT DeveloperName
                FROM PLD_Record_Type__mdt WHERE Enabled__c = TRUE ORDER BY DeveloperName DESC];

                PLD_RECORD_TYPES = new Map<String, PLD_Record_Type__mdt>();
                for (PLD_Record_Type__mdt rt : recordTypes) {
                    PLD_RECORD_TYPES.put(rt.DeveloperName, rt);
                }
            }
            return PLD_RECORD_TYPES;
        }
        private set;
    }

    public static Map<String, PLD_Synced_Field__mdt> PLD_SYNCED_FIELDS {
        get {
            if (PLD_SYNCED_FIELDS == null) {
                List<PLD_Synced_Field__mdt> syncedFields = [
                        SELECT
                                Label,
                                DeveloperName,
                                ParentFieldName__c,
                                ChildFieldName__c,
                                SyncDirection__c,
                                SyncCondition__c,
                                MergePicklist__c,
                                MergeTextField__c,
                                MergedTextFieldSeparator__c
                        FROM PLD_Synced_Field__mdt
                ];

                PLD_SYNCED_FIELDS = new Map<String, PLD_Synced_Field__mdt>();
                for (PLD_Synced_Field__mdt f : syncedFields) {
                    PLD_SYNCED_FIELDS.put(f.DeveloperName, f);
                }
            }
            return PLD_SYNCED_FIELDS;
        }
        private set;
    }

    public static final String PLD_DIRECTION_BIDIRECTIONAL = 'Bidirectional';
    public static final String PLD_DIRECTION_TO_PARENT = 'To Parent';
    public static final String PLD_DIRECTION_TO_CHILD = 'To Child';

    public static final String PLD_CONDITION_ALWAYS = 'Always';
    public static final String PLD_CONDITION_WHEN_CHANGED = 'When changed';
    public static final String PLD_CONDITION_ONLY_ON_CREATION = 'Only on creation';

}