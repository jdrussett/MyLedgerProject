@IsTest
public class TransferTriggerControllerTest {
    
    @isTest
    static void addNewTransfersTest_OneRecord_Lateral() {
        Account testSource = TestDataFactory.CreateOneGeneralAccount('001', 'Source');
        Account testTarget = TestDataFactory.CreateOneGeneralAccount('002', 'Target');
        Transfer__c testTransfer = TestDataFactory.createOneTransfer(testSource, testTarget, 25, 'test_transfer', 'Online Transfer');
        Test.startTest();
        TransferTriggerController.addNewTransfers(new List<Transfer__c>{testTransfer});
        Account updatedSource = [SELECT Id, Total_Transfers_Out__c, AccountNumber
                                 FROM Account
                                 WHERE AccountNumber = 'General001'][0];
        Account updatedTarget = [SELECT Id, Total_Transfers_In__c, AccountNumber
                                 FROM Account
                                 WHERE AccountNumber = 'General002'][0];
        System.assertEquals(updatedSource.Total_Transfers_Out__c, 50);
        System.assertEquals(updatedTarget.Total_Transfers_In__c, 125);
        Test.stopTest();
    }

    @isTest
    static void addNewTransfersTest_multipleTransfers(){
        Map<Account, Account> testAcctsMap = TestDataFactory.createTestAccountPairs(3);
        List<Transfer__c> testTransfers = TestDataFactory.createMultipleTransfers(testAcctsMap);
        Test.startTest();
        TransferTriggerController.addNewTransfers(testTransfers);
        List<Account> updatedAccounts = [SELECT Id, AccountNumber, Total_Transfers_Out__c, Total_Card_Charges__c, Balance__c FROM Account];
        System.assertEquals(updatedAccounts.size(), 6);
        for (Account a : updatedAccounts) {
            switch on a.AccountNumber {
                when '1111' {
                    System.assertEquals(a.Total_Transfers_Out__c, 400);
                    System.assertEquals(a.Balance__c, 300);
                }
                when '2222' {
                    System.assertEquals(a.Balance__c, 1100);
                }
                when '3333' {
                    System.assertEquals(a.Total_Card_Charges__c, 450);
                    System.assertEquals(a.Balance__c, 250);
                }
                when '4444' {
                    System.assertEquals(a.Balance__c, -1150);
                }
                when '5555' {
                    System.assertEquals(a.Total_Transfers_Out__c, 500);
                    System.assertEquals(a.Balance__c, 200);
                }
                when '6666' {
                    System.assertEquals(a.Balance__c, 1200);
                }
            }
        }
        Test.stopTest();
    }

    @isTest
    static void revertPriorTransfersTest_multipleTransfers() {
        Map<Account, Account> testAcctsMap = TestDataFactory.createTestAccountPairs(2);
        List<Transfer__c> testTransfers = TestDataFactory.createMultipleTransfers(testAcctsMap);
        Test.startTest();
        TransferTriggerController.revertPriorTransfers(testTransfers);
        List<Account> updatedAccounts = [SELECT Id, AccountNumber, Total_Transfers_Out__c, Total_Card_Charges__c, Balance__c 
                                         FROM Account];
        System.assertEquals(updatedAccounts.size(), 4);
        for (Account a : updatedAccounts) {
            switch on a.AccountNumber {
                when '1111' {
                    System.assertEquals(a.Total_Transfers_Out__c, 200);
                    System.assertEquals(a.Balance__c, 500);
                }
                when '2222' {
                    System.assertEquals(a.Balance__c, 900);
                }
                when '3333' {
                    System.assertEquals(a.Total_Card_Charges__c, 150);
                    System.assertEquals(a.Balance__c, 550);
                }
                when '4444' {
                    System.assertEquals(a.Balance__c, -850);
                }
            }
        }
        Test.stopTest();
    }

    @isTest
    static void addNewTransfersTest_InitialLoad() {
        Account testTarget = TestDataFactory.CreateOneGeneralAccount('1111', 'initial load 1');
        Transfer__c testTransfer = TestDataFactory.createOneTransferForInitialLoad(testTarget, 100, 'test initial load', null);
        Test.startTest();
        TransferTriggerController.addNewTransfers(new List<Transfer__c>{testTransfer});
        Account updatedTarget = [SELECT Id, Total_Transfers_In__c, AccountNumber
                                 FROM Account
                                 WHERE AccountNumber = 'General1111'][0];
        System.assertEquals(updatedTarget.Total_Transfers_In__c, 200);
        Test.stopTest();
    }

    @isTest
    static void addNewTransfersTest_strickenCharge() {
        Account testAcc = TestDataFactory.CreateOneCreditCardAccount('TestCard123');
        Transfer__c testTransfer = TestDataFactory.createOneTransferForInitialLoad(
            testAcc, 25, 'Test Stricken Charge', 'Stricken Charge'
        );
        Test.startTest();
        TransferTriggerController.addNewTransfers(new List<Transfer__c>{testTransfer});
        Account updatedTarget = [SELECT Id, Total_Charges_Stricken__c, Name
                                 FROM Account
                                 WHERE Name = 'Test Credit Card Account TestCard123'];
        System.assertEquals(updatedTarget.Total_Charges_Stricken__c, 75);
        Test.stopTest();
    }

    @isTest
    static void revertPriorTransfersTest_strickenCharge() {
        Account testAcc = TestDataFactory.CreateOneCreditCardAccount('TestCard123');
        Transfer__c testTransfer = TestDataFactory.createOneTransferForInitialLoad(
            testAcc, 25, 'Test Stricken Charge', 'Stricken Charge'
        );
        Test.startTest();
        TransferTriggerController.revertPriorTransfers(new List<Transfer__c>{testTransfer});
        Account updatedTarget = [SELECT Id, Total_Charges_Stricken__c, Name
                                 FROM Account
                                 WHERE Name = 'Test Credit Card Account TestCard123'];
        System.assertEquals(updatedTarget.Total_Charges_Stricken__c, 25);
        Test.stopTest();
    }

    @isTest
    static void addNewTransfersTest_OneAccountMultipleAppearances() {
        Account testChecking = TestDataFactory.CreateOneGeneralAccount('111', 'testchecking');
        System.debug('MYDEBUG1 :: testchecking: ' + testchecking);
        Account testCheckingtwo = TestDataFactory.CreateOneGeneralAccount('222', 'testcheckingtwo');
        System.debug('MYDEBUG2 :: testCheckingtwo: ' + testCheckingtwo);
        Account testSavings = TestDataFactory.CreateOneGeneralAccount('333', 'testsaving');
        System.debug('MYDEBUG3 :: testSavings: ' + testSavings);
        Account testCard = TestDataFactory.CreateOneCreditCardAccount('testCard');
        System.debug('MYDEBUG4 :: testCard: ' + testCard);
        Transfer__c transfer1 = TestDataFactory.createOneTransfer(testChecking, testCard, 20, 'test transfer 1', 'Card Payoff');
        Transfer__c transfer2 = TestDataFactory.createOneTransfer(testChecking, testCheckingtwo, 25, 'test transfer 2', 'Online Transfer');
        Transfer__c transfer3 = TestDataFactory.createOneTransfer(testCheckingtwo, testSavings, 30, 'test transfer 3', 'Online Transfer');
        List<Transfer__c> newTransfers = new List<Transfer__c>{transfer1, transfer2, transfer3};
        for (Transfer__c t : newTransfers) {
            System.debug('MYDEBUG5 :: current transfer: ' + t);
        }
        TransferTriggerController.addNewTransfers(newTransfers);
        Account updated_testchecking = [SELECT Id, Name, AccountNumber, Type, Total_Transfers_In__c,
                                        Total_Transfers_Out__c, Total_Card_Charges__c, Total_Charges_Stricken__c
                                        FROM Account
                                        WHERE Name = 'Test General Account testchecking'][0];
        Account updated_testcheckingtwo = [SELECT Id, Name, AccountNumber, Type, Total_Transfers_In__c,
                                           Total_Transfers_Out__c, Total_Card_Charges__c, Total_Charges_Stricken__c
                                           FROM Account
                                           WHERE Name = 'Test General Account testcheckingtwo'][0];
        Account updated_testSavings = [SELECT Id, Name, AccountNumber, Type, Total_Transfers_In__c,
                                       Total_Transfers_Out__c, Total_Card_Charges__c, Total_Charges_Stricken__c
                                       FROM Account
                                       WHERE Name = 'Test General Account testsaving'][0];
        Account updated_testCard = [SELECT Id, Name, AccountNumber, Type, Total_Transfers_In__c,
                                    Total_Transfers_Out__c, Total_Card_Charges__c, Total_Charges_Stricken__c
                                    FROM Account
                                    WHERE Name = 'Test Credit Card Account testCard'][0];

        System.assertEquals(updated_testchecking.Total_Transfers_In__c, 100);
        System.assertEquals(updated_testchecking.Total_Card_Charges__c, 45);
        System.assertEquals(updated_testchecking.Total_Transfers_Out__c, 50);
        
        System.assertEquals(updated_testcheckingtwo.Total_Transfers_In__c, 125);
        System.assertEquals(updated_testcheckingtwo.Total_Card_Charges__c, 25);
        System.assertEquals(updated_testcheckingtwo.Total_Transfers_Out__c, 55);
        
        System.assertEquals(updated_testSavings.Total_Transfers_In__c, 130);
        System.assertEquals(updated_testSavings.Total_Card_Charges__c, 25);
        System.assertEquals(updated_testSavings.Total_Transfers_Out__c, 25);
        
        System.assertEquals(updated_testCard.Total_Transfers_In__c, 95);
        System.assertEquals(updated_testCard.Total_Charges_Stricken__c, 50);
    }
}