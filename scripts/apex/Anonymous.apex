// -----------------------------------------------------------------------------------------------------------------
// delete [select id from transfer__c];
// delete [select id from expense__c];
// Integer numPairs = 1;
// -----------------------------------------------------------------------------------------------------------------
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
// // -----------------------------------------------------------------------------------------------------------------
// Map<String, Transfer__c> transferMap = new Map<String, Transfer__c>{
//     'firstTransfer' => new Transfer__c(Subject__c = 'testacc1', Amount__c = 5),
//     'secondTransfer' => new Transfer__c(Subject__c = 'testacc2', Amount__c = 3),
//     'thirdTransfer' => new Transfer__c(Subject__c = 'testacc1', Amount__c = 9)
// };

// Map<String, Account> accountMap = new Map<String, Account>{
//     'testacc1' => new Account(Name = 'test acc 1', Total_Transfers_In__c = 0),
//     'testacc2' => new Account(Name = 'test acc 2', Total_Transfers_In__c = 0)
// };

// insert accountMap.values();

// for (String s : transferMap.keySet()) {
//     if (accountMap.containsKey(transferMap.get(s).Subject__c)) {
//         accountMap.get(transferMap.get(s).Subject__c).Total_Transfers_In__c += transferMap.get(s).Amount__c;
//     }
// }
// update accountMap.values();
// System.debug('accountMap: ' + accountMap);
// -----------------------------------------------------------------------------------------------------------------
// Map<Account, Account> accountMap = new Map<Account, Account> {
//     new Account(Name = 'test key account 1', AccountNumber = '1111') => new Account(Name = 'test value account 1', AccountNumber = '2222'),
//     new Account(Name = 'test key account 2', AccountNumber = '3333') => new Account(Name = 'test value account 2', AccountNumber = '4444'),
//     new Account(Name = 'test key account 3', AccountNumber = '5555') => new Account(Name = 'test value account 3', AccountNumber = '6666')
// };
// for (Account a : accountMap.keySet()) {
//     System.debug('current key: ' + a);
//     System.debug('current value: ' + accountMap.get(a));
// }
// List<Account> accsToInsert = accountMap.values().clone();
// accsToInsert.addAll(accountMap.keySet());
// insert accsToInsert;
// for (Account a : accountMap.keySet()) {
//     System.debug('current key: ' + a);
//     System.debug('current value: ' + accountMap.get(a));
// }
// System.debug('accountMap.clone(): ' + accountMap.clone());
// Map<Account, Account> cloneAccountMap = accountMap.clone();
// for (Account a : cloneAccountMap.keySet()) {
//     System.debug('current key: ' + a);
//     System.debug('current value: ' + cloneAccountMap.get(a));
// }
// System.debug('accountMap.deepclone(): ' + accountMap.deepClone());
// delete accsToInsert;
// -----------------------------------------------------------------------------------------------------------------
// Map<String, String> newMap = new Map<String, String>{
//     'a key' => 'a key',
//     null => 'another key'
// };
// System.debug('newMap: ' + newMap);
// System.debug('newMap')
// -----------------------------------------------------------------------------------------------------------------
Set<String> set1 = new Set<String>();
List<String> list1 = new List<String>();
list1.add('value1');
list1.add('value2');
list1.add('value2');
list1.add('value3');
list1.add('value3');
list1.add('value3');
List<String> list2 = new List<String>();
list1.add('value3');
list1.add('value3');
list1.add('value4');
list1.add('value5');
list1.add('value6');
list1.add('value6');
set1.addAll(list1);
set1.addAll(list2);
System.debug('new List<String>(set1): ' + new List<String>(set1));