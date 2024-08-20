public with sharing class MovieController {
    @AuraEnabled(cacheable=true)
    public static List<Movie__c> getMovies(String genre, Integer limitSize) {
        String genreCondition = genre != 'All' ? '%' + genre + '%' : '%';
        String query = 'SELECT Id, Title__c, Genre__c, Rating__c, Poster_URL__c ' +
                       'FROM Movie__c WHERE Genre__c INCLUDES (:genreCondition) LIMIT :limitSize';
        return Database.query(query);
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getGenres() {
        Set<String> genres = new Set<String>();
        for (Movie__c movie : [SELECT Genre__c FROM Movie__c]) {
            if (movie.Genre__c != null) {
                genres.addAll(movie.Genre__c.split(';'));
            }
        }
        return new List<String>(genres);
    }
}
