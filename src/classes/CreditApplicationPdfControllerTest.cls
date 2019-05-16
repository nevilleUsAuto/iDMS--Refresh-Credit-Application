@isTest
private class CreditApplicationPdfControllerTest
{
    @testSetup static void init()
    {
        insert new Years_Requiring_Previous_Information__c(
            Name = 'Standard Settings',
            Housing_Information__c = '0,1,2,3,4',
            Employer_Information__c = '0,1,2,3,4'
        );
        
        Schema.Contact buyer =  new Schema.Contact(
            FirstName = 'Test Buyer',
            LastName = 'Test Buyer',
            MiddleName = 'Test Buyer',
            HomePhone = '12345678',
            MobilePhone = '12345678',
            Email = 'test@test.test',
            Driver_License_Number__c = '12345678'
        );
        
        Schema.Contact cobuyer = new Schema.Contact(
            FirstName = 'Test Co-Buyer',
            LastName = 'Test Co-Buyer',
            MiddleName = 'Test Co-Buyer'
        );
        
        insert new List<Schema.Contact>{buyer, cobuyer};
        
        Credit_Application__c creditApp =  new Credit_Application__c(
            Buyer__c = buyer.Id,
            Co_Buyer__c = cobuyer.Id,
            Repeat_Customer__c = '1 Prior Purchase',
            Co_App_Repeat_Customer__c = '1 Prior Purchase'
        );
        
        insert creditApp;
        
        insert new List<Residence__c>{
            new Residence__c(
                Address_Duration_Years__c = '1',
                Is_Current_Residence__c = true,
                Is_Primary_Buyer__c = true,
                Credit_Application__c = creditApp.Id
            ),
            new Residence__c(
                Address_Duration_Years__c = '1',
                Is_Current_Residence__c = true,
                Is_Primary_Buyer__c = false,
                Credit_Application__c = creditApp.Id
            )
        };
        
        insert new List<Employment__c>{
            new Employment__c(
                Employer_Duration_Years__c = '1',
                Other_Income__c = 100,
                Is_Current_Employment__c = true,
                Is_Primary_Buyer__c = true,
                Credit_Application__c = creditApp.Id
            ),
            new Employment__c(
                Employer_Duration_Years__c = '1',
                Other_Income__c = 100,
                Is_Current_Employment__c = true,
                Is_Primary_Buyer__c = false,
                Credit_Application__c = creditApp.Id
            )
        };
    }
    
    @isTest static void testHideNonRequiredInfo() {
        Credit_Application__c creditApplication = [
            SELECT  Buyer__r.FirstName, Buyer__r.LastName, Buyer__r.MiddleName, Buyer__r.HomePhone,
                Buyer__r.MobilePhone, Buyer__r.Email, Buyer__r.SocialSecurityNumber__c, Buyer__r.Birthdate,
                Buyer__r.Driver_License_Number__c, Buyer__r.Driver_License_State__c, Buyer__r.Suffix__c, Buyer__r.SalesPortalId__c,
                Buyer__r.Is_Military__c, Buyer__r.Military_Status__c, Buyer__r.Driver_License_Expiration_Date__c,
                
                Co_Buyer__r.FirstName, Co_Buyer__r.LastName, Co_Buyer__r.MiddleName, Co_Buyer__r.HomePhone,
                Co_Buyer__r.MobilePhone, Co_Buyer__r.Email, Co_Buyer__r.SocialSecurityNumber__c, Co_Buyer__r.Birthdate,
                Co_Buyer__r.Driver_License_Number__c, Co_Buyer__r.Driver_License_State__c, Co_Buyer__r.Suffix__c,
                Co_Buyer__r.Is_Military__c, Co_Buyer__r.Military_Status__c, Co_Buyer__r.Driver_License_Expiration_Date__c,
                
                Car_Repossessed__c, Currently_in_bankruptcy__c, Ever_filed_Bankruptcy_or_Chapter_13__c, Repeat_Customer__c,
                Repeat_Reason__c, Co_App_Repeat_Customer__c, Co_App_Repeat_Reason__c,
                Previous_Account_Number__c, Co_App_Previous_Account_Number__c, Co_App_car_repossessed__c, Co_App_currently_in_bankruptcy__c,
                Co_App_gone_through_bankruptcy__c, Ready_To_Submit__c,  Credit_Application_Status__c, Opportunity__c,
                Credit_Application_Comment__c, Last_Comment_Left_By__c, Sales_Portal_ID__c, Owner.Name, Owner.Email,
                Buyer__c, Co_Buyer__c, Co_Buyer__r.SalesPortalId__c,
                Client_Ancestor__c, Store_Location__c, Store_Location__r.Name, Store_Location__r.SalesPortalId__c,
                Co_App_Available_Down_Payment__c, Available_Down_Payment__c
            FROM Credit_Application__c
        ];

        PageReference pdfPage = Page.CreditApplicationPdf;
        pdfPage.getParameters().put('id', creditApplication.Id);

        ApexPages.StandardController sc = new ApexPages.StandardController(creditApplication);
        
        Test.startTest();
        CreditApplicationPdfController controller = new CreditApplicationPdfController(sc);
        Test.stopTest();

        System.assertEquals(true, controller.isPreviousAddressDisplayed);
        System.assertEquals(true, controller.isPreviousEmployerInfoDisplayed);
        System.assertEquals(true, controller.isOtherIncomeDisplayed);
        System.assertEquals(true, controller.isRepeatCustomerInfoDisplayed);
        System.assertEquals(true, controller.isCoAppPreviousAddressDisplayed);
        System.assertEquals(true, controller.isCoAppPreviousEmployerInfoDisplayed);
        System.assertEquals(true, controller.isCoAppOtherIncomeDisplayed);
        System.assertEquals(true, controller.isCoAppRepeatCustomerInfoDisplayed);
    }
}