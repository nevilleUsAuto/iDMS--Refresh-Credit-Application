/**
 * Created by admin on 3/19/18.
 */

@IsTest
global class TestDataFactory {

    global static List<Account> createAccounts(Integer numAccounts, Boolean doInsert) {
        return makeAccounts(numAccounts, doInsert);
    }

    global static List<Schema.Contact> createContacts(Integer numContacts, Boolean doInsert) {
        return makeContacts(numContacts, doInsert);
    }

    global static List<Schema.Contact> createReferenceContacts(Integer numContacts, Boolean doInsert, ID id) {
        return makeReferenceContacts(numContacts, doInsert, id);
    }


    global static List<dealer__Dealer_Location__c> createDealerLocations(Integer numSalesUps, Boolean doInsert) {
        return makeDealerLocation(numSalesUps, doInsert);
    }

    global static List<dealer__Sales_Up__c> createSalesUps(Integer numSalesAppoints, Boolean doInsert) {
        return makeSalesUps(numSalesAppoints, doInsert);
    }

    global static List<dealer__Sales_Appointment__c> createSalesAppointments(Integer numSalesAppoints, Boolean doInsert) {
        return makeSalesAppointments(numSalesAppoints, doInsert);
    }

    global static List<dealer__Credit_Application__c> createCreditApplications(Integer numCreditApps, Boolean doInsert) {
        return makeCreditApplications(numCreditApps, doInsert);
    }

    global static List<dealer__Credit_Application__c> createCreditApplicationsNoCoBuyer(Integer numCreditApps, Boolean doInsert) {
        return makeCreditApplicationsNoCoBuyer(numCreditApps, doInsert);
    }

    global static List<dealer__Deal__c> createDealerDeals(Integer numDeals, Boolean doInsert,
            List<dealer__Sales_Up__c> salesUp, List<dealer__Dealer_Location__c> location) {
        return makeDealerDeals(numDeals, doInsert, salesUp, location);
    }

    global static List<Task> createTasks(Integer numTasks, Boolean doInsert) {
        return makeTasks(numTasks, doInsert);
    }

    global static User createUser(Boolean MakeActive, Boolean doInsert) {
        return makeNewUser(MakeActive, doInsert);
    }

    global static List<TrafficLog__c> createTrafficLogs( Boolean doInsert, List<dealer__Sales_Up__c> su){
        return makeTrafficLogs(doInsert, su);
    }
    /****************************************************************************************************
    **
    **       ACTION SECTION
    **
    ****************************************************************************************************/

    // create one traffic log for each SU
    private static List<TrafficLog__c> makeTrafficLogs(Boolean doInsert, List<dealer__Sales_Up__c> su){
        List<TrafficLog__c> tLogs = new List<TrafficLog__c>();

        for (Integer idx = 0; idx < su.size(); idx++) {
            tLogs.add(
                    new TrafficLog__c(
                            LogType__c = 'Lead Created',
                            SalesUp__c = su[idx].Id
                    )
            );
        }

        if (doInsert) {
            insert tLogs;
        }
        return tLogs;
    }

    private static User makeNewUser(Boolean MakeActive, Boolean doInsert) {
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'Test Role');
        insert r;

        User u = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name LIKE '%ISC%' LIMIT 1].Id,
                LastName = 'Architect' + System.currentTimeMillis(),
                FirstName = 'Developer',
                Email = 'Architect@testing.com',
                Username = 'architect@testing.com',
                CompanyName = 'Test Company',
                Title = 'Senior Architect',
                Alias = 'arch',
                TimeZoneSidKey = 'America/New_York',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                IsActive = MakeActive,
                UserRoleId = r.Id
        );
        if (doInsert) {
            insert u;
        }
        return u;
    }

    private static List<Account> makeAccounts(Integer numAccounts, Boolean doInsert) {

        Map <String, Schema.RecordTypeInfo> rtm = Account.sObjectType.getDescribe().getRecordTypeInfosByName();

        /* individual accounts
        Schema.RecordTypeInfo rti = rtm.get('Individual Account');

        numAccounts = (numAccounts > 10 ? 10 : numAccounts);
        List<Account> accounts = new List<Account>();

        for (Integer idx = 0; idx < numAccounts; idx++) {
            accounts.add(
                    new Account(
                            Name = 'Account Name ' + String.valueOf(idx + 1)
                    )
            );
        }
        */

        //numAccounts = (numAccounts > 10 ? 10 : numAccounts); do not modify for accounts.
        List<Account> accounts = new List<Account>();
        Schema.RecordTypeInfo rti = rtm.get('Person Account');

        for (Integer idx = 0; idx < numAccounts; idx++) {
            accounts.add(
                    new Account(
                            FirstName = 'TDF_FirstName' + String.valueOf(idx + 1),
                            MiddleName = 'MiddleName' + String.valueOf(idx + 1),
                            LastName = 'TDF_LastName' + String.valueOf(idx + 1),
                            PersonHomePhone = '212345678' + String.valueOf(idx), // need to account for greater than two digits
                            PersonMobilePhone = '212345678' + String.valueOf(idx),
                            PersonEmail = 'test' + String.valueOf(idx + 1) + '@test.com',
                            dealer__Drivers_License_Number__pc = '12345678',
                            dealer__Drivers_License_State__pc = 'GA'
                    )
            );
        }

        System.debug('value of rti: ' + rti );
        if (rti != null) {
            System.debug('Adding Record Types');

            for (Account a : accounts) {
                a.RecordTypeId = rti.getRecordTypeId();
                System.debug('Record Type added');
            }
        }

        if (doInsert) {
            System.debug('List of Accounts to add: ' + accounts);
            insert accounts;
        }

        return accounts;
    }

    private static List<Schema.Contact> makeContacts(integer numContacts, Boolean doInsert) {
        numContacts = (numContacts > 10 ? 10 : numContacts);
        List<Schema.Contact> contacts = new List<Schema.Contact>();

        for (Integer idx = 0; idx < numContacts; idx++) {
            contacts.add(
                    new Schema.Contact(
                            FirstName = 'FirstName' + String.valueOf(idx + 1),
                            LastName = 'LastName' + String.valueOf(idx + 1),
                            Phone = '212345678' + String.valueOf(idx),
                            Email = 'testing9@gmail.com',
                            MobilePhone = '212345679'
                    )
            );
        }

        if (doInsert) {
            insert contacts;
        }

        return contacts;
    }

    private static List<Schema.Contact> makeReferenceContacts(integer numContacts, Boolean doInsert, Id id) {
        numContacts = (numContacts > 10 ? 10 : numContacts);
        List<Schema.Contact> contacts = new List<Schema.Contact>();
        Id contactRefRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Reference').getRecordTypeId();



        for (Integer idx = 0; idx < numContacts; idx++) {
            contacts.add(
                    new Schema.Contact(
                            FirstName = 'FirstName' + String.valueOf(idx + 1),
                            LastName = 'LastName' + String.valueOf(idx + 1),
                            Phone = '212345678' + String.valueOf(idx),
                            Email = 'testing' + String.valueOf(idx) + '@gmail.com',
                            MobilePhone = '212345679',
                            RecordTypeId = contactRefRecTypeId,
                            ca_Reference__c = id
                    )
            );
        }

        if (doInsert) {
            insert contacts;
        }

        return contacts;
    }

    private static List<dealer__Dealer_Location__c> makeDealerLocation(Integer quantity, Boolean doInsert) {
        quantity = (quantity > 10 ? 10 : quantity);
        List<dealer__Dealer_Location__c> ddl = new List<dealer__Dealer_Location__c>();

        for (Integer idx = 0; idx < quantity; idx++) {
            ddl.add(
                    new dealer__Dealer_Location__c(
                            Name = 'TDF_Test Store - ' + String.valueOf(idx + 1),
                            dealer__Company_Number__c = 'CN-' + String.valueOf(idx + 1),
                            dealer__City__c = 'Test City' + String.valueOf(idx + 1),
                            dealer__Postal_Code__c = '3009' + String.valueOf(idx + 1),
                            dealer__State__c = 'GA',
                            PodiumId__c = 30094
                    )
            );
        }

        if (doInsert) {
            System.debug('The Deal: ' + ddl);
            insert ddl;
        }

        return ddl;
    }

    /***************************************************************************
    *
    * modify this method to accept a list of account.  If the size matches the quantity,
    * then make one to one. Otherwise just use the first account id.  If size is 0, make one
    * account and use the one for the number of salesUp requested.
    *
    * similar consideration for dealer location.
    *
    ****************************************************************************/
    private static List<dealer__Sales_Up__c> makeSalesUps(Integer quantity, Boolean doInsert) {
        quantity = (quantity > 10 ? 10 : quantity);
        List<dealer__Sales_Up__c> salesUps = new List<dealer__Sales_Up__c>();

        List<Account> accounts = makeAccounts((quantity + 1), true);  //added 1 for the co_buyer property.
        List<dealer__Dealer_Location__c> location = makeDealerLocation(quantity, true);
        List<Schema.Contact> contacts = makeContacts(quantity, true);

        for (Integer idx = 0; idx < quantity; idx++) {
            salesUps.add(
                    new dealer__Sales_Up__c(
                            dealer__FirstName__c = 'Test',
                            dealer__LastName__c = 'Test' + System.currentTimeMillis(),
                            dealer__Phone__c = '212-456-7809',
                            dealer__Email__c = 'test' + System.currentTimeMillis() + '@test.com',
                            dealer__Buyer_Contact__c = contacts[idx].Id,
                            dealer__Mailing_Street__c = System.currentTimeMillis() + ' Trial Drive',
                            dealer__Mailing_City__c = 'Duluth',
                            dealer__Mailing_State__c = 'GA',
                            dealer__Mailing_Zip__c = '30052',
                            dealer__Lead_Type__c = 'BDC',
                            dealer__Lead_Status__c = 'Open',
                            dealer__Customer_Account__c = accounts[idx].Id,
                            dealer__Co_Buyer__c = accounts[quantity].Id,  // same co_buyer for all
                            dealer__Store_Location__c = location[idx].Id,
                            dealer__Latest_Appointment_Date_Time__c = Datetime.now(),
                            dealer__CCC_Rep__c = UserInfo.getUserId(),
                            dealer__Birthdate__c = Date.today().addYears(-20)
                    )
            );
        }

        if (doInsert) {
            insert salesUps;
        }

        return salesUps;
    }

    private static List<dealer__Credit_Application__c> makeCreditApplicationsNoCoBuyer(integer quantity, Boolean doInsert) {
        quantity = (quantity > 10 ? 10 : quantity);
        List<dealer__Credit_Application__c> creds = new List<dealer__Credit_Application__c>();

        List<Account> accounts = makeAccounts(quantity, true);
        List<dealer__Sales_Up__c> salesUp = makeSalesUps(quantity, true);
        List<dealer__Dealer_Location__c> location = [SELECT Id FROM dealer__Dealer_Location__c]; // created in Sales Up process.

        if (location.size() == 0) {
            location = makeDealerLocation(quantity, true);
        }

        for (Integer idx = 0; idx < quantity; idx++) {
            creds.add(
                    new dealer__Credit_Application__c(
                            dealer__First_Name__c = 'Test Buyer',
                            dealer__Middle_Name__c = 'Test Buyer',
                            dealer__Last_Name__c = 'Test Buyer' + System.currentTimeMillis(),
                            dealer__Home_Phone__c = '770-456-0978',
                            dealer__Mobile_Phone__c = '770-234=5678',
                            dealer__Email_Address__c = 'test' + System.currentTimeMillis() +'@test.com',
                            dealer__Driver_License_No__c = '12345678',
                            Driver_License_State__c = 'GA',
                            dealer__Buyer_Account__c = accounts[0].Id,
                            Credit_Application_Status__c = 'In Progress',
                            dealer__Store_Location__c = location[0].Id,
                            Sales_Up__c = salesUp[0].Id,
                            Current_House_Number__c = '20',
                            Current_Street__c = 'Dodge',
                            Current_Street_Type__c = 'Drive',
                            dealer__Current_Address_City__c = 'Dodge City',
                            Current_Address_State__c = 'GA',
                            dealer__Current_Address_Zip__c= '30052',
                            dealer__BirthDate__c = date.today().addYears(-30)
                    )
            );
        }

        if (doInsert) {
            insert creds;
        }

        return creds;
    }

    private static List<dealer__Credit_Application__c> makeCreditApplications(Integer quantity, Boolean doInsert) {
        quantity = (quantity > 10 ? 10 : quantity);
        List<dealer__Credit_Application__c> creds = new List<dealer__Credit_Application__c>();

        List<Account> accounts = makeAccounts((quantity + 1), true); // one more for the cobuyer account.  same for all
        List<dealer__Sales_Up__c> salesUp = makeSalesUps(quantity, true);
        List<dealer__Dealer_Location__c> location = [SELECT Id FROM dealer__Dealer_Location__c]; // created in Sales Up process.

        if (location.size() == 0) {
            location = makeDealerLocation(quantity, true);
        }

        for (Integer idx = 0; idx < quantity; idx++) {
            creds.add(
                    new dealer__Credit_Application__c(
                            dealer__First_Name__c = 'Test Buyer',
                            dealer__Middle_Name__c = 'Test Buyer',
                            dealer__Last_Name__c = 'Test Buyer',
                            dealer__Co_App_First_Name__c = 'Test Co-Buyer',
                            dealer__Co_App_Last_Name__c = 'Test Co-Buyer',
                            dealer__Home_Phone__c = '212-345-678' + String.valueOf(idx),
                            dealer__Mobile_Phone__c = '212-345-678' + String.valueOf(idx),
                            dealer__Email_Address__c = 'test' + System.currentTimeMillis() + '@test.test',
                            dealer__Driver_License_No__c = '21234567804' + String.valueOf(idx),
                            Driver_License_State__c = 'GA',
                            dealer__Buyer_Account__c = accounts[idx].Id,
                            dealer__Co_Buyer_Account__c = accounts[quantity].Id, // same cobuyer on all
                            Credit_Application_Status__c = 'In Progress',
                            dealer__Store_Location__c = location[idx].Id,
                            Sales_Up__c = salesUp[idx].Id,
                            Current_House_Number__c = '20' + String.valueOf(idx),
                            Current_Street__c = 'Dodge',
                            Current_Street_Type__c = 'Drive',
                            dealer__Current_Address_City__c = 'Dodge City',
                            Current_Address_State__c = 'GA',
                            dealer__Current_Address_Zip__c= '30052',
                            dealer__BirthDate__c = Date.today().addYears(-30)
                    )
            );
        }

        if (doInsert) {
            insert creds;
        }

        return creds;
    }

    private static List<dealer__Sales_Appointment__c> makeSalesAppointments(integer quantity, Boolean doInsert) {
        quantity = (quantity > 10 ? 10 : quantity);
        List<dealer__Sales_Appointment__c> salesAppointments = new List<dealer__Sales_Appointment__c>();

        List<dealer__Sales_Up__c> salesUp = makeSalesUps(quantity, true);

        for (Integer idx = 0; idx < quantity; idx++) {
            salesAppointments.add(
                    new dealer__Sales_Appointment__c(
                            dealer__Assigned_To__c = UserInfo.getUserId(),
                            dealer__Appointment_Type__c = 'First Visit',
                            dealer__Date__c = System.today() - 5,
                            dealer__Time__c = '10:55 AM',
                            dealer__Sales_Up__c = salesUp[idx].Id,
                            dealer__DateTime__c = System.today()
                    )
            );

        }

        if (doInsert) {
            insert salesAppointments;
        }

        return salesAppointments;
    }

    private static List<dealer__Deal__c> makeDealerDeals(integer quantity, Boolean doInsert,
            List<dealer__Sales_Up__c> salesUp, List<dealer__Dealer_Location__c> location) {

        quantity = (quantity > 10 ? 10 : quantity);
        List<dealer__Deal__c> theDeals = new List<dealer__Deal__c>();

        for (Integer idx = 0; idx < quantity; idx++) {
            theDeals.add(
                    new dealer__Deal__c(
                            Name = 'a0C6100000L8BPd-' + +String.valueOf(idx + 1),
                            dealer__Store_Location__c = location[0].Id,
                            dealer__Sales_Lead__c = salesUp[0].Id,
                            dealer__Deal_ID__c = '66032_SALESFORCE_197231_197231_2_55.0' + String.valueOf(idx + 1)
                    )
            );
        }

        if (doInsert) {
            insert theDeals;
            // make created date yesterday for testing
            for (dealer__Deal__c dd : theDeals) {
                Test.setCreatedDate(dd.Id, (System.now().addDays(-1)));
            }
        }

        return theDeals;
    }

    /*************************************************************************
     *
     * @param quantity = number of task to create
     * @param doInsert = should the method execute the DML to insert the list
     *
     * @return = the list of created task
     *
     * Recommendation: use an even number quantity that to get an even number of Statuses, IsArchived, and Priority
     */
    private static List<Task> makeTasks( Integer quantity, Boolean doInsert) {
        List<Task> tk = new List<Task>();
        List<String> tkStatus = new List<String>{'Open', 'Completed'};
        List<String> priority = new List<String> {'high', 'low'};

        quantity = (quantity > 10 ? 10 : quantity);

        for(Integer idx = 0; idx < quantity; idx++) {
            tk.add(
                    new Task(
                            Type = 'Email',
                            Subject = 'Test Task Email'+ String.valueOf(idx + 1),
                            Status = tkStatus[math.mod(idx,2)],
                            Priority = priority[math.mod(idx,2)],
                            ActivityDate = System.Date.today()
                    )
            );
        }

        if (doInsert) {
            insert tk;
        }

        return tk;
    }

}