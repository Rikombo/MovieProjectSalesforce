public with sharing class MovieSyncBatch implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {

    private Integer recordsProcessed = 0;

    public Database.QueryLocator start(Database.BatchableContext BC) {
        Date oneMonthAgo = Date.today().addMonths(-1);
        return Database.getQueryLocator([
            SELECT Id, TMDB_ID__c, Poster_URL__c
            FROM Movie__c 
            WHERE (TMDBSyncDate__c = NULL OR TMDBSyncDate__c < :oneMonthAgo) 
            AND TMDB_ID__c != NULL
        ]);
    }

    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        List<Movie__c> moviesToUpdate = new List<Movie__c>();

        for (Movie__c movie : (List<Movie__c>)scope) {
            Map<String, Object> movieDetails = TMDBApiService.fetchMovieDetailsFromTMDB(movie.TMDB_ID__c);

            if (movieDetails != null && !movieDetails.isEmpty()) {
                movie.Revenue__c = (Decimal) movieDetails.get('revenue');
                movie.Rating__c = (Decimal) movieDetails.get('vote_average');
                movie.TMDBSyncDate__c = Date.today(); 

                
                if (String.isEmpty(movie.Poster_URL__c)) {
                    String posterPath = (String) movieDetails.get('poster_path');
                    if (posterPath != null) {
                        movie.Poster_URL__c = 'https://image.tmdb.org/t/p/original' + posterPath;
                    }
                }

                moviesToUpdate.add(movie);
                recordsProcessed++;
            } else {
                System.debug('No movie details found for TMDB ID: ' + movie.TMDB_ID__c);
            }
        }

        if (!moviesToUpdate.isEmpty()) {
            TriggerHelper.bypassTrigger = true;
            update moviesToUpdate;
            TriggerHelper.bypassTrigger = false;
        }
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('Batch job complete. Total records processed: ' + recordsProcessed);
    }
}
