import { LightningElement, api, wire, track } from 'lwc';
import getGenres from '@salesforce/apex/MovieController.getGenres';

export default class MovieListFilter extends LightningElement {
    @api selectedGenre = 'All'; // Default to "All"
    @track selectedLimit = 10;   // Default to 10 records
    genreOptions = [];

    @wire(getGenres)
    wiredGenres({ error, data }) {
        if (data) {
            this.genreOptions = [{ label: 'All', value: 'All' }, ...data.map(genre => ({
                label: genre.replace(/_/g, ' '), 
                value: genre
            }))];
        } else if (error) {
            console.error('Error fetching genres:', error);
        }
    }

    handleGenreChange(event) {
        this.selectedGenre = event.detail.value;
    }

    handleLimitChange(event) {
        const newLimit = parseInt(event.target.value, 10);
        if (!isNaN(newLimit) && newLimit > 0) {
            this.selectedLimit = newLimit;
        } else {
            this.selectedLimit = 10; // Fallback to default if input is invalid
        }
    }

    handleFilterClick() {
        const filterEvent = new CustomEvent('filter', {
            detail: { genre: this.selectedGenre, limit: this.selectedLimit }
        });
        this.dispatchEvent(filterEvent);
    }
}
