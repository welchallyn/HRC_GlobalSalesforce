@IsTest
public class CreateAndUpdateManualShares {
   Map<string,string> roleNameIdMap = new Map<string,string>();
   Map<string,string> profileNameIdMap = new Map<string,string>();
    @IsTest
   public static void TestCreateShares(){
        createTestUsers();
        Test.startTest();
       
        /* #24 Jitendra,moved below code into future method; code starts */
         testValidations();
        /* #24 Jitendra, code ends  */
        Test.stopTest();
       
        //Verify share for new user is created
        //Company_Car_Request__Share carshrnew = [SELECT UserOrGroupId FROM Company_Car_Request__Share WHERE
        //                                  UserOrGroupId = '005E00000030hoP' AND ParentId = :car.Id];
        //System.assert(carshrnew.Id != null);
    }
    
    @future
    public static void testValidations(){
        User employeeName = GetTestUser('Erp_Specialist_Pietro_Delfrati','System Administrator');
        User employeeManager = GetTestUser('Regional_Vp_Apac_Abinash_Nayak','INT Sales Manager v2.0');
        User nextLevelManager = GetTestUser('It_Service_Delivery_Teamleader_Alexander_Wojtowicz','ServiceDesk Change Manager');
        User gmVP = GetTestUser('Director_Quality_Ra_Alfredo_Rodriguez_Garza6','ServiceDesk Change Manager');
        User hrManagerDirector =GetTestUser('Executive_Director_R_D_Alvin_Tan','ServiceDesk Client');
        
        Compensation_Request__c cr = new Compensation_Request__c (Employee_Name__c = employeeName.id,Employee_s_Manager__c =employeeManager.id,
                                                                 Next_Level_Manager__c = nextLevelManager.id,GM_VP__c = gmVP.id,
                                                                 HR_Manager_Director__c = hrManagerDirector.id,Current_Currency__c='AED',Proposed_Currency__c='ARS');
        try{
           insert cr;
        }catch(Exception e){
          system.debug('Exception occurred... '+e);
        }
       
          
        cr = [SELECT Name FROM Compensation_Request__c WHERE Id = :cr.Id];
        User usrIdOrGroupId = GetTestUser('Regional_Vp_Apac_Abinash_Nayak','INT Sales Manager v2.0'); 
        Compensation_Request__Share crs = [SELECT UserOrGroupId FROM Compensation_Request__Share WHERE
                                          UserOrGroupId = :usrIdOrGroupId.id AND ParentId = :cr.Id];
       System.Assert(crs.Id !=null);
        User empManager = GetTestUser('Mgr_Human_Resources_Andrea_Watkins','ServiceDesk Client');
        //Replace current Employee's Manager with a new ID
        cr.Employee_s_Manager__c = empManager.id;
        
         try{
           update cr;
        }catch(Exception e){
          system.debug('Exception occurred... '+e);
        }
                
        //Verify share for new user is created
        Compensation_Request__Share crsnew = [SELECT UserOrGroupId FROM Compensation_Request__Share WHERE
                                          UserOrGroupId =:empManager.id AND ParentId = :cr.Id];
        System.assert(crsnew.Id != null);
        
        User carFleetManager = GetTestUser('Hr_Representative_Anne_Sandmann','ServiceDesk Client');
        User hrManager = GetTestUser('Account_Manager_Benoit_Martinez','INT Account Manager v2.0');
        User cbInternational = GetTestUser('Sales_and_Marketing_Director_Christopher_Hill','ServiceDesk Client');
        User directSuperVisor = GetTestUser('Country_Service_Director_David_Gittings','ServiceDesk Client');
        //Set up a Company Car Request record
        Company_Car_Request__c car = new Company_Car_Request__c (Car_Fleet_Manager__c = carFleetManager.id,HR_Manager__c = hrManager.id,
                                                                 C_B_International__c =cbInternational.id,Direct_Supervisor__c =directSuperVisor.id
                                                                 );
        
        try{
           insert car;
        }catch(Exception e){
          system.debug('Exception occurred... '+e);
        }
        car = [SELECT Name FROM Company_Car_Request__c WHERE Id = :car.Id];
        Company_Car_Request__Share carshr = [SELECT UserOrGroupId FROM Company_Car_Request__Share WHERE
                                          UserOrGroupId = :carFleetManager.id AND ParentId = :car.Id];
      System.Assert(carshr.Id !=null);
       
        User carDirectSuperVisor = GetTestUser('Territory_Sales_Manager_Edward_Birmingham','ServiceDesk Client');

        //Replace current Employee's Manager with a new ID
        car.Direct_Supervisor__c = carDirectSuperVisor.id;
       
        try{
           update car;
        }catch(Exception e){
          system.debug('Exception occurred... '+e);
        }
    }
     public static user GetTestUser(string  rolename, string profilename){   
            UserRole objRole = [SELECT Id,name FROM userrole where DeveloperName =:rolename ];
            //Get User Profile.
            Profile pf = [SELECT Id FROM Profile WHERE Name = :profilename];
            User sfdcuser = [select id from user where UserRoleId=:objRole.id AND ProfileId=:pf.id limit 1];
            return sfdcuser;
        }
      
    
        public static void createTestUsers(){
            Map<string,string> rlNameIdMap = new Map<string,string>();
            Map<string,string> pfNameIdMap = new Map<string,string>();
            List<string> profileList = new List<string>{'System Administrator','INT Sales Manager v2.0','ServiceDesk Change Manager','ServiceDesk Client','INT Account Manager v2.0'};
            List<string> roleList = new List<string>{'Erp_Specialist_Pietro_Delfrati','Regional_Vp_Apac_Abinash_Nayak','It_Service_Delivery_Teamleader_Alexander_Wojtowicz','Director_Quality_Ra_Alfredo_Rodriguez_Garza6','Executive_Director_R_D_Alvin_Tan','Mgr_Human_Resources_Andrea_Watkins','Hr_Representative_Anne_Sandmann','Account_Manager_Benoit_Martinez','Sales_and_Marketing_Director_Christopher_Hill','Country_Service_Director_David_Gittings','Territory_Sales_Manager_Edward_Birmingham'};
            // populate profile map
            for(Profile pf : [SELECT Id, Name FROM Profile WHERE Name in :profileList]){
                pfNameIdMap.put(pf.Name,pf.Id);
            }
            system.debug('.. pfNameIdMap==='+pfNameIdMap.size());
            
            // popupate role map
            for(UserRole ur : [SELECT Id,DeveloperName FROM userrole where DeveloperName in :roleList]){
                rlNameIdMap.put(ur.DeveloperName, ur.Id);
            }
            system.debug('.. rlNameIdMap==='+rlNameIdMap.size());
            
            List<UserRole> rolesToBeCreated = new List<UserRole>();
            for(String roleName : roleList){
                if(!rlNameIdMap.keySet().contains(roleName)){
                    UserRole ur = new UserRole(Name = roleName, developerName = roleName, OpportunityAccessForAccountOwner='Edit');
                    rolesToBeCreated.add(ur);
                }
            }
            system.debug('..roles to be created:::'+rolesToBeCreated.size());
            
            try{
            insert rolesToBeCreated;
          }catch(Exception e){
            system.debug('Exception occurred... '+e);
          }
            // Add newly created roles in the Map
            for(UserRole ur : rolesToBeCreated){
                rlNameIdMap.put(ur.developerName, ur.Id);
            }
            
            // instantiate users and insert
      List<user> userlist = new List<User>();
      //user1 - employee
      User employee = new User(FirstName='Employee',LastName='First',JDE_External_ID__c='emp', Alias='emp',UserName='test.user@welchallyn.com',Email='test.user@welchallyn.com',CommunityNickname='SSEmp', TimeZoneSidKey='GMT', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', UserRoleId = rlNameIdMap.get('Erp_Specialist_Pietro_Delfrati') , ProfileId = pfNameIdMap.get('System Administrator'));
      
      userlist.add(employee);
      
      //user2 - employee Manager
      User employeeManager = new User(FirstName='Employee',LastName='Manager',JDE_External_ID__c='empm',Alias='empm',UserName='emp.mngr@welchallyn.com',Email='emp.mngr@welchallyn.com',CommunityNickname='SSEmpm', TimeZoneSidKey='GMT', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', UserRoleId = rlNameIdMap.get('Regional_Vp_Apac_Abinash_Nayak') , ProfileId = pfNameIdMap.get('INT Sales Manager v2.0'));
      
      userlist.add(employeeManager);
      
      //user3 - nextLevelManager
      User nextLevelManager = new User(FirstName='Nxtlvl',LastName='Manager',JDE_External_ID__c='Nxtlvlm',Alias='Nxtlvlm',UserName='Nxtlvl.mngr@welchallyn.com',Email='Nxtlvl.mngr@welchallyn.com',CommunityNickname='Nxtlvlm', TimeZoneSidKey='GMT', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', UserRoleId = rlNameIdMap.get('It_Service_Delivery_Teamleader_Alexander_Wojtowicz') , ProfileId = pfNameIdMap.get('ServiceDesk Change Manager'));
      
      userlist.add(nextLevelManager);
      
      //user4 - gmVP
      User gmVP = new User(FirstName='gmVP',LastName='Manager',JDE_External_ID__c='gmVP',Alias='gmVP',UserName='gmVP.mngr@welchallyn.com',Email='gmVP.mngr@welchallyn.com',CommunityNickname='gmVPM', TimeZoneSidKey='GMT', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', UserRoleId = rlNameIdMap.get('Director_Quality_Ra_Alfredo_Rodriguez_Garza6') , ProfileId = pfNameIdMap.get('ServiceDesk Change Manager'));
      
      userlist.add(gmVP);
      
      //user5 - hrManagerDirector
      User hrManagerDirector = new User(FirstName='HRM',LastName='Manager',JDE_External_ID__c='HRM',Alias='HRM',UserName='hrm.mngr@welchallyn.com',Email='hrm.mngr@welchallyn.com',CommunityNickname='hrm', TimeZoneSidKey='GMT', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', UserRoleId = rlNameIdMap.get('Executive_Director_R_D_Alvin_Tan') , ProfileId = pfNameIdMap.get('ServiceDesk Client'));
      
      userlist.add(hrManagerDirector);
      
      //user6 - empManager
      User empManager = new User(FirstName='Andrea',LastName='TestWat',JDE_External_ID__c='andy',Alias='andy',UserName='andy.wat@welchallyn.com',Email='andy.wat@welchallyn.com',CommunityNickname='SSAW', TimeZoneSidKey='GMT', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', UserRoleId = rlNameIdMap.get('Mgr_Human_Resources_Andrea_Watkins') , ProfileId = pfNameIdMap.get('ServiceDesk Client'));
      
      userlist.add(empManager);
      
      //user7 - carFleetManager
      User carFleetManager = new User(FirstName='Fleet',LastName='Manager',JDE_External_ID__c='carflt',Alias='carflt',UserName='car.flt@welchallyn.com',Email='car.flt@welchallyn.com',CommunityNickname='SSCarFlt', TimeZoneSidKey='GMT', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', UserRoleId = rlNameIdMap.get('Hr_Representative_Anne_Sandmann') , ProfileId = pfNameIdMap.get('ServiceDesk Client'));
      
      userlist.add(carFleetManager);
      
      //user8 - hrManager
      User hrManager = new User(FirstName='HR',LastName='Manager',Alias='HRmngr',JDE_External_ID__c='HRmngr',UserName='hr.mngr@welchallyn.com',Email='hr.mngr@welchallyn.com',CommunityNickname='hrManager', TimeZoneSidKey='GMT', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', UserRoleId = rlNameIdMap.get('Account_Manager_Benoit_Martinez') , ProfileId = pfNameIdMap.get('INT Account Manager v2.0'));
      
      userlist.add(hrManager);
      
      //user9 - cbInternational
      User cbInternational = new User(FirstName='cb',LastName='Inter',JDE_External_ID__c='cbInter',Alias='cbInter',UserName='cb.inter@welchallyn.com',Email='cb.inter@welchallyn.com',CommunityNickname='cbinter', TimeZoneSidKey='GMT', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', UserRoleId = rlNameIdMap.get('Sales_and_Marketing_Director_Christopher_Hill') , ProfileId = pfNameIdMap.get('ServiceDesk Client'));
      
      userlist.add(cbInternational);
      
      //user9 - directSuperVisor
      User directSuperVisor = new User(FirstName='direct',LastName='super',JDE_External_ID__c='supervsr',Alias='supervsr',UserName='dr.super@welchallyn.com',Email='dr.super@welchallyn.com',CommunityNickname='drsuper', TimeZoneSidKey='GMT', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', UserRoleId = rlNameIdMap.get('Country_Service_Director_David_Gittings') , ProfileId = pfNameIdMap.get('ServiceDesk Client'));
      
      userlist.add(directSuperVisor);
      
      //user10 - carDirectSuperVisor
      User carDirectSuperVisor = new User(FirstName='car',LastName='super',JDE_External_ID__c='sprcar',Alias='sprcar',UserName='car.super@welchallyn.com',Email='car.super@welchallyn.com',CommunityNickname='carsupr', TimeZoneSidKey='GMT', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', UserRoleId = rlNameIdMap.get('Territory_Sales_Manager_Edward_Birmingham') , ProfileId = pfNameIdMap.get('ServiceDesk Client'));
      
      userlist.add(carDirectSuperVisor);
            
            
             try{
              system.debug(userlist);
            insert userlist;
          }catch(Exception e){
            system.debug('Exception occurred... '+e);
          }
            
        }
}