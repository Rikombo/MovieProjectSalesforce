@IsTest
public class MovieDataImporterTest {

    @TestSetup
    static void setup() {
        // Create some test Movie__c records
        Movie__c movie1 = new Movie__c(
            TMDB_ID__c = '12345',
            Title__c = 'Test Movie 1',
            Genre__c = 'Action',
            Rating__c = 4.5
        );
        Movie__c movie2 = new Movie__c(
            TMDB_ID__c = '67890',
            Title__c = 'Test Movie 2',
            Genre__c = 'Drama',
            Rating__c = 4.0
        );
        insert new List<Movie__c>{movie1, movie2};
    }

    @IsTest
    static void testGetExistingMovieIds() {
        // Call the method
        List<String> existingMovieIds = MovieDataImporter.getExistingMovieIds();

        // Validate the response
        System.assertNotEquals(null, existingMovieIds, 'Movie IDs list should not be null');
        System.assertEquals(2, existingMovieIds.size(), 'There should be 2 movie IDs returned');
        System.assert(existingMovieIds.contains('12345'), 'The list should contain TMDB ID 12345');
        System.assert(existingMovieIds.contains('67890'), 'The list should contain TMDB ID 67890');
    }

    @IsTest
    static void testDoesMovieExist() {
        // Test with an existing TMDB ID
        Boolean movieExists = MovieDataImporter.doesMovieExist('12345');
        System.assertEquals(true, movieExists, 'The movie with TMDB ID 12345 should exist');

        // Test with a non-existing TMDB ID
        Boolean movieDoesNotExist = MovieDataImporter.doesMovieExist('99999');
        System.assertEquals(false, movieDoesNotExist, 'The movie with TMDB ID 99999 should not exist');
    }

@IsTest
static void testCreateMovie() {
    // Set up mock response
    TMDBApiServiceMock mock = new TMDBApiServiceMock();
    Test.setMock(HttpCalloutMock.class, mock);
    
    // Test creating a new movie
    String newTmdbId = '54321';
    MovieDataImporter.createMovie(newTmdbId);

    // Validate that the movie was created
    Movie__c newMovie = [SELECT Id, TMDB_ID__c FROM Movie__c WHERE TMDB_ID__c = :newTmdbId LIMIT 1];
    System.assertNotEquals(null, newMovie, 'New movie should be created');
    System.assertEquals(newTmdbId, newMovie.TMDB_ID__c, 'TMDB ID should match the provided ID');
}

    @IsTest
    static void testCreateMovieAlreadyExists() {
        // Test creating a movie that already exists
        String existingTmdbId = '12345';

        try {
            MovieDataImporter.createMovie(existingTmdbId);
            System.assert(false, 'Exception should be thrown for duplicate movie creation');
        } catch (AuraHandledException e) {
            System.assertEquals('This movie already exists in the database.', e.getMessage(), 'Error message should match');
        }
    }

    @IsTest
    static void testImportAllMovies() {
        // Mock the StaticResource and simulate JSON response
        String jsonMovies = '[{"id":"54321","name":"Imported Movie","tmdb_id":"54321","genre":"Adventure","rating":8.5,"budget":1000000,"revenue":5000000}]';

        // Mocking the HTTP response from the StaticResource
        Test.startTest();
        MovieDataImporter.importMovies(jsonMovies);
        Test.stopTest();

        // Validate that the movies were imported
        Movie__c importedMovie = [SELECT Id, Title__c, TMDB_ID__c FROM Movie__c WHERE TMDB_ID__c = '54321' LIMIT 1];
        System.assertNotEquals(null, importedMovie, 'Imported movie should be created');
    }

    @IsTest
    static void testImportMoviesAndSync() {
        // Simulate the JSON string of movies
        String jsonMovies = '[{"id":"54321","name":"Imported Movie","tmdb_id":"54321","genre":"Adventure","rating":8.5,"budget":1000000,"revenue":5000000}]';

        // Test importing movies and syncing
        Test.startTest();
        String result = MovieDataImporter.importMoviesAndSync(jsonMovies);
        Test.stopTest();

        // Validate that the movies were imported and sync started
        Movie__c importedMovie = [SELECT Id, Title__c, TMDB_ID__c FROM Movie__c WHERE TMDB_ID__c = '54321' LIMIT 1];
        System.assertNotEquals(null, importedMovie, 'Imported movie should be created');
        System.assertEquals('Movies imported and sync started successfully', result, 'Result message should match');
    }

    @IsTest
    static void testImportMoviesFromFile() {
        // Simulate the JSON string of movies
        String jsonMovies = '[{"id":"54321","name":"Imported Movie","tmdb_id":"54321","genre":"Adventure","rating":8.5,"budget":1000000,"revenue":5000000}]';

        // Mock the ContentVersion record
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.ContentDocumentId = 'mockContentDocumentId';
        contentVersion.VersionData = Blob.valueOf(jsonMovies);
        insert contentVersion;

        // Mock the response for ContentVersion query
        Test.startTest();
        String result = MovieDataImporter.importMoviesFromFile('mockContentDocumentId');
        Test.stopTest();

        // Validate that the movies were imported
        Movie__c importedMovie = [SELECT Id, Title__c, TMDB_ID__c FROM Movie__c WHERE TMDB_ID__c = '54321' LIMIT 1];
        System.assertNotEquals(null, importedMovie, 'Imported movie should be created');
        System.assertEquals('Movies successfully imported', result, 'Result message should match');
    }

    @isTest
    static void testImportMovies_WithValidData() {
        String jsonMovies = '[{"id": "3", "name": "New Movie", "tmdb_id": "300", "genre": "Drama", "script": {"id": "3", "name": "New Script", "description": "A new script"}}]';

        TMDBApiServiceMock mock = new TMDBApiServiceMock();
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        MovieDataImporter.importMovies(jsonMovies);
        Test.stopTest();

        Movie__c importedMovie = [SELECT Id, Title__c, TMDB_ID__c, Script__c, Revenue__c FROM Movie__c WHERE TMDB_ID__c = '300' LIMIT 1];
        System.assertEquals('New Movie Test', importedMovie.Title__c);
        System.assertEquals(1000000, importedMovie.Revenue__c);  
        Script__c associatedScript = [SELECT Id, Title__c FROM Script__c WHERE Id = :importedMovie.Script__c LIMIT 1];
        System.assertEquals('New Script', associatedScript.Title__c);
    }
}
