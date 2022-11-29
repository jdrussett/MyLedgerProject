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
        List<Account> updatedAccounts = [SELECT Id, AccountNumber, Balance__c FROM Account];
        System.assertEquals(updatedAccounts.size(), 6);
        for (Account a : updatedAccounts) {
            switch on a.AccountNumber {
                when '1111' {
                    System.assertEquals(a.Balance__c, 300);
                }
                when '2222' {
                    System.assertEquals(a.Balance__c, 1100);
                }
                when '3333' {
                    System.assertEquals(a.Balance__c, 250);
                }
                when '4444' {
                    System.assertEquals(a.Balance__c, -1150);
                }
                when '5555' {
                    System.assertEquals(a.Balance__c, 200);
                }
                when '6666' {
                    System.assertEquals(a.Balance__c, 1200);
                }
            }
        }
        Test.stopTest();
    }
}