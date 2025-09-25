trigger TransferTrigger on Transfer__c (after insert, before update, after update, before delete) {
    if (Trigger.isInsert || (Trigger.isUpdate && Trigger.isAfter)) {
        TransferTriggerController.addNewTransfers(Trigger.new);
    }
    if ((Trigger.isUpdate && Trigger.isBefore) || Trigger.isDelete) {
        TransferTriggerController.revertPriorTransfers(Trigger.old);
    }
}