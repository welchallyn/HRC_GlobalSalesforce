@isTest
public class ParseMultiselectValuesTest {
    @isTest
    
    static void ParseMultiselectValuesTest(){
        
        List<string> tempLst = new list<string>();
        List<string> EmailList = new List<string>();
        
        EmailList.add('ramndeep.kaur@hillrom.com');
        
        tempLst.add('Data & Analytics');
        
        tempLst.add('Integrations');
        
        ParseMultiselectValues.getVal(tempLst);
        
        
        
    }
}