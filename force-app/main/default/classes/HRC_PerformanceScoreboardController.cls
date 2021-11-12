/**
@ClassName    : HRC_PerformanceScoreboardController
@CReatedBy : Doug Lecher
@CreatedOn    : 11/8/2013
@LastModifiedBy   : Varun Gupta
@Description  : This class is the controller class for Performance Scoreboard.
@Visualforce Page : HRC_PerformanceScoreboard.vfp
@Test Class : HRC_PerformanceScoreboardControllerTest
*/

public without sharing class HRC_PerformanceScoreboardController {
    
    public Boolean showData {get; private set;}
    public Integer userLevel { 
        get {
            if(userLevel == null) { 
                if(isAEUser) {
                    userLevel = 1;
                }
                if(isAVPUser) {
                    userLevel = 2;
                }
                if(isRVPUser) {
                    userLevel = 3;
                }
                if(isVPUser) {
                    userLevel = 4;
                } 
            } 
            system.debug('userLevel===>>'+userLevel);
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
                isAEUser = (!isVPUser) && (!isRVPUser) && (!isAVPUser);
            } 
            system.debug('isAEUser+++>>'+isAEUser);
            return isAEUser;
        }
        set;
    }
    
    public string employee {set; get;}
    // Used for Employee Dropdown
    public List<SelectOption> employees {
        get {
            if(employees == null) { 
                employees = new List<SelectOption>();
                if(userLevel > 1) { // We need this info if User is AVP/DVP
                    if(userRole != null && userRole != '') {
                        employees = HRC_Util.getAeUsers(userRole, '', new Set<Id>(), this.userLevel, false, true);
                        system.debug('employeessssss----->>'+employees+'-userRole====>>'+userRole+'userLevel===>>'+userLevel);
                    }
                }
            }
            
            return employees;
            
        }
        set;
    }
    
    
    public string userRole {set; get;}
    // Used for Role Dropdown 
    public List<SelectOption> roles {
        get {
            
            if(roles == null) {
                roles = new List<SelectOption>();
                String defaultValue = '';
                if(userLevel == 2) defaultValue = 'My Area';
                if(userLevel == 3) defaultValue = 'My Reqion';
                if(userLevel == 4) defaultValue = 'All';
                
                if(userLevel != 2) roles.add(new SelectOption('', defaultValue));
            
                if(userLevel == 2) 
                    roles.addAll(HRC_Util.getRoles());
                else if(userLevel == 3) 
                    roles.addAll(HRC_Util.getRVPRoles());
                else if(userLevel == 4) 
                    roles.addAll(HRC_Util.getVPRoles());
                
            }
            return roles;
        }
        
        set;
    }
    
    public string territory {set;get;}
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
            system.debug('territories===>>'+territories);
            return territories;
        }
        
        private set;
    }
    
    public String timeFrame {set; get;}
    public List<SelectOption> timeFrames{
        get {
            if(timeFrames == null) {
                timeFrames = new List<SelectOption>();
                timeFrames.add(new SelectOption('Q1', 'Q1'));
                timeFrames.add(new SelectOption('Q2', 'Q2'));
                timeFrames.add(new SelectOption('Q3', 'Q3'));
                timeFrames.add(new SelectOption('Q4', 'Q4'));
                timeFrames.add(new SelectOption('YTD', 'YTD'));
            }
            
            return timeFrames;
        } 
        private set;
    }
    
    public PageReference territoryChanged() {
        return null;
    }
    
    public PageReference timeframeChanged() {
        return null; 
    }
    
    public PageReference employeeChanged() {
        return null;
    }
    
    public PageReference roleChanged() {
        initializeData();
        return null;
    }
    
    private Integer getUserLevelForRole() {
        Integer userLevelForTheRole = userLevel;
        System.debug('userLevel====>>>'+userLevel);
        System.debug('userRole====>>>'+userRole);
        if(employee != null && employee != '') {
            if(userRole == 'AVP')
                userLevelForTheRole = 2;
            else if(userRole == 'RVP')
                userLevelForTheRole = 3;
            else if(userRole != '')
                userLevelForTheRole = 1;
        }
        System.debug('userLevelForTheRole=====>>>'+userLevelForTheRole);
        return userLevelForTheRole;
    }
    public PageReference retrieveTerritoryCodes() {
        Integer userLevelForTheRole = getUserLevelForRole();
        this.territoryCodes = new Set<String>();
        this.salesGoalData = null;
        this.showData = false;
        
        System.debug('userLevelForTheRole: ' + userLevelForTheRole);
        System.debug('role: ' + userRole);
        System.debug('territory: ' + territory);
        System.debug('employee: ' + employee);
        
        
        if(employee != null && employee != '') {
            this.territoryCodes = HRC_Util.getTerritoryCodesByLevel(userLevelForTheRole, null, employee, territory, userRole,true); 
        } else {
            this.territoryCodes = HRC_Util.getTerritoryCodesByLevel(userLevelForTheRole, UserInfo.getFirstName(), UserInfo.getLastName(), territory, userRole,true);
        }
        
        this.showData = true;
        return null;
    }
    
    private void initializeData() {
        this.employees = null;
        this.employee = '';
        this.territoryCodes = new Set<String>();
        this.salesGoalData = null;
        this.showData = false;
    }
    
    public List<SalesGoalData> salesGoalData {
        get {
            if(salesGoalData == null) {
                salesGoalData = getSalesGoalData();
            }
             
            return salesGoalData;
        }
        set;
    }
    
    private Set<String> territoryCodes;
    private List<SalesGoalData> getSalesGoalData() {
        Integer userLevelForTheRole = getUserLevelForRole();
        
        Boolean processFurther = true;
        
        
        System.debug('getSalesGoalData.userLevelForTheRole: ' + userLevelForTheRole);
        System.debug('getSalesGoalData.this.territoryCodes: ' + this.territoryCodes);
        if(!Test.isRunningTest())
        processFurther = (this.territoryCodes != null && this.territoryCodes.size() > 0);
        system.debug('Boolean-->'+processFurther);
        List<SalesGoalData> salesGoalData = new List<SalesGoalData>();
        
        initializeOverAllVariables(0);
        if(processFurther) {
            System.debug('territories: ' + this.territoryCodes);
            String query = 'Select YTD_SHIPPED__c,' + 
                                'YTD_Performance__c,' + 
                                'YTD_Percent_to_Quota__c,' + 
                                'YTD_PENDING__c,' + 
                                'YTD_Over_Under_to_Quota__c,' + 
                                'YTD_OPP_MED__c,' + 
                                'YTD_OPP_LOW__c,' + 
                                'YTD_OPPORTUNITY__c,' + 
                                'YTD_OPEN__c,' + 
                                'YTD_INVOICED__c,' + 
                                'YTD_GOAL__c,' + 
                                'YTD_DISCOUNT__c,' + 
                                'YTD_ADJUSTMENT__c,' + 
                                'Q4_SHIPPED__c,' + 
                                'Q4_Performance__c,' + 
                                'Q4_Percent_to_Quota__c,' + 
                                'Q4_PENDING__c,' + 
                                'Q4_Over_Under_to_Quota__c,' + 
                                'Q4_OPP_MED__c,' + 
                                'Q4_OPP_LOW__c,' + 
                                'Q4_OPPORTUNITY__c,' + 
                                'Q4_OPEN__c,' + 
                                'Q4_INVOICED__c,' + 
                                'Q4_GOAL__c,' + 
                                'Q4_DISCOUNT__c,' + 
                                'Q4_ADJUSTMENT__c,' + 
                                'Q3_SHIPPED__c,' + 
                                'Q3_Performance__c,' + 
                                'Q3_Percent_to_Quota__c,' + 
                                'Q3_PENDING__c,' + 
                                'Q3_Over_Under_to_Quota__c,' + 
                                'Q3_OPP_MED__c,' + 
                                'Q3_OPP_LOW__c,' + 
                                'Q3_OPPORTUNITY__c,' + 
                                'Q3_OPEN__c,' + 
                                'Q3_INVOICED__c,' + 
                                'Q3_GOAL__c,' + 
                                'Q3_DISCOUNT__c,' + 
                                'Q3_ADJUSTMENT__c,' + 
                                'Q2_SHIPPED__c,' + 
                                'Q2_Performance__c,' + 
                                'Q2_Percent_to_Quota__c,' + 
                                'Q2_PENDING__c,' + 
                                'Q2_Over_Under_to_Quota__c,' + 
                                'Q2_OPP_MED__c,' + 
                                'Q2_OPP_LOW__c,' + 
                                'Q2_OPPORTUNITY__c,' + 
                                'Q2_OPEN__c,' + 
                                'Q2_INVOICED__c,' + 
                                'Q2_GOAL__c,' + 
                                'Q2_DISCOUNT__c,' + 
                                'Q2_ADJUSTMENT__c,' + 
                                'Q1_SHIPPED__c,' + 
                                'Q1_Performance__c,' + 
                                'Q1_Percent_to_Quota__c,' + 
                                'Q1_PENDING__c,' + 
                                'Q1_Over_Under_to_Quota__c,' + 
                                'Q1_OPP_MED__c,' + 
                                'Q1_OPP_LOW__c,' + 
                                'Q1_OPPORTUNITY__c,' + 
                                'Q1_OPEN__c,' + 
                                'Q1_INVOICED__c,' + 
                                'Q1_GOAL__c,' + 
                                'Q1_DISCOUNT__c,' + 
                                'Q1_ADJUSTMENT__c,' + 
                                'GOAL_LVL_2__c,' + 
                                'GOAL_LVL_1__c,' + 
                                'TERR_CD__c,' +
                                'EXP_DT__c,' +    
                                'Q1_Open_Shipped__c,' + 
                                'Q2_Open_Shipped__c,' + 
                                'Q4_Open_Shipped__c,' + 
                                'Q3_Open_Shipped__c,' +
                                'YTD_Open_Shipped__c,' +
                                'TYPE__c,' +
                            'EFF_DT__c From Sales_Goal_Data__c ' +
                            ' where GOAL_LVL_1__c != null and ' +
                            ' EXP_DT__c = THIS_FISCAL_YEAR and ' +
                            ' EFF_DT__c = THIS_FISCAL_YEAR ' + getWhereClause() + 
                            ' ORDER BY GOAL_LVL_1__c, GOAL_LVL_2__c limit ' + (50000 - Limits.getQueryRows() > 20000 ? 20000 : 50000 - Limits.getQueryRows());
                            
            system.debug('query 1 salesgoaldata :'+query);
            List<Sales_Goal_Data__c> salesData = (List<Sales_Goal_Data__c>) Database.query(query);
            //New code
            //Extra Sales_Goal_Data__c objects for enhancement.
            Sales_Goal_Data__c salesCapitalData,salesRentalData;
            if(!Test.isRunningTest()){
                salesCapitalData = new Sales_Goal_Data__c(GOAL_LVL_1__c = 'CAPITAL SUBTOTAL', GOAL_LVL_2__c = 'CAPITAL SUBTOTAL', CurrencyIsoCode = 'USD - U.S. Dollar', PK_SALES_GOALS__c = 0, TERR_CD__c = (new list<string>(territoryCodes) )[0]);
                salesRentalData = new Sales_Goal_Data__c(GOAL_LVL_1__c = 'RENTAL SUBTOTAL', GOAL_LVL_2__c = 'RENTAL SUBTOTAL', CurrencyIsoCode = 'USD - U.S. Dollar', PK_SALES_GOALS__c = 0, TERR_CD__c = (new list<string>(territoryCodes) )[0]);
                salesData.add(salesCapitalData);
                salesData.add(salesRentalData);
            }
            
            

            Map<String, List<SalesGoalDataWrapper>> productToData = new Map<String, List<SalesGoalDataWrapper>>();
            Map<String, List<SalesGoalDataWrapper>> subProductToData = new Map<String, List<SalesGoalDataWrapper>>();
            Map<String, Set<String>> productToSubProduct = new Map<String, Set<String>>(); 
             
            for(Sales_Goal_Data__c s : salesData) {
                String product = s.GOAL_LVL_1__c.toUpperCase();
                String subProduct = s.GOAL_LVL_2__c;
    
                List<SalesGoalDataWrapper> productData = productToData.get(product);
                if(productData == null) {
                    productData = new List<SalesGoalDataWrapper>();
                    productToData.put(product, productData);
                }
                
                SalesGoalDataWrapper sgdw = new SalesGoalDataWrapper(this.timeFrame, s/*, colsNames*/);
                productData.add(sgdw);
                system.debug('---->sgdw:: '+sgdw);
                
                //New code
                
                // /***Below Code Modified by Srishti Goyal on 9th September 2020 - Added filter for "CARE COMM HCA" in if condition***/
                if((s.TYPE__c != null && s.GOAL_LVL_1__c != 'NON-GOAL') && s.GOAL_LVL_2__c != 'CARE COMM SERVICES' /*&& s.GOAL_LVL_1__c!='CCOMM ORDERS - HCA' && s.GOAL_LVL_1__c!='CARE COMM SERVICES NON HCA' && s.GOAL_LVL_1__c!='CARE COMM HCA'*/) {
                    SalesGoalDataWrapper sgdw2;
                    List<SalesGoalDataWrapper> productData2;
                    String marker = '';
                    
                    if(s.TYPE__c.equalsIgnoreCase('C')) {
                        marker = 'CAPITAL SUBTOTAL';
                    } else if(s.TYPE__c.equalsIgnoreCase('R')) {
                        marker = 'RENTAL SUBTOTAL';
                    }
                    if(marker == 'CAPITAL SUBTOTAL' || marker == 'RENTAL SUBTOTAL'){
                        productData2 = productToData.get(marker);
                        if(productData2 == null) {
                            productData2 = new List<SalesGoalDataWrapper>();
                            productToData.put(marker, productData2);
                        }
                        
                        salesRentalData = s;
                        salesRentalData.GOAL_LVL_1__c = marker;
                        salesRentalData.GOAL_LVL_2__c = marker;
                        sgdw2 = new SalesGoalDataWrapper(this.timeFrame, salesRentalData/*, colsNames*/);
                        productData2.add(sgdw2);
                    }
                
                
                }

                if(subProduct != null && subProduct != '') {
                    subProduct = subProduct.toUpperCase();
                    Set<String> subProducts = productToSubProduct.get(product);
                    if(subProducts == null) {
                        subProducts = new Set<String>();
                        productToSubProduct.put(product, subProducts);
                    }
                    
                    subProducts.add(subProduct);
                    
                    List<SalesGoalDataWrapper> subProductData = subProductToData.get(subProduct) ;
                    
                    if(subProductData == null) {
                        subProductData = new List<SalesGoalDataWrapper>();
                        subProductToData.put(subProduct, subProductData);
                    }
                    subProductData.add(sgdw);
                }
            }

            List<String> orderedProducts = new List<String>{/*'MEDSURG',
                                                            'ICU',
                                                            'MATERNAL',
                                                            'MOBILE ORDERS',
                                                            'STRETCHERS',
                                                            'Therapy Capital/Other',
                                                            'THERAPY CAPITAL / OTHER',
                                                            'THERAPY CAPITAL /OTHER',
                                                            'THERAPY CAPITAL/ OTHER',
                                                            'OTHER CAPITAL',
                                                            'THERAPY CAPITAL',
                                                            'Therapy OTHER',
                                                            'FURNITURE',
                                                            'PATIENT HANDLING',
                                                            'PATIENT MONITORING',
                                                            'Patient Handling EC',
                                                            'Patient',
                                                            'WATCHCHILD',
                                                            'CCOMM ORDERS - NON HCA',
                                                            'CARE COMM NON HCA',
                                                            'CWS Orders - SMA',
                                                            'Other',
                                                            'AIR FLUIDIZED THERAPY',
                                                            'BARIATRIC',
                                                            'NON AFT WOUND/OTHER',
                                                            'PULMONARY',
                                                            'SERVICE CONTRACTS',*/
                											'POC',
                  											'POC-CC',
                											'TRUMPF',
                											'SERVICE',
                                                            'RENTAL',
                                                            'CAPITAL SUBTOTAL',
                                                            'RENTAL SUBTOTAL'
                											
															
															
            };
            //Code Modification By Varun Gupta on 24-11-2020 starts
            /*List<String> orderedMedsurgSubs = new List<String>{
                'CENTRELLA',
                'VERSACARE',
                'OTHER MEDSURG'
            };
            
            List<String> orderedICUSubs = new List<String>{
                'PROGRESSA',
                'ICU OTHER'
            };*/
            
			List<String> orderedPOCSubs = new List<String>{
                'ICU',
                'MEDSURG',
                'CFCM',
				'WATCHCARE PADS',
				'FURNITURE',
				'MATERNAL',
				'PATIENT HANDLING',
				'STRETCHERS',
				'THERAPY CAPITAL',
				'COMPELLA',
				'WATCHCARE HARDWARE'
            };
			List<String> orderedPOCCCsurgSubs = new List<String>{
                'NURSE CALL ORDERS',
                'NURSE CALL ORDERS SMA',
                'VOALTE',
				'EXCEL'
            };
			List<String> orderedServicesurgSubs = new List<String>{
                'SERVICE',
                'LOGISTICS',
                'NEW',
				'POINT OF SALE',
				'RENEWAL & SSG',
				'RETAINERS'
            };
			List<String> orderedRentalsurgSubs = new List<String>{
                'RENTAL',
                'AIR FLUIDIZED THERAPY',
                'BARIATRIC',
				'OTHER WOUND/NON AFT',
				'PULMONARY'
            };
			//Code Modification By Varun Gupta Ends
                
            for(String product : orderedProducts) {
                product = product.toUpperCase();
                System.debug('---->#408 product: ' + product);
            //}
            //for(String product : productToData.keySet()) {
                List<SalesGoalDataWrapper> productData = productToData.get(product);
                System.debug('---->#412 productData ' + productData + ' for :' + product);
                if(productData != null) {
                    System.debug('productData: ' + productData);
                    SalesGoalDataProduct p = new SalesGoalDataProduct(productData);
                    
                    Set<String> subProducts = productToSubProduct.get(product);
                    System.debug('subProducts: ' + subProducts);
                    List<SalesGoalDataSubFamily> sfs = new List<SalesGoalDataSubFamily>();
                    
                    if(subProducts != null) {
                        List<String> relatedOrderedList = new List<String>();
                        //Code Modification By Varun Gupta on 24-11-2020 Starts here
                        /*if(product == 'MEDSURG') {
                            relatedOrderedList = orderedMedsurgSubs;
                        } else if(product == 'ICU') {
                            relatedOrderedList = orderedICUSubs;
                        }*/
                        
                        if(product == 'POC'){
							relatedOrderedList = orderedPOCSubs;
						}else if(product == 'POC-CC'){
							relatedOrderedList = orderedPOCCCsurgSubs;
						}else if(product == 'SERVICE'){
							relatedOrderedList = orderedServicesurgSubs;
						}else if(product == 'RENTAL'){
							relatedOrderedList = orderedRentalsurgSubs;
						}
                        //End of Code Modification By Varun Gupta on 24-11-2020
                        
                        for(String subProduct : relatedOrderedList) {
                            List<SalesGoalDataWrapper> subProductData = subProductToData.get(subProduct);
                            
                            
                            System.debug('subProductData: ' + subProductData);
                            if(subProductData != null) {
                                sfs.add(new SalesGoalDataSubFamily(subProductData));
                            }
                        }
                    }
                    
                    salesGoalData.add(new SalesGoalData(p, sfs));
                }
            }
            
            if(salesGoalData != null && salesGoalData.size() > 0) {
                for(SalesGoalData sgd : salesGoalData) {
                    /*  Original used to not include Service Contracts in total Calculation
                    if(sgd.productData.summaryForProduct.goalLevel.indexOf('SERVICE') < 0) {*/
                    if(!(sgd.productData.summaryForProduct.goalLevel.equalsIgnoreCase('CAPITAL SUBTOTAL') || sgd.productData.summaryForProduct.goalLevel.equalsIgnoreCase('RENTAL SUBTOTAL'))) {
                        System.debug('---->#493 sgd.productData.summaryForProduct.goalLevel::'+sgd.productData.summaryForProduct.goalLevel);
                        System.debug('---->#493 sgd.productData.summaryForProduct.quota::'+sgd.productData.summaryForProduct.quota);
                        this.overall_quota += sgd.productData.summaryForProduct.quota;
                        this.overall_performance += sgd.productData.summaryForProduct.performance;
                        //this.overall_percentToQuota += sgd.productData.summaryForProduct.percentToQuota;
                        this.overall_dollarToQuota += sgd.productData.summaryForProduct.dollarToQuota;
                        this.overall_lowOpp += sgd.productData.summaryForProduct.lowOpp;
                        this.overall_medOpp += sgd.productData.summaryForProduct.medOpp;
                        this.overall_highOpp += sgd.productData.summaryForProduct.highOpp;
                        this.overall_openShipped += sgd.productData.summaryForProduct.openShipped;
                        this.overall_invoiced += sgd.productData.summaryForProduct.invoiced;
                        this.overall_pending += sgd.productData.summaryForProduct.pending;
                    }
                    //see above comment}
                }
                
                this.overall_percentToQuota = this.overall_quota > 0 ? ((this.overall_openShipped + this.overall_invoiced)  / this.overall_quota) * 100 : 0;
            }
        } 
        
        System.debug('----> salesGoalData::'+salesGoalData);
        return salesGoalData;
        
    }
    
    private void initializeOverAllVariables(Double defaultValue) {
        this.overall_quota = defaultValue;
        this.overall_performance = defaultValue;
        this.overall_percentToQuota = defaultValue;
        this.overall_dollarToQuota = defaultValue;
        this.overall_lowOpp = defaultValue;
        this.overall_medOpp = defaultValue;
        this.overall_highOpp = defaultValue;
        this.overall_openShipped = defaultValue;
        this.overall_invoiced = defaultValue;
        this.overall_pending = defaultValue;
    }
    public Double overall_quota {set; get;}
    public Double overall_percentToQuota {set; get;}
    public Double overall_dollarToQuota {set; get;}
    public Double overall_performance {set; get;}
    public Double overall_lowOpp {set; get;}
    public Double overall_medOpp {set; get;}
    public Double overall_highOpp {set; get;}
    public Double overall_openShipped {set; get;}
    public Double overall_invoiced {set; get;}
    public Double overall_pending {set; get;}
    
    public String getWhereClause() {
        String whereClause = '';
        if(this.territoryCodes != null && this.territoryCodes.size() > 0) {
            String goalLevel2 = 'and GOAL_LVL_2__c!=\'CARE COMM SERVICES\'';
            whereClause += goalLevel2 + 'and TERR_CD__c in :territoryCodes';
        }
        return whereClause;
    }
    
    public class SalesGoalData {
        public SalesGoalDataProduct productData {set; get;}
        public List<SalesGoalDataSubFamily> subFamilyData {set; get;}
        
        public SalesGoalData(SalesGoalDataProduct p, List<SalesGoalDataSubFamily> sfs) {
            this.productData = p;
            this.subFamilyData = sfs;
        }
    }
    
    public class SalesGoalDataProduct {
        public SalesGoalDataWrapper summaryForProduct {set; get;}
        
        public SalesGoalDataProduct(List<SalesGoalDataWrapper> productData) {
            this.summaryForProduct = new SalesGoalDataWrapper();
            if(productData != null && productData.size() > 0) {
                for(SalesGoalDataWrapper pd : productData) {
                    this.summaryForProduct.goalLevel = pd.goalLevel;
                    this.summaryForProduct.quota += pd.quota;
                    this.summaryForProduct.performance += pd.performance;
                    //this.summaryForProduct.percentToQuota += pd.percentToQuota;
                    this.summaryForProduct.dollarToQuota += pd.dollarToQuota;
                    this.summaryForProduct.lowOpp += pd.lowOpp;
                    this.summaryForProduct.medOpp += pd.medOpp;
                    this.summaryForProduct.highOpp += pd.highOpp;
                    this.summaryForProduct.openShipped += pd.openShipped;
                    this.summaryForProduct.invoiced += pd.invoiced;
                    this.summaryForProduct.pending += pd.pending;
                }
                
                this.summaryForProduct.percentToQuota = this.summaryForProduct.quota > 0 ? ((this.summaryForProduct.openShipped + this.summaryForProduct.invoiced)  / this.summaryForProduct.quota) * 100 : 0;
            }
        }
    }
    
    public class SalesGoalDataSubFamily {
        public SalesGoalDataWrapper summaryForSubFamily {set; get;}
        
        public SalesGoalDataSubFamily(List<SalesGoalDataWrapper> subProductData) {
            this.summaryForSubFamily = new SalesGoalDataWrapper();
            if(subProductData != null && subProductData.size() > 0) {
                System.debug(subProductData.size());
                for(SalesGoalDataWrapper spd : subProductData) {
                    this.summaryForSubFamily.subGoalLevel = spd.subGoalLevel;
                    this.summaryForSubFamily.quota += spd.quota;
                    this.summaryForSubFamily.performance += spd.performance;
                    //this.summaryForSubFamily.percentToQuota += spd.percentToQuota;
                    this.summaryForSubFamily.dollarToQuota += spd.dollarToQuota;
                    this.summaryForSubFamily.lowOpp += spd.lowOpp;
                    this.summaryForSubFamily.medOpp += spd.medOpp;
                    this.summaryForSubFamily.highOpp += spd.highOpp;
                    this.summaryForSubFamily.openShipped += spd.openShipped;
                    this.summaryForSubFamily.invoiced += spd.invoiced;
                    this.summaryForSubFamily.pending += spd.pending;
                } 
                this.summaryForSubFamily.percentToQuota = this.summaryForSubFamily.quota > 0 ? ((this.summaryForSubFamily.openShipped + this.summaryForSubFamily.invoiced)  / this.summaryForSubFamily.quota) * 100 : 0;
            }
        }
    }
    
    public class SalesGoalDataWrapper {
        public String goalLevel {set; get;}
        public String subGoalLevel {set; get;}
        public Double quota {set; get;}
        public Double percentToQuota {set; get;}
        public Double dollarToQuota {set; get;}
        public Double performance {set; get;}
        public Double lowOpp {set; get;}
        public Double medOpp {set; get;}
        public Double highOpp {set; get;}
        public Double openShipped {set; get;}
        public Double invoiced {set; get;}
        public Double pending {set; get;}
        
        public SalesGoalDataWrapper() {
            this.goalLevel = '';
            this.subGoalLevel = '';
            this.quota = 0;
            this.performance = 0;
            this.percentToQuota = 0;
            this.dollarToQuota = 0;
            this.lowOpp = 0;
            this.medOpp = 0;
            this.highOpp = 0;
            this.openShipped = 0;
            this.invoiced = 0;
            this.pending = 0;
        }
        
        public SalesGoalDataWrapper(String timeFrame, Sales_Goal_Data__c s/*, List<String> colsNames*/) {
            
            SObject sObj = (SObject) s;
            this.goalLevel = (String) sObj.get('GOAL_LVL_1__c');
            this.subGoalLevel = (String) sObj.get('GOAL_LVL_2__c');
            
            this.quota = (Double) sObj.get(timeFrame + '_GOAL__c');
            if(this.quota == null) this.quota = 0;
            
            this.performance = (Double) sObj.get(timeFrame + '_Performance__c');
            if(this.performance == null) this.performance = 0;
            
            this.percentToQuota = (Double) sObj.get(timeFrame + '_Percent_to_Quota__c');
            if(this.percentToQuota == null) this.percentToQuota = 0;
            
            this.dollarToQuota = (Double) sObj.get(timeFrame + '_Over_Under_to_Quota__c');
            if(this.dollarToQuota == null) this.dollarToQuota = 0;
            
            this.lowOpp = (Double) sObj.get(timeFrame + '_OPP_LOW__c');
            if(this.lowOpp == null) this.lowOpp = 0;
            
            this.medOpp = (Double) sObj.get(timeFrame + '_OPP_MED__c');
            if(this.medOpp == null) this.medOpp = 0;
    
            this.highOpp = (Double) sObj.get(timeFrame + '_OPPORTUNITY__c');
            if(this.highOpp == null) this.highOpp = 0;
            
            this.openShipped = (Double) sObj.get(timeFrame + '_Open_Shipped__c');
            if(this.openShipped == null) this.openShipped = 0;
    
            this.invoiced = (Double) sObj.get(timeFrame + '_INVOICED__c');
            if(this.invoiced == null) this.invoiced = 0;
            
            this.pending = (Double) sObj.get(timeFrame + '_PENDING__c');
            if(this.pending == null) this.pending = 0;
        }
    }
    
    public HRC_PerformanceScoreboardController() {
        this.timeFrame = 'Q1';
        this.territory = 'Primary';
        this.userRole = userLevel == 2 ? 'Account Executive' : '';
        this.showData = false;
    }
}