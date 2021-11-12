@isTest
private class HRC_OpportunityMatrixControllerTest {

    static testMethod void testController() {
        List<Account> accounts = new List<Account>();
        RecordType rt = [select Id from RecordType where Name = 'Facility' and SObjectType = 'Account']; 
        
        SObject aBase1 = new Account(RecordTypeId = rt.Id, Name = 'Account ', BillingCountry = 'United States', CurrencyIsoCode = 'USD', Cat_Code_16__c = 'CPT', Cat_Code_12__c = 'IDN');
        for(Schema.FieldSetMember f : SObjectType.Account.FieldSets.TERRITORY_FIELDS.getFields()) {
                aBase1.put(f.getFieldPath(), f.getFieldPath().replaceAll('_', ' ') + ' 1');
        }
        for(Schema.FieldSetMember f : SObjectType.Account.FieldSets.AE_ROLE_FIELDS.getFields()) {
                aBase1.put(f.getFieldPath(), f.getFieldPath().replaceAll('_', ' ') + ' 1');
        }
        
        SObject aBase5 = new Account(RecordTypeId = rt.Id, Name = 'Account ', BillingCountry = 'United States', CurrencyIsoCode = 'USD', Cat_Code_16__c = 'CPT', Cat_Code_12__c = 'HP');
        for(Schema.FieldSetMember f : SObjectType.Account.FieldSets.TERRITORY_FIELDS.getFields()) {
                aBase5.put(f.getFieldPath(), f.getFieldPath().replaceAll('_', ' ') + ' 1');
        }
        for(Schema.FieldSetMember f : SObjectType.Account.FieldSets.AE_ROLE_FIELDS.getFields()) {
                aBase5.put(f.getFieldPath(), f.getFieldPath().replaceAll('_', ' ') + ' 1');
        }
        
        SObject aBase6 = new Account(RecordTypeId = rt.Id, Name = 'Account ', BillingCountry = 'United States', CurrencyIsoCode = 'USD', Cat_Code_16__c = 'CPT', Cat_Code_12__c = 'LP');
        for(Schema.FieldSetMember f : SObjectType.Account.FieldSets.TERRITORY_FIELDS.getFields()) {
                aBase6.put(f.getFieldPath(), f.getFieldPath().replaceAll('_', ' ') + ' 1');
        }
        for(Schema.FieldSetMember f : SObjectType.Account.FieldSets.COM_ROLE_FIELDS.getFields()) {
                aBase6.put(f.getFieldPath(), f.getFieldPath().replaceAll('_', ' ') + ' 1');
        }
        
        SObject aBase2 = new Account(RecordTypeId = rt.Id, Name = 'Account ', BillingCountry = 'United States', CurrencyIsoCode = 'USD', Cat_Code_16__c = 'DEF', Cat_Code_12__c = 'HP');
        for(Schema.FieldSetMember f : SObjectType.Account.FieldSets.TERRITORY_FIELDS.getFields()) {
                aBase2.put(f.getFieldPath(),'OPEN ' +  f.getFieldPath().replaceAll('_', ' ') + ' 2');
        }
        for(Schema.FieldSetMember f : SObjectType.Account.FieldSets.COM_ROLE_FIELDS.getFields()) {
                aBase2.put(f.getFieldPath(), f.getFieldPath().replaceAll('_', ' ') + ' 2');
        }
        
        SObject aBase3 = new Account(RecordTypeId = rt.Id, Name = 'Account ', BillingCountry = 'Canada', CurrencyIsoCode = 'USD', Cat_Code_16__c = 'DEF', Cat_Code_12__c = 'LP');
        for(Schema.FieldSetMember f : SObjectType.Account.FieldSets.TERRITORY_FIELDS.getFields()) {
                aBase3.put(f.getFieldPath(), 'OPEN ' +  f.getFieldPath().replaceAll('_', ' ') + ' 3');
        }
        for(Schema.FieldSetMember f : SObjectType.Account.FieldSets.SPECIALIST_ROLE_FIELDS.getFields()) {
                aBase3.put(f.getFieldPath(), f.getFieldPath().replaceAll('_', ' ') + ' 3');
        }
        
        SObject aBase4 = new Account(RecordTypeId = rt.Id, Name = 'Account ', BillingCountry = 'Canada', CurrencyIsoCode = 'USD', Cat_Code_16__c = 'DEF', Cat_Code_12__c = 'IDN');
        for(Schema.FieldSetMember f : SObjectType.Account.FieldSets.TERRITORY_FIELDS.getFields()) {
                aBase4.put(f.getFieldPath(), 'OPEN ' +  f.getFieldPath().replaceAll('_', ' ') + ' 4');
        }
        for(Schema.FieldSetMember f : SObjectType.Account.FieldSets.SPECIALIST_ROLE_FIELDS.getFields()) {
                aBase4.put(f.getFieldPath(), f.getFieldPath().replaceAll('_', ' ') + ' 3');
        }
        
   
        for(integer i = 0; i < 5; i ++ ) {
            SObject a = aBase1.clone(false, true, false, false);
            Account acc = (Account) a;
            acc.Name += '' + i;
            accounts.add(acc);
        }
        
        for(integer i = 0; i < 5; i ++ ) {
            SObject a = aBase2.clone(false, true, false, false);
            Account acc = (Account) a;
            acc.Name += '' + (i + 5);
            accounts.add(acc);
        }
        for(integer i = 0; i < 5; i ++ ) {
            SObject a = aBase3.clone(false, true, false, false);
            Account acc = (Account) a;
            acc.Name += '' + (i + 100);
            accounts.add(acc);
        }
        for(integer i = 0; i < 5; i ++ ) {
            SObject a = aBase4.clone(false, true, false, false);
            Account acc = (Account) a;
            acc.Name += '' + (i + 15);
            accounts.add(acc);
        }
        for(integer i = 0; i < 5; i ++ ) {
            SObject a = aBase5.clone(false, true, false, false);
            Account acc = (Account) a;
            acc.Name += '' + (i + 200);
            accounts.add(acc);
        }
        for(integer i = 0; i < 5; i ++ ) {
            SObject a = aBase6.clone(false, true, false, false);
            Account acc = (Account) a;
            acc.Name += '' + (i + 25);
            accounts.add(acc);
        }
        insert accounts;
        
        List<Contact> contacts = new List<Contact>();
        
        for(Account a : accounts) {
            contacts.add(new Contact(LastName = 'Contact ' + a.Name, email='sftest@hill-rom.com', AccountId = a.Id, Role__c = 'Administrator',   Department_UK__c = 'Finance', CurrencyIsoCode = 'USD'));
        }
        insert contacts;
        
        //<option value="Closed Won">Closed Won</option><option value="Closed Lost">Closed Lost</option>
        RecordType ort = [select Id from RecordType where Name = 'B2C' and SObjectType = 'Opportunity'];
        List<Opportunity> opps = new List<Opportunity>();
        List<String> stages = new List<String>{'Qualified Opportunity', 'Qualified Opportunity', 'Developing Opportunity', 'Confirmed Opportunity', 'Finalizing Closure', 'Gaining Commitment'};
        Date closeDate = date.today().addMonths(-12); 
        Double amount = 1231;
        Integer stageCount = 0;
        for(Contact c : contacts) {
            opps.add(new Opportunity(Name = c.LastName, AccountId = c.AccountId, RecordTypeId = ort.Id, CurrencyIsoCode = 'USD',
                        StageName =  stages[stageCount], CloseDate = closeDate.addMonths(stageCount * 3),
                        Amount = (amount * (stageCount + 1) * 1.379),
                        Order_Contact__c = c.Id
                        )); 
                        
            stageCount ++;
            if(stageCount == 6) {
                stageCount = 0;
            }
        }
        
        opps.add(new Opportunity(Name = contacts[0].LastName, AccountId = contacts[0].AccountId, RecordTypeId = ort.Id, CurrencyIsoCode = 'USD',
                        StageName =  'Closed Won', CloseDate = closeDate.addMonths(2 * 3),
                        Amount = (amount * 1.379),
                        Order_Contact__c = contacts[0].Id, Win_Loss_Reason__c = 'Competitive Pricing',Loss_Comment__c = 'Some Reason'
                        ));
                        
        insert opps;
        
        HRC_OpportunityMatrixController omc = new HRC_OpportunityMatrixController();
        System.debug('Oportunities: ' + omc.getOpportunities().size());
        System.debug('closeDateRanges: ' + omc.closeDateRanges);
        System.debug('probabilityRanges: ' + omc.probabilityRanges);
        System.debug('types: ' + omc.types);
        omc.actionOnPageLoad();
        omc.loadData();
        System.debug('Oportunities: ' + omc.getOpportunities().size());
        
        omc.closeDateRange = 'FY';
        omc.probabilityRange = '30';
        omc.userLevel = 2;
        omc.userRole = 'Specialist';
        omc.picklistChanged();
        omc.renderMatrix();

        
        System.debug('Oportunities: ' + omc.getOpportunities().size());
    }
}