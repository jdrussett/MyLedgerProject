public class TransferTriggerController {
    
    public static void addNewTransfers(List<Transfer__c> transfersFromTrigger) {
        List<Map<Id,Account>> relatedAccounts = getRelatedAccounts(transfersFromTrigger);
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

        // get all source records
        Map<Id, Account> SourceAccountsMap = new Map<Id, Account>();
        for (Integer i = 0; i < SourceAccountIds.size(); i++) {
            if (SourceAccountIds[i] == null) {
                SourceAccountIds.remove(i);
            }
        }
        
        if (SourceAccountIds.size() > 0) {
            for (Account a : [SELECT Id, Total_Transfers_In__c, Total_Transfers_Out__c, Total_Card_Charges__c, Total_Charges_Stricken__c, Type
                              FROM Account
                              WHERE Id IN :SourceAccountIds]) {
                SourceAccountsMap.put(a.Id, a);
            }
        } 

        // get all target records
        Map<Id, Account> TargetAccountsMap = new Map<Id, Account>(
            [SELECT Id, Total_Transfers_In__c, Total_Transfers_Out__c, Total_Card_Charges__c, Total_Charges_Stricken__c, Type
             FROM Account
             WHERE Id IN :TargetAccountIds]
        );
        return new List<Map<Id,Account>>{SourceAccountsMap, TargetAccountsMap};
    }
}
