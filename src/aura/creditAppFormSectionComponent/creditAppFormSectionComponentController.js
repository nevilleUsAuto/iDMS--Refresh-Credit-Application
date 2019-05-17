({
	init : function (component, event, helper) {
		component.set('v.showSpinner', true);
		console.log('init');
		component.set('v.isInitComplete', false);
		var getPicklistsAction = component.get("c.getAllPicklistsByName");
		var getPickListsAction = commonHelper.createPromise(component, getPicklistsAction);
		getPickListsAction.then(
			$A.getCallback(function(picklists){
				component.set("v.picklists", JSON.parse(picklists));

				var getCreditApplicationAction = component.get("c.getCreditApplication");
				getCreditApplicationAction.setParams({
					opportunityId : component.get("v.recordId")
				});

				return commonHelper.createPromise(component, getCreditApplicationAction);
			})
		).then(
			$A.getCallback(function (response) {
				var wrapper = JSON.parse(response);

				debugger;
				component.set("v.buyer", wrapper.buyer);
				component.set("v.creditApplication", wrapper.creditApplication);
				component.set("v.employment", wrapper.currentEmployment);
				component.set("v.previousEmployment", wrapper.previousEmployment);
				component.set("v.coAppEmployment", wrapper.coAppCurrentEmployment);
				component.set("v.previousCoAppEmployment", wrapper.coAppPreviousEmployment);
				component.set("v.residence", wrapper.currentHousing);
				component.set("v.previousResidence", wrapper.previousHousing);
				component.set("v.coAppResidence", wrapper.coAppCurrentHousing);
				component.set("v.previousCoAppResidence", wrapper.coAppPreviousHousing);
				component.set("v.referencesList", wrapper.references);
				
                /* NB: 2019 02 27 -- REMOVED '&& wrapper.coBuyer.Id == null' TO ALLOW editing on Initial Paycall status regardless.
                 * 
                 * if (wrapper.creditApplication.Credit_Application_Status__c == "In Progress" ||
						((wrapper.creditApplication.Credit_Application_Status__c == "Initial Paycall" ||
						wrapper.creditApplication.Credit_Application_Status__c == "Letter Printed") && wrapper.coBuyer.Id == null) ||
						wrapper.creditApplication.Credit_Application_Status__c == "Conditionally Scored"||
						wrapper.creditApplication.Credit_Application_Status__c == "Incomplete") {
                */
				if (wrapper.creditApplication.Credit_Application_Status__c == "In Progress" ||
						((wrapper.creditApplication.Credit_Application_Status__c == "Initial Paycall" ||
						wrapper.creditApplication.Credit_Application_Status__c == "Letter Printed") ) ||
						wrapper.creditApplication.Credit_Application_Status__c == "Conditionally Scored"||
						wrapper.creditApplication.Credit_Application_Status__c == "Incomplete") {

					component.set("v.creditAppCanBeEdited", true);
				}

				if (wrapper.coBuyer.Id != null) {
					component.set("v.isCoBuyerExist", true);
					component.set("v.coBuyer", wrapper.coBuyer);
				} else {
				//	component.set("v.coAppEmployment", null);
				//	component.set("v.previousCoAppEmployment", null);
				//	component.set("v.coAppResidence", null);
				//	component.set("v.previousCoAppResidence", null);
					component.set("v.previousCoBuyerEmployerDisabled", true);
					component.set("v.previousCoBuyerAddressDisabled", true);
					component.set("v.coBuyerMilitaryDisabled", true);
				}

				if (!$A.util.isEmpty(wrapper.currentHousing.Address_Duration_Years__c) && (wrapper.currentHousing.Address_Duration_Years__c > 5 ||
					wrapper.currentHousing.Address_Duration_Years__c == '10+')) {
					component.set("v.previousBuyerAddressDisabled", true);
					component.set("v.previousResidence", null);
				}

				if (!$A.util.isEmpty(wrapper.coAppCurrentHousing.Address_Duration_Years__c) && (wrapper.coAppCurrentHousing.Address_Duration_Years__c > 5 ||
					wrapper.coAppCurrentHousing.Address_Duration_Years__c == '10+')) {
					component.set("v.previousCoBuyerAddressDisabled", true);
					component.set("v.previousCoAppResidence", null);
				}

				if (!$A.util.isEmpty(wrapper.currentEmployment.Employer_Duration_Years__c) && (wrapper.currentEmployment.Employer_Duration_Years__c > 5 ||
					wrapper.currentEmployment.Employer_Duration_Years__c == '10+')) {
					component.set("v.previousBuyerEmployerDisabled", true);
					component.set("v.previousEmployment", null);
				}

				if (!$A.util.isEmpty(wrapper.coAppCurrentEmployment.Employer_Duration_Years__c) && (wrapper.coAppCurrentEmployment.Employer_Duration_Years__c > 5 ||
					wrapper.coAppCurrentEmployment.Employer_Duration_Years__c == '10+')) {
					component.set("v.previousCoBuyerEmployerDisabled", true);
					component.set("v.previousCoAppEmployment", null);
				}

				if (wrapper.buyer.Is_Military__c) {
					component.set("v.buyerMilitaryDisabled", false);
				}

				if (wrapper.coBuyer.Is_Military__c) {
					component.set("v.coBuyerMilitaryDisabled", false);
				}

				if (!$A.util.isEmpty(wrapper.creditApplication.Valid_Sections__c)) {
					var validSections = wrapper.creditApplication.Valid_Sections__c.trim().split(' ');
					var readyToSubmitSections = component.get("v.readyToSubmitSections");

					console.log('test');
					console.log(validSections);

					for (var value in readyToSubmitSections) {
						if ( (value == 'previous-housing' && component.get("v.previousBuyerAddressDisabled") && component.get("v.previousCoBuyerAddressDisabled")) ||
							(value == 'previous-employment' && component.get("v.previousBuyerEmployerDisabled") && component.get("v.previousCoBuyerEmployerDisabled")) ||
							(validSections.includes(value))) {
							readyToSubmitSections[value] = true;
						}
					}
					component.set("v.readyToSubmitSections", readyToSubmitSections);
				}
				component.set("v.isInit", false);
				component.set('v.isInitComplete', true);  // NB:2019-04-25

				$A.get('e.force:refreshView').fire();
				component.set('v.showSpinner', false);
			})
		).catch(
			$A.getCallback(function(errorMessage) {
				commonHelper.showToast(errorMessage, "sticky", "error");
				component.set("v.isInit", false);
				component.set('v.showSpinner', false);
			})
		);
	},

	setValidPhoneFormat : function(component, event, helper) {
		var editablePhoneValuePattern = new RegExp("^[0-9]{10}$");

		var sourceComponent = event.getSource();
		var phoneValue = sourceComponent.get("v.value");

		if (editablePhoneValuePattern.test(phoneValue)) {
			sourceComponent.set("v.value", phoneValue.substring(0, 3) + "-" + phoneValue.substring(3, 6) + "-" + phoneValue.substring(6, 10));
		}
	},

	validateLicenseExpirationDate : function(component, event, helper) {
		var licenseExpirationDateInput = event.getSource();

		var licenseExpirationDate = licenseExpirationDateInput.get("v.value");
		var today = new Date()

		if (licenseExpirationDate < today) {
			licenseExpirationDateInput.set("v.validity", {valid : false, badInput : true});
		}
	},

	handlePreviousBuyerAddressEnabling : function (component, event, helper) {

		if(!component.get("v.isInit"))
		{

			var buyerAddress = component.get("v.residence");
			if (buyerAddress.Address_Duration_Years__c > 5 ||
				buyerAddress.Address_Duration_Years__c == '10+') {
				var previousHousingInputs = component.find("buyer-previous-housing");
				$A.util.removeClass(previousHousingInputs, "slds-has-error");
				//component.set("v.previousResidence", null);
				component.set("v.previousBuyerAddressDisabled", true);
			} else  if (component.get("v.previousBuyerAddressDisabled")){
				component.set("v.previousResidence", {
					sObjectType : "Residence__c",
					Is_Current_Residence__c : false,
					Is_Primary_Buyer__c : true,
					Housing_Type__c : "",
					House_Number__c : "",
					Address_Street__c : "",
					Address_Street_Type__c : "",
					Address_City__c : "",
					Address_State__c : "",
					Address_Zip__c : "",
					Home_Payment__c : "",
					Address_Duration_Years__c : "",
					Address_Duration_Months__c : "0"
				});
				component.set("v.previousBuyerAddressDisabled", false);
			}

			var sectionName = component.get("v.currentSectionName");
			var isValid = false;
			isValid = helper.validateForm(component, component.get('v.isCoBuyerExist'));
			var validationMap = component.get("v.readyToSubmitSections");
			validationMap[sectionName] = isValid;
			component.set("v.readyToSubmitSections", validationMap);
		}
	},

	handlePreviousCoBuyerAddressEnabling : function (component, event, helper) {
		if(!component.get("v.isInit"))
		{
			var previousCoBuyerAddress = component.get("v.coAppResidence");

			if (component.get("v.isCoBuyerExist") && previousCoBuyerAddress.Address_Duration_Years__c > 5 ||
				previousCoBuyerAddress.Address_Duration_Years__c == '10+') {
				var previousHousingInputs = component.find("cobuyer-previous-housing");
				$A.util.removeClass(previousHousingInputs, "slds-has-error");
				//component.set("v.previousCoAppResidence", null);
				component.set("v.previousCoBuyerAddressDisabled", true);
			} else if (component.get("v.isCoBuyerExist") && component.get("v.previousCoBuyerAddressDisabled")){
				component.set("v.previousCoAppResidence", {
					sObjectType : "Residence__c",
					Is_Current_Residence__c : false,
					Is_Primary_Buyer__c : false,
					Housing_Type__c : "",
					House_Number__c : "",
					Address_Street__c : "",
					Address_Street_Type__c : "",
					Address_City__c : "",
					Address_State__c : "",
					Address_Zip__c : "",
					Home_Payment__c : "",
					Address_Duration_Years__c : "",
					Address_Duration_Months__c : "0"
				});
				component.set("v.previousCoBuyerAddressDisabled", false);
			}

			var sectionName = component.get("v.currentSectionName");
			var isValid = false;
			isValid = helper.validateForm(component, component.get('v.isCoBuyerExist'));
			var validationMap = component.get("v.readyToSubmitSections");
			validationMap[sectionName] = isValid;
			component.set("v.readyToSubmitSections", validationMap);
		}
	},

	handlePreviousBuyerEmployerEnabling : function (component, event, helper) {
		if(!component.get("v.isInit")) {
			var buyerEmployer = component.get("v.employment");

			if (buyerEmployer.Employer_Duration_Years__c > 5 ||
				buyerEmployer.Employer_Duration_Years__c == '10+') {
				var previousHousingInputs = component.find("buyer-previous-employer");
				$A.util.removeClass(previousHousingInputs, "slds-has-error");
				//component.set("v.previousEmployment", null);
				component.set("v.previousBuyerEmployerDisabled", true);
			} else if (component.get("v.previousBuyerEmployerDisabled")){
				component.set("v.previousEmployment", {
					sObjectType: "Employment__c",
					Is_Primary_Buyer__c: true,
					Is_Current_Employment__c: false,
					Employer_Name__c: "",
					Employer_Street__c: "",
					Employer_City__c: "",
					Employer_State__c: "",
					Employer_Zip__c: "",
					Occupation_Or_Rank__c: "",
					Employer_Phone__c: "",
					Salary_Type__c: "",
					Other_Income__c: "",
					Employer_Duration_Years__c: "",
					Employer_Duration_Months__c: "0"
				});
				component.set("v.previousBuyerEmployerDisabled", false);
			}

			var sectionName = component.get("v.currentSectionName");
			var isValid = false;
			isValid = helper.validateForm(component, component.get('v.isCoBuyerExist'));
			var validationMap = component.get("v.readyToSubmitSections");
			validationMap[sectionName] = isValid;
			component.set("v.readyToSubmitSections", validationMap);
		}
	},

	handlePreviousCoBuyerEmployerEnabling : function (component, event, helper) {
		if(!component.get("v.isInit")) {
			var coBuyerEmployer = component.get("v.coAppEmployment");

			console.log(coBuyerEmployer.Employer_Duration_Years__c);
            console.log(component.get("v.isCoBuyerExist"));

			if (component.get("v.isCoBuyerExist") && coBuyerEmployer.Employer_Duration_Years__c > 5 ||
				coBuyerEmployer.Employer_Duration_Years__c == '10+') {
				var previousHousingInputs = component.find("cobuyer-previous-employer");
				$A.util.removeClass(previousHousingInputs, "slds-has-error");
				//component.set("v.previousCoAppEmployment", null);
                console.log('here1');
				component.set("v.previousCoBuyerEmployerDisabled", true);
			} else if (component.get("v.isCoBuyerExist") && component.get("v.previousCoBuyerEmployerDisabled")){
                console.log('here2');
				component.set("v.previousCoAppEmployment", {
					sObjectType: "Employment__c",
					Is_Primary_Buyer__c: false,
					Is_Current_Employment__c: false,
					Employer_Name__c: "",
					Employer_Street__c: "",
					Employer_City__c: "",
					Employer_State__c: "",
					Employer_Zip__c: "",
					Occupation_Or_Rank__c: "",
					Employer_Phone__c: "",
					Salary_Type__c: "",
					Other_Income__c: "",
					Employer_Duration_Years__c: "",
					Employer_Duration_Months__c: "0"
				});
				component.set("v.previousCoBuyerEmployerDisabled", false);
			}

			var sectionName = component.get("v.currentSectionName");
			var isValid = false;
			isValid = helper.validateForm(component, component.get('v.isCoBuyerExist'));
			var validationMap = component.get("v.readyToSubmitSections");
			validationMap[sectionName] = isValid;
			component.set("v.readyToSubmitSections", validationMap);
		}
	},

	sectionButtonChange : function (component, t, helper) {
		var showMenu = component.find("show-menu");
		var isOpen = $A.util.hasClass(showMenu, "slds-is-open");

		if (isOpen) {
			$A.util.removeClass(showMenu, "slds-is-open");
		} else {
			$A.util.addClass(showMenu, "slds-is-open");
		}
	},

	sectionBuyerChange : function (component, event, helper) {
	    console.log('here0');

		var tabBuyer = [];
		var tabCoBuyer = [];
		var sectionBuyer = [];
		var sectionCoBuyer = [];
		if ($A.util.isArray(component.find('tab-buyer'))) {
			Array.prototype.push.apply(tabBuyer,component.find('tab-buyer'));
		} else {
			tabBuyer.push(component.find('tab-buyer'));
		}
		if ($A.util.isArray(component.find('tab-co-buyer'))) {
			Array.prototype.push.apply(tabCoBuyer,component.find('tab-co-buyer'));
		}else {
			tabCoBuyer.push(component.find('tab-co-buyer'));
		}
		if ($A.util.isArray(component.find('section-buyer'))) {
			Array.prototype.push.apply(sectionBuyer,component.find('section-buyer'));
		}else {
			sectionBuyer.push(component.find('section-buyer'));
		}
		if ($A.util.isArray(component.find('section-co-buyer'))) {
			tabBuyer = [];
			Array.prototype.push.apply(sectionCoBuyer, component.find('section-co-buyer'));
		}else {
			sectionCoBuyer.push(component.find('section-co-buyer'));
		}

		if (event.target.id === 'buyer-ref-section' &&
			(component.get("v.currentSectionName") != 'previous-housing' || component.get("v.currentSectionName") != 'previous-employment')) {
			if (!$A.util.hasClass(tabBuyer[0], 'slds-is-active')) {
				$A.util.addClass(tabBuyer[0], 'slds-is-active');
				$A.util.removeClass(sectionBuyer[0], 'slds-hide')
				$A.util.addClass(sectionBuyer[0], 'slds-show');
				$A.util.removeClass(tabCoBuyer[0], 'slds-is-active');
				$A.util.removeClass(sectionCoBuyer[0], 'slds-show');
				$A.util.addClass(sectionCoBuyer[0], 'slds-hide');
			}
		} else if (event.target.id === 'co-buyer-ref-section' &&
			(component.get("v.currentSectionName") != 'previous-housing' || component.get("v.currentSectionName") != 'previous-employment')) {
			if (!$A.util.hasClass(tabCoBuyer[0], 'slds-is-active')) {

				$A.util.removeClass(tabBuyer[0], 'slds-is-active');
				$A.util.removeClass(sectionBuyer[0], 'slds-show');
				$A.util.addClass(sectionBuyer[0], 'slds-hide');

				$A.util.addClass(tabCoBuyer[0], 'slds-is-active');
				$A.util.removeClass(sectionCoBuyer[0], 'slds-hide');
				$A.util.addClass(sectionCoBuyer[0], 'slds-show');
			}
		}
	},

	navigateToComponentSection : function(component, event, helper) {
		var selectedMenuItemValue = event.getParam("value");
		component.set("v.currentSectionName", selectedMenuItemValue);

		var index = 0;
		for(var value of component.get("v.menuItems")) {
			if (value == selectedMenuItemValue) {
				component.set("v.menuIndex", index);
			}
			else {
				index++;
			}
		}
	},

	openPreviousSection : function(component, event, helper) {
		var index = component.get("v.menuIndex");
		index--;
		if ( (component.get("v.currentSectionName") == 'current-employment' && component.get("v.previousBuyerAddressDisabled") && component.get("v.previousCoBuyerAddressDisabled")) ||
			(component.get("v.currentSectionName") == 'references' && component.get("v.previousBuyerEmployerDisabled") && component.get("v.previousCoBuyerEmployerDisabled"))) {
			index--;
		}
		component.set("v.menuIndex", index);
		component.set("v.currentSectionName", component.get("v.menuItems")[index]);
	},

	openNextSection : function(component, event, helper) {
		var index = component.get("v.menuIndex");
		index++;
		if ( (component.get("v.currentSectionName") == 'current-housing' && component.get("v.previousBuyerAddressDisabled") && component.get("v.previousCoBuyerAddressDisabled")) ||
			(component.get("v.currentSectionName") == 'current-employment' && component.get("v.previousBuyerEmployerDisabled") && component.get("v.previousCoBuyerEmployerDisabled"))) {
			index++;
		}
		component.set("v.menuIndex", index);
		component.set("v.currentSectionName", component.get("v.menuItems")[index]);

        /*if (component.get("v.isCoBuyerExist")) {
            if (component.get("v.currentSectionName") == 'previous-housing') {
                if (!component.get("v.previousResidence"))
                {
                    //setTimeout(function() {
                    var sectionBuyer = component.find('section-buyer')[0];
                        var tabCoBuyer = component.find('tab-co-buyer')[0];
                        console.log(tabCoBuyer);

                        var sectionCoBuyer = component.find('section-co-buyer')[0];
                        console.log(sectionCoBuyer);

                        $A.util.addClass(tabCoBuyer, 'slds-is-active');
                        $A.util.removeClass(sectionCoBuyer, 'slds-hide');
                        $A.util.addClass(sectionCoBuyer, 'slds-show');

                        $A.util.removeClass(sectionBuyer, 'slds-show');
                        $A.util.addClass(sectionBuyer, 'slds-hide');

                        console.log("finished");
                    //}, 1000);

                	console.log('here11');


                }
            }
            if (component.get("v.currentSectionName") == 'previous-employment') {
                if (!component.get("v.previousEmployment"))
				{

				}
            }
        }*/

	},

	addNewReference : function (component, event, helper){
		var references = component.get("v.referencesList");
		var newReference = {
			"sObjectType" : "Contact",
			"FirstName": "",
			"LastName": "",
			"Phone": "",
			"MailingStreet": "",
			"MailingCity": "",
			"MailingState": "",
			"MailingPostalCode": ""
		};
		references.push(newReference);
		component.set("v.referencesList", references);
	},

	removeReference : function(component, event, helper){
		var rowIndex = event.target.id;
		var references = component.get("v.referencesList");
		var removedRefs = component.get("v.removedReferences");

		if (!$A.util.isEmpty(references[rowIndex].Id)) {
			removedRefs.push(references[rowIndex]);
			component.set("v.removedReferences", removedRefs);
		}
		references.splice(rowIndex, 1);
		component.set("v.referencesList", references);
	},

	addCoBuyer : function (component, event, helper) {
		if (component.get('v.isCoBuyerExist')) {
			component.set("v.deleteCoBuyerModal", true);
			component.set('v.addCobuyerModal', false);
		} else {
			component.set('v.addCobuyerModal', true);
		}
	},

	searchCobuyer : function (component, event, helper) {
		component.set("v.searchResult", null);
		var searchForCustomerAction = component.get("c.getAccountsBySocialSecurityNumber");

		searchForCustomerAction.setParams({
			"coBuyerSocialSecurityNumber" : component.get("v.coBuyerSocialSecurityNumber")
		});

		var searchForCustomerPromise = commonHelper.createPromise(component, searchForCustomerAction);

		searchForCustomerPromise.then(
			$A.getCallback(function(searchResult){
				if (searchResult != null) {
					component.set("v.searchResult", searchResult);
					component.find("save-button").set("v.disabled", !searchResult.canContinue);
				}
			})
		);
	},

	saveCoBuyer : function (component, event, helper) {
	    debugger;
		var coBuyer = component.get("v.searchResult").coBuyer;
		var creditApplication = component.get("v.creditApplication");

		coBuyer.SocialSecurityNumber__c = component.get("v.coBuyerSocialSecurityNumber");
		creditApplication.Co_Buyer__c = coBuyer.Id;
		component.set("v.creditApplication", creditApplication);
		component.set("v.coBuyer", coBuyer);
		component.set("v.addCobuyerModal", false);
		component.set('v.isCoBuyerExist', true);
		component.set("v.searchResult", null);

		if (component.get("v.coAppEmployment") == null) {
			component.set("v.coAppEmployment", {
				sObjectType: "Employment__c",
				Is_Primary_Buyer__c: false,
				Is_Current_Employment__c: true,
				Employer_Name__c: "",
				Employer_Street__c: "",
				Employer_City__c: "",
				Employer_State__c: "",
				Employer_Zip__c: "",
				Occupation_Or_Rank__c: "",
				Employer_Phone__c: "",
				Salary_Type__c: "",
				Other_Income__c: "",
				Employer_Duration_Years__c: "",
				Employer_Duration_Months__c: "0"
			});
		}
		if (component.get("v.previousCoAppEmployment") == null) {
			component.set("v.previousCoAppEmployment", {
				sObjectType: "Employment__c",
				Is_Primary_Buyer__c: false,
				Is_Current_Employment__c: false,
				Employer_Name__c: "",
				Employer_Street__c: "",
				Employer_City__c: "",
				Employer_State__c: "",
				Employer_Zip__c: "",
				Occupation_Or_Rank__c: "",
				Employer_Phone__c: "",
				Salary_Type__c: "",
				Other_Income__c: "",
				Employer_Duration_Years__c: "",
				Employer_Duration_Months__c: "0"
			});
		}
		if (component.get("v.coAppResidence") == null) {
			component.set("v.coAppResidence", {
				sObjectType: "Residence__c",
				Is_Current_Residence__c: true,
				Is_Primary_Buyer__c: false,
				Housing_Type__c: "",
				House_Number__c: "",
				Address_Street__c: "",
				Address_Street_Type__c: "",
				Address_City__c: "",
				Address_State__c: "",
				Address_Zip__c: "",
				Home_Payment__c: "",
				Address_Duration_Years__c: "",
				Address_Duration_Months__c: "0"
			});
		}
		if (component.get("v.previousCoAppResidence") == null) {
			component.set("v.previousCoAppResidence", {
				sObjectType: "Residence__c",
				Is_Current_Residence__c: false,
				Is_Primary_Buyer__c: false,
				Housing_Type__c: "",
				House_Number__c: "",
				Address_Street__c: "",
				Address_Street_Type__c: "",
				Address_City__c: "",
				Address_State__c: "",
				Address_Zip__c: "",
				Home_Payment__c: "",
				Address_Duration_Years__c: "",
				Address_Duration_Months__c: "0"
			});
		}
		component.set("v.previousCoBuyerAddressDisabled", false);
		component.set("v.previousCoBuyerEmployerDisabled", false);
		console.log("co-cobuyer" + JSON.stringify(component.get("v.coBuyer")));
		if (component.get("v.saveButtonClickedMode") && !component.get("v.isInit")) {
			helper.validateForm(component, true);
		}
	},

    tryToSaveCreditApplication1 : function (component, event, helper) {

		component.set('v.showSpinner', true);
        helper.handleReferencesChange(component, event);

		var validateWrapperAction = component.get("c.validateData");

		var empl = component.get("v.employment");
        var prevempl = component.get("v.previousEmployment");
        var res = component.get("v.residence");
        var prevres = component.get("v.previousResidence");

        if (!empl.Employer_Duration_Months__c) {
            empl.Employer_Duration_Months__c = '0';
        }
        if (prevempl) {
            if (!prevempl.Employer_Duration_Months__c) {
                prevempl.Employer_Duration_Months__c = '0';
            }
        }
        if (!res.Address_Duration_Months__c) {
            res.Address_Duration_Months__c = '0';
        }
        if (prevres) {
            if (!prevres.Address_Duration_Months__c) {
                prevres.Address_Duration_Months__c = '0';
            }
        }

        if (!empl.Employer_Duration_Years__c) {
            empl.Employer_Duration_Years__c = '0';
        }
        if (prevempl) {
            if (!prevempl.Employer_Duration_Years__c) {
                prevempl.Employer_Duration_Years__c = '0';
            }
        }
        if (!res.Address_Duration_Years__c) {
            res.Address_Duration_Years__c = '0';
        }
        if (prevres) {
            if (!prevres.Address_Duration_Years__c) {
                prevres.Address_Duration_Years__c = '0';
            }
        }

        debugger;
        component.set("v.employment", empl);
        component.set("v.previousEmployment", prevempl);
        component.set("v.residence", res);
        component.set("v.previousResidence", prevres);

        if (component.get("v.isCoBuyerExist")) {
            var coempl = component.get("v.coAppEmployment");
            var coprevempl = component.get("v.previousCoAppEmployment");
            var cores = component.get("v.coAppResidence");
            var coprevres = component.get("v.previousCoAppResidence");

            if (!coempl.Employer_Duration_Months__c) {
                coempl.Employer_Duration_Months__c = '0';
            }
            if (coprevempl) {
                if (!coprevempl.Employer_Duration_Months__c) {
                    coprevempl.Employer_Duration_Months__c = '0';
                }
            }
            if (!cores.Address_Duration_Months__c) {
                cores.Address_Duration_Months__c = '0';
            }
            if (coprevres) {
                if (!coprevres.Address_Duration_Months__c) {
                    coprevres.Address_Duration_Months__c = '0';
                }
            }

            if (!coempl.Employer_Duration_Years__c) {
                coempl.Employer_Duration_Years__c = '0';
            }
            if (coprevempl) {
                if (!coprevempl.Employer_Duration_Years__c) {
                    coprevempl.Employer_Duration_Years__c = '0';
                }
            }
            if (!cores.Address_Duration_Years__c) {
                cores.Address_Duration_Years__c = '0';
            }
            if (coprevres) {
                if (!coprevres.Address_Duration_Years__c) {
                    coprevres.Address_Duration_Years__c = '0';
                }
            }

            component.set("v.coAppEmployment", coempl);
            component.set("v.previousCoAppEmployment", coprevempl);
            component.set("v.coAppResidence", cores);
            component.set("v.previousCoAppResidence", coprevres);
        }


        var references = component.get("v.referencesList");
        for (var i = 0; i < references.length; i++) {
            if ($A.util.isEmpty(references[i].FirstName) || $A.util.isEmpty(references[i].LastName)) {
                references.splice(i, 1);
            }
        }

        var creditApp = {
            creditApplication : component.get("v.creditApplication"),
            buyer : component.get("v.buyer"),
            currentEmployment : component.get("v.employment"),
            previousEmployment : component.get("v.previousEmployment"),
            currentHousing : component.get("v.residence"),
            previousHousing : component.get("v.previousResidence"),
            references : references,
            removedReferences : component.get("v.removedReferences"),
            isPrevBuyerHousingDeleted : false,
            isPrevCoBuyerHousingDeleted : false,
            isPrevBuyerEmploymentDeleted : false,
            isPrevCoBuyerEmploymentDeleted : false
        };

        if (component.get("v.isCoBuyerExist")) {
            creditApp.coBuyer = component.get("v.coBuyer");
            creditApp.coAppCurrentEmployment = component.get("v.coAppEmployment");
            creditApp.coAppPreviousEmployment = component.get("v.previousCoAppEmployment");
            creditApp.coAppCurrentHousing = component.get("v.coAppResidence");
            creditApp.coAppPreviousHousing = component.get("v.previousCoAppResidence");
        } else {
            creditApp.coBuyer = null;
            creditApp.coAppCurrentEmployment = null;
            creditApp.coAppPreviousEmployment = null;
            creditApp.coAppCurrentHousing = null;
            creditApp.coAppPreviousHousing = null;
        }

        if (component.get("v.previousBuyerAddressDisabled")) {
            console.log('previousBuyerAddressDisabled');
            creditApp.isPrevBuyerHousingDeleted = true;
        }

        if (component.get("v.previousCoBuyerAddressDisabled")) {
            creditApp.isPrevCoBuyerHousingDeleted = true;
        }

        if (component.get("v.previousBuyerEmployerDisabled")) {
            console.log('previousBuyerEmployerDisabled');
            creditApp.isPrevBuyerEmploymentDeleted = true;
        }

        if (component.get("v.previousCoBuyerEmployerDisabled")) {
            creditApp.isPrevCoBuyerEmploymentDeleted = true;
        }

        var wrapper = JSON.stringify(creditApp);

		validateWrapperAction.setParams({
            wrapperJSON : wrapper
		});

		var validateWrapperPromise = commonHelper.createPromise(component, validateWrapperAction);

		validateWrapperPromise.then(
			$A.getCallback(function(invalidFields){
                helper.handleReferencesChange(component, event);

                var readyToSubmitSections = component.get("v.readyToSubmitSections");
                var creditApp = component.get("v.creditApplication");
                var isFormValid = true;
                var validSections = [];
                var sectionLabels = component.get("v.sectionLables");


                if (invalidFields.buyerFields.length != 0 || invalidFields.coBuyerFields.length != 0)
                {
                    isFormValid = false;
                }

                component.set("v.isFormValid", isFormValid);
				component.set("v.invalidFields", invalidFields);
                component.set("v.finishEditModal", true);
                component.set("v.saveButtonClickedMode", true);
                component.set("v.creditApplication", creditApp);
				component.set('v.showSpinner', false);
				console.log(invalidFields);
			})
		).catch(
            $A.getCallback(function(error){
            	console.log(error);
            })
		);
	},

	tryToSaveCreditApplication : function (component, event, helper) {
		component.set('v.showSpinner', true);
		helper.handleReferencesChange(component, event);

		var readyToSubmitSections = component.get("v.readyToSubmitSections");
		var creditApp = component.get("v.creditApplication");
		var isFormValid = true;
		var validSections = [];
		var sectionLabels = component.get("v.sectionLables");
		var messageWhenInvalid = [];
		console.log(JSON.stringify(readyToSubmitSections));

		for (var value in readyToSubmitSections) {
			if ( (value == 'previous-housing' && component.get("v.previousBuyerAddressDisabled") && component.get("v.previousCoBuyerAddressDisabled")) ||
				(value == 'previous-employment' && component.get("v.previousBuyerEmployerDisabled") && component.get("v.previousCoBuyerEmployerDisabled"))) {
				readyToSubmitSections[value] = true;
			}
			console.log(value + ' ' + readyToSubmitSections[value]);

			if (!readyToSubmitSections[value]) {
				isFormValid = false;
				messageWhenInvalid.push(sectionLabels[value]);
			} else {
				validSections.push(value);
			}
		}

		creditApp.Valid_Sections__c = Array.from(validSections).join(' ');
		component.set("v.isFormValid", isFormValid);
		component.set("v.finishEditModal", true);
		component.set("v.saveButtonClickedMode", true);
		component.set("v.creditApplication", creditApp);
		component.set("v.messageWhenNotReadyToSubmit", messageWhenInvalid);
		component.set('v.showSpinner', false);
	},

	finishSaveCreditApplication : function (component, event, helper) {
		component.set('v.showSpinner', true);

		var references = component.get("v.referencesList");
		for (var i = 0; i < references.length; i++) {
			if ($A.util.isEmpty(references[i].FirstName) || $A.util.isEmpty(references[i].LastName)) {
				references.splice(i, 1);
			}
		}

		var finishSaveCreditApplicationAction = component.get("c.saveCreditApplication");
		var creditApp = {
			creditApplication : component.get("v.creditApplication"),
			buyer : component.get("v.buyer"),
			currentEmployment : component.get("v.employment"),
			previousEmployment : component.get("v.previousEmployment"),
			currentHousing : component.get("v.residence"),
			previousHousing : component.get("v.previousResidence"),
			references : references,
			removedReferences : component.get("v.removedReferences"),
			isPrevBuyerHousingDeleted : false,
			isPrevCoBuyerHousingDeleted : false,
			isPrevBuyerEmploymentDeleted : false,
			isPrevCoBuyerEmploymentDeleted : false
		};

		if (component.get("v.isCoBuyerExist")) {
			creditApp.coBuyer = component.get("v.coBuyer");
			creditApp.coAppCurrentEmployment = component.get("v.coAppEmployment");
			creditApp.coAppPreviousEmployment = component.get("v.previousCoAppEmployment");
			creditApp.coAppCurrentHousing = component.get("v.coAppResidence");
			creditApp.coAppPreviousHousing = component.get("v.previousCoAppResidence");
		} else {
			creditApp.coBuyer = null;
			creditApp.coAppCurrentEmployment = null;
			creditApp.coAppPreviousEmployment = null;
			creditApp.coAppCurrentHousing = null;
			creditApp.coAppPreviousHousing = null;
		}

		if (component.get("v.previousBuyerAddressDisabled")) {
			creditApp.isPrevBuyerHousingDeleted = true;
		}

		if (component.get("v.previousCoBuyerAddressDisabled")) {
			creditApp.isPrevCoBuyerHousingDeleted = true;
		}

		if (component.get("v.previousBuyerEmployerDisabled")) {
			creditApp.isPrevBuyerEmploymentDeleted = true;
		}

		if (component.get("v.previousCoBuyerEmployerDisabled")) {
			creditApp.isPrevCoBuyerEmploymentDeleted = true;
		}

		var wrapper = JSON.stringify(creditApp);
		finishSaveCreditApplicationAction.setParams({
			creditAppJSON : wrapper,
			isReadyToSubmit : component.get("v.isFormValid")
		});

		var finishSaveCreditApplicationPromise = commonHelper.createPromise(component, finishSaveCreditApplicationAction);
		finishSaveCreditApplicationPromise.then(
			$A.getCallback(function(opportunityId){
				commonHelper.showToast("App Saved!", "sticky", "success");
				var redirectToSalesUpEvent = $A.get("e.force:navigateToSObject");

				redirectToSalesUpEvent.setParams({
					"recordId" : opportunityId,
					"slideDevName": "detail"
				});

				redirectToSalesUpEvent.fire();
				if (component.get("v.isFormValid")) {
					component.set("v.appBoxToBeReloaded", true);
				}
			})
		).catch(
			$A.getCallback(function(errorMessage) {
				commonHelper.showToast(errorMessage, "sticky", "error");
				component.set('v.showSpinner', false);
			})
		);
	},

	handleCustomerChange : function (component, event, helper) {
		var isValid = event.getSource().get("v.isCardValid");
		var sections = component.get("v.readyToSubmitSections");
		sections.personal = isValid;
		component.set("v.readyToSubmitSections", sections);
	},

	fixInputField : function (component, event, helper, type) {
		if (event.getSource().get("v.validity").valid) {
			$A.util.removeClass(event.getSource(), "slds-has-error");
		}
	},

	validateSocialSecurityNumber : function(component, event, helper) {
		var ssnFormatWithNoDashes = new RegExp("^[0-9]{9}$");
		var socialSecurityNumberInput = event.getSource();

		if (!socialSecurityNumberInput.get("v.validity").valid) {
			component.find("search-button").set("v.disabled", true);
			return;
		} else {
			var inputValue = socialSecurityNumberInput.get("v.value");

			if (inputValue == component.get("v.buyer").SocialSecurityNumber__c) {
				component.find("search-button").set("v.disabled", true);
				socialSecurityNumberInput.set('v.validity', {valid:false, badInput :true});
				return;
			}

			if (ssnFormatWithNoDashes.test(inputValue)) {
				socialSecurityNumberInput.set("v.value", inputValue.substring(0, 3) + "-" + inputValue.substring(3, 5) + "-" + inputValue.substring(5, 9));
			}
		}

		component.find("search-button").set("v.disabled", false);
	},

	handleValidation : function (component, event, helper) {
		var sectionName = component.get("v.currentSectionName");
		if (!component.get("v.isInit") && sectionName != 'personal') {

			var isValid = false;
			if (component.get("v.isCoBuyerExist")) {
				isValid = helper.validateForm(component, true);
			} else {
				isValid = helper.validateForm(component, false);
			}
			var validationMap = component.get("v.readyToSubmitSections");
			validationMap[sectionName] = isValid;
			component.set("v.readyToSubmitSections", validationMap);
		}
	},

	handleReferencesChange : function (component, event, helper) {
		helper.handleReferencesChange(component, event);
	},

	backToSalesUp : function (component, event, helper) {
		var opportunityId = component.get("v.creditApplication").Opportunity__c;
		var redirectToOppEvent = $A.get("e.force:navigateToSObject");

		redirectToOppEvent.setParams({
			"recordId" : opportunityId,
			"slideDevName": "detail"
		});

		redirectToOppEvent.fire();
	},

	deleteCoBuyer : function (component, event, helper) {
		component.set("v.coBuyer", {sObjectType : "Contact"});
		var creditApplication = component.get("v.creditApplication");
		creditApplication.Co_Buyer__c = null;
		component.set("v.creditApplication", creditApplication);
		component.set("v.deleteCoBuyerModal", false);
		component.set("v.isCoBuyerExist", false);
		component.set("v.previousCoBuyerEmployerDisabled", true);
		component.set("v.previousCoBuyerAddressDisabled", true);
	},

	closeModal : function (component, event, helper) {
		component.set("v.addCobuyerModal", false);
		component.set("v.finishEditModal", false);
		component.set("v.deleteCoBuyerModal", false);

		if (event.target.Id == 'edit-now-button') {
			component.set("v.errorsCanBeAdded", true);
		}
	}
});