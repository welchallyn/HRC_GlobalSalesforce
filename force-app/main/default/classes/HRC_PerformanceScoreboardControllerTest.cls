//Doug Lecher 2014.02.05 changed description names from DVP to RVP
@isTest
private class HRC_PerformanceScoreboardControllerTest {
    static testMethod void testController() {
        User vpRole = [select UserRoleId, Id, FirstName, LastName from User where  IsActive = true and (UserRole.Name like 'Area Vice%' or UserRole.Name like 'AVP%' or UserRole.Name like 'Area VP%') limit 1];
        System.assert(vpRole.Id != null);
        
        User rvpUser = [Select Id, UserRoleId, LastName, FirstName 
//original              From User where (UserRole.Name like 'Divisional%' or UserRole.Name like 'DVP%') limit 1];
                        From User where UserRole.Name like 'Regional V%' limit 1];
        
        Map<Id, User> rvpUsersMap = HRC_Util.getUsersByParentRoleId(vpRole.UserRoleId);
        System.assert(rvpUsersMap.size() > 0);
         
        Map<Id, User> avpUsersMap = HRC_Util.getUsersByParentRoleId(rvpUser.UserRoleId);
        System.assert(avpUsersMap.size() > 0);
        
        List<Account> accounts = new List<Account>();
        RecordType rt = [select Id from RecordType where Name = 'Facility' and SObjectType = 'Account'];
        
        Account baseAccount = new Account(RecordTypeId = rt.Id, Name = 'Account ', BillingCity = 'Batesville', BillingPostalCode = '47006', BillingCountry = 'United States', CurrencyIsoCode = 'USD');
        List<Account> level3CloneAccounts = new List<Account>();
        for(User u : rvpUsersMap.values()) {
            Account a = baseAccount.clone(false, true, false, false);
            a.Name += 'RVP ';
            a.Capital_Level_3__c = String.valueOf(u.Id).substring(String.valueOf(u.Id).length() - 10, String.valueOf(u.Id).length() - 1);
            a.Capital_Level_3_Emp__c = u.LastName + ', ' + u.FirstName;
            level3CloneAccounts.add(a);
        }
         
        List<Account> level2CloneAccounts = new List<Account>();
        for(User u : avpUsersMap.values()) {    
            for(Account accL3 : level3CloneAccounts) {
                Account a = accL3.clone(false, true, false, false);
                a.Name += 'AVP ';
                a.Capital_Level_2__c = String.valueOf(u.Id).substring(String.valueOf(u.Id).length() - 10, String.valueOf(u.Id).length() - 1);
                a.Capital_Level_2_Emp__c = u.LastName + ', ' + u.FirstName;
                level2CloneAccounts.add(a);
            }
        } 
        
        List<Sales_Goal_Data__c> sgds = new List<Sales_Goal_Data__c>();
        
        Sales_Goal_Data__c sBase = new Sales_Goal_Data__c();
        sBase.GOAL_LVL_1__c = 'POC';
        sBase.GOAL_LVL_2__c = 'ICU';
        sBase.Q1_GOAL__c = 1000;
        sBase.Q1_OPP_MED__c = 100;
        sBase.Q1_OPP_LOW__c = 200;
        sBase.Q1_OPPORTUNITY__c = 300;
        sBase.EXP_DT__c = Date.today();
        sBase.EFF_DT__c = Date.today();
        
        Sales_Goal_Data__c sBase2 = new Sales_Goal_Data__c();
        sBase2.GOAL_LVL_1__c = 'POC-CC';
        sBase2.GOAL_LVL_2__c = 'VOALTE';
        sBase2.Q1_GOAL__c = 10000;
        sBase2.Q1_OPP_MED__c = 1200;
        sBase2.Q1_OPP_LOW__c = 2000;
        sBase2.Q1_OPPORTUNITY__c = 3600;
        sBase2.EXP_DT__c = Date.today();
        sBase2.EFF_DT__c = Date.today();
        
        Sales_Goal_Data__c sBase3 = new Sales_Goal_Data__c();
        sBase3.GOAL_LVL_1__c = 'Service Contracts';
        sBase3.Q1_GOAL__c = 100000;
        sBase3.Q1_OPP_MED__c = 12700;
        sBase3.Q1_OPP_LOW__c = 20080;
        sBase3.Q1_OPPORTUNITY__c = 36400;
        sBase3.EXP_DT__c = Date.today();
        sBase3.EFF_DT__c = Date.today();
        Integer pkId = 1;
        Integer accCount = 0;
        
        Sales_Goal_Data__c sBase4 = new Sales_Goal_Data__c();
        sBase4.GOAL_LVL_1__c = 'Service';
        sBase4.GOAL_LVL_2__c = 'Service';
        sBase4.Q1_GOAL__c = 10000;
        sBase4.Q1_OPP_MED__c = 1200;
        sBase4.Q1_OPP_LOW__c = 2000;
        sBase4.Q1_OPPORTUNITY__c = 3600;
        sBase4.EXP_DT__c = Date.today();
        sBase4.EFF_DT__c = Date.today();
        
        Sales_Goal_Data__c sBase5 = new Sales_Goal_Data__c();
        sBase5.GOAL_LVL_1__c = 'Rental';
        sBase5.GOAL_LVL_2__c = 'Rental';
        sBase5.Q1_GOAL__c = 10000;
        sBase5.Q1_OPP_MED__c = 1200;
        sBase5.Q1_OPP_LOW__c = 2000;
        sBase5.Q1_OPPORTUNITY__c = 3600;
        sBase5.EXP_DT__c = Date.today();
        sBase5.EFF_DT__c = Date.today();
        
        for(Account accL2 : level2CloneAccounts) {
            Account a = accL2.clone(false, true, false, false);
            Sales_Goal_Data__c s1 = sBase.clone(false, true, false, false);
            Sales_Goal_Data__c s2 = sBase2.clone(false, true, false, false);
            Sales_Goal_Data__c s3 = sBase3.clone(false, true, false, false);
            Sales_Goal_Data__c s4 = sBase4.clone(false, true, false, false);
            Sales_Goal_Data__c s5 = sBase5.clone(false, true, false, false);
            
            a.Name += 'AE ';
            a.Capital_Level_1__c = String.valueOf(UserInfo.getUserId()).substring(String.valueOf(UserInfo.getUserId()).length() - 10, String.valueOf(UserInfo.getUserId()).length() - 1);
            a.Capital_Level_1_Emp__c = UserInfo.getLastName() + ', ' + UserInfo.getFirstName();
            
            s1.PK_SALES_GOALS__c = pkId;
            pkId++;
            s1.TERR_CD__c = a.Capital_Level_1__c;
            
            s2.TERR_CD__c = a.Capital_Level_2__c;
            s2.PK_SALES_GOALS__c = pkId;
            pkId++;
            
            s3.TERR_CD__c = a.Capital_Level_3__c;
            s3.PK_SALES_GOALS__c = pkId;
            pkId++;
            
            s4.TERR_CD__c = a.Capital_Level_3__c;
            s4.PK_SALES_GOALS__c = pkId;
            pkId++;
            
            s5.TERR_CD__c = a.Capital_Level_3__c;
            s5.PK_SALES_GOALS__c = pkId;
            pkId++;
            
            sgds.add(s1);
            sgds.add(s2);
            sgds.add(s3);
            sgds.add(s4);
            sgds.add(s5);
            
            accounts.add(a);
            accCount ++;
            
            if(accCount > 49) {
                break;
            }
            
        }
        insert accounts;
        insert sgds;
        
        HRC_PerformanceScoreboardController hrc = new HRC_PerformanceScoreboardController();
        System.debug(hrc.userLevel);
        hrc.timeFrame = 'Q1';
          hrc.retrieveTerritoryCodes();
        hrc.roleChanged();
       
        hrc.territoryChanged();
        hrc.timeframeChanged();
        hrc.employeeChanged();
        
        System.debug(hrc.salesGoalData.size());
        
        System.runAs(vpRole) {
            HRC_PerformanceScoreboardController hrc_vp = new HRC_PerformanceScoreboardController();
            System.debug(hrc_vp);
            hrc_vp.timeFrame = 'Q1';
            
            
            //System.debug(hrc_vp.salesGoalData.size());
            
            hrc_vp.employee = rvpUsersMap.values().get(0).Id;
            hrc_vp.salesGoalData = null;
            System.debug(hrc_vp.salesGoalData.size());
        }
        /*
        System.runAs(rvpUser) {
            HRC_PerformanceScoreboardController hrc_rvp = new HRC_PerformanceScoreboardController();
            System.debug(hrc_rvp.userLevel);
            hrc_rvp.timeFrame = 'Q1';
            
            hrc_rvp.getSalesGoalData();
            
            hrc_rvp.employee = avpUsersMap.values().get(0).Id;
            hrc_rvp.getSalesGoalData();
        }
        
        Id sysAdminUser = UserInfo.getUserId();
        System.runAs(avpUsersMap.values().get(0)) {
            HRC_PerformanceScoreboardController hrc_avp = new HRC_PerformanceScoreboardController();
            System.debug(hrc_avp.userLevel);
            hrc_avp.timeFrame = 'Q1';
            
            hrc_avp.getSalesGoalData();
            
            hrc_avp.employee = sysAdminUser;
            hrc_avp.getSalesGoalData();
        }*/
    }
}