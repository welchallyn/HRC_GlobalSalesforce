public with sharing class OpportunityLookupController {

    public Opportunity opportunity {get;set;}   // new opportunity to create
    public List<Opportunity> results{get;set;}  // search results
    public string searchString{get;set;}        // search keyword
    public Id clinicalProgramId{get;set;}       // clinical program Id

    public OpportunityLookupController() {
        opportunity = new Opportunity();
                
        // get the current search string
        searchString = System.currentPageReference().getParameters().get('lksrch');
        clinicalProgramId = System.currentPageReference().getParameters().get('oppId');

        System.debug('SCS: Parameters - lksrch = ' + searchString + ' , oppId = ' + clinicalProgramId);

        runSearch();
    }
    
    // performs the keyword search
    public PageReference search() {
        runSearch();
        return null;
    }

    // prepare the query and issue the search command
    private void runSearch() {
    // TODO prepare query string for complex serarches & prevent injections
    results = performSearch(searchString);
    }
    // run the search and return the records found.
    private List<Opportunity> performSearch(string searchString) {

        
        Id actId = [SELECT AccountId FROM Opportunity WHERE Id = :clinicalProgramId LIMIT 1].AccountId;

        System.debug('SCS: Account ID = ' + actId);

        String soql = 'SELECT Id, Name, Account.Name, Amount FROM Opportunity ';

        List<Id> recordTypeIds = new List<Id>();
        recordTypeIds.add(RecordTypeUtil.getRecordTypeIdByName('Opportunity', 'Capital'));
        recordTypeIds.add(RecordTypeUtil.getRecordTypeIdByName('Opportunity', 'HITS'));
        recordTypeIds.add(RecordTypeUtil.getRecordTypeIdByName('Opportunity', 'LIKO'));
        recordTypeIds.add(RecordTypeUtil.getRecordTypeIdByName('Opportunity', 'PSS Therapy Rental'));

        if ( actId != null && clinicalProgramId != null) {
            soql +=  ' WHERE RecordTypeId in :recordTypeIds ' ;
            //soql +=  ' WHERE RecordTypeId in :recordTypeIds and IsClosed = false and Id != \''+ clinicalProgramId + '\'' ;
            soql +=  ' AND AccountId = \'' + actId + '\'';
            if(!String.isEmpty(searchString))
                soql = soql + ' AND Name LIKE \'%' + String.escapeSingleQuotes(searchString) +'%\' ';

            soql +=  ' ORDER By LastModifiedDate desc, Name asc ' ;
        }
        
        soql = soql + ' LIMIT 50';
        System.debug('SCS: Query = ' + soql);

        return database.query(soql);
     
    }

    // used by the visualforce page to send the link to the right dom element
    public string getFormTag() {
        return System.currentPageReference().getParameters().get('frm');
    }
    // used by the visualforce page to send the link to the right dom element for the text box
    public string getTextBox() {
        return System.currentPageReference().getParameters().get('txt');
    } 
}