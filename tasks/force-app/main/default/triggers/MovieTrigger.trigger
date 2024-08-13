trigger MovieTrigger on Movie__c (before insert, before update) {
    Set<String> tmdbIds = new Set<String>();

    for (Movie__c movie : Trigger.new) {
        if (movie.TMDB_ID__c != null && (Trigger.isInsert || (Trigger.isUpdate && movie.TMDB_ID__c != Trigger.oldMap.get(movie.Id).TMDB_ID__c))) {
            tmdbIds.add(movie.TMDB_ID__c);
        }
    }

    if (!tmdbIds.isEmpty()) {
        for (String tmdbId : tmdbIds) {
            MovieDetailsService.fetchAndUpdateMovie(tmdbId);
        }
    }
}
