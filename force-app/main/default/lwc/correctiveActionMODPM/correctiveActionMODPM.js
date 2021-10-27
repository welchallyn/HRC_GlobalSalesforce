import { LightningElement, wire, track } from "lwc";
import retrieveWorkOrders from "@salesforce/apex/HRCSVC_getAssetDetails.retrieveWorkOrders";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const columns = [
  {
    label: "Work Order Number",
    fieldName: "numUrl",
    type: "url",
    typeAttributes: {
      label: { fieldName: "WorkOrderNumber" },
      target: "_blank"
    },
    sortable: false
  },
  {
    label: "Work Order Type",
    fieldName: "HRCFSL_Work_Type_Name__c",
    type: "text",
    sortable: false
  },
  {
    label: "Product Desciption",
    fieldName: "Description",
    type: "text",
    wrapText: false,
    sortable: false
  },
  {
    label: "Next PM Date",
    fieldName: "HRCFSL_Next_PM_DT__c",
    type: "date-local",
    typeAttributes: {
      month: "2-digit",
      day: "2-digit"
    },
    sortable: true
  },
  {
    label: "Frequency",
    fieldName: "Frequency",
    type: "text",
    sortable: false
  },
  {
    label: "Maintenance Plan",
    fieldName: "MaintenancePlanNumber",
    type: "Number",
    sortable: false
  },
  {
    label: "Service Contract",
    fieldName: "ServiceContract",
    type: "text",
    sortable: false
  },
  {
    label: "Serial Number",
    fieldName: "assetUrl",
    type: "url",
    typeAttributes: {
      label: { fieldName: "Asset" },
      target: "_blank"
    },
    sortable: false
  },
  {
    label: "Location",
    fieldName: "HRCFSL_Location_Name__c",
    type: "text",
    sortable: false
  },
  {
    label: "Location Description",
    fieldName: "LocationDesc",
    type: "text",
    sortable: false
  },
  {
    label: "Service Territory",
    fieldName: "ServiceTerritory",
    type: "text",
    sortable: false
  },
  {
    label: "Work Order Due Date",
    fieldName: "EndDate",
    type: "date-local",
    typeAttributes: {
      month: "2-digit",
      day: "2-digit"
    },
    sortable: false
  }
];

export default class CorrectiveActionMODPM extends LightningElement {
  @track page = 1; //this will initialize 1st page
  @track items = []; //it contains all the records.
  @track data = []; //data to be displayed in the table
  @track completeSet = []; //it contains all the records and will never change.
  @track columns; //holds column info.
  @track startingRecord = 1; //start record position per page
  @track endingRecord = 0; //end record position per page
  @track pageSize = 35; //default value we are assigning
  @track totalRecountCount = 0; //total record count received from all retrieved records
  @track totalPage = 0; //total number of page is needed to display all records

  @track error;

  wiredActivities;
  @track sortBy = "HRCFSL_Next_PM_DT__c";
  @track sortDirection = "asc";
  @track searchKeySnum;
  @track searchKeyCust;
  @track searchKeySTerr;
  @track searchKeyMPType;
  @track searchKeyMOD;
  @track searchKeyWODue;
  @track showTable = false;
  @track listEmpty = false;
  @track singlePage = false;
  @track wosSpinner = true;
  @wire(retrieveWorkOrders)
  wiredAccounts(value) {
    console.log("Wired activities");
    this.wiredActivities = value;
    const { data, error } = value;
    if (data) {

      console.log("inside if");
      console.log(data);
      this.wosSpinner = false;
      const evt = new ShowToastEvent({
        title: 'Successfully fetched Work Orders.',
        message: '',
        variant: 'success',
        mode: 'dismissable'
      });
      this.dispatchEvent(evt);


      let numUrl;
      let Frequency;
      let MaintenancePlanNumber;
      let ServiceContract;
      let Asset;
      let assetUrl;
      let LocationDesc;
      let ServiceTerritory;
      this.items = data.map((row) => {
        numUrl = `/${row.Id}`;
        Frequency =
          row.MaintenancePlan.Frequency +
          " " +
          row.MaintenancePlan.FrequencyType;
        MaintenancePlanNumber = row.MaintenancePlan.MaintenancePlanNumber;

        if (Object.keys(row).includes("ServiceContract")) {
          ServiceContract = row.ServiceContract.Name;
        } else {
          ServiceContract = "";
        }

        if (Object.keys(row).includes("Asset")) {
          Asset = row.Asset.Name;
          assetUrl = `/${row.AssetId}`;
        } else {
          Asset = "";
          assetUrl = "";
        }

        if (Object.keys(row).includes("Location")) {
          LocationDesc = row.Location.HRCFSL_Description__c;
        } else {
          LocationDesc = "";
        }

        if (Object.keys(row).includes("ServiceTerritory")) {
          ServiceTerritory = row.ServiceTerritory.Name;
        } else {
          ServiceTerritory = "";
        }

        return {
          ...row,
          numUrl,
          Frequency,
          MaintenancePlanNumber,
          ServiceContract,
          Asset,
          assetUrl,
          LocationDesc,
          ServiceTerritory
        };
      });
      //this.items = data;
      if (data.length === 0) this.listEmpty = true;
      else this.listEmpty = false;
      this.completeSet = this.items;
      if (data.length >= 30) this.pageSize = 30;
      else this.pageSize = data.length;
      this.totalRecountCount = data.length; //here it is 23
      this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); //here it is 5
      if (this.totalPage <= 1) this.singlePage = true;
      else this.singlePage = false;
      this.data = this.items.slice(0, this.pageSize);
      this.endingRecord = this.pageSize;
      this.columns = columns;

      this.error = undefined;
      console.table(this.data);
    } else if (error) {
      console.log("inside else");
      this.error = error;
      console.log(this.error);
      this.data = undefined;

      this.wosSpinner = false;
      const evt = new ShowToastEvent({
        title: 'Error',
        message: this.error.body.message,
        variant: 'error',
        mode: 'dismissable'
      });
      this.dispatchEvent(evt);
    }
  }

  //clicking on previous button this method will be called
  previousHandler() {
    if (this.page > 1) {
      this.page = this.page - 1; //decrease page by 1
      this.displayRecordPerPage(this.page);
    }
  }

  //clicking on next button this method will be called
  nextHandler() {
    if (this.page < this.totalPage && this.page !== this.totalPage) {
      this.page = this.page + 1; //increase page by 1
      this.displayRecordPerPage(this.page);
    }
  }

  //this method displays records page by page
  displayRecordPerPage(page) {
    /*let's say for 2nd page, it will be => "Displaying 6 to 10 of 23 records. Page 2 of 5"
          page = 2; pageSize = 5; startingRecord = 5, endingRecord = 10
          so, slice(5,10) will give 5th to 9th records.
          */
    this.startingRecord = (page - 1) * this.pageSize;
    this.endingRecord = this.pageSize * page;

    this.endingRecord =
      this.endingRecord > this.totalRecountCount
        ? this.totalRecountCount
        : this.endingRecord;

    this.data = this.items.slice(this.startingRecord, this.endingRecord);

    //increment by 1 to display the startingRecord count,
    //so for 2nd page, it will show "Displaying 6 to 10 of 23 records. Page 2 of 5"
    this.startingRecord = this.startingRecord + 1;
  }

  handleSortdata(event) {
    // field name
    this.sortBy = event.detail.fieldName;

    // sort direction
    this.sortDirection = event.detail.sortDirection;

    // calling sortdata function to sort the data based on direction and selected field
    this.sortData(event.detail.fieldName, event.detail.sortDirection);
  }

  sortData(fieldname, direction) {
    console.log("sort called");
    // serialize the data before calling sort function
    let parseData = JSON.parse(JSON.stringify(this.items));

    // Return the value stored in the field
    let keyValue = (a) => {
      return a[fieldname];
    };

    // cheking reverse direction
    let isReverse = direction === "asc" ? 1 : -1;

    // sorting data
    parseData.sort((x, y) => {
      x = keyValue(x) ? keyValue(x) : ""; // handling null values
      y = keyValue(y) ? keyValue(y) : "";

      // sorting values based on direction
      return isReverse * ((x > y) - (y > x));
    });

    // set the sorted data to data table data
    this.items = parseData;
    this.data = this.items.slice(this.startingRecord, this.endingRecord);

    console.log("sort done");
  }

  handleKeyChangeSnum(event) {
    this.searchKeySnum = event.target.value;
    console.log(this.searchKeySnum);
    console.log(this.searchKeySnum.length);
  }

  handleKeyChangeCust(event) {
    this.searchKeyCust = event.target.value;
    console.log(this.searchKeyCust);
    console.log(this.searchKeyCust.length);
  }

  handleKeyChangeSTerr(event) {
    this.searchKeySTerr = event.target.value;
    console.log(this.searchKeySTerr);
    console.log(this.searchKeySTerr.length);
  }

  handleKeyChangeMPType(event) {
    this.searchKeyMPType = event.target.value;
    console.log(this.searchKeyMPType);
    console.log(this.searchKeyMPType.length);
  }

  handleKeyChangeMOD(event) {
    this.searchKeyMOD = event.target.value;
    console.log(this.searchKeyMOD);
    console.log(this.searchKeyMOD.length);
  }

  handleKeyChangeWODue(event) {
    this.searchKeyWODue = event.target.value;
    if (this.searchKeyWODue != null) {
      console.log(this.searchKeyWODue);
      console.log(this.searchKeyWODue.length);
    }
  }

  handleSearchBtn(event) {
    this.items = this.completeSet;

    if (this.searchKeySnum != null && this.searchKeySnum.length != 0) {
      this.items = this.items.filter((row) => {
        if (row.Asset != "") {
          let str1 = row.Asset.toLowerCase();
          let str2 = this.searchKeySnum.toLowerCase();
          if (str1.includes(str2)) return row;
        }
      });
    }

    if (this.searchKeyCust != null && this.searchKeyCust.length != 0) {
      this.items = this.items.filter((row) => {
        if (Object.keys(row).includes("HRCFSL_Location_Name__c")) {
          if (row.HRCFSL_Location_Name__c != "") {
            let str1 = row.HRCFSL_Location_Name__c.toLowerCase();
            let str2 = this.searchKeyCust.toLowerCase();
            if (str1.includes(str2)) return row;
          }
        }
      });
    }

    if (this.searchKeySTerr != null && this.searchKeySTerr.length != 0) {
      this.items = this.items.filter((row) => {
        if (Object.keys(row).includes("ServiceTerritory")) {
          if (row.ServiceTerritory != "") {
            let str1 = row.ServiceTerritory.toLowerCase();
            let str2 = this.searchKeySTerr.toLowerCase();
            if (str1.includes(str2)) return row;
          }
        }
      });
    }

    if (this.searchKeyMPType != null && this.searchKeyMPType.length != 0) {
      this.items = this.items.filter((row) => {
        if (row.HRCFSL_Work_Type_Name__c != "") {
          let str1 = row.HRCFSL_Work_Type_Name__c.toLowerCase();
          let str2 = this.searchKeyMPType.toLowerCase();
          if (str1.includes(str2)) return row;
        }
      });
    }

    if (this.searchKeyMOD != null && this.searchKeyMOD.length != 0) {
      this.items = this.items.filter((row) => {
        if (Object.keys(row).includes("HRCFSL_ModList__c")) {
          if (row.HRCFSL_ModList__r.Name != "") {
            let str1 = row.HRCFSL_ModList__r.Name.toLowerCase();
            let str2 = this.searchKeyMOD.toLowerCase();
            if (str1.includes(str2)) return row;
          }
        }
      });
    }

    if (this.searchKeyWODue != null && this.searchKeyWODue.length != 0) {
      let d1 = new Date(this.searchKeyWODue);
      let mon1 = d1.getUTCMonth() + 1; //months from 1-12
      let day1 = d1.getUTCDate();
      let year1 = d1.getUTCFullYear();
      this.items = this.items.filter((row) => {
        if (row.EndDate != "") {
          let d2 = new Date(row.EndDate);
          let mon2 = d2.getUTCMonth() + 1;
          let day2 = d2.getUTCDate();
          let year2 = d2.getUTCFullYear();
          if (mon1 === mon2 && day1 === day2 && year1 === year2) return row;
        }
      });
    }

    this.page = 1;
    this.startingRecord = 1;
    if (this.items.length === 0) this.listEmpty = true;
    else this.listEmpty = false;
    if (this.items.length >= 30) this.pageSize = 30;
    else this.pageSize = this.items.length;
    this.totalRecountCount = this.items.length; //here it is 23
    this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); //here it is 5
    if (this.totalPage <= 1) this.singlePage = true;
    else this.singlePage = false;
    this.data = this.items.slice(0, this.pageSize);
    this.endingRecord = this.pageSize;
    this.showTable = true;
  }
}