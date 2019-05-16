public class CreditAppBoxComponentController
{
    private static final Set<String> newOnlineApplicationStatuses = new Set<String>{
            SalesPortalUtils.CREDIT_APP_STATUS_COND_SCORED, SalesPortalUtils.CREDIT_APP_STATUS_ONLINE_APP_DECLINED
    };

    private static final Set<String> expiredApplicationStatuses = new Set<String>{
            SalesPortalUtils.CREDIT_APP_STATUS_EXPIRED
    };

    @AuraEnabled
    public static Opportunity getOpportunity(Id opportunityId)
    {
        Opportunity opportunity = [
                SELECT Buyer_Contact__c
                FROM Opportunity
                WHERE Id = :opportunityId
        ];

        return opportunity;
    }

    @AuraEnabled
    public static String getCreditApplication(Id opportunityId, String salesPortalAccessToken)
    {
        try {
            List<Credit_Application__c> cas = [
                    SELECT Id, Opportunity__r.Email__c, Opportunity__r.StageName, Credit_Application_Status__c, Opportunity__c, Ready_To_Submit__c,
                            Credit_Application_Comment__c, Last_Comment_Left_By__c, Sales_Portal_ID__c, Buyer__c, Co_Buyer__c,
                            Sales_Portal_Creation_Date__c, Is_Linked__c, Is_Flipped__c, Flip_Reason__c, Store_Location__r.SalesPortalId__c,
                            Link_Details__c, DealSalesPortalId__c, Is_Active__c
                    FROM Credit_Application__c
                    WHERE (Opportunity__c = :opportunityId)
                    ORDER BY CreatedDate DESC
                    LIMIT 1
            ];

            if (!cas.isEmpty()) {
                CreditAppWrapper wrapper = new CreditAppWrapper();
                wrapper.creditApp = cas[0];

                if (wrapper.creditApp.Is_Active__c) {
                    if (String.isNotBlank(wrapper.creditApp.Sales_Portal_ID__c)) {
                        try {
                            SalesPortalAPIResponses.CreditApplicationStatus result =
                                    SalesPortalAPI.getCreditApplicationsStatuses(new List<Integer>{
                                            Integer.valueOf(wrapper.creditApp.Sales_Portal_ID__c)
                                    }, salesPortalAccessToken, 120000)[0];

                            System.debug('CreditAppBoxComponentController.getCreditApplication: Sales Portal Credit Application Status: ' + result);
                            if (!result.isActive) {
                                return null;
                            }

                            wrapper.creditApp.Credit_Application_Status__c = SalesPortalUtils.salesPortalCreditApplicationStatusIdToValue.get(result.statusID);

                            if (String.isNotBlank(result.lastComment)) {
                                if (String.isNotBlank(result.spUser)) {
                                    wrapper.creditApp.Last_Comment_Left_By__c = result.spUser.substringAfter('\\');
                                }

                                wrapper.creditApp.Credit_Application_Comment__c = result.lastComment;
                            }

                            update wrapper.creditApp;
                        } catch (Exception ex) {
                            Utils.logException(ex);
                            throw new AuraHandledException('Unable to refresh status from Sales Portal.');
                        }
                    }

                    return JSON.serialize(wrapper);
                }
            }
        } catch (Exception ex) {
            System.debug('getCreditApplication Error: ' + ex.getMessage());
            throw new CA_RefreshException( ex.getMessage() + ' ~~ ' + ex.getLineNumber() + ' ~~ ' + ex.getCause());
        }

        return null;
    }

    @AuraEnabled
    public static String getUserProfile()
    {
        Profile currentUserProfile = [
                SELECT Name
                FROM Profile
                WHERE Id = :UserInfo.getProfileId()
        ];

        return currentUserProfile.Name;
    }

    @AuraEnabled
    public static String getSalesPortalAccessToken()
    {
        try
        {
            return SalesPortalAPI.authentificateOnSalesPortal(120000);
        }
        catch (Exception ex)
        {
            Utils.logException(ex);
            throw new AuraHandledException('Unable to log in to Sales Portal.');
        }
    }

    public class CreditAppWrapper
    {
        Credit_Application__c creditApp;
        Employment__c employment;
    }

    public class CA_RefreshException extends Exception {}

}