@isTest(seeAllData=true)
public class UpdateCustomFieldsOnTaskIncidentTest
{
    public static TestMethod void Test0_TestInsertWithValue() {
    
        Profile p = [Select Id,Name from Profile where Name = 'System Administrator' limit 1];

               
        
        User u = new User(Username='1463tset1useaher1@hill-rom.com',LastName = 'test',email = 'test1@hill-rom.com',ProfileId = p.Id, Alias = 'tst',
        TimeZoneSidKey = 'America/Chicago',localesidkey='en_US',emailencodingkey='UTF-8',languagelocalekey='en_US',JDE_External_Id__c='1209');
        
        insert u;

        BMCServiceDesk__Incident__c incidentObj = new BMCServiceDesk__Incident__c();
        incidentObj.BMCServiceDesk__FKClient__c= u.id;
        incidentObj.Operational_Catalog_Tier_1__c = 'Administrative';
        incidentObj.Operational_Catalog_Tier_2__c = 'Facilities';
        incidentObj.Product_Catalog_Tier_1__c = 'Laptop';
        incidentObj.Product_Catalog_Tier_2__c = 'MacBook Pro';
        insert incidentObj;
        
        BMCServiceDesk__Task__c incTaskObj = new BMCServiceDesk__Task__c(BMCServiceDesk__FKIncident__c = incidentObj.ID);
        insert incTaskObj;
        
        
    }
}