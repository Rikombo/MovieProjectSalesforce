@isTest
global class TMDBApiServiceMock implements HttpCalloutMock {
    
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
            // Adjust the mock response to match the test expectations
            res.setBody('{"id": 300, "original_title": "New Movie Test", "overview": "Mock Description", "vote_average": 7.5, "revenue": 1000000, "genres": [{"id": 18, "name": "Drama"}]}');
        }

        return res;
    }
}
