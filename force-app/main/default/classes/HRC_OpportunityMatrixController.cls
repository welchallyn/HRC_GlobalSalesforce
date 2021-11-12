public with sharing class HRC_OpportunityMatrixController {
    private List<OpportunityMatrix> matrixData;
    private String comRoleWhere; 
    private String aeRoleWhere;
    private String spRoleWhere;
    private String avpRoleWhere;
    private String rvpRoleWhere; 
    
    public Boolean showData {set; get;}
    public Boolean showPanel {set; get;}  
    
    public HRC_OpportunityMatrixController() {
        //this.showRecordTypes = true; 
        this.showData = false;
        this.showPanel = false;
        territory = 'Primary';
        aeUser = '';
        userRole = '';
        aeRoleWhere = HRC_Util.getAeRoleWhere('Account.');
        avpRoleWhere = HRC_Util.getAVPRoleWhere('Account.');
        rvpRoleWhere = HRC_Util.getRVPRoleWhere('Account.');        
        spRoleWhere = HRC_Util.getSpRoleWhere('Account.');
        comRoleWhere = HRC_Util.getComRoleWhere('Account.');
    }
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
    
    // Flag to show record types
    public Boolean showRecordTypes {
        get {
            if(showRecordTypes == null) {
                showRecordTypes = HRC_Util.getIsProfileValidForOppTypes();
            } 
            return showRecordTypes;
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
    
    public string recordTypeId {set;get;}
    // Used for Types Dropdown
    public List<SelectOption> types {
        get {
            
            if(types == null) {
                types = new List<SelectOption>();
                
                if(showRecordTypes) { // We need this info for specific profiles
                    types = HRC_Util.getOppRecordTypes();
                }
            }
            return types;
            
        }
        private set;
    }
    
    // Used for Employee Dropdown
    public List<SelectOption> aeUsers {
        get {
            
            if(aeUsers == null) {
                aeUsers = new List<SelectOption>();
                 
                if(userLevel > 1) { // We need this info if User is AVP/DVP
                    if(userRole != null && userRole != '') {
                        Set<Id> accountIds = getRelatedAccounts('');
                        aeUsers = HRC_Util.getAeUsers(userRole, '', accountIds, this.userLevel, false, false);
                    }
                }
            }
            return aeUsers;
            
        }
        private set;
    }
    
    // Used for Role Dropdown 
    public List<SelectOption> roles {
        get {
            roles = new List<SelectOption>();
            roles.add(new SelectOption('', 'All'));
            if(userLevel == 2) 
                roles.addAll(HRC_Util.getRoles());
            else if(userLevel == 3) 
                roles.addAll(HRC_Util.getRVPRoles());
            else if(userLevel == 4) 
                roles.addAll(HRC_Util.getVPRoles());
            return roles;
        }
        
        private set;
    }
    
    // Used for Territory Dropdown
    public List<SelectOption> territories {
        get {
            if(territories == null) {
                territories = HRC_Util.getTerritories();
                if(isAEUser){
                    territories.add(new SelectOption('', 'All'));
                }
            }
            return territories;
        }
        
        private set;
    }
    
    public String probabilityRange {set; get;}
    public List<SelectOption> probabilityRanges  {
        get {
            if(probabilityRanges == null) {
                probabilityRanges = new List<SelectOption>();
                probabilityRanges.add(new SelectOption('', 'All'));
                for(String s : Label.ProbabilityStartRanges.split(',')) {
                    probabilityRanges.add(new SelectOption(s, '>' + s + '%'));
                }
            }
            return probabilityRanges;
        }
        set;
    }
    
    public String closeDateRange {set; get;}
    public List<SelectOption> closeDateRanges  {
        get {
            if(closeDateRanges == null) {
                closeDateRanges = new List<SelectOption>();
                closeDateRanges.add(new SelectOption('', 'All'));
                closeDateRanges.add(new SelectOption('FY', 'Current Fiscal Year'));
                closeDateRanges.add(new SelectOption('FQ', 'Current Fiscal Quarter'));
                closeDateRanges.add(new SelectOption('NQ', 'Next Fiscal Quarter'));
                closeDateRanges.add(new SelectOption('PD', 'Past Due'));
            }
            return closeDateRanges;
        }
        set;
    }
    
    private String getWhereClause() {
        String whereClause = '';
        if(probabilityRange != null && probabilityRange != '') {
            whereClause += ' Probability >= ' + probabilityRange + ' and Probability <= 99 '; 
        }
        
        if(closeDateRange != null && closeDateRange != '') {
            if(whereClause != '') whereClause += ' and ';
            if(closeDateRange == 'FY') {
                whereClause += ' CloseDate = THIS_FISCAL_YEAR ';
            } else if(closeDateRange == 'FQ') {
                whereClause += ' CloseDate = THIS_FISCAL_QUARTER ';
            } else if(closeDateRange == 'NQ') {
                whereClause += ' CloseDate = NEXT_FISCAL_QUARTER ';
            }  else if(closeDateRange == 'PD') {
                whereClause += ' CloseDate < TODAY ';
            } 
        }
        
        if(recordTypeId != null && recordTypeId != '') {
            if(whereClause != '') whereClause += ' and ';
            whereClause += ' RecordTypeId = \'' + recordTypeId + '\' ';
        }
        
        Integer userLevelForTheRole = userLevel;
        
        if(aeUser != null && aeUser != '') {
            if(userRole == 'AVP')
                userLevelForTheRole = 2;
            else if(userRole == 'RVP')
                userLevelForTheRole = 3;
            else if(userRole != '')
                userLevelForTheRole = 1; 
        }
        String whereFromUtil = '';
        if(userLevelForTheRole < 4) {
            if(aeUser != null && aeUser != '') {
                whereFromUtil = HRC_Util.getWhereClause(null, aeUser, territory, aeUser, userRole, aeRoleWhere, comRoleWhere, spRoleWhere, avpRoleWhere, rvpRoleWhere, 'Account.', userLevelForTheRole); 
            } else {
                whereFromUtil = HRC_Util.getWhereClause(UserInfo.getFirstName(), UserInfo.getLastName(), territory, aeUser, userRole, aeRoleWhere, comRoleWhere, spRoleWhere, avpRoleWhere, rvpRoleWhere, 'Account.', userLevelForTheRole);
            }
            
        }
        System.debug('whereFromUtil: ' + whereFromUtil); 
        
        return ((whereClause != '') ? ' and ' + whereClause : whereClause) + whereFromUtil;
    }
    
    public Double defendGrandTotal {set; get;}
    public Double captureGrandTotal {set; get;}
    public Double idnDefendTotal {set; get;}
    public Double idnCaptureTotal {set; get;}
    public Double highDefendTotal {set; get;}
    public Double highCaptureTotal {set; get;}
    public Double lowDefendTotal {set; get;}
    public Double lowCaptureTotal {set; get;}
    
    public PageReference renderMatrix() { 
        this.accountIds = null;
        this.whereClause = null;
        return null;
    }
    
    public PageReference picklistChanged() { 
        this.aeUsers = null;
        return null;
    }
    
    public PageReference actionOnPageLoad() {
        System.debug('Total Accounts Found on Load: ' + this.accountIds.size());
        System.debug('this.whereClause: ' + this.whereClause);
        this.showPanel = true;
        return null;
    }
    
    public PageReference loadData() {
        this.showData = true;
        return null;
    }
    private  List<AggregateResult> getRelatedAccountsWithSum(String whClause) {
         
        List<AggregateResult> accoutsWithOpps = (List<AggregateResult>) database.query('select AccountId, Sum(Amount) from Opportunity ' + 
 '                      where AccountId != null ' + 
 '                          and Account.Cat_Code_16__c != null ' + 
 '                          and Account.Cat_Code_12__c != null  ' + 
 '                          and Account.IsPersonAccount = false ' + 
 '                          and Account.BillingCountry in (\'United States\',\'Canada\') ' + 
 '                          and Account.Account_Matrix_Position__c > -1' + 
 '                          and IsWon = false ' +  
 '                          and Amount > 0 ' + 
 '                          and IsClosed = false ' + whClause +
 '                      group by AccountId order by Sum(Amount) desc limit 1000');
        
        return accoutsWithOpps;
    }
    
    private  Set<Id> getRelatedAccounts(String whClause) {
        System.debug('whClause: ' + whClause); 
        this.sortedAccounts = getRelatedAccountsWithSum(whClause);
        Set<Id> accountIds = new Set<Id>();
        for(AggregateResult ar : this.sortedAccounts) {
            accountIds.add((ID) ar.get('AccountId'));
        }
        
        return accountIds;
    } 
    
    private Set<Id> accountIds {
        get {
            if(accountIds == null) {
                accountIds = getRelatedAccounts(this.whereClause);
            }
            return accountIds;
        }
        private set;
    }
    
    private List<AggregateResult> sortedAccounts;
    
    private String whereClause {
        get {
            if(whereClause == null) {
                whereClause = getWhereClause();
            }
            return whereClause;
        }
        private set;
    }
    
    public List<OpportunityMatrix> getOpportunities() {
        List<OpportunityMatrix> matrixData = new List<OpportunityMatrix>();
        
        System.debug('Total Accounts Found: ' + this.accountIds.size());
        Map<Id, Account> accountMap = new Map<Id, Account>();
        Map<Id, List<Opportunity>> accountIdToOppsMap = new Map<Id, List<Opportunity>>();
        
        List<Opportunity> os = (List<Opportunity>)  database.query('select AccountId, ' +
 '                                  Account.Id, ' +
 '                                  Account.Name, ' +
 '                                  Account.Account_Matrix_Position__c, ' + 
 '                                  Id, ' +
 '                                  Name, ' +
 '                                  Amount, ' + 
 '                                  CloseDate, ' + 
 '                                  Probability, ' +  
 '                                  StageName ' + 
 '                                  from Opportunity ' + 
 '                      where IsWon = false ' +  
 '                          and Amount > 0 ' + 
 '                          and AccountId in :accountIds ' + 
 '                          and IsClosed = false ' + this.whereClause +
 '                      order by Account.Account_Matrix_Position__c asc,  Account.Name asc, Amount desc ' + 
 '                      limit 40000');
        
        for(Opportunity o : os) {
                                
             List<Opportunity> opps = accountIdToOppsMap.get(o.AccountId);
             
             if(opps == null) {
                opps = new List<Opportunity>();
                accountIdToOppsMap.put(o.AccountId, opps);
                accountMap.put(o.AccountId, o.Account);
             }
             opps.add(o);
        }
        
        for(AggregateResult ar : this.sortedAccounts) {
            Id accountId = (ID) ar.get('AccountId'); //(ID) String.valueOf(ar.get('AccountId')).subString(0, 15);
            Account account = accountMap.get(accountId);
            List<Opportunity> opps = accountIdToOppsMap.get(accountId);
            
            if(account != null && opps != null) {
                matrixData.add(new OpportunityMatrix(account, opps));
            }
        }
        
        /*for(Id accountId : accountMap.keySet()) {
            matrixData.add(new OpportunityMatrix(accountMap.get(accountId), accountIdToOppsMap.get(accountId)));
        }*/
        
        defendGrandTotal = 0;
        captureGrandTotal = 0;
        idnDefendTotal = 0;
        idnCaptureTotal = 0;
        highDefendTotal = 0;
        highCaptureTotal = 0;
        lowDefendTotal = 0;
        lowCaptureTotal = 0;
        for(OpportunityMatrix md : matrixData) {
            if(md.account.Account_Matrix_Position__c == 0 || md.account.Account_Matrix_Position__c == 2 || md.account.Account_Matrix_Position__c == 4) {
                defendGrandTotal += md.accountTotal;
                if(md.account.Account_Matrix_Position__c == 0){
                    idnDefendTotal += md.accountTotal;
                }
                if(md.account.Account_Matrix_Position__c == 2){
                    highDefendTotal += md.accountTotal;
                }
                if(md.account.Account_Matrix_Position__c == 4){
                    lowDefendTotal += md.accountTotal;
                }
            } else if(md.account.Account_Matrix_Position__c == 1 || md.account.Account_Matrix_Position__c == 3 || md.account.Account_Matrix_Position__c == 5) {
                captureGrandTotal += md.accountTotal;
                if(md.account.Account_Matrix_Position__c == 1){
                    idnCaptureTotal += md.accountTotal;
                }
                if(md.account.Account_Matrix_Position__c == 3){
                    highCaptureTotal += md.accountTotal;
                }
                if(md.account.Account_Matrix_Position__c == 5){ 
                    lowCaptureTotal += md.accountTotal;
                }
            }  
        }
        
        /*integer n = matrixData.size();
        OpportunityMatrix temp = null;
       
        for(integer i=0; i < n; i++){
            for(integer j=1; j < (n-i); j++){                       
                if(matrixData[j-1].accountTotal < matrixData[j].accountTotal){
                    //swap the elements!
                    temp = matrixData[j-1];
                    matrixData[j-1] = matrixData[j];
                    matrixData[j] = temp;
                }
                   
            }
        }*/
        return matrixData;
    }
    
    public class OpportunityMatrix {
        public Account account {set; get;}
        public Double accountTotal {set; get;}
        public List<Opportunity> opportunities {set; get;}
        
        public OpportunityMatrix(Account a, List<Opportunity> os) {
            this.account = a;
            this.opportunities = os;
            this.calculateTotal(); 
            
        }
        
        private void calculateTotal() {
            this.accountTotal = 0;
            for(Opportunity o : this.opportunities) {
                this.accountTotal += o.Amount;
            }
        }
        
        private void sortOpportunities() {
            integer n = this.opportunities.size();
            Opportunity temp = null;
           
            for(integer i=0; i < n; i++){
                for(integer j=1; j < (n-i); j++){                       
                    if(this.opportunities[j-1].Amount < this.opportunities[j].Amount){
                        //swap the elements!
                        temp = this.opportunities[j-1];
                        this.opportunities[j-1] = this.opportunities[j];
                        this.opportunities[j] = temp;
                    }
                       
                }
            }
        }
    }
}