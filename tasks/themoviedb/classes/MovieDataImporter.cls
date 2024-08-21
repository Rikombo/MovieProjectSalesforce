public with sharing class MovieDataImporter {

    @AuraEnabled(cacheable=true)
    public static List<String> getExistingMovieIds() {
        List<String> tmdbIds = new List<String>();

        for (Movie__c movie : [SELECT TMDB_ID__c FROM Movie__c WHERE TMDB_ID__c != null]) {
            tmdbIds.add(movie.TMDB_ID__c);
        }

        return tmdbIds;
    }

    @AuraEnabled
    public static Boolean doesMovieExist(String tmdbId) {
        Integer count = [SELECT count() FROM Movie__c WHERE TMDB_ID__c = :tmdbId];
        return count > 0;
    }

    @AuraEnabled
    public static void createMovie(String tmdbId) {
        if (tmdbId == null || tmdbId.trim() == '') {
            throw new AuraHandledException('TMDB ID cannot be null or empty.');
        }

        Boolean movieExists = doesMovieExist(tmdbId);
        if (movieExists) {
            throw new AuraHandledException('This movie already exists in the database.');
        }

        Movie__c newMovie = new Movie__c();
        newMovie.TMDB_ID__c = tmdbId;

        try {
            insert newMovie;
        } catch (Exception e) {
            throw new AuraHandledException('Failed to create new movie record: ' + e.getMessage());
        }
    }

    public static void importAllMovies(String staticResourceName) {
        StaticResource movieDataResource = [SELECT Body FROM StaticResource WHERE Name = :staticResourceName LIMIT 1];
        String jsonMovies = movieDataResource.Body.toString();

        importMovies(jsonMovies);
    }


    @AuraEnabled
    public static String importMoviesAndSync(String jsonMovies) {
        // Import the movies using the existing importMovies method
        importMovies(jsonMovies);
        
        // Call the batch class to sync the movies after importing
        MovieSyncBatch movieSyncBatch = new MovieSyncBatch();
        Database.executeBatch(movieSyncBatch, 100);
    
        return 'Movies imported and sync started successfully';
    }

    @AuraEnabled
    public static String importMoviesFromFile(String contentDocumentId) {
        // Retrieve the file content using ContentDocumentId
        ContentVersion contentVersion = [
            SELECT VersionData 
            FROM ContentVersion 
            WHERE ContentDocumentId = :contentDocumentId 
            LIMIT 1
        ];
        Blob jsonBlob = contentVersion.VersionData;
        
        // Convert the Blob to a string
        String jsonContent = jsonBlob.toString();
    
        // Call the existing importMovies method
        importMovies(jsonContent);
    
        return 'Movies successfully imported';
    }

    public static void importMovies(String jsonMovies) {
        List<MovieWrapper> movies = (List<MovieWrapper>) JSON.deserialize(jsonMovies, List<MovieWrapper>.class);
    
        List<Movie__c> moviesToInsert = new List<Movie__c>();
    
        for (MovieWrapper movieData : movies) {
            if (movieData.genre == '[]' || String.isBlank(movieData.genre)) {
                System.debug('Skipping movie with empty genre: ' + movieData.name);
                continue; 
            }
    
            Movie__c newMovie = new Movie__c();
            newMovie.LegacyId__c = movieData.id;
            newMovie.Title__c = movieData.name;  
            newMovie.TMDB_ID__c = movieData.tmdb_id;
            
            newMovie.Genre__c = movieData.genre;
            newMovie.Rating__c = movieData.rating != null ? movieData.rating : 0;
            newMovie.Budget__c = movieData.budget != null ? movieData.budget : 0;
            newMovie.Revenue__c = movieData.revenue != null ? movieData.revenue : 0;
            newMovie.Description__c = movieData.script != null ? movieData.script.description : '';
    
            moviesToInsert.add(newMovie);
        }
    
        if (!moviesToInsert.isEmpty()) {
            insert moviesToInsert;
        }
        
        MovieSyncBatch movieSyncBatch = new MovieSyncBatch();
        Database.executeBatch(movieSyncBatch, 100);
        System.debug('Number of movies inserted: ' + moviesToInsert.size());
    }
    

    public class MovieWrapper {
        public String id;
        public String name;
        public String tmdb_id;
        public String genre;
        public Decimal rating;
        public Decimal budget;
        public Decimal revenue;
        public ScriptWrapper script;
    }

    public class ScriptWrapper {
        public String id;
        public String name;
        public String description;
    }
}