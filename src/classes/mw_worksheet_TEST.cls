/**
 * Created by nevil on 11/4/2018.
 */

@IsTest
private class mw_worksheet_TEST {
    @TestSetup static void setup() {
        List<dealer__Credit_Application__c> ca = TestDataFactory.createCreditApplicationsNoCoBuyer(1, false);
        ca[0].Sales_Portal_ID__c = '149233';
        ca[0].Current_Address_State__c = 'GA';
        insert ca;
        System.assert(ca[0].Id != null, 'Credit Application not created.');
    }

    @IsTest static void testGetSecurityToken() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new mw_worksheet_SecurityToken_MOCK());
        String res = mw_worksheet_controller.retrieveToken();
        Test.stopTest();

        System.debug('Security Token: ' + res);

        SecurityToken st = (SecurityToken) JSON.deserialize(res, SecurityToken.class);
        System.assert(st.expiration != null, 'The expiration date of the security token should not be null');
        System.assert(st.access_token != null, 'The token of the security token should not be null');
    }

    class SecurityToken {
        public String access_token;
        public Datetime expiration;
    }

    @IsTest static void testGetDeal() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new mw_worksheet_SecurityToken_MOCK());
        String res = mw_worksheet_controller.retrieveToken();
        Test.stopTest();

        System.debug('Retrieved Token: ' + res);
        SecurityToken st = (SecurityToken) JSON.deserialize(res, SecurityToken.class);

        String portalId = '6366';
        Test.setMock(HttpCalloutMock.class, new mw_worksheet_Deal_MOCK());
        System.debug('Deal Mock Instantiated');
        res = mw_worksheet_controller.myDeal(st.access_token, portalId);
        System.debug('The Deal: ' + res);
        Deal dl = (Deal) JSON.deserialize(res, Deal.class);
        System.assertEquals(dl.dealID, Integer.valueOf(portalId), 'The deal ID should match');
    }

    class Deal {
        public Integer dealID;
        public Integer scoreID;
        public String appType;
        public String offerType;
        public String lot;
        public Decimal maximumMonthlyPayment;
        public Double iRate;
        public Decimal availableDownPayment;
        public Double minDownPaymentPercent;
        public Decimal pickAllowance;
        public Decimal maxSellingPrice;
        public String customergrade;
    }

    @IsTest static void testVehiclesOnLot() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new mw_worksheet_SecurityToken_MOCK());
        String res = mw_worksheet_controller.retrieveToken();
        Test.stopTest();

        SecurityToken st = (SecurityToken) JSON.deserialize(res, SecurityToken.class);

        String lot = '23';
        String grade = 'B';
        String stockno = null;

        Test.setMock(HttpCalloutMock.class, new mw_worksheet_VehiclesOnLot_MOCK());
        System.debug('Vehicles on Lot Mock Instantiated');
        res = mw_worksheet_controller.vehiclesOnLot(st.access_token, lot, grade, stockno);
        System.debug('Vehicles on Lot: ' + res);

        List<Lot> l = (List<Lot>) JSON.deserialize(res, List<Lot>.class);
        System.assertEquals(7, l.size(), 'There are seven vehicles on the log');
        System.debug('Number of vehicles on lot: ' + l.size());
        System.assertEquals('ACURA', l[6].make, 'The seventh vehicle on the lot is an Acura');
    }

    class Lot {
        public String lotLocation;
        public String lot;
        public String stockNo;
        public String carType;
        public String year;
        public String make;
        public String model;
        public String trim;
        public String mileage;
        public Decimal sellingprice;
        public Integer daysonlot;
        public String lotstate;
    }

    @IsTest static void testVehiclesByStockNumber() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new mw_worksheet_SecurityToken_MOCK());
        String res = mw_worksheet_controller.retrieveToken();
        Test.stopTest();

        SecurityToken st = (SecurityToken) JSON.deserialize(res, SecurityToken.class);

        String lot = null;
        String grade = null;
        String stockno = '208703';

        Test.setMock(HttpCalloutMock.class, new mw_worksheet_VehiclesByStockNumber_MOCK());
        System.debug('Vehicles By Stock number on Lot Mock Instantiated');
        res = mw_worksheet_controller.vehiclesOnLot(st.access_token, lot, grade, stockno);
        System.debug('Vehicles by stock number: ' + res);

        Lot l = (Lot) JSON.deserialize(res, Lot.class);
        System.assertEquals(stockno, l.stockNo);

        System.assertEquals('RL', l.model);
    }

    @IsTest static void testGetTables() {

        List<String> nodes = new List<String>{'ca_info','mw_fees','mw_products','mw_downPayments','mw_terms','mw_vscOverrides'};

        List<dealer__Credit_Application__c> ca  = [SELECT Id, Sales_Portal_ID__c, Current_Address_State__c FROM dealer__Credit_Application__c];
        System.debug('CA in test: ' + ca + ' List Size: ' + ca.size());
        System.assertEquals(1, ca.size(), 'Didn\'t get CA record' );

        Test.startTest();
        String obj = mw_worksheet_controller.getTables();
        Test.stopTest();

        System.debug('Tables: ' + obj);
        //confirm that the result contains all the nodes:
        for (String n : nodes) {
            System.assert(obj.indexOf(n) != 0, n + ' IS NOT A NODE IN THE TABLES');
        }
    }

    @IsTest static void testCurrentUserInfo() {
        Test.startTest();
        CurrentUser sobj = (CurrentUser) JSON.deserialize( mw_worksheet_controller.currentUserInfo(), CurrentUser.class);
        //String sobj = mw_worksheet_controller.currentUserInfo();
        Test.stopTest();
        System.debug('metadata types: ' + sobj);
        System.assert(sobj.UserId != null, 'Process failed to retrieve the current user\'s Id');
    }

    class CurrentUser {
        public String UserName;
        public String UserId;
        public String UserEmail;
        public String UserType;
        public String UserRoleId;
    }

}