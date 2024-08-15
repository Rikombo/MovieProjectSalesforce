public with sharing class MovieSyncScheduler implements Schedulable {
    
    public void execute(SchedulableContext sc){
        MovieSyncBatch batch = new MovieSyncBatch();
        Database.executeBatch(batch);
    }
}

// System.schedule('Daily TMDB Sync', '0 0 2 * * ?', new MovieSyncScheduler());
