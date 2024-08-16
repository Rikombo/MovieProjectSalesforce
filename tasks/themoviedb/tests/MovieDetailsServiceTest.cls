@isTest
private class MovieDetailsServiceTest {

    @isTest
    static void testGenreMapping() {
        // Set up a mock for the TMDB API response
        TMDBApiServiceMock mock = new TMDBApiServiceMock();
        Test.setMock(HttpCalloutMock.class, mock);

        // Set a custom mock response to test the genre mapping
        mock.setMockResponse(
            '{"id": 300, "original_title": "Test Movie", "overview": "Test description", "vote_average": 8.5, "revenue": 1000000, "genres": [{"id": 28, "name": "Action"}, {"id": 12, "name": "Adventure"}]}'
        );

        // Insert a test movie record
        Movie__c testMovie = new Movie__c(TMDB_ID__c = '300', Title__c = 'Test Movie');
        insert testMovie;

        // Call the method under test
        Test.startTest();
        MovieDetailsService.fetchAndUpdateMovie('300');
        Test.stopTest();

        // Verify that the genres were correctly mapped
        Movie__c updatedMovie = [SELECT Id, Genre__c FROM Movie__c WHERE Id = :testMovie.Id LIMIT 1];
        System.assertEquals('Action;Adventure', updatedMovie.Genre__c, 'Genres should be correctly mapped and joined');
    }
}
