public class HRCSVC20_Quote_Create_PDF_Controller {
    public PageReference pdfPage;
    public  id quoteId{get;set;}
    public String getquoteId(){return quoteid;}
    
    public void setquoteId(Id quoteId)
    {
        this.quoteId= quoteId;
    }   
    
    public HRCSVC20_Quote_Create_PDF_Controller(ApexPages.standardController sc) { 
        system.debug('idiiss'+(id)sc.getRecord().id);
        quoteid= (id)sc.getRecord().id;
        Quote quo = [select id,opportunityid from quote where id=:quoteid];
        initialize(quoteid);
    }
    
    public PageReference initialize(id oppId){    
        pdfPage = new PageReference('/apex/HRCSVC20_Quote_Generate_PDF?id='+ oppId);
        pdfPage.setRedirect(true);
        return pdfPage;
    } 
    
    public PageReference savePDF() { 
        createPDF(quoteId);
        pdfPage = new PageReference('/'+quoteId);
        pdfPage.setRedirect(true);
        return pdfPage;
    }
    
    @future(callout=true)
    public static void createPDF(id quoteId){
       PageReference pg = new PageReference('/apex/HRCSVC20_Quote_Generate_PDF?id='+quoteId) ;
        QuoteDocument quotedoc = new QuoteDocument(); 
        Blob b = pg.getContentAsPDF();
        quotedoc.Document = b;
        quotedoc.QuoteId = quoteId ;
        insert quotedoc;
    }
   
    public String returnurl {
        get{
            system.debug('id==== '+'/apex/HRCSVC20_Quote_Generate_PDF?id='+quoteId);
            return '/apex/HRCSVC20_Quote_Generate_PDF?id='+quoteId;
        }
        set{}
    }
}