public with sharing class SalesPortalAPIRequests
{
	public class AuthentificationRequestBody
	{
		public String User;
		public String Password;
	}

	public class PrintLetterRequestBody
	{
		public Boolean IsJointScore;
		public String SFEmailCreatedBy;
		public Integer SPCreditAppID;
	}

	public class GetVehiclesListRequestBody
	{
		public Decimal CashUpFront;
		public Double InterestRate;
		public Boolean IsJoint;
		public Integer LotID;
		public Decimal PickPayment;
		public String SFEmailCreatedBy;
		public Integer SPCreditAppID;
		public Decimal TradeACV;
		public Decimal TradePayoff;
		public Integer PageNumber;
		public Integer PageSize;
		public String Search;
		public String SortBy;
		public String SortOrder;
		public Integer StateId;
	}

	public class GetVehicleDetailsRequestBody
	{
		public Decimal CashUpFront;
		public Double InterestRate;
		public Boolean IsJoint;
		public Integer LotID;
		public Decimal PickPayment;
		public Decimal TradeACV;
		public Integer SPCreditAppID;
		public Integer VehicleId;
		public Integer WarrantyID;
		public String SFEmailCreatedBy;
		public Integer StateId;
	}

	public class SelectVehicleRequestBody
	{
		public Decimal CashUpFront;
		public Double InterestRate;
		public Boolean IsJoint;
		public Integer LotID;
		public Decimal PickPayment;
		public Decimal TradeACV;
		public Integer SPCreditAppID;
		public Decimal TradePayoff;
		public Integer VehicleId;
		public Integer WarrantyID;
		public String SFEmailCreatedBy;
		public Integer StateId;
	}

	public class CreditApplicationSubmitRequestWrapper
	{
		public String SFEmailCreatedBy;
		public Integer SPCreditAppID;
	}

	public class ManagersSubmitRequestWrapper
	{
		public String SFEmailCreatedBy;
		public Integer SPCreditAppID;
		public Decimal TradeACV;
		public Decimal TradePayoff;
		public Decimal WarrantyID;
	}

	public class SaveUserRequestBody
	{
		public String Password;
		public String SFEmail;
		public String SPUser;
		public String Salt;
		public String UserId;
	}

	public class ActiveApplicationSearchRequestBody
	{
		public Set<String> SsnList;
	}

	public class SaveShortCreditScoreApplicationRequestBody
	{
		public String AddressLine;
		public String City;
		public Integer ClientAncestorId;
		public Boolean CurrentlyInBankruptcy;
		public String Email;
		public String FirstName;
		public String HomePhone;
		public String HouseNumber;
		public Integer HouseType;
		public Integer JobMonthsId;
		public Integer JobYearsId;
		public String LastName;
		public String MiddleName;
		public String MobilePhone;
		public Decimal OtherIncome;
		public Integer PaymentType;
		public Decimal PeriodPaycheck;
		public String ReferrerCode;
		public Integer ResidenceMonthsId;
		public Integer ResidenceYearsId;
		public String Ssn;
		public Integer State;
		public String StreetName;
		public Integer StreetType;
		public String WorkPhone;
		public String Zip;
		public Boolean ActiveOrFormerMilitary;
		public Integer MilitaryChoise;
	}

	public class SendApprovalEmailRequestBody
	{
		public String CustomerEmail;
		public String FirstName;
		public Decimal MaxFinanceAmount;
	}

	public class SaveOrUpdateStoreLocationRequestBody
	{
		public Integer Id;
		public String LotCode;
		public String LotEmail;
		public String LotName;
		public String OrgUnitName;
	}
	
	public class AccountRegisterRequestBody
	{
		public Integer DealId;
	}

	public class CheckDuplicatedCustomerRequestBody
	{
		public String FirstName;
		public String LastName;
		public String SSN;
		public String DateOfBirth;
	}
}