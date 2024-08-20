import { LightningElement, track } from 'lwc';

export default class MovieCatalogPage extends LightningElement {
    @track selectedGenre = 'All';
    @track selectedLimit = 10; // Default to 10 records

    handleFilter(event) {
        this.selectedGenre = event.detail.genre;
        this.selectedLimit = event.detail.limit;

        const movieCatalog = this.template.querySelector('c-movie-catalog');
        if (movieCatalog) {
            movieCatalog.limitSize = this.selectedLimit;
            movieCatalog.selectedGenre = this.selectedGenre;
            movieCatalog.filterMovies();
        }
    }
}
