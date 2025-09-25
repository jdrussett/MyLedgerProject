import { LightningElement, wire, track } from "lwc";
import getCardAccounts from "@salesforce/apex/AccountService.getCardAccounts";

export default class ExpenseRecordCreationTable extends LightningElement {
  @track wiredCardAccounts;
  clickedCardBalance;
  
  @wire(getCardAccounts) wiredCardAccountFunction (result) {
    if (result.data) {
      this.wiredCardAccounts = result.data;
    }
  }

  handleCardClick(event) {
    this.clickedCardBalance = event.target.value?.Balance__c;
  }
}