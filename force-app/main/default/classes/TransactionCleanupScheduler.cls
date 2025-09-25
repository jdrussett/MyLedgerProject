public with sharing class TransactionCleanupScheduler implements Schedulable {
  private static final String JOB_NAME = 'Transaction Cleanup Service';
  private static final String CRON_EXPRESSION = '0 0 4 1 * ?';

  public static void execute(SchedulableContext ctx) {
    TransactionCleanupService.run();
  }

  public static String schedule(String unique) {
    return System.schedule(JOB_NAME + unique, CRON_EXPRESSION, new TransactionCleanupScheduler());
  }
}