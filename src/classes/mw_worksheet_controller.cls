/**
 * Created by admin on 10/2/18.
 */

public with sharing class mw_worksheet_controller {
    /************************************************************************
    *
    *
    *      GLOBAL VARIABLES
    *
    *************************************************************************/
    @TestVisible private static String gPortalId;

    /************************************************************************
    *
    *
    *       WEB SERVICE CALLOUT SECTION
    *
    *************************************************************************/
    private static String endPoint_Token = 'https://sf.usauto-sales.com/auth/token';
    private static String userName = 'nomeally@usauto-sales.com';
    private static String userPswd = 'USAuto12!';
    private static String endPoint_Deal = 'https://sf.usauto-sales.com/salesforce/getSFDeals?DealID=';
    private static String endPoint_Vehicles = 'https://sf.usauto-sales.com/salesforce/getSFVehicles';

    // the callout
    public static String webServiceGet(String endPoint, String securityKey, String securityToken, String callMethod,
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

    // dynamic processes data
    class dpd {
        public List<Menu_Worksheet_Product__mdt> mw_products;
        public List<Menu_Worksheet_Required_Down_Payment__mdt> mw_downPayments;
        public List<Menu_Worksheet_Terms__mdt> mw_terms;
        public List<Menu_Worksheet_VSC_Override__mdt> mw_vscOverrides;

        private dpd() {
            mw_products = [SELECT List_Sort_Order__c, Product_Type__c, Description__c, Cost__c
                FROM Menu_Worksheet_Product__mdt ORDER BY List_Sort_Order__c];//should remap this to dpdProducts class--later.
            mw_downPayments = [SELECT List_Sort_Order__c, Package_Type__c, Number_of_Products_Required__c, Cash_Down_Required__c
                FROM Menu_Worksheet_Required_Down_Payment__mdt  ORDER BY List_Sort_Order__c];
            mw_terms = [SELECT List_Sort_Order__c, Vehicle_Type__c, Low_Mileage__c, High_Mileage__c, Months_Base_Package__c,
                    Months_Tier_1__c, Months_Tier_2__c, BiWeekly_Base__c, BiWeekly_Tier_1__c, BiWeekly_Tier_2__c
                FROM Menu_Worksheet_Terms__mdt  ORDER BY List_Sort_Order__c];

            mw_vscOverrides = [SELECT VSC_Override_State_Code__c, VSC_Override_State_Name__c FROM Menu_Worksheet_VSC_Override__mdt];
        }
    }

    // dynamic processes data -- fees table.  This is depended on having a portal id and is called for each deal.
    // to reduce the number of queries, if the CA State is the same, do not call the Fee query
    class dpdFees {
        public List<Menu_Worksheet_Fee__mdt> mw_fees; //only update if different than the last
        public List<dealer__Credit_Application__c> ca_info;

        public dpdFees(String cState, String portalId) {
            ca_info = [
                    SELECT Id, Sales_Portal_ID__c, Current_Address_State__c, dealer__First_Name__c, dealer__Last_Name__c, Name
                    FROM dealer__Credit_Application__c
                    WHERE Sales_Portal_ID__c = :portalId
            ];  // will only be one; could limit 1; personal preference.

            System.debug('Credit Application: ' + ca_info);
            if (ca_info.size() != 0 && String.isNotBlank(ca_info[0].Current_Address_State__c)) { //} && ca_info[0].Current_Address_State__c != cState) {
                mw_fees = [
                        SELECT State__c, Description__c, Fee_Value__c
                        FROM Menu_Worksheet_Fee__mdt
                        WHERE State__c = :ca_info[0].Current_Address_State__c
                        ORDER BY State__c
                ];
                if ( mw_fees.size() == 0) {
                    throw new AuraHandledException('Process Aborted: The Fee Table does not have a configuration for the selected State Code:- ' +
                            ca_info[0].Current_Address_State__c );
                }
            } else {
                throw new AuraHandledException('Process Aborted: Did not find a Credit Application with the specified Port ID or invalid State Code: ' + ca_info[0].Id);
            }
            System.debug('Fees Table: ' + mw_fees);
        }
    }

    class dpdProducts {
        public List<Menu_Worksheet_Product__mdt> mw_products;

        private dpdProducts() {
            mw_products = [
                    SELECT List_Sort_Order__c, Product_Type__c, Description__c, Cost__c
                    FROM Menu_Worksheet_Product__mdt
                    ORDER BY List_Sort_Order__c
            ];
        }
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

    // get the deal by portal ID
    @AuraEnabled
    public static String myDeal(String securityToken, String portalId) {
        gPortalId = portalId;
        String securityKey = 'Authorization';
        String securityValue = 'Bearer ' + securityToken;
        String endPt = endPoint_Deal + portalId;
        String callMethod = 'POST';

        System.debug('Inside getDeal');

        String result = webServiceGet(endPt, securityKey, securityValue, callMethod, null);
        System.debug('Inside getDeal Result: ' + result);

        return result;
    }

    // Get Vehicles by lot
    @AuraEnabled
    public static String vehiclesOnLot(String securityToken, String lotId, String grade, String stockno) {
        String securityKey = 'Authorization';
        String securityValue = 'Bearer ' + securityToken;
        String callMethod = 'POST';

        System.debug('Inside get Vehicles on Lot');

        JSONGenerator generator = JSON.createGenerator(true); 	//instantiation of the generator
        generator.writeStartObject(); 				// Writes the starting marker of a JSON object '{'

        if (stockno == null) {
            generator.writeStringField('lot', lotId);    //Writes the lot id
            generator.writeStringField('grade', grade);
        } else {
            generator.writeStringField('stockno', stockno);
        }
        generator.writeEndObject(); 				//Writes the ending marker of a JSON object '}'
        String payLoad = generator.getAsString();

        String result = webServiceGet(endPoint_Vehicles, securityKey, securityValue, callMethod, payLoad);
        System.debug('Inside getDeal Result: ' + result);

        return result;
    }

    // table data to initialize dynamic processes
    // fees table is depended on Portal ID on the credit app.
    @AuraEnabled
    public static String getFeesTables(String cState, String portalId) {

        System.debug('getTables method in Apex Controller with State Parameter.');
        return JSON.serialize(new dpdFees(cState, portalId));
    }

    // table data to initialize dynamic processes
    @AuraEnabled
    public static String getTables() {
        System.debug('getTables method in Apex Controller WITHOUT State Parameter.');
        return JSON.serialize(new dpd());
    }

    @AuraEnabled
    public static String getProductTables() {
        return JSON.serialize(new dpdProducts());
    }

    //get current user object.  Necessary when the user disables picks
    @AuraEnabled
    public static String currentUserInfo() {
        JSONGenerator currentUserInfo = JSON.createGenerator(true);
        currentUserInfo.writeStartObject();
        currentUserInfo.writeStringField('UserName', UserInfo.getName());
        currentUserInfo.writeStringField('UserId', UserInfo.getUserId());
        currentUserInfo.writeStringField('UserEmail', UserInfo.getUserEmail());
        currentUserInfo.writeStringField('UserType', UserInfo.getUserType());
        currentUserInfo.writeStringField('UserRoleId', UserInfo.getUserRoleId());
        //currentUserInfo.writeStringField('SessionId', UserInfo.getSessionId());
        currentUserInfo.writeEndObject();
        return currentUserInfo.getAsString();
    }

    @AuraEnabled
    public static String saveTheDeal( List<Menu_Desking_Project__c> mdp) {

        System.debug('Spit it out: ' + mdp);

        Menu_Desking_Project__c mp = [SELECT Id FROM Menu_Desking_Project__c WHERE hdr_Deal_ID__c =: mdp[0].hdr_Deal_ID__c LIMIT 1];

        if (mp != null) {
            mdp[0].Id = mp.Id;
        }
        upsert mdp;

        return JSON.serialize(mdp);
    }

    @AuraEnabled
    public static String getTheDeal( String portalId ) {

        List<Menu_Desking_Project__c> mdp = [SELECT Buyer__c,CreatedDate,dpi_Additional_Cash_to_Unlock_Picks__c,dpi_Cash_Down__c,dpi_Pick_Allowance__c,dpi_Pick_Amount__c,
                dpi_Trade_ACV_Amount__c,dpi_Trade_in_Payoff_Amount__c,hdr_Deal_ID__c,hdr_Disable_Picks__c,hdr_Down_Payment_Percentage__c,hdr_Layaway__c,
                hdr_Lot_Description__c,hdr_Toggle_Payment_Terms__c,Id,LastActivityDate,LastModifiedById,LastModifiedDate,Name,OwnerId,
                pci_Bi_Weekly_Payment__c,pci_Interest_Rate__c,pci_Max_Monthly_Payment__c,pci_Percent_Required_to_Unlock_Picks__c,
                pci_Required_Amount_to_Unlock_Picks__c,ps_Bi_weekly_Payment_T1__c,ps_Bi_weekly_Payment_T2__c,ps_Bi_Weekly_Payment__c,
                ps_Bi_weekly_Term_Allowed_T1__c,ps_Bi_weekly_Term_Allowed_T2__c,ps_Bi_weekly_Term_Allowed__c,ps_Monthly_Payment_T1__c,
                ps_Monthly_Payment_T2__c,ps_Monthly_Term_Allowed_T1__c,ps_Monthly_Term_Allowed_T2__c,ps_Monthly_Term_Allowed__c,
                ps_Number_of_Products__c,ps_Required_Cash_Down_T1__c,ps_Required_Cash_Down_T2__c,ps_Required_Cash_Down__c,
                SystemModstamp,vs_Bi_weekly_Payment__c,vs_Desired_Term__c,vs_Down_Payment_Required__c,vs_Estimated_Monthly_Payment__c,
                vs_Estimated_Taxes__c,vs_Gap_Amount__c,vs_Mileage__c,vs_Product_Total__c,vs_Roadside__c,vs_Selected_Package__c,
                vs_Selected_Vehicle__c,vs_VCS_Amount__c,vs_Vehicle_List_Price__c,vs_Vehicle_Retail_Price__c,vs_Vehicle_Stock_Number__c,
                vs_VSC_Override_Amount__c, BuyerStateCode__c FROM Menu_Desking_Project__c WHERE hdr_Deal_ID__c =: portalId];

        //List<sObject> mdp = Database.query(queryString);
        System.debug('The Deal Record: ' + mdp +'  ~~~ Portal ID: ' + portalId );
        return JSON.serialize(mdp);


    }

}