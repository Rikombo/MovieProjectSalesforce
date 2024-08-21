public with sharing class MovieTriggerHandler {
    private static final Integer RECORD_THRESHOLD = 5;

    public static void handleBeforeInsertOrUpdate(Map<Id, Movie__c> oldMap, List<Movie__c> newMovies) {
        if (newMovies.size() > RECORD_THRESHOLD) {
            System.debug('Skipping trigger logic due to large number of records: ' + newMovies.size());
            return;
        }

        for (Movie__c movie : newMovies) {
            if (movie.TMDB_ID__c != null) {
                Boolean isNewOrUpdated = oldMap == null || oldMap.get(movie.Id)?.TMDB_ID__c != movie.TMDB_ID__c;
                if (isNewOrUpdated) {
                    // Skip future method in future or batch context
                    if (!System.isFuture() && !System.isBatch()) {
                        MovieDetailsService.fetchAndUpdateMovie(movie.TMDB_ID__c);
                    } else {
                        System.debug('Cannot call future method in this context.');
                    }
                }
            }
        }
    }
}
