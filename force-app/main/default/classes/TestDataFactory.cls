@IsTest
public class TestDataFactory {
    public static Account CreateOneGeneralAccount(String accNum, String accName) {
        Account acc = new Account(
            AccountNumber = 'General' + accNum,
            Type = 'Checking Account',
            RecordTypeId = '012Dn000000tIWQIA2',
            Name = 'Test General Account ' + accName,
            Total_Transfers_In__c = 100,
            Total_Transfers_Out__c = 25,
            Total_Card_Charges__c = 25
        );
        insert acc;
        return acc;
    }
    
    public static Account CreateOneCreditCardAccount(String accName) {
        Account acc = new Account(
            AccountNumber = '456xyz credit',
            Type = 'Credit Card',
            RecordTypeId = '012Dn000000tIWLIA2',
            Name = 'Test Credit Card Account ' + accName,
            Total_Transfers_Out__c = 25
        );
        insert acc;
        return acc;
    }

    private static Map<Account, Account> createTestAccountPairs(Integer numPairs) {
        Map<Account, Account> sourceTargetPairs = new Map<Account, Account>();
        for (Integer i = 0; i < numPairs; i++) {
            sourceTargetPairs.put(
                new Account(
                    AccountNumber = i.format().repeat(4),
                    Name = 'Test Source Account ' + (i+1).format(),
                    Total_Transfers_In__c = 300,
                    Total_Transfers_Out__c = 300
                ),
                new Account(
                    AccountNumber = (i+1).format().repeat(4),
                    Name = 'Test Target Account ' + (i+1).format(),
                    Total_Transfers_In__c = 300,
                    Total_Transfers_Out__c = 300
                )
            );
        }
        System.debug('new lists of accounts: source list: ' + sourceTargetPairs.keySet() + '; target list: ' + sourceTargetPairs.values());
        try {
            insert new List<Account>(sourceTargetPairs.keySet());
            insert new List<Account>(sourceTargetPairs.values());
        } catch (DmlException exc) {
            System.debug('could not insert test accounts: ' + exc);
        }
        System.debug('sourceTargetPair: ' + sourceTargetPairs);
        return sourceTargetPairs;
    }

    public static Transfer__c createOneTransfer(
            Account source, 
            Account target, 
            Integer amount, 
            String transferName,
            String method
        ) {
        Transfer__c transfer = new Transfer__c(
            Amount__c = amount,
            Source_Account__c = source.Id,
            Target_Account__c = target.Id,
            Subject__c = transferName,
            Method__c = method
        );
        return transfer;
    }
    
    // public static List<Transfer__c> createMultipleTransfers(Map<Account, Account> AccountMap) {
    //     List<Transfer__c> newTransfers = new List<Transfer__c>();
    //     Integer amt = 100;
    //     for (Account a : AccountMap.keySet()) {
    //         Integer i = 0;
    //         newTransfers.add(new Transfer(
    //             Amount__c = amt,
    //             RecordTypeId = (math.mod(i,2)==0) ? '012Dn000000tI9JIAU' : '012Dn000000tI9EIAU',
    //             Source_Account__c = a.Id,
    //             Target_Account__c = AccountMap.get(a).Id,
    //             Subject__c = 'Test Transfer Record ' + (i+1).format()
    //         ));
    //         amt += 50;
    //         I += 1;
    //     }
    // }
}
