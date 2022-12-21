public class TransferTriggerController {
    
    public static void addNewTransfers(List<Transfer__c> transfersFromTrigger) {
        Map<Id,Account> relatedAccounts = getRelatedAccounts(transfersFromTrigger);
        System.debug('MYDEBUG9 :: relatedAccounts: ' + relatedAccounts);

        for (Transfer__c t : transfersFromTrigger) {
            if (t.Source_Account__c != null) {
                if (t.Method__c == 'Card Payoff') {
                    relatedAccounts.get(t.Source_Account__c).Total_Card_Charges__c += t.Amount__c;
                } else {
                    relatedAccounts.get(t.Source_Account__c).Total_Transfers_Out__c += t.Amount__c;
                }
            }
            if (t.Method__c == 'Stricken Charge') {
                relatedAccounts.get(t.Target_Account__c).Total_Charges_Stricken__c += t.Amount__c;
            } else {
                relatedAccounts.get(t.Target_Account__c).Total_Transfers_In__c += t.Amount__c;
            }
        }
        
        update new List<Account>(relatedAccounts.values());
    }

    public static void revertPriorTransfers(List<Transfer__c> transfersFromTrigger) {
        Map<Id,Account> relatedAccounts = getRelatedAccounts(transfersFromTrigger);

        for (Transfer__c t : transfersFromTrigger) {
            if (t.Source_Account__c != null) {
                if (t.Method__c == 'Card Payoff') {
                    relatedAccounts.get(t.Source_Account__c).Total_Card_Charges__c -= t.Amount__c;
                }
                else {
                    relatedAccounts.get(t.Source_Account__c).Total_Transfers_Out__c -= t.Amount__c;
                }
            }
            if (t.Method__c == 'Stricken Charge') {
                relatedAccounts.get(t.Target_Account__c).Total_Charges_Stricken__c -= t.Amount__c;
            } else {
                relatedAccounts.get(t.Target_Account__c).Total_Transfers_In__c -= t.Amount__c;
            }
        }

        update new List<Account>(relatedAccounts.values());
    }

    private static Map<Id,Account> getRelatedAccounts(List<Transfer__c> transfers) {
        Set<Id> AccountIds = new Set<Id>();

        // get lists of source and target account IDs
        for (Transfer__c t : transfers) {
            AccountIds.add(t.Source_Account__c);
            AccountIds.add(t.Target_Account__c);
            System.debug('MYDEBUG6 :: AccountIds: ' + AccountIds);
        }

        // get all sources and targets
        Map<Id, Account> AccountsMap = new Map<Id, Account>();
        if (AccountIds.size() > 0) {
            for (Account a : [SELECT Id, Name, AccountNumber, Total_Transfers_In__c, Total_Transfers_Out__c,
                              Total_Card_Charges__c, Total_Charges_Stricken__c, Type
                              FROM Account
                              WHERE Id IN :AccountIds]) {
                AccountsMap.put(a.Id, a);
                System.debug('MYDEBUG7 :: sourceAccountsMap.get(a): ' + a);
            }
        } 

        return AccountsMap;
    }
}
