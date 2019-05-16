public class SalesPortalAPIResponses
{
	/*
	 * Common properties for any response coming from Sales Portal.
	 */
	
	public virtual class SalesPortalResponseBody
	{
		public Boolean isError;
		public String message;
		public Integer statusCode;
	}

	/*
	 * Authentification response. It contains access token that should be used in any callout to Sales Portal.
	 */
	
	public class AuthentificationResponseBody extends SalesPortalResponseBody
	{
		public String result;
	}

	/*
	 * Response for credit application save in Sales Portal. Salesforce credit application is treated as
	 * "credit Scores" application in Sales Portal. In addition to insert of credit Scores application Sales Portal
	 * creates credit applications for buyer and cobuyer and inserts credit application file.
	 * Description of these records is also stored in response.
	 */
	
	public class SaveCreditScoreApplicationResponseBody extends SalesPortalResponseBody
	{
		public CreditScoreApplicationData result;
	}
	
	public class CreditScoreApplicationData
	{
		public CreditApplicationData coBuyerApp;
		public CreditApplicationData primaryBuyerApp;
		public CreditApplicationFileData uploadedFileJSON;
		public Integer CreditScoreAppStatusID;
		public Integer SPCreditAppID;
	}
	
	public class CreditApplicationData
	{
		public Integer appID;
		public Integer customerID;
		public Boolean isSubmitted;
	}
	
	public class CreditApplicationFileData
	{
		public Integer byteSize;
		public Integer fileGUID;
		public Boolean isErrorUploading;
		public Boolean isInFileSystem;
	}

	/*
	 * Response for credit application status refresh. In addition to status it also gets latest comment,
	 * "isActive" state of credit Scores application, client ancestor and last modification date.
	 */
	
	public class GetCreditApplicationStatusesResponseBody extends SalesPortalResponseBody
	{
		public List<CreditApplicationStatus> result;
	}
	
	public class CreditApplicationStatus
	{
		public String clientAncestor;
		public Boolean isActive;
		public String lastComment;
		public Integer SPCreditAppID;
		public Integer statusID;
		public String spUser;
	}

	/*
	 * Response with adjusted Scores for short application(Conditionally Scoresd and Awaiting Stips applications).
	 */
	
	public class GetOnlineApplicationAdjustedScoresResponseBody extends SalesPortalResponseBody
	{
		public List<OnlineApplicationAdjustedScores> result;
	}
	
	public class OnlineApplicationAdjustedScores
	{
		@AuraEnabled public Integer customerID {get; set;}
		@AuraEnabled public Integer SPCreditAppID {get; set;}
		@AuraEnabled public AdjustedScores scoreData {get; set;}
		@AuraEnabled public Integer statusID {get; set;}
	}

	/*
	 * Response with adjusted Scores for regular applications(Initial Paycall and Letter Printed applications).
	 */
	
	public class GetAdjustedCreditScoresResponseBody extends SalesPortalResponseBody
	{
		public List<RegularApplicationAdjustedScores> result;
	}
	
	public class RegularApplicationAdjustedScores
	{
		@AuraEnabled public Boolean isIncomplete;
		@AuraEnabled public Boolean isScored;
		@AuraEnabled public AdjustedScores coBuyerScore {get; set;}
		@AuraEnabled public AdjustedScores jointScore {get; set;}
		@AuraEnabled public AdjustedScores primaryScore {get; set;}
		@AuraEnabled public Integer SPCreditAppID;
	}
	
	public class AdjustedScores
	{
		@AuraEnabled public Integer beaconScoreValue {get; set;}
		@AuraEnabled public String ficoPercent
		{
			get
			{
				if (String.isNotBlank(ficoPercent))
				{
					ficoPercent = ficoPercent.remove('%');
				}
				
				return ficoPercent;
			}
			set;
		}
		@AuraEnabled public Boolean isAdjusted {get; set;}
		@AuraEnabled public Boolean isLetterPrinted {get; set;}
		@AuraEnabled public Decimal maxMonthlyPayment {get; set;}
		@AuraEnabled public Decimal maxPurchasePrice {get; set;}
		@AuraEnabled public Decimal maxFinance {get; set;}
		@AuraEnabled public Decimal minDownPaymentPercent {get; set;}
		@AuraEnabled public Decimal minimumDownPaymentOver {get; set;}
		@AuraEnabled public Decimal minimumDownPaymentUnder {get; set;}
		@AuraEnabled public String customerCode {get; set;}
		@AuraEnabled public Integer scoreID {get; set;}
		@AuraEnabled public Integer scoreValue {get; set;}
	}

	/*
	 * Response for setting credit application status as "Letter Printed". Once letter is printed request is sent
	 * to Sales Portal to mark that letter for credit Scores application is printed. If operation went successfull positive
	 * result will be returned.
	 */
	
	public class PrintLetterResponseBody extends SalesPortalResponseBody
	{
		public Boolean result;
	}

	/*
	 * Response with calculator data for inventory grid component.
	 */
	
	public class GetCalculatorDataResponseBody extends SalesPortalResponseBody
	{
		public CalculatorData result;
	}
	
	public class CalculatorData
	{
		@AuraEnabled public Decimal cashUpFront {get; set;}
		@AuraEnabled public Double interestRate {get; set;}
		@AuraEnabled public Boolean isJoint {get; set;}
		@AuraEnabled public Integer lotId {get; set;}
		@AuraEnabled public Decimal pickPayment {get; set;}
		@AuraEnabled public Decimal tradeACV {get; set;}
		@AuraEnabled public Decimal tradePayoff {get; set;}
		@AuraEnabled public Integer SPCreditAppID {get; set;}
	}

	/*
	 * Response with list of vehicles for inventory grid component.
	 */
	
	public class GetVehiclesListResponseBody extends SalesPortalResponseBody
	{
		public VehiclesList result;
	}
	
	public class VehiclesList
	{
		@AuraEnabled List<Vehicle> items {get; set;}
		@AuraEnabled Integer totalCount {get; set;}
	}
	
	public class Vehicle
	{
		@AuraEnabled public String lotName {get; set;}
		@AuraEnabled public Integer lotID {get; set;}
		@AuraEnabled public String carMake {get; set;}
		@AuraEnabled public String carModel {get; set;}
		@AuraEnabled public String carYear {get; set;}
		@AuraEnabled public Decimal sellingPrice {get; set;}
		@AuraEnabled public Integer minDownPayment {get; set;}
		@AuraEnabled public String stockNo {get; set;}
		@AuraEnabled public Decimal mileage {get; set;}
		@AuraEnabled public Integer maxTermNoVSC {get; set;}
		@AuraEnabled public Integer maxTermVSC {get; set;}
		@AuraEnabled public Double warranty24 {get; set;}
		@AuraEnabled public Double warranty36 {get; set;}
		@AuraEnabled public Decimal vscNo {get; set;}
		@AuraEnabled public Decimal vsc2 {get; set;}
		@AuraEnabled public Decimal vsc3 {get; set;}
		@AuraEnabled public Integer id {get; set;}
	}

	/*
	 * Response with detail vehicle description for inventory grid vehicle info component.
	 */
	
	public class GetVehicleDetailsResponseBody extends SalesPortalResponseBody
	{
		public VehicleDetails result {get; set;}
	}
	
	public class VehicleDetails
	{
		@AuraEnabled public Integer id {get; set;}
		@AuraEnabled public String stockNo {get; set;}
		@AuraEnabled public String carYear {get; set;}
		@AuraEnabled public String carMake {get; set;}
		@AuraEnabled public String carModel {get; set;}
		@AuraEnabled public Decimal mileage {get; set;}
		@AuraEnabled public Decimal sellingPrice {get; set;}
		@AuraEnabled public String carColor {get; set;}
		@AuraEnabled public String engineCycles {get; set;}
		@AuraEnabled public String fuelType {get; set;}
		@AuraEnabled public String transmission {get; set;}
		@AuraEnabled public String vin {get; set;}
		@AuraEnabled public Integer lotID {get; set;}
		@AuraEnabled public String carType {get; set;}
		@AuraEnabled public Integer termID {get; set;}
		@AuraEnabled public Integer maxTerm {get; set;}
		@AuraEnabled public String lotName {get; set;}
		@AuraEnabled public Decimal monthlyPayment {get; set;}
		@AuraEnabled public Decimal payment {get; set;}
		@AuraEnabled public Decimal downPayment {get; set;}
		@AuraEnabled public Integer pickPayment {get; set;}
		@AuraEnabled public Integer warrantyID {get; set;}
		@AuraEnabled public Decimal warrantyPrice {get; set;}
		@AuraEnabled public Decimal tradeACV {get; set;}
		@AuraEnabled public Decimal tradePayoff
		{
			get
			{
				if (tradePayoff == null)
				{
					return 0;
				}
				
				return tradePayoff;
			}
			set;
		}
		@AuraEnabled public Double interestRate {get; set;}
		@AuraEnabled public List<VehicleVSCItem> vscItems {get; set;}
	}
	
	public class VehicleVSCItem
	{
		@AuraEnabled public Integer id {get; set;}
		@AuraEnabled public String name {get; set;}
		@AuraEnabled public Decimal payment {get; set;}
		@AuraEnabled public Integer term {get; set;}
		@AuraEnabled public Integer warrantyPrice {get; set;}
	}

	/*
	 * Response is returned when vehicle is selected.
	 */
	
	public class SelectVehicleResponseBody extends SalesPortalResponseBody
	{
		public VehicleSelectionResult result;
	}
	
	public class VehicleSelectionResult
	{
		public Integer CreditScoreAppStatusID;
		public Integer dealId;
		public Boolean isSubmitted;
		public Integer SPCreditAppID;
	}

	/*
	 * Response contains deal details. They include adjusted Scores, vehicle and deal details.
	 */
	
	public class GetDealDetailsResponseBody extends SalesPortalResponseBody
	{
		public List<DealDetails> result {get; set;}
	}
	
	public class DealDetails
	{
		@AuraEnabled public Integer dealId {get; set;}
		@AuraEnabled public Decimal maxMonthly {get; set;}
		@AuraEnabled public Decimal maxPrice {get; set;}
		@AuraEnabled public Double percentBelow {get; set;}
		@AuraEnabled public Double percentUnder {get; set;}
		@AuraEnabled public VehicleDetails vehicleDetails {get; set;}
	}

	/*
	 * Some operations such as final submit, remove of vehicle or revert to incomplete have same response structure.
	 * This structure is called SubmitResponseBody.
	 */
	
	public class SubmitResponseBody extends SalesPortalResponseBody
	{
		public SubmitResult Result;
	}
	
	public class SubmitResult
	{
		public Integer statusID;
		public Integer SPCreditAppID;
	}

	/*
	 * Response with data for user created in Sales Portal database.
	 */
	
	public class SaveUserResponseBody extends SalesPortalResponseBody
	{
		public List<UserData> result;
	}
	
	public class UserData
	{
		public String SFEmail;
		public Integer userId;
	}

	/*
	 * Response with the result of search of active applications in Sales Portal database.
	 */
	
	public class ActiveApplicationSearchResponseBody extends SalesPortalResponseBody
	{
		public List<ActiveApplicationData> result;
	}
	
	public class ActiveApplicationData
	{
		public Boolean isPrimarySsn;
		public Integer SPCreditAppID;
		public String ssn;
	}

	/*
	 * Response returned when phone application is save in Sales Portal. Phone application is a regular application
	 * created by ISC department.
	 */
	
	public class SaveShortCreditScoreApplicationResponseBody extends SalesPortalResponseBody
	{
		public ShortCreditApplicationData result;
	}
	
	public class ShortCreditApplicationData
	{
		public Integer customerId;
		public Integer SPCreditAppID;
		public Integer statusID;
	}

	/*
	 * Response is returned when approval email is sent.
	 */
	
	public class SendApprovalEmailResponseBody extends SalesPortalResponseBody
	{
		public Boolean result;
	}

	/*
	 * Response is returned when store location is getting inserted or updated in Sales Portal database.
	 */
	
	public class SaveOrUpdateStoreLocationResponseBody extends SalesPortalResponseBody
	{
		public List<StoreLocationData> result;
	}
	
	public class StoreLocationData
	{
		public Integer id;
		public String lotCode;
	}
	
	public class GetDealAndVehicleDetailsResponseBody extends SalesPortalResponseBody
	{
		public List<DealAndVehicle> result {get; set;}
	}
	
	public class DealAndVehicle
	{
		public Integer Contract {get; set;}
		public String StockNo {get; set;}
		public Date Datesold {get; set;}
		public String Custcode {get; set;}
		public Integer Lot {get; set;}
		public String Customergrade {get; set;}
		public String Apr {get; set;}
		public Decimal Intrate {get; set;}
		public String CARINFO {get; set;}
		public Decimal Downpay {get; set;}
		public String PICKUP {get; set;}
		public String REBATEPO {get; set;}
		public String Single {get; set;}
		public Decimal SELLPRICE {get; set;}
		public String WARRANTY {get; set;}
		public String companycode {get; set;}
		public String BODYTYPE {get; set;}
		public Integer BUYER {get; set;}
		public String Carcolor {get; set;}
		public String Carmake {get; set;}
		public String Carmodel {get; set;}
		public String cartype {get; set;}
		public String daterec {get; set;}
		public String Enginecyls {get; set;}
		public String Fueltype {get; set;}
		public Decimal mileage {get; set;}
		public String selling1 {get; set;}
		public String Transtype {get; set;}
		public String Trim {get; set;}
		public String vin {get; set;}
	}

	/*
	 * Set of methods generating responses instead of mocks.
	 */
	
	public static HttpResponse generateAuthentificationResponse(HttpRequest request)
	{
		AuthentificationResponseBody responseBody = new AuthentificationResponseBody();
		responseBody.isError = false;
		responseBody.statusCode = 200;
		responseBody.result = 'token';
		
		HTTPResponse response = new HTTPResponse();
		response.setStatusCode(200);
		response.setStatus('Success');
		response.setBody(JSON.serialize(responseBody));
		
		return response;
	}
	
	public static HttpResponse generateSaveCreditScoreApplicationResponse(HttpRequest request)
	{
		if (request == null)
		{
			SaveCreditScoreApplicationResponseBody responseBody = new SaveCreditScoreApplicationResponseBody();
			responseBody.isError = true;
			responseBody.message = 'Error';
			
			HttpResponse response = new HttpResponse();
			response.setStatus('Error');
			response.setBody(JSON.serialize(responseBody));
			
			return response;
		}
		
		CreditApplicationFileData uploadedFileJSON = new CreditApplicationFileData();
		uploadedFileJSON.byteSize = 1;
		uploadedFileJSON.fileGUID = 1;
		uploadedFileJSON.isErrorUploading = false;
		uploadedFileJSON.isInFileSystem = true;
		
		CreditApplicationData primaryBuyerApp = new CreditApplicationData();
		primaryBuyerApp.appID = 2;
		primaryBuyerApp.customerID = 145;
		primaryBuyerApp.isSubmitted = false;
		
		CreditApplicationData coBuyerApp = new CreditApplicationData();
		coBuyerApp.appID = 3;
		coBuyerApp.customerID = 431;
		coBuyerApp.isSubmitted = false;
		
		CreditScoreApplicationData CreditScoreApplicationData = new CreditScoreApplicationData();
		CreditScoreApplicationData.primaryBuyerApp = primaryBuyerApp;
		CreditScoreApplicationData.coBuyerApp = coBuyerApp;
		CreditScoreApplicationData.uploadedFileJson = uploadedFileJson;
		CreditScoreApplicationData.CreditScoreAppStatusID = 1;
		CreditScoreApplicationData.SPCreditAppID = 1;
		
		SaveCreditScoreApplicationResponseBody responseBody = new SaveCreditScoreApplicationResponseBody();
		responseBody.isError = false;
		responseBody.statusCode = 200;
		responseBody.result = CreditScoreApplicationData;
		
		HttpResponse response = new HttpResponse();
		response.setStatusCode(200);
		response.setStatus('Success');
		response.setBody(JSON.serialize(responseBody));
		
		return response;
	}
	
	public static HttpResponse generategetCreditApplicationsStatusesResponse(HttpRequest request)
	{
		if (request == null)
		{
			SaveCreditScoreApplicationResponseBody responseBody = new SaveCreditScoreApplicationResponseBody();
			responseBody.isError = true;
			responseBody.message = 'Error';
			
			HttpResponse response = new HttpResponse();
			response.setStatus('Error');
			response.setBody(JSON.serialize(responseBody));
			
			return response;
		}
		
		CreditApplicationStatus creditApplicationStatus = new CreditApplicationStatus();
		creditApplicationStatus.SPCreditAppID = 124;
		creditApplicationStatus.lastComment = 'Comment';
		creditApplicationStatus.spUser = 'Test User';
		creditApplicationStatus.statusID = 1;
		creditApplicationStatus.isActive = true;
		
		GetCreditApplicationStatusesResponseBody responseBody = new GetCreditApplicationStatusesResponseBody();
		responseBody.isError = false;
		responseBody.statusCode = 200;
		responseBody.result = new List<CreditApplicationStatus>{creditApplicationStatus};
		
		HttpResponse response = new HttpResponse();
		response.setStatusCode(200);
		response.setStatus('Success');
		response.setBody(JSON.serialize(responseBody));
		
		return response;
	}
	
	public static HttpResponse generateGetAdjustedCreditScoresResponse(HttpRequest request)
	{
		if (request == null)
		{
			SaveCreditScoreApplicationResponseBody responseBody = new SaveCreditScoreApplicationResponseBody();
			responseBody.isError = true;
			responseBody.message = 'Error';
			
			HttpResponse response = new HttpResponse();
			response.setStatus('Error');
			response.setBody(JSON.serialize(responseBody));
			
			return response;
		}
		
		AdjustedScores primaryScore = new AdjustedScores();
		primaryScore.beaconScoreValue = 0;
		primaryScore.ficoPercent = '10%';
		primaryScore.isAdjusted = true;
		primaryScore.isLetterPrinted = true;
		primaryScore.maxMonthlyPayment = 1500;
		primaryScore.maxPurchasePrice = 23000;
		primaryScore.minDownPaymentPercent = 1.5;
		primaryScore.scoreID = 124;
		primaryScore.scoreValue = 34000;
		
		RegularApplicationAdjustedScores regularApplicationScore = new RegularApplicationAdjustedScores();
		regularApplicationScore.isIncomplete = false;
		regularApplicationScore.isScored = true;
		regularApplicationScore.primaryScore = primaryScore;
		regularApplicationScore.SPCreditAppID = 124;
		
		List<RegularApplicationAdjustedScores> result = new List<RegularApplicationAdjustedScores>{regularApplicationScore};
		
		GetAdjustedCreditScoresResponseBody responseBody = new GetAdjustedCreditScoresResponseBody();
		responseBody.isError = false;
		responseBody.statusCode = 200;
		responseBody.result = result;
		
		HttpResponse response = new HttpResponse();
		response.setStatusCode(200);
		response.setStatus('Success');
		response.setBody(JSON.serialize(responseBody));
		
		return response;
	}
	
	public static HttpResponse generatePrintLetterResponse(HttpRequest request)
	{
		if (request == null)
		{
			SaveCreditScoreApplicationResponseBody responseBody = new SaveCreditScoreApplicationResponseBody();
			responseBody.isError = true;
			responseBody.message = 'Error';
			
			HttpResponse response = new HttpResponse();
			response.setStatus('Error');
			response.setBody(JSON.serialize(responseBody));
			
			return response;
		}
		
		PrintLetterResponseBody responseBody = new PrintLetterResponseBody();
		responseBody.isError = false;
		responseBody.statusCode = 200;
		responseBody.result = true;
		
		HttpResponse response = new HttpResponse();
		response.setStatusCode(200);
		response.setStatus('Success');
		response.setBody(JSON.serialize(responseBody));
		
		return response;
	}
	
	public static HttpResponse generateCalculatorDataResponse(HttpRequest request)
	{
		if (request == null)
		{
			SaveCreditScoreApplicationResponseBody responseBody = new SaveCreditScoreApplicationResponseBody();
			responseBody.isError = true;
			responseBody.message = 'Error';
			
			HttpResponse response = new HttpResponse();
			response.setStatus('Error');
			response.setBody(JSON.serialize(responseBody));
			
			return response;
		}
		
		CalculatorData calculatorData = new CalculatorData();
		calculatorData.cashUpFront = 12000.0;
		calculatorData.interestRate = 10.0;
		calculatorData.isJoint = false;
		calculatorData.lotID = 1;
		calculatorData.pickPayment = 2500.0;
		calculatorData.SPCreditAppID = 2;
		calculatorData.tradeACV = 2300.0;
		
		GetCalculatorDataResponseBody responseBody = new GetCalculatorDataResponseBody();
		responseBody.isError = false;
		responseBody.statusCode = 200;
		responseBody.result = calculatorData;
		
		HttpResponse response = new HttpResponse();
		
		response.setStatusCode(200);
		response.setStatus('Success');
		response.setBody(JSON.serialize(responseBody));
		
		return response;
	}
	
	public static HttpResponse generateGetVehiclesListResponse(HttpRequest request)
	{
		if (request == null)
		{
			SaveCreditScoreApplicationResponseBody responseBody = new SaveCreditScoreApplicationResponseBody();
			responseBody.isError = true;
			responseBody.message = 'Error';
			
			HttpResponse response = new HttpResponse();
			response.setStatus('Error');
			response.setBody(JSON.serialize(responseBody));
			
			return response;
		}
		
		Vehicle vehicle = new Vehicle();
		vehicle.lotName = 'LotName';
		vehicle.carMake = 'CarMake';
		vehicle.carModel = 'CarModel';
		vehicle.carYear = '1994';
		vehicle.sellingPrice = 4495.0;
		vehicle.minDownPayment = 2000;
		vehicle.stockNo = '2435325';
		vehicle.warranty24 = 2300.0;
		vehicle.warranty36 = 2300.0;
		vehicle.vscNo = 2300.0;
		vehicle.vsc2 = 2300.0;
		vehicle.vsc3 = 2300.0;
		vehicle.id = 12;
		
		VehiclesList vehiclesList = new VehiclesList();
		vehiclesList.items = new List<Vehicle>{vehicle};
		vehiclesList.totalCount = 1;
		
		GetVehiclesListResponseBody responseBody = new GetVehiclesListResponseBody();
		responseBody.isError = false;
		responseBody.statusCode = 200;
		responseBody.result = vehiclesList;
		
		HttpResponse response = new HttpResponse();
		response.setStatusCode(200);
		response.setStatus('Success');
		response.setBody(JSON.serialize(responseBody));
		
		return response;
	}
	
	public static HttpResponse generateGetVehicleDetailsResponse(HttpRequest request)
	{
		if (request == null)
		{
			SaveCreditScoreApplicationResponseBody responseBody = new SaveCreditScoreApplicationResponseBody();
			responseBody.isError = true;
			responseBody.message = 'Error';
			
			HttpResponse response = new HttpResponse();
			response.setStatus('Error');
			response.setBody(JSON.serialize(responseBody));
			
			return response;
		}
		
		VehicleDetails vehicleDetails = new VehicleDetails();
		vehicleDetails.id = 124;
		vehicleDetails.stockNo = 'StockNo';
		vehicleDetails.carYear = '2001';
		vehicleDetails.carMake = 'CarMake';
		vehicleDetails.carModel = 'CarModel';
		vehicleDetails.mileage = 2000.2;
		vehicleDetails.sellingPrice = 21000.0;
		vehicleDetails.carColor = 'Red';
		vehicleDetails.engineCycles = 'GH-1; JHJ';
		vehicleDetails.fuelType = 'Diesel';
		vehicleDetails.transmission = 'Transmission';
		vehicleDetails.vin = '98847472HHF883';
		vehicleDetails.lotID = 44;
		vehicleDetails.carType = 'Hatchback';
		vehicleDetails.termID = 124;
		vehicleDetails.maxTerm = 12;
		vehicleDetails.lotName = 'Gainesville';
		vehicleDetails.monthlyPayment = 2300.0;
		vehicleDetails.downPayment = 2300.0;
		vehicleDetails.pickPayment = 2300;
		vehicleDetails.warrantyID = 23;
		vehicleDetails.warrantyPrice = 1200.0;
		vehicleDetails.tradeACV = 2300.0;
		vehicleDetails.tradePayoff = 2300.0;
		vehicleDetails.interestRate = 12.0;
		
		GetVehicleDetailsResponseBody responseBody = new GetVehicleDetailsResponseBody();
		responseBody.isError = false;
		responseBody.statusCode = 200;
		responseBody.result = vehicleDetails;
		
		HttpResponse response = new HttpResponse();
		response.setStatusCode(200);
		response.setStatus('Success');
		response.setBody(JSON.serialize(responseBody));
		
		return response;
	}
	
	public static HttpResponse generateSelectVehicleResponse(HttpRequest request)
	{
		if (request == null)
		{
			SaveCreditScoreApplicationResponseBody responseBody = new SaveCreditScoreApplicationResponseBody();
			responseBody.isError = true;
			responseBody.message = 'Error';
			
			HttpResponse response = new HttpResponse();
			response.setStatus('Error');
			response.setBody(JSON.serialize(responseBody));
			
			return response;
		}
		
		VehicleSelectionResult selectionResult = new VehicleSelectionResult();
		selectionResult.creditScoreAppStatusID = 4;
		selectionResult.dealId = 11;
		selectionResult.isSubmitted = true;
		selectionResult.SPCreditAppID = 1;
		
		SelectVehicleResponseBody responseBody = new SelectVehicleResponseBody();
		responseBody.isError = false;
		responseBody.statusCode = 200;
		responseBody.result = selectionResult;
		
		HttpResponse response = new HttpResponse();
		response.setStatusCode(200);
		response.setStatus('Success');
		response.setBody(JSON.serialize(responseBody));
		
		return response;
	}
	
	public static HttpResponse generateGetDealDetailsResponse(HttpRequest request)
	{
		if (request == null)
		{
			SaveCreditScoreApplicationResponseBody responseBody = new SaveCreditScoreApplicationResponseBody();
			responseBody.isError = true;
			responseBody.message = 'Error';
			
			HttpResponse response = new HttpResponse();
			response.setStatus('Error');
			response.setBody(JSON.serialize(responseBody));
			
			return response;
		}
		
		VehicleDetails vehicleDetails = new VehicleDetails();
		vehicleDetails.id = 124;
		vehicleDetails.stockNo = 'StockNo';
		vehicleDetails.carYear = '2001';
		vehicleDetails.carMake = 'CarMake';
		vehicleDetails.carModel = 'CarModel';
		vehicleDetails.mileage = 2000.2;
		vehicleDetails.sellingPrice = 21000.0;
		vehicleDetails.carColor = 'Red';
		vehicleDetails.engineCycles = 'GH-1; JHJ';
		vehicleDetails.fuelType = 'Diesel';
		vehicleDetails.transmission = 'Transmission';
		vehicleDetails.vin = '98847472HHF883';
		vehicleDetails.lotID = 44;
		vehicleDetails.carType = 'Hatchback';
		vehicleDetails.termID = 124;
		vehicleDetails.maxTerm = 12;
		vehicleDetails.lotName = 'Gainesville';
		vehicleDetails.monthlyPayment = 2300.0;
		vehicleDetails.downPayment = 2300.0;
		vehicleDetails.pickPayment = 2300;
		vehicleDetails.warrantyID = 23;
		vehicleDetails.warrantyPrice = 1200.0;
		vehicleDetails.tradeACV = 2300.0;
		vehicleDetails.tradePayoff = 2300.0;
		vehicleDetails.interestRate = 12.0;
		
		DealDetails dealDetails = new DealDetails();
		dealDetails.dealId = 12;
		dealDetails.maxMonthly = 12000.00;
		dealDetails.maxPrice = 24000.00;
		dealDetails.percentBelow = 12.0;
		dealDetails.percentUnder = 11.0;
		dealDetails.vehicleDetails = vehicleDetails;
		
		GetDealDetailsResponseBody responseBody = new GetDealDetailsResponseBody();
		responseBody.isError = false;
		responseBody.statusCode = 200;
		responseBody.result = new List<DealDetails>{dealDetails};
		
		HttpResponse response = new HttpResponse();
		response.setStatusCode(200);
		response.setStatus('Success');
		response.setBody(JSON.serialize(responseBody));
		
		return response;
	}
	
	public static HttpResponse generateSubmitResponse(HttpRequest request)
	{
		if (request == null)
		{
			SaveCreditScoreApplicationResponseBody responseBody = new SaveCreditScoreApplicationResponseBody();
			responseBody.isError = true;
			responseBody.message = 'Error';
			
			HttpResponse response = new HttpResponse();
			response.setStatus('Error');
			response.setBody(JSON.serialize(responseBody));
			
			return response;
		}
		
		SubmitResult submitResult = new SubmitResult();
		submitResult.statusID = 2;
		submitResult.SPCreditAppID = 1;
		
		SubmitResponseBody responseBody = new SubmitResponseBody();
		responseBody.isError = false;
		responseBody.statusCode = 200;
		responseBody.result = submitResult;
		
		HttpResponse response = new HttpResponse();
		response.setStatusCode(200);
		response.setStatus('Success');
		response.setBody(JSON.serialize(responseBody));
		
		return response;
	}
	
	public static HttpResponse generateGetOnlineApplicationAdjustedScoresResponse(HttpRequest request)
	{
		if (request == null)
		{
			SaveCreditScoreApplicationResponseBody responseBody = new SaveCreditScoreApplicationResponseBody();
			responseBody.isError = true;
			responseBody.message = 'Error';
			
			HttpResponse response = new HttpResponse();
			response.setStatus('Error');
			response.setBody(JSON.serialize(responseBody));
			
			return response;
		}
		
		AdjustedScores primaryScore = new AdjustedScores();
		primaryScore.beaconScoreValue = 0;
		primaryScore.ficoPercent = '10%';
		primaryScore.isAdjusted = true;
		primaryScore.isLetterPrinted = true;
		primaryScore.maxMonthlyPayment = 1500;
		primaryScore.maxPurchasePrice = 23000;
		primaryScore.minDownPaymentPercent = 1.5;
		primaryScore.scoreID = 124;
		primaryScore.scoreValue = 34000;
		
		OnlineApplicationAdjustedScores onlineApplicationAdjustedScores = new OnlineApplicationAdjustedScores();
		onlineApplicationAdjustedScores.customerID = 1344;
		onlineApplicationAdjustedScores.SPCreditAppID = 12;
		onlineApplicationAdjustedScores.scoreData = primaryScore;
		onlineApplicationAdjustedScores.statusID = 1;
		
		GetOnlineApplicationAdjustedScoresResponseBody responseBody = new GetOnlineApplicationAdjustedScoresResponseBody();
		responseBody.isError = false;
		responseBody.statusCode = 200;
		responseBody.result = new List<OnlineApplicationAdjustedScores>{OnlineApplicationAdjustedScores};
		
		HttpResponse response = new HttpResponse();
		response.setStatusCode(200);
		response.setStatus('Success');
		response.setBody(JSON.serialize(responseBody));
		
		return response;
	}
	
	public static HttpResponse generateActiveApplicationSearchResponse(HttpRequest request)
	{
		if (request == null)
		{
			SaveCreditScoreApplicationResponseBody responseBody = new SaveCreditScoreApplicationResponseBody();
			responseBody.isError = true;
			responseBody.message = 'Error';
			
			HttpResponse response = new HttpResponse();
			response.setStatus('Error');
			response.setBody(JSON.serialize(responseBody));
			
			return response;
		}
		
		ActiveApplicationData searchResultBuyer = new ActiveApplicationData();
		searchResultBuyer.Ssn = '111-11-1111';
		searchResultBuyer.IsPrimarySsn = true;
		searchResultBuyer.SPCreditAppID = 1;
		
		ActiveApplicationData searchResultCoBuyer = new ActiveApplicationData();
		searchResultCoBuyer.Ssn = '222-22-2222';
		searchResultCoBuyer.IsPrimarySsn = false;
		searchResultCoBuyer.SPCreditAppID = 2;
		
		ActiveApplicationSearchResponseBody searchResponse = new ActiveApplicationSearchResponseBody();
		
		searchResponse.isError = false;
		searchResponse.result = new List<ActiveApplicationData>{searchResultBuyer, searchResultCoBuyer};
		
		HTTPResponse response = new HTTPResponse();
		response.setStatusCode(200);
		response.setBody(JSON.serialize(searchResponse));
		
		return response;
	}
	
	public static HttpResponse generateSaveShortCreditScoreApplicationResponse(HttpRequest request)
	{
		if (request == null)
		{
			SaveCreditScoreApplicationResponseBody responseBody = new SaveCreditScoreApplicationResponseBody();
			responseBody.isError = true;
			responseBody.message = 'Error';
			
			HttpResponse response = new HttpResponse();
			response.setStatus('Error');
			response.setBody(JSON.serialize(responseBody));
			
			return response;
		}
		
		ShortCreditApplicationData result = new ShortCreditApplicationData();
		result.statusID = 3;
		result.customerId = 1;
		result.SPCreditAppID = 1;
		
		SaveShortCreditScoreApplicationResponseBody responseBody = new SaveShortCreditScoreApplicationResponseBody();
		responseBody.isError = false;
		responseBody.statusCode = 200;
		responseBody.result = result;
		
		HTTPResponse response = new HTTPResponse();
		response.setStatusCode(200);
		response.setBody(JSON.serialize(responseBody));
		
		return response;
	}
	
	public static HttpResponse generateSendApprovalEmailResponse(HttpRequest request)
	{
		if (request == null)
		{
			SaveCreditScoreApplicationResponseBody responseBody = new SaveCreditScoreApplicationResponseBody();
			responseBody.isError = true;
			responseBody.message = 'Error';
			
			HttpResponse response = new HttpResponse();
			response.setStatus('Error');
			response.setBody(JSON.serialize(responseBody));
			
			return response;
		}
		
		SendApprovalEmailResponseBody responseBody = new SendApprovalEmailResponseBody();
		responseBody.isError = false;
		responseBody.statusCode = 200;
		responseBody.result = true;
		
		HTTPResponse response = new HTTPResponse();
		response.setStatusCode(200);
		response.setBody(JSON.serialize(responseBody));
		
		return response;
	}
	
	public static HttpResponse generateSaveUserResponse(HttpRequest request)
	{
		if (request == null)
		{
			SaveCreditScoreApplicationResponseBody responseBody = new SaveCreditScoreApplicationResponseBody();
			responseBody.isError = true;
			responseBody.message = 'Error';
			
			HttpResponse response = new HttpResponse();
			response.setStatus('Error');
			response.setBody(JSON.serialize(responseBody));
			
			return response;
		}
		
		UserData userData = new UserData();
		userData.SFEmail = 'emailsavetest@email.com';
		userData.userId = 1;
		
		SaveUserResponseBody responseBody = new SaveUserResponseBody();
		responseBody.isError = false;
		responseBody.statusCode = 200;
		responseBody.result = new List<UserData>{userData};
		
		HTTPResponse response = new HTTPResponse();
		response.setStatusCode(200);
		response.setBody(JSON.serialize(responseBody));
		
		return response;
	}
	
	public static HttpResponse generateSaveOrUpdateStoreLocationResponse(HttpRequest request)
	{
		if (request == null)
		{
			SaveCreditScoreApplicationResponseBody responseBody = new SaveCreditScoreApplicationResponseBody();
			responseBody.isError = true;
			responseBody.message = 'Error';
			
			HttpResponse response = new HttpResponse();
			response.setStatus('Error');
			response.setBody(JSON.serialize(responseBody));
			
			return response;
		}
		
		StoreLocationData locationData = new StoreLocationData();
		locationData.id = 12;
		locationData.lotCode = '1207';
		
		SaveOrUpdateStoreLocationResponseBody responseBody = new SaveOrUpdateStoreLocationResponseBody();
		responseBody.isError = false;
		responseBody.statusCode = 200;
		responseBody.result = new List<StoreLocationData>{locationData};
		
		HttpResponse response = new HttpResponse();
		response.setStatusCode(200);
		response.setBody(JSON.serialize(responseBody));
		
		return response;
	}
	
	public static HttpResponse generateAccountRegisterResponse(HttpRequest request)
	{
		if (request == null)
		{
			SaveCreditScoreApplicationResponseBody responseBody = new SaveCreditScoreApplicationResponseBody();
			responseBody.isError = true;
			responseBody.message = 'Error';
			
			HttpResponse response = new HttpResponse();
			response.setStatus('Error');
			response.setBody(JSON.serialize(responseBody));
			
			return response;
		}
		
		HttpResponse response = new HttpResponse();
		response.setStatusCode(200);
		
		return response;
	}
	
	public static HttpResponse generateGetDealAndVehicleDetailsResponse(HttpRequest request)
	{
		if (request == null)
		{
			SaveCreditScoreApplicationResponseBody responseBody = new SaveCreditScoreApplicationResponseBody();
			responseBody.isError = true;
			responseBody.message = 'Error';
			
			HttpResponse response = new HttpResponse();
			response.setStatus('Error');
			response.setBody(JSON.serialize(responseBody));
			
			return response;
		}
		
		DealAndVehicle dealAndVehicleDetails = new DealAndVehicle();
		dealAndVehicleDetails.Contract = 1;
		dealAndVehicleDetails.StockNo = 'StockNo';
		dealAndVehicleDetails.Datesold = Date.today();
		dealAndVehicleDetails.CustCode = '1';
		dealAndVehicleDetails.Lot = 1;
		dealAndVehicleDetails.Customergrade = 'Customergrade';
		dealAndVehicleDetails.Apr = 'Apr';
		dealAndVehicleDetails.Intrate = 10.0;
		dealAndVehicleDetails.CARINFO = 'CARINFO';
		dealAndVehicleDetails.Downpay = 10.0;
		dealAndVehicleDetails.PICKUP = 'PICKUP';
		dealAndVehicleDetails.REBATEPO = 'REBATEPO';
		dealAndVehicleDetails.Single = 'Single';
		dealAndVehicleDetails.SELLPRICE = 50.0;
		dealAndVehicleDetails.WARRANTY = 'WARRANTY';
		dealAndVehicleDetails.companycode = '123';
		dealAndVehicleDetails.BODYTYPE = 'BODYTYPE';
		dealAndVehicleDetails.BUYER = 156;
		dealAndVehicleDetails.Carcolor = 'red';
		dealAndVehicleDetails.Carmake = 'Toyota';
		dealAndVehicleDetails.Carmodel = 'Corolla';
		dealAndVehicleDetails.cartype = 'Hatchback';
		dealAndVehicleDetails.daterec = 'daterec';
		dealAndVehicleDetails.Enginecyls = 'GH-1; JHJ';
		dealAndVehicleDetails.Fueltype = 'Diesel';
		dealAndVehicleDetails.mileage = 2000.2;
		dealAndVehicleDetails.selling1 = 'selling1';
		dealAndVehicleDetails.Transtype = 'Transmission';
		dealAndVehicleDetails.Trim = 'Trim';
		dealAndVehicleDetails.vin = '98847472HHF883';
		
		
		GetDealAndVehicleDetailsResponseBody responseBody = new GetDealAndVehicleDetailsResponseBody();
		responseBody.isError = false;
		responseBody.statusCode = 200;
		responseBody.result = new List<DealAndVehicle>{dealAndVehicleDetails};
		
		HttpResponse response = new HttpResponse();
		response.setStatusCode(200);
		response.setStatus('Success');
		response.setBody(JSON.serialize(responseBody));
		
		return response;
	}
}