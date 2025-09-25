trigger TransferTrigger on Transfer__c(
  after insert,
  after update,
  after delete,
  after undelete
) {
  List<Transfer__c> allTransfers = new List<Transfer__c>();
  allTransfers.addAll(Trigger.New ?? new List<Transfer__c>());
  allTransfers.addAll(Trigger.Old ?? new List<Transfer__c>());
  TransferTriggerController.processTransfers(allTransfers);
}