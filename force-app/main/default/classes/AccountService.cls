public with sharing class AccountService {
  @AuraEnabled(cacheable=true)
  public static List<Account> getCardAccounts() {
    return [SELECT Id, Name, Balance__c FROM Account WHERE Type = 'Credit Card' WITH USER_MODE];
  }
}