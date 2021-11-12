/* Class:       LeadTriggerHandlerTest
** Created by:  OpFocus (Jason Curry) on 2021-06-21
** Description: Trigger handler for Leads
*/

@IsTest(IsParallel=true)
private class LeadTriggerHandlerTest {

    private static User SALES_USER {
        get {
            if (SALES_USER == null) {
                SALES_USER = [SELECT Id FROM User WHERE (NOT Username LIKE :Constants.PARDOT_USERNAME) AND IsActive = TRUE LIMIT 1];
            }
            return SALES_USER;
        }
        set;
    }

    @TestSetup
    static void makeData() {
        System.runAs(Constants.PARDOT_USER) {
            List<Lead> leads = new List<Lead>();
            Lead parent = new Lead(
                    FirstName = 'Test',
                    LastName = 'Parent1',
                    Phone = '555-555-5555',
                    Email = 'testparent1@testingParent.test',
                    Comments__c = 'Parent1 Comments',
                    Company = 'Test Company',
                    Country = 'United States',
                    Title = 'Title',
                    RecordTypeId = Constants.LEAD_RECORD_TYPES_BY_DEVELOPER_NAME.get('Inside_Sales').recordTypeId,
                    OwnerId = SALES_USER.Id
            );
            leads.add(parent);

            Lead child = new Lead(
                    FirstName = 'Test',
                    LastName = 'Parent1',
                    Phone = '555-555-5555',
                    Email = 'testparent1@testingParent.test',
                    Comments__c = 'Child Comments',
                    Company = 'Test Company',
                    Country = 'United States',
                    Title = 'Title',
                    RecordTypeId = Constants.LEAD_RECORD_TYPES_BY_DEVELOPER_NAME.get('Inside_Sales').recordTypeId,
                    OwnerId = SALES_USER.Id
            );
            leads.add(child);

            insert leads;
        }

        List<Lead> insertedLeads = [SELECT Id, RecordType.DeveloperName, OwnerId, Owner.Name, Owner.Username, PLDLeadType__c FROM Lead ORDER BY PLDLeadType__c ASC];
        System.assertEquals(3, insertedLeads.size());
        System.assertEquals(Constants.LEAD_PLD_LEAD_TYPE_PARENT, insertedLeads[0].PLDLeadType__c);
        System.debug('##### insertedLeads[0]: ' + insertedLeads[0]);
        System.assertEquals(Constants.PARDOT_USER.Id, insertedLeads[0].OwnerId);
        System.assertEquals('Parent_Lead', insertedLeads[0].RecordType.DeveloperName);
        System.assertEquals(Constants.LEAD_PLD_LEAD_TYPE_CHILD, insertedLeads[1].PLDLeadType__c);
        System.assertNotEquals(Constants.PARDOT_USER.Id, insertedLeads[1].OwnerId);
        System.assertNotEquals('Parent_Lead', insertedLeads[1].RecordType.DeveloperName);
        System.assertEquals(Constants.LEAD_PLD_LEAD_TYPE_CHILD, insertedLeads[2].PLDLeadType__c);
        System.assertNotEquals(Constants.PARDOT_USER.Id, insertedLeads[2].OwnerId);
        System.assertNotEquals('Parent_Lead', insertedLeads[2].RecordType.DeveloperName);

        System.runAs(Constants.PARDOT_USER) {
            List<Lead> pardotVisibleLeads = [SELECT Id, RecordType.DeveloperName, OwnerId, Owner.Name, Owner.Username, PLDLeadType__c FROM Lead ORDER BY PLDLeadType__c ASC];
            System.assertEquals(1, pardotVisibleLeads.size());
        }
    }

    static List<String> CARECATEGORY_PICKLIST_VALUES {
        get {
            if (CARECATEGORY_PICKLIST_VALUES == null) {
                CARECATEGORY_PICKLIST_VALUES = new List<String>();

                Schema.DescribeFieldResult fieldResult = Lead.Care_Category__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                for (Schema.PicklistEntry pickListVal : ple) {
                    CARECATEGORY_PICKLIST_VALUES.add(pickListVal.getValue());
                }
            }
            return CARECATEGORY_PICKLIST_VALUES;
        }
        private set;
    }

    @IsTest static void validateTextFieldMerge() {
        Test.startTest();
        Test.stopTest();

        List<Lead> leads = [SELECT Id, PLDLeadType__c, Comments__c FROM Lead WHERE LastName = 'Parent1' ORDER BY PLDLeadType__c ASC];

        System.assertEquals(3, leads.size(), 'Should only be 3 leads, 1 parent and 2 child');
        System.assertEquals(Constants.LEAD_PLD_LEAD_TYPE_PARENT, leads[0].PLDLeadType__c);
        System.assertEquals('Parent1 Comments;Child Comments', leads[0].Comments__c);
    }

    @IsTest static void newParentLead() {
        Test.startTest();
        Lead l = null;
        System.runAs(Constants.PARDOT_USER) {
            l = new Lead(
                    FirstName = 'Test',
                    LastName = 'User',
                    Phone = '555-555-5555',
                    Email = 'testuser@testing.test',
                    RecordTypeId = Constants.LEAD_RECORD_TYPES_BY_DEVELOPER_NAME.get('Inside_Sales').recordTypeId
            );

            insert l;
        }
        Test.stopTest();

        l = [SELECT Id, Name, FirstName, LastName, Email, PLDLeadType__c, PLDParentLead__c, Comments__c FROM Lead WHERE Id = :l.Id LIMIT 1];
        System.assertEquals(Constants.LEAD_PLD_LEAD_TYPE_CHILD, l.PLDLeadType__c, 'PLDLeadType should be Child.');

        Lead lc = [SELECT Id, Name, FirstName, LastName, Email, PLDLeadType__c, PLDParentLead__c, Comments__c, Status FROM Lead WHERE Id = :l.PLDParentLead__c LIMIT 1];
        System.assertEquals(Constants.LEAD_PLD_LEAD_TYPE_PARENT, lc.PLDLeadType__c, 'PLDLeadType should be Parent.');
        System.assertEquals('Parent Lead', lc.Status);
        System.assertEquals(l.PLDParentLead__c, lc.Id, 'PLDParentLead should be the Id of the first lead.');
    }

    @IsTest static void newChildLead() {
        Test.startTest();
        Lead l = new Lead(
                FirstName = 'Test',
                LastName = 'Parent1',
                Phone = '555-777-5555',
                MobilePhone = '555-666-5555',
                Fax = '555-444-5555',
                Email = 'testparent1@testingParent.test',
                Company = 'Updated Company',
                Title = 'Updated Title',
                Comments__c = 'More Child Comments',
                Street = '123 Main',
                City = 'San Francisco',
                State = 'CA',
                PostalCode = '20202',
                Country = 'USA',
                HasOptedOutOfEmail = true,
                DoNotCall = true,
                pi__comments__c = 'Child Pardot Comments',
                PrimaryProduct__c = 'Beds',
                Primary_Product_of_Interest__c = 'Bariatrics',
                Pardot_Department__c = 'Nursing',
                RecordTypeId = Constants.LEAD_RECORD_TYPES_BY_DEVELOPER_NAME.get('Inside_Sales').recordTypeId
        );
        insert l;
        Test.stopTest();
        Lead pl = [SELECT Id, Phone, Company, Title, Comments__c, pi__comments__c, HasOptedOutOfEmail FROM Lead WHERE PLDLeadType__c = :Constants.LEAD_PLD_LEAD_TYPE_PARENT AND Email = :l.Email LIMIT 1];
        System.assertEquals('555-777-5555', pl.Phone, 'Parent phone was not updated.');
        System.assertEquals('Updated Company', pl.Company);
        System.assertEquals('Updated Title', pl.Title);
        System.assertEquals('Parent1 Comments;Child Comments;More Child Comments', pl.Comments__c);
        System.assertEquals(true, pl.HasOptedOutOfEmail);
        System.assertEquals('Child Pardot Comments', pl.pi__comments__c);
        /*l = [SELECT Id, Company, PLDLeadType__c, PLDParentLead__c FROM Lead WHERE Id = :l.Id];
        System.assertEquals(Constants.LEAD_PLD_LEAD_TYPE_CHILD, l.PLDLeadType__c, 'PLDLeadType should be Child');
        System.assertEquals(pl.Id, l.PLDParentLead__c, 'PLDParentLead should be set to parent.');*/
        List<Lead> childLeads = [SELECT Id, Phone, Company, Title, Comments__c, pi__comments__c, HasOptedOutOfEmail, PLDLeadType__c, PLDParentLead__c FROM Lead WHERE PLDLeadType__c = :Constants.LEAD_PLD_LEAD_TYPE_CHILD AND PLDParentLead__c = :pl.Id];
        System.assertEquals(3, childLeads.size(), 'Should be 3 child leads, the 2 from setup and the one just created in this test.');
        for (Lead cl : childLeads) {
            System.assertEquals(Constants.LEAD_PLD_LEAD_TYPE_CHILD, cl.PLDLeadType__c, 'PLDLeadType should be Child');
            System.assertEquals(pl.Id, cl.PLDParentLead__c, 'PLDParentLead should be set to parent.');
            System.assertEquals('555-777-5555', cl.Phone);
            System.assertEquals('Updated Company', cl.Company);
            System.assertEquals('Updated Title', cl.Title);
            System.assertNotEquals('Parent1 Comments;Child Comments;More Child Comments', cl.Comments__c);
            System.assertEquals(true, cl.HasOptedOutOfEmail);
            if (cl.Id == l.Id) {
                System.assertEquals('Child Pardot Comments', cl.pi__comments__c);
            } else {
                System.assertEquals(null, cl.pi__comments__c);
            }
        }
    }

    @IsTest static void childUpdatesParent() {
        Lead childLead = [SELECT Id, PLDParentLead__c FROM Lead WHERE PLDLeadType__c = :Constants.LEAD_PLD_LEAD_TYPE_CHILD LIMIT 1];
        System.assertNotEquals(null, childLead.PLDParentLead__c);
        System.debug('#### childLead: ' + childLead);
        childLead.FirstName = 'EditedFirst';

        Test.startTest();
        update childLead;
        Test.stopTest();

        System.debug('#### PLDParentLead: ' + childLead.PLDParentLead__c);
        Lead parentLead = [SELECT Id, FirstName FROM Lead WHERE Id = :childLead.PLDParentLead__c LIMIT 1];
        System.assertEquals('EditedFirst', parentLead.FirstName, 'Parent FirstName was not updated');

        Lead otherChild = [SELECT Id, FirstName, PLDParentLead__c FROM Lead
        WHERE Id != :childLead.Id AND PLDLeadType__c = :Constants.LEAD_PLD_LEAD_TYPE_CHILD AND PLDParentLead__c = :childLead.PLDParentLead__c
        LIMIT 1];
        System.assertEquals('EditedFirst', otherChild.FirstName, 'Other Child FirstName was not updated: ' + otherChild);
    }

    @IsTest static void parentUpdatesChildren() {
        Lead parentLead = [SELECT Id, PLDParentLead__c FROM Lead WHERE PLDLeadType__c = :Constants.LEAD_PLD_LEAD_TYPE_PARENT LIMIT 1];
        parentLead.FirstName = 'EditedParentFirst';

        Test.startTest();
        update parentLead;
        Test.stopTest();

        List<Lead> childLeads = [SELECT Id, FirstName FROM Lead WHERE PLDLeadType__c = :Constants.LEAD_PLD_LEAD_TYPE_CHILD];
        System.assertEquals(2, childLeads.size());
        for (Lead l : childLeads) {
            System.assertEquals('EditedParentFirst', l.FirstName, 'Child FirstName was not updated.');
        }
    }

    @IsTest static void insertMultipleLeadsWithSameEmail() {
        List<Lead> newLeads = new List<Lead>();
        newLeads.add(new Lead(
                FirstName = 'Test',
                LastName = 'Parent1',
                Phone = '555-777-5555',
                Email = 'testparent2@testingParent.test',
                Care_Category__c = CARECATEGORY_PICKLIST_VALUES[0],
                RecordTypeId = Constants.LEAD_RECORD_TYPES_BY_DEVELOPER_NAME.get('Inside_Sales').recordTypeId
        ));

        newLeads.add(new Lead(
                FirstName = 'Test',
                LastName = 'Parent1',
                Phone = '555-777-5555',
                Email = 'testparent2@testingParent.test',
                Care_Category__c = CARECATEGORY_PICKLIST_VALUES[1],
                RecordTypeId = Constants.LEAD_RECORD_TYPES_BY_DEVELOPER_NAME.get('Inside_Sales').recordTypeId
        ));

        newLeads.add(new Lead(
                FirstName = 'Test',
                LastName = 'Parent1',
                Phone = '555-777-5555',
                Email = 'testparent2@testingParent.test',
                Care_Category__c = CARECATEGORY_PICKLIST_VALUES[3],
                RecordTypeId = Constants.LEAD_RECORD_TYPES_BY_DEVELOPER_NAME.get('Inside_Sales').recordTypeId
        ));

        Test.startTest();
        insert newLeads;
        Test.stopTest();

        List<Lead> leads = [SELECT
                Id,
                All_Interested_Care_Categories__c,
                Care_Category__c,
                PLDParentLead__c,
                PLDLeadType__c
        FROM Lead
        WHERE Email = 'testparent2@testingParent.test' ORDER BY PLDLeadType__c ASC];

        System.assertEquals(4, leads.size());
        System.assertEquals(Constants.LEAD_PLD_LEAD_TYPE_PARENT, leads[0].PLDLeadType__c);

        System.assertEquals(Constants.LEAD_PLD_LEAD_TYPE_CHILD, leads[1].PLDLeadType__c);
        System.assertEquals(leads[0].Id, leads[1].PLDParentLead__c);

        System.assertEquals(Constants.LEAD_PLD_LEAD_TYPE_CHILD, leads[2].PLDLeadType__c);
        System.assertEquals(leads[0].Id, leads[2].PLDParentLead__c);

        System.assertEquals(Constants.LEAD_PLD_LEAD_TYPE_CHILD, leads[3].PLDLeadType__c);
        System.assertEquals(leads[0].Id, leads[3].PLDParentLead__c);

        System.assert(leads[0].All_Interested_Care_Categories__c.contains(leads[1].Care_Category__c));
        System.assert(leads[0].All_Interested_Care_Categories__c.contains(leads[2].Care_Category__c));
        System.assert(leads[0].All_Interested_Care_Categories__c.contains(leads[3].Care_Category__c));
    }

    @IsTest static void leadWithNoEmail() {
        Test.startTest();
        Lead l = new Lead(
                FirstName = 'Test',
                LastName = 'User',
                Phone = '555-555-5555',
                RecordTypeId = Constants.LEAD_RECORD_TYPES_BY_DEVELOPER_NAME.get('Inside_Sales').recordTypeId
        );

        insert l;
        Test.stopTest();

        l = [SELECT Id, Name, FirstName, LastName, Email, PLDLeadType__c, PLDParentLead__c
            FROM Lead WHERE Id = :l.Id];
        System.assertEquals(null, l.PLDLeadType__c, 'PLDLeadType should be NULL because no email.');
    }


}