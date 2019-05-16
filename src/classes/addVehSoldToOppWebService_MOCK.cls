/**
 * Created by admin on 2019-03-22.
 */

global class addVehSoldToOppWebService_MOCK implements HttpCalloutMock {

    global HttpResponse respond(HttpRequest req) {

        String resString =
                '[{"stockNo":"209887","salesPortalId":"167718","dateSold":"2019-03-19T00:00:00Z"},' +
                '{"stockNo":"209797","salesPortalId":"168199","dateSold":"2019-03-19T00:00:00Z"},' +
                '{"stockNo":"213444","salesPortalId":"169656","dateSold":"2019-03-19T00:00:00Z"},' +
                '{"stockNo":"218177","salesPortalId":"172301","dateSold":"2019-03-18T00:00:00Z"},' +
                '{"stockNo":"218067","salesPortalId":"172230","dateSold":"2019-03-18T00:00:00Z"},' +
                '{"stockNo":"217077","salesPortalId":"172243","dateSold":"2019-03-18T00:00:00Z"},' +
                '{"stockNo":"218216","salesPortalId":"172198","dateSold":"2019-03-20T00:00:00Z"},' +
                '{"stockNo":"218951","salesPortalId":"171569","dateSold":"2019-03-20T00:00:00Z"},' +
                '{"stockNo":"218582","salesPortalId":"170402","dateSold":"2019-03-20T00:00:00Z"}]';

        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(resString);

        res.setStatusCode(200);
        return res;
    }
}