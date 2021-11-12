@isTest(seeAllData=true)
public class UpdateCustomFieldsOnTaskProblemTest
{
    public static TestMethod void Test0_TestInsertWithValue() {
    
        Profile p = [Select Id,Name from Profile where Name = 'System Administrator' limit 1];

               
        
        User u = new User(Username='1463tset1useaher1@hill-rom.com',LastName = 'test',email = 'test1@hill-rom.com',ProfileId = p.Id, Alias = 'tst',
        TimeZoneSidKey = 'America/Chicago',localesidkey='en_US',emailencodingkey='UTF-8',languagelocalekey='en_US',JDE_External_Id__c='1209');
        
        insert u;
        
                BMCServiceDesk__Problem__c problemObj = new BMCServiceDesk__Problem__c(BMCServiceDesk__Problem_Description__c='Test Description', OwnerId=UserInfo.getUserId());
        problemObj.Operational_Catalog_Tier_1__c = 'Administrative';
        problemObj.Operational_Catalog_Tier_2__c = 'Facilities';
        problemObj.Product_Catalog_Tier_1__c = 'Laptop';
        problemObj.Product_Catalog_Tier_2__c = 'MacBook Pro';
        insert problemObj;
        
        BMCServiceDesk__Task__c probTaskObj = new BMCServiceDesk__Task__c(BMCServiceDesk__FKProblem__c= problemObj.ID);
        insert probTaskObj;
    }
}