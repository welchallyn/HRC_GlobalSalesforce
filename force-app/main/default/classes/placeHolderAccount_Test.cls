@isTest ( seealldata = true)
private class placeHolderAccount_Test{
public static testMethod void test() { 

        Profile objProfileSalesAdmin = [SELECT Id FROM profile where name like '%system%' limit 1]; 
      
       
    UserRole objUserrole = [SELECT Id FROM UserRole limit 1]; 
     
        User objUserSalesAdmin = new User(alias = 'salesadm', email='salesadmin@hill-rom.com', emailencodingkey='UTF-8',
                         lastname='Testing', languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='America/Los_Angeles',
                         username='salesadmin@hill-rom.com', profileid = objProfileSalesAdmin.Id, userRoleId=objUserrole.Id, JDE_External_ID__c='test');
            
           
        List<User> list_User = new List<User>();
        
        list_User.add(objUserSalesAdmin);
         Test.StartTest();
        insert list_User;
        Test.stopTest();
        }
        }