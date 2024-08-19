import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import TITLE_FIELD from '@salesforce/schema/Movie__c.Title__c';
import GENRE_FIELD from '@salesforce/schema/Movie__c.Genre__c';
import RATING_FIELD from '@salesforce/schema/Movie__c.Rating__c';
import POSTER_URL_FIELD from '@salesforce/schema/Movie__c.Poster_URL__c';

export default class MovieCard extends NavigationMixin(LightningElement) {
    @api title;
    @api genre;
    @api rating;
    @api posterUrl;
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: [TITLE_FIELD, GENRE_FIELD, RATING_FIELD, POSTER_URL_FIELD] })
    movie;

    get computedTitle() {
        return this.recordId ? this.movie?.data?.fields?.Title__c?.value : this.title;
    }

    get computedGenre() {
        const genreStr = this.recordId ? this.movie?.data?.fields?.Genre__c?.value : this.genre;
        return genreStr ? genreStr.split(';').join(', ') : ''; // Replace semicolons with commas
    }

    get computedRating() {
        return this.recordId ? this.movie?.data?.fields?.Rating__c?.value : this.rating;
    }

    get computedPosterUrl() {
        return this.recordId ? this.movie?.data?.fields?.Poster_URL__c?.value : this.posterUrl;
    }

    get isHorrorMovie() {
        const genre = this.computedGenre;
        return genre && genre.toLowerCase().includes('horror');
    }

    navigateToDetails() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Movie__c',
                actionName: 'view'
            }
        });
    }
}
