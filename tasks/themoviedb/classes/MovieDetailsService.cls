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
        List<Movie__c> movies = [SELECT Id, TMDB_ID__c, Genre__c FROM Movie__c WHERE TMDB_ID__c = :tmdbId LIMIT 1];
    
        if (!movies.isEmpty()) {
            Movie__c movie = movies[0];
            movie.Title__c = (String) movieDetails.get('original_title');
            movie.Description__c = (String) movieDetails.get('overview');
            movie.Revenue__c = (Decimal) movieDetails.get('revenue');
            movie.Rating__c = (Decimal) movieDetails.get('vote_average');
            movie.Poster_URL__c = (String) movieDetails.get('poster_path');
            movie.Budget__c = (Decimal) movieDetails.get('budget');
    
            // Handle genre mapping
            List<Object> genreList = (List<Object>) movieDetails.get('genres');
            if (genreList != null && !genreList.isEmpty()) {
                List<String> genreNames = new List<String>();
                Values values = new Values();
                Map<String, Integer> genreMap = values.genreIdByName;
    
                for (Object genreObj : genreList) {
                    Map<String, Object> genreMapEntry = (Map<String, Object>) genreObj;
                    Integer genreId = (Integer) genreMapEntry.get('id');
                    for (String genreName : genreMap.keySet()) {
                        if (genreMap.get(genreName) == genreId) {
                            if (genreName == 'Science Fiction') {
                                genreName = 'Science_Fiction'; 
                            }
                            genreNames.add(genreName);
                            break;
                        }
                    }
                }
                movie.Genre__c = String.join(genreNames, ';');
            }
    
            System.debug('Updating movie with TMDB ID: ' + tmdbId);
            update movie;
        } else {
            System.debug('No movie found with TMDB ID: ' + tmdbId);
        }
    }
    
}
