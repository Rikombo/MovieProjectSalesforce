import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

import POSTER_URL_FIELD from '@salesforce/schema/Movie__c.Poster_URL__c';

export default class MoviePoster extends LightningElement {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: [POSTER_URL_FIELD] })
    movie;

    get posterUrl() {
        return this.movie.data ? this.movie.data.fields.Poster_URL__c.value : null;
    }
}
