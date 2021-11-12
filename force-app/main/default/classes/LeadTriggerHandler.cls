/* Class:       LeadTriggerHandler
** Created by:  OpFocus (Jason Curry) on 2021-06-21
** Description: Trigger handler for Leads
*/

public without sharing class LeadTriggerHandler extends TriggerHandler {

    private static final Set<String> processedNewLeads = new Set<String>();
    private static final Set<String> processedUpdatedLeads = new Set<String>();

    private static final List<Lead> NEW_LEADS {
        get {
            return (List<Lead>) Trigger.new;
        }
    }

    private static final Map<Id, Lead> NEW_LEADS_MAP {
        get {
            return (Map<Id, Lead>) Trigger.newMap;
        }
    }

    private static final Map<Id, Lead> OLD_LEADS_MAP {
        get {
            return (Map<Id, Lead>) Trigger.oldMap;
        }
    }

    public override void beforeInsert() {
        setPLDLeadType();
    }

    public override void afterInsert() {
        processNewLeads();
    }

    public override void afterUpdate() {
        syncUpdates();
    }

    private static void syncUpdates() {
        List<Lead> parentLeads = new List<Lead>();
        List<Lead> childLeads = new List<Lead>();

        for (Lead l : NEW_LEADS) {

            if (processedUpdatedLeads.contains(l.Id)) {
                continue;
            }

            processedUpdatedLeads.add(l.Id);

            if (l.PLDLeadType__c == Constants.LEAD_PLD_LEAD_TYPE_PARENT) {
                parentLeads.add(l);
            } else if (l.PLDLeadType__c == Constants.LEAD_PLD_LEAD_TYPE_CHILD) {
                childLeads.add(l);
            }
        }

        syncChildLeadsWithParent(childLeads);
        syncParentLeadsWithChildren(parentLeads);
    }

    private static Map<String, Lead> parentLeadsMapsByEmail = new Map<String, Lead>();

    private static void setPLDLeadType() {
        //List<Lead> actionableLeads = getActionableLeads();
        Map<String, Lead> matchingLeadsByEmail = getMatchingParentLeadsByEmail(getUniqueLeadEmails(NEW_LEADS));
        List<Lead> newParentLeads = new List<Lead>();
        List<Lead> newLeads = NEW_LEADS;
        for (Lead l : newLeads) {
            if (l.PLDLeadType__c != null || l.Email == null) {
                //System.debug('#### skipping: ' + l.PLDLeadType__c);
                continue;
            }

            if (!matchingLeadsByEmail.containsKey(l.Email.toLowerCase())) {
                matchingLeadsByEmail.put(l.Email.toLowerCase(), l);
                l.PLDLeadType__c = Constants.LEAD_PLD_LEAD_TYPE_CHILD;
                if (!parentLeadsMapsByEmail.containsKey(l.Email.toLowerCase())) {
                    Lead parentLead = cloneFirstParentLead(l);
                    parentLeadsMapsByEmail.put(l.Email.toLowerCase(), parentLead);
                    newParentLeads.add(parentLead);
                } else {
                    setParentPLDFieldsFromChild(parentLeadsMapsByEmail.get(l.Email.toLowerCase()), l);
                    l.PLDParentLead__c = parentLeadsMapsByEmail.get(l.Email.toLowerCase()).Id;
                }
            } else {
                l.PLDLeadType__c = Constants.LEAD_PLD_LEAD_TYPE_CHILD;
                l.PLDParentLead__c = matchingLeadsByEmail.get(l.Email.toLowerCase()).Id;

                if (!parentLeadsMapsByEmail.containsKey(l.Email.toLowerCase())) {
                    parentLeadsMapsByEmail.put(l.Email.toLowerCase(), matchingLeadsByEmail.get(l.Email.toLowerCase()));
                }

                if (parentLeadsMapsByEmail.containsKey(l.Email.toLowerCase())) {
                    setParentPLDFieldsFromChild(parentLeadsMapsByEmail.get(l.Email.toLowerCase()), l);
                }
            }
        }

        if (!newParentLeads.isEmpty()) {
            insert newParentLeads;
        }

        if (Trigger.isBefore) {
            for (Lead l : newLeads) {
                if (String.isNotBlank(l.PLDParentLead__c)) {
                    continue;
                }

                Lead parentLead = parentLeadsMapsByEmail.get(l.Email.toLowerCase());
                l.PLDParentLead__c = parentLead.Id;
            }
        }
    }

    private static void processNewLeads() {
        processNewParentLeads();
        List<Lead> actionableLeads = getActionableChildLeads();
        Map<String, Lead> matchingLeadsByEmail = getMatchingParentLeadsByEmail(getUniqueLeadEmails(actionableLeads));

        List<Lead> leadsToBeSynced = new List<Lead>();
        List<Lead> updatedLeadParents = new List<Lead>();

        Map<String, Lead> leadsNeedingParent = new Map<String, Lead>();

        for (Lead lead : actionableLeads) {
            Lead l = lead.clone(true);

            if (String.isNotBlank(l.Email)
                    && l.PLDLeadType__c == Constants.LEAD_PLD_LEAD_TYPE_CHILD
                    && String.isBlank(l.PLDParentLead__c)
                    && matchingLeadsByEmail.containsKey(l.Email.toLowerCase())) {

                l.PLDParentLead__c = matchingLeadsByEmail.get(l.Email.toLowerCase()).Id;
                if (String.isNotBlank(l.Id)) {
                    updatedLeadParents.add(new Lead(Id = l.Id, PLDParentLead__c = l.PLDParentLead__c));
                }
            }

            if (matchingLeadsByEmail.containsKey(l.Email.toLowerCase())) {
                leadsToBeSynced.add(l);
            }
        }

        if (!updatedLeadParents.isEmpty()) {
            update updatedLeadParents;
        }

        if (!leadsToBeSynced.isEmpty()) {
            syncChildLeadsWithParent(leadsToBeSynced);
        }
    }

    private static Lead cloneFirstParentLead(Lead childLead) {
        Lead parentLead = new Lead();

        parentLead.Email = childLead.Email;
        parentLead.FirstName = childLead.FirstName;
        parentLead.LastName = childLead.LastName;
        parentLead.PLDLeadType__c = Constants.LEAD_PLD_LEAD_TYPE_PARENT;
        parentLead.Status = 'Parent Lead';
        parentLead.RecordTypeId = Constants.LEAD_RECORD_TYPES_BY_DEVELOPER_NAME.get('Parent_Lead').recordTypeId;
        parentLead.OwnerId = Constants.PARDOT_USER.Id;

        setParentPLDFieldsFromChild(parentLead, childLead);

        return parentLead;
    }

    private static Boolean setChildPLDFieldsFromParent(Lead childLead, Lead parentLead) {
        Boolean updatesMade = false;
        for (PLD_Synced_Field__mdt f : Constants.PLD_SYNCED_FIELDS.values()) {
            if ((f.SyncDirection__c == Constants.PLD_DIRECTION_BIDIRECTIONAL
                    || f.SyncDirection__c == Constants.PLD_DIRECTION_TO_CHILD)
                    && (
                    (f.SyncCondition__c == Constants.PLD_CONDITION_ALWAYS)
                    || (f.SyncCondition__c == Constants.PLD_CONDITION_ONLY_ON_CREATION && Trigger.operationType == TriggerOperation.AFTER_INSERT)
                    || (f.SyncCondition__c == Constants.PLD_CONDITION_WHEN_CHANGED && Trigger.isUpdate
                         && parentLead.get(f.ParentFieldName__c) != OLD_LEADS_MAP.get(parentLead.Id).get(f.ParentFieldName__c))
            )) {

                childLead.put(f.ChildFieldName__c, parentLead.get(f.ParentFieldName__c));
                updatesMade = true;

            }
        }

        return updatesMade;
    }

    private static Boolean setParentPLDFieldsFromChild(Lead parentLead, Lead childLead) {
        Boolean updatesMade = false;
        for (PLD_Synced_Field__mdt f : Constants.PLD_SYNCED_FIELDS.values()) {
            if ((f.SyncDirection__c == Constants.PLD_DIRECTION_BIDIRECTIONAL
                    || f.SyncDirection__c == Constants.PLD_DIRECTION_TO_PARENT)
                    && (
                    (f.SyncCondition__c == Constants.PLD_CONDITION_ALWAYS)
                            || (f.SyncCondition__c == Constants.PLD_CONDITION_ONLY_ON_CREATION && Trigger.operationType == TriggerOperation.AFTER_INSERT)
                            || (f.SyncCondition__c == Constants.PLD_CONDITION_WHEN_CHANGED && Trigger.isUpdate
                            && childLead.get(f.ChildFieldName__c) != OLD_LEADS_MAP.get(childLead.Id).get(f.ChildFieldName__c))
            )) {
                updatesMade = true;

                if (f.MergePicklist__c && f.SyncDirection__c == Constants.PLD_DIRECTION_TO_PARENT && String.isNotBlank((String) childLead.get(f.ChildFieldName__c))) {
                    String childValue = (String) childLead.get(f.ChildFieldName__c);
                    String parentValue;
                    if (String.isBlank((String) parentLead.get(f.ParentFieldName__c))) {
                        parentValue = (String) parentLead.get(f.ParentFieldName__c);
                    } else {
                        parentValue = (String) parentLead.get(f.ParentFieldName__c);
                    }
                    if (String.isBlank(parentValue)) {
                        parentLead.put(f.ParentFieldName__c, childValue);
                    } else if (!parentValue.contains(childValue)) {
                        parentLead.put(f.ParentFieldName__c, parentValue + ',' + childValue);
                    }
                } else if (f.MergeTextField__c && f.SyncDirection__c == Constants.PLD_DIRECTION_TO_PARENT) {
                    String childValue = (String) childLead.get(f.ChildFieldName__c);
                    String parentValue;
                    if (String.isNotBlank((String) parentLead.get(f.ParentFieldName__c))) {
                        parentValue = (String) parentLead.get(f.ParentFieldName__c);
                    } else {
                        parentValue = '';
                    }
                    if (String.isBlank(parentValue)) {
                        parentLead.put(f.ParentFieldName__c, childValue);
                    } else {
                        parentLead.put(f.ParentFieldName__c, parentValue + f.MergedTextFieldSeparator__c + childValue);
                    }
                } else if (!f.MergePicklist__c && !f.MergeTextField__c) {
                    parentLead.put(f.ParentFieldName__c, childLead.get(f.ChildFieldName__c));
                }

            }
        }

        return updatesMade;
    }

    private static void syncParentLeadsWithChildren(List<Lead> leads) {
        Map<Id, List<Lead>> childLeadsMapByParentId = getChildLeads(getLeadIds(leads));

        Map<Id, Lead> updatedLeadsMap = new Map<Id, Lead>();

        for (Lead pl : leads) {
            if (!childLeadsMapByParentId.containsKey(pl.Id)) {
                // No child leads to sync
                continue;
            }

            for (Lead cl : childLeadsMapByParentId.get(pl.Id)) {
                Lead updatedLead = new Lead(Id = cl.Id);
                if (setChildPLDFieldsFromParent(updatedLead, pl)) {
                    updatedLeadsMap.put(updatedLead.Id, updatedLead);
                }
            }
        }

        if (!updatedLeadsMap.isEmpty()) {
            update updatedLeadsMap.values();
        }
    }

    private static void syncChildLeadsWithParent(List<Lead> leads) {
        Map<Id, Lead> parentLeadsMap = getParentLeads(getPLDParentIdsSetFromLeads(leads));

        Map<Id, Lead> updatedParentLeadsMap = new Map<Id, Lead>();

        for (Lead l : leads) {
            if (!parentLeadsMap.containsKey(l.PLDParentLead__c)) {
                continue;
            }

            Lead parentLead = parentLeadsMap.get(l.PLDParentLead__c);

            Lead updatedParentLead = null;

            if (!updatedParentLeadsMap.containsKey(parentLead.Id)) {
                updatedParentLead = parentLead.clone(true);
                updatedParentLeadsMap.put(updatedParentLead.Id, updatedParentLead);
            } else {
                updatedParentLead = updatedParentLeadsMap.get(parentLead.Id);
            }

            setParentPLDFieldsFromChild(updatedParentLead, l);

        }

        if (!updatedParentLeadsMap.values().isEmpty()) {
            update updatedParentLeadsMap.values();
        }
    }

    private static Map<Id, List<Lead>> getChildLeads(Set<Id> parentLeadIds) {
        Map<Id, Lead> childLeadsMap = getLeadsMapFromQuery('SELECT ' + QUERY_LEAD_FIELDS + ' FROM Lead WHERE PLDParentLead__c = :leadIds', parentLeadIds);

        Map<Id, List<Lead>> childLeadsMapByParent = new Map<Id, List<Lead>>();
        for (Lead l : childLeadsMap.values()) {
            List<Lead> childLeads;
            if (childLeadsMapByParent.containsKey(l.PLDParentLead__c)) {
                childLeads = childLeadsMapByParent.get(l.PLDParentLead__c);
            } else {
                childLeads = new List<Lead>();
                childLeadsMapByParent.put(l.PLDParentLead__c, childLeads);
            }
            childLeads.add(l);
        }
        return childLeadsMapByParent;
    }

    private static Map<Id, Lead> getParentLeads(Set<Id> leadIds) {
        return getLeadsMapFromQuery('SELECT ' + QUERY_LEAD_FIELDS + ' FROM Lead WHERE Id = :leadIds', leadIds);
    }

    private static Map<Id, Lead> getLeadsMapFromQuery(String query, Set<Id> leadIds) {
        Map<Id, Lead> leadsMap = new Map<Id, Lead>();
        for (Lead l : Database.query(query)) {
            leadsMap.put(l.Id, l);
        }
        return leadsMap;
    }

    private static final String QUERY_LEAD_FIELDS {
        get {
            if (QUERY_LEAD_FIELDS == null) {
                List<String> fields = new List<String>();
                fields.add('Id');
                fields.add('PLDParentLead__c');
                fields.add('PLDLeadType__c');
                for (PLD_Synced_Field__mdt f : Constants.PLD_SYNCED_FIELDS.values()) {
                    fields.add(f.ParentFieldName__c);
                }
                QUERY_LEAD_FIELDS = String.join(fields, ', ');
            }
            return QUERY_LEAD_FIELDS;
        }
        private set;
    }

    private static Set<Id> getLeadIds(List<Lead> leads) {
        Set<Id> leadIds = new Set<Id>();
        for (Lead l : leads) {
            leadIds.add(l.Id);
        }
        return leadIds;
    }

    private static Set<Id> getPLDParentIdsSetFromLeads(List<Lead> leads) {
        Set<Id> parentLeads = new Set<Id>();
        for (Lead l : leads) {
            if (String.isNotBlank(l.PLDParentLead__c)) {
                parentLeads.add(l.PLDParentLead__c);
            }
        }
        return parentLeads;
    }

    private static void processNewParentLeads() {
        Map<String, Lead> newParentLeads = new Map<String, Lead>();
        for (Lead l : NEW_LEADS) {
            if (l.PLDLeadType__c == Constants.LEAD_PLD_LEAD_TYPE_PARENT) {
                newParentLeads.put(l.Email.toLowerCase(), l);
            }
        }

        if (!newParentLeads.isEmpty()) {
            List<Lead> childLeads = [SELECT Id, Email FROM Lead WHERE Email = :newParentLeads.keySet() AND PLDLeadType__c = :Constants.LEAD_PLD_LEAD_TYPE_CHILD AND PLDParentLead__c = NULL];
            for (Lead l : childLeads) {
                l.PLDParentLead__c = newParentLeads.get(l.Email.toLowerCase()).Id;
                if (NEW_LEADS_MAP.containsKey(l.Id)) {
                    NEW_LEADS_MAP.get(l.Id).PLDParentLead__c = l.PLDParentLead__c;
                }
                System.debug('#### l: ' + l);
            }
            update childLeads;
        }
    }

    private static List<Lead> getActionableChildLeads() {
        List<Lead> actionableLeads = new List<Lead>();
        for (Lead l : NEW_LEADS) {

            if (l.PLDLeadType__c == Constants.LEAD_PLD_LEAD_TYPE_PARENT) {
                continue;
            }

            if (Trigger.isAfter && processedNewLeads.contains(l.Id)) {
                System.debug('### lead has already been processed: ' + l.Id);
                continue;
            }

            if (String.isBlank(l.Email)) {
                System.debug('### email was null: ' + l);
                continue;
            }

            if (Trigger.isAfter) {
                processedNewLeads.add(l.Id);
            }

            //System.debug('#### processed record types: ' + Constants.PLD_RECORD_TYPES);
            //System.debug('#### ' + Constants.LEAD_RECORD_TYPES_BY_ID.get(l.RecordTypeId).developerName);
            //System.debug('#### ' + Constants.PLD_RECORD_TYPES.containsKey(Constants.LEAD_RECORD_TYPES_BY_ID.get(l.RecordTypeId).developerName));
            if (Constants.PLD_RECORD_TYPES.containsKey(Constants.LEAD_RECORD_TYPES_BY_ID.get(l.RecordTypeId).developerName)) {
                System.debug('#### adding lead to actionable: ' + l);
                actionableLeads.add(l);
            } else {
                System.debug('#### lead\'s record type not being processed: ' + l);
            }
        }
        return actionableLeads;
    }

    private static Set<String> getUniqueLeadEmails(List<Lead> leads) {
        Set<String> uniqueEmails = new Set<String>();
        for (Lead l : leads) {
            if (String.isNotBlank(l.Email)) {
                uniqueEmails.add(l.Email.toLowerCase());
            }
        }
        return uniqueEmails;
    }

    private static Map<String, Lead> getMatchingParentLeadsByEmail(Set<String> uniqueEmails) {
        // Get the matching leads by email.  There might be multiple with the same email.
        List<Lead> matchingLeadsList = [SELECT Id, Email, PLDLeadType__c, PLDParentLead__c
            FROM Lead
            WHERE Email = :uniqueEmails AND PLDLeadType__c = :Constants.LEAD_PLD_LEAD_TYPE_PARENT];

        Map<String, Lead> matchingLeadsByEmail = new Map<String, Lead>();
        for (Lead l : matchingLeadsList) {
            if (!matchingLeadsByEmail.containsKey(l.Email.toLowerCase())) {
                matchingLeadsByEmail.put(l.Email.toLowerCase(), l);
            }
        }
        return matchingLeadsByEmail;
    }

}