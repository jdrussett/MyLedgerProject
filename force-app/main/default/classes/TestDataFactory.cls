@IsTest
public class TestDataFactory {
    public static Account CreateOneGeneralAccount() {
        Account acc = new Account(
            AccountNumber = '123abc general',
            Type = 'Checking Account',
            RecordTypeId = '012Dn000000tIWQIA2'
        );
        insert acc;
        return acc;
    }
    
    public static Account CreateOneCreditCardAccount() {
        Account acc = new Account(
            AccountNumber = '456xyz credit',
            Type = 'Credit Card',
            RecordTypeId = '012Dn000000tIWLIA2'
        );
        insert acc;
        return acc;
    }

    public static Transfer__c createOneTransfer(Account source, Account target, Integer amount, String transferName) {
        Transfer__c transfer = new Transfer__c(
            Amount__c = amount,
            Source_Account__c = source.Id,
            Target_Account__c = target.Id,
            Subject__c = transferName
        );
    }
    
    public static List<Transfer__c> createMultipleTransfers(Map<Account, Account> AccountMap) {
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
}
