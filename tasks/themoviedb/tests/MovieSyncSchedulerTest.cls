@isTest
private class MovieSyncSchedulerTest {

    @isTest
    static void testExecute() {
        // Set the schedule to run 1 minute from now
        String cronExp = '0 ' + (DateTime.now().minute() + 1) + ' * * * ?';

        // Start test context
        Test.startTest();
        
        // Schedule the job
        String jobId = System.schedule('Test Movie Sync', cronExp, new MovieSyncScheduler());
        
        // Assert that the job has been scheduled
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime 
                          FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(cronExp, ct.CronExpression, 'Cron expression does not match');
        System.assertEquals(0, ct.TimesTriggered, 'Job should not have triggered yet');
        
        // Simulate executing the scheduled job
        Test.stopTest();
        
        // Fetch the Apex class ID for MovieSyncBatch using SOQL
        Id movieSyncBatchClassId = [SELECT Id FROM ApexClass WHERE Name = 'MovieSyncBatch' LIMIT 1].Id;
        
        // Assert that the batch job was executed (check the batch job status)
        List<AsyncApexJob> jobs = [SELECT Id, Status, JobItemsProcessed, NumberOfErrors 
                                   FROM AsyncApexJob 
                                   WHERE JobType = 'BatchApex' 
                                   AND ApexClassId = :movieSyncBatchClassId];
        System.assertEquals(1, jobs.size(), 'One batch job should have been executed');
        System.assertEquals('Completed', jobs[0].Status, 'Batch job should have completed successfully');
        System.assertEquals(0, jobs[0].NumberOfErrors, 'There should be no errors in the batch job');
    }
}
