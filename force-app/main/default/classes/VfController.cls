public class VfController {
    private final Opportunity o;
    public VfController(ApexPages.StandardController stdController) {
        this.o = (Opportunity) stdController.getRecord();
    }

    public PageReference autoRun() {

        String theId = ApexPages.currentPage().getParameters().get('id');

        if (theId == null) {
            // Display the Visualforce page's content if no Id is passed over
            return null;
        }

        Opportunity o = [select id, CreatedDate, CloseDate, Proposal_Number__c from Opportunity where id =: theId];
        // code to delete Opportunity Line items 
        if (o.Proposal_Number__c == Null) {
            PageReference pageRef = Page.EnterProposalNumber;
            pageRef.setRedirect(true);


            return pageRef;

        }

        try {

            JDE_Prop__c p = [Select Id, Name from JDE_Prop__c where Name =: o.Proposal_Number__c];
            if (o.Proposal_Number__c == p.Name) {

                List < OpportunityLineItem > oldLineItems = [Select id from OpportunityLineItem where opportunityId =: o.Id];
                delete oldLineItems;
            }
        } catch (QueryException e) {
            // Redirect the user back to the original page
            PageReference pageRef = Page.InvalidProposalNumber;
            pageRef.setRedirect(true);
            return pageRef;
        } catch (DMLException e) {

        }
        List < OpportunityLineItem > lstOppLine = new List < OpportunityLineItem > ();
        // Inserting the new products from Proposal Line item
        try {
            JDE_Prop__c p = [Select Id, Name from JDE_Prop__C where Name =: o.Proposal_Number__c];

            //Querying the Valid Proposal Line items

            List < JDE_Prop_Ln_Item__c > lstProposalLine = [Select id, Proposal__c, Quantity__c, Sys_discount__c, Package_Options__c,
                Package_code__c, Item_Description__c, Extended_Line_Amount__c, List_price__c, Price__c
                from JDE_Prop_Ln_Item__c where Parent_Line__c = null and Package_code__c != null and Proposal__c =: p.Id
            ];

            //Collecting all the package code of Valid Proposal Line items in the set

            Set < String > codeSet = new Set < String > ();
            for (JDE_Prop_Ln_Item__c Proposalline: lstProposalLine) {
                codeSet.add(Proposalline.Package_code__c);
            }

            //Selecting all the products on the collected package code

            list < Product2 > p2 = [select Package_code__c, Lead_Time__c from product2 where package_code__c in: codeSet and(NOT Family like 'APTtus_%')];

            //Creating a map of Id's and products called product map

            Map < Id, Product2 > productMap = new Map < ID, Product2 > ([select id, Package_code__c from Product2 where
                package_code__c in: codeSet and(NOT Family like 'APTtus_%')
            ]);

            Map < String, Product2 > packageCodeProduct2Map = new Map < String, Product2 > ();

            //Creating a Map of Valid Package code and Products

            for (Product2 prod: productMap.values()) {
                packageCodeProduct2Map.put(prod.Package_code__c, prod);

            }
            /* 
      
       Map<String, List<JDE_Prop_Ln_Item__c>> ProposalProposalLineItemMap = new   Map<String, List<JDE_Prop_Ln_Item__c>>();
    List<JDE_Prop_Ln_Item__c> ProposalLineItemList = null;
    system.debug('####$$$$$$$$$$'+lstProposalLine);
    for (JDE_Prop_Ln_Item__c pli : lstProposalLine ) {

         if (ProposalProposalLineItemMap.containsKey(pli.Proposal__c)) {
           ProposalProposalLineItemMap.get(pli.Proposal__c).add(pli);
         } else {
            ProposalLineItemList = new List<JDE_Prop_Ln_Item__c>();
            ProposalLineItemList.add(pli);
           ProposalProposalLineItemMap.put(pli.Proposal__c, ProposalLineItemList);
         }
         
      }
      */

            //Querying Pricebookentry  

            List < PriceBookEntry > lstPbeId = [select Id, Product2Id, CurrencyIsoCode from PriceBookEntry where CurrencyIsoCode = 'usd'
                and isactive = true and Pricebook2id = '01sE0000000HpytIAC' and Product2Id in: productMap.keySet()
            ];

            Map < String, List < PriceBookEntry >> prodPriceBookMap = new Map < String, List < PriceBookEntry >> ();
            List < PriceBookEntry > pbeList = null;
            for (PriceBookEntry pbe: lstPbeId) {
                if (prodPriceBookMap.containsKey(pbe.product2ID)) {
                    prodPriceBookMap.get(pbe.product2ID).add(pbe);
                } else {
                    pbeList = new List < PriceBookEntry > ();
                    pbeList.add(pbe);
                    prodPriceBookMap.put(pbe.product2ID, pbeList);
                }

            }
            List < PriceBookEntry > ProposalPBEList = null;
            for (JDE_Prop_Ln_Item__c prl: lstProposalLine)

            {
                // for each pricebook entry for each product_code in the order, create an oppporturni LI
                for (product2 pr: p2) {
                    if (prl.Package_code__c == pr.Package_code__c) {
                        system.debug('####$$$$$$$$$$' + pr.Package_code__c);

                        String productId = packageCodeProduct2Map.get(prl.Package_code__c).Id;
                        system.debug('####$$$$$$$$$$' + productId);
                        ProposalPBEList = prodPriceBookMap.get(productID);
                        system.debug('####$$$$$$$$$$' + ProposalPBEList);
                        for (PriceBookEntry pbe: ProposalPBEList) {
                            OpportunityLineItem opl = new OpportunityLineItem();
                            if (prl.Quantity__c != null)
                                opl.Quantity = prl.Quantity__c;
                            opl.OpportunityId = o.id;
                            //  opl.discount = prl.Sys_discount__c;
                            if (prl.Package_Options__c != null)
                                opl.Package_options__c = prl.Package_Options__c;
                            if (o.CloseDate != null && pr.Lead_Time__c != null)
                                opl.Line_Item_Ship_Date__c = o.CloseDate + pr.Lead_Time__c.intValue();
                            if (prl.Extended_Line_Amount__c != null)
                                opl.TotalPrice = prl.Extended_Line_Amount__c;
                            if (pbe.id != null)
                                opl.PricebookentryId = pbe.id;
                            if (prl.List_price__c != null)
                                opl.List_Price_edit__c = prl.List_price__c;


                            lstOppLine.add(opl);
                        }
                    }
                }
            }
            insert lstOppLine;

        } catch (QueryException e) {
            PageReference pageRef = Page.InvalidProposalNumber;
            pageRef.setRedirect(true);
            return pageRef;
        } catch (DMLException e) {

        }

        // Redirect the user back to the original page
        PageReference pageRef = new PageReference('/' + theId);
        pageRef.setRedirect(true);
        return pageRef;


    }
}