public class EmailHandler

{
    public static void sendEmail(string body)

    {

       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

       // email address of the salesforce email service

       //QA address// 
       //String[] toAddresses = new String[] {'calldeleteinactiverolesclass@w-16dmjer7jnnl1c94zj50d9yv3.l-uktmaa.l.apex.sandbox.salesforce.com'};
       //Production address// 
       String[] toAddresses = new String[] {'calldeleteinactiverolesclass@r-2hzpr3ctn6wwlstlqiqsnmhzag8bk512dslvd5gr2bk1jsor0e.e-kmt9mag.e.apex.salesforce.com'};

       mail.setToAddresses(toAddresses);

       mail.setSubject('Test Batch' );

       mail.setPlainTextBody(body);

       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

    }
}