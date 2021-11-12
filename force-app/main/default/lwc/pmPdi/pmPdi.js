import { LightningElement, wire } from 'lwc';
import getPmPdiSteps from '@salesforce/apex/HRCFSL_PmPdiController.getPmPdiSteps';
import getAsset from '@salesforce/apex/HRCFSL_PmPdiController.getAsset';
import getTechnician from '@salesforce/apex/HRCFSL_PmPdiController.getTechnician';
import createWorkOrder from '@salesforce/apex/HRCFSL_PmPdiController.createWorkOrder';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PmPdi extends LightningElement {

    steps; 
    error; 

    isLoading;

    get showAsset() {
        if (!this.asset)
            return false;
        else
            return true;     
    }

    get showSearch() {
        if (!this.asset)
            return true;
        else
            return false;     
    }

    get showSteps() {
        if (!this.steps)
            return false;
        if (this.steps.length == 0)
            return false;     
        return true; 
    }

    connectedCallback() {
        setTimeout(() => {
            this.focusAssetSearch();
        }, 3000);               
    }



    focusAssetSearch() {
        console.log('in focusAssetSearch'); 
        const targetId = '[data-search="asset"]';
        console.log('targetId: ' + targetId); 
        let target = this.template.querySelector(targetId);
        console.log('target: ' + JSON.stringify(target)); 
        if (target) {
            target.focus();
            return true;
        }
        return false;     
    }
    
    focusFirstStep() {
        const stepFields = this.template.querySelectorAll(".step");
        console.log('step fields: ' + JSON.stringify(stepFields));
        if (stepFields && stepFields.length > 0) {
            stepFields[0].focus(); 
        }
    }

    handleDivClick(event) {
        console.log('in handleDivClick');
        if (!this.focusAssetSearch()) 
            this.focusFirstStep();
    }

    asset; 

    searchAsset(event) {
        console.log('executing searchAsset...'); 
        let serialNumber = event.target.value; 
        console.log('serialNumber is ' + serialNumber); 
        getAsset({ serialNumber : serialNumber   })
            .then(result => {
                console.log('Asset is ' + result); 
                this.asset = result;
                this.error = undefined;

                setTimeout(() => {
                    const stepFields = this.template.querySelectorAll(".step");
                    console.log('step fields: ' + JSON.stringify(stepFields));
                    if (stepFields && stepFields.length > 0) {
                        stepFields[0].focus(); 
                    }
                }, 2000);
            })
            .catch(error => {
                console.log('error:  ' + JSON.stringify(error)); 
                this.error = error;
                                
                const event = new ShowToastEvent({
                    title: 'Failure',
                    message: 'Could not find Asset with that Serial Number ', 
                    variant: 'error'
                });
                this.dispatchEvent(event);
                const target = this.template.querySelector('[data-search="asset"]');    
                target.value = '';
            });

            

    }
    
    handleCommit(event) {
        console.log('handleCommit'); 
        //handle RESET and CLOSE
        let value = event.target.value; 
        console.log('value is ' + value);
        if (value.toUpperCase() === 'CLOSE') {
            console.log('Close: clear search results'); 
            this.close();
            return;      
        }
        
        if (value.toUpperCase() === 'RESET') {
            console.log('Reset: Reset fields'); 
            this.reset();   
            return;
        }

        let name = event.target.dataset.name;
        if (name === 'technicianName') {
            return this.searchTechnician(event);             
        }
        
        //advance to next row, or if last row, advance to Action input field
        this.advanceNext(event); 
    }
    
    user; 

    searchTechnician(event) {
        console.log('looking up technician....'); 
        
        const jdeId = event.target.value; 
        const techNameInputCmp = this.template.querySelector('[data-name="technicianName"' );
        
        console.log('JDE ID is ' + jdeId);
        
        getTechnician({ jdeId : jdeId })
        .then(result => {
            console.log('User is ' + JSON.stringify(result)); 
            this.user = result;
            this.error = undefined;
            techNameInputCmp.value = this.user.Name;
            techNameInputCmp.setCustomValidity("");
            techNameInputCmp.reportValidity();
            //advance to next field
            const target = this.template.querySelector('[data-name="disinfectantUsed"'); 
            console.log('target: ' + JSON.stringify(target));
            target.focus(); 
        })
        .catch(error => {
            console.log('error:  ' + JSON.stringify(error)); 

            techNameInputCmp.setCustomValidity("Please enter a valid technician Id");
            techNameInputCmp.reportValidity();
            techNameInputCmp.value = '';
            techNameInputCmp.focus(); 

            this.error = error;
            this.user = undefined; 
        });
    }

    handleAction(event) {
        console.log('executing handleAction'); 
        let value = event.target.value;
        
        if (value.toUpperCase() === 'OK') {
            console.log('OK: Save fields'); 
            return this.ok(event); 
            
        }
    }

    advanceNext(event) {
        let current = event.target.dataset.name;
        console.log('current field is ' + current); 
        let nextFieldName = '';
        if (current === 'disinfectantUsed') {  
            nextFieldName = '[data-name="infectionType"]';
        }
        else if (current === 'infectionType') {
            nextFieldName = '[data-name="action"]';
        }
        const target = this.template.querySelector(nextFieldName);
        console.log('target: ' + JSON.stringify(target));
        target.focus();
    }

    reset() {
        const stepFields = this.template.querySelectorAll(".step");
        console.log('step fields: ' + JSON.stringify(stepFields)); 
        if (stepFields) {
            stepFields.forEach(field => {
                field.value = ""; 
            });
            stepFields[0].focus(); 

        }
    }

    handleChange(event) {
        this.isLoading = true;
    }

    ok(event) {
        debugger; 
        this.isLoading = true;  

        //Validate fields are filled in
        const infectionCmp = this.template.querySelector('[data-name="infectionType"' );
        const infectionType = infectionCmp.value;

        const disinfectantUsedCmp = this.template.querySelector('[data-name="disinfectantUsed"' );
        const disinfectantUsed = disinfectantUsedCmp.value;
        
        const params = {
            assetId : this.asset.Id,
            userId : this.user.Id,
            technicianName : this.user.Name,
            disinfectantUsed : disinfectantUsed,
            infectionType : infectionType
        }
        console.log('params: ' + JSON.stringify(params));

        createWorkOrder(params)
        .then(result => {
            const event = new ShowToastEvent({
                title: 'Success!',
                message: 'Created Work Order ' + result,
                variant: 'success'
            });
            this.dispatchEvent(event);    
            this.isLoading = false;
            this.close();    
        })
        .catch(error => {  
            const event = new ShowToastEvent({
                title: 'Failure',
                message: 'Could not create Work Order ', 
                variant: 'error'
            });
            this.dispatchEvent(event);   
            this.isLoading = false;       
        });

        
    }

    close() {
        this.asset = null;
        setTimeout(() => {
            this.focusAssetSearch();
        }, 2000);   
    }
}