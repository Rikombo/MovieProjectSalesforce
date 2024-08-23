@IsTest
public class MovieControllerTest {
    
    @TestSetup
    static void setup() {
        // Create test movie records with different genres
        Movie__c movie1 = new Movie__c(
            Title__c = 'Test Movie 1',
            Genre__c = 'Action;Adventure',
            Rating__c = 4.5,
            Poster_URL__c = 'https://example.com/poster1.jpg'
        );
        Movie__c movie2 = new Movie__c(
            Title__c = 'Test Movie 2',
            Genre__c = 'Drama',
            Rating__c = 4.0,
            Poster_URL__c = 'https://example.com/poster2.jpg'
        );
        Movie__c movie3 = new Movie__c(
            Title__c = 'Test Movie 3',
            Genre__c = 'Comedy',
            Rating__c = 3.5,
            Poster_URL__c = 'https://example.com/poster3.jpg'
        );
        insert new List<Movie__c>{movie1, movie2, movie3};
    }
    
    @IsTest
    static void testGetMoviesWithGenre() {
        // Test fetching movies with a specific genre
        List<Movie__c> actionMovies = MovieController.getMovies('Action', 10);
        
        // Validate results
        System.assertNotEquals(0, actionMovies.size(), 'There should be at least one Action movie.');
        System.assertEquals('Action', actionMovies[0].Genre__c.split(';')[0], 'The first genre should be Action.');
    }

    @IsTest
    static void testGetMoviesWithAllGenres() {
        // Test fetching all movies without genre filter
        List<Movie__c> allMovies = MovieController.getMovies('All', 10);
        
        // Validate results
        System.assertEquals(3, allMovies.size(), 'There should be 3 movies returned.');
    }

    @IsTest
    static void testGetMoviesWithLimit() {
        // Test fetching movies with a limit
        List<Movie__c> limitedMovies = MovieController.getMovies('All', 2);
        
        // Validate results
        System.assertEquals(2, limitedMovies.size(), 'There should be only 2 movies returned due to limit.');
    }
    
    @IsTest
    static void testGetGenres() {
        // Test fetching all unique genres
        List<String> genres = MovieController.getGenres();
        
        // Validate results
        System.assertNotEquals(0, genres.size(), 'There should be at least one genre.');
        System.assert(genres.contains('Action'), 'Genres should include Action.');
        System.assert(genres.contains('Drama'), 'Genres should include Drama.');
        System.assert(genres.contains('Comedy'), 'Genres should include Comedy.');
    }
}
