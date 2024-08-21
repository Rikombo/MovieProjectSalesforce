import { LightningElement, track } from 'lwc';

export default class MovieCatalogPage extends LightningElement {
    @track selectedGenre = 'All';
    @track selectedLimit = 10;

    handleFilter(event) {
        this.selectedGenre = event.detail.genre || 'All';  // Ensure genre fallback
        this.selectedLimit = event.detail.limit || 10;     // Ensure limit fallback

        const movieCatalog = this.template.querySelector('c-movie-catalog');
        if (movieCatalog) {
            movieCatalog.limitSize = this.selectedLimit;
            movieCatalog.selectedGenre = this.selectedGenre;
            movieCatalog.filterMovies();
        }
    }
}
