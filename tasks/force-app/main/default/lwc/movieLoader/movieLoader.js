import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import importMoviesFromFile from '@salesforce/apex/MovieDataImporter.importMoviesFromFile';

export default class MovieLoader extends LightningElement {
    @api recordId;

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;

        // Ensure there is at least one uploaded file
        if (uploadedFiles && uploadedFiles.length > 0) {
            const contentDocumentId = uploadedFiles[0].documentId;

            // Call Apex to process the uploaded file
            importMoviesFromFile({ contentDocumentId })
                .then(result => {
                    this.showToast('Success', result, 'success');
                })
                .catch(error => {
                    console.error('Apex error:', error); 
                    this.showToast('Error', 'Error loading records: ' + (error.body ? error.body.message : error.message), 'error');
                });
        } else {
            this.showToast('Error', 'No files were uploaded.', 'error');
        }
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant,
        });
        this.dispatchEvent(evt);
    }
}
