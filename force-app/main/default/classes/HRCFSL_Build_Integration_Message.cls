public class HRCFSL_Build_Integration_Message
{
    public List<Id> WorkOrderIds;
    List<HRCFSL_Organization_Settings__mdt> orgSettings;
    public HRCFSL_Build_Integration_Message(List<Id> woIds)
    {
        WorkOrderIds = woIds;
        orgSettings = [select developername, HRCFSL_Component_Detail_Long__c from HRCFSL_Organization_Settings__mdt
                                                        where DeveloperName in ('HRCFSL_Work_Order_Integration_Fields', 'HRCFSL_Work_Order_Line_IntegrationFields',
                                                                                'HRCFSL_Product_ConsumedIntegrationFields','HRCFSL_Asset_Integration_Fields', 'HRCFSL_WO_Fields_On_Asset',
                                                                                'HRCFSL_Inspection_Integration_Fields')];
    }   
    public List<string> getMessages()
    {
        List<String> messageList = new List<String>();
        list<String> assetIds = new list<string>();
        for(workorder wo:[select id,AssetId from workorder where id in: workOrderIds and assetid <>null]){
            assetIds.add(wo.AssetId);
        }
        List<WorkOrder> workOrders;
        List<WorkOrderLineItem> workOrderLines;
        List<ProductConsumed> productConsumed;
        list<Asset> assetlst;
        List<WorkOrder> workOrderOnAsset;
        List<HRCFSL_Inspection_Step__c> inspectionSteps;
        //code line added on 7th April 2021
        string woQuery,woliQuery,productConsumedQuery,assetQuery,woOnAssetQuery,woInspectionStepQuery;
        /* To prevent running this soql in a loop, moved to the constructor
        for (HRCFSL_Organization_Settings__mdt fields: [select developername, HRCFSL_Component_Detail_Long__c from HRCFSL_Organization_Settings__mdt
                                                        where DeveloperName in ('HRCFSL_Work_Order_Integration_Fields', 'HRCFSL_Work_Order_Line_IntegrationFields',
                                                                                'HRCFSL_Product_ConsumedIntegrationFields','HRCFSL_Asset_Integration_Fields', 'HRCFSL_WO_Fields_On_Asset',
                                                                                'HRCFSL_Inspection_Integration_Fields')])
		*/
        for(HRCFSL_Organization_Settings__mdt fields: orgSettings)
        {
            if (fields.developername == 'HRCFSL_Work_Order_Integration_Fields'){
                woQuery = 'select AssetId,' + fields.HRCFSL_Component_Detail_Long__c + ' from workorder where id in: workorderids order by hrcfsl_jde_id__c asc';
                // workOrders = (List<WorkOrder>) database.query(woQuery);
            }
            else if (fields.DeveloperName == 'HRCFSL_Work_Order_Line_IntegrationFields'){
                woliQuery = 'select WorkOrderId,' + fields.HRCFSL_Component_Detail_Long__c + ' from workorderlineitem where workorderid in: workorderids';
                //workOrderLines = (List<WorkOrderLineItem>) database.query(woliQuery);
            }
            else if (fields.DeveloperName == 'HRCFSL_Product_ConsumedIntegrationFields'){
                productConsumedQuery = 'select WorkOrderId,' + fields.HRCFSL_Component_Detail_Long__c + ' from productconsumed where workorderid in: workorderids';
                // productConsumed = (List<ProductConsumed>) Database.query(productConsumedQuery);
            }
            else if (fields.DeveloperName == 'HRCFSL_Asset_Integration_Fields'){
                assetQuery = 'select ' + fields.HRCFSL_Component_Detail_Long__c + ' from Asset where id in: assetIds';
                // assetlst= (List<Asset>) Database.query(assetQuery);
            }
            else if (fields.DeveloperName == 'HRCFSL_WO_Fields_On_Asset'){
                woOnAssetQuery = 'select AssetId,' + fields.HRCFSL_Component_Detail_Long__c + ' from WorkOrder where id in: workorderids';
                // workOrderOnAsset= (List<WorkOrder>) Database.query(woOnAssetQuery);
            }
            else if (fields.DeveloperName == 'HRCFSL_Inspection_Integration_Fields'){
                woInspectionStepQuery = 'select HRCFSL_Work_Order__c, ' + fields.HRCFSL_Component_Detail_Long__c +
                    ' from HRCFSL_Inspection_Step__c where HRCFSL_Work_Order__c in: workorderids';
                // inspectionSteps = (List<HRCFSL_Inspection_Step__c>) Database.query(woInspectionStepQuery);
            }
        }
        //code line added on 7th April 2021
        workOrders = (List<WorkOrder>) database.query(woQuery);
        workOrderLines = (List<WorkOrderLineItem>) database.query(woliQuery);
        productConsumed = (List<ProductConsumed>) Database.query(productConsumedQuery);
        assetlst= (List<Asset>) Database.query(assetQuery);
        workOrderOnAsset= (List<WorkOrder>) Database.query(woOnAssetQuery);
        inspectionSteps = (List<HRCFSL_Inspection_Step__c>) Database.query(woInspectionStepQuery);
        for (WorkOrder currentWorkOrder : workOrders)
        {
            List<WorkOrderLineItem> currentLines = new List<WorkOrderLineItem>();
            List<ProductConsumed> currentPCs = new List<ProductConsumed>();
            List<Asset> currentAssets = new List<Asset>();
            List<HRCFSL_Inspection_Step__c> currentInspectionSteps = new List<HRCFSL_Inspection_Step__c>();
            WorkOrder workOrderAsset = null;
            for (WorkOrderLineItem line: workOrderLines)
                if (line.WorkOrderId == currentWorkOrder.Id)
                currentLines.add(line);
            for (ProductConsumed pc: productConsumed)
                if (pc.WorkorderId == currentWorkOrder.Id)
                currentPCs.add(pc);
            for (Asset ast : assetlst)
                if (ast.Id == currentWorkorder.AssetId)
                currentAssets.add(ast);
            for (WorkOrder woa : workOrderOnAsset)
                if (woa.Id == currentWorkOrder.Id)
                workOrderAsset = woa;
            for (HRCFSL_Inspection_Step__c step : inspectionSteps) {
                if (step.HRCFSL_Work_Order__c == currentWorkOrder.Id) {
                    currentInspectionSteps.add(step);
                }
            }
            String message = getXMLStructure(currentWorkOrder, currentLines, currentPCs,currentAssets, workOrderAsset, currentInspectionSteps);
            messageList.add(message);
        }
      
        /**** SE-2118 : Moved the below code to a new method getChildMessages ******
        List<Id> childWorkOrders = new List<Id>();       
        for (WorkOrder wo: [select id, parentworkorderid from workorder where parentworkorderid in: WorkOrderIds and id not in: WorkOrderIds]){
                childWorkOrders.add(wo.Id);
        }
        system.debug('childWorkOrders#='+childWorkOrders.size());
        if (childWorkOrders != null && childWorkOrders.size() != 0)
        {
            messageList.addAll(new HRCFSL_Build_Integration_Message(childWorkOrders).getMessages());
        }
		*/
        
        return messageList;
    }
    
    public List<string> getChildMessages()
    {
        List<String> messageList = new List<String>();
        List<Id> childWorkOrders = new List<Id>();       
        for (WorkOrder wo: [select id, parentworkorderid from workorder where parentworkorderid in: WorkOrderIds and id not in: WorkOrderIds]){
                childWorkOrders.add(wo.Id);
        }
        system.debug('childWorkOrders#='+childWorkOrders.size());
        if (childWorkOrders != null && childWorkOrders.size() != 0)
        {
            messageList.addAll(new HRCFSL_Build_Integration_Message(childWorkOrders).getMessages());
        }
		return messageList;
    }
    
    private static string getXMLStructure(WorkOrder wo, List<WorkOrderLineItem> wolis, List<ProductConsumed> pcs , List<Asset> asstlst, WorkOrder woa,
                                          List<HRCFSL_Inspection_Step__c> inspectionSteps)
    {
        Map<String, Object> woFields = wo.getPopulatedFieldsAsMap();
        DOM.Document doc = new DOM.Document();
        dom.XmlNode products = doc.createRootElement('root', null, null);
        dom.XmlNode body1= products.addChildElement('WorkOrder', null, null);
        for (String woField: woFields.keySet()){
            if(woFields.get(woField) instanceof DateTime){ // for testing needs to be updated for dynamic values
                body1.addChildElement(woField, null, null).addTextNode(((DateTime) woFields.get(woField)).format('yyyy-MM-dd\'T\'HH:mm:ss', 'GMT'));
            }else{
                body1.addChildElement(woField, null, null).addTextNode(string.valueof(woFields.get(woField)));
            }
        }
        dom.XmlNode header1 = body1.addChildElement('WorkOrderLineItems', null, null);
        dom.XmlNode body2;//= body1.addChildElement('WorkOrderLineItem', null, null);
        for (WorkOrderLineItem woli : wolis) {
            body2=header1.addChildElement('WorkOrderLineItem', null, null);
            Map<String, Object> woliFields = woli.getPopulatedFieldsAsMap();
            for (String woliField: woliFields.keySet()) {
                if (woliFields.get(woliField) instanceof DateTime)
                    body2.addChildElement(woliField, null, null).addTextNode(((DateTime) woliFields.get(woliField)).format('yyyy-MM-dd\'T\'HH:mm:ss', 'GMT')); //body3.addChildElement(pcField, null, null).addTextNode(((DateTime) pcFields.get(pcField)).format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
                else
                    body2.addChildElement(woliField, null, null).addTextNode(string.valueof(woliFields.get(woliField)));
            }
        }
        dom.XmlNode header2 = body1.addChildElement('ProductsConsumed', null, null);
        dom.XmlNode body3;//= body1.addChildElement('ProductConsumed', null, null);
        for (ProductConsumed pc : pcs) {
            body3= header2.addChildElement('ProductConsumed', null, null);
            Map<String, Object> pcFields = pc.getPopulatedFieldsAsMap();
            for (String pcField: pcFields.keySet()) {
                if (pcField == 'Id' || pcField == 'CurrencyIsoCode')
                    continue;
                if (pcFields.get(pcField) instanceof DateTime)
                    body3.addChildElement(pcField, null, null).addTextNode(((DateTime) pcFields.get(pcField)).format('yyyy-MM-dd\'T\'HH:mm:ss', 'GMT'));
                else
                    body3.addChildElement(pcField, null, null).addTextNode(string.valueof(pcFields.get(pcField)));
            }
        }
        dom.XmlNode header3 = body1.addChildElement('Assets', null, null);
        dom.XmlNode body4;//= body1.addChildElement('ProductConsumed', null, null);
        for (Asset ast : asstlst) {
            body4= header3.addChildElement('Asset', null, null);
            Map<String, Object> asFields = ast.getPopulatedFieldsAsMap();
            for (String asField: asFields.keySet()) {
                if (asFields.get(asField) instanceof DateTime)
                    body4.addChildElement(asField, null, null).addTextNode(((DateTime) asFields.get(asField)).format('yyyy-MM-dd\'T\'HH:mm:ss', 'GMT'));
                else
                    body4.addChildElement(asField, null, null).addTextNode(string.valueof(asFields.get(asField)));
            }
            Map<String, Object> woaFields = woa.getPopulatedFieldsAsMap();
            for (String woaField: woaFields.keySet())
            {
                if(woaFields.get(woaField) instanceof DateTime) // for testing needs to be updated for dynamic values
                    body4.addChildElement(woaField, null, null).addTextNode(((DateTime) woaFields.get(woaField)).format('yyyy-MM-dd\'T\'HH:mm:ss', 'GMT'));
                else
                    body4.addChildElement(woaField, null, null).addTextNode(string.valueof(woaFields.get(woaField)));
            }
        }
        //add a seciton for inspection step. only include those where input <> null
        dom.XmlNode header4 = body1.addChildElement('InspectionSteps', null, null);
        dom.XmlNode body5;
        for (HRCFSL_Inspection_Step__c step : inspectionSteps) {
            body5 = header4.addChildElement('InspectionStep', null, null);
            Map<String, Object> stepFields = step.getPopulatedFieldsAsMap();
            for (String stepField: stepFields.keySet()) {
                if (stepField == 'Id' || stepField == 'CurrencyIsoCode' || stepField == 'RecordTypeId')
                    continue;
                if (stepField == 'HRCFSL_Work_Order__c') {
                    body5.addChildElement('WorkOrderId', null, null).addTextNode(String.valueof(stepFields.get(stepField)));
                }
                else {
                    body5.addChildElement(stepField, null, null).addTextNode(String.valueof(stepFields.get(stepField)));
                }
            }
        }
        String xmlstring = doc.toXmlString();
        return xmlstring;
    }
}