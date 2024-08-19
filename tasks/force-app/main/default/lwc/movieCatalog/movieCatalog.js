import { LightningElement, wire, api } from 'lwc';
import getMovies from '@salesforce/apex/MovieController.getMovies';

export default class MovieCatalog extends LightningElement {
    @api selectedGenre = '';
    movies = [];
    filteredMovies = [];
    limitSize = 100; // Increase the limit size for more movies

    @wire(getMovies, { genre: '$selectedGenre', limitSize: '$limitSize' })
    wiredMovies({ error, data }) {
        if (data) {
            console.log('Fetched movies:', data);
            this.movies = data;
            this.filterMovies();
        } else if (error) {
            console.error('Error fetching movies:', error);
        }
    }
    

    @api
    filterMovies() {
        if (this.selectedGenre && this.selectedGenre !== 'All') {
            this.filteredMovies = this.movies.filter(movie => {
                const genres = movie.Genre__c.split(';').map(genre => genre.trim().toLowerCase());
                return genres.includes(this.selectedGenre.toLowerCase());
            });
        } else {
            this.filteredMovies = this.movies;
        }
        console.log('Filtered movies:', this.filteredMovies);
    }
    
}
