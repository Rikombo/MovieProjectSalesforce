@isTest
private class MovieSyncBatchTest {

    @isTest
    static void testMovieSyncBatch() {
        // Setup mock data
        Movie__c movie1 = new Movie__c(TMDB_ID__c = '300', Title__c = 'Movie 1');
        insert movie1;

        // Set the mock callout
        TMDBApiServiceMock mock = new TMDBApiServiceMock();
        mock.setMockResponse('{"id": 300, "original_title": "Mock Movie 1", "overview": "Mock Description 1", "vote_average": 8.0, "revenue": 500000, "genres": [{"id": 18, "name": "Drama"}]}');
        Test.setMock(HttpCalloutMock.class, mock);

        // Execute the batch
        Test.startTest();
        Database.executeBatch(new MovieSyncBatch());
        Test.stopTest();

        // Validate the Movie record was updated
        Movie__c updatedMovie = [SELECT Revenue__c, Rating__c FROM Movie__c WHERE Id = :movie1.Id LIMIT 1];
        System.assertEquals(500000, updatedMovie.Revenue__c);  // Match the mock's revenue value
        System.assertEquals(8.0, updatedMovie.Rating__c);  // Match the mock's rating value
    }
}
