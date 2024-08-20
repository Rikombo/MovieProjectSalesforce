import { LightningElement, wire, api, track } from 'lwc';
import getMovies from '@salesforce/apex/MovieController.getMovies';

export default class MovieCatalog extends LightningElement {
    @api selectedGenre = '';
    @api limitSize = 10; // Default to 10 records
    movies = [];
    filteredMovies = [];
    paginatedMovies = [];
    @track currentPage = 1;
    @track totalPages = 1;
    moviesPerPage = 10; // Number of movies per page

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
        this.setupPagination();
    }

    setupPagination() {
        this.totalPages = Math.ceil(this.filteredMovies.length / this.moviesPerPage);
        this.currentPage = 1;
        this.updatePaginatedMovies();
    }

    updatePaginatedMovies() {
        const startIndex = (this.currentPage - 1) * this.moviesPerPage;
        const endIndex = this.currentPage * this.moviesPerPage;
        this.paginatedMovies = this.filteredMovies.slice(startIndex, endIndex);
        console.log('Paginated Movies:', this.paginatedMovies);
    }

    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage += 1;
            this.updatePaginatedMovies();
        }
    }

    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage -= 1;
            this.updatePaginatedMovies();
        }
    }

    get isPreviousDisabled() {
        return this.currentPage === 1;
    }

    get isNextDisabled() {
        return this.currentPage === this.totalPages;
    }
}
