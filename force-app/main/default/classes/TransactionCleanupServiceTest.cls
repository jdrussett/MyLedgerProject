@IsTest
private with sharing class TransactionCleanupServiceTest {
  private static final User ME = new User(Id = UserInfo.getUserId());
  private static final Date LONGAGO = System.today().addMonths(-15);

  @TestSetup
  static void testSetup() {
    System.runAs(ME) {
      TestDataFactory.setupScheduledServiceTestData();
    }
  }

  @isTest
  static void transactionCleanupServiceTest() {
    Map<String, Account> actualPre = new Map<String, Account>();
    Map<String, Account> actualPost = new Map<String, Account>();
    for (Account a : TransactionCleanupService.getAccounts().values()) {
      actualPre.put(a.Name, a);
    }
    Map<String, Map<String, Double>> expectedPre = new Map<String, Map<String, Double>>{
      'test_checking' => new Map<String, Double>{
        'Balancing_Amount__c' => 100,
        'Balance__c' => 1690
      },
      'test_savings' => new Map<String, Double>{
        'Balancing_Amount__c' => 100,
        'Balance__c' => 410
      },
      'test_card' => new Map<String, Double>{
        'Balancing_Amount__c' => 100,
        'Balance__c' => 75
      },
      'test_cash' => new Map<String, Double>{
        'Balancing_Amount__c' => 100,
        'Balance__c' => 415
      },
      'test_digital' => new Map<String, Double>{
        'Balancing_Amount__c' => 100,
        'Balance__c' => 270
      }
    };

    assertBalances(actualPre, expectedPre);

    Test.startTest();
    String jobId;
    List<SObject> allRecordsToDelete = new List<SObject>();
    System.runAs(ME) {
      for (Income__c i : [
        SELECT Id, Date__c
        FROM Income__c
        WHERE
          Subject__c IN (
            'employment_income_1',
            'gig_income_1',
            'gig_income_2',
            'employment_income_3'
          )
      ]) {
        i.Date__c = LONGAGO;
        allRecordsToDelete.add(i);
      }
      for (Expense__c e : [
        SELECT Id, Date__c
        FROM Expense__c
        WHERE
          Subject__c IN (
            'card_expense_1',
            'checking_expense_1',
            'card_expense_3',
            'cash_expense_1'
          )
      ]) {
        e.Date__c = LONGAGO;
        allRecordsToDelete.add(e);
      }
      for (Transfer__c t : [
        SELECT Id, Date__c
        FROM Transfer__c
        WHERE
          Subject__c IN (
            'lateral_transfer_1',
            'stricken_transfer_1',
            'atm_transfer_2',
            'lateral_transfer_3'
          )
      ]) {
        t.Date__c = LONGAGO;
        allRecordsToDelete.add(t);
      }
    }

    update allRecordsToDelete;

    jobId = TransactionCleanupScheduler.schedule(
      'myUniqueStringForTesting' + String.valueOf(Math.random())
    );
    Test.stopTest();

    for (Account a : TransactionCleanupService.getAccounts().values()) {
      actualPost.put(a.Name, a);
    }
    Map<String, Map<String, Double>> expectedPost = new Map<String, Map<String, Double>>{
      'test_checking' => new Map<String, Double>{
        'Balancing_Amount__c' => 1550,
        'Balance__c' => 1690
      },
      'test_savings' => new Map<String, Double>{
        'Balancing_Amount__c' => 400,
        'Balance__c' => 410
      },
      'test_card' => new Map<String, Double>{
        'Balancing_Amount__c' => 260,
        'Balance__c' => 75
      },
      'test_cash' => new Map<String, Double>{
        'Balancing_Amount__c' => 205,
        'Balance__c' => 415
      },
      'test_digital' => new Map<String, Double>{
        'Balancing_Amount__c' => 250,
        'Balance__c' => 270
      }
    };

    assertBalances(actualPost, expectedPost);

    Assert.isTrue(true, 'all asserts have passed; satisfy PMD');
  }

  static void assertBalances(
    Map<String, Account> actuals,
    Map<String, Map<String, Double>> expecteds
  ) {
    for (String accName : actuals.keySet()) {
      Map<String, Double> expected = expecteds.get(accName);
      Account actual = actuals.get(accName);
      for (String field : expected.keySet()) {
        Assert.areEqual(
          expected.get(field),
          actual.get(field),
          'actual field value should match expected value for account: ' +
          accName
        );
      }
    }
  }
}