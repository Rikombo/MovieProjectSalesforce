@IsTest
public class TMDBApiServiceTest {


    
    @IsTest
    static void testSearchMovies() {
        // Set up mock response for movies
        TMDBApiServiceMock mock = new TMDBApiServiceMock();
        mock.setMockResponse('{"results": [{"id": 19995, "title": "Avatar", "overview": "A paraplegic marine...", "vote_average": 7.5, "poster_path": "/poster.jpg", "genre_ids": [28, 12]}]}');
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Call the method
        List<Map<String, Object>> movies = TMDBApiService.searchMovies('Avatar');
        
        // Validate the response
        System.assertNotEquals(null, movies, 'Movies list should not be null');
        System.assert(movies.size() > 0, 'Movies should be returned');
        System.assertEquals('Avatar', movies[0].get('title'), 'First movie should be Avatar');
    }
    
    @IsTest
    static void testFetchReviews() {
        // Set up mock response for reviews
        TMDBApiServiceMock mock = new TMDBApiServiceMock();
        mock.setMockResponse('{"results": [{"id": "5b1c13b9c3a36848f2026384", "author": "Goddard", "content": "Pretty awesome movie.", "created_at": "2018-06-09T17:51:53.359Z"}]}');
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Call the method
        List<Map<String, Object>> reviews = TMDBApiService.fetchReviews('550');
        
        // Validate the response
        System.assertNotEquals(null, reviews, 'Reviews list should not be null');
        System.assert(reviews.size() > 0, 'Reviews should be returned');
        System.assertEquals('Goddard', reviews[0].get('author'), 'First review should be from Goddard');
    }
}
