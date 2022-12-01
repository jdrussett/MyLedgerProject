public class TransferTriggerController {
    
    public static void addNewTransfers(List<Transfer__c> transfersFromTrigger) {
        List<Map<Id,Account>> relatedAccounts = getRelatedAccounts(transfersFromTrigger);
        Map<Id, Account> SourceAccountsMap = relatedAccounts[0];
        Map<Id, Account> TargetAccountsMap = relatedAccounts[1];

        for (Transfer__c t : transfersFromTrigger) {

            // card payoffs
            if (t.Method__c == 'Card Payoff') {
                if (t.Source_Account__c != null) {
                    SourceAccountsMap.get(t.Source_Account__c).Total_Card_Charges__c += t.Amount__c;
                }
                TargetAccountsMap.get(t.Target_Account__c).Total_Transfers_In__c += t.Amount__c;
            }
            // lateral transfers
            else {
                if (t.Source_Account__c != null) {
                    SourceAccountsMap.get(t.Source_Account__c).Total_Transfers_Out__c += t.Amount__c;
                }
                TargetAccountsMap.get(t.Target_Account__c).Total_Transfers_In__c += t.Amount__c;
            }
        }
        
        List<Account> accountsToUpdate = new List<Account>();
        accountsToUpdate.addAll(SourceAccountsMap.values());
        accountsToUpdate.addAll(TargetAccountsMap.values());
        update accountsToUpdate;
    }

    public static void revertPriorTransfers(List<Transfer__c> transfersFromTrigger) {
        List<Map<Id,Account>> relatedAccounts = getRelatedAccounts(transfersFromTrigger);
        Map<Id, Account> SourceAccountsMap = relatedAccounts[0];
        Map<Id, Account> TargetAccountsMap = relatedAccounts[1];

        for (Transfer__c t : transfersFromTrigger) {

            // undo card payoffs
            if (t.Method__c == 'Card Payoff') {
                if (t.Source_Account__c != null) {
                    SourceAccountsMap.get(t.Source_Account__c).Total_Card_Charges__c -= t.Amount__c;
                }
                TargetAccountsMap.get(t.Target_Account__c).Total_Transfers_In__c -= t.Amount__c;
            }
            // undo lateral transfers
            else {
                if (t.Source_Account__c != null) {
                    SourceAccountsMap.get(t.Source_Account__c).Total_Transfers_Out__c -= t.Amount__c;
                }
                TargetAccountsMap.get(t.Target_Account__c).Total_Transfers_In__c -= t.Amount__c;
            }
        }

        List<Account> accountsToUpdate = new List<Account>();
        accountsToUpdate.addAll(SourceAccountsMap.values());
        accountsToUpdate.addAll(TargetAccountsMap.values());
        update accountsToUpdate;
    }

    private static List<Map<Id,Account>> getRelatedAccounts(List<Transfer__c> transfers) {
        List<Id> SourceAccountIds = new List<Id>();
        List<Id> TargetAccountIds = new List<Id>();

        // get lists of source and target account IDs
        for (Transfer__c t : transfers) {
            SourceAccountIds.add(t.Source_Account__c);
            TargetAccountIds.add(t.Target_Account__c);
        }
        System.debug('SourceAccountIds: ' + SourceAccountIds);
        System.debug('TargetAccountIds: ' + TargetAccountIds);

        // get all source records
        Map<Id, Account> SourceAccountsMap = new Map<Id, Account>();
        for (Integer i = 0; i < SourceAccountIds.size(); i++) {
            if (SourceAccountIds[i] == null) {
                SourceAccountIds.remove(i);
            }
        }
        if (SourceAccountIds.size() > 0) {
            for (Account a : [SELECT Id, Total_Transfers_In__c, Total_Transfers_Out__c, Total_Card_Charges__c, Type
                              FROM Account
                              WHERE Id IN :SourceAccountIds]) {
                SourceAccountsMap.put(a.Id, a);
                System.debug('current map key-value: ' + a.Id + ', ' + SourceAccountsMap.get(a.Id));
            }
        } 
        // handle initial loads/transfers into accounts to initialize a balance, if source accounts map is empty
        // else {
        //     Account tempAccount = new Account(
        //         Name = 'tempAccountToBeDeleted',
        //         AccountNumber = 'tempAccountToBeDeleted',
        //         Type = 'Other'
        //     );
        //     insert tempAccount;
        //     System.debug('tempAccount: ' + tempAccount);
        //     for (Integer i = 0; i < TargetAccountIds.size(); i++) {
        //         SourceAccountsMap.put(tempAccount.Id, tempAccount);
        //         System.debug('current map key-value: ' + tempAccount.Id + ', ' + SourceAccountsMap.get(tempAccount.Id));
        //     }
        // }

        // get all target records
        Map<Id, Account> TargetAccountsMap = new Map<Id, Account>(
            [SELECT Id, Total_Transfers_In__c, Total_Transfers_Out__c, Total_Card_Charges__c, Type
             FROM Account
             WHERE Id IN :TargetAccountIds]
        );
        System.debug('sourceAccountsMap: ' + SourceAccountsMap);
        System.debug('TargetAccountsMap: ' + TargetAccountsMap);
        return new List<Map<Id,Account>>{SourceAccountsMap, TargetAccountsMap};
    }
}
