/*************************************************************************************************
* Class Name                       : HRCFSL_TestUtilityClass_Test
* Author                           : Capgemini
* Date                             : 20/01/2020
* Description                      : Test class for HRCFSL_TestUtilityClass class. 
*************************************************************************************************/
@isTest
public class HRCFSL_TestUtilityClass_Test {
    @isTest static void TestMasterFunc() {
        
        Account acc=new Account();
        acc.Name='Test Acc';
        insert acc;
        Id accid=acc.Id;
        
        Test.startTest();
       
        List<User> lu=HRCFSL_TestUtilityClass.createUsers(true,'System Administrator',1);
        list<ServiceResource>  sr=HRCFSL_TestUtilityClass.createServiceResources(true,lu);
        Asset tas=HRCFSL_TestUtilityClass.createAsset(true);
        Entitlement et= HRCFSL_TestUtilityClass.createEntitlement(true,'entname',date.today(),date.today(),accid);
        Schema.Location loc= HRCFSL_TestUtilityClass.createCustomer(true,'8545');
        ServiceAppointment sa=HRCFSL_TestUtilityClass.createSAwithWorkOrder(true, '12345','8545');
        
        //ProductConsumed pc=HRCFSL_TestUtilityClass.createProductConsumed(true, sa.ParentRecordId  );//2nd arg is wo
       
        Test.stopTest();
    }
    @isTest static void TestMultipleSA() {
        Test.startTest();
        
        List<ServiceAppointment>  salist=HRCFSL_TestUtilityClass.createMultipleServiceAppointmentsWithWO('Scheduled',System.now(),System.now(),System.now(),System.now());
        
        Test.stopTest();
    }
    
    @isTest static void TestWODefWT() {
        Test.startTest();
        
        List<WorkOrder>  wos=HRCFSL_TestUtilityClass.createWorkOrderWithDefaultWorkType();
        
        Test.stopTest();
    }

    @isTest static void TestRentalFunc() {
        Test.startTest();
        Schema.Location loc= HRCFSL_TestUtilityClass.createCustomer(true,'Customer0619');
        Product2 product = HRCFSL_TestUtilityClass.createProduct(true,'PS73B','PAO');
        HRCSVC_Customer_Rental__c crent = HRCFSL_TestUtilityClass.createCustomerRental(true,product.Id,loc.Id);
        ServiceTerritory st= HRCFSL_TestUtilityClass.createServiceTerritory(true,'12345','stname');
        HRCSVC_ST_Product_Unavailability__c cstpou =  HRCFSL_TestUtilityClass.createSTProductUnavailability(true,product.Id,st.Id);
        HRCSVC_Standing_PO__c cstpo =  HRCFSL_TestUtilityClass.createStandingPO(true,loc.Id);
        HRCSVC_Standing_PO_Rule__c cstpor =  HRCFSL_TestUtilityClass.createStandingPORule(true,product.Id,'tempw',loc.Id,cstpo.Id); 
        Account account = HRCFSL_TestUtilityClass.createAccount(true,'Active');        
        Additional_Account_Info__c addacc = HRCFSL_TestUtilityClass.createAdditionalAccountInfo(true,'Temp KbAcc','protocol acc');
        Asset atsstest = HRCFSL_TestUtilityClass.createAsset(true,'ST',product.id);
        Case caseObj = HRCFSL_TestUtilityClass.createCase(true,'New','Problem - Product Related','Onsite Repair');
        HRCSVC_Complaint_Qualification__c comqual = HRCFSL_TestUtilityClass.createComplaintQualification(true,'Qualified Complaint');
        contact con=HRCFSL_TestUtilityClass.createContact(true,'Temp KbAcc','Test','Cont','tcont@test.com');
        
        Test.stopTest();
    }
    @isTest static void TestcreateSR() {
        Test.startTest();
        
        Schema.Location loc= HRCFSL_TestUtilityClass.createCustomer(true,'8545');
        ServiceAppointment sa=HRCFSL_TestUtilityClass.createSAwithWOInPrg(true, '12345',loc.Id);
        ServiceReport srr=HRCFSL_TestUtilityClass.createServiceReport(true,sa.Id );//2nd arg is ID of a service appointment record 
                
        Test.stopTest();
    }
    @isTest static void TestcreateSA() {
        Test.startTest();
        
        Schema.Location loc= HRCFSL_TestUtilityClass.createCustomer(true,'8545');
        ServiceAppointment sa=HRCFSL_TestUtilityClass.createSAwithWONone(true, '12345',loc.Id);  
                
        Test.stopTest();
    }
}