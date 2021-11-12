/******************************************************************************************************* 
Class       :   HRCCFR_TestSetupData
Description :   Utility class for providing test data related to CFR App.

*******************************************************************************************************/
@isTest
public class HRCCFR_TestSetupData {
    
    //   Method to create a User record
    public static User createUser(Profile prof, string uniqueSuffix){
         Integer randomInteger = Integer.valueOf(math.rint(math.random()*1000000));
        User userRec = new User(UserName            = 'user_'+ uniqueSuffix + randomInteger +'@hill-rom.com' ,                              
                                JDE_External_Id__c  = 'CFR'+ uniqueSuffix,
                                LastName            = 'test_ ' + uniqueSuffix, 
                                Email               = 'user_' + uniqueSuffix + '@hill-rom.com', 
                                Alias               = 'user_ ' + uniqueSuffix,
                                CommunityNickname   = 'test_' + uniqueSuffix,
                                TimeZoneSidKey      = 'America/Los_Angeles', 
                                LocaleSidKey        = 'en_US', 
                                EmailEncodingKey    = 'UTF-8', 
                                ProfileId           = prof.Id,
                                LanguageLocaleKey   = 'en_US', 
                                isActive                = true
                            );      
        return userRec;
    }
   
    //  Method to create a User record
    public static User getUser(string profileName){
        User userRec = [select id, Username, LastName, Email, Alias, CommunityNickname, TimeZoneSidKey, LocaleSidKey, 
                        EmailEncodingKey, ProfileId, LanguageLocaleKey from user where profile.name = :profileName limit 1];
        return userRec;
    }
    
    
    //Method to fetch profile
    public static Profile getProfile(String profileName){
        Profile userProfile = [ Select Id From Profile Where Name = :ProfileName limit 1 ];
        return userProfile; 
    }
    
    //Method to create a Capital Request
    public static Capital_Requests__c createCapitalRequest(Id recordType, String name){
        Capital_Requests__c cr = new Capital_Requests__c(recordTypeID = recordType, 
                                                        Executive_Summary__c='test', 
                                                        Project_Name__c= name,
                                                        Project_Objective__c = 'test');
        //insert cr;
        return cr;
    }
    
    //Method to fetch Capital Request record
    public static Capital_Requests__c getCapitalRequest(String Name){
        try{
            Capital_Requests__c cr = [select Name,Status__c,Last_Approved_Step__c,InitiateAutoApproveProcess__c,
                                             Auto_Approve_Step_HelperField__c, Approver_1__c, Approver_2__c,
                                             Approver_3__c, Approver_4__c 
                                      from Capital_Requests__c where Project_Name__c=: Name limit 1];
            return cr;
        }catch(Exception e){
            return null;
        }
    }
    
    //Method to create a Capital_Iem__c
    public static Capital_Iem__c createCapitalItem(Id capitalRequestId, integer amount){
        Capital_Iem__c cr = new Capital_Iem__c(Capital_Request__c = capitalRequestId, 
                                               Original__c = amount,
                                               Capital_Item__c = 'test Capital Item');
        
        return cr;
    }
    
    //Method to fetch Capital_Iem__c record
    public static Capital_Iem__c getCapitalItem(String crName){
        try{
            Capital_Iem__c cr = [select Name from Capital_Iem__c where Name =: crName limit 1];
            return cr;
        }catch(Exception e){
            return null;
        }
    }
    
    //Method to create a Expense_Item__c
    public static Expense_Item__c createExpenseItem(Id capitalRequestId, integer amount){
        Expense_Item__c cr = new Expense_Item__c(Expense_Item__c = capitalRequestId, 
                                                 Original__c = amount);
        
        return cr;
    }
    
    //Method to fetch Capital_Iem__c record
    public static Expense_Item__c getExpenseItem(String crName){
        try{
            Expense_Item__c cr = [select Name from Expense_Item__c where Name =: crName limit 1];
            return cr;
        }catch(Exception e){
            return null;
        }
    }
   /** 
    //Method to fetch Capital_Iem__c record
    public static List<HRCCFR_Capital_ApprovalStep_Queue_pair> getCapitalCustomSetting(){
       //HRCCFR_Capital_ApprovalStep_Queue_pair = new HRCCFR_Capital_ApprovalStep_Queue_pair();
       
    }
    **/
    
}//End Class