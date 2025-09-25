import { LightningElement, wire } from "lwc";
import { createRecord } from "lightning/uiRecordApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";

// import fields
import Account__c from "@salesforce/schema/Expense__c.Account__c";
import Amount__c from "@salesforce/schema/Expense__c.Amount__c";
import Category__c from "@salesforce/schema/Expense__c.Category__c";
import Date__c from "@salesforce/schema/Expense__c.Date__c";
import Establishment__c from "@salesforce/schema/Expense__c.Establishment__c";
import Expecting_Reimbursement__c from "@salesforce/schema/Expense__c.Expecting_Reimbursement__c";
import Method__c from "@salesforce/schema/Expense__c.Method__c";
import Project__c from "@salesforce/schema/Expense__c.Project__c";
import Recurring__c from "@salesforce/schema/Expense__c.Recurring__c";
import Reflected_Online__c from "@salesforce/schema/Expense__c.Reflected_Online__c";

const EXPENSE__C = "Expense__c";
const DISCRETIONARY = "Discretionary";
const NONDISCRETIONARY = "Nondiscretionary";

export default class ExpenseCreationForm extends LightningElement {
  
  
  discretionary = { label: DISCRETIONARY, is: false };
  nonDiscretionary = { label: NONDISCRETIONARY, is: false };

  // get record type
  expenseRTs;
  @wire(getObjectInfo, { objectApiName: EXPENSE__C })
  objectInfo({ data, error }) {
    if (data) {
      this.expenseRTs = data.recordTypeInfos;
    } else if (error) {
      console.error("myerror :: ", error);
    }
  }

  handleClick(event) {
    console.log("mylog :: handleClick()");
    console.log("mylog :: event.detail: " + event.detail);
    console.log("mylog :: event.detail.fields: " + event.detail.fields);
  }

  handleSubmit() {
    console.log("mylog :: handleSubmit()");
  }

  toggleExpenseType(event) {
    console.log('mylog :: event.target: ' + event.target);
    console.log('mylog :: event.detail: ' + event.detail);
  }

  log() {
    console.log("mylog :: log()");
  }
}