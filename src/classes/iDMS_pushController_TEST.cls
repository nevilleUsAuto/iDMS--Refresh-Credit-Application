/**
 * Created by admin on 2019-05-06.
 */

@IsTest
private class iDMS_pushController_TEST {

    @TestSetup static void testData() {
        insert new Sales_Portal_Integration_Settings__c(Name = 'Standard Settings', Login__c = 'it@usauto-sales.com',
                Password__c = 'IntegrationAX2',Save_Short_Credit_Score_App_URL__c = 'https://ws.usautosales.info/web/portal/SaveShortCreditScoreApp',
                Save_App_Data_URL__c = 'https://ws.usautosales.info/web/portal/SaveCreditScoreApp',
                Get_Credit_Applications_Statuses_URL__c = 'https://ws.usautosales.info/web/portal/GetAllAppStatusComments?ids={ID}',
                Get_Adjusted_Credit_Score_URL__c = 'https://ws.usautosales.info/web/portal/GetAdjustedCreditScore?ids={ID}',
                UpdateLetterPrintedFieldOnSP_URL__c = 'https://ws.usautosales.info/web/portal/PrintLetter',
                GetCalculatorData_URL__c = 'https://ws.usautosales.info/web/portal/GetCalculatorData?id={ID}&isJoint={ISJOINT}',
                Add_User_URL__c = 'https://ws.usautosales.info/web/portal/AddUser',
                Reverse_To_In_Progress_URL__c = 'https://ws.usautosales.info/web/portal/SetInitialPaycallToInProgress',
                Authentification_URL__c = 'https://ws.usautosales.info/web/auth/Authenticate');


        //create both an admin and not admin users
        List<String> profileTypes = new List<String>{
                'Regional Manager New', 'Standard User'
        };
        List<Profile> pf = [SELECT Id FROM Profile WHERE Name IN :profileTypes];

        List<User> usrs = new List<User>{
                new User(LastName = 'IDMSLAST1',
                        FirstName = 'IDMSFIRST',
                        Alias = 'IDMS1',
                        Email = 'idms1@user.com',
                        Username = 'idms1@user.com',
                        ProfileId = pf[0].Id,
                        TimeZoneSidKey = 'GMT',
                        LanguageLocaleKey = 'en_US',
                        EmailEncodingKey = 'UTF-8',
                        LocaleSidKey = 'en_US'),
                new User(LastName = 'IDMSLAST2',
                        FirstName = 'IDMSFIRST2',
                        Alias = 'IDMS2',
                        Email = 'idms2@user.com',
                        Username = 'idms2@user.com',
                        ProfileId = pf[0].Id,
                        TimeZoneSidKey = 'GMT',
                        LanguageLocaleKey = 'en_US',
                        EmailEncodingKey = 'UTF-8',
                        LocaleSidKey = 'en_US')
        };
        insert usrs;
    }

    @IsTest static void isAdminUserTest() {
        Boolean isAdmin;
        String adminUserEmail = 'idms1@user.com';
        User u = [SELECT Id, Name FROM User WHERE Email = : adminUserEmail LIMIT 1];

        Test.startTest();
        System.runAs(u) {
            isAdmin = iDMS_pushController.isCurrentUserAdmin();
        }
        Test.stopTest();

        System.debug('This must be true' + isAdmin + '  user record: ' + u);
        System.assert(isAdmin, 'This must be true');
    }

    @IsTest static void isNonAdminUserTest() {
        Boolean isAdmin;
        String adminUserEmail = 'idms1@user.com';
        User u = [SELECT Id, Name FROM User WHERE Email != : adminUserEmail LIMIT 1];

        Test.startTest();
        System.runAs(u) {
            isAdmin = iDMS_pushController.isCurrentUserAdmin();
        }
        Test.stopTest();

        System.debug('This must be false' + isAdmin + '  user record: ' + u);
        System.assert(isAdmin == false, 'This must be false');
    }

    @IsTest static void iDMSSendTest() {
        String dummyToken = 'GARBAGE TOKEN STRING.';
        String testDealString = '147567';
        String testStockNumber = '221883';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new iDMS_send_MOCK());
        String response = iDMS_pushController.sendToIDMS(dummyToken, testDealString, testStockNumber);
        Test.stopTest();

        System.debug('Response: ' + response);
        System.assert( response.indexOf('Successful') != -1, 'Process should return message containing Successful');
    }

    @IsTest static void getSecurityTokenTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new addVehSoldToOppWebService_Token_MOCK());
        String tokenString = iDMS_pushController.getTokenString();
        System.assert(!String.isBlank(tokenString), 'Could not retrieve security token.');
        Test.stopTest();
    }

}