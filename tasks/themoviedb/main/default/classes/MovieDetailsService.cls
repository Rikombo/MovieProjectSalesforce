public with sharing class MovieDetailsService {
    private static final String BASE_URL = 'https://api.themoviedb.org/3/movie/';
    private static final String BEARER_TOKEN = 'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI5Yjk1ZGFhOWZjYTUzYTgzYTZkZDIwMGIzYjY5YTY4NSIsIm5iZiI6MTcyMzQ1MTg5MC4xMTUwMDMsInN1YiI6IjY2YjljMDdhNmY5Y2I0ZTJlNjA3N2I3OSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.RJAGubnjJg8KdRkcHmHjPtbnhID06wpfw_oKjmXY5X0'; 
    
    @future(callout=true)
    public static void fetchAndUpdateMovie(String tmdbId) {
        String endpoint = BASE_URL + tmdbId + '?language=en-US';

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('accept', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + BEARER_TOKEN);

        Http http = new Http();
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            Map<String, Object> movieDetails = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            if (movieDetails != null && !movieDetails.isEmpty()) {
                updateMovieRecord(tmdbId, movieDetails);
            } else {
                System.debug('No movie details returned for TMDB ID: ' + tmdbId);
            }
        } else {
            System.debug('Failed to get movie details. Status: ' + response.getStatusCode() + ' Response: ' + response.getBody());
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
