public class BRMITFormSendEmails {
	@InvocableMethod
    public static void sendEmails (List<FlowInputs> flowinputs) {
        try{   
            if(flowinputs.size() > 0){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(flowinputs[0].emails);
                mail.setSubject(flowinputs[0].subject);
                mail.setPlainTextBody(flowinputs[0].emailbody);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
    	}
        catch(Exception e){
            system.debug('Exception : '+e);
        }
    }
    public class FlowInputs{
        @InvocableVariable
        public List<String> emails;
        
        @InvocableVariable
        public String emailbody;
        
        @InvocableVariable
        public String subject;
        
    }
}