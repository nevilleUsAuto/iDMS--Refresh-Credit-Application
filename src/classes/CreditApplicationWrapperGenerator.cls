public class CreditApplicationWrapperGenerator
{
    public static String getCreditApplicationJSON(Credit_Application__c creditApplication, Attachment file, String fileType)
    {
        CreditApplicationWrapper wrappedCreditApplication = new CreditApplicationWrapper();
        CreditApplicationPdfController.RelatedListWrapper relatedRecordsWrapper = new CreditApplicationPdfController.RelatedListWrapper(creditApplication.Employments__r, creditApplication.Residences__r);
        
        if (creditApplication.Co_Buyer__c != null)
        {
            wrappedCreditApplication.CoBuyer = new Application();
            wrappedCreditApplication.CoBuyer.Customer = new Customer();
            wrappedCreditApplication.CoBuyer.Address = new Address();
            wrappedCreditApplication.CoBuyer.Address.Duration = new Duration();
            wrappedCreditApplication.CoBuyer.Employment = new Employment();
            wrappedCreditApplication.CoBuyer.Employment.Duration = new Duration();
            wrappedCreditApplication.CoBuyer.GeneralInfo = new GeneralInfo();
            wrappedCreditApplication.CoBuyer.PayingCapacity = new PayingCapacity();
            wrappedCreditApplication.CoBuyer.ActiveOrFormerMilitary = creditApplication.Co_Buyer__r.Is_Military__c;
            wrappedCreditApplication.CoBuyer.MilitaryChoise = SalesPortalUtils.militaryNameToSalesPortalId.get(creditApplication.Co_Buyer__r.Military_Status__c);
            
            wrappedCreditApplication.CoBuyer.Customer.BirthDate = getSalesPortalDateRepresentation(creditApplication.Co_Buyer__r.Birthdate);
            wrappedCreditApplication.CoBuyer.Customer.DriverLicenseNumber = creditApplication.Co_Buyer__r.Driver_License_Number__c;
            wrappedCreditApplication.CoBuyer.Customer.DriverLicenseStateID = SalesPortalUtils.salesPortalStateValueToId.get(creditApplication.Co_Buyer__r.Driver_License_State__c);
            wrappedCreditApplication.CoBuyer.Customer.EmailAddress = creditApplication.Co_Buyer__r.Email;
            wrappedCreditApplication.CoBuyer.Customer.FirstName = creditApplication.Co_Buyer__r.FirstName;
            wrappedCreditApplication.CoBuyer.Customer.HomePhone = creditApplication.Co_Buyer__r.HomePhone;
            wrappedCreditApplication.CoBuyer.Customer.Id = Integer.valueOf(creditApplication.Co_Buyer__r.SalesPortalId__c);
            wrappedCreditApplication.CoBuyer.Customer.LastName = creditApplication.Co_Buyer__r.LastName;
            wrappedCreditApplication.CoBuyer.Customer.MiddleName = creditApplication.Co_Buyer__r.MiddleName;
            wrappedCreditApplication.CoBuyer.Customer.MobilePhone = creditApplication.Co_Buyer__r.MobilePhone;
            wrappedCreditApplication.CoBuyer.Customer.SSN = creditApplication.Co_Buyer__r.SocialSecurityNumber__c;
            wrappedCreditApplication.CoBuyer.Customer.SuffixTypeID = SalesPortalUtils.salesPortalSuffixValueToId.get(creditApplication.Co_Buyer__r.Suffix__c);
            wrappedCreditApplication.CoBuyer.Customer.DriverLicenseExpirationDate = getSalesPortalDateRepresentation(creditApplication.Co_Buyer__r.Driver_License_Expiration_Date__c);
            
            wrappedCreditApplication.CoBuyer.Address.AddressLine = relatedRecordsWrapper.coBuyerCurrentResidence.Home_Address_2__c;
            wrappedCreditApplication.CoBuyer.Address.City = relatedRecordsWrapper.coBuyerCurrentResidence.Address_City__c;
            wrappedCreditApplication.CoBuyer.Address.HouseNumber = relatedRecordsWrapper.coBuyerCurrentResidence.House_Number__c;
            wrappedCreditApplication.CoBuyer.Address.PostalCode = relatedRecordsWrapper.coBuyerCurrentResidence.Address_Zip__c;
            wrappedCreditApplication.CoBuyer.Address.Duration.MonthId = SalesPortalUtils.salesPortalDurationMonthsValueToId.get(relatedRecordsWrapper.coBuyerCurrentResidence.Address_Duration_Months__c);
            wrappedCreditApplication.CoBuyer.Address.Duration.YearId = SalesPortalUtils.salesPortalDurationYearsValueToId.get(relatedRecordsWrapper.coBuyerCurrentResidence.Address_Duration_Years__c);
            wrappedCreditApplication.CoBuyer.Address.StateID = SalesPortalUtils.salesPortalStateValueToId.get(relatedRecordsWrapper.coBuyerCurrentResidence.Address_State__c);
            wrappedCreditApplication.CoBuyer.Address.StreetName = relatedRecordsWrapper.coBuyerCurrentResidence.Address_Street__c;
            wrappedCreditApplication.CoBuyer.Address.StreetTypeID = SalesPortalUtils.salesPortalStreetTypeValueToId.get(relatedRecordsWrapper.coBuyerCurrentResidence.Address_Street_Type__c);
            
            wrappedCreditApplication.CoBuyer.Employment.EmploymentPosition = relatedRecordsWrapper.coBuyerCurrentEmployment.Occupation_Or_Rank__c;
            wrappedCreditApplication.CoBuyer.Employment.FullAddress = relatedRecordsWrapper.coBuyerCurrentEmployment.Employer_City__c;
            wrappedCreditApplication.CoBuyer.Employment.Name = relatedRecordsWrapper.coBuyerCurrentEmployment.Employer_Name__c;
            wrappedCreditApplication.CoBuyer.Employment.Duration.MonthId = SalesPortalUtils.salesPortalDurationMonthsValueToId.get(relatedRecordsWrapper.coBuyerCurrentEmployment.Employer_Duration_Months__c);
            wrappedCreditApplication.CoBuyer.Employment.Duration.YearId = SalesPortalUtils.salesPortalDurationYearsValueToId.get(relatedRecordsWrapper.coBuyerCurrentEmployment.Employer_Duration_Years__c);
            wrappedCreditApplication.CoBuyer.Employment.WorkPhone = relatedRecordsWrapper.coBuyerCurrentEmployment.Employer_Phone__c;
            
            wrappedCreditApplication.CoBuyer.GeneralInfo.PreviousAccountNumber = creditApplication.Co_App_Previous_Account_Number__c;
            wrappedCreditApplication.CoBuyer.GeneralInfo.PriorPurchaseOptionID = SalesPortalUtils.salesPortalPriorPurchaseValueToId.get(creditApplication.Co_App_Repeat_Customer__c);
            wrappedCreditApplication.CoBuyer.GeneralInfo.RepeatReasonOptionID = SalesPortalUtils.salesPortalRepeatReasonValueToId.get(creditApplication.Co_App_Repeat_Reason__c);
            wrappedCreditApplication.CoBuyer.GeneralInfo.RepossessedVehicle = creditApplication.Co_App_car_repossessed__c;
            
            wrappedCreditApplication.CoBuyer.PayingCapacity.AvailableDownPayment = creditApplication.Co_App_Available_Down_Payment__c;
            wrappedCreditApplication.CoBuyer.PayingCapacity.CurrentBankruptcy = creditApplication.Co_App_currently_in_bankruptcy__c;
            wrappedCreditApplication.CoBuyer.PayingCapacity.EverBankruptcy = creditApplication.Co_App_gone_through_bankruptcy__c;
            wrappedCreditApplication.CoBuyer.PayingCapacity.HousingPayment = relatedRecordsWrapper.coBuyerCurrentResidence.Home_Payment__c;
            wrappedCreditApplication.CoBuyer.PayingCapacity.HousingTypeID = SalesPortalUtils.salesPortalHousingTypeValueToId.get(relatedRecordsWrapper.coBuyerCurrentResidence.Housing_Type__c);
            wrappedCreditApplication.CoBuyer.PayingCapacity.PeriodPaycheck = relatedRecordsWrapper.coBuyerCurrentEmployment.Applicant_Net_Period_Paycheck__c;
            wrappedCreditApplication.CoBuyer.PayingCapacity.OtherIncome = relatedRecordsWrapper.coBuyerCurrentEmployment.Other_Income__c;
            wrappedCreditApplication.CoBuyer.PayingCapacity.SalaryTypeID = SalesPortalUtils.salesPortalSalaryTypeValueToId.get(relatedRecordsWrapper.coBuyerCurrentEmployment.Salary_Type__c);
            
            if (SalesPortalUtils.yearsRequiringPreviousInformationForHousing.contains(relatedRecordsWrapper.coBuyerCurrentResidence.Address_Duration_Years__c))
            {
                wrappedCreditApplication.CoBuyer.Address.PrevDuration = new Duration();
                wrappedCreditApplication.CoBuyer.Address.PrevDuration.YearId = SalesPortalUtils.salesPortalDurationMonthsValueToId.get(relatedRecordsWrapper.coBuyerPreviousResidence.Address_Duration_Years__c);
                wrappedCreditApplication.CoBuyer.Address.PrevDuration.MonthId = SalesPortalUtils.salesPortalDurationYearsValueToId.get(relatedRecordsWrapper.coBuyerPreviousResidence.Address_Duration_Months__c);
                wrappedCreditApplication.CoBuyer.Address.PrevAddressLine = relatedRecordsWrapper.coBuyerPreviousResidence.Address_Street__c + ' '
                    + relatedRecordsWrapper.coBuyerPreviousResidence.Address_City__c + ' '  + relatedRecordsWrapper.coBuyerPreviousResidence.Address_State__c;
                wrappedCreditApplication.CoBuyer.Address.PrevCity = relatedRecordsWrapper.coBuyerPreviousResidence.Address_City__c;
                wrappedCreditApplication.CoBuyer.Address.PrevPostalCode = relatedRecordsWrapper.coBuyerPreviousResidence.Address_Zip__c;
                wrappedCreditApplication.CoBuyer.Address.PrevStateID = SalesPortalUtils.salesPortalStateValueToId.get(relatedRecordsWrapper.coBuyerPreviousResidence.Address_State__c);
            }
            
            if (SalesPortalUtils.yearsRequiringPreviousInformationForEmployer.contains(relatedRecordsWrapper.coBuyerCurrentEmployment.Employer_Duration_Years__c))
            {
                wrappedCreditApplication.CoBuyer.Employment.PrevDuration = new Duration();
                wrappedCreditApplication.CoBuyer.Employment.PrevDuration.MonthId = SalesPortalUtils.salesPortalDurationMonthsValueToId.get(relatedRecordsWrapper.coBuyerPreviousEmployment.Employer_Duration_Months__c);
                wrappedCreditApplication.CoBuyer.Employment.PrevDuration.YearId = SalesPortalUtils.salesPortalDurationYearsValueToId.get(relatedRecordsWrapper.coBuyerPreviousEmployment.Employer_Duration_Years__c);
                wrappedCreditApplication.CoBuyer.Employment.PrevName = relatedRecordsWrapper.coBuyerPreviousEmployment.Employer_Name__c;
            }
        }
        
        wrappedCreditApplication.Primary = new Application();
        
        wrappedCreditApplication.UploadedAppFileData = new ApplicationFileData();
        wrappedCreditApplication.Primary.Address = new Address();
        wrappedCreditApplication.Primary.Address.Duration = new Duration();
        wrappedCreditApplication.Primary.Employment = new Employment();
        wrappedCreditApplication.Primary.Employment.Duration = new Duration();
        wrappedCreditApplication.Primary.Customer = new Customer();
        wrappedCreditApplication.Primary.GeneralInfo = new GeneralInfo();
        wrappedCreditApplication.Primary.PayingCapacity = new PayingCapacity();
        wrappedCreditApplication.Primary.ActiveOrFormerMilitary = creditApplication.Buyer__r.Is_Military__c;
        wrappedCreditApplication.Primary.MilitaryChoise = SalesPortalUtils.militaryNameToSalesPortalId.get(creditApplication.Buyer__r.Military_Status__c);
        
        wrappedCreditApplication.Primary.Customer.BirthDate = getSalesPortalDateRepresentation(creditApplication.Buyer__r.Birthdate);
        wrappedCreditApplication.Primary.Customer.DriverLicenseNumber = creditApplication.Buyer__r.Driver_License_Number__c;
        wrappedCreditApplication.Primary.Customer.DriverLicenseStateID = SalesPortalUtils.salesPortalStateValueToId.get(creditApplication.Buyer__r.Driver_License_State__c);
        wrappedCreditApplication.Primary.Customer.EmailAddress = creditApplication.Buyer__r.Email;
        wrappedCreditApplication.Primary.Customer.FirstName = creditApplication.Buyer__r.FirstName;
        wrappedCreditApplication.Primary.Customer.HomePhone = creditApplication.Buyer__r.HomePhone;
        wrappedCreditApplication.Primary.Customer.Id = Integer.valueOf(creditApplication.Buyer__r.SalesPortalId__c);
        wrappedCreditApplication.Primary.Customer.LastName = creditApplication.Buyer__r.LastName;
        wrappedCreditApplication.Primary.Customer.MiddleName = creditApplication.Buyer__r.MiddleName;
        wrappedCreditApplication.Primary.Customer.MobileConsent = null;
        wrappedCreditApplication.Primary.Customer.MobilePhone = creditApplication.Buyer__r.MobilePhone;
        wrappedCreditApplication.Primary.Customer.SSN = creditApplication.Buyer__r.SocialSecurityNumber__c;
        wrappedCreditApplication.Primary.Customer.SuffixTypeID = SalesPortalUtils.salesPortalSuffixValueToId.get(creditApplication.Buyer__r.Suffix__c);
        wrappedCreditApplication.Primary.Customer.DriverLicenseExpirationDate = getSalesPortalDateRepresentation(creditApplication.Buyer__r.Driver_License_Expiration_Date__c);
        
        wrappedCreditApplication.Primary.Address.AddressLine = relatedRecordsWrapper.buyerCurrentResidence.Home_Address_2__c;
        wrappedCreditApplication.Primary.Address.City = relatedRecordsWrapper.buyerCurrentResidence.Address_City__c;
        wrappedCreditApplication.Primary.Address.HouseNumber = relatedRecordsWrapper.buyerCurrentResidence.House_Number__c;
        wrappedCreditApplication.Primary.Address.PostalCode = relatedRecordsWrapper.buyerCurrentResidence.Address_Zip__c;
        wrappedCreditApplication.Primary.Address.Duration.MonthId = SalesPortalUtils.salesPortalDurationMonthsValueToId.get(relatedRecordsWrapper.buyerCurrentResidence.Address_Duration_Months__c);
        wrappedCreditApplication.Primary.Address.Duration.YearId = SalesPortalUtils.salesPortalDurationYearsValueToId.get(relatedRecordsWrapper.buyerCurrentResidence.Address_Duration_Years__c);
        wrappedCreditApplication.Primary.Address.StateId = SalesPortalUtils.salesPortalStateValueToId.get(relatedRecordsWrapper.buyerCurrentResidence.Address_State__c);
        wrappedCreditApplication.Primary.Address.StreetName = relatedRecordsWrapper.buyerCurrentResidence.Address_Street__c;
        wrappedCreditApplication.Primary.Address.StreetTypeId = SalesPortalUtils.salesPortalStreetTypeValueToId.get(relatedRecordsWrapper.buyerCurrentResidence.Address_Street_Type__c);
        
        wrappedCreditApplication.Primary.Employment.EmploymentPosition = relatedRecordsWrapper.buyerCurrentEmployment.Occupation_Or_Rank__c;
        wrappedCreditApplication.Primary.Employment.FullAddress = relatedRecordsWrapper.buyerCurrentEmployment.Employer_Street__c ;
        wrappedCreditApplication.Primary.Employment.Name = relatedRecordsWrapper.buyerCurrentEmployment.Employer_Name__c;
        wrappedCreditApplication.Primary.Employment.Duration.MonthId = SalesPortalUtils.salesPortalDurationMonthsValueToId.get(relatedRecordsWrapper.buyerCurrentEmployment.Employer_Duration_Months__c);
        wrappedCreditApplication.Primary.Employment.Duration.YearId = SalesPortalUtils.salesPortalDurationYearsValueToId.get(relatedRecordsWrapper.buyerCurrentEmployment.Employer_Duration_Years__c);
        wrappedCreditApplication.Primary.Employment.WorkPhone = relatedRecordsWrapper.buyerCurrentEmployment.Employer_Phone__c;
        
        wrappedCreditApplication.Primary.GeneralInfo.AssistingSalesRep = null;
        wrappedCreditApplication.Primary.GeneralInfo.PreviousAccountNumber = creditApplication.Previous_Account_Number__c;
        wrappedCreditApplication.Primary.GeneralInfo.PriorPurchaseOptionID = SalesPortalUtils.salesPortalPriorPurchaseValueToId.get(creditApplication.Repeat_Customer__c);
        wrappedCreditApplication.Primary.GeneralInfo.RepeatReasonOptionID = SalesPortalUtils.salesPortalRepeatReasonValueToId.get(creditApplication.Repeat_Reason__c);
        wrappedCreditApplication.Primary.GeneralInfo.RepossessedVehicle = creditApplication.Car_Repossessed__c;
        
        wrappedCreditApplication.Primary.PayingCapacity.AvailableDownPayment = creditApplication.Available_Down_Payment__c;
        wrappedCreditApplication.Primary.PayingCapacity.CurrentBankruptcy = creditApplication.Currently_in_bankruptcy__c;
        wrappedCreditApplication.Primary.PayingCapacity.EverBankruptcy = creditApplication.Ever_filed_Bankruptcy_or_Chapter_13__c;
        wrappedCreditApplication.Primary.PayingCapacity.HousingPayment = relatedRecordsWrapper.buyerCurrentResidence.Home_Payment__c;
        wrappedCreditApplication.Primary.PayingCapacity.HousingTypeID = SalesPortalUtils.salesPortalHousingTypeValueToId.get(relatedRecordsWrapper.buyerCurrentResidence.Housing_Type__c);
        wrappedCreditApplication.Primary.PayingCapacity.PeriodPaycheck = relatedRecordsWrapper.buyerCurrentEmployment.Applicant_Net_Period_Paycheck__c;
        wrappedCreditApplication.Primary.PayingCapacity.OtherIncome = relatedRecordsWrapper.buyerCurrentEmployment.Other_Income__c;
        wrappedCreditApplication.Primary.PayingCapacity.SalaryTypeID = SalesPortalUtils.salesPortalSalaryTypeValueToId.get(relatedRecordsWrapper.buyerCurrentEmployment.Salary_Type__c);
        
        if (SalesPortalUtils.yearsRequiringPreviousInformationForHousing.contains(relatedRecordsWrapper.buyerCurrentResidence.Address_Duration_Years__c))
        {
            wrappedCreditApplication.Primary.Address.PrevDuration = new Duration();
            wrappedCreditApplication.Primary.Address.PrevDuration.MonthId = SalesPortalUtils.salesPortalDurationMonthsValueToId.get(relatedRecordsWrapper.buyerPreviousResidence.Address_Duration_Months__c);
            wrappedCreditApplication.Primary.Address.PrevDuration.YearId = SalesPortalUtils.salesPortalDurationYearsValueToId.get(relatedRecordsWrapper.buyerPreviousResidence.Address_Duration_Years__c);
            
            wrappedCreditApplication.Primary.Address.PrevAddressLine = relatedRecordsWrapper.buyerPreviousResidence.Address_Street__c + ' '
                + relatedRecordsWrapper.buyerPreviousResidence.Address_City__c + ' ' + relatedRecordsWrapper.buyerPreviousResidence.Address_State__c;
            wrappedCreditApplication.Primary.Address.PrevCity = relatedRecordsWrapper.buyerPreviousResidence.Address_City__c;
            wrappedCreditApplication.Primary.Address.PrevPostalCode = relatedRecordsWrapper.buyerPreviousResidence.Address_Zip__c;
            wrappedCreditApplication.Primary.Address.PrevStateID = SalesPortalUtils.salesPortalStateValueToId.get(relatedRecordsWrapper.buyerPreviousResidence.Address_State__c);
        }
        
        if (SalesPortalUtils.yearsRequiringPreviousInformationForEmployer.contains(relatedRecordsWrapper.buyerCurrentEmployment.Employer_Duration_Years__c))
        {
            wrappedCreditApplication.Primary.Employment.PrevDuration = new Duration();
            wrappedCreditApplication.Primary.Employment.PrevDuration.MonthId = SalesPortalUtils.salesPortalDurationMonthsValueToId.get(relatedRecordsWrapper.buyerPreviousEmployment.Employer_Duration_Months__c);
            wrappedCreditApplication.Primary.Employment.PrevDuration.YearId = SalesPortalUtils.salesPortalDurationYearsValueToId.get(relatedRecordsWrapper.buyerPreviousEmployment.Employer_Duration_Years__c);
            wrappedCreditApplication.Primary.Employment.PrevName = relatedRecordsWrapper.buyerPreviousEmployment.Employer_Name__c;
        }
        
        if (String.isNotBlank(creditApplication.Sales_Portal_ID__c))
        {
            wrappedCreditApplication.SPCreditAppID = Integer.valueOf(creditApplication.Sales_Portal_ID__c);
        }
        else
        {
            wrappedCreditApplication.SPCreditAppID = 0;
        }
        
        wrappedCreditApplication.Comment = creditApplication.Credit_Application_Comment__c;
        wrappedCreditApplication.StatusId = SalesPortalUtils.salesPortalCreditApplicationStatusValueToId.get(creditApplication.Credit_Application_Status__c);
        wrappedCreditApplication.IsActive = true;
        wrappedCreditApplication.LotCode = Integer.valueOf(creditApplication.Store_Location__r.SalesPortalId__c);
        wrappedCreditApplication.ClientAncestorID = SalesPortalUtils.salesPortalClientAncestorsValueToId.get(creditApplication.Client_Ancestor__c);
        wrappedCreditApplication.ReferrerCode = creditApplication.Opportunity__r.Referrer_code__c;
        
        wrappedCreditApplication.SFCreditAppID = creditApplication.Id;
        wrappedCreditApplication.SFSalesUpID = creditApplication.Opportunity__c;
        wrappedCreditApplication.SFEmailCreatedBy = creditApplication.Owner.Email;
        wrappedCreditApplication.UploadedAppFileData.FileName = file.Name;
        wrappedCreditApplication.UploadedAppFileData.UploadUrl = System.URL.getSalesforceBaseURL().toExternalForm()
            + '/services/data/v37.0/sobjects/Attachment/' + file.Id + '/body';
        wrappedCreditApplication.UploadedAppFileData.FileType = SalesPortalUtils.salesPortalFileTypeValueToId.get(fileType);
        wrappedCreditApplication.UploadedAppFileData.UserName = creditApplication.Owner.Name;
        
        return JSON.serialize(wrappedCreditApplication);
    }
    
    private static String getSalesPortalDateRepresentation(Date datevalue)
    {
        return datevalue.month() + '/' + datevalue.day() + '/' + datevalue.year();
    }
    
    public class CreditApplicationWrapper
    {
        public Integer StatusId;
        public Integer SPCreditAppID;
        public Application CoBuyer;
        public String Comment;
        public Boolean IsActive;
        public Integer LotCode;
        public String ReferrerCode;
        public String SFCreditScoreAppKey = '1';
        public String SFCreditAppID;
        public String SFSalesUpID;
        public Application Primary;
        public String SFEmailCreatedBy;
        public ApplicationFileData UploadedAppFileData;
        public Integer ClientAncestorID;
    }
    
    public class ApplicationFileData
    {
        public Integer FileGUID;
        public Integer FileType;
        public String FileName;
        public String UploadUrl;
        public String UserName;
    }
    
    public class Application
    {
        public Address Address;
        public Customer Customer;
        public Employment Employment;
        public GeneralInfo GeneralInfo;
        public PayingCapacity PayingCapacity;
        public Boolean ActiveOrFormerMilitary;
        public Integer MilitaryChoise;
    }
    
    public class Address
    {
        public String AddressLine;
        public String City;
        public Duration Duration;
        public String HouseNumber;
        public String PostalCode;
        public String PrevAddressLine;
        public String PrevCity;
        public Duration PrevDuration;
        public String PrevPostalCode;
        public Integer PrevStateID;
        public Integer StateID;
        public Integer StreetTypeID;
        public String StreetName;
    }
    
    public class Employment
    {
        public Duration Duration;
        public String EmploymentPosition;
        public String FullAddress;
        public String Name;
        public Duration PrevDuration;
        public String WorkPhone;
        public String PrevName;
    }
    
    public class Customer
    {
        public String BirthDate;
        public String DriverLicenseNumber;
        public Integer DriverLicenseStateID;
        public String EmailAddress;
        public String FirstName;
        public String HomePhone;
        public Integer Id;
        public String LastName;
        public String MiddleName;
        public Boolean MobileConsent;
        public String MobilePhone;
        public String SSN;
        public Integer SuffixTypeID;
        public String DriverLicenseExpirationDate;
    }
    
    public class GeneralInfo
    {
        public String AssistingSalesRep;
        public String PreviousAccountNumber;
        public Integer PriorPurchaseOptionID;
        public Integer RepeatReasonOptionID;
        public Boolean RepossessedVehicle;
    }
    
    public class PayingCapacity
    {
        public Decimal AvailableDownPayment;
        public Boolean CurrentBankruptcy;
        public Boolean EverBankruptcy;
        public Decimal HousingPayment;
        public Integer HousingTypeID;
        public Decimal PeriodPaycheck;
        public Decimal OtherIncome;
        public Integer SalaryTypeID;
    }
    
    public class Duration
    {
        public Integer MonthId;
        public Integer YearId;
    }
}