/******************************************************************************************************
* Name                             : HRCSVC_GetRandomNumberNew_Test
* Author                           : Capgemini
* Date                             : February/18/2021
* Requirement/Project Name         : Hill-Rom
* Requirement/Project Description  :  Class to
*                                   1. Test class for HRCSVC_GetRandomNumberNew_Test for #SE-1191
* Revison                          :
/*****************************************************************************************************/
@isTest
public class HRCSVC_GetRandomNumberNew_Test {
    @isTest
    public static void flowTest(){
        Double num = 20.0;
        Map<String, Object> inputParams = new Map<String, Object>();
        inputParams.put('randomNumber', num);
        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        GetRandomNumberNew plugin = new GetRandomNumberNew();
        plugin.invoke(request);
        Process.PluginDescribeResult result = plugin.describe();
    }
    
}