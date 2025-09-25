public with sharing class TransferObject {
    // record type initialization
    public static final Map<String, Schema.RecordTypeInfo> RT_MAP;
    public static final Schema.RecordTypeInfo RT_CARDPAYOFF;
    public static final Schema.RecordTypeInfo RT_LATERAL;

    // static initialization
    static {
        RT_MAP = Account.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName();
        // RT_MAP = System.debug('mydebug :: rt map!: ' + Transfer__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName());
        RT_CARDTRANSFER = RT_MAP.get('Card_Payoff');
        RT_CARDTRANSFER = RT_MAP.get('Lateral_Transfer');
    }
}
