// enter anonymous apex code to run here
// delete [select id from transfer__c];
// delete [select id from expense__c];
// Integer numPairs = 1;
// Map<Account, Account> sourceTargetPair = new Map<Account, Account>();
// List<Account> testSources = new List<Account>();
// List<Account> testTargets = new List<Account>();
// for (Integer i = 0; i < numPairs; i++) {
//     Account sourceAccount = new Account(
//         AccountNumber = i.format().repeat(4),
//         Name = 'Test Source Account ' + (i+1).format()
//     );
//     System.debug('new test source account: ' + sourceAccount);
//     Account targetAccount = new Account(
//         AccountNumber = (i+1).format().repeat(4),
//         Name = 'Test Target Account ' + (i+1).format()
//     );
//     System.debug('new test target account: ' + targetAccount);
//     testSources.add(sourceAccount);
//     testTargets.add(targetAccount);
// }
// System.debug('new lists of accounts: source list: ' + testSources + '; target list: ' + testTargets);
// try {
//     insert testSources;
//     insert testTargets;
// } catch (DmlException exc) {
//     System.debug('could not insert test accounts: ' + exc);
// }
// for (Integer i=0; i < testSources.size(); i++) {
//     sourceTargetPair.put(testSources[i], testTargets[i]);
// }
// System.debug('sourceTargetPair: ' + sourceTargetPair);
Map<String, Transfer__c> transferMap = new Map<String, Transfer__c>{
    'firstTransfer' => new Transfer__c(Subject__c = 'testacc1', Amount__c = 5),
    'secondTransfer' => new Transfer__c(Subject__c = 'testacc2', Amount__c = 3),
    'thirdTransfer' => new Transfer__c(Subject__c = 'testacc1', Amount__c = 9)
};

Map<String, Account> accountMap = new Map<String, Account>{
    'testacc1' => new Account(Name = 'test acc 1', Total_Transfers_In__c = 0),
    'testacc2' => new Account(Name = 'test acc 2', Total_Transfers_In__c = 0)
};

for (String s : transferMap.keySet()) {
    if (accountMap.containsKey(transferMap.get(s).Subject__c)) {
        accountMap.get(transferMap.get(s).Subject__c).Total_Transfers_In__c += transferMap.get(s).Amount__c;
    }
}
System.debug('accountMap: ' + accountMap);