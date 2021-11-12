public class PaginationController {

    public Integer noOfRecordsPerPage {get; set;}    //No: of Records to be displayed on the page
    public Integer selectedPage {get; set;}    //The page selected by the user in the picklist
    public Map<Integer, List<PendingApprovalRecord>> mapPendingApprovalRecords {get; set;}    //contains mappings of page and corresponding approval records
    public List<SelectOption> pageOptions {get; set;}    // list of page labels and corresponding page values
    public List<PendingApprovalRecord> pagePendingApprovals {get; set;}    //current pending approval records to be displayed
    
    public PaginationController(ItemsToApproveController controller) {
        // Get the no: of records per page from Custom Settings. Handle the exception that may raise if the number is in incorrect format 
        try{
            HillRom_Settings__c NoOfRecordsPerPagename = HillRom_Settings__c.getValues('NoOfRecordsPerPage');
            NoOfRecordsPerPage = Integer.valueOf(NoOfRecordsPerPageName.Value__c.trim());
            System.debug('NoOfRecordsPerPage:'+ NoOfRecordsPerPage);
        }
        catch(Exception e){
            System.debug('Pagination error:' + e);
            ApexPages.Message error = new ApexPages.Message(ApexPages.Severity.ERROR, 'Some error occured.Please contact your administrator');
            ApexPages.addMessage(error);
            return;
        }                
        selectedPage = 1;    //default the initial selection of page to 1
        mapPendingApprovalRecords = new Map<Integer, List<PendingApprovalRecord>>();
        List<PendingApprovalRecord> listPendingApprovalRecords = controller.queryPendingApprovalRecords();    
        System.debug('Pending approvals size:'+listPendingApprovalRecords.size());
        Integer totalNoOfPages;
        // Formulate the total no: of pages required based on no: of records per page 
        if(listPendingApprovalRecords.size() > 0) {
            pageOptions = new List<SelectOption>();
            totalNoOfPages = listPendingApprovalRecords.size()/noOfRecordsPerPage;
            if(Math.mod(listPendingApprovalRecords.size(), noOfRecordsPerPage) > 0) {
                totalNoOfPages = totalNoOfPages + 1;
            }
        }
        System.debug('totalNoOfPages: '+totalNoOfPages);

        // Populate Initial PageStartvalue and PageEndValue for putting those records in the map
        Integer pageStartValue = 0;
        Integer pageEndValue;
        if(listPendingApprovalRecords.size() >= noOfRecordsPerPage) {
            pageEndValue = noOfRecordsPerPage;
            System.debug('Inside if->PageEndValue:'+pageEndValue);
        }
        else {
            pageEndValue = Math.mod(listPendingApprovalRecords.size(), noOfRecordsPerPage);    
            System.debug('Inside else->PageEndValue:'+pageEndValue);
        }
        System.debug('PageEndValue:'+pageEndValue);

        //Populate the map for all the pages with key as the pageno: and value as the list of those pending approval records
        for(Integer i=0; i<totalNoOfPages; i++) {
            Integer counter = i+1;
            pageOptions.add(new SelectOption(counter+'',counter+''));
            List<PendingApprovalRecord> pendingApprovalRecordsList = new List<PendingApprovalRecord>();
            for(Integer j=pageStartValue; j<pageEndValue; j++) {
                pendingApprovalRecordsList.add(listPendingApprovalRecords[j]);
                System.debug('J####: '+j);
            }
            pageStartValue = pageEndValue;
            System.debug('PageStart Value Reloaded: '+pageStartValue );
            if( i != totalNoOfPages - 2) {
                pageEndValue = noOfRecordsPerPage * (i+2);
                System.debug('Inside If->PageEnd Value Reloaded: '+pageEndValue );
            }
            else {
                if(Math.mod(listPendingApprovalRecords.size(), noOfRecordsPerPage) == 0)
                    pageEndValue = (noOfRecordsPerPage*(i+1)) + noOfRecordsPerPage ;
                else
                    pageEndValue = (noOfRecordsPerPage*(i+1)) + Math.mod(listPendingApprovalRecords.size(), noOfRecordsPerPage);
                
                System.debug('Inside else->PageEnd Value Reloaded: '+pageEndValue );
            }
            mapPendingApprovalRecords.put(counter, pendingApprovalRecordsList);
        }

        //Initiate the list "pagePendingApprovals with the selectedpage value
        pagePendingApprovals =  mapPendingApprovalRecords.get(selectedPage); 
        System.debug('mapPendingApprovalRecords:'+mapPendingApprovalRecords);
        System.debug('pagePendingApprovals: '+pagePendingApprovals );
    }
    
    //Consequent page selections will invoke the function to reflect the corresponding records
    public void nextPage() {
        pagePendingApprovals = mapPendingApprovalRecords.get(selectedPage); 
    }    
}