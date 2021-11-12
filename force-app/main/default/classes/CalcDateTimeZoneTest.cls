/************************************************************************************************************
 * Name                             : CalcDateTimeZoneTest
 * Author                           : 
 * Date                             : July/4/2020
 * Requirement/Project Name         : Hill-Rom
 * Requirement/Project Description  : SE-30 Test class for CalcDateTimeZone
 *                                   
 * Revison                          :
/*************************************************************************************************************/
@isTest
public class CalcDateTimeZoneTest {
    @testSetup static void setup() {
    	list<user> standardUsers = HRCFSL_TestUtilityClass.createUsers(true, 'Standard User', 1);
    }
    //test method with user and request with same timezone
    @isTest
    static void calculateDateTimeTestwithSameZone() {
        //create test user with profile as standard user
        list<user> standardUsers = [select name from user where email = 'testxyz123user1@capgemini.com'];
        User standardUser;
        if(!standardUsers.isEmpty()){
            standardUser = standardUsers[0];
            standardUser.TimeZoneSidKey = 'America/Phoenix';
            update standardUser;
        }
     
        Date inputDate = Date.today();
        Time inputTime = Time.newInstance(0,0,0,0); 
        
        List<CalcDateTimeZone.Response> res = null; 
        System.runAs(standardUser) {
            CalcDateTimeZone.Request req = new CalcDateTimeZone.Request();
            req.dateInput = Date.today();
            req.hourInput = 0;
            req.minutesInput = 0;
            req.timeZoneInput = 'America/Phoenix';
            res = CalcDateTimeZone.execute(new List<CalcDateTimeZone.Request>{ req }); 
        }
        DateTime dt = res[0].dateTimeOutput;
        system.assert(dt.hourGmt() == 7, 'Hours are offset by 7 hours'); //Arizona Time        
    }
    //test method with user and request with different timezone
    @isTest
    static void calculateDateTimeTestwithDifferentZone() {
        //create test user with profile as standard user
         list<user> standardUsers = [select name from user where email = 'testxyz123user1@capgemini.com'];
        User standardUser;
        if(!standardUsers.isEmpty()){
            standardUser = standardUsers[0];
        }
        Date inputDate = Date.today();
        Time inputTime = Time.newInstance(0,0,0,0); 
        
        List<CalcDateTimeZone.Response> res = null; 
        System.runAs(standardUser) {
            CalcDateTimeZone.Request req = new CalcDateTimeZone.Request();
            req.dateInput = Date.today();
            req.hourInput = 0;
            req.minutesInput = 0;
            req.timeZoneInput = 'America/Chicago';
            res = CalcDateTimeZone.execute(new List<CalcDateTimeZone.Request>{ req }); 
        }
        DateTime dt = res[0].dateTimeOutput;
        system.assert(dt.hourGmt() == 5, 'Hours are offset by 5 hours'); //Chicago Time  
    }
}