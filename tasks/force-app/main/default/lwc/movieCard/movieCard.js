import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import RATING_FIELD from '@salesforce/schema/Movie__c.Rating__c';
import TITLE_FIELD from '@salesforce/schema/Movie__c.Title__c';
import POSTER_URL_FIELD from '@salesforce/schema/Movie__c.Poster_URL__c';
import GENRE_FIELD from '@salesforce/schema/Movie__c.Genre__c';

export default class MovieCard extends LightningElement {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: [RATING_FIELD, TITLE_FIELD, POSTER_URL_FIELD, GENRE_FIELD] })
    movie;

    get rating() {
        return this.movie.data ? this.movie.data.fields.Rating__c.value : 'N/A';
    }

    get title() {
        return this.movie.data ? this.movie.data.fields.Title__c.value : 'No Title';
    }

    get posterUrl() {
        return this.movie.data ? this.movie.data.fields.Poster_URL__c.value : '';
    }

    get genre() {
        return this.movie.data ? this.movie.data.fields.Genre__c.value : '';
    }
}
