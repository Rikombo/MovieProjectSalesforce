import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

// Import the field that contains the Poster URL
import POSTER_URL_FIELD from '@salesforce/schema/Movie__c.Poster_URL__c';

export default class MoviePoster extends LightningElement {
    @api recordId;

    // Fetch the movie record, including the Poster URL field
    @wire(getRecord, { recordId: '$recordId', fields: [POSTER_URL_FIELD] })
    movie;

    // Get the poster URL from the movie record
    get posterUrl() {
        return this.movie.data ? this.movie.data.fields.Poster_URL__c.value : null;
    }
}
