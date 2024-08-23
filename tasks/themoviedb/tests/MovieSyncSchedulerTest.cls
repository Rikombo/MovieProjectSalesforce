@isTest
private class MovieSyncSchedulerTest {

    @isTest
    static void testExecute() {
        String cronExp = '0 ' + (DateTime.now().minute() + 1) + ' * * * ?';

        Test.startTest();
        
        String jobId = System.schedule('Test Movie Sync', cronExp, new MovieSyncScheduler());
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime 
                          FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(cronExp, ct.CronExpression, 'Cron expression does not match');
        System.assertEquals(0, ct.TimesTriggered, 'Job should not have triggered yet');
        
        Test.stopTest();
        
        Id movieSyncBatchClassId = [SELECT Id FROM ApexClass WHERE Name = 'MovieSyncBatch' LIMIT 1].Id;
        
        List<AsyncApexJob> jobs = [SELECT Id, Status, JobItemsProcessed, NumberOfErrors 
                                   FROM AsyncApexJob 
                                   WHERE JobType = 'BatchApex' 
                                   AND ApexClassId = :movieSyncBatchClassId];
        System.assertEquals(1, jobs.size(), 'One batch job should have been executed');
        System.assertEquals('Completed', jobs[0].Status, 'Batch job should have completed successfully');
        System.assertEquals(0, jobs[0].NumberOfErrors, 'There should be no errors in the batch job');
    }
}
