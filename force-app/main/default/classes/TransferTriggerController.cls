public class TransferTriggerController {
    public void newTransfers(List<Transfer__c> transfersFromTrigger) {
        List<Id> SourceAccountIds = new List<Account>();
        List<Id> TargetAccountIds = new List<Account>();
        
        // get lists of source and target account IDs
        for (Transfer__c t : transfersFromTrigger) {
            SourceAccountIds.add(transfersFromTrigger.Source_Account__c);
            TargetAccountIds.add(transfersFromTrigger.Target_Account__c);
        }

        // get all source and target account records
        List<Account> SourceAccounts = [SELECT Id, Total_Transfers_In__c, Total_Transfers_Out__c, Type
                                        FROM Account
                                        WHERE Id IN :SourceAccountIds];
        List<Account> TargetAccounts = [SELECT Id, Total_Transfers_In__c, Total_Transfers_Out__c, Type
                                        FROM Account
                                        WHERE Id IN :TargetAccountIds];

        Map<Id, Account> SourceAccountsMap = new Map<Id, Account>(SourceAccounts);
        Map<Id, Account> TargetAccountsMap = new Map<Id, Account>(TargetAccounts);

        // for (Id t : transfersFromTrigger) {
        //     if (SourceAccountsMap.containsKey(t.Source_Account__c)) {
        //         SourceAccountsMap.get(t.Source_Account__c).Total_Transfers_Out__c += t.Amount__c;
        //     }
        // }
        // 
        // scenarios:

        for (Transfer__c t : transfersFromTrigger) {

            // lateral transfers
            if (SourceAccountsMap.containsKey(t.Source_Account__c)) {
                SourceAccountsMap.get(t.Source_Account__c).Total_Transfers_Out__c += t.Amount__c;
            }
            if (TargetAccountsMap.containsKey(t.Target_Account__c) && t.Method__c != 'Card Payoff') {
                
            }
        }
        
    }
    public void updateTransfers(List<Transfer__c> transfersFromTriggerMap) {

    }
    public void deleteTransfers(List<Transfer__c> transfersFromTriggerMap) {

    }
}
