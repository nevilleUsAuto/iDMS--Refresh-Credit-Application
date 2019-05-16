({
	validateForm : function (component, joinCoBuyerFields) {
		console.log('validate');
		var section = component.get("v.currentSectionName");

		if (section == "optional-message") {
			return true;
		}

		if (section == "military-experience") {
			var buyer = component.get("v.buyer");
			var cobuyer = component.get("v.coBuyer");
			if (!buyer.Is_Military__c) {
				buyer.Military_Status__c = null;
			}
			if (joinCoBuyerFields && !cobuyer.Is_Military__c) {
				cobuyer.Military_Status__c = null;
			}
			component.set("v.isInit", true);
			component.set("v.buyer", buyer);
			component.set("v.coBuyer", cobuyer);
			component.set("v.isInit", false);
		}

		var creditApplication = component.get("v.creditApplication");
		if (section == "repeat-customer" && (creditApplication.Repeat_Customer__c == "No" || creditApplication.Co_App_Repeat_Customer__c == "No")) {
			var valid = false;
			if (creditApplication.Repeat_Customer__c == "No") {
				creditApplication.Repeat_Reason__c = null;
				creditApplication.Previous_Account_Number__c = null;
				valid = true;
			}
			else {
				valid = false;
			}

			if(joinCoBuyerFields && creditApplication.Co_App_Repeat_Customer__c == "No") {
				creditApplication.Co_App_Repeat_Reason__c = null;
				creditApplication.Co_App_Previous_Account_Number__c = null;
				valid = true;
			}
			else if(joinCoBuyerFields){
				valid = false;
			}

			component.set("v.isInit", true);
			component.set("v.creditApplication", creditApplication);
			component.set("v.isInit", false);

			if (valid) {
				return valid;
			}
		}

		var coBuyerInputSections = component.find("section-co-buyer");
		var buyerInputSections = component.find("section-buyer");
		var isFormValid = true;

		var sectionErrNames = ["current-housing-information-err", "previous-housing-information-err",
			"employment-information-err", "credit-history-err", "military-expirience-err", "repeat-customer-err"];

		if (!$A.util.isEmpty(buyerInputSections)) {
            for (var currentSectionIndex = 0; currentSectionIndex < buyerInputSections.length; currentSectionIndex++) {
                var isValid = true;
                var buyerComponents = [];
                var coBuyerComponents = [];

                var inputs = buyerInputSections[currentSectionIndex].find({ instancesOf : "lightning:input" });

                if (joinCoBuyerFields) {
					Array.prototype.push.apply(coBuyerComponents, coBuyerInputSections[currentSectionIndex].find({ instancesOf : "lightning:select" }));
					Array.prototype.push.apply(coBuyerComponents, coBuyerInputSections[currentSectionIndex].find({ instancesOf : "lightning:input" }));
				}
                Array.prototype.push.apply(buyerComponents, buyerInputSections[currentSectionIndex].find({ instancesOf : "lightning:input" }));
                Array.prototype.push.apply(buyerComponents, buyerInputSections[currentSectionIndex].find({ instancesOf : "lightning:select" }));
                Array.prototype.push.apply(buyerComponents, buyerInputSections[currentSectionIndex].find({ instancesOf : "c:selectlist" }));
			//	var message = component.get("v.messageWhenNotReadyToSubmit");
				for (var i = 0; i < buyerComponents.length; i++) {
					try {

						if (buyerComponents[i].get("v.disabled") || buyerComponents[i].get("v.label") == "Current Address Duration (Months)" ||
																	buyerComponents[i].get("v.label") == "Previous Address Duration (Months)") {
							$A.util.removeClass(buyerComponents[i], "slds-has-error");
                            console.log('here in label ' + buyerComponents[i].get("v.label"));
							continue;
						}
                        
						if (!buyerComponents[i].get("v.validity")) {

							throw 'validityIsEmpty';
						}


						if (buyerComponents[i].isInstanceOf("lightning:input") || buyerComponents[i].isInstanceOf("lightning:select")) {
							if (!buyerComponents[i].get("v.validity").valid) {
                                console.log('not valid ' + buyerComponents[i].get("v.label"));
                                //message.push(buyerComponents[i].get("v.label"));
								isValid = false;
								if (component.get("v.errorsCanBeAdded")) {
									$A.util.addClass(buyerComponents[i], "slds-has-error");
								}
							} else {
								if (component.get("v.errorsCanBeAdded")) {
									$A.util.removeClass(buyerComponents[i], "slds-has-error");
								}
							}
						} else if (buyerComponents[i].isInstanceOf("c:selectlist")) {

						}

						if (buyerComponents[i].get("v.required") && $A.util.isEmpty(buyerComponents[i].get("v.value"))) {
							isValid = false;
							if (component.get("v.errorsCanBeAdded")) {
								$A.util.addClass(buyerComponents[i], "slds-has-error");
							}
							console.log('field is not filled: ' + buyerComponents[i].get("v.label"));
						//	message.push(buyerComponents[i].get("v.label"));

						} else {
							if (component.get("v.errorsCanBeAdded")) {
								$A.util.removeClass(buyerComponents[i], "slds-has-error");
							}
						}
						//component.set("v.messageWhenNotReadyToSubmit", message);
					} catch(exception) {
						//throw exception;
						if(exception === 'validityIsEmpty') {
							console.log('validityIsEmpty');
						//	isFormValid = false;
							continue;
						} else {
							isFormValid = false;
							throw exception;
						}
					}
				}

                var sectionError = component.find(sectionErrNames[currentSectionIndex]);

                if (!isValid) {
                 //   sectionError.set("v.isTrue", false);
                    $A.util.addClass(sectionError, "slds-is-active");
                    isFormValid = false;
                } else { $A.util.removeClass(sectionError, "slds-is-active");
                 //   sectionError.set("v.isTrue", true);
                }
            }
		}


		var references = component.find("references");
        var inputs = [];
		if (!$A.util.isEmpty(references)) {
			/*console.log(JSON.stringify(references));
			Array.prototype.push.apply(inputs, references[0].find({instancesOf: "lightning:input"}));

			for (var i = 0; i < inputs.length; i++) {
				if (inputs[i].get("v.required") && $A.util.isEmpty(inputs[i].get("v.value"))) {
					isFormValid = false;
					$A.util.addClass(inputs[i], "slds-has-error");
					console.log('field is not filled: ' + inputs[i].get("v.label"));
				} else {
					$A.util.removeClass(inputs[i], "slds-has-error");
				}
			}*/
		}
        /*var errorMessageComponents = component.find("error-message-item");
        errorMessageComponents.forEach(function (currentComponent, i, arr) {
            currentComponent.set("v.isTrue", !isValid);
        });*/

		return isFormValid;
	},

	checkCoBuyerFilling : function (component) {
		var wasFilled = false;
		var coBuyerInputSections = component.find("section-co-buyer");
		console.log("size = " + coBuyerInputSections.length);
		var coBuyerComponents = [];

		for (var currentSectionIndex = 0; currentSectionIndex < coBuyerInputSections.length; currentSectionIndex++) {
			console.log("here1 juhu- " + coBuyerInputSections[currentSectionIndex]);
			var inputs = coBuyerInputSections[currentSectionIndex].find({instancesOf: "lightning:input"});
			var selects = coBuyerInputSections[currentSectionIndex].find({instancesOf: "lightning:select"});
			var checkBoxes = coBuyerInputSections[currentSectionIndex].find({instancesOf: "ui:inputCheckbox"});
			Array.prototype.push.apply(coBuyerComponents, inputs);
			Array.prototype.push.apply(coBuyerComponents, selects);
			Array.prototype.push.apply(coBuyerComponents, checkBoxes);
		}

		for (var currentInputIndex = 0; currentInputIndex < coBuyerComponents.length; currentInputIndex++) {
			if (coBuyerComponents[currentInputIndex].get("v.value") != null && coBuyerComponents[currentInputIndex].get("v.value") != '') {
				wasFilled = true;
				break;
			}
		}

		for (var currentInputIndex = 0; currentInputIndex < coBuyerComponents.length; currentInputIndex++) {
			if (!wasFilled) {
				$A.util.removeClass(coBuyerComponents[currentInputIndex], "slds-has-error");
			}
		}

		return wasFilled;
	},

	handleReferencesChange : function (component, event) {
		var references = component.get("v.referencesList");
		var validationMap = component.get("v.readyToSubmitSections");
		var isValid = true;

		if (references.length < 4) {
			isValid = false;
		}
		else {
			var section = component.find("section-references");

			if (!$A.util.isEmpty(section)) {
				var inputs = section.find({ instancesOf : "lightning:input" });

				for (var i = 0; i < inputs.length; i++) {
					if ((inputs[i].get("v.required") && $A.util.isEmpty(inputs[i].get("v.value"))) ||
						(!inputs[i].get("v.validity").valid)) {
						isValid = false;
					}
				}
			}
		}
		validationMap.references = isValid;
		component.set("v.readyToSubmitSections", validationMap);
	},

	showSpinner : function(component, event) {
		var popovers = component.find("box-container").find({instancesOf : "c:popover"});

		for (var i = 0; i < popovers.length; i++) {
			popovers[i].set("v.isVisible", false);
		}

		var actionSpinner = component.find("action-spinner");
		//actionSpinner.set("v.isTrue", true);
	},

	hideSpinner : function(component, event) {
		var actionSpinner = component.find("action-spinner");
		actionSpinner.set("v.isTrue", false);
	}

});