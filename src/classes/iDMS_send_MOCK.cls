/**
 * Created by admin on 2019-05-07.
 */

global class iDMS_send_MOCK implements HttpCalloutMock {

    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"response":"iDMS Send Successful"}');
        res.setStatusCode(200);
        return res;
    }

}