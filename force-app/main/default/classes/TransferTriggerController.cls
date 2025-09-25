public with sharing class TransferTriggerController extends TriggerHandler {
    private static Map<Id, Map<String, Double>> accountSubtotals = new Map<Id, Map<String, Double>>();

    private static final String F_TRANSFERS_IN = 'Total_Transfers_In__c';
    private static final String F_TRANSFERS_OUT = 'Total_Transfers_Out__c';
    private static final String F_CARD_CHARGES = 'Total_Card_Charges__c';
    private static final String F_STRICKEN_CHARGES = 'Total_Charges_Stricken__c';

    private static Map<Id, Double> transfersInToRecalculate = new Map<Id, Double>();
    private static Map<Id, Double> transfersOutToRecalculate = new Map<Id, Double>();
    private static Map<Id, Double> cardChargesToRecalculate = new Map<Id, Double>();
    private static Map<Id, Double> strickenChargesToRecalculate = new Map<Id, Double>();

    public static Map<Id, String> transferRecordTypes {
        get {
            if (transferRecordTypes == null) {
                transferRecordTypes = new Map<Id, String>();
                for (RecordType transferRecordType : [
                    SELECT Id, DeveloperName
                    FROM RecordType
                    WHERE SobjectType = 'Transfer__c'
                    WITH SYSTEM_MODE
                ]) {
                    transferRecordTypes.put(transferRecordType.Id, transferRecordType.DeveloperName);
                }
            }
            return transferRecordTypes;
        }
        set;
    }

    public static void processTransfers(List<Transfer__c> allTransfers) {
        for (Transfer__c t : allTransfers) {
            if (transferRecordTypes.get(t.RecordTypeId) == 'Lateral_Transfer') {
                transfersOutToRecalculate.put(t.Source_Account__c, 0);
                transfersInToRecalculate.put(t.Target_Account__c, 0);
            } else {
                (t.Method__c == 'Card Payoff' ? transfersInToRecalculate : strickenChargesToRecalculate)
                    .put(t.Target_Account__c, 0);
                cardChargesToRecalculate.put(t.Source_Account__c, 0);
            }
        }
        recalculateSubtotals();
        if (accountSubtotals.isEmpty() == false) {
            accountSubtotals.remove(null);
            updateSubtotals();
        }
    }

    private static void recalculateSubtotals() {
        if (transfersInToRecalculate.isEmpty() == false) {
            recalculateTransfersIn(transfersInToRecalculate);
        }

        if (transfersOutToRecalculate.isEmpty() == false) {
            recalculateTransfersOut(transfersOutToRecalculate);
        }

        if (cardChargesToRecalculate.isEmpty() == false) {
            recalculateCardCharges(cardChargesToRecalculate);
        }

        if (strickenChargesToRecalculate.isEmpty() == false) {
            recalculateStrickenCharges(strickenChargesToRecalculate);
        }
    }

    private static void updateSubtotals() {
        List<Account> accountsToUpdate = new List<Account>();
        for (Id accountId : accountSubtotals.keySet()) {
            Account newAccount = new Account(Id = accountId);
            Map<String, Double> fieldValues = accountSubtotals.get(accountId);
            for (String field : fieldValues.keySet()) {
                newAccount.put(field, fieldValues.get(field));
            }
            accountsToUpdate.add(newAccount);
        }
        update as system accountsToUpdate;
    }

    private static void recalculateTransfersIn(Map<Id, Double> accountIdMap) {
        Map<Id, Double> results = accountIdMap.clone();
        for (AggregateResult ar : [
            SELECT SUM(Amount__c) sum, Target_Account__c
            FROM Transfer__c
            WHERE
                ((RecordType.DeveloperName = 'Lateral_Transfer'
                AND Method__c IN ('ATM Withdrawal', 'Online Transfer', 'Venmo Transfer'))
                OR (RecordType.DeveloperName = 'Card_Payoff'
                AND Method__c = 'Card Payoff'))
                AND Target_Account__c IN :accountIdMap.keySet()
            WITH USER_MODE
            GROUP BY Target_Account__c
        ]) {
            results.put(String.valueOf(ar.get('Target_Account__c')), Double.valueOf(ar.get('sum')));
        }

        for (Id accId : results.keySet()) {
            if (accountSubtotals.containsKey(accId)) {
                accountSubtotals.get(accId).put(F_TRANSFERS_IN, results.get(accId));
            } else {
                accountSubtotals.put(accId, new Map<String, Double>{ F_TRANSFERS_IN => results.get(accId) });
            }
        }
    }

    private static void recalculateTransfersOut(Map<Id, Double> accountIdMap) {
        Map<Id, Double> results = accountIdMap.clone();
        for (AggregateResult ar : [
            SELECT SUM(Amount__c) sum, Source_Account__c
            FROM Transfer__c
            WHERE
                RecordType.DeveloperName = 'Lateral_Transfer'
                AND Method__c IN ('ATM Withdrawal', 'Online Transfer', 'Venmo Transfer')
                AND Source_Account__c IN :accountIdMap.keySet()
            WITH USER_MODE
            GROUP BY Source_Account__c
        ]) {
            results.put(String.valueOf(ar.get('Source_Account__c')), Double.valueOf(ar.get('sum')));
        }

        for (Id accId : results.keySet()) {
            if (accountSubtotals.containsKey(accId)) {
                accountSubtotals.get(accId).put(F_TRANSFERS_OUT, results.get(accId));
            } else {
                accountSubtotals.put(accId, new Map<String, Double>{ F_TRANSFERS_OUT => results.get(accId) });
            }
        }
    }

    private static void recalculateCardCharges(Map<Id, Double> accountIdMap) {
        Map<Id, Double> results = accountIdMap.clone();
        for (AggregateResult ar : [
            SELECT SUM(Amount__c) sum, Source_Account__c
            FROM Transfer__c
            WHERE
                RecordType.DeveloperName = 'Card_Payoff'
                AND Method__c = 'Card Payoff'
                AND Source_Account__c IN :accountIdMap.keySet()
            WITH USER_MODE
            GROUP BY Source_Account__c
        ]) {
            results.put(String.valueOf(ar.get('Source_Account__c')), Double.valueOf(ar.get('sum')));
        }

        for (Id accId : results.keySet()) {
            if (accountSubtotals.containsKey(accId)) {
                accountSubtotals.get(accId).put(F_CARD_CHARGES, results.get(accId));
            } else {
                accountSubtotals.put(accId, new Map<String, Double>{ F_CARD_CHARGES => results.get(accId) });
            }
        }
    }

    private static void recalculateStrickenCharges(Map<Id, Double> accountIdMap) {
        Map<Id, Double> results = accountIdMap.clone();
        for (AggregateResult ar : [
            SELECT SUM(Amount__c) sum, Target_Account__c
            FROM Transfer__c
            WHERE
                RecordType.DeveloperName = 'Card_Payoff'
                AND Method__c = 'Stricken Charge'
                AND Target_Account__c IN :accountIdMap.keySet()
            WITH USER_MODE
            GROUP BY Target_Account__c
        ]) {
            results.put(String.valueOf(ar.get('Target_Account__c')), Double.valueOf(ar.get('sum')));
        }

        for (Id accId : results.keySet()) {
            if (accountSubtotals.containsKey(accId)) {
                accountSubtotals.get(accId).put(F_STRICKEN_CHARGES, results.get(accId));
            } else {
                accountSubtotals.put(accId, new Map<String, Double>{ F_STRICKEN_CHARGES => results.get(accId) });
            }
        }
    }
}
