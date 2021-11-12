/************************************************************************************************************
 * Name                             : CalcDateTimeZone
 * Author                           : Johnny
 * Date                             : July/4/2020
 * Requirement/Project Name         : Hill-Rom
 * Requirement/Project Description  : SE-30 Class to be called via flow (Shift Manager)
 *                                    for Calculting date/time based on user timezone
 *                                   
 * Revison                          :
/*************************************************************************************************************/
global class CalcDateTimeZone {
    @InvocableMethod(
        label = 'Date/Time Converter'
        description = 'Converts date and time or date/time values to a date/time value in the specified timezone'
    )
    /************************************************************************************************************
     * Method Name                      : execute
     * Author                           : Johnny
 	 * Date                             : July/6/2020
	 * Description                      : Converts date and time or date/time values to a date/time value in the
	 * 									  specified timezone
	/*************************************************************************************************************/
    global static List<Response> execute( List<Request> requests ) {
        List<Response> responses = new List<Response>();
        for ( Request req : requests ) {
            Response res = new Response();
            Datetime dateTimeConstructor = null;
            if (req.dateTimeInput == null) {
                Time timeConstructor = Time.newInstance(req.hourInput, req.minutesInput, 00, 000);
                dateTimeConstructor = DateTime.newInstance(req.dateInput, timeConstructor);
            } else  {
                dateTimeConstructor = DateTime.newInstance(req.dateInput, req.dateTimeInput.time());
            }
            if (Userinfo.getTimeZone().getID() == req.timeZoneInput) {
                res.dateTimeOutput = dateTimeConstructor;
            } else {
                string dateTimeStr = dateTimeConstructor.format('yyyy-MM-dd HH:mm:ss',  req.timeZoneInput);
                Datetime localDateTime = DateTime.valueOf(dateTimeStr);
                Long milliSecDiff =  dateTimeConstructor.getTime() - localDateTime.getTime();
                Long minDiff = milliSecDiff / 1000 / 60;
                Datetime outDateTime = dateTimeConstructor.addMinutes(minDiff.intValue());
                res.dateTimeOutput = outDateTime;
            }
            responses.add( res );
        }
        return responses;
    }
     /************************************************
     * Inner Class for holding Request Wrapper class
     ************************************************/
    global class Request {
        @InvocableVariable(
            label = 'Date'
            description = 'Date only value'
            required = true
        )
        global Date dateInput;
        
        @InvocableVariable(
            label = 'Hour'
            description = 'Alternative to Date/Time'
            required = false
        )
        global Integer hourInput;
        
        @InvocableVariable(
            label = 'Minutes'
            description = 'Alternative to Date/Time'
            required = false
        )
        global Integer minutesInput;
        
        @InvocableVariable(
            label = 'Date/Time'
            description = 'Alternative to Hours & Minutes'
            required = false
        )
        global Datetime dateTimeInput;
        
        @InvocableVariable(
            label = 'Time Zone'
            required = true
        )
        global String timeZoneInput;
    }
    /************************************************
     * Inner Class for holding Response Wrapper class
     ************************************************/
    global class Response {
        @InvocableVariable(
            label = 'Date/Time'
            description = 'Returned local date/time value'
        )
        global Datetime dateTimeOutput;
    }          
}