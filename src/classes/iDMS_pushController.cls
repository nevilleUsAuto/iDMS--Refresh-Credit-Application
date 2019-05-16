/**
 * Created by admin on 2019-05-01.
 */

public without sharing class iDMS_pushController {

    private static String IDMSport = 'https://sf.usauto-sales.com/salesforce/AddSingleDealToIDMS';
    private static String endPoint_Token = 'https://sf.usauto-sales.com/auth/token';
    private static String userName = 'nomeally@usauto-sales.com';
    private static String userPswd = 'USAuto12!';

    // the callout
    private static String webServiceGet(String endPoint, String securityKey, String securityToken, String callMethod,
            String payload) {

        String score = 'Inside webService Get';
        System.debug('Inside webServiceGet');

        try {

            HttpResponse response;

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setMethod(callMethod);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Content-Length', '0'); // Not sure why this is required.
            request.setTimeout(120000);
            request.setEndpoint(endPoint);
            request.setHeader(securityKey, securityToken);

            if (payload != null) {
                request.setBody(payload);
            }

            System.debug('The Request: ' + request);

            response = http.send(request);
            score = 'Response Message: ' + response.getStatusCode() + ' ~~~ ' + response.getBody() + ' ~~~~~'  + request;

            System.debug('webServiceGet Method: ' + score);
            if (response.getStatusCode() == 200) {
                score = ( String.isEmpty(response.getBody()) ? String.valueOf(response.getStatusCode()) : response.getBody()) ;
            } else {
                System.debug(score);
            }

        } catch (Exception e) {
            score = 'Error: getCreditApplication Try/Catch: ' + e.getMessage();
            System.debug(score);
        }

        return score;
    }

    // get the callout token
    @AuraEnabled
    public static String retrieveToken() {
        String token;

        try {

            HttpResponse response;

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setTimeout(120000);
            request.setEndpoint(endPoint_Token);

            JSONGenerator msgBody = JSON.createGenerator(true);
            msgBody.writeStartObject();
            msgBody.writeStringField('Email', userName);
            msgBody.writeStringField('password', userPswd);
            msgBody.writeEndObject();

            System.debug('get token body: ' + msgBody);
            request.setBody(msgBody.getAsString());
            response = http.send(request);

            System.debug('Response Message: ' + response.getStatusCode() + ' ~~~ ' + response.getBody());
            if (response.getStatusCode() == 200) {
                token = response.getBody(); //JSON.serialize(fr);
            } else {
                System.debug(response.getStatusCode());
            }
        } catch (Exception e) {
            token = 'Error: (mw_worksheet_controller=>retrieveToken): ' + e.getMessage();
        }

        return token;
    }

    @AuraEnabled
    public static Boolean isCurrentUserAdmin() {
        List<String>  adminUsers = new List<String>{'Regional Manager New', 'System Administrator'};
        Map<Id, Profile> admIds = new Map<Id,Profile>([SELECT Id, Name FROM Profile WHERE Name IN :adminUsers]);
        return (admIds.get(UserInfo.getProfileId()) != null ? true : false);
    }

    // there are two HTTP callouts associated with this option,
    @AuraEnabled
    public static String sendToIDMS(String securityToken, String dealId, String StockNo) {
        return iDMS_pushController(securityToken, dealId, StockNo);
    }

    @AuraEnabled  //@Future(Callout = true)
    public static String getTokenString() {
        String response = retrieveToken();
        Map<String,Object> token = (Map<String,Object>)JSON.deserializeUntyped(response);
        return (String)token.get('access_token');
    }

    private static String iDMS_pushController(String token, String dealId, String stockNo) {
        String securityKey = 'Authorization';
        String securityValue = 'Bearer ' + token;
        String endPt = IDMSport;
        String callMethod = 'POST';

        JSONGenerator generator = JSON.createGenerator(true); 	//instantiation of the generator
        generator.writeStartObject(); 				// Writes the starting marker of a JSON object '{'
        generator.writeStringField('stockNo', stockNo);    //Writes the lot id
        generator.writeStringField('dealID', dealId);
        generator.writeEndObject(); 				//Writes the ending marker of a JSON object '}'
        String payLoad = generator.getAsString();

        return webServiceGet(endPt, securityKey, securityValue, callMethod, payLoad);
        //System.debug('Inside iDMS_pushController Result: ' + result);
    }

}