public with sharing class TMDBApiService {
    private static final String BASE_URL = 'https://api.themoviedb.org/3/movie/';
    private static final String BEARER_TOKEN = 'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI5Yjk1ZGFhOWZjYTUzYTgzYTZkZDIwMGIzYjY5YTY4NSIsIm5iZiI6MTcyMzQ1MTg5MC4xMTUwMDMsInN1YiI6IjY2YjljMDdhNmY5Y2I0ZTJlNjA3N2I3OSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.RJAGubnjJg8KdRkcHmHjPtbnhID06wpfw_oKjmXY5X0'; 
    
    public static Map<String, Object> fetchMovieDetailsFromTMDB(String tmdbId) {
        String endpoint = BASE_URL + tmdbId + '?language=en-US';
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('accept', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + BEARER_TOKEN);

        Http http = new Http();
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            return (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        } else {
            System.debug('Failed to get movie details. Status: ' + response.getStatusCode() + ' Response: ' + response.getBody());
            return null;
        }
    }
    
    public static tmdbGenreListResponse fetchGenres() {
        String endpoint = 'https://api.themoviedb.org/3/genre/movie/list?language=en-US';
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('accept', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + BEARER_TOKEN);

        Http http = new Http();
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            return (tmdbGenreListResponse) JSON.deserialize(response.getBody(), tmdbGenreListResponse.class);
        } else {
            System.debug('Failed to get genre list. Status: ' + response.getStatusCode() + ' Response: ' + response.getBody());
            return null;
        }
    }
}
