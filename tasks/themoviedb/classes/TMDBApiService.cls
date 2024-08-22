public with sharing class TMDBApiService {

    private static final String SEARCH_URL = 'https://api.themoviedb.org/3/search/movie';
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

    // Fetches genre list from TMDB
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

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> searchMovies(String title) {
        String endpoint = SEARCH_URL + '?query=' + EncodingUtil.urlEncode(title, 'UTF-8') + '&include_adult=false&language=en-US&page=1';
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('accept', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + BEARER_TOKEN);
    
        Http http = new Http();
        HttpResponse response = http.send(request);
    
        if (response.getStatusCode() == 200) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> moviesList = (List<Object>) result.get('results');
            List<Map<String, Object>> movies = new List<Map<String, Object>>();
            Values values = new Values(); 
            Map<String, Integer> genreMap = values.genreIdByName;
    
            for (Object movieObj : moviesList) {
                Map<String, Object> movie = (Map<String, Object>) movieObj;
    
                String posterPath = (String) movie.get('poster_path');
                String posterUrl = posterPath != null ? 'https://image.tmdb.org/t/p/original' + posterPath : null;
    
                List<Object> genreIds = (List<Object>) movie.get('genre_ids');
                List<String> genreNames = new List<String>();
                for (Object genreIdObj : genreIds) {
                    Integer genreId = (Integer) genreIdObj;
                    for (String genreName : genreMap.keySet()) {
                        if (genreMap.get(genreName) == genreId) {
                            genreNames.add(genreName);
                            break;
                        }
                    }
                }
    
                String genres = genreNames.isEmpty() ? 'No genre' : String.join(genreNames, ', ');
    
                movies.add(new Map<String, Object>{
                    'id' => movie.get('id'),
                    'title' => movie.get('title'),
                    'overview' => movie.get('overview'),
                    'rating' => movie.get('vote_average'),
                    'posterUrl' => posterUrl,
                    'genre' => genres
                });
            }
    
            return movies;
        } else {
            throw new AuraHandledException('Failed to fetch movies from TMDB: ' + response.getStatusCode());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> fetchReviews(String tmdbId) {
        String endpoint = BASE_URL + tmdbId + '/reviews?language=en-US';
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + BEARER_TOKEN);

        Http http = new Http();
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> reviewsList = (List<Object>) result.get('results');
            List<Map<String, Object>> reviews = new List<Map<String, Object>>();

            for (Object reviewObj : reviewsList) {
                Map<String, Object> review = (Map<String, Object>) reviewObj;
                reviews.add(new Map<String, Object>{
                    'id' => review.get('id'),
                    'author' => review.get('author'),
                    'content' => review.get('content'),
                    'created_at' => review.get('created_at')
                });
            }

            return reviews;
        } else {
            throw new AuraHandledException('Failed to fetch reviews from TMDB: ' + response.getStatusCode());
        }
    }
    


    
}
