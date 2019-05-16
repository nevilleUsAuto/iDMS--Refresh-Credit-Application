/**
 * Created by admin on 2018-11-26.
 */

global class mw_worksheet_VehiclesOnLot_MOCK implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('[' +
                '{"lotLocation":"20 -JACKSONVILLE","lot":"20","stockNo":"203681","carType":"TRUCK","year":"2010","make":"ACURA","model":"RDX","trim":"TECH PKG","mileage":"85387","sellingprice":18493.0,"daysonlot":63,"lotstate":"FL"},' +
                '{"lotLocation":"20 -JACKSONVILLE","lot":"20","stockNo":"207690","carType":"TRUCK","year":"2012","make":"KIA","model":"SPORTAGE","trim":"EX","mileage":"94648","sellingprice":18091.0,"daysonlot":63,"lotstate":"FL"},' +
                '{"lotLocation":"20 -JACKSONVILLE","lot":"20","stockNo":"208349","carType":"TRUCK","year":"2011","make":"DODGE","model":"DAKOTA","trim":"BIGHORN/LONESTAR","mileage":"94383","sellingprice":18291.0,"daysonlot":56,"lotstate":"FL"},' +
                '{"lotLocation":"20 -JACKSONVILLE","lot":"20","stockNo":"208774","carType":"CAR","year":"2015","make":"KIA","model":"OPTIMA","trim":"LX","mileage":"55975","sellingprice":18695.0,"daysonlot":56,"lotstate":"FL"},' +
                '{"lotLocation":"20 -JACKSONVILLE","lot":"20","stockNo":"208924","carType":"CAR","year":"2015","make":"KIA","model":"OPTIMA","trim":"LX","mileage":"95711","sellingprice":14995.0,"daysonlot":54,"lotstate":"FL"},' +
                '{"lotLocation":"20 -JACKSONVILLE","lot":"20","stockNo":"208706","carType":"CAR","year":"2012","make":"CADILLAC","model":"CTS","trim":"","mileage":"71969","sellingprice":20395.0,"daysonlot":48,"lotstate":"FL"},' +
                '{"lotLocation":"20 -JACKSONVILLE","lot":"20","stockNo":"208703","carType":"CAR","year":"2010","make":"ACURA","model":"RL","trim":"","mileage":"80976","sellingprice":20595.0,"daysonlot":45,"lotstate":"FL"}' +
                ']');
        res.setStatusCode(200);
        return res;
    }
}