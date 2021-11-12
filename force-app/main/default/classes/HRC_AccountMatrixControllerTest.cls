@isTest
public class HRC_AccountMatrixControllerTest {
    public static testmethod void testController() { 
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
        
        HRC_AccountMatrixController amc = new HRC_AccountMatrixController();
        System.debug(amc.getAccounts());
        System.debug(amc.isAVP_DVP_User);
        
        amc.isAVP_DVP_User = true;
        
        amc.userRole = 'COM';
        System.debug(amc.aeUsers); 
        
        
        amc.userRole = 'Account Executive';
        System.debug(amc.aeUsers);
        
        
        amc.userRole = 'Specialist';
        System.debug(amc.aeUsers);
        
        System.debug(amc.territories);
        System.debug(amc.roles);
        amc.territory = 'Open';
        amc.aeUser = String.valueOf(UserInfo.getUserId());
        System.debug(amc.getAccounts());
        
        amc.userRole = 'Specialist';
        amc.territory = 'Primary';
        amc.aeUser = String.valueOf(UserInfo.getUserId());
        System.debug(amc.getAccounts());
    }
}