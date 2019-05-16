/**
 * Created by admin on 2019-03-22.
 */

@IsTest
public with sharing class TestDataFactory_Opportunity {

    private static String orgId = UserInfo.getOrganizationId();
    private static String dateString {
        get {
            return (String.valueOf(Datetime.now()).replace(' ', '').replace(':', '').replace('-', ''));
        }
    }
    private static Integer randomInt = Integer.valueOf(Math.rint(Math.random()*1000000));
    private static String uniqueName {
        get {
            return (orgId + dateString + randomInt);
        }
    }

    public class DataFactoryException extends Exception {}

    private static List<Integer> portalId = new List<Integer>{167718, 168199, 169656, 172301, 172230, 172243, 172198, 171569, 170402};

    public static Location__c makeOneLocation() {
        try {

            System.debug('IS THERE A LOCATION?');
            List<Location__c> location = [SELECT Id FROM Location__c WHERE Name = 'BDC'];
            System.debug('AFTER: IS THERE A LOCATION?');

            if (location.size() == 0) {

                location.add( new Location__c(
                        Name = 'BDC',
                        City__c = 'test',
                        Postal_Code__c = '12345',
                        State__c = 'TX',
                        SalesPortalId__c = 99,
                        General_Manager__c = UserInfo.getUserId()
                ));
                insert location;
            }
            System.debug('Here is my Location: ' + location);
            return location[0];
        } catch (Exception ex) {
            throw new DataFactoryException('Data Factory Opportunity Exception (Method: makeOneLocation)' + ex.getMessage());
        }
    }

    public static List<Opportunity> makeOpportunity(Integer oppCnt, Boolean dbPost) {

        try {
            List<Opportunity> opp = new List<Opportunity>();

            for (Integer i = 0; i < oppCnt; i++) {
                opp.add(
                        new Opportunity(Name = 'OppName' + String.valueOf(i),
                                StageName = 'Qualify',
                                CloseDate = Date.today().addDays(120))
                );
            }

            if (dbPost) {
                insert opp;
            }

            return opp;
        } catch (Exception ex) {
            throw new DataFactoryException('Data Factory Opportunity Exception (Method: makeOpportunity)' + ex.getMessage());
        }
    }

    public static List<Account> makeAccounts(Integer Cnt, Boolean dbPost) {
        try {
            List<Account> obj = new List<Account>();

            for (Integer i = 0; i < Cnt; i++) {
                obj.add(
                        new Account(
                                Name = 'MyTest Account' + String.valueOf(i)
                        )
                );
            }

            if (dbPost) {
                insert obj;
            }

            return obj;
        } catch (Exception ex) {
            throw new DataFactoryException('Data Factory Opportunity Exception (Method: makeAccounts)' + ex.getMessage());
        }
    }

    public static List<Contact> makeContacts(List<Account> acc, Boolean dbPost) {
        try {
            Id contactTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Business Contact').getRecordTypeId();
            List<Contact> obj = new List<Contact>();

            for (Integer i = 0; i < acc.size(); i++) {
                obj.add(
                        new Contact(LastName = 'TestLastName' + String.valueOf(i),
                                Email = 'Testor' + String.valueOf(i) + '@test.com', AccountId = acc[i].Id,
                                RecordTypeId = contactTypeId)
                );
            }

            if (dbPost) {
                insert obj;
            }

            return obj;
        } catch (Exception ex) {
            throw new DataFactoryException('Data Factory Opportunity Exception (Method: makeContacts)' + ex.getMessage());
        }
    }

    public static List<Credit_Application__c> makeCreditApplications(Integer caCnt, Boolean dbPost) {

        try {
            // build required related objects
            List<Contact> ct = makeContacts(makeAccounts(caCnt, true), true);
            List<Opportunity> opp = makeOpportunity(caCnt, true);
            Location__c loc = makeOneLocation();
            //Integer portalIndex = 12334;
            // end build required related objects

            List<Credit_Application__c> obj = new List<Credit_Application__c>();

            for (Integer i = 0; i < caCnt; i++) {
                obj.add(
                        new Credit_Application__c(
                                Buyer__c = ct[i].Id,
                                Opportunity__c = opp[i].Id,
                                Repeat_Customer__c = '1 Prior Purchase',
                                Co_App_Repeat_Customer__c = '1 Prior Purchase',
                                Store_Location__c = loc.Id,
                                Sales_Portal_ID__c = String.valueOf(portalId[i])
                        )
                );
            }

            if (dbPost) {
                insert obj;
            }

            return obj;
        } catch (Exception ex) {
            throw new DataFactoryException('Data Factory Opportunity Exception (Method: makeCreditApplications)' + ex.getMessage());
        }
    }

    public static List<Event> makeOpportunityEvents(List<Opportunity> opps, Boolean dbPost, Boolean addBlankResult) {
        try {
            List<Event> events = new List<Event>();
            List<String> appResults = new List<String>{
                    'Show', 'No-Show'
            };

            for (Integer i = 0; i < opps.size(); i++) {
                events.add(
                        new Event(
                                WhatId = opps[i].Id,
                                DurationInMinutes = 30,
                                Subject = 'Meeting',
                                ActivityDate = Date.today().addDays(7),
                                StartDateTime = Datetime.now(),
                                Appointment_Result__c = (Math.mod(i, 2) == 0 ? appResults[0] : appResults[1]),
                                Confirmes__c = (Math.mod(i, 2) == 0 ? true : false),
                                Set_By__c = UserInfo.getUserId()
                        ));
            }

            System.debug('Here are the Events before insert: ' + events);

            if (addBlankResult) {
                events.add(
                        new Event(
                                WhatId = opps[0].Id,
                                DurationInMinutes = 30,
                                Subject = 'Meeting',
                                ActivityDate = Date.today().addDays(10),
                                StartDateTime = Datetime.now(),
                                Appointment_Result__c = '',
                                Confirmes__c = true,
                                Set_By__c = UserInfo.getUserId()
                        ));
            }

            if (dbPost) {
                insert events;
            }

            return events;
        } catch (Exception ex) {
            throw new DataFactoryException('Data Factory Opportunity Exception (Method: makeOpportunityEvents)' + ex.getMessage());
        }
    }

    public static List<Lead> makeLeads(Integer Cnt, Boolean dbPost) {
        try {
            List<Lead> obj = new List<Lead>();
            Integer phLastFour = 1000;

            for (Integer i = 0; i < Cnt; i++) {
                obj.add(
                        new Lead(
                                Email = 'dops@usauto-sales.com', // uniqueName + '@test' + orgId + '.org',
                                Channel__c = 'DealerOn',  // not sure this is being used.
                                Lead_Channel__c = 'Walk-in',
                                Lead_Status__c = 'WORKING', // IN STORE, COMPLETE, COMING BACK, DEAD PHONE APPLICATION, ONLINE APPROVAL
                                MobilePhone = '999101' + String.valueOf(phLastFour + i),
                                Store_Location_New__c = null,
                                Salesperson_1__c = null,
                                Comments__c = 'Lead Comment ' + String.valueOf(i),
                                LastName = 'BakerTest',
                                FirstName = 'Testing'
                        )
                );
            }

            if (dbPost) {
                insert obj;
            }

            return obj;
        } catch (Exception ex) {
            throw new DataFactoryException('Data Factory Opportunity Exception (Method: makeLeads)'
                    + ex.getMessage() + ' ~~ Error Cause: '
                    + ex.getCause() + ' ~~ Error Line Number: '
                    + ex.getLineNumber());
        }
    }

}