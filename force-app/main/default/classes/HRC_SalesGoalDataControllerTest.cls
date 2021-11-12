@isTest
public class HRC_SalesGoalDataControllerTest
{
    public static testmethod void testSalesGoalData()
    {
        User u = createUser();
        
        Sales_Goal_Data__c sg = new Sales_Goal_Data__c(TERR_CD__c='123', PK_SALES_GOALS__c = 2, Sales_User__c = u.Id);
        insert sg;
        
        System.assert([select Id, OwnerId, Sales_User__c from Sales_Goal_Data__c where Id = :sg.Id limit 1].OwnerId == u.Id);
        
        sg.Sales_User__c = Userinfo.getUserId();
        update sg;
        
        System.assert([select Id, OwnerId, Sales_User__c from Sales_Goal_Data__c where Id = :sg.Id limit 1].OwnerId == Userinfo.getUserId());
    }
    private static User createUser()
    {
        String uniqueKey = '49a84701';
        User testUser ;
        testUser = new User();
        testUser.Alias = uniqueKey;
        testUser.Email = uniqueKey + '@hill-rom.com';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.LastName = 'Test' + uniqueKey;
        testUser.LanguageLocaleKey = 'en_US';
        testUser.LocaleSidKey = 'en_US';
        testUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'HRC Account Executive'].Id;
        testUser.TimeZoneSidKey = 'America/Chicago';
        testUser.Username = uniqueKey + 'test' + Math.round(Math.random() * 10000) + '@hill-rom.com';
        testUser.UserRoleId = null;
        testUser.Country = 'United States';
        insert testUser;
        return testUser;
    }
}