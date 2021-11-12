@isTest
private class SL_Test_AccountMappingFromPostalCode {

    static testMethod void fetchPostalCode() 
    {
    	List <Account> lst = new List <Account> (); 
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Billingcity = 'TestCity-01';
        acc.BillingPostalCode = '00544';
        acc.BillingCountry = 'US';
        acc.BillingState = 'Alaska';
        acc.ShippingPostalCode = '005441';
        acc.ShippingCountry = 'US';
        acc.Type = 'Strategic';
        acc.Market_Segment_WA__c = 'Acuteee';
        insert acc;
        
        lst.add(acc);
        Account acc1 = new Account();
        acc1.Name = 'Test Account1';
        acc1.Billingcity = 'TestCity-03';
        acc1.BillingPostalCode = '005442';
        acc1.BillingCountry = 'United States';
        acc1.BillingState = 'Alaska';
        acc1.ShippingPostalCode = '00544';
        acc1.ShippingCountry = 'US';
        acc1.Type = 'Agent';
        acc1.Inside_Sales__c='inside';
        acc1.Market_Segment__c='Acute';
        acc1.Market_Segment_WA__c = 'Acuteee';
        insert acc1;
        lst.add(acc1);
         Account acc4 = new Account();
        acc4.Name = 'Test Account1';
        acc4.Billingcity = 'TestCity-03';
        acc4.BillingPostalCode = '005442';
        acc4.BillingCountry = 'USA';
        acc4.BillingState = 'Alaska';
        acc4.ShippingPostalCode = '005441';
        acc4.ShippingCountry = 'US';
        acc4.Type = 'Agent';
        acc4.Inside_Sales__c='inside';
        acc4.Market_Segment_WA__c = 'Ambulatory';
        insert acc4;
        lst.add(acc4);
        Account acc5 = new Account();
        acc5.Name = 'Test Account1';
        acc5.Billingcity = 'TestCity-03';
        acc5.BillingPostalCode = '005442';
        acc5.BillingCountry = 'USA';
        acc5.BillingState = 'Alaska';
        acc5.ShippingPostalCode = '005441';
        acc5.ShippingCountry = 'CA';
        acc5.Type = 'Agent';
        acc5.Market_Segment_WA__c = 'Acuteee';
        insert acc5;
        lst.add(acc5);
        Set<String> str=new set<String>{'ka005441','005451','005441','005441'};
        
        List <Postal_Code_Mapping__c> postalcode = new List <Postal_Code_Mapping__c> ();
        Postal_Code_Mapping__c post = new Postal_Code_Mapping__c();
        post.Name = 'ka005441';
        post.Acute_Region__c = 'Acute Region Test';
        post.Acute_Territory__c = 'Acute Territory Test';
        post.Ambulatory_Region__c = 'Ambulatory Region';
        post.Ambulatory_Territory__c = 'Ambulatory Territory';
        post.Inside_Sales__c = 'Inside Sales Test';
        post.Solutions_Architect__c = 'Solution Architect Test';
        post.Acute_Mortara_Territory__c = 'Acute Mortara Territory';
        insert post;
        postalcode.add(post);
         Postal_Code_Mapping__c post1 = new Postal_Code_Mapping__c();
        post1.Name = '89645';
        post1.Acute_Region__c = 'Acute Region Test';
        post1.Acute_Territory__c = 'Acute Territory Test';
        post1.Ambulatory_Region__c = 'Ambulatory Region';
        post1.Ambulatory_Territory__c = 'Ambulatory Territory';
        post1.Inside_Sales__c = 'Inside Sales Test';
        post1.Solutions_Architect__c = 'Solution Architect Test';
        post1.Acute_Mortara_Territory__c = 'Acute Mortara Territory';
        insert post1;
        postalcode.add(post1);
        Map <String, Postal_Code_Mapping__c> mappost= new Map <String, Postal_Code_Mapping__c>();
        mappost.put('89645',post1);
    //    mappost.put('ka005441',post);
    
    test.startTest();
           
       SL_AccountMappingFromPostalCode.fetchPostalCode(str,lst);
    // SL_AccountMappingFromPostalCode.fieldMapAccountFromPostalCode(acc1,mappost);
     SL_AccountMappingFromPostalCode.fieldMapAccountFromPostalCode(acc1,null);
    test.stopTest(); 
    }  
    
    static testMethod void fieldMapAccountFromPostalCode() 
    {
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Billingcity = 'TestCity-01';
        acc.BillingPostalCode = '00544';
        acc.BillingCountry = 'US';
        acc.BillingState = 'Alaska';
        acc.ShippingPostalCode = '005441';
        acc.ShippingCountry = 'CA';
        acc.Type = 'Strategic';
        acc.Market_Segment_WA__c = 'Acute';
        insert acc;
        Postal_Code_Mapping__c map1=new Postal_Code_Mapping__c();
       // map1.Name='Testmapping';
        map1.Name = 'Postal Code Mapping Map1';
        map1.Acute_Region__c = 'Acute Region Test Map1';
        map1.Acute_Territory__c = 'Acute Territory Test Map1';
        map1.Ambulatory_Region__c = 'Ambulatory Region Map1';
        map1.Ambulatory_Territory__c = 'Ambulatory Territory Map1';
        map1.Inside_Sales__c = 'Inside Sales Test Map1';
        map1.Solutions_Architect__c = 'Solution Architect Test Map1';
        map1.Acute_Mortara_Territory__c = 'Acute Mortara Territory Map1';
        insert map1;
     //   Map <String, Postal_Code_Mapping__c> mappost1= new Map <String, Postal_Code_Mapping__c>();
     //   mappost1.put('89646',post1);
      //  test.startTest();
           
       // SL_AccountMappingFromPostalCode.fieldMapAccountFromPostalCode(map1);
      
      //  test.stopTest(); 
    }  
	
	
	static testMethod void fetchPostalCodeforElse() 
    {
    	List <Account> lst = new List <Account> (); 
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Billingcity = 'TestCity-01';
        acc.BillingPostalCode = '005441';
        acc.BillingCountry = 'US';
        acc.BillingState = 'Alaska';
        acc.ShippingPostalCode = '005441';
        acc.ShippingCountry = 'US';
        acc.Type = 'Ambulatory';
        acc.Market_Segment_WA__c = 'Ambulatory';
        insert acc;
        lst.add(acc);
		
        Account acc1 = new Account();
        acc1.Name = 'Test Account';
        acc1.Billingcity = 'TestCity-01';
        acc1.BillingPostalCode = 'ka0005';
        acc1.BillingCountry = 'CA';
        acc1.BillingState = 'Alaska';
        acc1.ShippingPostalCode = '005441';
        acc1.ShippingCountry = 'US';
        acc1.Type = 'Acute';
        acc1.Market_Segment_WA__c = 'Acute';
        insert acc1;
        lst.add(acc1);
        
		Set<String> str=new set<String>{'ka0','0054','00544','005441','005441'};
        
        List <Postal_Code_Mapping__c> postalcode = new List <Postal_Code_Mapping__c> ();
        Postal_Code_Mapping__c post = new Postal_Code_Mapping__c();
        post.Name = '0054';
        post.Acute_Region__c = 'Acute Region Test';
        post.Acute_Territory__c = 'Acute Territory Test';
        post.Ambulatory_Region__c = 'Ambulatory Region';
        post.Ambulatory_Territory__c = 'Ambulatory Territory';
        post.Inside_Sales__c = 'Inside Sales Test';
        post.Solutions_Architect__c = 'Solution Architect Test';
        post.Acute_Mortara_Territory__c = 'Acute Mortara Territory';
        insert post;
        postalcode.add(post);
         Postal_Code_Mapping__c post1 = new Postal_Code_Mapping__c();
        post1.Name = 'ka0';
        post1.Acute_Region__c = 'Acute Region Test';
        post1.Acute_Territory__c = 'Acute Territory Test';
        post1.Ambulatory_Region__c = 'Ambulatory Region';
        post1.Ambulatory_Territory__c = 'Ambulatory Territory';
        post1.Inside_Sales__c = 'Inside Sales Test';
        post1.Solutions_Architect__c = 'Solution Architect Test';
        post1.Acute_Mortara_Territory__c = 'Acute Mortara Territory';
        insert post1;
        postalcode.add(post1);
		Map <String, Postal_Code_Mapping__c> mappost= new Map <String, Postal_Code_Mapping__c>();
        mappost.put('0054',post1);
		test.startTest();
			SL_AccountMappingFromPostalCode.fetchPostalCode(str,lst);
			SL_AccountMappingFromPostalCode.fieldMapAccountFromPostalCode(acc1,null);
		test.stopTest();
	}
	
    
    static testMethod void fetchPostalCodeforElseIf() 
    {
    	List <Account> lst = new List <Account> (); 
        Account acc1 = new Account();
        acc1.Name = 'Test Account';
        acc1.Billingcity = 'TestCity-01';
        acc1.BillingPostalCode = '66666';
        acc1.BillingCountry = 'CA';
        acc1.BillingState = 'Alaska';
        acc1.ShippingPostalCode = '005441';
        acc1.ShippingCountry = 'US';
        acc1.Type = 'Acute';
        acc1.Market_Segment_WA__c = 'Acute';
        insert acc1;
        lst.add(acc1);
        
        Account acc2 = new Account();
        acc2.Name = 'Test Account';
        acc2.Billingcity = 'TestCity-01';
        acc2.BillingPostalCode = 'ka0';
        acc2.BillingCountry = 'CA';
        acc2.BillingState = 'Alaska';
        acc2.ShippingPostalCode = '005441';
        acc2.ShippingCountry = 'US';
        acc2.Type = 'Acute';
        acc2.Market_Segment_WA__c = 'System';
        insert acc2;
        lst.add(acc2);
        
        Account acc3 = new Account();
        acc3.Name = 'Test Account';
        acc3.Billingcity = 'TestCity-01';
        acc3.BillingPostalCode = 'ka0';
        acc3.BillingCountry = 'CA';
        acc3.BillingState = 'Alaska';
        acc3.ShippingPostalCode = '005441';
        acc3.ShippingCountry = 'US';
        acc3.Type = 'Acute';
        acc3.Market_Segment_WA__c = 'Ambulatory';
        insert acc3;
        lst.add(acc3);
        
		Set<String> str=new set<String>{'ka0','0054','00544','005441','005441'};
        
        List <Postal_Code_Mapping__c> postalcode = new List <Postal_Code_Mapping__c> ();
        
        Postal_Code_Mapping__c post1 = new Postal_Code_Mapping__c();
        post1.Name = 'ka0';
        post1.Acute_Region__c = 'Acute Region Test';
        post1.Acute_Territory__c = 'Acute Territory Test';
        post1.Ambulatory_Region__c = 'Ambulatory Region';
        post1.Ambulatory_Territory__c = 'Ambulatory Territory';
        post1.Inside_Sales__c = 'Inside Sales Test';
        post1.Solutions_Architect__c = 'Solution Architect Test';
        post1.Acute_Mortara_Territory__c = 'Acute Mortara Territory';
        insert post1;
        postalcode.add(post1);
		Map <String, Postal_Code_Mapping__c> mappost= new Map <String, Postal_Code_Mapping__c>();
        mappost.put('0054',post1);
		test.startTest();
			SL_AccountMappingFromPostalCode.fetchPostalCode(str,lst);
			SL_AccountMappingFromPostalCode.fieldMapAccountFromPostalCode(acc1,null);
		test.stopTest();
	}
	
}