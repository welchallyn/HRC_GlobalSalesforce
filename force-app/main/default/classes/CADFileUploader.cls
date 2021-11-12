public class CADFileUploader 
{
    public string nameFile{get;set;}
    public Blob contentFile{get;set;}
    String currentRecordId;
    String[] filelines = new String[]{};
    List<String> productNames;
    
   //Instance of the Flow
    public Flow.Interview.File_Upload_Flow_Create_Config_from_CAD_File myFlow {get; set;}
   
    //This function reads the CSV file and creates a list of file contents.

    public Pagereference ReadFile()
    {
        try{
                //Convert the uploaded file which is in BLOB format into a string
                nameFile =blobToString( contentFile,'ISO-8859-1');
               
                //Now sepatate every row of the excel file
                filelines = nameFile.split('\n');
               
                //Iterate through every line and add item to list object for each row
                productNames = new List<String>();
                for (Integer i=1;i<filelines.size();i++)
                {
                    String[] inputvalues = new String[]{};
                    inputvalues = filelines[i].split(',');
                    productNames.add(inputvalues[0] + '|@|' + inputvalues[1] + '|$|' + inputvalues[2] + '|%|' + inputvalues[3]);
                }
         }
         catch(Exception e){
                ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured reading the CSV file'+e.getMessage());
                ApexPages.addMessage(errormsg);
         }
                
        //Call workflow
        try{
              Map<String, Object> myMap = new Map<String, Object>();
              currentRecordId  = ApexPages.CurrentPage().getparameters().get('Id');
              myMap.put('inputQuoteId', currentRecordId);
              myMap.put('cadItems', productNames);
              myFlow = new Flow.Interview.File_Upload_Flow_Create_Config_from_CAD_File(myMap);
              myFlow.start();
              if (myFlow.getVariableValue('workflowErrorMessage') == null){
                  ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.CONFIRM,'File Upload Successful');
                  ApexPages.addMessage(errormsg);
              }
              else {          
                  ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'File Upload Unsuccessful - ' + myFlow.getVariableValue('workflowErrorMessage'));
                  ApexPages.addMessage(errormsg);
              }    
                }
        catch (Exception e)
        {
            ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured inserting the records'+e.getMessage());
            ApexPages.addMessage(errormsg);
        }   
        return null;
    }

        public static String blobToString(Blob input, String inCharset){
            String hex = EncodingUtil.convertToHex(input);
            System.assertEquals(0, hex.length() & 1);
            final Integer bytesCount = hex.length() >> 1;
            String[] bytes = new String[bytesCount];
            for(Integer i = 0; i < bytesCount; ++i)
                bytes[i] =  hex.mid(i << 1, 2);
            return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
        }
}