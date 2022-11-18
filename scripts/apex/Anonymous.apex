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
delete [SELECT Id FROM Account WHERE CreatedDate = TODAY];