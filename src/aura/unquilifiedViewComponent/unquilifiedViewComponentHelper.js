({
    updateForm: function (component, offset, limit, addToExisted) {
        var getTotalRecordsCountAction = component.get('c.getTotalUnqualifiedRecordsCount');

        getTotalRecordsCountAction.setParams({
            days: component.get('v.lastDays')
        });

        var getTotalRecordsPromise = commonHelper.createPromise(component, getTotalRecordsCountAction);

        getTotalRecordsPromise.then(
            $A.getCallback(function (totalCount) {
                component.set('v.totalDatabaseRecordCount', totalCount);

                if (totalCount !== 0) {
                    var lastDays = component.get('v.lastDays');
                    var getUnqualifiedRecordsAction = component.get('c.getUnqualifiedRecords');

                    getUnqualifiedRecordsAction.setParams({
                        days: lastDays,
                        offsetRecords: offset,
                        limitRecords: limit
                    });

                    return commonHelper.createPromise(component, getUnqualifiedRecordsAction);
                }
            })
        ).then(
            $A.getCallback(function (unqualifiedRecords) {
                if (addToExisted) {
                    var newUnqualifiedList = component.get('v.unqualifiedRecords').concat(unqualifiedRecords);

                    component.set('v.unqualifiedRecords', newUnqualifiedList);
                } else {
                    component.set('v.unqualifiedRecords', unqualifiedRecords);
                }
                component.set('v.showSpinner', false);
            })
        ).catch(
            $A.getCallback(function (errorMessage) {
                debugger;
                component.set('v.showSpinner', false);
                if (errorMessage.indexOf('List has no rows for assignment to SObject') !== -1 ) {
                    commonHelper.showToast('There are no records in the queue at this time.', "dismissible", "warning");
                } else {
                    commonHelper.showToast(errorMessage, "", "error");
                }

            })
        );
    }
});