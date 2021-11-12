trigger Trip_Request_Calendar_Trigger on Trip__c (after insert, after update) {
     list<event> newEvents = new list<event>();
     list<event> newEvents1 = new list<event>();
      list<event> newEvents2 = new list<event>();
       list<event> deleteEvents = new list<event>();
     string salesOpsCalendar = 'Ops Calendar';

     for (Trip__c tRequest : System.Trigger.new) {
      
     newEvents1 = [select id from event where whatid =: tRequest.id];
         try {
         if (Trigger.isinsert == true && tRequest.Trip_Start_date__c != null && tRequest.Trip_End_date__c != null 
          && trequest.trip_request_status__c == 'submitted' && newEvents1.size() == 0)      
          
             newEvents.add(new Event(           
                 OwnerId = tRequest.OwnerId, 
                 StartDateTime = tRequest.Trip_Start_date__c,
                 EndDateTime = tRequest.Trip_Start_date__c,
                 IsAllDayEvent = true,
                 whatid = tRequest.id,
                 CEC_Account__c = trequest.Account_Name__r.name,
                 CEC_Location__c = trequest.trip_location__c,
                 CEC_Status__c = trequest.trip_request_status__c,
                 Subject = 'CEC Visit'
               )
              );
         integer count = tRequest.Trip_Start_date__c.daysBetween(tRequest.Trip_End_date__c);
         for (integer i = 0; i<= count-1; i++){
         list <date> dates = new list<date>();
         if (Trigger.isinsert == true && tRequest.Trip_Start_date__c != null && tRequest.Trip_End_date__c != null 
          && trequest.trip_request_status__c == 'submitted' && newEvents1.size() == 0) 
             newEvents.add(new Event(
                 
                 //  How do I convert 'Ops Calendar' to an id that owns our shared calendar?                 
                 OwnerId = tRequest.OwnerId, 
                 StartDateTime = tRequest.Trip_Start_date__c.addDays(i+1),
                 EndDateTime = tRequest.Trip_Start_date__c.addDays(i+1),
                 IsAllDayEvent = true,
                 whatid = tRequest.id,
                 CEC_Account__c = trequest.Account_Name__r.name,
                 CEC_Location__c = trequest.trip_location__c,
                 CEC_Status__c = trequest.trip_request_status__c,
                 Subject = 'CEC Visit'
               )
              );
              }

         }
         catch(Exception e){
             system.debug(e);
         }
     } 
     
    // insert newEvents;
     if (Trigger.isupdate == true)
     for (Trip__c tRequestu : System.Trigger.new) {
    
     newEvents2 = [select id from event where whatid =: tRequestu.id];
     Trip__c beforeUpdate2 = System.Trigger.oldMap.get(tRequestu.Id);
     Try{
     if (newEvents2.size() != 0 && (tRequestu.Trip_Start_date__c != beforeUpdate2.Trip_Start_date__c 
          || tRequestu.Trip_End_date__c != beforeUpdate2.Trip_End_date__c))
          for (event de: newEvents2){
         deleteevents.add(de);
         }
         delete deleteevents;
         }
         catch(Exception e){
             system.debug(e);
         }
          //Trip__c beforeUpdate2 = System.Trigger.oldMap.get(tRequestu.Id);
         try {
         if ( tRequestu.Trip_Start_date__c != null && tRequestu.Trip_End_date__c != null 
          && trequestu.trip_request_status__c == 'submitted' 
          && (tRequestu.Trip_Start_date__c != beforeUpdate2.Trip_Start_date__c 
          || tRequestu.Trip_End_date__c != beforeUpdate2.Trip_End_date__c))      
          
             newEvents.add(new Event(           
                 OwnerId = tRequestu.OwnerId, 
                 StartDateTime = tRequestu.Trip_Start_date__c,
                 EndDateTime = tRequestu.Trip_Start_date__c,
                 IsAllDayEvent = true,
                 whatid = tRequestu.id,
                 CEC_Account__c = trequestu.Account_Name__r.name,
                 CEC_Location__c = trequestu.trip_location__c,
                 CEC_Status__c = trequestu.trip_request_status__c,
                 Subject = 'CEC Visit'
               )
              );
         integer count1 = tRequestu.Trip_Start_date__c.daysBetween(tRequestu.Trip_End_date__c);
         for (integer i = 0; i<= count1-1; i++){
         list <date> dates = new list<date>();
          if ( tRequestu.Trip_Start_date__c != null && tRequestu.Trip_End_date__c != null 
          && trequestu.trip_request_status__c == 'submitted' 
          && (tRequestu.Trip_Start_date__c != beforeUpdate2.Trip_Start_date__c 
          || tRequestu.Trip_End_date__c != beforeUpdate2.Trip_End_date__c)) 
             newEvents.add(new Event(
                 
                 //  How do I convert 'Ops Calendar' to an id that owns our shared calendar?                 
                 OwnerId = tRequestu.OwnerId, 
                 StartDateTime = tRequestu.Trip_Start_date__c.addDays(i+1),
                 EndDateTime = tRequestu.Trip_Start_date__c.addDays(i+1),
                 IsAllDayEvent = true,
                 whatid = tRequestu.id,
                 CEC_Account__c = trequestu.Account_Name__r.name,
                 CEC_Location__c = trequestu.trip_location__c,
                 CEC_Status__c = trequestu.trip_request_status__c,
                 Subject = 'CEC Visit'
               )
              );
              }

         }
         catch(Exception e){
             system.debug(e);
         }
     } 
     
     insert newEvents;
     
     
     if(Trigger.isupdate == true )
     for (Trip__c tuRequest : System.Trigger.new) {
     
     Trip__c beforeUpdate = System.Trigger.oldMap.get(tuRequest.Id);
      if(Trigger.isupdate == true && beforeUpdate.trip_request_status__c != tuRequest.trip_request_status__c)
             
             {
             list <event> uEvents = [select id from event where whatid =:turequest.id];
             list <event> uEvents1 = new list<event>();
             for (event u: uEvents){
             
             u.CEC_Status__c = turequest.trip_request_status__c;
             update u;
             }
             
             }
             }
   List<Trip__c> tripList = new List<Trip__c>();          
for (Trip__c tRequest1 : System.Trigger.new) {

if ((Trigger.isinsert == true && trequest1.opportunity__c != null) )
{
opportunity opp =[select id, accountid from opportunity where id =: trequest1.opportunity__c limit 1];
 Trip__c trip = new Trip__c(id = tRequest1.id, account_name__c = opp.accountid);
        
tripList.add(trip);
    }
    }


  if(Trigger.isupdate == true )
for (Trip__c tRequest2 : System.Trigger.new) {
Trip__c beforeUpdate1 = System.Trigger.oldMap.get(tRequest2.Id);
if (beforeUpdate1.opportunity__c !=tRequest2.opportunity__c)
{
 opportunity opp1 =[select id, accountid from opportunity where id =: trequest2.opportunity__c limit 1];
 Trip__c trip1 = new Trip__c(id = tRequest2.id, account_name__c = opp1.accountid);
        
tripList.add(trip1);
 }
 }
     if(tripList.size()>0)
    update tripList;
}