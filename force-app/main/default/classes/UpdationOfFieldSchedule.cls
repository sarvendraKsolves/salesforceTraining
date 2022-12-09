global class UpdationOfFieldSchedule implements Schedulable {
    /**we are implementing the Schedulable interface **/
    global static final String CRON_EXPR = '0 0 0 ? * *';
    global static String scheduleIt() {
        UpdationOfFieldSchedule job = new UpdationOfFieldSchedule();
        return System.schedule('Schedule the Account Email Batch', CRON_EXPR, job);
    }
    global void execute(SchedulableContext bc) {
        AccountEmailBatch b = new AccountEmailBatch();
        Database.executeBatch(b,10);
    }
}