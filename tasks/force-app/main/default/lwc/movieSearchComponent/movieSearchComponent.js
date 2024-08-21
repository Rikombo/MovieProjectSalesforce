import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import searchMovies from '@salesforce/apex/TMDBApiService.searchMovies';
import getExistingMovieIds from '@salesforce/apex/MovieDataImporter.getExistingMovieIds';
import createMovie from '@salesforce/apex/MovieDataImporter.createMovie';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const FIELDS = ['Movie__c.Title__c'];

export default class MovieSearchComponent extends LightningElement {
    @api recordId;
    @track movieTitle;
    @track movies = [];
    @track error;
    existingMovieTitles = new Set();

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (data) {
            this.movieTitle = data.fields.Title__c.value;
            this.loadMovies(); 
        } else if (error) {
            this.error = 'Error fetching movie record: ' + JSON.stringify(error);
        }
    }

    loadMovies() {
        if (!this.movieTitle) {
            this.error = 'Movie title is missing!';
            return;
        }
    
        getExistingMovieIds()
            .then(existingTitles => {
                this.existingMovieTitles = new Set(existingTitles);
                return searchMovies({ title: this.movieTitle });
            })
            .then(moviesFromApi => {
                console.log('Movies from API:', moviesFromApi);
                this.movies = moviesFromApi.map(movie => {
                    // Set a default value for genre if it is empty
                    const genre = movie.genre && movie.genre.trim() !== '' ? movie.genre : 'No genre';
    
                    return {
                        ...movie,
                        genre,  // Use the default value if the genre is empty
                        isOpen: false,
                        statusMessage: '',
                        statusClass: '',
                        existsInDb: this.existingMovieTitles.has(movie.title.toLowerCase()),
                        accordionIconClass: 'accordion-icon'
                    };
                });
    
                this.movies = this.movies.map(movie => {
                    if (movie.existsInDb) {
                        return {
                            ...movie,
                            statusMessage: 'Movie Already Exists in the Database',
                            statusClass: 'status-error'
                        };
                    }
                    return movie;
                });
    
                this.error = undefined;
            })
            .catch(error => {
                this.error = 'Error fetching movies: ' + error.body.message;
                this.movies = [];
            });
    }
    

    toggleAccordion(event) {
        const index = event.currentTarget.dataset.index;
        this.movies = this.movies.map((movie, i) => {
            const isOpen = i === parseInt(index, 10) ? !movie.isOpen : movie.isOpen;
            return {
                ...movie,
                isOpen,
                accordionIconClass: isOpen ? 'accordion-icon open' : 'accordion-icon'
            };
        });
    }

    handleCopyMovie(event) {
        const index = event.target.dataset.index;
        const movieId = event.target.dataset.id;
    
        createMovie({ tmdbId: movieId })
            .then(() => {
                this.movies = this.movies.map((movie, i) => {
                    if (i === parseInt(index, 10)) {
                        return {
                            ...movie,
                            statusMessage: 'Movie successfully added to the database!',
                            statusClass: 'status-success',
                            existsInDb: true
                        };
                    }
                    return movie;
                });
                this.showToast('Success', 'Movie successfully added to the database!', 'success');
            })
            .catch(error => {
                this.movies = this.movies.map((movie, i) => {
                    if (i === parseInt(index, 10)) {
                        return {
                            ...movie,
                            statusMessage: 'Failed to add movie: ' + (error.body ? error.body.message : error.message),
                            statusClass: 'status-error'
                        };
                    }
                    return movie;
                });
                this.showToast('Error', 'Failed to add movie: ' + (error.body ? error.body.message : error.message), 'error');
            });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}
