import { LightningElement, wire, track } from 'lwc';
import getMovies from '@salesforce/apex/MovieController.getMovies'; 

export default class MovieCatalog extends LightningElement {
    @track movies = [];
    @track filteredMovies = [];
    selectedGenre = '';

    @wire(getMovies)
    wiredMovies({ error, data }) {
        if (data) {
            this.movies = data;
            this.filteredMovies = data; 
        } else if (error) {
            console.error('Error fetching movies:', error);
        }
    }

    handleGenreChange(event) {
        const selectedGenre = event.detail.genre;

        if (selectedGenre === '' || selectedGenre === undefined) {
            this.filteredMovies = this.movies; 
        } else {
            this.filteredMovies = this.movies.filter(movie => 
                movie.Genre__c.toLowerCase().includes(selectedGenre.toLowerCase())
            );
        }
    }
}
