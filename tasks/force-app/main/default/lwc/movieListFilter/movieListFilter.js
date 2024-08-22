import { LightningElement, api, track, wire } from 'lwc';
import getGenres from '@salesforce/apex/MovieController.getGenres';

export default class MovieListFilter extends LightningElement {
    @api selectedGenre = 'All'; // Default to "All"
    @track selectedLimit = 10;   // Default to 10 records
    genreOptions = [];

    // Fetch genres from Apex controller
    @wire(getGenres)
    wiredGenres({ error, data }) {
        if (data) {
            this.genreOptions = [{ label: 'All', value: 'All' }, ...data.map(genre => ({
                label: genre ? genre.replace(/_/g, ' ') : 'No genre', 
                value: genre ? genre : 'No genre'
            }))];
        } else if (error) {
            console.error('Error fetching genres:', error);
            this.genreOptions = [{ label: 'All', value: 'All' }];
        }
    }

    handleGenreChange(event) {
        this.selectedGenre = event.detail.value || 'All'; 
    }
    
    handleLimitChange(event) {
        const newLimit = parseInt(event.target.value, 10);
        if (!isNaN(newLimit) && newLimit > 0) {
            this.selectedLimit = newLimit;
        } else {
            this.selectedLimit = 10; // Fallback to default if input is invalid
        }
    }

    async handleFilterClick(event) {
        try {
            if (!this.selectedGenre || this.selectedGenre === 'No genre') {
                this.selectedGenre = 'All';
            }
            if (!this.selectedLimit || isNaN(this.selectedLimit) || this.selectedLimit <= 0) {
                this.selectedLimit = 10;
            }
    
            console.log('Filtering with Genre:', this.selectedGenre, 'and Limit:', this.selectedLimit);
    
            const filterEvent = new CustomEvent('filter', {
                detail: { genre: this.selectedGenre, limit: this.selectedLimit }
            });
            this.dispatchEvent(filterEvent);
    
        } catch (error) {
            console.error('Error during filter click:', error);
            this.showToast('Error', 'An error occurred while filtering. Please try again.', 'error');
        }
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
