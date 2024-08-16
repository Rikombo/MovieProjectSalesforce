import { LightningElement, wire } from 'lwc';
import getGenres from '@salesforce/apex/MovieController.getGenres'; 

export default class MovieListFilter extends LightningElement {
    selectedGenre = '';
    genreOptions = [];

    @wire(getGenres)
    wiredGenres({ error, data }) {
        if (data) {
            this.genreOptions = data.map(genre => ({
                label: genre,
                value: genre
            }));
        } else if (error) {
            console.error('Error fetching genres:', error);
        }
    }

    handleGenreChange(event) {
        this.selectedGenre = event.detail.value;
        const genreChangeEvent = new CustomEvent('genrechange', {
            detail: { genre: this.selectedGenre }
        });
        this.dispatchEvent(genreChangeEvent);
    }
}
