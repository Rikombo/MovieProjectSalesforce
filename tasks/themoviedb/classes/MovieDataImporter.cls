public class MovieDataImporter {

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

    public static void importMovies(String jsonMovies) {
        
        List<MovieWrapper> movies = (List<MovieWrapper>) JSON.deserialize(jsonMovies, List<MovieWrapper>.class);

        for (MovieWrapper movieData : movies) {
            
            System.debug('Checking for TMDB ID: ' + movieData.tmdb_id);

            
            String tmdbId = movieData.tmdb_id != null ? movieData.tmdb_id.trim() : null;

            
            List<Movie__c> existingMovies = [SELECT Id, TMDB_ID__c FROM Movie__c WHERE TMDB_ID__c = :tmdbId LIMIT 1];
            System.debug('Query result for TMDB ID ' + tmdbId + ': ' + existingMovies);

            if (!existingMovies.isEmpty()) {
                System.debug('Movie with TMDB ID ' + tmdbId + ' already exists. Skipping import.');
                continue;
            }

            
            Script__c scriptRecord;
            if (movieData.script != null) {
                List<Script__c> existingScripts = [SELECT Id FROM Script__c WHERE LegacyId__c = :movieData.script.id LIMIT 1];
                if (!existingScripts.isEmpty()) {
                    scriptRecord = existingScripts[0];
                } else {
                    scriptRecord = new Script__c();
                    scriptRecord.LegacyId__c = movieData.script.id;
                    scriptRecord.Title__c = movieData.script.name;
                    scriptRecord.Description__c = movieData.script.description;
                    insert scriptRecord;
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
            }

            insert newMovie;
            System.debug('Imported movie: ' + newMovie.Title__c + ' with TMDB ID: ' + newMovie.TMDB_ID__c);
        }
    }
}


// For test
// String jsonMovies = '[{ "id": "1", "name": "Avatar", "tmdb_id": "19995", "genre": "Action;Adventure;Fantasy;Science_Fiction", "rating": 7.2, "budget": 237000000, "revenue": 2787965087, "script": { "id": "1", "name": "Avatar", "description": "In the 22nd century, a paraplegic Marine is dispatched to the moon Pandora on a unique mission, but becomes torn between following orders and protecting an alien civilization." }, "release_date": "10/12/2009", "status": "Released" }, { "id": "2", "name": "Pirates of the Caribbean: At World\'s End", "tmdb_id": "285", "genre": "Adventure;Fantasy;Action", "rating": 6.9, "budget": 300000000, "revenue": 961000000, "script": { "id": "2", "name": "Pirates of the Caribbean: At World\'s End", "description": "Captain Barbossa, long believed to be dead, has come back to life and is headed to the edge of the Earth with Will Turner and Elizabeth Swann. But nothing is quite as it seems." }, "release_date": "19/05/2007", "status": "Released" }]';
// MovieDataImporter.importMovies(jsonMovies);
