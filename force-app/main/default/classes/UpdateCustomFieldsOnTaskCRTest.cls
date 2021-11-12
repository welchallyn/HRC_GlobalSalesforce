@isTest(seeAllData=true)
public class UpdateCustomFieldsOnTaskCRTest
{
    public static TestMethod void Test0_TestInsertWithValue() {
    
        Profile p = [Select Id,Name from Profile where Name = 'System Administrator' limit 1];

               
        
        User u = new User(Username='1463tset1useaher1@hill-rom.com',LastName = 'test',email = 'test1@hill-rom.com',ProfileId = p.Id, Alias = 'tst',
        TimeZoneSidKey = 'America/Chicago',localesidkey='en_US',emailencodingkey='UTF-8',languagelocalekey='en_US',JDE_External_Id__c='1209');
        
        insert u;
        
        BMCServiceDesk__Change_Request__c changeobj = new BMCServiceDesk__Change_Request__c();
        changeobj.Operational_Catalog_Tier_1__c = 'Administrative';
        changeobj.Operational_Catalog_Tier_2__c = 'Facilities';
        changeobj.Product_Catalog_Tier_1__c = 'Laptop';
        changeobj.Product_Catalog_Tier_2__c = 'MacBook Pro';
        insert changeobj ;
        
        BMCServiceDesk__Task__c changeTaskObj = new BMCServiceDesk__Task__c(BMCServiceDesk__FKChange__c = changeobj.ID);
        insert changeTaskObj;
    }
}