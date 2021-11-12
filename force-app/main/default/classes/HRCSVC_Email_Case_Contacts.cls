public class HRCSVC_Email_Case_Contacts {
    @InvocableMethod
    public static void emailContacts (List<FlowInputs> flowinputs) {
        try{   
            if(flowinputs.size() > 0){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'noreply@hillrom.com'];
                if ( owea.size() > 0 ) {
                    mail.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                mail.setToAddresses(flowinputs[0].emails);
                mail.setSubject(flowinputs[0].emailSubject);
/*                if(flowinputs[0].emailType == 'Creation'){
                    mail.setSubject('Hillrom - New Case #: ' + flowinputs[0].casenumber);
                }
                else if(flowinputs[0].emailType == 'Comment'){
                    mail.setSubject('Hillrom - New Comment On Case #: '+ flowinputs[0].casenumber);
                }
                else if(flowinputs[0].emailType == 'Closure'){
                    mail.setSubject('Hillrom - Closed Case #: '+ flowinputs[0].casenumber);
                }  */
                
              mail.setPlainTextBody(flowinputs[0].template);
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
        public String template;
        
        @InvocableVariable
        public String casenumber;
         
        @InvocableVariable
        public String emailType;
        
        @InvocableVariable
        public String emailSubject;
    }
}