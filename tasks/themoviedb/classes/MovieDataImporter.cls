public with sharing class MovieDataImporter {

    public static void importAllMovies(String staticResourceName) {
        StaticResource movieDataResource = [SELECT Body FROM StaticResource WHERE Name = :staticResourceName LIMIT 1];
        String jsonMovies = movieDataResource.Body.toString();

        importMovies(jsonMovies);
    }

    public static void importMoviesFromStaticResource(String resourceName) {
        StaticResource movieDataResource = [SELECT Body FROM StaticResource WHERE Name = :resourceName LIMIT 1];
        String jsonMovies = movieDataResource.Body.toString();
        importMovies(jsonMovies);
    }

    public static void importMovies(String jsonMovies) {
        List<MovieWrapper> movies = (List<MovieWrapper>) JSON.deserialize(jsonMovies, List<MovieWrapper>.class);

        Set<String> tmdbIds = new Set<String>();
        Set<String> scriptIds = new Set<String>();

        for (MovieWrapper movie : movies) {
            if (movie.tmdb_id != null) {
                tmdbIds.add(movie.tmdb_id.trim());
            }
            if (movie.script != null) {
                scriptIds.add(movie.script.id);
            }
        }

        Map<String, Movie__c> existingMoviesMap = new Map<String, Movie__c>();
        for (Movie__c existingMovie : [SELECT Id, TMDB_ID__c FROM Movie__c WHERE TMDB_ID__c IN :tmdbIds]) {
            existingMoviesMap.put(existingMovie.TMDB_ID__c, existingMovie);
        }

        Map<String, Script__c> existingScriptsMap = new Map<String, Script__c>();
        for (Script__c existingScript : [SELECT Id, LegacyId__c FROM Script__c WHERE LegacyId__c IN :scriptIds]) {
            existingScriptsMap.put(existingScript.LegacyId__c, existingScript);
        }

        List<Movie__c> moviesToInsert = new List<Movie__c>();
        List<Script__c> scriptsToInsert = new List<Script__c>();

        String invalidChars = '!@#$%^&*()_+=[]{}|;:"<>,?/\\`~•§±≠≈Ωµπ∞∑∆√Üâ‰∏É‰∫∫„ÅÆ‰æç„Éè„Ç¶„É´„ÅÆÂãï„ÅèÂüé–°–æ–ª—è—Ä–∏—ÅÈ¢®Êö¥';

        for (MovieWrapper movieData : movies) {
            String tmdbId = movieData.tmdb_id != null ? movieData.tmdb_id.trim() : null;

            if (existingMoviesMap.containsKey(tmdbId)) {
                continue;
            }

            Boolean isValidTitle = true;
            for (Integer i = 0; i < movieData.name.length(); i++) {
                if (invalidChars.contains(movieData.name.mid(i, 1))) {
                    isValidTitle = false;
                    break;
                }
            }
            
            if (!isValidTitle) {
                continue; 
            }

            String firstGenre = '';
            if (movieData.genre != null) {
                List<String> genreList = movieData.genre.split(';');
                if (!genreList.isEmpty()) {
                    firstGenre = genreList[0].trim(); 
                }
            }

            Set<String> validGenres = new Set<String>();
            for (Schema.PicklistEntry entry : Script__c.Genre__c.getDescribe().getPicklistValues()) {
                validGenres.add(entry.getValue().toLowerCase()); 
            }

            if (!validGenres.contains(firstGenre.toLowerCase())) {
                continue; 
            }

            Script__c scriptRecord = null;

            if (movieData.script != null) {
                if (!existingScriptsMap.containsKey(movieData.script.id)) {
                    scriptRecord = new Script__c();
                    scriptRecord.LegacyId__c = movieData.script.id;
                    scriptRecord.Title__c = movieData.name;
                    scriptRecord.Description__c = movieData.script.description;
                    scriptRecord.Genre__c = firstGenre; 
                    scriptsToInsert.add(scriptRecord);
                } else {
                    scriptRecord = existingScriptsMap.get(movieData.script.id);
                }
            }

            Movie__c newMovie = new Movie__c();
            newMovie.LegacyId__c = movieData.id;
            newMovie.Title__c = movieData.name;
            newMovie.TMDB_ID__c = tmdbId;
            newMovie.Genre__c = movieData.genre;
            newMovie.Rating__c = movieData.rating;
            newMovie.Budget__c = movieData.budget;
            newMovie.Revenue__c = movieData.revenue;
            newMovie.Description__c = movieData.script != null ? movieData.script.description : null;

            if (scriptRecord != null) {
                newMovie.Script__c = scriptRecord.Id;
            } else if (existingScriptsMap.containsKey(movieData.script.id)) {
                newMovie.Script__c = existingScriptsMap.get(movieData.script.id).Id;
            }

            moviesToInsert.add(newMovie);
        }

        if (!scriptsToInsert.isEmpty()) {
            insert scriptsToInsert;

            Map<String, Id> scriptIdMap = new Map<String, Id>();
            for (Script__c script : scriptsToInsert) {
                scriptIdMap.put(script.LegacyId__c, script.Id);
            }

            for (Movie__c movie : moviesToInsert) {
                if (scriptIdMap.containsKey(movie.LegacyId__c)) {
                    movie.Script__c = scriptIdMap.get(movie.LegacyId__c);
                }
            }
        }

        if (!moviesToInsert.isEmpty()) {
            insert moviesToInsert;
        }
    }

    public class MovieWrapper {
        public String id;
        public String name;
        public String tmdb_id;
        public String genre;
        public Decimal rating;
        public Decimal budget;
        public Decimal revenue;
        public ScriptWrapper script;
        public String release_date;
        public String status;
    }

    public class ScriptWrapper {
        public String id;
        public String name;
        public String description;
    }
}
