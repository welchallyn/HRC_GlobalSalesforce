/*
    Name         : APTSCU_productDeepCloneController
    Author       : Sagar Jogi
    Created Date : 5th May 2015
    Description  : It will clone product's record with all related object's data.
    Used by      : APTSCU_productDeepCloning
*/


public with sharing class APTSCU_productDeepCloneController {
    
    public list<product2> productList = new list<product2>();
    
    product2 clonedProduct = new product2();
    String productID = ApexPages.currentPage().getParameters().get('id');
    
    public list<Apttus_Config2__PriceListItem__c> priceListItemsList = new list<Apttus_Config2__PriceListItem__c>();
    public list<Apttus_Config2__PriceListItem__c> clonedPriceListItemsList = new list<Apttus_Config2__PriceListItem__c>();
    Apttus_Config2__PriceListItem__c clonePriceListItem = new Apttus_Config2__PriceListItem__c();
    
    public list<Apttus_Config2__ProductClassification__c> productClassificationList = new list<Apttus_Config2__ProductClassification__c>();
    public list<Apttus_Config2__ProductClassification__c> clonedProductClassificationList = new list<Apttus_Config2__ProductClassification__c>();
    Apttus_Config2__ProductClassification__c clonedProductClassification = new Apttus_Config2__ProductClassification__c();
  
    public list<Apttus_Config2__ProductOptionGroup__c> productOptionGroupList = new list<Apttus_Config2__ProductOptionGroup__c>();
    public list<Apttus_Config2__ProductOptionGroup__c> clonedProductOptionGroupList  = new list<Apttus_Config2__ProductOptionGroup__c>();
    Apttus_Config2__ProductOptionGroup__c clonedProductOption = new Apttus_Config2__ProductOptionGroup__c();  
  
    public list<Apttus_Config2__ProductOptionComponent__c> productOptionComponentList= new list<Apttus_Config2__ProductOptionComponent__c>();
    public list<Apttus_Config2__ProductOptionComponent__c> clonedProductOptionComponentList = new list<Apttus_Config2__ProductOptionComponent__c>();
    Apttus_Config2__ProductOptionComponent__c clonedProductOptionComponent = new Apttus_Config2__ProductOptionComponent__c();   
    
    public list<Apttus_Config2__ProductConstraint__c> productConstraintList = new list<Apttus_Config2__ProductConstraint__c>();
    public list<Apttus_Config2__ProductConstraint__c> clonedProductConstraintList = new list<Apttus_Config2__ProductConstraint__c>();
    Apttus_Config2__ProductConstraint__c clonedProductConstraint = new Apttus_Config2__ProductConstraint__c();   
    
    public list<Apttus_Config2__ProductConstraintEntry__c> productConstraintEntryList = new list<Apttus_Config2__ProductConstraintEntry__c>();
    public list<Apttus_Config2__ProductConstraintEntry__c> clonedProductConstraintEntryList = new list<Apttus_Config2__ProductConstraintEntry__c>();
    Apttus_Config2__ProductConstraintEntry__c clonedProductConstraintEntry = new Apttus_Config2__ProductConstraintEntry__c(); 
    
    public list<Apttus_Config2__ConstraintRuleCondition__c> productConstraintConditionList = new list<Apttus_Config2__ConstraintRuleCondition__c>();
    public list<Apttus_Config2__ConstraintRuleCondition__c> clonedProductConstraintConditionList = new list<Apttus_Config2__ConstraintRuleCondition__c>();
    Apttus_Config2__ConstraintRuleCondition__c clonedProductConstraintCondition = new Apttus_Config2__ConstraintRuleCondition__c(); 
    
    public list<Apttus_Config2__ConstraintRuleAction__c> productConstraintActionList = new list<Apttus_Config2__ConstraintRuleAction__c>();
    public list<Apttus_Config2__ConstraintRuleAction__c> clonedProductConstraintActionList = new list<Apttus_Config2__ConstraintRuleAction__c>();
    Apttus_Config2__ConstraintRuleAction__c clonedProductConstraintAction = new Apttus_Config2__ConstraintRuleAction__c(); 
       
    public list<Apttus_Config2__SearchAttributeValue__c> productSearchAttributeList = new list<Apttus_Config2__SearchAttributeValue__c>();
    public list<Apttus_Config2__SearchAttributeValue__c> clonedProductSearchAttributeList = new list<Apttus_Config2__SearchAttributeValue__c>();
    Apttus_Config2__SearchAttributeValue__c clonedProductSearchAttribute = new Apttus_Config2__SearchAttributeValue__c(); 
    
    public list<Apttus_Config2__ProductGroupMember__c> productGroupMemberList = new list<Apttus_Config2__ProductGroupMember__c>();
    public list<Apttus_Config2__ProductGroupMember__c> clonedProductGroupMemberList = new list<Apttus_Config2__ProductGroupMember__c>();
    Apttus_Config2__ProductGroupMember__c clonedProductGroupMember = new Apttus_Config2__ProductGroupMember__c(); 
    
    public list<Apttus_Config2__ProductAttributeGroupMember__c> productAttributeGroupMemberList = new list<Apttus_Config2__ProductAttributeGroupMember__c>();
    public list<Apttus_Config2__ProductAttributeGroupMember__c> clonedProductAttributeGroupMemberList = new list<Apttus_Config2__ProductAttributeGroupMember__c>();
    Apttus_Config2__ProductAttributeGroupMember__c clonedProductAttributeGroupMember  = new Apttus_Config2__ProductAttributeGroupMember__c(); 
    
    public list<Apttus_Config2__ProductInformation__c> productInformationList = new list<Apttus_Config2__ProductInformation__c>();
    public list<Apttus_Config2__ProductInformation__c> clonedProductInformationList = new list<Apttus_Config2__ProductInformation__c>();
    Apttus_Config2__ProductInformation__c clonedProductInformation  = new Apttus_Config2__ProductInformation__c(); 
    
    public list<Apttus_Config2__PriceMatrix__c> priceMatrixList = new List<Apttus_Config2__PriceMatrix__c>();
    public list<Apttus_Config2__PriceMatrix__c> clonedPriceMatrixList = new List<Apttus_Config2__PriceMatrix__c>();
    Apttus_Config2__PriceMatrix__c clonedPriceMatrix = new Apttus_Config2__PriceMatrix__c();
    
    public list<Apttus_Config2__PriceMatrixEntry__c> priceMatrixEntryList = new List<Apttus_Config2__PriceMatrixEntry__c>();
    public list<Apttus_Config2__PriceMatrixEntry__c> clonedPriceMatrixEntryList  = new List<Apttus_Config2__PriceMatrixEntry__c>();
    Apttus_Config2__PriceMatrixEntry__c clonedPriceMatrixEntry= new Apttus_Config2__PriceMatrixEntry__c();
    
    
    String queryString;
    
    public PageReference redirect(){
        //Product Cloning
        queryString = getQueryStringWithAllFields('product2', 'Id =:productID' );
        productList = Database.query(queryString );
        clonedProduct = productList[0].clone(false,true);
        clonedProduct.Name = clonedProduct.Name  + ' -Clone';
        if(clonedProduct != null) {
            insert clonedProduct;
        }
        
        //Pricelist Item Cloning  
        queryString = getQueryStringWithAllFields('Apttus_Config2__PriceListItem__c','Apttus_Config2__ProductId__c=:productID');
        priceListItemsList = Database.query(queryString );
        
        for(Apttus_Config2__PriceListItem__c pricelistItem : priceListItemsList) {
            clonePriceListItem = pricelistItem.clone(false,true);
            clonePriceListItem.Apttus_Config2__ProductId__c = clonedProduct.id;
            insert clonePriceListItem;
           
            string priceListItemId = pricelistItem.id;
            queryString = getQueryStringWithAllFields('Apttus_Config2__PriceMatrix__c','Apttus_Config2__PriceListItemId__c=:priceListItemId');
            priceMatrixList = Database.query(queryString );
            
            for(Apttus_Config2__PriceMatrix__c pMatrix: priceMatrixList) {
                clonedPriceMatrix = pMatrix.clone(false,true);
                clonedPriceMatrix.Apttus_Config2__PriceListItemId__c = clonePriceListItem.id;
                insert clonedPriceMatrix;
                
                string pMatrixId = pMatrix.id;
                queryString = getQueryStringWithAllFields('Apttus_Config2__PriceMatrixEntry__c','Apttus_Config2__PriceMatrixId__c=:pMatrixId ');
                priceMatrixEntryList = Database.query(queryString );
                
                for(Apttus_Config2__PriceMatrixEntry__c pMEntry :priceMatrixEntryList ) {
                    clonedPriceMatrixEntry = pMEntry.clone(false,true);
                    clonedPriceMatrixEntry.Apttus_Config2__PriceMatrixId__c = clonedPriceMatrix.id;
                    clonedPriceMatrixEntryList.add(clonedPriceMatrixEntry);
                }
            }
            //clonedPriceListItemsList.add(clonePriceListItem);
        }
        
        /*
        if(clonedPriceListItemsList.size() > 0) {
            insert clonedPriceListItemsList;
        }*/
        
        if(clonedPriceMatrixEntryList.size() > 0) {
            insert clonedPriceMatrixEntryList;
        }
        
        //Product classification cloning
        queryString = getQueryStringWithAllFields('Apttus_Config2__ProductClassification__c','Apttus_Config2__ProductId__c=:productID');
        productClassificationList = Database.query(queryString );
        
        for(Apttus_Config2__ProductClassification__c productClassification : productClassificationList) {
            clonedProductClassification = productClassification.clone(false,true);
            clonedProductClassification.Apttus_Config2__ProductId__c = clonedProduct.id;
            clonedProductClassificationList.add(clonedProductClassification);
        }
        if(clonedProductClassificationList.size() > 0) {
            insert clonedProductClassificationList;
        }
      
        //Product Option Group Cloning
        queryString = getQueryStringWithAllFields('Apttus_Config2__ProductOptionGroup__c','Apttus_Config2__ProductId__c=:productID');
        productOptionGroupList = Database.query(queryString );
        
        for(Apttus_Config2__ProductOptionGroup__c productOptionGroup : productOptionGroupList ) {
            clonedProductOption = productOptionGroup.clone(false,true);
            clonedProductOption.Apttus_Config2__ProductId__c = clonedProduct.id;
            if (clonedProductOption != null) {
                insert clonedProductOption;
            }
            
            
            //Product Option Component Cloning
            String productOptionGroupId = productOptionGroup.id;
            queryString = getQueryStringWithAllFields('Apttus_Config2__ProductOptionComponent__c','Apttus_Config2__ProductOptionGroupId__c=:productOptionGroupId AND Apttus_Config2__ParentProductId__c=:productID');
            productOptionComponentList = Database.query(queryString );
            
            for(Apttus_Config2__ProductOptionComponent__c productOptionComponent : productOptionComponentList) {
                clonedProductOptionComponent = productOptionComponent.clone(false,true);
                clonedProductOptionComponent.Apttus_Config2__ParentProductId__c = clonedProduct.id;
                clonedProductOptionComponent.Apttus_Config2__ProductOptionGroupId__c = clonedProductOption.id;
                clonedProductOptionComponentList.add(clonedProductOptionComponent );
            }            
            
        }
  
        if(clonedProductOptionComponentList.size() > 0) {
            insert clonedProductOptionComponentList ;
        }  
             
        //Product Constraint Cloning
        queryString = getQueryStringWithAllFields('Apttus_Config2__ProductConstraint__c','Apttus_Config2__ProductId__c=:productID');
        productConstraintList = Database.query(queryString );
        
        for(Apttus_Config2__ProductConstraint__c productConstraint : productConstraintList) {
            clonedProductConstraint = productConstraint.clone(false,true);
            clonedProductConstraint.Apttus_Config2__ProductId__c = clonedProduct.id;
            if (clonedProductConstraint != null) {
                insert clonedProductConstraint;
            }
    
            
            //Product Constraint Entry Cloning
            String constraintId = productConstraint.id;
            queryString = getQueryStringWithAllFields('Apttus_Config2__ProductConstraintEntry__c','Apttus_Config2__ProductConstraintId__c=:constraintId');
            productConstraintEntryList = Database.query(queryString);
            for(Apttus_Config2__ProductConstraintEntry__c productConstraintEntry : productConstraintEntryList) {
                clonedProductConstraintEntry = productConstraintEntry.clone(false,true) ;
                clonedProductConstraintEntry.Apttus_Config2__ProductConstraintId__c = clonedProductConstraint.id;
                clonedProductConstraintEntryList.add(clonedProductConstraintEntry);          
                
            }
            if(clonedProductConstraintEntryList.size() > 0) {
                insert clonedProductConstraintEntryList;
            } 
        }
        
        //Product Constraint Condition Cloning
        queryString = getQueryStringWithAllFields('Apttus_Config2__ConstraintRuleCondition__c','Apttus_Config2__ProductId__c=:productID');
        productConstraintConditionList = Database.query(queryString );
        boolean groupAvailable =false;
        Apttus_Config2__ProductGroup__c cloneProductGroup = new Apttus_Config2__ProductGroup__c();
        if (productConstraintConditionList.size() > 0) {
            
            cloneProductGroup.Name = clonedProduct.Name + ' - Group';
            insert cloneProductGroup;
            groupAvailable = true;
            Apttus_Config2__ProductGroupMember__c masterProductMember = new Apttus_Config2__ProductGroupMember__c();
            masterProductMember.Apttus_Config2__ProductGroupId__c = cloneProductGroup.id;
            masterProductMember.Apttus_Config2__ProductId__c = productList[0].id;
            masterProductMember.Apttus_Config2__Sequence__c = 1;
            
            Apttus_Config2__ProductGroupMember__c clonedProductMember = new Apttus_Config2__ProductGroupMember__c();
            clonedProductMember.Apttus_Config2__ProductGroupId__c = cloneProductGroup.id;
            clonedProductMember.Apttus_Config2__ProductId__c = clonedProduct.id;
            clonedProductMember.Apttus_Config2__Sequence__c = 2;
            
            insert masterProductMember;
            insert clonedProductMember;
           
            
            for(Apttus_Config2__ConstraintRuleCondition__c productConstraintCondition : productConstraintConditionList) {   
                clonedProductConstraintCondition = productConstraintCondition.clone(false,true);
                clonedProductConstraintCondition.Name = productConstraintCondition.Name + ' -Group';
                clonedProductConstraintCondition.Apttus_Config2__ProductId__c = null;
                clonedProductConstraintCondition.Apttus_Config2__ProductScope__c ='Product Group';
                clonedProductConstraintCondition.Apttus_Config2__ProductGroupId__c = cloneProductGroup.id;
                clonedProductConstraintCondition.Apttus_Config2__MatchRule__c = 'Match Any In Group';
                clonedProductConstraintConditionList.add(clonedProductConstraintCondition);
            }    
                
        }
        
        
        if(clonedProductConstraintConditionList.size() > 0) {
           delete productConstraintConditionList;
           insert clonedProductConstraintConditionList;
        }
        
        //Product Constraint Action Cloning
        queryString = getQueryStringWithAllFields('Apttus_Config2__ConstraintRuleAction__c','Apttus_Config2__ProductId__c=:productID');
        productConstraintActionList = Database.query(queryString );
        
        if(productConstraintActionList.size() > 0) {
            if(!groupAvailable) {
                cloneProductGroup.Name = clonedProduct.Name + ' - Group';
                insert cloneProductGroup;
                
                Apttus_Config2__ProductGroupMember__c masterProductMember = new Apttus_Config2__ProductGroupMember__c();
                masterProductMember.Apttus_Config2__ProductGroupId__c = cloneProductGroup.id;
                masterProductMember.Apttus_Config2__ProductId__c = productList[0].id;
                masterProductMember.Apttus_Config2__Sequence__c = 1;
                
                Apttus_Config2__ProductGroupMember__c clonedProductMember = new Apttus_Config2__ProductGroupMember__c();
                clonedProductMember.Apttus_Config2__ProductGroupId__c = cloneProductGroup.id;
                clonedProductMember.Apttus_Config2__ProductId__c = clonedProduct.id;
                clonedProductMember.Apttus_Config2__Sequence__c = 2;
                
                insert masterProductMember;
                insert clonedProductMember;         
            }
            
            for(Apttus_Config2__ConstraintRuleAction__c productConstraintAction : productConstraintActionList) {
               
                clonedProductConstraintAction = productConstraintAction.clone(false,true);
                clonedProductConstraintAction.Apttus_Config2__ProductId__c = clonedProduct.id;
                clonedProductConstraintActionList.add(clonedProductConstraintAction);
            }
                
        }
        
        if(clonedProductConstraintActionList.size() > 0) {
           delete productConstraintActionList;
           insert clonedProductConstraintActionList;
        }
      
        //Product Search Attribute cloning
        queryString = getQueryStringWithAllFields('Apttus_Config2__SearchAttributeValue__c','Apttus_Config2__BaseProductId__c=:productID');
        productSearchAttributeList = Database.query(queryString );
        
        for(Apttus_Config2__SearchAttributeValue__c productSearchAttribute : productSearchAttributeList) {
            clonedProductSearchAttribute = productSearchAttribute.clone(false,true);
            clonedProductSearchAttribute.Apttus_Config2__BaseProductId__c = clonedProduct.id;

            clonedProductSearchAttributeList.add(clonedProductSearchAttribute);
        }

        if(clonedProductSearchAttributeList.size() > 0) {
           insert clonedProductSearchAttributeList;
        }
      
        //Product Group Member cloning
        queryString = getQueryStringWithAllFields('Apttus_Config2__ProductGroupMember__c','Apttus_Config2__ProductId__c=:productID');
        productGroupMemberList = Database.query(queryString );
        
        for(Apttus_Config2__ProductGroupMember__c productGroupMember : productGroupMemberList) {
            clonedProductGroupMember  = productGroupMember.clone(false,true);
            clonedProductGroupMember.Apttus_Config2__ProductId__c = clonedProduct.id;

            clonedProductGroupMemberList.add(clonedProductGroupMember);
        }

        if(clonedProductGroupMemberList.size() > 0) {
           insert clonedProductGroupMemberList;
        }     
           
        //Product Attribute Group Member cloning
        queryString = getQueryStringWithAllFields('Apttus_Config2__ProductAttributeGroupMember__c','Apttus_Config2__ProductId__c=:productID');
        productAttributeGroupMemberList = Database.query(queryString );
        
        for(Apttus_Config2__ProductAttributeGroupMember__c productAttributeGroupMember : productAttributeGroupMemberList) {
            clonedProductAttributeGroupMember  = productAttributeGroupMember.clone(false,true);
            clonedProductAttributeGroupMember.Apttus_Config2__ProductId__c = clonedProduct.id;

            clonedProductAttributeGroupMemberList.add(clonedProductAttributeGroupMember);
        }

        if(clonedProductAttributeGroupMemberList.size() > 0) {
           insert clonedProductAttributeGroupMemberList;
        }
        
       
        //Product Information cloning
        queryString = getQueryStringWithAllFields('Apttus_Config2__ProductInformation__c','Apttus_Config2__ProductId__c=:productID');
        productInformationList = Database.query(queryString);
        
        for(Apttus_Config2__ProductInformation__c productInformation : productInformationList ) {
            clonedProductInformation = productInformation.clone(false,true);
            clonedProductInformation.Apttus_Config2__ProductId__c = clonedProduct.id;

            clonedProductInformationList.add(clonedProductInformation);
        }

        if(clonedProductInformationList.size() > 0) {
           insert clonedProductInformationList;
        }                   
               
        PageReference productPage = new PageReference('/'+clonedProduct.id);
        productPage.setRedirect(true);
        return productPage;
    }
    
    public static string getQueryStringWithAllFields(String objectName, String whereClause){
        String selects = '';
     
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable() && fd.getName() != 'APTS_Ext_ID__c'){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
             
        }
        
        if (whereClause != null) {
            return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
        }
        else {
            return 'SELECT ' + selects + ' FROM ' + objectName ;
        }
        
          
    }
}