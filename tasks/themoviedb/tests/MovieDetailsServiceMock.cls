@IsTest
global class MovieDetailsServiceMock implements HttpCalloutMock {

    private String mockResponse;

    public void setMockResponse(String response) {
        this.mockResponse = response;
    }

    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        
        // Use the custom mock response if provided
        if (mockResponse != null) {
            res.setBody(mockResponse);
        } else {
            // Default mock response
            res.setBody('{"id": "12345", "title": "Mock Movie Title", "overview": "Mock Description", "vote_average": 7.5, "revenue": 500000, "budget": 200000, "poster_path": "/mock_poster.jpg", "genres": [{"id": 18, "name": "Drama"}, {"id": 35, "name": "Comedy"}]}');
        }

        return res;
    }
}
