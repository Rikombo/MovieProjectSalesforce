@isTest
private class MovieDataImporterTest {

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
