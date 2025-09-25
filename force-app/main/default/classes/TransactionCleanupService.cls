public with sharing class TransactionCleanupService {
  public static void run() {
    // get all accounts with subtotals fields before deleting old records
    // gather expenses more than 12 months old
    // gather incomes more than 12 months old
    // gather transfers more than 12 months old
    // delete expenses
    // delete incomes
    // delete transfers
    // get all accounts again
    // compare balances and correct for differences with balancing amount
    Date oneYearAgo = System.today().addYears(-1);
    List<SObject> recordsToDelete = new List<SObject>();
    Map<Id, Account> accountsPre = getAccounts();

    List<Expense__c> expenses = getExpenses(oneYearAgo);
    List<Income__c> incomes = getIncomes(oneYearAgo);
    List<Transfer__c> transfers = getTransfers(oneYearAgo);

    recordsToDelete.addAll(expenses);
    recordsToDelete.addAll(incomes);
    recordsToDelete.addAll(transfers);

    delete as system recordsToDelete;

    Map<Id, Account> accountsPost = getAccounts();
    Map<Id, Account> accountsToUpdate = accountsPost.deepClone();

    for (Id accId : accountsPost.keySet()) {
      Double balanceBefore = accountsPre.get(accId).Balance__c;
      Double balanceAfter = accountsPost.get(accId).Balance__c;
      Double balanceDifference = balanceBefore - balanceAfter;
      accountsToUpdate.get(accId).Balancing_Amount__c += balanceDifference;
    }

    update as system accountsToUpdate.values();
  }

  public static Map<Id, Account> getAccounts() {
    return new Map<Id, Account>(
      [SELECT Id, Name, Balance__c, Balancing_Amount__c FROM Account WITH SYSTEM_MODE]
    );
  }

  private static List<Expense__c> getExpenses(Date dateParam) {
    return [
      SELECT Id
      FROM Expense__c
      WHERE Date__c < :dateParam
      WITH SYSTEM_MODE
    ];
  }

  private static List<Income__c> getIncomes(Date dateParam) {
    return [
      SELECT Id
      FROM Income__c
      WHERE Date__c < :dateParam
      WITH SYSTEM_MODE
    ];
  }

  private static List<Transfer__c> getTransfers(Date dateParam) {
    return [
      SELECT Id
      FROM Transfer__c
      WHERE Date__c < :dateParam
      WITH SYSTEM_MODE
    ];
  }
}