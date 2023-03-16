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
        // ADDING A COMMENT
    }
    
    public static Account CreateOneCreditCardAccount(String accName) {
        Account acc = new Account(
            AccountNumber = '456xyz credit',
            Type = 'Credit Card',
            RecordTypeId = '012Dn000000tIWLIA2',
            Name = 'Test Credit Card Account ' + accName,
            Total_Transfers_In__c = 75,
            Total_Charges_Stricken__c = 50
        );
        insert acc;
        return acc;
    }

    public static Map<Account, Account> createTestAccountPairs(Integer numPairs) {
        Map<Account, Account> sourceTargetPairs = new Map<Account, Account>();
        for (Integer i = 0; i < numPairs; i++) {
            sourceTargetPairs.put(
                new Account(
                    AccountNumber = ((2*(i+1))-1).format().repeat(4),
                    Name = 'Test Source Account ' + ((2*(i+1))-1).format(),
                    Total_Transfers_In__c = 1000,
                    Total_Transfers_Out__c = 300,
                    Total_Card_Charges__c = 300,
                    Type = 'Checking Account'
                ),
                new Account(
                    AccountNumber = (2*(i+1)).format().repeat(4),
                    Name = 'Test Target Account ' + (2*(i+1)).format(),
                    Total_Transfers_In__c = 1000,
                    Total_Charges_Stricken__c = 0,
                    Type = (math.mod((2*(i+1)),4) == 0) ? 'Credit Card' : 'Checking Account',
                    RecordTypeId = (math.mod((2*(i+1)),4) == 0) ? '012Dn000000tIWLIA2' : '012Dn000000tIWQIA2'
                )
            );
        }
        
        List<Account> accsToInsert = sourceTargetPairs.values().clone();
        accsToInsert.addAll(sourceTargetPairs.keySet());
        
        try {
            insert accsToInsert;
        } catch (DmlException exc) {
            System.debug('could not insert test accounts: ' + exc);
        }
        return sourceTargetPairs.clone();
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
    
    public static Transfer__c createOneTransferForInitialLoad(
            Account target, 
            Integer amount, 
            String transferName,
            String method
        ) {
        Transfer__c transfer = new Transfer__c(
            Amount__c = amount,
            Target_Account__c = target.Id,
            Subject__c = transferName,
            Method__c = method
        );
        return transfer;
    }
    
    public static List<Transfer__c> createMultipleTransfers(Map<Account, Account> AccountMap) {
        List<Transfer__c> newTransfers = new List<Transfer__c>();
        Integer amt = 100;
        Integer i = 1;
        for (Account a : new List<Account>(AccountMap.keySet())) {
            newTransfers.add(new Transfer__c(
                Amount__c = amt,
                RecordTypeId = (AccountMap.get(a).Type == 'Credit Card') ? '012Dn000000tI9JIAU' : '012Dn000000tI9EIAU',
                Method__c = (AccountMap.get(a).Type == 'Credit Card') ? 'Card Payoff' : 'Online Transfer',
                Source_Account__c = a.Id,
                Target_Account__c = AccountMap.get(a).Id,
                Subject__c = 'Test Transfer Record ' + (i).format()
            ));
            amt += 50;
            i += 1;
        }
        return newTransfers;
    }
}
