@IsTest(SeeAllData=true)
private class CADFileUploader_TestMethod
{

     static testmethod void testfileupload(){
         StaticResource testdoc = [Select Id,Body from StaticResource where name ='cadTestFile'];
         CADFileUploader  testUpload = new CADFileUploader();
         testUpload.contentFile= testdoc.Body;
         testUpload.ReadFile();
     }
}