public class MovieTriggerHandler {
    public static void handleBeforeInsertOrUpdate(Map<Id, Movie__c> oldMap, List<Movie__c> newMovies) {
        Set<String> tmdbIds = new Set<String>();
        Map<String, Movie__c> existingMovies = new Map<String, Movie__c>();

        for (Movie__c movie : newMovies) {
            if (movie.TMDB_ID__c != null) {
                tmdbIds.add(movie.TMDB_ID__c);
            }
        }

        if (!tmdbIds.isEmpty()) {
            existingMovies = new Map<String, Movie__c>([SELECT Id, TMDB_ID__c FROM Movie__c WHERE TMDB_ID__c IN :tmdbIds]);
        }

        for (Movie__c movie : newMovies) {
            if (existingMovies.containsKey(movie.TMDB_ID__c)) {
                Movie__c existingMovie = existingMovies.get(movie.TMDB_ID__c);

                if (oldMap == null) { 
                    movie.Id = existingMovie.Id;
                }

                // Only call the future method if we are not in an asynchronous context
                if (!System.isFuture() && !System.isBatch()) {
                    if (oldMap != null || (oldMap == null && movie.Budget__c != null)) {
                        MovieDetailsService.fetchAndUpdateMovie(movie.TMDB_ID__c);
                    }
                } else {
                    System.debug('Cannot call future method in this context.');
                }
            } else {
                if (!System.isFuture() && !System.isBatch()) {
                    if (oldMap != null && movie.Budget__c != oldMap.get(movie.Id).Budget__c) {
                        MovieDetailsService.fetchAndUpdateMovie(movie.TMDB_ID__c);
                    }
                } else {
                    System.debug('Cannot call future method in this context.');
                }
            }
        }
    }
}
