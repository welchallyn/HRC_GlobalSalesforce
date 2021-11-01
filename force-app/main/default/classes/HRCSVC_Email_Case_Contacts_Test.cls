@isTest
public class HRCSVC_Email_Case_Contacts_Test {
    public testmethod static void testSendEmail(){
        Test.startTest();
        List<HRCSVC_Email_Case_Contacts.FlowInputs> inputList = new List<HRCSVC_Email_Case_Contacts.FlowInputs>();
        HRCSVC_Email_Case_Contacts.FlowInputs inputs = new HRCSVC_Email_Case_Contacts.FlowInputs();
        List<String> email = new List<String>();
        email.add('test@test.com');
        inputs.emails = email;
        inputs.emailType = 'Creation';
        inputList.add(inputs);
        HRCSVC_Email_Case_Contacts.emailContacts(inputList);
        Test.stopTest();
    }
}