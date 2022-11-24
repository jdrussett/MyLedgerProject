trigger TransferTrigger on Transfer__c (after insert, before update, after update, after delete) {
    if (Trigger.isInsert || (Trigger.isUpdate && Trigger.isAfter)) {
        TransferTriggerController.addNewTransfers(Trigger.new);
    }
    if (Trigger.isUpdate || Trigger.isBefore) {
        TransferTriggerController.revertPriorTransfers(Trigger.new);
    }
    if (Trigger.isDelete) {
        TransferTriggerController.deleteTransfers(Trigger.new);
    }
}