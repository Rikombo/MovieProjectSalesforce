public with sharing class MovieTriggerHandler {

    public static void handleBeforeInsertOrUpdate(Map<Id, Movie__c> oldMap, List<Movie__c> newMovies) {
        for (Movie__c movie : newMovies) {
            if (movie.TMDB_ID__c != null) {
                Boolean isNewOrUpdated = oldMap == null || oldMap.get(movie.Id)?.TMDB_ID__c != movie.TMDB_ID__c;
                if (isNewOrUpdated) {
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
