@IsTest
private class TransferTriggerControllerTest {
    
    private static List<Transfer__c> createTestTransfers(Map<Account, Account> AccountMap) {
        List<Transfer__c> newTransfers = new List<Transfer__c>();
        Integer amt = 100;
        for (Account a : AccountMap.keySet()) {
            Integer i = 0;
            newTransfers.add(new Transfer(
                Amount__c = amt,
                RecordTypeId = (math.mod(i,2)==0) ? '012Dn000000tI9JIAU' : '012Dn000000tI9EIAU',
                Source_Account__c = a.Id,
                Target_Account__c = AccountMap.get(a).Id,
                Subject__c = 'Test Transfer Record ' + (i+1).format()
            ));
            amt += 50;
            I += 1;
        }
    }

    private static Map<Account, Account> createTestAccountPairs(Integer numPairs) {
        Map<Account, Account> sourceTargetPair = new Map<Account, Account>();
        List<Account> testSources = new List<Account>();
        List<Account> testTargets = new List<Account>();
        for (Integer i = 0; i < numPairs; i++) {
            Account sourceAccount = new Account(
                AccountNumber = Integer.valueOf(i.format().repeat(4)),
                Balance = 1000,
                Name = 'Test Source Account ' + (i+1).format(),
                Total_Transfers_In__c = 300,
                Total_Transfers_Out__c = 300
            );
            Account targetAccount = new Account(
                AccountNumber = Integer.valueOf((i+1).format().repeat(4)),
                Balance = 1000,
                Name = 'Test Target Account ' + (i+1).format(),
                Total_Transfers_In__c = 300,
                Total_Transfers_Out__c = 300
            );
            testSources.add(sourceAccount);
            testTargets.add(targetAccount);
        }
        System.debug('new lists of accounts: source list: ' + testSources + '; target list: ' + testTargets);
        try {
            insert testSources;
            insert testTargets;
        } catch (DmlException exc) {
            System.debug('could not insert test accounts: ' + exc);
        }
        for (Integer i=0; i < testSources.size(); i++) {
            sourceTargetPair.put(testSources[i], testTargets[i]);
        }
        return sourceTargetPair;
        System.debug('sourceTargetPair: ' + sourceTargetPair);
    }
}
