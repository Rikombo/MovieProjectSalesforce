@IsTest
public class MovieDetailsServiceTest {

    @TestSetup
    static void setup() {
        // Insert a test movie to check update functionality
        Movie__c movie = new Movie__c(
            TMDB_ID__c = '12345',
            Title__c = 'Original Title',
            Description__c = 'Original Description',
            Rating__c = 5.0,
            Genre__c = 'Action',
            Poster_URL__c = 'https://image.tmdb.org/t/p/original/sample.jpg'
        );
        insert movie;
    }

    @IsTest
    static void testCreateOrUpdateMovie_CreateNew() {
        // Set up mock response using the new MovieDetailsServiceMock
        MovieDetailsServiceMock mock = new MovieDetailsServiceMock();
        mock.setMockResponse('{"id": "67890", "title": "New Movie", "overview": "This is a new movie description.", "vote_average": 8.0, "poster_path": "/new_movie_poster.jpg", "genres": [{"id": 18, "name": "Drama"}]}');
        Test.setMock(HttpCalloutMock.class, mock);

        // Test creating a new movie record
        String tmdbId = '67890';
        String title = 'New Movie Title';
        String originalTitle = 'New Movie Original Title';
        String overview = 'This is a new movie description.';
        Decimal rating = 8.0;
        String genres = 'Drama';
        String posterUrl = 'https://image.tmdb.org/t/p/original/new_movie_poster.jpg';

        // Call the method
        Test.startTest();
        MovieDetailsService.createOrUpdateMovie(tmdbId, title, originalTitle, overview, rating, genres, posterUrl);
        Test.stopTest();

        // Verify that the movie was created
        Movie__c createdMovie = [SELECT Id, Title__c, Description__c, Rating__c, Genre__c, Poster_URL__c FROM Movie__c WHERE TMDB_ID__c = :tmdbId LIMIT 1];
        System.assertNotEquals(null, createdMovie, 'The new movie should have been created');
        System.assertEquals(title, createdMovie.Title__c, 'The title should match the provided title');
        System.assertEquals(overview, createdMovie.Description__c, 'The description should match the provided overview');
        System.assertEquals(rating, createdMovie.Rating__c, 'The rating should match the provided rating');
        System.assertEquals(genres, createdMovie.Genre__c, 'The genres should match the provided genres');
        System.assertEquals(posterUrl, createdMovie.Poster_URL__c, 'The poster URL should match the provided poster URL');
    }

    @IsTest
    static void testCreateOrUpdateMovie_UpdateExisting() {
        // Set up mock response using the new MovieDetailsServiceMock
        MovieDetailsServiceMock mock = new MovieDetailsServiceMock();
        mock.setMockResponse('{"id": "12345", "title": "Updated Movie Title", "overview": "This is an updated movie description.", "vote_average": 9.0, "poster_path": "/updated_movie_poster.jpg", "genres": [{"id": 35, "name": "Comedy"}]}');
        Test.setMock(HttpCalloutMock.class, mock);

        // Test updating an existing movie record
        String tmdbId = '12345'; // Use the TMDB ID of the movie inserted in the TestSetup
        String title = 'Updated Movie Title';
        String originalTitle = 'Updated Movie Original Title';
        String overview = 'This is an updated movie description.';
        Decimal rating = 9.0;
        String genres = 'Comedy';
        String posterUrl = 'https://image.tmdb.org/t/p/original/updated_movie_poster.jpg';

        // Call the method
        Test.startTest();
        MovieDetailsService.createOrUpdateMovie(tmdbId, title, originalTitle, overview, rating, genres, posterUrl);
        Test.stopTest();

        // Verify that the movie was updated
        Movie__c updatedMovie = [SELECT Id, Title__c, Description__c, Rating__c, Genre__c, Poster_URL__c FROM Movie__c WHERE TMDB_ID__c = :tmdbId LIMIT 1];
        System.assertNotEquals(null, updatedMovie, 'The movie should have been updated');
        System.assertEquals(title, updatedMovie.Title__c, 'The title should match the updated title');
        System.assertEquals(overview, updatedMovie.Description__c, 'The description should match the updated overview');
        System.assertEquals(rating, updatedMovie.Rating__c, 'The rating should match the updated rating');
        System.assertEquals(genres, updatedMovie.Genre__c, 'The genres should match the updated genres');
        System.assertEquals(posterUrl, updatedMovie.Poster_URL__c, 'The poster URL should match the updated poster URL');
    }

    @IsTest
    static void testCreateOrUpdateMovie_UseOriginalTitleWhenTitleIsBlank() {
        // Set up mock response using the new MovieDetailsServiceMock
        MovieDetailsServiceMock mock = new MovieDetailsServiceMock();
        mock.setMockResponse('{"id": "54321", "original_title": "Original Movie Title", "overview": "This is a movie description with blank title.", "vote_average": 7.0, "poster_path": "/movie_poster.jpg", "genres": [{"id": 27, "name": "Horror"}]}');
        Test.setMock(HttpCalloutMock.class, mock);

        // Test using original title when title is blank
        String tmdbId = '54321';
        String title = '';
        String originalTitle = 'Original Movie Title';
        String overview = 'This is a movie description with blank title.';
        Decimal rating = 7.0;
        String genres = 'Horror';
        String posterUrl = 'https://image.tmdb.org/t/p/original/movie_poster.jpg';

        // Call the method
        Test.startTest();
        MovieDetailsService.createOrUpdateMovie(tmdbId, title, originalTitle, overview, rating, genres, posterUrl);
        Test.stopTest();

        // Verify that the movie was created with the original title
        Movie__c createdMovie = [SELECT Id, Title__c, Description__c, Rating__c, Genre__c, Poster_URL__c FROM Movie__c WHERE TMDB_ID__c = :tmdbId LIMIT 1];
        System.assertNotEquals(null, createdMovie, 'The new movie should have been created');
        System.assertEquals(originalTitle, createdMovie.Title__c, 'The title should match the original title when the title is blank');
        System.assertEquals(overview, createdMovie.Description__c, 'The description should match the provided overview');
        System.assertEquals(rating, createdMovie.Rating__c, 'The rating should match the provided rating');
        System.assertEquals(genres, createdMovie.Genre__c, 'The genres should match the provided genres');
        System.assertEquals(posterUrl, createdMovie.Poster_URL__c, 'The poster URL should match the provided poster URL');
    }
}
