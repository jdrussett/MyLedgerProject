public class TransferTriggerController_Old {
    
    public static void addNewTransfers(List<Transfer__c> transfersFromTrigger) {
        List<Map<Id,Account>> relatedAccounts = getRelatedAccounts(transfersFromTrigger);
        System.debug('MYDEBUG11 :: relatedAccounts: ' + relatedAccounts);
        Map<Id, Account> SourceAccountsMap = relatedAccounts[0];
        Map<Id, Account> TargetAccountsMap = relatedAccounts[1];

        for (Transfer__c t : transfersFromTrigger) {
            if (t.Source_Account__c != null) {
                if (t.Method__c == 'Card Payoff') {
                    SourceAccountsMap.get(t.Source_Account__c).Total_Card_Charges__c += t.Amount__c;
                } else {
                    SourceAccountsMap.get(t.Source_Account__c).Total_Transfers_Out__c += t.Amount__c;
                }
            }
            if (t.Method__c == 'Stricken Charge') {
                TargetAccountsMap.get(t.Target_Account__c).Total_Charges_Stricken__c += t.Amount__c;
            } else {
                TargetAccountsMap.get(t.Target_Account__c).Total_Transfers_In__c += t.Amount__c;
            }
        }
        
        Set<Account> accountsToUpdate = new Set<Account>();
        accountsToUpdate.addAll(SourceAccountsMap.values());
        for (Account a : SourceAccountsMap.values()) {
            System.debug('MYDEBUG12 :: updated source account: ' + a);
        }
        accountsToUpdate.addAll(TargetAccountsMap.values());
        for (Account a : TargetAccountsMap.values()) {
            System.debug('MYDEBUG13 :: updated target account: ' + a);
        }
        update new List<Account>(accountsToUpdate);
    }

    public static void revertPriorTransfers(List<Transfer__c> transfersFromTrigger) {
        List<Map<Id,Account>> relatedAccounts = getRelatedAccounts(transfersFromTrigger);
        Map<Id, Account> SourceAccountsMap = relatedAccounts[0];
        Map<Id, Account> TargetAccountsMap = relatedAccounts[1];

        for (Transfer__c t : transfersFromTrigger) {
            if (t.Source_Account__c != null) {
                if (t.Method__c == 'Card Payoff') {
                    SourceAccountsMap.get(t.Source_Account__c).Total_Card_Charges__c -= t.Amount__c;
                }
                else {
                    SourceAccountsMap.get(t.Source_Account__c).Total_Transfers_Out__c -= t.Amount__c;
                }
            }
            if (t.Method__c == 'Stricken Charge') {
                TargetAccountsMap.get(t.Target_Account__c).Total_Charges_Stricken__c -= t.Amount__c;
            } else {
                TargetAccountsMap.get(t.Target_Account__c).Total_Transfers_In__c -= t.Amount__c;
            }
        }

        Set<Account> accountsToUpdate = new Set<Account>();
        accountsToUpdate.addAll(SourceAccountsMap.values());
        accountsToUpdate.addAll(TargetAccountsMap.values());
        update new List<Account>(accountsToUpdate);
    }

    private static List<Map<Id,Account>> getRelatedAccounts(List<Transfer__c> transfers) {
        Set<Id> SourceAccountIds = new Set<Id>();
        Set<Id> TargetAccountIds = new Set<Id>();

        // get lists of source and target account IDs
        for (Transfer__c t : transfers) {
            if (t.Source_Account__c != null) {
                SourceAccountIds.add(t.Source_Account__c);
            }
            System.debug('MYDEBUG6 :: sourceAccountIds: ' + SourceAccountIds);
            TargetAccountIds.add(t.Target_Account__c);
            System.debug('MYDEBUG7 :: targetAccountIds: ' + TargetAccountIds);
        }

        // get all source records
        Map<Id, Account> SourceAccountsMap = new Map<Id, Account>();
        if (SourceAccountIds.size() > 0) {
            for (Account a : [SELECT Id, Total_Transfers_In__c, Total_Transfers_Out__c, Total_Card_Charges__c, Total_Charges_Stricken__c, Type
                              FROM Account
                              WHERE Id IN :SourceAccountIds]) {
                SourceAccountsMap.put(a.Id, a);
                System.debug('MYDEBUG8 :: sourceAccountsMap.get(a): ' + a);
            }
        } 

        // get all target records
        Map<Id, Account> TargetAccountsMap = new Map<Id, Account>(
            [SELECT Id, Total_Transfers_In__c, Total_Transfers_Out__c, Total_Card_Charges__c, Total_Charges_Stricken__c, Type
             FROM Account
             WHERE Id IN :TargetAccountIds]
        );
        for (Id i : TargetAccountsMap.keySet()) {
            System.debug('MYDEBUG9 :: i: ' + i);
            System.debug('MYDEBUG10 :: TargetAccountsMap.get(i): ' + TargetAccountsMap.get(i));
        }
        return new List<Map<Id,Account>>{SourceAccountsMap, TargetAccountsMap};
    }
}
