public with sharing class MovieDetailsService {

    @future(callout=true)
    public static void fetchAndUpdateMovie(String tmdbId) {
        Map<String, Object> movieDetails = TMDBApiService.fetchMovieDetailsFromTMDB(tmdbId);

        if (movieDetails != null && !movieDetails.isEmpty()) {
            updateMovieRecord(tmdbId, movieDetails);
        } else {
            System.debug('No movie details returned for TMDB ID: ' + tmdbId);
        }
    }

    public static void updateMovieRecord(String tmdbId, Map<String, Object> movieDetails) {
        List<Movie__c> movies = [SELECT Id, TMDB_ID__c FROM Movie__c WHERE TMDB_ID__c = :tmdbId LIMIT 1];

        if (!movies.isEmpty()) {
            Movie__c movie = movies[0];
            movie.Title__c = (String) movieDetails.get('original_title');
            movie.Description__c = (String) movieDetails.get('overview');
            movie.Revenue__c = (Decimal) movieDetails.get('revenue');
            movie.Rating__c = (Decimal) movieDetails.get('vote_average');
            movie.Poster_URL__c = (String) movieDetails.get('poster_path');
            movie.Budget__c = (Decimal) movieDetails.get('budget');

            System.debug('Updating movie with TMDB ID: ' + tmdbId);
            update movie;
        } else {
            System.debug('No movie found with TMDB ID: ' + tmdbId);
        }
    }
}
