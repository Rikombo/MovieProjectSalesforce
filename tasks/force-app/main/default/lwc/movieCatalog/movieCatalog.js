import { LightningElement } from 'lwc';

export default class MovieCatalog extends LightningElement {
    movie = {
        Title__c: 'Inception',
        Rating__c: 8.8,
        Poster_URL__c: 'https://image.tmdb.org/t/p/original/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg'
    };
}
