public with sharing class HRC_AccountMatrixController {
    
    // Flag to indicate either user is AVP/DVP or not
    public Boolean isAVP_DVP_User {
        get {
            if(isAVP_DVP_User == null) {
                isAVP_DVP_User = HRC_Util.getIsAVPDVPUser();
            } 
            return isAVP_DVP_User; 
        } 
        set;
    }
    public Integer userLevel { 
        get {
            if(userLevel == null) {
                if(isAEUser) {
                    userLevel = 1;
                }
                if(isAVPUser || isAVP_DVP_User) {
                    userLevel = 2;
                }
                if(isRVPUser) {
                    userLevel = 3;
                }
                if(isVPUser) {
                    userLevel = 4;
                } 
            } 
            return userLevel;
        }
        set;
    }
    // Flag to indicate either user is AVP or not
    public Boolean isAVPUser {
        get {
            if(isAVPUser == null) {
                isAVPUser = HRC_Util.getIsAVPUser();
            } 
            return isAVPUser;
        }
        set;
    }
    
    // Flag to indicate either user is RVP or not
    public Boolean isRVPUser {
        get {
            if(isRVPUser == null) {
                isRVPUser = HRC_Util.getIsRVPUser();
            } 
            return isRVPUser;
        }
        set;
    }
    
    // Flag to indicate either user is VP or not
    public Boolean isVPUser {
        get {
            if(isVPUser == null) {
                isVPUser = HRC_Util.getIsVPUser();
            } 
            return isVPUser;
        }
        set;
    }
    
    // Flag to indicate either user is AE/COM/Spec User or not
    public Boolean isAEUser {
        get {
            if(isAEUser == null) {
                isAEUser = (!isAVP_DVP_User) && (!isVPUser) && (!isRVPUser) && (!isAVPUser);
            } 
            return isAEUser;
        }
        set;
    }
    
    // Used to hold value selected by User from dropdown
    public string aeUser {set; get;}
    public string userRole {set; get;}
    public string territory {set;get;} 
    
    // Used for Employee Dropdown
    public List<SelectOption> aeUsers { 
        get {
            
            aeUsers = new List<SelectOption>();
            
            if(isAVP_DVP_User || isVPUser || isRVPUser || isAVPUser) { // We need this info if User is AVP/DVP
                if(userRole != null && userRole != '') {
                    aeUsers = HRC_Util.getAeUsers(userRole, '', new Set<Id>(), userLevel, true, false); 
                }
            }
            return aeUsers;
            
        }
        private set;
    }
    
    // Used for Role Dropdown 
    public List<SelectOption> roles {
        get {
            if(roles == null) {
                roles = new List<SelectOption>();
                roles.add(new SelectOption('', 'All'));
                roles.addAll(HRC_Util.getRoles());   
            }
            return roles;
        }
        
        private set;
    }
    
    // Used for Territory Dropdown
    public List<SelectOption> territories {
        get {
            if(territories == null) {
                territories = new List<SelectOption>();
                if(isAEUser){ 
                    territories.add(new SelectOption('', 'All'));
                }
                territories.addAll(HRC_Util.getTerritories());
            }
            return territories; 
        }
        
        private set;
    }
    
    // Need where clause when data is retrieved for AVP/DVP  
    private String getWhereClause() {
        String whereClause = HRC_Util.getWhereClause(UserInfo.getFirstName(), UserInfo.getLastName(), territory, aeUser, userRole, aeRoleWhere, comRoleWhere, spRoleWhere, avpRoleWhere, rvpRoleWhere, '', userLevel);
        System.debug('whereClause: ' + whereClause);
        return whereClause;
    } 
    public void picklistChanged() {
        
    }
    /* 
        Function to retrieve accounts based on the values in Territory, Employee, and Role drop-downs.
    */
    public List<Account> getAccounts() {
        String baseQuery = 'select Id, Name, Account_Matrix_Position__c from Account where Cat_Code_16__c != null and Cat_Code_12__c != null ' + getWhereClause();
        baseQuery += ' and IsPersonAccount = false and BillingCountry in (\'United States\',\'Canada\') ';
        baseQuery += ' order by Name asc limit 1000 ';
        
        System.debug('baseQuery: ' + baseQuery);
        return (List<Account>) database.query(baseQuery);
    }
    
    private String comRoleWhere;
    private String aeRoleWhere;
    private String spRoleWhere;
    private String avpRoleWhere;
    private String rvpRoleWhere;
    
    public HRC_AccountMatrixController() {
        this.territory = 'Primary';
        this.aeUser = '';
        this.aeRoleWhere = HRC_Util.getAeRoleWhere('');        
        this.spRoleWhere = HRC_Util.getSpRoleWhere('');
        this.comRoleWhere = HRC_Util.getComRoleWhere('');
        this.avpRoleWhere = HRC_Util.getAVPRoleWhere('');
        this.rvpRoleWhere = HRC_Util.getRVPRoleWhere('');  
    }  
}