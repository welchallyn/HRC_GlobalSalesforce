/**
 * Created by jasoncurry on 7/13/21.
 */

import {LightningElement, api, track} from 'lwc';

export default class PageBanner extends LightningElement {

    @api label = 'test';
    @api color = 'white';
    @api backgroundColor = 'red';
    @api fontWeight = 'bolder';
    @api fontSize = 'larger';

    @track style = 'width: 100%;';

    hillromPurple = '#5869de';


    connectedCallback() {
        this.style =
            'color: ' + (this.color.toLocaleLowerCase() === 'hillrom purple' ? this.hillromPurple : this.color) + ';' +
            'background-color: ' + (this.backgroundColor.toLocaleLowerCase() === 'hillrom purple' ? this.hillromPurple : this.backgroundColor) + ';' +
            'font-weight: ' + this.fontWeight + ';' +
            'font-size: ' + this.fontSize + ';';
    }

}