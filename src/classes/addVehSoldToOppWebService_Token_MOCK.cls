/**
 * Created by admin on 2019-03-22.
 */

global class addVehSoldToOppWebService_Token_MOCK  implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint and method.
        // System.assertEquals('http://example.com/example/test', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJOT01FQUxMWUBVU0FVVE8tU0FMRVMuQ09NIiwianRpIjoiNWU5Y2JmMDctZGZjNi00NzczLThhOTMtNjYyNDkyNmJiYmY0IiwiZXhwIjoxNTQzMjM5NDYyLCJpc3MiOiJodHRwczovL3NmLnVzYXV0by1zYWxlcy5pbmZvIiwiYXVkIjoiaHR0cHM6Ly9zZi51c2F1dG8tc2FsZXMuaW5mbyJ9.Id_8lQP06Vzky2eyqPCUZbFd4lWSj1zLOO812TCTvKU","expiration": "2018-11-26T13:37:42Z"}');
        res.setStatusCode(200);
        return res;
    }
}