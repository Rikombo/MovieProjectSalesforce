public with sharing class MovieController {
    @AuraEnabled(cacheable=true)
    public static List<Movie__c> getMovies(String genre, Integer limitSize) {
        if (genre == 'All' || genre == null || genre == '') {
            return [SELECT Id, Title__c, Genre__c, Rating__c, Poster_URL__c 
                    FROM Movie__c 
                    LIMIT :limitSize];
        } else {
            return [SELECT Id, Title__c, Genre__c, Rating__c, Poster_URL__c 
                    FROM Movie__c 
                    WHERE Genre__c INCLUDES (:genre)
                    LIMIT :limitSize];
        }
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
