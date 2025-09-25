@IsTest
public class TestDataFactory {
  public static Map<String, Id> accountRecordTypes {
    get {
      if (accountRecordTypes == null) {
        accountRecordTypes = new Map<String, Id>();
        for (RecordType rt : [
          SELECT Id, DeveloperName
          FROM RecordType
          WHERE SObjectType = 'Account'
        ]) {
          accountRecordTypes.put(rt.DeveloperName, rt.Id);
        }
      }
      return accountRecordTypes;
    }
    set;
  }

  public static Map<String, Id> transferRecordTypes {
    get {
      if (transferRecordTypes == null) {
        transferRecordTypes = new Map<String, Id>();
        for (RecordType rt : [
          SELECT Id, DeveloperName
          FROM RecordType
          WHERE SObjectType = 'Transfer__c'
        ]) {
          transferRecordTypes.put(rt.DeveloperName, rt.Id);
        }
      }
      return transferRecordTypes;
    }
    set;
  }

  public static Map<String, Id> incomeRecordTypes {
    get {
      if (incomeRecordTypes == null) {
        incomeRecordTypes = new Map<String, Id>();
        for (RecordType rt : [
          SELECT Id, DeveloperName
          FROM RecordType
          WHERE SObjectType = 'Income__c'
        ]) {
          incomeRecordTypes.put(rt.DeveloperName, rt.Id);
        }
      }
      return incomeRecordTypes;
    }
    set;
  }

  public static Map<String, Id> expenseRecordTypes {
    get {
      if (expenseRecordTypes == null) {
        expenseRecordTypes = new Map<String, Id>();
        for (RecordType rt : [
          SELECT Id, DeveloperName
          FROM RecordType
          WHERE SObjectType = 'Expense__c'
        ]) {
          expenseRecordTypes.put(rt.DeveloperName, rt.Id);
        }
      }
      return expenseRecordTypes;
    }
    set;
  }

  public static Map<String, Account> createTestAccounts() {
    Map<String, Account> accountMap = new Map<String, Account>();
    List<Account> accounts = new List<Account>{
      new Account(
        Type = 'Checking Account',
        Name = 'test_checking',
        RecordTypeId = accountRecordTypes.get('General_Equity')
      ),
      new Account(
        Type = 'Savings Account',
        Name = 'test_savings',
        RecordTypeId = accountRecordTypes.get('General_Equity')
      ),
      new Account(Type = 'Cash', Name = 'test_cash', RecordTypeId = accountRecordTypes.get('General_Equity')),
      new Account(Type = 'Credit Card', Name = 'test_card', RecordTypeId = accountRecordTypes.get('Credit_Card')),
      new Account(Type = 'Digital', Name = 'test_digital', RecordTypeId = accountRecordTypes.get('General_Equity'))
    };
    for (Account a : accounts) {
      a.Balancing_Amount__c = 100;
      a.Total_Transfers_In__c = 0;
      a.Total_Transfers_Out__c = 0;
      a.Total_Card_Charges__c = 0;
      a.Total_Charges_Stricken__c = 0;
      accountMap.put(a.Name, a);
    }
    insert as user accountMap.values();
    return accountMap;
  }

  public static Map<String, Transfer__c> createTransfers() {
    Map<String, Account> accountMap = createTestAccounts();
    Map<String, Transfer__c> transferMap = new Map<String, Transfer__c>();
    List<Transfer__c> transfers = new List<Transfer__c>{
      new Transfer__c(
        Subject__c = 'checking_to_savings',
        RecordTypeId = transferRecordTypes.get('Lateral_Transfer'),
        Amount__c = 10, // checking 90, savings 110
        Method__c = 'Online Transfer',
        Source_Account__c = accountMap.get('test_checking').Id,
        Target_Account__c = accountMap.get('test_savings').Id
      ),
      new Transfer__c(
        Subject__c = 'atm_withdrawal',
        RecordTypeId = transferRecordTypes.get('Lateral_Transfer'),
        Amount__c = 15, // checking 75, cash 115
        Method__c = 'ATM Withdrawal',
        Source_Account__c = accountMap.get('test_checking').Id,
        Target_Account__c = accountMap.get('test_cash').Id
      ),
      new Transfer__c(
        Subject__c = 'card_payoff',
        RecordTypeId = transferRecordTypes.get('Card_Payoff'),
        Amount__c = 20, // checking 55, card 80
        Method__c = 'Card Payoff',
        Source_Account__c = accountMap.get('test_checking').Id,
        Target_Account__c = accountMap.get('test_card').Id
      ),
      new Transfer__c(
        Subject__c = 'stricken_charge',
        RecordTypeId = transferRecordTypes.get('Card_Payoff'),
        Amount__c = 25, // card 55
        Method__c = 'Stricken Charge',
        Target_Account__c = accountMap.get('test_card').Id
      ),
      new Transfer__c(
        Subject__c = 'venmo_transfer',
        RecordTypeId = transferRecordTypes.get('Lateral_Transfer'),
        Amount__c = 30, // digital 70, checking 85
        Method__c = 'Venmo Transfer',
        Source_Account__c = accountMap.get('test_digital').Id,
        Target_Account__c = accountMap.get('test_checking').Id
      )
    };
    for (Transfer__c t : transfers) {
      transferMap.put(t.Subject__c, t);
    }
    return transferMap;
  }

  /**
   * account totals (after all income/expense/transfers):
   * 
   * -- name -- || -- amount --  
   * --------------------------
   *  checking  ||     1690
   *  savings   ||      410
   *    card    ||      75
   *    cash    ||      415
   *   digital  ||      270
   */
  public static void setupScheduledServiceTestData() {
    Map<String, Account> accountMap = createTestAccounts();
    insert new List<Income__c>{
      new Income__c(
        Amount__c = 1000,
        Account__c = accountMap.get('test_checking').Id,
        Date__c = System.today(),
        Method__c = 'Direct Deposit',
        RecordTypeId = incomeRecordTypes.get('Employment'),
        Subject__c = 'employment_income_1'
      ),
      new Income__c(
        Amount__c = 100,
        Account__c = accountMap.get('test_cash').Id,
        Date__c = System.today(),
        Method__c = 'Cash',
        RecordTypeId = incomeRecordTypes.get('Music'),
        Subject__c = 'gig_income_1'
      ),
      new Income__c(
        Amount__c = 150,
        Account__c = accountMap.get('test_digital').Id,
        Date__c = System.today(),
        Method__c = 'Venmo Transfer',
        RecordTypeId = incomeRecordTypes.get('Music'),
        Subject__c = 'gig_income_2'
      ),
      new Income__c(
        Amount__c = 1200,
        Account__c = accountMap.get('test_checking').Id,
        Date__c = System.today(),
        Method__c = 'Direct Deposit',
        RecordTypeId = incomeRecordTypes.get('Employment'),
        Subject__c = 'employment_income_2'
      ),
      new Income__c(
        Amount__c = 50,
        Account__c = accountMap.get('test_cash').Id,
        Date__c = System.today(),
        Method__c = 'Cash',
        RecordTypeId = incomeRecordTypes.get('Other'),
        Subject__c = 'cash_income_1'
      ),
      new Income__c(
        Amount__c = 70,
        Account__c = accountMap.get('test_digital').Id,
        Date__c = System.today(),
        Method__c = 'Venmo Transfer',
        RecordTypeId = incomeRecordTypes.get('Music'),
        Subject__c = 'gig_income_3'
      ),
      new Income__c(
        Amount__c = 900,
        Account__c = accountMap.get('test_checking').Id,
        Date__c = System.today(),
        Method__c = 'Direct Deposit',
        RecordTypeId = incomeRecordTypes.get('Employment'),
        Subject__c = 'employment_income_3'
      ),
      new Income__c(
        Amount__c = 80,
        Account__c = accountMap.get('test_cash').Id,
        Date__c = System.today(),
        Method__c = 'Cash',
        RecordTypeId = incomeRecordTypes.get('Reimbursement'),
        Subject__c = 'reimbursement_income_1'
      ),
      new Income__c(
        Amount__c = 10,
        Account__c = accountMap.get('test_savings').Id,
        Date__c = System.today(),
        Method__c = 'Online Transfer',
        RecordTypeId = incomeRecordTypes.get('Other'),
        Subject__c = 'interest_income_1'
      ),
      new Income__c(
        Amount__c = 100,
        Account__c = accountMap.get('test_digital').Id,
        Date__c = System.today(),
        Method__c = 'Venmo Transfer',
        RecordTypeId = incomeRecordTypes.get('Music'),
        Subject__c = 'gig_income_4'
      )
    };
    insert new List<Expense__c>{
      new Expense__c(
        Amount__c = 65,
        Account__c = accountMap.get('test_card').Id,
        Category__c = 'Food & Leisure',
        Date__c = System.today(),
        Method__c = 'Credit Card',
        RecordTypeId = expenseRecordTypes.get('Discretionary'),
        Subject__c = 'card_expense_1'
      ),
      new Expense__c(
        Amount__c = 110,
        Account__c = accountMap.get('test_checking').Id,
        Category__c = 'Internet',
        Date__c = System.today(),
        Method__c = 'Online Payment',
        RecordTypeId = expenseRecordTypes.get('Nondiscretionary'),
        Subject__c = 'checking_expense_1'
      ),
      new Expense__c(
        Amount__c = 95,
        Account__c = accountMap.get('test_card').Id,
        Category__c = 'Groceries & Gas',
        Date__c = System.today(),
        Method__c = 'Credit Card',
        RecordTypeId = expenseRecordTypes.get('Nondiscretionary'),
        Subject__c = 'card_expense_2'
      ),
      new Expense__c(
        Amount__c = 40,
        Account__c = accountMap.get('test_digital').Id,
        Category__c = 'Necessary Life Supplies',
        Date__c = System.today(),
        Method__c = 'Venmo Transfer',
        RecordTypeId = expenseRecordTypes.get('Nondiscretionary'),
        Subject__c = 'digital_expense_1'
      ),
      new Expense__c(
        Amount__c = 145,
        Account__c = accountMap.get('test_card').Id,
        Category__c = 'Products & Merchandise',
        Date__c = System.today(),
        Method__c = 'Credit Card',
        RecordTypeId = expenseRecordTypes.get('Discretionary'),
        Subject__c = 'card_expense_3'
      ),
      new Expense__c(
        Amount__c = 500,
        Account__c = accountMap.get('test_checking').Id,
        Category__c = 'Rent & Utilities',
        Date__c = System.today(),
        Method__c = 'Online Payment',
        RecordTypeId = expenseRecordTypes.get('Nondiscretionary'),
        Subject__c = 'checking_expense_2'
      ),
      new Expense__c(
        Amount__c = 35,
        Account__c = accountMap.get('test_cash').Id,
        Category__c = 'Giftgiving',
        Date__c = System.today(),
        Method__c = 'Cash',
        RecordTypeId = expenseRecordTypes.get('Discretionary'),
        Subject__c = 'cash_expense_1'
      ),
      new Expense__c(
        Amount__c = 170,
        Account__c = accountMap.get('test_checking').Id,
        Category__c = 'Nonnegotiable Unpredictables',
        Date__c = System.today(),
        Method__c = 'Check',
        RecordTypeId = expenseRecordTypes.get('Nondiscretionary'),
        Subject__c = 'checking_expense_3'
      ),
      new Expense__c(
        Amount__c = 80,
        Account__c = accountMap.get('test_card').Id,
        Category__c = 'Vacationing/Travel',
        Date__c = System.today(),
        Method__c = 'Credit Card',
        RecordTypeId = expenseRecordTypes.get('Discretionary'),
        Subject__c = 'card_expense_4'
      ),
      new Expense__c(
        Amount__c = 60,
        Account__c = accountMap.get('test_cash').Id,
        Category__c = 'Recreation',
        Date__c = System.today(),
        Method__c = 'Cash',
        RecordTypeId = expenseRecordTypes.get('Discretionary'),
        Subject__c = 'cash_expense_2'
      )
    };
    insert new List<Transfer__c>{
      new Transfer__c(
        Amount__c = 150,
        Date__c = System.today(),
        Method__c = 'Card Payoff',
        RecordTypeId = transferRecordTypes.get('Card_Payoff'),
        Source_Account__c = accountMap.get('test_checking').Id,
        Target_Account__c = accountMap.get('test_card').Id,
        Subject__c = 'card_transfer_1'
      ),
      new Transfer__c(
        Amount__c = 200,
        Date__c = System.today(),
        Method__c = 'Online Transfer',
        RecordTypeId = transferRecordTypes.get('Lateral_Transfer'),
        Source_Account__c = accountMap.get('test_checking').Id,
        Target_Account__c = accountMap.get('test_savings').Id,
        Subject__c = 'lateral_transfer_1'
      ),
      new Transfer__c(
        Amount__c = 140,
        Date__c = System.today(),
        Method__c = 'ATM Withdrawal',
        RecordTypeId = transferRecordTypes.get('Lateral_Transfer'),
        Source_Account__c = accountMap.get('test_checking').Id,
        Target_Account__c = accountMap.get('test_cash').Id,
        Subject__c = 'atm_transfer_1'
      ),
      new Transfer__c(
        Amount__c = 50,
        Date__c = System.today(),
        Method__c = 'Stricken Charge',
        RecordTypeId = transferRecordTypes.get('Card_Payoff'),
        Target_Account__c = accountMap.get('test_card').Id,
        Subject__c = 'stricken_transfer_1'
      ),
      new Transfer__c(
        Amount__c = 135,
        Date__c = System.today(),
        Method__c = 'Card Payoff',
        RecordTypeId = transferRecordTypes.get('Card_Payoff'),
        Source_Account__c = accountMap.get('test_checking').Id,
        Target_Account__c = accountMap.get('test_card').Id,
        Subject__c = 'card_transfer_2'
      ),
      new Transfer__c(
        Amount__c = 20,
        Date__c = System.today(),
        Method__c = 'Venmo Transfer',
        RecordTypeId = transferRecordTypes.get('Lateral_Transfer'),
        Source_Account__c = accountMap.get('test_digital').Id,
        Target_Account__c = accountMap.get('test_checking').Id,
        Subject__c = 'lateral_transfer_2'
      ),
      new Transfer__c(
        Amount__c = 40,
        Date__c = System.today(),
        Method__c = 'ATM Withdrawal',
        RecordTypeId = transferRecordTypes.get('Lateral_Transfer'),
        Source_Account__c = accountMap.get('test_checking').Id,
        Target_Account__c = accountMap.get('test_cash').Id,
        Subject__c = 'atm_transfer_2'
      ),
      new Transfer__c(
        Amount__c = 75,
        Date__c = System.today(),
        Method__c = 'Card Payoff',
        RecordTypeId = transferRecordTypes.get('Card_Payoff'),
        Source_Account__c = accountMap.get('test_checking').Id,
        Target_Account__c = accountMap.get('test_card').Id,
        Subject__c = 'card_transfer_3'
      ),
      new Transfer__c(
        Amount__c = 100,
        Date__c = System.today(),
        Method__c = 'Online Transfer',
        RecordTypeId = transferRecordTypes.get('Lateral_Transfer'),
        Source_Account__c = accountMap.get('test_checking').Id,
        Target_Account__c = accountMap.get('test_savings').Id,
        Subject__c = 'lateral_transfer_3'
      ),
      new Transfer__c(
        Amount__c = 90,
        Date__c = System.today(),
        Method__c = 'Venmo Transfer',
        RecordTypeId = transferRecordTypes.get('Lateral_Transfer'),
        Source_Account__c = accountMap.get('test_digital').Id,
        Target_Account__c = accountMap.get('test_checking').Id,
        Subject__c = 'lateral_transfer_4'
      )
    };
  }
}