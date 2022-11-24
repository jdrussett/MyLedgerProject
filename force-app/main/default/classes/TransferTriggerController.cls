public class TransferTriggerController {
    
    public static void addNewTransfers(List<Transfer__c> transfersFromTrigger) {
        List<Id> SourceAccountIds = new List<Id>();
        List<Id> TargetAccountIds = new List<Id>();
        
        // get lists of source and target account IDs
        for (Transfer__c t : transfersFromTrigger) {
            SourceAccountIds.add(t.Source_Account__c);
            TargetAccountIds.add(t.Target_Account__c);
        }

        // get all source and target account records
        List<Account> SourceAccounts = [SELECT Id, Total_Transfers_In__c, Total_Transfers_Out__c, Total_Card_Charges__c, Type
                                        FROM Account
                                        WHERE Id IN :SourceAccountIds];
        List<Account> TargetAccounts = [SELECT Id, Total_Transfers_In__c, Total_Transfers_Out__c, Total_Card_Charges__c, Type
                                        FROM Account
                                        WHERE Id IN :TargetAccountIds];

        Map<Id, Account> SourceAccountsMap = new Map<Id, Account>(SourceAccounts);
        Map<Id, Account> TargetAccountsMap = new Map<Id, Account>(TargetAccounts);

        for (Transfer__c t : transfersFromTrigger) {

            // lateral transfers
            if (t.Method__c == 'Card Payoff') {
                if (t.Source_Account__c != null) {
                    SourceAccountsMap.get(t.Source_Account__c).Total_Transfers_Out__c += t.Amount__c;
                }
                TargetAccountsMap.get(t.Target_Account__c).Total_Card_Charges__c += t.Amount__c;
            }
            else {
                if (t.Source_Account__c != null) {
                    SourceAccountsMap.get(t.Source_Account__c).Total_Transfers_Out__c += t.Amount__c;
                }
                TargetAccountsMap.get(t.Target_Account__c).Total_Transfers_In__c += t.Amount__c;
            }
        }
        List<Account> accountsToUpdate = new List<Account>{
            SourceAccountsMap.values(),
            TargetAccountsMap.values()
        };
        update accountsToUpdate;   
    }

    public static void revertPriorTransfers(List<Transfer__c> transfersFromTriggerMap) {

    }
    
    public static void deleteTransfers(List<Transfer__c> transfersFromTriggerMap) {

    }
}
