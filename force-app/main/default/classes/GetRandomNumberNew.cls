global class GetRandomNumberNew implements Process.Plugin { 

   global Process.PluginResult invoke(Process.PluginRequest request) { 
      Double num = (Double) Math.random();
      Map<String,Object> result = new Map<String,Object>();
      result.put('randomNumber', num);
      return new Process.PluginResult(result);
   }

   global Process.PluginDescribeResult describe() { 
      Process.PluginDescribeResult result = new Process.PluginDescribeResult(); 
      result.Name = 'Generate Random Number';
      result.Tag = 'Utility Classes';
      result.outputParameters = new 
         List<Process.PluginDescribeResult.OutputParameter>{              
            new Process.PluginDescribeResult.OutputParameter('randomNumber', 'Random decimal output',
            Process.PluginDescribeResult.ParameterType.Double)
         }; 
      return result; 
   }
}