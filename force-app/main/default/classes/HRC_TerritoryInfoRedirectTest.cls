@isTest
private class HRC_TerritoryInfoRedirectTest {

    static testMethod void myUnitTest() {
        Territory_Info__c info = new Territory_Info__c(Name = 'TEST-TERR', CurrencyIsoCode = 'USD');
        insert info;
        
        Attachment att=new Attachment();
		att.Body=Blob.valueOf('BODY');
		att.Name='Note_' + System.now().format('yyyy_MM_dd_hh_mm_ss') + '.txt';
		att.parentId = info.id;
		insert att;
		
		HRC_TerritoryInfoRedirect ti = new HRC_TerritoryInfoRedirect();
		System.debug(ti.userLevel);
		ti.redirect();
    }
}