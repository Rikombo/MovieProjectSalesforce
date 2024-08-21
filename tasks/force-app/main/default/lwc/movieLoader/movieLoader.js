import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import importMoviesAndSync from '@salesforce/apex/MovieDataImporter.importMoviesAndSync';

export default class MovieLoader extends LightningElement {
    @api recordId;

    handleFileUpload(event) {
        const file = event.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = () => {
                const fileContents = reader.result;
                importMoviesAndSync({ jsonMovies: fileContents })
                    .then(result => {
                        this.showToast('Success', result, 'success');
                    })
                    .catch(error => {
                        this.showToast('Error', 'An error occurred while importing movies.', 'error');
                        console.error(error);
                    });
            };
            reader.readAsText(file);
        }
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}
