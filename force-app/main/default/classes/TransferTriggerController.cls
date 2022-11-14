public class TransferTriggerController {
    public void newTransfers(Map<Id, Transfer__c> transfersFromTriggerMap) {
        List<Id> SourceAccountIds = new List<Account>();
        List<Id> TargetAccountIds = new List<Account>();
        
        for (Id t : transfersFromTriggerMap.keySet()) {
            SourceAccountIds.add(transfersFromTriggerMap.get(t).Source_Account__c);
            TargetAccountIds.add(transfersFromTriggerMap.get(t).Target_Account__c);
        }

        // get all source and target account records
        List<Account> SourceAccounts = [SELECT Id, Total_Transfers_In__c, Total_Transfers_Out__c
                                        FROM Account
                                        WHERE Id IN :SourceAccountIds];
        List<Account> TargetAccounts = [SELECT Id, Total_Transfers_In__c, Total_Transfers_Out__c
                                        FROM Account
                                        WHERE Id IN :TargetAccountIds];

        Map<Id, Account> SourceAccountsMap = new Map<Id, Account>(SourceAccounts);
        Map<Id, Account> TargetAccountsMap = new Map<Id, Account>(TargetAccounts);

        for (Id t : transfersFromTriggerMap.keySet()) {
            if (SourceAccountsMap.containsKey(transfersFromTriggerMap.get(t).Source_Account__c)) {
                SourceAccountsMap.get(transfersFromTriggerMap.get(t).Source_Account__c).Total_Transfers_Out__c += 
                transfersFromTriggerMap.get(t).Amount__c;
            }
        }
        
    }
    public void updateTransfers(List<Transfer__c> transfersFromTriggerMap) {

    }
    public void deleteTransfers(List<Transfer__c> transfersFromTriggerMap) {

    }
}
