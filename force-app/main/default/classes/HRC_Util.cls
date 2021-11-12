public without sharing class HRC_Util { 
 
    
    public static Map<Id, User> getUsersByParentRoleId(Id roleId) {
        return new Map<Id, User>([select UserRoleId, Id, LastName, FirstName
            from User where
        UserRole.ParentRoleId = :roleId and IsActive = true order by LastName, FirstName limit 1000]);
    } 
    public static Boolean getIsProfileValidForOppTypes() {
        Profile pr = [select Name from Profile where Id = :UserInfo.getProfileId() limit 1];
        String validProfileNames = Label.OpportunityNaming;
        return (validProfileNames.indexOf(pr.Name) >= 0 || Test.isRunningTest());
    }
    
    public static Boolean getIsAVPDVPUser() {
        List<PermissionSetAssignment> psas = [Select Id From PermissionSetAssignment  
                                where PermissionSet.Label = 'DVP access to Forecast and Commit Fields' and AssigneeId = :UserInfo.getUserId()];
                
                return psas.size() > 0; 
    }
    
    public static Boolean getIsAVPUser() {
        /***Below Code Modified by Varun Gupta on 1st Mar 2020 as part of CR00027558***/
        //List<User> users = [Select Id From User where Id = :UserInfo.getUserId() and (UserRole.Name like 'Area%' or UserRole.Name like 'AVP%')];
        
        List<User> users = [Select Id From User where Id = :UserInfo.getUserId() and (UserRole.Name like 'Area Vice%' or UserRole.Name like 'AVP%' or UserRole.Name like 'Area VP%')];
        /*****Code  Modification Ends****/
        return users.size() > 0;
    }
    
    public static Boolean getIsRVPUser() {
        /***Below Code Modified by Varun Gupta on 1st Mar 2020 as part of CR00027558***/
        //List<User> users = [Select Id From User where Id = :UserInfo.getUserId() and (UserRole.Name like 'Region Vice%' or UserRole.Name like 'RVP%')];
        
        List<User> users = [Select Id From User where Id = :UserInfo.getUserId() and (UserRole.Name like 'Regional Vice%')];
       /*****Code  Modification Ends****/
        return users.size() > 0;
    }
    
    public static Boolean getIsVPUser() {
        /***Below Code Modified by Varun Gupta on 1st Mar 2020 as part of CR00027558***/
        //List<User> users = [Select Id From User where Id = :UserInfo.getUserId() and UserRole.Name like 'VP%'];
        
        List<User> users = [Select Id From User where Id = :UserInfo.getUserId() and (UserRole.Name like 'Vice%' or UserRole.Name like 'VP%')];
        /*****Code  Modification Ends****/
        return users.size() > 0;
    }
    
    public static Set<String> getAeUsersSet(String userRole, String colPrefix, Set<Id> accountIds, Integer userLevel) {
        return getAeUsersSet(userRole, colPrefix, accountIds, userLevel, false, false);
    }
    
    public static Set<String> getAeUsersSet(String userRole, String colPrefix, Set<Id> accountIds, Integer userLevel, Boolean isForAccountMatrix, Boolean isForScoreboard) {
        List<SelectOption> aeUsers = new List<SelectOption>();
        List<Schema.FieldSetMember> fieldSet = new List<Schema.FieldSetMember>();
        System.debug('isForAccountMatrix: ' + isForAccountMatrix);
        Integer interestedLevel = userLevel;
         
        if(userRole == 'RVP') {
            if(isForScoreboard) {
                fieldSet = SObjectType.Account.FieldSets.AE_ROLE_FIELDS.getFields();
            } else {
                fieldSet = SObjectType.Account.FieldSets.LEVEL_3_EMP_FIELDS.getFields();
            }
            if((!isForAccountMatrix) || isForScoreboard) interestedLevel = 3;
        } else if(userRole == 'AVP') {
            if(isForScoreboard) {
                fieldSet = SObjectType.Account.FieldSets.AE_ROLE_FIELDS.getFields();
            } else {
                fieldSet = SObjectType.Account.FieldSets.LEVEL_2_EMP_FIELDS.getFields();
            }
            if((!isForAccountMatrix) || isForScoreboard) interestedLevel = 2;
        } else if(userRole == 'Account Executive') {
            fieldSet = SObjectType.Account.FieldSets.AE_ROLE_FIELDS.getFields();
            if((!isForAccountMatrix) || isForScoreboard) interestedLevel = 1;
        } else if(userRole == 'COM') {
            fieldSet = SObjectType.Account.FieldSets.COM_ROLE_FIELDS.getFields();
            if((!isForAccountMatrix) || isForScoreboard) interestedLevel = 1;
        } else if(userRole == 'Specialist') {
            fieldSet = SObjectType.Account.FieldSets.SPECIALIST_ROLE_FIELDS.getFields();         
            if((!isForAccountMatrix) || isForScoreboard) interestedLevel = 1;         
        }   
         
        System.debug('interestedLevel: ' + interestedLevel);
        List<User> Employee= [Select name, jde_external_id__c from user where lastname=:String.escapeSingleQuotes(UserInfo.getLastName())];
        String Emp_Number=Employee[0].jde_external_id__c;
         String Employee_Number = '=' +'\''+ Emp_Number +'\'';
        Set<String> emps = new Set<String>();

        for(Schema.FieldSetMember f : fieldSet) {
            
            String roleWhere = '';
            String empWhere = '';
            String empColumns = '';
            
            roleWhere = f.getFieldPath() + '  != null  ';
            empColumns = f.getFieldPath();
            
            if(isForScoreboard) {
                empColumns = empColumns.replace('1', String.valueOf(interestedLevel));
                roleWhere = empColumns + '  != null  ';
            }
            
            if(userLevel > 1 && userLevel < 4) {
                Integer valueOne, valueTwo;
                
                if(isForAccountMatrix)  {
                    valueTwo = interestedLevel;
                    valueOne = 1;
                } else {
                    valueTwo = interestedLevel + 1;
                    valueOne = interestedLevel;
                }
                 empWhere = roleWhere.replaceAll(String.valueOf(valueOne), String.valueOf((valueTwo))).replaceAll('_Emp__c','_Emp_num__c').replaceAll('!= null',Employee_Number );
            }
            
            String whereStatement;
                if(isForScoreboard )  {
                    whereStatement = ' IsPersonAccount = false and BillingCountry in (\'United States\',\'Canada\') ' ;
                } else {
                    whereStatement = ' Cat_Code_16__c != null and Cat_Code_12__c != null  and ' +
                                             ' IsPersonAccount = false and BillingCountry in (\'United States\',\'Canada\') ' ;
                }
            
            String employeeAccountQuery = 'select ' + empColumns + ' from Account where' + whereStatement ;
                                             
            List<SObject> employeeAccounts = Database.query(employeeAccountQuery +  
                                                            (empWhere != '' ? ' and (' + empWhere + ') ': empWhere) 
                                                                 + ' and (' + roleWhere + ') ' +
                                                 (accountIds != null && accountIds.size() > 0 ? ' and Id in :accountIds ' : '') + ' group by ' + empColumns + ' limit 1000 ');
                                                 
            for(SObject a : employeeAccounts ) {
                String emp = (String) a.get(empColumns);
                if(emp != null) {
                    emps.add(emp);
                }
            }
        }
        
       return emps;
    }
    public static List<SelectOption> getOppRecordTypes() {
        List<RecordType> rts = [select Id, Name from RecordType where SObjectType = 'Opportunity' and IsActive = true 
                                 and Name in ('Capital',
                                                'HITS',
                                                'LIKO',
                                                'Service Contracts') 
                                order by Name];
        
        List<SelectOption> types = new List<SelectOption>();
        types.add(new SelectOption('', 'All'));
        for(RecordType rt : rts) {
            types.add(new SelectOption(String.valueOf(rt.Id), rt.Name));
        }
        
        return types;
        
    }
    public static List<SelectOption> getAeUsers(String userRole, String colPrefix, Set<Id> accountIds, Integer userLevel) {
        return getAeUsers(userRole, colPrefix, accountIds, userLevel, false, false);
    }
    
    public static List<SelectOption> getAeUsers(String userRole, String colPrefix, Set<Id> accountIds, Integer userLevel, Boolean isForAccountMatrix, Boolean isForScoreboard) {
        List<SelectOption> aeUsers = new List<SelectOption>();
        
        Set<String> emps = getAeUsersSet(userRole, colPrefix, accountIds, userLevel, isForAccountMatrix, isForScoreboard);
        
        aeUsers.add(new SelectOption('', 'All'));
        
        List<SelectOption> tempAeUsers = new List<SelectOption>();
        for(String emp : emps) {
            tempAeUsers.add(new SelectOption(emp, emp));
            if(tempAeUsers.size() == 1000) {
                break;
            }
        }
        
        integer n = tempAeUsers.size();
        SelectOption temp = null;      
        for(integer i=0; i < n; i++){
            for(integer j=1; j < (n-i); j++){                       
                if(tempAeUsers[j-1].getLabel() > tempAeUsers[j].getLabel()){
                    //swap the elements!
                    temp = tempAeUsers[j-1];
                    tempAeUsers[j-1] = tempAeUsers[j];
                    tempAeUsers[j] = temp;
                }
                   
            }
        }
        
        aeUsers.addAll(tempAeUsers);
        
        return aeUsers;
    }
    
    public static List<SelectOption> getRoles() {
        List<SelectOption> roles = new List<SelectOption>();
        
        roles.add(new SelectOption('Account Executive', 'Account Executive'));
        roles.add(new SelectOption('COM', 'COM'));
        roles.add(new SelectOption('Specialist', 'Specialist'));
        
        return roles;
    }
    
    public static List<SelectOption> getRVPRoles() {
        List<SelectOption> roles = new List<SelectOption>();
        
        roles.add(new SelectOption('AVP', 'AVP'));
        
        return roles;
    }
    
    public static List<SelectOption> getVPRoles() {
        List<SelectOption> roles = new List<SelectOption>();
        
        roles.add(new SelectOption('RVP', 'RVP'));
        roles.add(new SelectOption('AVP', 'AVP'));
        
        return roles;
    }
    
    
    public static List<SelectOption> getTerritories() {
        List<SelectOption> territories = new List<SelectOption>();
        territories.add(new SelectOption('Primary', 'Primary'));
        territories.add(new SelectOption('Open', 'Open'));
        
        return territories;
    }
    
    public static String getAVPRoleWhere(String colPrefix) {
        String avpRoleWhere = '';
        for(Schema.FieldSetMember f : SObjectType.Account.FieldSets.LEVEL_2_EMP_FIELDS.getFields()) {
            if(avpRoleWhere != '') avpRoleWhere += ' or ';
            avpRoleWhere += colPrefix + f.getFieldPath() + ' != null ';
        }
        
        return avpRoleWhere;
    }
    
    public static String getRVPRoleWhere(String colPrefix) {
        String rvpRoleWhere = '';
        for(Schema.FieldSetMember f : SObjectType.Account.FieldSets.LEVEL_3_EMP_FIELDS.getFields()) {
            if(rvpRoleWhere != '') rvpRoleWhere += ' or ';
            rvpRoleWhere += colPrefix + f.getFieldPath() + ' != null ';
        }
        
        return rvpRoleWhere;
    }
    
    public static String getAeRoleWhere(String colPrefix) {
        String aeRoleWhere = '';
        for(Schema.FieldSetMember f : SObjectType.Account.FieldSets.AE_ROLE_FIELDS.getFields()) {
            if(aeRoleWhere != '') aeRoleWhere += ' or ';
            aeRoleWhere += colPrefix + f.getFieldPath() + ' != null ';
        }
        
        return aeRoleWhere;
    }
    
    public static String getSpRoleWhere(String colPrefix) {
        String spRoleWhere = '';
        for(Schema.FieldSetMember f : SObjectType.Account.FieldSets.SPECIALIST_ROLE_FIELDS.getFields()) {
            if(spRoleWhere != '') spRoleWhere += ' or ';
            spRoleWhere += colPrefix + f.getFieldPath() + ' != null ';
        }
        return spRoleWhere;
    }   
    
    public static String getComRoleWhere(String colPrefix) {
        String comRoleWhere = '';
        for(Schema.FieldSetMember f : SObjectType.Account.FieldSets.COM_ROLE_FIELDS.getFields()) {
            if(comRoleWhere != '') comRoleWhere += ' or ';
            comRoleWhere += colPrefix + f.getFieldPath() + ' != null ';
        }
        return comRoleWhere;
    }
    
        public static String getTerritoyWhere(String colPrefix, String territory, Integer level, String firstName, String lastName, List<Schema.FieldSetMember> fs) {
         
        String empWhere = '';
        
        
        List<Schema.FieldSetMember> empFields = fs;
        
        if(empFields == null) {
            if(level == 1) {
                empFields = SObjectType.Account.FieldSets.LEVEL_1_EMP_FIELDS.getFields();
            } else if(level == 2) {
                empFields = SObjectType.Account.FieldSets.LEVEL_2_EMP_FIELDS.getFields();
            } else if(level == 3 || level == 4) {
                empFields = SObjectType.Account.FieldSets.LEVEL_3_EMP_FIELDS.getFields();
            } 
        }
        Boolean flag_employee_type= false;
        String empSearchPrefix = '';
        if(territory == 'Open') 
        
        {
        empSearchPrefix = 'OPEN%';
        flag_employee_type = true;
        
        }
        if(territory == null || territory == '') empSearchPrefix = '%';
        
        try{
        String Employee_Number=' ';
         
        List<User> Employee= [Select name, jde_external_id__c from user where lastname=:String.escapeSingleQuotes(lastName) and firstname=:String.escapeSingleQuotes(firstName)];
        String Emp_Number=Employee[0].jde_external_id__c;
          Employee_Number = '=' +'\''+ Emp_Number +'\'';
        
         for(Schema.FieldSetMember f : empFields) {
           
          
           if(empWhere != '') empWhere += ' or ';
            if(territory == null || territory == '')
            {
            empWhere += colPrefix + f.getFieldPath().replaceAll('_Emp__c','_Emp_num__c') + Employee_Number ;
        }
     else
        {
        empWhere += '(' + colPrefix + f.getFieldPath().replaceAll('_Emp__c','_Open__c') + '=' + flag_employee_type  + ' and ' + colPrefix + f.getFieldPath().replaceAll('_Emp__c','_Emp_num__c') + Employee_Number + ')' ;
        }
        
        }
          return empWhere;
         }
         
         catch(Exception e)
         {
         
        lastName = lastName.replace('OPEN ', '').replace('Open ', '').replace('open ', '');
        
        for(Schema.FieldSetMember f : empFields) {
            if(empWhere != '') empWhere += ' or ';
            empWhere += colPrefix + f.getFieldPath() + ' like \'' + empSearchPrefix + String.escapeSingleQuotes(lastName) + 
                            (firstName == null || firstName == '' ? '' : '%' + String.escapeSingleQuotes(firstName)) + '%\' ';
        }
         return empWhere;
        
         
         }
        
}

     public static Set<String> getTerritoryCodesByLevel(Integer level, String firstName, String lastName, String territory, String userRole, Boolean isForScoreboard) {
        List<Schema.FieldSetMember> terrFields = new List<Schema.FieldSetMember>();
        if(level == 1 && (userRole == null || userRole == '')) {
            terrFields.addAll(SObjectType.Account.FieldSets.LEVEL_1_EMP_FIELDS.getFields());
        } else if((level > 1 && (userRole == null || userRole == '')) || userRole == 'Account Executive' || userRole == 'AVP' || userRole == 'RVP') {
            terrFields.addAll(SObjectType.Account.FieldSets.AE_ROLE_FIELDS.getFields());
        } else if(userRole == 'COM') {
            terrFields.addAll(SObjectType.Account.FieldSets.COM_ROLE_FIELDS.getFields());
        } else if(userRole == 'Specialist') {
            terrFields.addAll(SObjectType.Account.FieldSets.SPECIALIST_ROLE_FIELDS.getFields());
        }
        
        String empSearchPrefix = '%';
        
        Boolean flag_employee_type= false;
        
        if(territory == 'Open') 
        
        {
        empSearchPrefix = 'OPEN%';
        flag_employee_type = true;
        
        }
        if(territory == null || territory == '') empSearchPrefix = '%'; 
        
        lastName = lastName.replace('OPEN ', '').replace('Open ', '').replace('open ', '');
        String whereClause;
                if(isForScoreboard )  {
                    whereClause = ' IsPersonAccount = false and BillingCountry in (\'United States\',\'Canada\') and ' ;
                } else {
                    whereClause = ' Cat_Code_16__c != null and Cat_Code_12__c != null  and ' +
                                             ' IsPersonAccount = false and BillingCountry in (\'United States\',\'Canada\') and ' ;
                }
        
        Set<String> emps = new Set<String>();
        if(level == 4) {
            emps = getAeUsersSet('RVP', '', new Set<Id>(), level, false, true); 
            }
        try{
        
        String Emp_Number=' ';
        
        List<User> Employee= [Select name, jde_external_id__c from user where lastname=:String.escapeSingleQuotes(lastName) and firstname=:String.escapeSingleQuotes(firstName)];
            Emp_Number=Employee[0].jde_external_id__c;
          
        
        
            
        
        
        Set<String> territories = new Set<String>();
        for(Schema.FieldSetMember f : terrFields) {
            String fName = f.getFieldPath();
            String sName=fName.replace('_Emp__c','_Emp_num__c');
            
            String Employee_type=fName.replace('_Emp__c','_Open__c');
            String colName = fName.replace('_Emp__c', '__c');
            String query = '';
            
            System.debug(logginglevel.ERROR, 'fName: ' + fName);
            System.debug(logginglevel.ERROR, 'colName: ' + colName);
            System.debug(logginglevel.ERROR, 'level: ' + level);
            
            
            if(level == 1) {
            
            if(territory == null || territory == '')
            {query = 'select ' + colName + ' from Account where ' + whereClause + sName + '=' +'\''+ Emp_Number +'\'' + ' and '  + colName + ' != null group by ' + colName + ' limit 1000';
          } else{
          query = 'select ' + colName + ' from Account where ' + whereClause + sName + '=' +'\''+ Emp_Number +'\'' + ' and '  + Employee_type + '=' + flag_employee_type + ' and ' + colName + ' != null group by ' + colName + ' limit 1000';
          }
               
            } else if(level == 2 || level == 3) {
            if(territory == null || territory == '')
            {
                query = 'select ' + colName + ' from Account where ' + whereClause + sName.replace('1', String.valueOf(level)) + '=' +'\''+ Emp_Number +'\'' + ' and ' + colName + ' != null group by ' + colName + ' limit 1000';
                }
                else{
                query = 'select ' + colName + ' from Account where ' + whereClause + sName.replace('1', String.valueOf(level)) + '=' +'\''+ Emp_Number +'\'' + ' and ' +  Employee_type.replace('1', String.valueOf(level)) + '=' + flag_employee_type + ' and ' + colName + ' != null group by ' + colName + ' limit 1000';
                }
            } else if(level == 4 && emps.size() > 0 ){
                String whereCol = fName.replace('1', '3');
                
                String vpWhereClause = '';
                
                for(String emp : emps) {
                    if(vpWhereClause != '') vpWhereClause += ' or ';
                    emp = emp.replace('OPEN ', '').replace('Open ', '').replace('open ', '');
                    
                    vpWhereClause += whereCol + ' = \'' + (territory == 'Open' ? 'OPEN ' : '') + String.escapeSingleQuotes(emp) + '\'';
                }
                query = 'select ' + colName + ' from Account where ' + whereClause +
                            colName + ' != null and (' + vpWhereClause + ') and ' + whereCol + ' != null group by ' + colName + ' limit 1000';
            }
            System.debug(logginglevel.ERROR, 'getTerritoryCodesByLevel query: ' + query);
            
            if(query != '') {
                List<AggregateResult> result = (List<AggregateResult>) database.query(query);
                System.debug('Limits.getQueryRows(): ' + Limits.getQueryRows());
                if(result != null && result.size() > 0) {
                    for(AggregateResult r : result) {
                        territories.add((String) r.get(colName));
                    }
                }
            }
        }
        
        return territories;
        }
        
         catch (Exception e)
        {
        Set<String> territories = new Set<String>();
        for(Schema.FieldSetMember f : terrFields) {
            String fName = f.getFieldPath();
            String colName = fName.replace('_Emp__c', '__c');
            String query = '';
            
            System.debug(logginglevel.ERROR, 'fName: ' + fName);
            System.debug(logginglevel.ERROR, 'colName: ' + colName);
            System.debug(logginglevel.ERROR, 'level: ' + level);
            
            
            if(level == 1) {
                query = 'select ' + colName + ' from Account where ' + whereClause + fName + ' like \'' + empSearchPrefix + String.escapeSingleQuotes(lastName) + 
                            (firstName == null || firstName == '' ? '' : '%' + String.escapeSingleQuotes(firstName)) + '%\' and ' + 
                            colName + ' != null group by ' + colName + ' limit 1000';
            } else if(level == 2 || level == 3) {
                query = 'select ' + colName + ' from Account where ' + whereClause + fName.replace('1', String.valueOf(level)) + ' like \'' + empSearchPrefix + String.escapeSingleQuotes(lastName) + 
                            (firstName == null || firstName == '' ? '' : '%' + String.escapeSingleQuotes(firstName)) + '%\' and ' + 
                            colName + ' != null group by ' + colName + ' limit 1000';
            } else if(level == 4 && emps.size() > 0 ){
                String whereCol = fName.replace('1', '3');
                
                String vpWhereClause = '';
                
                for(String emp : emps) {
                    if(vpWhereClause != '') vpWhereClause += ' or ';
                    emp = emp.replace('OPEN ', '').replace('Open ', '').replace('open ', '');
                    
                    vpWhereClause += whereCol + ' = \'' + (territory == 'Open' ? 'OPEN ' : '') + String.escapeSingleQuotes(emp) + '\'';
                }
                query = 'select ' + colName + ' from Account where ' + whereClause +
                            colName + ' != null and (' + vpWhereClause + ') and ' + whereCol + ' != null group by ' + colName + ' limit 1000';
            }
            System.debug(logginglevel.ERROR, 'getTerritoryCodesByLevel query: ' + query);
            
            if(query != '') {
                List<AggregateResult> result = (List<AggregateResult>) database.query(query);
                System.debug('Limits.getQueryRows(): ' + Limits.getQueryRows());
                if(result != null && result.size() > 0) {
                    for(AggregateResult r : result) {
                        territories.add((String) r.get(colName));
                    }
                }
            }
        }
        
        return territories;
    }
        
        
        }
        
    
        
    public static String getWhereClause(String firstName, String lastName, String territory, String aeUser, String userRole, String aeRoleWhere, String comRoleWhere, String spRoleWhere, String avpRoleWhere, String rvpRoleWhere, String colPrefix, Integer userLevel) {
        String whereClause = '';
        
        if(userLevel > 1) {
            
            if(userRole != null && userRole != '') {
                if(whereClause != '') whereClause += ' and '; 
                String roleWhere = '';
                if(userRole == 'RVP') {
                    roleWhere = rvpRoleWhere;
                } else if(userRole == 'AVP') {
                    roleWhere = avpRoleWhere;
                } else if(userRole == 'Account Executive') {
                    roleWhere = aeRoleWhere;
                } else if(userRole == 'COM') {
                    roleWhere = comRoleWhere;
                } else if(userRole == 'Specialist') {
                    roleWhere = spRoleWhere;
                } 
                
                if(roleWhere != '')  whereClause += ' (' + roleWhere + ')';
                
                
                if(aeUser != null && aeUser != '') {
                    
                    String empSearchPrefix = '';
                    String empSearchPrefix2 = 'OPEN ';
                    if(territory == 'Open')  {
                        empSearchPrefix = 'OPEN ';
                        empSearchPrefix2 = ''; 
                        
                        aeUser = aeUser.replace('OPEN ', '');
                    }
                    
                    aeUser = aeUser.replace('\'', '\\\'');
                    aeUser = String.escapeSingleQuotes(aeUser);
                    
                    
                    if(whereClause != '') whereClause += ' and ';
                    
                    String employeeWhere = roleWhere.replaceAll('!= null', ' = \'' + empSearchPrefix + aeUser  + '\' ');
                    String employeeWhere2 = roleWhere.replaceAll('!= null', ' != \'' + empSearchPrefix2 + aeUser  + '\' ').replaceAll(' or ', ' and ');
                    
                    if(employeeWhere != '')  whereClause += '(' + employeeWhere + ') and (' + employeeWhere2 + ')';
                }
            }
            
            
        } else {
            String territoryWhere = getTerritoyWhere(colPrefix, territory, userLevel, firstName, lastName, null);
            if(territoryWhere != '')  whereClause += '(' + territoryWhere  + ')';
        }
        
        return whereClause == '' ? '' : ' and ' + whereClause;
    }     

}