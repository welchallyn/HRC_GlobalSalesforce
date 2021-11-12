@isTest(seeAllData=false)
public class ApprovalStatusControllerSRTest{
        static testMethod void runTest() {
           
            DateTime dt1 = System.Now();
System.debug('dt1'+dt1);
            DateTime dt = dt1.addDays(-1);
System.debug('dt'+dt);

             PageReference pageRef2 = Page.ApprovalStatusSRHelperPage;
            pageRef2.getParameters().put('SRFromDate', String.valueOf(dt));
            pageRef2.getParameters().put('SRToDate', String.valueOf(dt1));
            pageRef2.getParameters().put('svtype', 'All');
            Test.setCurrentPage(pageRef2);
              
            ApprovalStatusController.DatePicker dp = new ApprovalStatusController.DatePicker();
            
            ApprovalStatusController.SRApproverWrapper sp = new ApprovalStatusController.SRApproverWrapper();
           
            ApprovalStatusController a = new ApprovalStatusController();
            
            a.datValue();
            a.datValue1();
           
             Test.startTest();
           
            a.displaySRApprovers();
           
           

            
          
          
           Test.stopTest();
            

     
        }
        

}