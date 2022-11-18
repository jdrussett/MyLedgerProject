@IsTest
private class TransferTriggerControllerTest {
    
    private static List<Transfer__c> createTestTransfers(Map<Id, Id> AccountMap) {
        List<Transfer__c> newTransfers = new List<Transfer__c>();
        Integer amt = 100;
        for (Id i : AccountMap.keySet()) {
            newTransfers.add(new Transfer(

            ));
            amt += 50;
        }
    }
}
