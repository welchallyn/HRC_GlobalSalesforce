@isTest
public class BRMITFormSendEmailsTest {
	public testmethod static void testSendEmail(){ 
        Test.startTest();
        List<BRMITFormSendEmails.FlowInputs> inputList = new List<BRMITFormSendEmails.FlowInputs>();
        BRMITFormSendEmails.FlowInputs inputs = new BRMITFormSendEmails.FlowInputs();
        List<String> email = new List<String>();
        email.add('test@test.com');
        inputs.emails = email;
        inputList.add(inputs);
        BRMITFormSendEmails.sendEmails(inputList);
        Test.stopTest();
    }
}