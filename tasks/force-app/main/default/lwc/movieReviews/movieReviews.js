import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import fetchReviews from '@salesforce/apex/TMDBApiService.fetchReviews';

const FIELDS = ['Movie__c.TMDB_ID__c'];

export default class MovieReviews extends LightningElement {
    @api recordId;  // The recordId will be passed automatically when placed on the movie record page
    @track reviews = [];
    @track error;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (data) {
            const tmdbId = data.fields.TMDB_ID__c.value;
            this.loadReviews(tmdbId);
        } else if (error) {
            this.error = 'Error fetching movie record: ' + JSON.stringify(error);
        }
    }

    loadReviews(tmdbId) {
        fetchReviews({ tmdbId })
            .then(reviews => {
                this.reviews = reviews.map(review => {
                    return {
                        ...review,
                        created_at: new Date(review.created_at).toLocaleDateString()
                    };
                });
                this.error = undefined;
            })
            .catch(error => {
                this.error = 'Error fetching reviews: ' + error.body.message;
                this.reviews = [];
            });
    }
}
