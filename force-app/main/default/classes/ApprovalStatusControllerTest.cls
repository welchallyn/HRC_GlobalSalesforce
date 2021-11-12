@isTest(seeAllData=true)
public class ApprovalStatusControllerTest{
        static testMethod void runTest() {
           
            PageReference pageRef1 = Page.ApprovalStatusCRHelperPage;
            DateTime dt1 = System.Now();
System.debug('dt1'+dt1);
            DateTime dt = dt1.addDays(-1);
System.debug('dt'+dt);

            pageRef1.getParameters().put('CRFromDate', String.valueOf(dt));
            pageRef1.getParameters().put('CRToDate', String.valueOf(dt1));
            pageRef1.getParameters().put('changetype', 'Normal');
            pageRef1.getParameters().put('Stype', 'All');
            Test.setCurrentPage(pageRef1);
    
            ApprovalStatusController.DatePicker dp = new ApprovalStatusController.DatePicker();
            ApprovalStatusController.CRApproverWrapper cp = new ApprovalStatusController.CRApproverWrapper();
           /* ApprovalStatusController.SRApproverWrapper sp = new ApprovalStatusController.SRApproverWrapper();*/
           
            ApprovalStatusController a = new ApprovalStatusController();
            
            a.datValueCR();
            a.datValueCR1();
            a.datValue();
            a.datValue1();
            
            
           
            
           /* PageReference pageRef2 = Page.ApprovalStatusSRHelperPage;
            pageRef2.getParameters().put('SRFromDate', String.valueOf(dt));
            pageRef2.getParameters().put('SRToDate', String.valueOf(dt1));
            pageRef2.getParameters().put('svtype', 'All');
            Test.setCurrentPage(pageRef2);*/
            
            
            
            Test.startTest();
            
            a.displayCRApprovers();
           
          //a.displaySRApprovers();
          Test.stopTest();

     
        }
        

}