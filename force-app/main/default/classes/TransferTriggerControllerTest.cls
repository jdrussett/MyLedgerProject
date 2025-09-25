@IsTest
public class TransferTriggerControllerTest {
  @isTest
  static void insertTransfersTest() {
    Map<String, Transfer__c> transferMap = TestDataFactory.createTransfers();

    Test.startTest();
    System.runAs(new User(Id = UserInfo.getUserId())) {
      insert transferMap.values();
    }
    Test.stopTest();

    Map<String, Account> updatedAccounts = getUpdatedAccounts();

    assertAccountSubtotals(
      updatedAccounts.get('test_checking'),
      new Map<String, Double>{
        'Balancing_Amount__c' => 100,
        'Total_Transfers_In__c' => 30,
        'Total_Transfers_Out__c' => 25,
        'Total_Card_Charges__c' => 20,
        'Total_Charges_Stricken__c' => 0,
        'Balance__c' => 85
      }
    );

    assertAccountSubtotals(
      updatedAccounts.get('test_savings'),
      new Map<String, Double>{
        'Balancing_Amount__c' => 100,
        'Total_Transfers_In__c' => 10,
        'Total_Transfers_Out__c' => 0,
        'Total_Card_Charges__c' => 0,
        'Total_Charges_Stricken__c' => 0,
        'Balance__c' => 110
      }
    );

    assertAccountSubtotals(
      updatedAccounts.get('test_cash'),
      new Map<String, Double>{
        'Balancing_Amount__c' => 100,
        'Total_Transfers_In__c' => 15,
        'Total_Transfers_Out__c' => 0,
        'Total_Card_Charges__c' => 0,
        'Total_Charges_Stricken__c' => 0,
        'Balance__c' => 115
      }
    );

    assertAccountSubtotals(
      updatedAccounts.get('test_card'),
      new Map<String, Double>{
        'Balancing_Amount__c' => 100,
        'Total_Transfers_In__c' => 20,
        'Total_Transfers_Out__c' => 0,
        'Total_Card_Charges__c' => 0,
        'Total_Charges_Stricken__c' => 25,
        'Balance__c' => 55
      }
    );

    assertAccountSubtotals(
      updatedAccounts.get('test_digital'),
      new Map<String, Double>{
        'Balancing_Amount__c' => 100,
        'Total_Transfers_In__c' => 0,
        'Total_Transfers_Out__c' => 30,
        'Total_Card_Charges__c' => 0,
        'Total_Charges_Stricken__c' => 0,
        'Balance__c' => 70
      }
    );

    Assert.isTrue(true, 'all asserts have passed, satisfy PMD');
  }

  @isTest
  static void updateTransfersTest() {
    User testUser = new User(Id = UserInfo.getUserId());
    Map<String, Transfer__c> transferMap = TestDataFactory.createTransfers();
    System.runAs(testUser) {
      insert new List<Transfer__c>{
        transferMap.get('checking_to_savings'),
        transferMap.get('atm_withdrawal')
      };
    }

    Account newTestCheckingAccount = new Account(
      Type = 'Checking Account',
      Name = 'new_test_checking',
      RecordTypeId = TestDataFactory.accountRecordTypes.get('General_Equity'),
      Balancing_Amount__c = 100,
      Total_Transfers_In__c = 0,
      Total_Transfers_Out__c = 0,
      Total_Card_Charges__c = 0,
      Total_Charges_Stricken__c = 0
    );
    insert newTestCheckingAccount;
    transferMap.get('checking_to_savings')
      .Source_Account__c = newTestCheckingAccount.Id;
    transferMap.get('atm_withdrawal').Amount__c = 45;

    Test.startTest();
    System.runAs(testUser) {
      update new List<Transfer__c>{
        transferMap.get('checking_to_savings'),
        transferMap.get('atm_withdrawal')
      };
    }
    Test.stopTest();

    Map<String, Account> updatedAccounts = getUpdatedAccounts();

    assertAccountSubtotals(
      updatedAccounts.get('test_checking'),
      new Map<String, Double>{
        'Balancing_Amount__c' => 100,
        'Total_Transfers_In__c' => 0,
        'Total_Transfers_Out__c' => 45,
        'Total_Card_Charges__c' => 0,
        'Total_Charges_Stricken__c' => 0,
        'Balance__c' => 55
      }
    );
    assertAccountSubtotals(
      updatedAccounts.get('new_test_checking'),
      new Map<String, Double>{
        'Balancing_Amount__c' => 100,
        'Total_Transfers_In__c' => 0,
        'Total_Transfers_Out__c' => 10,
        'Total_Card_Charges__c' => 0,
        'Total_Charges_Stricken__c' => 0,
        'Balance__c' => 90
      }
    );
    assertAccountSubtotals(
      updatedAccounts.get('test_cash'),
      new Map<String, Double>{
        'Balancing_Amount__c' => 100,
        'Total_Transfers_In__c' => 45,
        'Total_Transfers_Out__c' => 0,
        'Total_Card_Charges__c' => 0,
        'Total_Charges_Stricken__c' => 0,
        'Balance__c' => 145
      }
    );

    Assert.isTrue(true, 'all asserts have passed, satisfy PMD');
  }

  @isTest
  static void deleteTransfersTest() {
    User testUser = new User(Id = UserInfo.getUserId());
    Map<String, Transfer__c> transferMap = TestDataFactory.createTransfers();
    System.runAs(testUser) {
      insert transferMap.values();
    }

    Map<String, Account> accountMap = getUpdatedAccounts();

    System.runAs(testUser) {
      insert new List<Transfer__c>{
        new Transfer__c(
          Subject__c = 'new_card_payoff',
          RecordTypeId = TestDataFactory.transferRecordTypes.get('Card_Payoff'),
          Amount__c = 55,
          Method__c = 'Card Payoff',
          Source_Account__c = accountMap.get('test_checking').Id,
          Target_Account__c = accountMap.get('test_card').Id
        ),
        new Transfer__c(
          Subject__c = 'new_venmo_transfer',
          RecordTypeId = TestDataFactory.transferRecordTypes.get(
            'Lateral_Transfer'
          ),
          Amount__c = 65,
          Method__c = 'Venmo Transfer',
          Source_Account__c = accountMap.get('test_digital').Id,
          Target_Account__c = accountMap.get('test_savings').Id
        )
      };
    }

    accountMap = getUpdatedAccounts();

    assertAccountSubtotals(
      accountMap.get('test_checking'),
      new Map<String, Double>{
        'Balancing_Amount__c' => 100,
        'Total_Transfers_In__c' => 30,
        'Total_Transfers_Out__c' => 25,
        'Total_Card_Charges__c' => 75,
        'Total_Charges_Stricken__c' => 0,
        'Balance__c' => 30
      }
    );

    assertAccountSubtotals(
      accountMap.get('test_savings'),
      new Map<String, Double>{
        'Balancing_Amount__c' => 100,
        'Total_Transfers_In__c' => 75,
        'Total_Transfers_Out__c' => 0,
        'Total_Card_Charges__c' => 0,
        'Total_Charges_Stricken__c' => 0,
        'Balance__c' => 175
      }
    );

    assertAccountSubtotals(
      accountMap.get('test_cash'),
      new Map<String, Double>{
        'Balancing_Amount__c' => 100,
        'Total_Transfers_In__c' => 15,
        'Total_Transfers_Out__c' => 0,
        'Total_Card_Charges__c' => 0,
        'Total_Charges_Stricken__c' => 0,
        'Balance__c' => 115
      }
    );

    assertAccountSubtotals(
      accountMap.get('test_card'),
      new Map<String, Double>{
        'Balancing_Amount__c' => 100,
        'Total_Transfers_In__c' => 75,
        'Total_Transfers_Out__c' => 0,
        'Total_Card_Charges__c' => 0,
        'Total_Charges_Stricken__c' => 25,
        'Balance__c' => 0
      }
    );

    assertAccountSubtotals(
      accountMap.get('test_digital'),
      new Map<String, Double>{
        'Balancing_Amount__c' => 100,
        'Total_Transfers_In__c' => 0,
        'Total_Transfers_Out__c' => 95,
        'Total_Card_Charges__c' => 0,
        'Total_Charges_Stricken__c' => 0,
        'Balance__c' => 5
      }
    );

    Test.startTest();
    System.runAs(testUser) {
      delete new List<Transfer__c>{
        transferMap.get('card_payoff'),
        transferMap.get('venmo_transfer')
      };
    }
    Test.stopTest();
    Assert.areEqual(
      5,
      [SELECT COUNT() FROM Transfer__c],
      'count of total transfer records'
    );

    Map<String, Account> updatedAccounts = getUpdatedAccounts();

    assertAccountSubtotals(
      updatedAccounts.get('test_checking'),
      new Map<String, Double>{
        'Balancing_Amount__c' => 100,
        'Total_Transfers_In__c' => 0,
        'Total_Transfers_Out__c' => 25,
        'Total_Card_Charges__c' => 55,
        'Total_Charges_Stricken__c' => 0,
        'Balance__c' => 20
      }
    );

    assertAccountSubtotals(
      updatedAccounts.get('test_card'),
      new Map<String, Double>{
        'Balancing_Amount__c' => 100,
        'Total_Transfers_In__c' => 55,
        'Total_Transfers_Out__c' => 0,
        'Total_Card_Charges__c' => 0,
        'Total_Charges_Stricken__c' => 25,
        'Balance__c' => 20
      }
    );

    assertAccountSubtotals(
      updatedAccounts.get('test_digital'),
      new Map<String, Double>{
        'Balancing_Amount__c' => 100,
        'Total_Transfers_In__c' => 0,
        'Total_Transfers_Out__c' => 65,
        'Total_Card_Charges__c' => 0,
        'Total_Charges_Stricken__c' => 0,
        'Balance__c' => 35
      }
    );

    Assert.isTrue(true, 'all asserts have passed, satisfy PMD');
  }

  /**
   * @param Account
   * @param expectedTotals (Map<String, Double>)
   */
  private static void assertAccountSubtotals(
    Account a,
    Map<String, Double> expectedTotals
  ) {
    for (String s : expectedTotals.keySet()) {
      Assert.areEqual(
        expectedTotals.get(s),
        a.get(s),
        'field: ' + s + ' for account: ' + a
      );
    }
  }

  private static Map<String, Account> getUpdatedAccounts() {
    Map<String, Account> accountMap = new Map<String, Account>();
    for (Account a : [
      SELECT
        Id,
        Name,
        Balancing_Amount__c,
        Total_Transfers_In__c,
        Total_Transfers_Out__c,
        Total_Card_Charges__c,
        Total_Charges_Stricken__c,
        Balance__c
      FROM Account
    ]) {
      accountMap.put(a.Name, a);
    }
    return accountMap;
  }
}