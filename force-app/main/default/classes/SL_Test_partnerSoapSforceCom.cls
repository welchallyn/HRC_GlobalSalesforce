/**
	@ClassName    : SL_Test_partnerSoapSforceCom
	@Ticket No.   : WADVDSC-7
	@CreatedOn    : 08/06/2015
	@CreatedBy    : Nrusingh
	@ModifiedOn   : 08/06/2015
	@ModifiedBy   : Nrusingh
	@Description  : This is the Test Class for partnerSoapSforceCom
*/
@isTest
global class SL_Test_partnerSoapSforceCom {

    global class WebServiceMockImpl implements WebServiceMock 
    {
    	// Create mock response
        global void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType) 
        {
        	if(request instanceof partnerSoapSforceCom.login_element)
            {
             	partnerSoapSforceCom.loginResponse_element obj = new partnerSoapSforceCom.loginResponse_element();
				partnerSoapSforceCom.LoginResult AsyncResult = new partnerSoapSforceCom.LoginResult();
				AsyncResult.serverUrl='test';
				AsyncResult.sessionId=String.valueOf(UserInfo.getSessionId());
				
				obj.result =  AsyncResult;
				response.put('response_x', obj);	
            }
            
            else if(request instanceof partnerSoapSforceCom.update_element)
            {
                partnerSoapSforceCom.updateResponse_element obj = new partnerSoapSforceCom.updateResponse_element();
				
				partnerSoapSforceCom.SaveResult AsyncResult = new partnerSoapSforceCom.SaveResult();
				AsyncResult.id='1';
				obj.result =  new List<partnerSoapSforceCom.SaveResult>{AsyncResult};
				response.put('response_x', obj);
            }
            
            else if(request instanceof partnerSoapSforceCom.describeSoqlListViews_element)
            {
                partnerSoapSforceCom.describeSoqlListViewsResponse_element obj = new partnerSoapSforceCom.describeSoqlListViewsResponse_element();
                partnerSoapSforceCom.DescribeSoqlListViewResult obj2 = new partnerSoapSforceCom.DescribeSoqlListViewResult ();
                
                obj2.describeSoqlListViews = null;
                
                obj.result = obj2;
                 
				response.put('response_x', obj);
            }
            
            else if(request instanceof partnerSoapSforceCom.describeCompactLayouts_element)
            {
                partnerSoapSforceCom.describeCompactLayoutsResponse_element obj = new partnerSoapSforceCom.describeCompactLayoutsResponse_element();
				response.put('response_x', obj);
            }
            
            else if(request instanceof partnerSoapSforceCom.describeGlobal_element)
            {
                partnerSoapSforceCom.describeGlobalResponse_element obj = new partnerSoapSforceCom.describeGlobalResponse_element();
				response.put('response_x', obj);
            }
            
            else if(request instanceof partnerSoapSforceCom.retrieve_element)
            {
                partnerSoapSforceCom.describeSoqlListViewsResponse_element obj = new partnerSoapSforceCom.describeSoqlListViewsResponse_element();
				response.put('response_x', null);
            }
            
            else if(request instanceof partnerSoapSforceCom.describeAllTabs_element)
            {
                partnerSoapSforceCom.describeAllTabsResponse_element obj = new partnerSoapSforceCom.describeAllTabsResponse_element();
				response.put('response_x', obj);
            }
			else if(request instanceof partnerSoapSforceCom.describeLayout_element)
            {
                partnerSoapSforceCom.describeLayoutResponse_element obj = new partnerSoapSforceCom.describeLayoutResponse_element();
				response.put('response_x', obj);
            }
            else if(request instanceof partnerSoapSforceCom.emptyRecycleBin_element)
            {
                partnerSoapSforceCom.emptyRecycleBinResponse_element obj = new partnerSoapSforceCom.emptyRecycleBinResponse_element();
				response.put('response_x', obj);
            }
            
            else if(request instanceof partnerSoapSforceCom.describeAppMenu_element)
            {
                partnerSoapSforceCom.describeAppMenuResponse_element obj = new partnerSoapSforceCom.describeAppMenuResponse_element();
				response.put('response_x', obj);
            }
            
            else if(request instanceof partnerSoapSforceCom.describeKnowledgeSettings_element)
            {
                partnerSoapSforceCom.describeKnowledgeSettingsResponse_element obj = new partnerSoapSforceCom.describeKnowledgeSettingsResponse_element();
				response.put('response_x', obj);
            }
            
            else if(request instanceof partnerSoapSforceCom.getUserInfo_element)
            {
                partnerSoapSforceCom.getUserInfoResponse_element obj = new partnerSoapSforceCom.getUserInfoResponse_element();
				response.put('response_x', obj);
            }
            else if(request instanceof partnerSoapSforceCom.getServerTimestamp_element)
            {
                partnerSoapSforceCom.getServerTimestampResponse_element obj = new partnerSoapSforceCom.getServerTimestampResponse_element();
				response.put('response_x', obj);
            }
            
            else if(request instanceof partnerSoapSforceCom.emptyRecycleBin_element)
            {
                partnerSoapSforceCom.emptyRecycleBinResponse_element obj = new partnerSoapSforceCom.emptyRecycleBinResponse_element();
				response.put('response_x', obj);
            }
            
          /*  else if(request instanceof partnerSoapSforceCom.describeFlexiPages_element)
            {
                partnerSoapSforceCom.describeFlexiPagesResponse_element obj = new partnerSoapSforceCom.describeFlexiPagesResponse_element();
				response.put('response_x', obj);
            }*/
            
            else if(request instanceof partnerSoapSforceCom.setPassword_element)
            {
                partnerSoapSforceCom.setPasswordResponse_element obj = new partnerSoapSforceCom.setPasswordResponse_element();
				response.put('response_x', obj);
            }
            
            else if(request instanceof partnerSoapSforceCom.sendEmailMessage_element)
            {
                partnerSoapSforceCom.sendEmailMessageResponse_element obj = new partnerSoapSforceCom.sendEmailMessageResponse_element();
				response.put('response_x', obj);
            }
            
            else if(request instanceof partnerSoapSforceCom.delete_element)
            {
                partnerSoapSforceCom.deleteResponse_element obj = new partnerSoapSforceCom.deleteResponse_element();
				response.put('response_x', obj);
            }
            else if(request instanceof partnerSoapSforceCom.describeSearchLayouts_element)
            {
                partnerSoapSforceCom.describeSearchLayoutsResponse_element obj = new partnerSoapSforceCom.describeSearchLayoutsResponse_element();
				response.put('response_x', obj);
            }
             else if(request instanceof partnerSoapSforceCom.describeCompactLayouts_element)
            {
                partnerSoapSforceCom.describeCompactLayoutsResponse_element obj = new partnerSoapSforceCom.describeCompactLayoutsResponse_element();
				response.put('response_x', obj);
            }
            else if(request instanceof partnerSoapSforceCom.retrieve_element)
            {
                //partnerSoapSforceCom.retrieveResponse_element obj = new partnerSoapSforceCom.retrieveResponse_element();
				//response.put('response_x', obj);
            }
            else if(request instanceof partnerSoapSforceCom.invalidateSessions_element)
            {
                partnerSoapSforceCom.invalidateSessionsResponse_element obj = new partnerSoapSforceCom.invalidateSessionsResponse_element();
				response.put('response_x', obj);
            }
            else if(request instanceof partnerSoapSforceCom.describePrimaryCompactLayouts_element)
            {
                partnerSoapSforceCom.describePrimaryCompactLayoutsResponse_element obj = new partnerSoapSforceCom.describePrimaryCompactLayoutsResponse_element();
				response.put('response_x', obj);
            }
            
            else if(request instanceof partnerSoapSforceCom.describeTabs_element)
            {
                partnerSoapSforceCom.describeTabsResponse_element obj = new partnerSoapSforceCom.describeTabsResponse_element();
				response.put('response_x', obj);
            }
            
            else if(request instanceof partnerSoapSforceCom.describeSoftphoneLayout_element)
            {
                partnerSoapSforceCom.describeSoftphoneLayoutResponse_element obj = new partnerSoapSforceCom.describeSoftphoneLayoutResponse_element();
				response.put('response_x', obj);
            }
            
            else if(request instanceof partnerSoapSforceCom.describeSObject_element)
            {
                partnerSoapSforceCom.describeSObjectResponse_element obj = new partnerSoapSforceCom.describeSObjectResponse_element();
				response.put('response_x', obj);
            }
            
            else if(request instanceof partnerSoapSforceCom.describeSObjects_element)
            {
                partnerSoapSforceCom.describeSObjectsResponse_element obj = new partnerSoapSforceCom.describeSObjectsResponse_element();
				response.put('response_x', obj);
            }
            
            else if(request instanceof partnerSoapSforceCom.getUpdated_element)
            {
                partnerSoapSforceCom.getUpdatedResponse_element obj = new partnerSoapSforceCom.getUpdatedResponse_element();
				response.put('response_x', obj);
            }
            
            else if(request instanceof partnerSoapSforceCom.queryAll_element)
            {
                partnerSoapSforceCom.queryAllResponse_element obj = new partnerSoapSforceCom.queryAllResponse_element();
				response.put('response_x', obj);
            }
            
            else if(request instanceof partnerSoapSforceCom.describeApprovalLayout_element)
            {
                partnerSoapSforceCom.describeApprovalLayoutResponse_element obj = new partnerSoapSforceCom.describeApprovalLayoutResponse_element();
				response.put('response_x', obj);
            }
            
            else if(request instanceof partnerSoapSforceCom.resetPassword_element)
            {
                partnerSoapSforceCom.resetPasswordResponse_element obj = new partnerSoapSforceCom.resetPasswordResponse_element();
				response.put('response_x', obj);
            }
            else if(request instanceof partnerSoapSforceCom.query_element)
            {
                partnerSoapSforceCom.queryResponse_element obj = new partnerSoapSforceCom.queryResponse_element();
				response.put('response_x', obj);
            }
            
            else if(request instanceof partnerSoapSforceCom.undelete_element)
            {
                partnerSoapSforceCom.undeleteResponse_element obj = new partnerSoapSforceCom.undeleteResponse_element();
				response.put('response_x', obj);
            }
            
            else if(request instanceof partnerSoapSforceCom.convertLead_element)
            {
                partnerSoapSforceCom.convertLeadResponse_element obj = new partnerSoapSforceCom.convertLeadResponse_element();
				response.put('response_x', obj);
            }
            
            else if(request instanceof partnerSoapSforceCom.describeGlobalTheme_element)
            {
                partnerSoapSforceCom.describeGlobalThemeResponse_element obj = new partnerSoapSforceCom.describeGlobalThemeResponse_element();
				response.put('response_x', obj);
            }
            else if(request instanceof partnerSoapSforceCom.describeAvailableQuickActions_element)
            {
                partnerSoapSforceCom.describeAvailableQuickActionsResponse_element obj = new partnerSoapSforceCom.describeAvailableQuickActionsResponse_element();
				response.put('response_x', obj);
            }
            
             else if(request instanceof partnerSoapSforceCom.getDeleted_element)
            {
                partnerSoapSforceCom.getDeletedResponse_element obj = new partnerSoapSforceCom.getDeletedResponse_element();
				response.put('response_x', obj);
            }
            else if(request instanceof partnerSoapSforceCom.describeQuickActions_element)
            {
                partnerSoapSforceCom.describeQuickActionsResponse_element obj = new partnerSoapSforceCom.describeQuickActionsResponse_element();
				response.put('response_x', obj);
            }
            else if(request instanceof partnerSoapSforceCom.retrieveQuickActionTemplates_element)
            {
                partnerSoapSforceCom.retrieveQuickActionTemplatesResponse_element obj = new partnerSoapSforceCom.retrieveQuickActionTemplatesResponse_element();
				response.put('response_x', obj);
            }
            else if(request instanceof partnerSoapSforceCom.describeSearchScopeOrder_element)
            {
                partnerSoapSforceCom.describeSearchScopeOrderResponse_element obj = new partnerSoapSforceCom.describeSearchScopeOrderResponse_element();
				response.put('response_x', obj);
            }
            else if(request instanceof partnerSoapSforceCom.describeDataCategoryGroups_element)
            {
                partnerSoapSforceCom.describeDataCategoryGroupsResponse_element obj = new partnerSoapSforceCom.describeDataCategoryGroupsResponse_element();
				response.put('response_x', obj);
            }
            else if(request instanceof partnerSoapSforceCom.queryMore_element)
            {
                partnerSoapSforceCom.queryMoreResponse_element obj = new partnerSoapSforceCom.queryMoreResponse_element();
				response.put('response_x', obj);
            }
            else if(request instanceof partnerSoapSforceCom.search_element)
            {
                partnerSoapSforceCom.searchResponse_element obj = new partnerSoapSforceCom.searchResponse_element();
				response.put('response_x', obj);
            }
            else if(request instanceof partnerSoapSforceCom.describeTheme_element)
            {
                partnerSoapSforceCom.describeThemeResponse_element obj = new partnerSoapSforceCom.describeThemeResponse_element();
				response.put('response_x', obj);
            }
            else if(request instanceof partnerSoapSforceCom.describeSObjectListViews_element)
            {
                partnerSoapSforceCom.describeSObjectListViewsResponse_element obj = new partnerSoapSforceCom.describeSObjectListViewsResponse_element();
				response.put('response_x', obj);
            }
    	}
    }
    
     /*
       Method Name : createStaticResource
       Description : Calling the create method of Preso_MetadataService and set mock callout response
    */
    @isTest
    private static void createStaticResource()
    {
    	// Web Service mock implementation
    	test.starttest();
    	System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
    	
    	partnerSoapSforceCom metaDataService = new partnerSoapSforceCom();
        // Invoke operations         
        partnerSoapSforceCom.Soap metaDataPort = new partnerSoapSforceCom.Soap();
		test.stoptest();    	
    }
    
    @IsTest
    private static void coverGeneratedCodeFileBasedOperations()
    {
    	System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
    	partnerSoapSforceCom metaDataService = new partnerSoapSforceCom();
    	partnerSoapSforceCom.Soap metaDataPort = new partnerSoapSforceCom.Soap();
    	metaDataPort.login('test','test'); 
    	metaDataPort.describeSoqlListViews(null);
    	metaDataPort.describeCompactLayouts('test',null);
    	metaDataPort.describeGlobal();
    	//metaDataPort.retrieve_x('test','test', null);
    	metaDataPort.describeAllTabs();
    	metaDataPort.describeLayout('test','test', null);
    	metaDataPort.emptyRecycleBin(null);
    	//metaDataPort.describeAppMenu('test');
    	//metaDataPort.process(null);
    	metaDataPort.logout();
    	List <String> lstSession = new List <String>(); 
    	lstSession.add(UserInfo.getSessionId());
    	metaDataPort.invalidateSessions(lstSession);
    	metaDataPort.describeKnowledgeSettings();
    	
    	List <String> lstSobjectTypes = new List <String> ();
    	lstSobjectTypes.adD('Account');
    	metaDataPort.describePrimaryCompactLayouts(lstSobjectTypes);
    	metaDataPort.getUserInfo();
    	metaDataPort.getServerTimestamp();
    	metaDataPort.describeSearchLayouts(null);
    	//metaDataPort.describeFlexiPages(null);
    	metaDataPort.setPassword('test','test');
    	metaDataPort.sendEmailMessage(null);
    	metaDataPort.delete_x(null);
    	metaDataPort.describeTabs();
    	//metaDataPort.executeListView(null);
    	metaDataPort.describeSoftphoneLayout();
    	metaDataPort.describeSObject('Account');
    	metaDataPort.describeSObjects(lstSobjectTypes);
    	metaDataPort.getUpdated('Account',DateTime.now(),DateTime.now());
    	metaDataPort.queryAll('test');
    	metaDataPort.describeApprovalLayout('Account',lstSobjectTypes);
    	metaDataPort.resetPassword('test');
    	//metaDataPort.merge_x(null);
    	metaDataPort.query('test');
    	metaDataPort.update_x(null);
    	metaDataPort.undelete_x(null);
    	metaDataPort.convertLead(null);
    	metaDataPort.describeGlobalTheme();
    	//metaDataPort.describeDataCategoryGroupStructures(null,true);
    	metaDataPort.describeAvailableQuickActions('test');
    	//metaDataPort.create(null);
    	metaDataPort.getDeleted('Account',Datetime.now(),Datetime.now());
    	metaDataPort.describeQuickActions(lstSobjectTypes);
    	metaDataPort.retrieveQuickActionTemplates(lstSobjectTypes,'test');
    	metaDataPort.login('test','test');
    	//metaDataPort.performQuickActions(null);
    	//metaDataPort.describeSearchScopeOrder();
    	metaDataPort.describeDataCategoryGroups(lstSobjectTypes);
    	metaDataPort.queryMore('test');
    	metaDataPort.search_x('test');
    	metaDataPort.describeTheme(lstSobjectTypes);
    	//metaDataPort.upsert_x('test',null);
    	metaDataPort.describeSObjectListViews('Account',true,'test',1,1);
    	
    	 
    }
    
    
    /*
       Method Name : coverInnerClasses
       Description : cover the inner classeses by instantiating them
    */
    @IsTest
    private static void instantiateInnerClasses()
    {              
        // Reference types
        new partnerSoapSforceCom();
        new partnerSoapSforceCom.DescribeSoftphoneLayoutResult();
        new partnerSoapSforceCom.queryMore_element();
        new partnerSoapSforceCom.DescribeAppMenuResult();
        new partnerSoapSforceCom.DescribeSoftphoneLayoutItem();
        new partnerSoapSforceCom.executeListViewResponse_element();
        new partnerSoapSforceCom.DescribeSoftphoneLayoutSection();
        new partnerSoapSforceCom.PerformQuickActionRequest();
        new partnerSoapSforceCom.describeQuickActionsResponse_element();
        new partnerSoapSforceCom.DescribeSoqlListViewParams();
        new partnerSoapSforceCom.DescribeApprovalLayoutResult();
        new partnerSoapSforceCom.SearchSnippet();
        new partnerSoapSforceCom.CustomLinkComponent();
        new partnerSoapSforceCom.ReportChartComponent();
        new partnerSoapSforceCom.KnowledgeLanguageItem();
        new partnerSoapSforceCom.loginResponse_element();
        new partnerSoapSforceCom.describeAppMenuResponse_element();
        new partnerSoapSforceCom.Email();
        new partnerSoapSforceCom.describeSoftphoneLayout_element();
        new partnerSoapSforceCom.getServerTimestamp_element();
        new partnerSoapSforceCom.ChildRelationship();
        new partnerSoapSforceCom.process_element();
        new partnerSoapSforceCom.DescribeLayoutComponent();
        new partnerSoapSforceCom.SoqlSubQueryCondition();
        new partnerSoapSforceCom.LimitInfo();
        new partnerSoapSforceCom.LimitInfoHeader_element();
        new partnerSoapSforceCom.QueryOptions_element();
        new partnerSoapSforceCom.CallOptions_element();
        new partnerSoapSforceCom.describeAvailableQuickActions_element();
        new partnerSoapSforceCom.SoqlCondition();
        new partnerSoapSforceCom.AllOrNoneHeader_element();
        new partnerSoapSforceCom.DescribeSoftphoneLayoutInfoField();
        new partnerSoapSforceCom.describeTabsResponse_element();
        new partnerSoapSforceCom.describeTabs_element();
        new partnerSoapSforceCom.DescribeLayoutButton();
        new partnerSoapSforceCom.describeGlobalResponse_element();
        new partnerSoapSforceCom.SendEmailError();
        new partnerSoapSforceCom.ListViewColumn();
        new partnerSoapSforceCom.DescribeLayoutItem();
        new partnerSoapSforceCom.emptyRecycleBin_element();
        new partnerSoapSforceCom.describeSoqlListViewsResponse_element();
        new partnerSoapSforceCom.DisableFeedTrackingHeader_element();
        new partnerSoapSforceCom.searchResponse_element();
        new partnerSoapSforceCom.MergeResult();
        new partnerSoapSforceCom.describeAppMenu_element();
        new partnerSoapSforceCom.SoqlConditionGroup();
        new partnerSoapSforceCom.sendEmail_element();
        new partnerSoapSforceCom.delete_element();
        new partnerSoapSforceCom.DescribeQuickActionListResult();
        new partnerSoapSforceCom.DescribeLayoutButtonSection();
        new partnerSoapSforceCom.updateResponse_element();
        new partnerSoapSforceCom.retrieve_element();
       // new partnerSoapSforceCom.DescribeComponentInstanceProperty();
        new partnerSoapSforceCom.RelatedList();
        new partnerSoapSforceCom.describeGlobalThemeResponse_element();
        new partnerSoapSforceCom.describeSearchScopeOrderResponse_element();
        new partnerSoapSforceCom.describeApprovalLayout_element();
        new partnerSoapSforceCom.DescribeThemeItem();
        new partnerSoapSforceCom.create_element();
       // new partnerSoapSforceCom.DescribeFlexiPageRegion();
        new partnerSoapSforceCom.describeThemeResponse_element();
        new partnerSoapSforceCom.createResponse_element();
        new partnerSoapSforceCom.describeKnowledgeSettings_element();
        new partnerSoapSforceCom.ProcessRequest();
        new partnerSoapSforceCom.LeadConvert();
        new partnerSoapSforceCom.SoqlNotCondition();
        new partnerSoapSforceCom.DescribeQuickActionListItemResult();
        new partnerSoapSforceCom.QuickActionTemplateResult();
        new partnerSoapSforceCom.LocaleOptions_element();
        new partnerSoapSforceCom.DescribeSoftphoneScreenPopOption();
        new partnerSoapSforceCom.DescribeSoqlListView();
        new partnerSoapSforceCom.getUpdatedResponse_element();
        new partnerSoapSforceCom.StreamingEnabledHeader_element();
        new partnerSoapSforceCom.DescribeDataCategoryGroupResult();
        new partnerSoapSforceCom.FilteredLookupInfo();
        new partnerSoapSforceCom.DataCategory();
        new partnerSoapSforceCom.describeSoqlListViews_element();
        new partnerSoapSforceCom.DescribeLayoutResult();
        new partnerSoapSforceCom.GetDeletedResult();
        new partnerSoapSforceCom.DescribeLayoutSection();
        new partnerSoapSforceCom.AssignmentRuleHeader_element();
        new partnerSoapSforceCom.ListViewRecordColumn();
        new partnerSoapSforceCom.PackageVersionHeader_element();
        new partnerSoapSforceCom.retrieveQuickActionTemplatesResponse_element();
        new partnerSoapSforceCom.login_element();
        new partnerSoapSforceCom.SendEmailResult();
        new partnerSoapSforceCom.getUpdated_element();
        new partnerSoapSforceCom.PicklistForRecordType();
        new partnerSoapSforceCom.upsertResponse_element();
        new partnerSoapSforceCom.Field();
       // new partnerSoapSforceCom.describeFlexiPagesResponse_element();
        new partnerSoapSforceCom.describeSObjectsResponse_element();
        new partnerSoapSforceCom.undeleteResponse_element();
        new partnerSoapSforceCom.setPasswordResponse_element();
        new partnerSoapSforceCom.describeLayout_element();
        new partnerSoapSforceCom.DescribeLayout();
        new partnerSoapSforceCom.sendEmailResponse_element();
        new partnerSoapSforceCom.describeKnowledgeSettingsResponse_element();
        new partnerSoapSforceCom.PicklistEntry();
        new partnerSoapSforceCom.UserTerritoryDeleteHeader_element();
        new partnerSoapSforceCom.describeApprovalLayoutResponse_element();
        new partnerSoapSforceCom.SearchRecord();
        new partnerSoapSforceCom.NamedLayoutInfo();
        new partnerSoapSforceCom.describeSObjectResponse_element();
        new partnerSoapSforceCom.EmailHeader_element();
        new partnerSoapSforceCom.RelatedListColumn();
        new partnerSoapSforceCom.GetUpdatedResult();
        new partnerSoapSforceCom.DescribeQuickActionDefaultValue();
        new partnerSoapSforceCom.performQuickActionsResponse_element();
        new partnerSoapSforceCom.resetPassword_element();
        new partnerSoapSforceCom.UndeleteResult();
        new partnerSoapSforceCom.Error();
        new partnerSoapSforceCom.NameValuePair();
        new partnerSoapSforceCom.DebuggingHeader_element();
        new partnerSoapSforceCom.SetPasswordResult();
        new partnerSoapSforceCom.describeSearchScopeOrder_element();
        new partnerSoapSforceCom.describeSObjectListViewsResponse_element();
        new partnerSoapSforceCom.DescribeApprovalLayout();
        new partnerSoapSforceCom.getUserInfo_element();
        new partnerSoapSforceCom.LoginResult();
        new partnerSoapSforceCom.DescribeSoqlListViewsRequest();
        new partnerSoapSforceCom.describeCompactLayouts_element();
        new partnerSoapSforceCom.ProcessResult();
        new partnerSoapSforceCom.logout_element();
        new partnerSoapSforceCom.describeDataCategoryGroupsResponse_element();
        new partnerSoapSforceCom.ExecuteListViewRequest();
        new partnerSoapSforceCom.PerformQuickActionResult();
        new partnerSoapSforceCom.ResetPasswordResult();
        new partnerSoapSforceCom.DescribeColor();
        new partnerSoapSforceCom.merge_element();
        new partnerSoapSforceCom.describeTheme_element();
        new partnerSoapSforceCom.describeSoftphoneLayoutResponse_element();
        new partnerSoapSforceCom.describeGlobal_element();
        new partnerSoapSforceCom.describeSObjectListViews_element();
        new partnerSoapSforceCom.RecordTypeInfo();
        new partnerSoapSforceCom.queryResponse_element();
        new partnerSoapSforceCom.DescribeColumn();
        new partnerSoapSforceCom.emptyRecycleBinResponse_element();
        new partnerSoapSforceCom.EmptyRecycleBinResult();
        new partnerSoapSforceCom.RelatedContent();
        new partnerSoapSforceCom.describeDataCategoryGroupStructures_element();
      //  new partnerSoapSforceCom.DescribeComponentInstance();
        new partnerSoapSforceCom.DescribeRelatedContentItem();
        new partnerSoapSforceCom.GetUserInfoResult();
        new partnerSoapSforceCom.QueryResult();
        new partnerSoapSforceCom.performQuickActions_element();
        new partnerSoapSforceCom.FieldLayoutComponent();
        new partnerSoapSforceCom.LeadConvertResult();
        new partnerSoapSforceCom.sendEmailMessage_element();
        new partnerSoapSforceCom.MruHeader_element();
        new partnerSoapSforceCom.processResponse_element();
        new partnerSoapSforceCom.DescribeSearchScopeOrderResult();
        new partnerSoapSforceCom.ProcessWorkitemRequest();
        new partnerSoapSforceCom.SessionHeader_element();
        new partnerSoapSforceCom.SoqlWhereCondition();
        new partnerSoapSforceCom.DescribeDataCategoryGroupStructureResult();
        new partnerSoapSforceCom.executeListView_element();
    //   new partnerSoapSforceCom.DescribeFlexiPageResult();
        new partnerSoapSforceCom.ListViewOrderBy();
        new partnerSoapSforceCom.describeDataCategoryGroups_element();
        new partnerSoapSforceCom.AllowFieldTruncationHeader_element();
        new partnerSoapSforceCom.ActionOverride();
        new partnerSoapSforceCom.getDeletedResponse_element();
        new partnerSoapSforceCom.SaveResult();
        new partnerSoapSforceCom.deleteResponse_element();
        new partnerSoapSforceCom.convertLead_element();
        new partnerSoapSforceCom.RecordTypeCompactLayoutMapping();
        new partnerSoapSforceCom.describeSObjects_element();
        new partnerSoapSforceCom.describeDataCategoryGroupStructuresResponse_element();
        new partnerSoapSforceCom.update_element();
        new partnerSoapSforceCom.search_element();
        new partnerSoapSforceCom.DescribeAvailableQuickActionResult();
        new partnerSoapSforceCom.describeQuickActions_element();
        new partnerSoapSforceCom.RelatedListSort();
        new partnerSoapSforceCom.describeSObject_element();
        new partnerSoapSforceCom.invalidateSessionsResponse_element();
        new partnerSoapSforceCom.LoginScopeHeader_element();
        new partnerSoapSforceCom.EmailFileAttachment();
        new partnerSoapSforceCom.convertLeadResponse_element();
        new partnerSoapSforceCom.queryAll_element();
        new partnerSoapSforceCom.describeSearchLayoutsResponse_element();
        new partnerSoapSforceCom.GetServerTimestampResult();
        new partnerSoapSforceCom.describePrimaryCompactLayouts_element();
        new partnerSoapSforceCom.retrieveResponse_element();
        new partnerSoapSforceCom.queryAllResponse_element();
        new partnerSoapSforceCom.invalidateSessions_element();
        new partnerSoapSforceCom.location();
        new partnerSoapSforceCom.ProcessSubmitRequest();
        new partnerSoapSforceCom.describeLayoutResponse_element();
        new partnerSoapSforceCom.DescribeSearchLayoutResult();
        new partnerSoapSforceCom.getServerTimestampResponse_element();
        new partnerSoapSforceCom.DescribeIcon();
        new partnerSoapSforceCom.DeletedRecord();
        new partnerSoapSforceCom.SearchResult();
        new partnerSoapSforceCom.describeGlobalTheme_element();
        new partnerSoapSforceCom.query_element();
        new partnerSoapSforceCom.getDeleted_element();
        new partnerSoapSforceCom.DataCategoryGroupSobjectTypePair();
        new partnerSoapSforceCom.PackageVersion();
        new partnerSoapSforceCom.DescribeGlobalResult();
        new partnerSoapSforceCom.describeCompactLayoutsResponse_element();
        new partnerSoapSforceCom.describeSearchLayouts_element();
        new partnerSoapSforceCom.describeAllTabs_element();
        new partnerSoapSforceCom.SingleEmailMessage();
        new partnerSoapSforceCom.MassEmailMessage();
        new partnerSoapSforceCom.describePrimaryCompactLayoutsResponse_element();
        new partnerSoapSforceCom.DescribeAppMenuItem();
        new partnerSoapSforceCom.DescribeTabSetResult();
        new partnerSoapSforceCom.getUserInfoResponse_element();
        new partnerSoapSforceCom.DescribeCompactLayoutsResult();
        new partnerSoapSforceCom.DescribeSObjectResult();
        new partnerSoapSforceCom.retrieveQuickActionTemplates_element();
        new partnerSoapSforceCom.logoutResponse_element();
        new partnerSoapSforceCom.InvalidateSessionsResult();
        
        new partnerSoapSforceCom.ListViewRecord();
        new partnerSoapSforceCom.RecordTypeMapping();
        new partnerSoapSforceCom.DescribeGlobalSObjectResult();
        new partnerSoapSforceCom.KnowledgeSettings();
        new partnerSoapSforceCom.DescribeQuickActionResult();
        new partnerSoapSforceCom.DescribeSoqlListViewResult();
        new partnerSoapSforceCom.DebuggingInfo_element();
        new partnerSoapSforceCom.undelete_element();
        new partnerSoapSforceCom.DeleteResult();
        new partnerSoapSforceCom.queryMoreResponse_element();
        new partnerSoapSforceCom.upsert_element();
        new partnerSoapSforceCom.OwnerChangeOptions_element();
        new partnerSoapSforceCom.DescribeLayoutRow();
        new partnerSoapSforceCom.DescribeCompactLayout();
        new partnerSoapSforceCom.describeAllTabsResponse_element();
        new partnerSoapSforceCom.describeAvailableQuickActionsResponse_element();
        new partnerSoapSforceCom.DescribeSoftphoneLayoutCallType();
        new partnerSoapSforceCom.DescribeThemeResult();
      //  new partnerSoapSforceCom.describeFlexiPages_element();
        
        new partnerSoapSforceCom.ExecuteListViewResult();
        new partnerSoapSforceCom.sendEmailMessageResponse_element();
        new partnerSoapSforceCom.address();
        new partnerSoapSforceCom.resetPasswordResponse_element();
        new partnerSoapSforceCom.MergeRequest();
        new partnerSoapSforceCom.DescribeTab();
        new partnerSoapSforceCom.Soap();
        
        new partnerSoapSforceCom.DescribeGlobalTheme();
        new partnerSoapSforceCom.mergeResponse_element();
        new partnerSoapSforceCom.UpsertResult();
        new partnerSoapSforceCom.setPassword_element();
        //added by a
        new partnerSoapSforceCom.ExtendedErrorDetails();
        new partnerSoapSforceCom.JunctionIdListNames();
        new partnerSoapSforceCom.deleteByExampleResponse_element();
        new partnerSoapSforceCom.RenderEmailTemplateError();
        new partnerSoapSforceCom.RenderStoredEmailTemplateRequest();
        new partnerSoapSforceCom.describeDataCategoryMappingsResponse_element();
        new partnerSoapSforceCom.renderStoredEmailTemplateResponse_element();
        new partnerSoapSforceCom.NameCaseValue();
        new partnerSoapSforceCom.SearchLayoutField();
        new partnerSoapSforceCom.DescribeVisualForceResult();
        new partnerSoapSforceCom.EntityErrorMetadata();
        new partnerSoapSforceCom.describeDataCategoryMappings_element();
        new partnerSoapSforceCom.DescribeDataCategoryMappingResult();
        new partnerSoapSforceCom.DescribeLayoutSaveOption();
        new partnerSoapSforceCom.FindDuplicatesResult();
        new partnerSoapSforceCom.DescribeAnimationRule();
        new partnerSoapSforceCom.LogInfo();
        new partnerSoapSforceCom.ChangeOwnPasswordResult();
        new partnerSoapSforceCom.findDuplicates_element();
        new partnerSoapSforceCom.deleteByExample_element();
        new partnerSoapSforceCom.RenderEmailTemplateBodyResult();
        new partnerSoapSforceCom.findDuplicatesByIdsResponse_element();
        new partnerSoapSforceCom.describePathAssistantsResponse_element();
        new partnerSoapSforceCom.Canvas();
        new partnerSoapSforceCom.findDuplicatesResponse_element();
        new partnerSoapSforceCom.FieldLevelSearchMetadata();
        new partnerSoapSforceCom.MatchRecord();
        new partnerSoapSforceCom.changeOwnPasswordResponse_element();
        new partnerSoapSforceCom.DescribePathAssistant();
        new partnerSoapSforceCom.AdditionalInformationMap();
        new partnerSoapSforceCom.MatchResult();
        new partnerSoapSforceCom.CurrencyConversionHeader_element();
        new partnerSoapSforceCom.DescribePathAssistantField();
        new partnerSoapSforceCom.RenderStoredEmailTemplateResult();
        new partnerSoapSforceCom.ChangeEventHeader();
        new partnerSoapSforceCom.describeNouns_element();
        new partnerSoapSforceCom.renderEmailTemplate_element();
        new partnerSoapSforceCom.DuplicateRuleHeader_element();
        new partnerSoapSforceCom.describeNounsResponse_element();
        new partnerSoapSforceCom.DeleteByExampleResult();
        new partnerSoapSforceCom.SearchResultsMetadata();
        new partnerSoapSforceCom.RenderEmailTemplateResult();
        new partnerSoapSforceCom.describeVisualForce_element();
        new partnerSoapSforceCom.FieldDiff();
        new partnerSoapSforceCom.describeQuickActionsForRecordType_element();
        new partnerSoapSforceCom.retrieveMassQuickActionTemplatesResponse_element();
        new partnerSoapSforceCom.DescribePathAssistantStep();
        new partnerSoapSforceCom.DuplicateError();
        new partnerSoapSforceCom.describeVisualForceResponse_element();
        new partnerSoapSforceCom.DescribeNounResult();
        new partnerSoapSforceCom.EntitySpellCorrectionMetadata();
        new partnerSoapSforceCom.SearchLayoutFieldsDisplayed();
        new partnerSoapSforceCom.DescribeLayoutFeedView();
        new partnerSoapSforceCom.StringList();
        new partnerSoapSforceCom.AnalyticsCloudComponent();
        new partnerSoapSforceCom.SearchLayoutButton();
        new partnerSoapSforceCom.DuplicateResult();
        new partnerSoapSforceCom.LabelsSearchMetadata();
        new partnerSoapSforceCom.describeQuickActionsForRecordTypeResponse_element();
        new partnerSoapSforceCom.EntitySearchPromotionMetadata();
        new partnerSoapSforceCom.DescribeSearchableEntityResult();
        new partnerSoapSforceCom.EntityIntentQueryMetadata();
        new partnerSoapSforceCom.renderStoredEmailTemplate_element();
        new partnerSoapSforceCom.describeSearchableEntities_element();
        new partnerSoapSforceCom.RenderEmailTemplateRequest();
        new partnerSoapSforceCom.findDuplicatesByIds_element();
        new partnerSoapSforceCom.renderEmailTemplateResponse_element();
        new partnerSoapSforceCom.SearchRecordMetadata();
        new partnerSoapSforceCom.RecordTypesSupported();
        new partnerSoapSforceCom.retrieveMassQuickActionTemplates_element();
        new partnerSoapSforceCom.DescribeLayoutFeedFilter();
        new partnerSoapSforceCom.describeSearchableEntitiesResponse_element();
        new partnerSoapSforceCom.EntitySearchMetadata();
        new partnerSoapSforceCom.NameObjectValuePair();
        new partnerSoapSforceCom.DescribePathAssistantsResult();
        new partnerSoapSforceCom.SearchLayoutButtonsDisplayed();
        new partnerSoapSforceCom.VisualforcePage();
        new partnerSoapSforceCom.RelationshipReferenceTo();
        new partnerSoapSforceCom.OwnerChangeOption();
        new partnerSoapSforceCom.FieldComponent();
        new partnerSoapSforceCom.ScopeInfo();
        new partnerSoapSforceCom.describePathAssistants_element();
                
    }
}