trigger TransferTrigger on SOBJECT (after insert, after update, after delete) {
    if (Trigger.isInsert) {
        TransferTriggerController.newTransfers(Trigger.newMap);
    }
    if (Trigger.isUpdate) {
        TransferTriggerController.updateTransfers(Trigger.newMap);
    }
    if (Trigger.isDelete) {
        TransferTriggerController.deleteTransfers(Trigger.newMap);
    }
}