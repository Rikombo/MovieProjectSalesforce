import { LightningElement, track } from 'lwc';

export default class MovieCatalogPage extends LightningElement {
    @track selectedGenre = '';

    handleGenreChange(event) {
        this.selectedGenre = event.detail.genre;

        const movieCatalog = this.template.querySelector('c-movie-catalog');
        if (movieCatalog) {
            movieCatalog.filterMovies();
        }
    }
}
