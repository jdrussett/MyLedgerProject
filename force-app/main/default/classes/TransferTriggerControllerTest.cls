@IsTest
public class TransferTriggerControllerTest {
    
    @isTest
    static void addNewTransfersTest_OneRecord_Lateral() {
        Account testSource = TestDataFactory.CreateOneGeneralAccount('001', 'Source');
        System.debug('testSource account: ' + testSource);
        Account testTarget = TestDataFactory.CreateOneGeneralAccount('002', 'Target');
        System.debug('testTarget account: ' + testTarget);
        Transfer__c testTransfer = TestDataFactory.createOneTransfer(testSource, testTarget, 25, 'test_transfer', 'Online Transfer');
        System.debug('testTransfer: ' + testTransfer);
        List<Transfer__c> transferList = new List<Transfer__c>{testTransfer};
        Test.startTest();
        TransferTriggerController.addNewTransfers(transferList);
        Account updatedSource = [SELECT Id, Total_Transfers_Out__c, AccountNumber
                                 FROM Account
                                 WHERE AccountNumber = 'General001'][0];
        Account updatedTarget = [SELECT Id, Total_Transfers_In__c, AccountNumber
                                 FROM Account
                                 WHERE AccountNumber = 'General002'][0];
        System.assert(updatedSource.Total_Transfers_Out__c == 50);
        System.assert(updatedTarget.Total_Transfers_In__c == 125);
        Test.stopTest();
    }

    @isTest
    static void addNewTransfersTest_multipleTransfers(){
        
    }
}
