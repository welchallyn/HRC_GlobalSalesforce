public class ParseMultiselectValues {
    
   @InvocableMethod(label='ITTowerValues' Description='Parse IT Tower Values')
    public static List<List<String>> getVal(List<String>val){
       
        List<String>sendMail = new List<String>();
        List<String>MultiVal = val[0].split(';');
        
        List<List<String>> DataEmail = new  List<List<String>>();
        Map<String,List<String>>custDataMap = new Map<String,List<String>>();
        List<BRM_IT_Tower_Information__mdt> ITList =  [Select Label,Emails__c from  BRM_IT_Tower_Information__mdt];
        for(BRM_IT_Tower_Information__mdt m :ITList){
            if(m.Emails__c!=null){
                List<String>custEmail = new List<String>();
                if(m.Emails__c.contains(',')){
                    custEmail = m.Emails__c.split(',');
                }
                else
                    custEmail.add(m.Emails__c); 
                custDataMap.put(m.Label,custEmail);
            }
        }
        for(String s : MultiVal){
            
            if(custDataMap.containsKey(s)){
                sendMail.addAll(custDataMap.get(s));
            }
            
        }
      
        
        DataEmail.add(sendMail);
       
        if(!sendMail.isEmpty()){
            
            return DataEmail;
        }
        else
            return null;
    }
    
     

   
}