public without sharing class SalesPortalAPI
{
    private static Sales_Portal_Integration_Settings__c integrationSettings = Sales_Portal_Integration_Settings__c.getInstance('Standard Settings');

    public static String authentificateOnSalesPortal(Integer timeout)
    {
        SalesPortalAPIRequests.AuthentificationRequestBody authentificationRequestBody = new SalesPortalAPIRequests.AuthentificationRequestBody();
        authentificationRequestBody.User = integrationSettings.Login__c;
        authentificationRequestBody.Password = integrationSettings.Password__c;

        HttpRequest authentificationRequest = new HttpRequest();

        authentificationRequest.setMethod('POST');
        authentificationRequest.setEndpoint(integrationSettings.Authentification_URL__c);
        authentificationRequest.setHeader('Content-Type', 'application/json');
        authentificationRequest.setTimeout(timeout);
        authentificationRequest.setBody(JSON.serialize(authentificationRequestBody));

        HTTPResponse response;

        if (Test.isRunningTest())
        {
            response = SalesPortalAPIResponses.generateAuthentificationResponse(authentificationRequest);
        }
        else
        {
            Http http = new Http();
            
            response = http.send(authentificationRequest);
        }

        Utils.logHttpCallout(authentificationRequest);
        Utils.logHttpResponse(response);

        if (response.getStatusCode() == 200)
        {
            SalesPortalAPIResponses.AuthentificationResponseBody responseBody = (SalesPortalAPIResponses.AuthentificationResponseBody)
                    JSON.deserialize(response.getBody(), SalesPortalAPIResponses.AuthentificationResponseBody.class);

            if (!responseBody.isError)
            {
                return responseBody.result; 
            }
            else
            {
                throw new SalesPortalAPIException(responseBody.message);
            }
        }
        else
        {

            throw new SalesPortalAPIException(response.getStatusCode() + ' : ' + response.getStatus());
        }

        return null;
    }

    public static SalesPortalAPIResponses.CreditScoreApplicationData saveCreditScoreApplication(String requestBody, String token, Integer timeout)
    {
        HttpRequest saveCreditScoreApplicationRequest = new HttpRequest();

        saveCreditScoreApplicationRequest.setMethod('POST');
        saveCreditScoreApplicationRequest.setEndpoint(integrationSettings.Save_App_Data_URL__c);
        saveCreditScoreApplicationRequest.setHeader('Content-Type', 'application/json');
        saveCreditScoreApplicationRequest.setHeader('Token', token);
        saveCreditScoreApplicationRequest.setTimeout(timeout);
        saveCreditScoreApplicationRequest.setBody(requestBody);

        HTTPResponse response;

        if (Test.isRunningTest())
        {
            response = SalesPortalAPIResponses.generateSaveCreditScoreApplicationResponse(saveCreditScoreApplicationRequest);
        }
        else
        {
            Http http = new Http();
            response = http.send(saveCreditScoreApplicationRequest);
        }

        Utils.logHttpCallout(saveCreditScoreApplicationRequest);
        Utils.logHttpResponse(response);

        if (response.getStatusCode() == 200)
        {
            SalesPortalAPIResponses.SaveCreditScoreApplicationResponseBody responseBody = (SalesPortalAPIResponses.SaveCreditScoreApplicationResponseBody)
                    JSON.deserialize(response.getBody(), SalesPortalAPIResponses.SaveCreditScoreApplicationResponseBody.class);

            if (!responseBody.isError)
            {
                return responseBody.result;
            }
            else
            {
                throw new SalesPortalAPIException(responseBody.message);
            }
        }
        else
        {
            SalesPortalAPIExceptionWrapper exceptionWrapper = (SalesPortalAPIExceptionWrapper)JSON.deserialize(response.getBody(), SalesPortalAPIExceptionWrapper.class);
            
            throw new SalesPortalAPIException(String.valueOf(exceptionWrapper.Members));
        }

        return null;
    }

    public static List<SalesPortalAPIResponses.CreditApplicationStatus> getCreditApplicationsStatuses(List<Integer> creditApplicationIds, String token, Integer timeout)
    {
        HttpRequest getCreditApplicationsStatusesRequest = new HttpRequest();

        getCreditApplicationsStatusesRequest.setMethod('GET');
        getCreditApplicationsStatusesRequest.setEndpoint(integrationSettings.Get_Credit_Applications_Statuses_URL__c.replace('{ID}', String.join(creditApplicationIds, ',')));
        getCreditApplicationsStatusesRequest.setHeader('Content-Type', 'application/json');
        getCreditApplicationsStatusesRequest.setHeader('Token', token);
        getCreditApplicationsStatusesRequest.setTimeout(timeout);

        HTTPResponse response;

        if (Test.isRunningTest())
        {
            response = SalesPortalAPIResponses.generategetCreditApplicationsStatusesResponse(getCreditApplicationsStatusesRequest);
        }
        else
        {
            Http http = new Http();
            response = http.send(getCreditApplicationsStatusesRequest);
        }

        Utils.logHttpCallout(getCreditApplicationsStatusesRequest);
        Utils.logHttpResponse(response);

        if (response.getStatusCode() == 200)
        {
            SalesPortalAPIResponses.GetCreditApplicationStatusesResponseBody responseBody = (SalesPortalAPIResponses.GetCreditApplicationStatusesResponseBody)
                    JSON.deserialize(response.getBody(), SalesPortalAPIResponses.GetCreditApplicationStatusesResponseBody.class);

            if (!responseBody.isError)
            {
                return responseBody.result;
            }
            else
            {
                throw new SalesPortalAPIException(responseBody.message);
            }
        }
        else
        {
            throw new SalesPortalAPIException(response.getStatusCode() + ' : ' + response.getStatus());
        }

        return null;
    }

    public static List<SalesPortalAPIResponses.RegularApplicationAdjustedScores> getAdjustedCreditScores(List<String> creditApplicationIds, String token, Integer timeout)
    {
        HttpRequest getAdjustedCreditScoresRequest = new HttpRequest();

        getAdjustedCreditScoresRequest.setMethod('GET');
        getAdjustedCreditScoresRequest.setEndpoint(integrationSettings.Get_Adjusted_Credit_Score_URL__c.replace('{ID}', String.join(creditApplicationIds, ',')));
        getAdjustedCreditScoresRequest.setHeader('Content-Type', 'application/json');
        getAdjustedCreditScoresRequest.setHeader('Token', token);
        getAdjustedCreditScoresRequest.setTimeout(timeout);

        HTTPResponse response;

        if (Test.isRunningTest())
        {
            response = SalesPortalAPIResponses.generateGetAdjustedCreditScoresResponse(getAdjustedCreditScoresRequest);
        }
        else
        {
            Http http = new Http();
            response = http.send(getAdjustedCreditScoresRequest);
        }

        Utils.logHttpCallout(getAdjustedCreditScoresRequest);
        Utils.logHttpResponse(response);

        if (response.getStatusCode() == 200)
        {
            SalesPortalAPIResponses.GetAdjustedCreditScoresResponseBody responseBody = (SalesPortalAPIResponses.GetAdjustedCreditScoresResponseBody)
                    JSON.deserialize(response.getBody(), SalesPortalAPIResponses.GetAdjustedCreditScoresResponseBody.class);

            if (!responseBody.isError)
            {
                return responseBody.result;
            }
            else
            {
                throw new SalesPortalAPIException(responseBody.message);
            }
        }
        else
        {
            throw new SalesPortalAPIException(response.getStatusCode() + ' : ' + response.getStatus());
        }

        return null;
    }

    public static void printLetter(String requestBody, String token, Integer timeout)
    {
        HttpRequest printLetterRequest = new HttpRequest();

        printLetterRequest.setMethod('POST');
        printLetterRequest.setEndpoint(integrationSettings.UpdateLetterPrintedFieldOnSP_URL__c);
        printLetterRequest.setHeader('Content-Type', 'application/json');
        printLetterRequest.setHeader('Token', token);
        printLetterRequest.setTimeout(timeout);
        printLetterRequest.setBody(requestBody);

        HTTPResponse response;

        if (Test.isRunningTest())
        {
            response = SalesPortalAPIResponses.generatePrintLetterResponse(printLetterRequest);
        }
        else
        {
            Http http = new Http();
            response = http.send(printLetterRequest);
        }

        Utils.logHttpCallout(printLetterRequest);
        Utils.logHttpResponse(response);

        if (response.getStatusCode() == 200)
        {
            SalesPortalAPIResponses.PrintLetterResponseBody responseBody = (SalesPortalAPIResponses.PrintLetterResponseBody)
                    JSON.deserialize(response.getBody(), SalesPortalAPIResponses.PrintLetterResponseBody.class);

            if (responseBody.isError)
            {
                throw new SalesPortalAPIException(responseBody.message);
            }
        }
        else
        {
            throw new SalesPortalAPIException(response.getStatusCode() + ' : ' + response.getStatus());
        }
    }

    public static SalesPortalAPIResponses.CalculatorData getCalculatorData(Integer creditApplicationId, String token, Boolean isJointApp, Integer timeout)
    {
        HttpRequest getCalculatorDataRequest = new HttpRequest();

        getCalculatorDataRequest.setMethod('GET');
        getCalculatorDataRequest.setHeader('Content-Type', 'application/json');
        getCalculatorDataRequest.setHeader('Token', token);
        getCalculatorDataRequest.setTimeout(timeout);
        getCalculatorDataRequest.setEndpoint(integrationSettings.GetCalculatorData_URL__c.replace('{ID}', String.valueOf(creditApplicationId)).replace('{ISJOINT}', String.valueOf(isJointApp)));

        HTTPResponse response;

        if (Test.isRunningTest())
        {
            response = SalesPortalAPIResponses.generateCalculatorDataResponse(getCalculatorDataRequest);
        }
        else
        {
            Http http = new Http();
            response = http.send(getCalculatorDataRequest);
        }

        Utils.logHttpCallout(getCalculatorDataRequest);
        Utils.logHttpResponse(response);

        if (response.getStatusCode() == 200)
        {
            SalesPortalAPIResponses.GetCalculatorDataResponseBody responseBody = (SalesPortalAPIResponses.GetCalculatorDataResponseBody)
                    JSON.deserialize(response.getBody(), SalesPortalAPIResponses.GetCalculatorDataResponseBody.class);

            if (!responseBody.isError)
            {
                return responseBody.result;
            }
            else
            {
                throw new SalesPortalAPIException(responseBody.message);
            }
        }
        else
        {
            throw new SalesPortalAPIException(response.getStatusCode() + ' : ' + response.getStatus());
        }

        return null;
    }

    public static SalesPortalAPIResponses.VehiclesList getVehiclesList(String requestBody, String token, Integer timeout)
    {
        HttpRequest getVehiclesListRequest = new HttpRequest();

        getVehiclesListRequest.setMethod('POST');
        getVehiclesListRequest.setEndpoint(integrationSettings.Get_Paged_Vehicles_List_URL__c);
        getVehiclesListRequest.setHeader('Content-Type', 'application/json');
        getVehiclesListRequest.setHeader('Token', token);
        getVehiclesListRequest.setTimeout(timeout);
        getVehiclesListRequest.setBody(requestBody);

        HTTPResponse response;

        if (Test.isRunningTest())
        {
            response = SalesPortalAPIResponses.generateGetVehiclesListResponse(getVehiclesListRequest);
        }
        else
        {
            Http http = new Http();
            response = http.send(getVehiclesListRequest);
        }

        Utils.logHttpCallout(getVehiclesListRequest);
        Utils.logHttpResponse(response);

        if (response.getStatusCode() == 200)
        {
            SalesPortalAPIResponses.GetVehiclesListResponseBody responseBody = (SalesPortalAPIResponses.GetVehiclesListResponseBody)
                    JSON.deserialize(response.getBody(), SalesPortalAPIResponses.GetVehiclesListResponseBody.class);

            if (!responseBody.isError)
            {
                return responseBody.result;
            }
            else
            {
                throw new SalesPortalAPIException(responseBody.message);
            }
        }
        else
        {
            throw new SalesPortalAPIException(response.getStatusCode() + ' : ' + response.getStatus());
        }

        return null;
    }

    public static SalesPortalAPIResponses.VehicleDetails getVehicleDetails(String requestBody, String token, Integer timeout)
    {
        HttpRequest getVehicleDetailsRequest = new HttpRequest();

        getVehicleDetailsRequest.setMethod('POST');
        getVehicleDetailsRequest.setEndpoint(integrationSettings.GetSelectedVehicleDetails_URL__c);
        getVehicleDetailsRequest.setHeader('Content-Type', 'application/json');
        getVehicleDetailsRequest.setHeader('Token', token);
        getVehicleDetailsRequest.setTimeout(timeout);
        getVehicleDetailsRequest.setBody(requestBody);

        HTTPResponse response;

        if (Test.isRunningTest())
        {
            response = SalesPortalAPIResponses.generateGetVehicleDetailsResponse(getVehicleDetailsRequest);
        }
        else
        {
            Http http = new Http();
            response = http.send(getVehicleDetailsRequest);
        }

        Utils.logHttpCallout(getVehicleDetailsRequest);
        Utils.logHttpResponse(response);

        if (response.getStatusCode() == 200)
        {
            SalesPortalAPIResponses.GetVehicleDetailsResponseBody responseBody = (SalesPortalAPIResponses.GetVehicleDetailsResponseBody)
                    JSON.deserialize(response.getBody(), SalesPortalAPIResponses.GetVehicleDetailsResponseBody.class);

            if (!responseBody.isError)
            {
                return responseBody.result;
            }
            else
            {
                throw new SalesPortalAPIException(responseBody.message);
            }
        }
        else
        {
            throw new SalesPortalAPIException(response.getStatusCode() + ' : ' + response.getStatus());
        }

        return null;
    }

    public static SalesPortalAPIResponses.VehicleSelectionResult selectVehicle(String requestBody, String token, Integer timeout)
    {
        HttpRequest selectVehicleRequest = new HttpRequest();

        selectVehicleRequest.setMethod('POST');
        selectVehicleRequest.setEndpoint(integrationSettings.SelectVehicle_URL__c);
        selectVehicleRequest.setHeader('Content-Type', 'application/json');
        selectVehicleRequest.setHeader('Token', token);
        selectVehicleRequest.setTimeout(timeout);
        selectVehicleRequest.setBody(requestBody);

        HTTPResponse response;

        if (Test.isRunningTest())
        {
            response = SalesPortalAPIResponses.generateSelectVehicleResponse(selectVehicleRequest);
        }
        else
        {
            Http http = new Http();
            response = http.send(selectVehicleRequest);
        }

        Utils.logHttpCallout(selectVehicleRequest);
        Utils.logHttpResponse(response);

        if (response.getStatusCode() == 200)
        {
            SalesPortalAPIResponses.SelectVehicleResponseBody responseBody = (SalesPortalAPIResponses.SelectVehicleResponseBody)
                JSON.deserialize(response.getBody(), SalesPortalAPIResponses.SelectVehicleResponseBody.class);

            if (!responseBody.isError)
            {
                return responseBody.result;
            }
            else
            {
                throw new SalesPortalAPIException(responseBody.message);
            }
        }
        else
        {
            throw new SalesPortalAPIException(response.getStatusCode() + ' : ' + response.getStatus());
        }

        return null;
    }

    public static List<SalesPortalAPIResponses.DealDetails> getDealDetails(List<String> creditAppIds, String token, Integer timeout)
    {
        HttpRequest getDealDetailsRequest = new HttpRequest();

        getDealDetailsRequest.setMethod('GET');
        getDealDetailsRequest.setEndpoint(integrationSettings.GetDealDetails_URL__c.replace('{ID}', String.join(creditAppIds, ',')));
        getDealDetailsRequest.setHeader('Content-Type', 'application/json');
        getDealDetailsRequest.setHeader('Token', token);
        getDealDetailsRequest.setTimeout(timeout);

        HTTPResponse response;

        if (Test.isRunningTest())
        {
            response = SalesPortalAPIResponses.generateGetDealDetailsResponse(getDealDetailsRequest);
        }
        else
        {
            Http http = new Http();
            response = http.send(getDealDetailsRequest);
        }

        Utils.logHttpCallout(getDealDetailsRequest);
        Utils.logHttpResponse(response);

        if (response.getStatusCode() == 200)
        {
            SalesPortalAPIResponses.GetDealDetailsResponseBody responseBody = (SalesPortalAPIResponses.GetDealDetailsResponseBody)
                    JSON.deserialize(response.getBody(), SalesPortalAPIResponses.GetDealDetailsResponseBody.class);

            if (!responseBody.isError)
            {
                return responseBody.result;
            }
            else
            {
                throw new SalesPortalAPIException(responseBody.message);
            }
        }
        else
        {
            throw new SalesPortalAPIException(response.getStatusCode() + ' : ' + response.getStatus());
        }

        return null;
    }

    public static SalesPortalAPIResponses.SubmitResult sendDealForManagersApproval(String requestBody, String token, Integer timeout)
    {
        HttpRequest sendDealForManagersApprovalRequest = new HttpRequest();

        sendDealForManagersApprovalRequest.setMethod('POST');
        sendDealForManagersApprovalRequest.setEndpoint(integrationSettings.Send_Deal_For_Managers_Approval_URL__c);
        sendDealForManagersApprovalRequest.setHeader('Content-Type', 'application/json');
        sendDealForManagersApprovalRequest.setHeader('Token', token);
        sendDealForManagersApprovalRequest.setTimeout(timeout);
        sendDealForManagersApprovalRequest.setBody(requestBody);

        HTTPResponse response;

        if (Test.isRunningTest())
        {
            response = SalesPortalAPIResponses.generateSubmitResponse(sendDealForManagersApprovalRequest);
        }
        else
        {
            Http http = new Http();
            response = http.send(sendDealForManagersApprovalRequest);
        }

        Utils.logHttpCallout(sendDealForManagersApprovalRequest);
        Utils.logHttpResponse(response);

        if (response.getStatusCode() == 200)
        {
            SalesPortalAPIResponses.SubmitResponseBody responseBody = (SalesPortalAPIResponses.SubmitResponseBody)
                    JSON.deserialize(response.getBody(), SalesPortalAPIResponses.SubmitResponseBody.class);

            if (!responseBody.isError)
            {
                return responseBody.result;
            }
            else
            {
                throw new SalesPortalAPIException(responseBody.message);
            }
        }
        else
        {
            throw new SalesPortalAPIException(response.getStatusCode() + ' : ' + response.getStatus());
        }

        return null;
    }

    public static SalesPortalAPIResponses.SubmitResult removeVehicle(String requestBody, String token, Integer timeout)
    {
        HttpRequest removeVehicleRequest = new HttpRequest();

        removeVehicleRequest.setMethod('POST');
        removeVehicleRequest.setEndpoint(integrationSettings.Remove_Vehicle_URL__c);
        removeVehicleRequest.setHeader('Content-Type', 'application/json');
        removeVehicleRequest.setHeader('Token', token);
        removeVehicleRequest.setTimeout(timeout);
        removeVehicleRequest.setBody(requestBody);

        HTTPResponse response;

        if (Test.isRunningTest())
        {
            response = SalesPortalAPIResponses.generateSubmitResponse(removeVehicleRequest);
        }
        else
        {
            Http http = new Http();
            response = http.send(removeVehicleRequest);
        }

        Utils.logHttpCallout(removeVehicleRequest);
        Utils.logHttpResponse(response);

        if (response.getStatusCode() == 200)
        {
            SalesPortalAPIResponses.SubmitResponseBody responseBody = (SalesPortalAPIResponses.SubmitResponseBody)
                    JSON.deserialize(response.getBody(), SalesPortalAPIResponses.SubmitResponseBody.class);

            if (!responseBody.isError)
            {
                return responseBody.result;
            }
            else
            {
                throw new SalesPortalAPIException(responseBody.message);
            }
        }
        else
        {
            throw new SalesPortalAPIException(response.getStatusCode() + ' : ' + response.getStatus());
        }

        return null;
    }

    public static SalesPortalAPIResponses.SubmitResult revertToIncomplete(String requestBody, String token, Integer timeout)
    {
        HttpRequest revertToIncompleteRequest = new HttpRequest();

        revertToIncompleteRequest.setMethod('POST');
        revertToIncompleteRequest.setEndpoint(integrationSettings.Reverse_To_In_Progress_URL__c);
        revertToIncompleteRequest.setHeader('Content-Type', 'application/json');
        revertToIncompleteRequest.setHeader('Token', token);
        revertToIncompleteRequest.setTimeout(timeout);
        revertToIncompleteRequest.setBody(requestBody);

        HTTPResponse response;

        if (Test.isRunningTest())
        {
            response = SalesPortalAPIResponses.generateSubmitResponse(revertToIncompleteRequest);
        }
        else
        {
            Http http = new Http();
            response = http.send(revertToIncompleteRequest);
        }

        Utils.logHttpCallout(revertToIncompleteRequest);
        Utils.logHttpResponse(response);

        if (response.getStatusCode() == 200)
        {
            SalesPortalAPIResponses.SubmitResponseBody responseBody = (SalesPortalAPIResponses.SubmitResponseBody)
                    JSON.deserialize(response.getBody(), SalesPortalAPIResponses.SubmitResponseBody.class);

            if (!responseBody.isError)
            {
                return responseBody.result;
            }
            else
            {
                throw new SalesPortalAPIException(responseBody.message);
            }
        }
        else
        {
            throw new SalesPortalAPIException(response.getStatusCode() + ' : ' + response.getStatus());
        }

        return null;
    }

    public static List<SalesPortalAPIResponses.OnlineApplicationAdjustedScores> getOnlineApplicationsAdjustedScores(List<String> creditApplicationIds, String token, Integer timeout)
    {
        HttpRequest getOnlineApplicationsAdjustedScoresRequest = new HttpRequest();

        getOnlineApplicationsAdjustedScoresRequest.setMethod('GET');
        getOnlineApplicationsAdjustedScoresRequest.setEndpoint(integrationSettings.Get_Online_Apps_Adjusted_Score_URL__c.replace('{ID}', String.join(creditApplicationIds, ',')));
        getOnlineApplicationsAdjustedScoresRequest.setHeader('Content-Type', 'application/json');
        getOnlineApplicationsAdjustedScoresRequest.setHeader('Token', token);
        getOnlineApplicationsAdjustedScoresRequest.setTimeout(timeout);

        HTTPResponse response;

        if (Test.isRunningTest())
        {
            response = SalesPortalAPIResponses.generateGetOnlineApplicationAdjustedScoresResponse(getOnlineApplicationsAdjustedScoresRequest);
        }
        else
        {
            Http http = new Http();
            response = http.send(getOnlineApplicationsAdjustedScoresRequest);
        }

        Utils.logHttpCallout(getOnlineApplicationsAdjustedScoresRequest);
        Utils.logHttpResponse(response);

        if (response.getStatusCode() == 200)
        {
            SalesPortalAPIResponses.GetOnlineApplicationAdjustedScoresResponseBody responseBody = (SalesPortalAPIResponses.GetOnlineApplicationAdjustedScoresResponseBody)
                    JSON.deserialize(response.getBody(), SalesPortalAPIResponses.GetOnlineApplicationAdjustedScoresResponseBody.class);

            if (!responseBody.isError)
            {
                return responseBody.result;
            }
            else
            {
                throw new SalesPortalAPIException(responseBody.message);
            }
        }
        else
        {
            throw new SalesPortalAPIException(response.getStatusCode() + ' : ' + response.getStatus());
        }

        return null;
    }

    public static List<SalesPortalAPIResponses.UserData> saveUser(String requestBody, String token, Integer timeout)
    {
        HttpRequest saveUserRequest = new HttpRequest();

        saveUserRequest.setMethod('POST');
        saveUserRequest.setEndpoint(integrationSettings.Add_User_URL__c);
        saveUserRequest.setHeader('Content-Type', 'application/json');
        saveUserRequest.setHeader('Token', token);
        saveUserRequest.setTimeout(timeout);
        saveUserRequest.setBody(requestBody);

        HTTPResponse response;

        if (Test.isRunningTest())
        {
            response = SalesPortalAPIResponses.generateSaveUserResponse(saveUserRequest);
        }
        else
        {
            Http http = new Http();
            response = http.send(saveUserRequest);
        }

        Utils.logHttpCallout(saveUserRequest);
        Utils.logHttpResponse(response);

        if (response.getStatusCode() == 200)
        {
            SalesPortalAPIResponses.SaveUserResponseBody responseBody = (SalesPortalAPIResponses.SaveUserResponseBody)
                    JSON.deserialize(response.getBody(), SalesPortalAPIResponses.SaveUserResponseBody.class);

            if (!responseBody.isError)
            {
                return responseBody.result;
            }
            else
            {
                throw new SalesPortalAPIException(responseBody.message);
            }
        }
        else
        {
            throw new SalesPortalAPIException(response.getStatusCode() + ' : ' + response.getStatus());
        }

        return null;
    }

    public static List<SalesPortalAPIResponses.ActiveApplicationData> searchActiveApplications(String requestBody, String token, Integer timeout)
    {
        HttpRequest searchActiveApplicationsRequest = new HttpRequest();

        searchActiveApplicationsRequest.setMethod('POST');
        searchActiveApplicationsRequest.setEndpoint(integrationSettings.Search_Active_Applications_URL__c);
        searchActiveApplicationsRequest.setHeader('Content-Type', 'application/json');
        searchActiveApplicationsRequest.setHeader('Token', token);
        searchActiveApplicationsRequest.setTimeout(timeout);
        searchActiveApplicationsRequest.setBody(requestBody);

        HTTPResponse response;

        if (Test.isRunningTest())
        {
            response = SalesPortalAPIResponses.generateActiveApplicationSearchResponse(searchActiveApplicationsRequest);
        }
        else
        {
            Http http = new Http();
            response = http.send(searchActiveApplicationsRequest);
        }

        Utils.logHttpCallout(searchActiveApplicationsRequest);
        Utils.logHttpResponse(response);

        if (response.getStatusCode() == 200)
        {
            SalesPortalAPIResponses.ActiveApplicationSearchResponseBody responseBody = (SalesPortalAPIResponses.ActiveApplicationSearchResponseBody)
                    JSON.deserialize(response.getBody(), SalesPortalAPIResponses.ActiveApplicationSearchResponseBody.class);

            if (!responseBody.isError)
            {
                return responseBody.result;
            }
            else
            {
                throw new SalesPortalAPIException(responseBody.message);
            }
        }
        else
        {
            throw new SalesPortalAPIException(response.getStatusCode() + ' : ' + response.getStatus());
        }
    }

    public static SalesPortalAPIResponses.ShortCreditApplicationData saveShortCreditScoreApplication(String requestBody, String token, Integer timeout)
    {
        HttpRequest saveShortCreditScoreApplicationRequest = new HttpRequest();

        saveShortCreditScoreApplicationRequest.setMethod('POST');
        saveShortCreditScoreApplicationRequest.setEndpoint(integrationSettings.Save_Short_Credit_Score_App_URL__c);
        saveShortCreditScoreApplicationRequest.setHeader('Content-Type', 'application/json');
        saveShortCreditScoreApplicationRequest.setHeader('Token', token);
        saveShortCreditScoreApplicationRequest.setTimeout(timeout);
        saveShortCreditScoreApplicationRequest.setBody(requestBody);

        HTTPResponse response;

        if (Test.isRunningTest())
        {
            response = SalesPortalAPIResponses.generateSaveShortCreditScoreApplicationResponse(saveShortCreditScoreApplicationRequest);
        }
        else
        {
            Http http = new Http();
            response = http.send(saveShortCreditScoreApplicationRequest);
        }

        Utils.logHttpCallout(saveShortCreditScoreApplicationRequest);
        Utils.logHttpResponse(response);

        if (response.getStatusCode() == 200)
        {
            SalesPortalAPIResponses.SaveShortCreditScoreApplicationResponseBody responseBody = (SalesPortalAPIResponses.SaveShortCreditScoreApplicationResponseBody)
                    JSON.deserialize(response.getBody(), SalesPortalAPIResponses.SaveShortCreditScoreApplicationResponseBody.class);

            if (!responseBody.isError)
            {
                return responseBody.result;
            }
            else
            {
                throw new SalesPortalAPIException(responseBody.message);
            }
        }
        else
        {
            throw new SalesPortalAPIException(response.getStatusCode() + ' : ' + response.getStatus());
        }
    }

    public static Boolean sendApprovalEmail(String sendApprovalEmailRequestBody, String token, Integer timeout)
    {
        HttpRequest sendApprovalEmailRequest = new HttpRequest();

        sendApprovalEmailRequest.setMethod('POST');
        sendApprovalEmailRequest.setEndpoint(integrationSettings.Send_Approval_Email_URL__c);
        sendApprovalEmailRequest.setHeader('Content-Type', 'application/json');
        sendApprovalEmailRequest.setHeader('Token', token);
        sendApprovalEmailRequest.setTimeout(timeout);
        sendApprovalEmailRequest.setBody(sendApprovalEmailRequestBody);

        HTTPResponse response;

        if (Test.isRunningTest())
        {
            response = SalesPortalAPIResponses.generateSendApprovalEmailResponse(sendApprovalEmailRequest);
        }
        else
        {
            Http http = new Http();
            response = http.send(sendApprovalEmailRequest);
        }

        Utils.logHttpCallout(sendApprovalEmailRequest);
        Utils.logHttpResponse(response);

        if (response.getStatusCode() == 200)
        {
            SalesPortalAPIResponses.SendApprovalEmailResponseBody responseBody = (SalesPortalAPIResponses.SendApprovalEmailResponseBody)
                    JSON.deserialize(response.getBody(), SalesPortalAPIResponses.SendApprovalEmailResponseBody.class);

            if (!responseBody.isError)
            {
                return responseBody.result;
            }
            else
            {
                throw new SalesPortalAPIException(responseBody.message);
            }
        }
        else
        {
            throw new SalesPortalAPIException(response.getStatusCode() + ' : ' + response.getStatus());
        }
    }
    
    public class SalesPortalAPIExceptionWrapper
    {
        public String ErrorMessage {public get; public set;}
        public Integer StatusCode {public get; public set;}
        public List<String> Members {public get; public set;}
    }

    public class SalesPortalAPIException extends Exception {}
}