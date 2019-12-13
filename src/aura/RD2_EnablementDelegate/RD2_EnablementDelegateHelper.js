({
    /****
    * @description Loads the enablement state and enables/disables page elements based on it
    */
    loadState: function (component) {
        var action = component.get("c.loadState");

        action.setCallback(this, function (response) {
            if (!component.isValid()) {
                return;
            }
            const state = response.getState();

            if (state === "SUCCESS") {
                const enablementState = JSON.parse(response.getReturnValue());

                if (!enablementState.isReady && !enablementState.isEnabled) {
                    this.displayElement(component, "enablementDisabled");
                    return;
                }

                this.displayElement(component, "enabler");
                component.set('v.state', enablementState);

                this.refreshDryRun(component);
                this.refreshEnable(component);
                this.refreshMetaDeploy(component);
                this.refreshMigration(component);

            } else if (state === "ERROR") {
                this.handleError(component, response.getError());
            }
        });

        $A.enqueueAction(action);
    },
    /****
    * @description Confirms enhanced Recurring Donations enablement
    */
    confirmEnable: function (component) {
        //disable the current active step so the next step is enabled only on current step success
        component.set('v.state.hideDryRun', true);
        component.set('v.state.isConfirmed', false);
        this.showSpinner(component, 'enableConfirmSpinner');
        this.clearError(component);

        var action = component.get('c.confirmEnablement');

        action.setCallback(this, function (response) {
            if (!component.isValid()) {
                return;
            }
            const state = response.getState();

            if (state === 'SUCCESS') {
                component.set('v.state.isConfirmed', true);

            } else if (state === 'ERROR') {
                this.handleError(component, response.getError(), 'enablement');
            }

            this.refreshEnable(component);
            this.hideSpinner(component, 'enableConfirmSpinner');
        });

        $A.enqueueAction(action);
    },
    /****
    * @description Enables enhanced Recurring Donations 
    */
    completeEnable: function (component) {
        //disable the current active step so the next step is enabled only on current step success
        component.set('v.state.isEnabled', false);
        this.clearError(component);
        this.disableEdit(component, "enableToggle");

        var action = component.get('c.enableEnhancement');

        action.setCallback(this, function (response) {
            if (!component.isValid()) {
                return;
            }
            const state = response.getState();

            if (state === 'SUCCESS') {
                component.set('v.state.isEnabled', true);

            } else if (state === 'ERROR') {
                this.handleError(component, response.getError(), 'enablement');
            }

            this.refreshEnable(component);
            this.refreshMetaDeploy(component);

            // notify NPSP Settings page about enhanced Recurring Donation enablement
            var event = $A.get("e.c:RD2_EnhancementEnabledEvent");
            event.fire();
        });

        $A.enqueueAction(action);
    },
    /****
    * @description Loads the enablement state and enables/disables page elements based on it
    */
    getDeployURL: function (component) {
        var action = component.get("c.getMetaDeployURL");

        action.setCallback(this, function (response) {
            if (!component.isValid()) {
                return;
            }
            let state = response.getState();

            if (state === "SUCCESS") {
                const metaDeployURL = response.getReturnValue();
                component.set('v.metaDeployURL', metaDeployURL);

            } else if (state === "ERROR") {
                component.set('v.metaDeployURL', 'https://install.salesforce.org/products/npsp/npsp-rd2-pilot');
            }
        });

        $A.enqueueAction(action);
    },
    /****
    * @description Confirms MetaDeploy has been launched
    */
    launchDeploy: function (component) {
        this.clearError(component);

        var action = component.get('c.launchMetaDeploy');

        action.setCallback(this, function (response) {
            if (!component.isValid()) {
                return;
            }
            const state = response.getState();

            if (state === 'SUCCESS') {
                component.set('v.state.isMetaDeployLaunched', true);

            } else if (state === 'ERROR') {
                this.handleError(component, response.getError(), 'metadeploy');
            }

            this.refreshMetaDeploy(component);
        });

        $A.enqueueAction(action);

    },
    /****
    * @description Confirms MetaDeploy has been deployed
    */
    confirmDeploy: function (component) {
        //disable the current active step so the next step is enabled only on current step success
        component.set('v.state.isMetaDeployConfirmed', false);
        this.showSpinner(component, 'metadeployConfirmSpinner');

        this.clearError(component);

        var action = component.get('c.confirmMetaDeploy');

        action.setCallback(this, function (response) {
            if (!component.isValid()) {
                return;
            }
            const state = response.getState();

            if (state === 'SUCCESS') {
                component.set('v.state.isMetaDeployConfirmed', true);

            } else if (state === 'ERROR') {
                this.handleError(component, response.getError(), 'metadeploy');
            }

            this.refreshMetaDeploy(component);
            this.hideSpinner(component, 'metadeployConfirmSpinner');
        });

        $A.enqueueAction(action);
    },
    /****
    * @description Starts data migration batch in dry run mode
    */
    runDryRun: function (component) {
        component.set('v.state.isDryRunInProgress', true);
        component.set('v.dryRunBatch', null);

        this.clearError(component);

        var action = component.get('c.runDryRun');

        action.setCallback(this, function (response) {
            if (!component.isValid()) {
                return;
            }
            const state = response.getState();

            if (state === 'SUCCESS') {
                component.find('dryRunJob').handleLoadBatchJob();

            } else if (state === 'ERROR') {
                component.set('v.state.isDryRunInProgress', false);
                this.handleError(component, response.getError(), 'dryRun');
            }
        });

        $A.enqueueAction(action);
    },
    /****
    * @description Starts data migration batch
    */
    runMigration: function (component) {
        component.set('v.state.isMigrationInProgress', true);
        component.set('v.migrationBatch', null);

        this.clearError(component);

        var action = component.get('c.runMigration');

        action.setCallback(this, function (response) {
            if (!component.isValid()) {
                return;
            }
            const state = response.getState();

            if (state === 'SUCCESS') {
                component.find('migrationJob').handleLoadBatchJob();

            } else if (state === 'ERROR') {
                component.set('v.state.isMigrationInProgress', false);
                this.handleError(component, response.getError(), 'migration');
            }
        });

        $A.enqueueAction(action);
    },
    /****
    * @description Updates page and settings based on the migration batch job status change
    */
    handleBatchEvent: function (component, event, batchAttribute) {
        if (!component.isValid()) {
            return;
        }

        const batch = event.getParam('batchProgress');
        if (batch === undefined
            || batch === null
            || batch.className !== 'RD2_DataMigration_BATCH'
        ) {
            return;
        }

        component.set(batchAttribute, batch);
    },
    /****
    * @description Displays an unexpected error generated during data migration batch execution
    */
    handleBatchError: function (component, event, section) {
        if (!component.isValid()) {
            return;
        }

        const errorDetail = event.getParam('errorDetail');
        if (errorDetail === undefined
            || errorDetail === null
            || errorDetail.className !== 'RD2_DataMigration_BATCH'
        ) {
            return;
        }

        this.clearError(component);
        this.handleError(component, errorDetail, section);
    },
    /****
    * @description Disables page elements and reloads the enablement state
    */
    refreshView: function (component) {
        this.hideElement(component, "enablementDisabled");
        this.hideElement(component, "enabler");

        this.loadState(component);
    },
    /****
    * @description Refreshes dry run migration section
    */
    refreshDryRun: function (component) {
        if (!component.isValid()) {
            return;
        }

        const state = component.get("v.state");
        if (state === undefined || state === null) {
            return;
        }

        component.set('v.state.hideDryRun', state.isConfirmed);

        const batch = component.get("v.dryRunBatch");
        let isInProgress = false;
        let isCompleted = false;

        if (state.isConfirmed) {
            isCompleted = true;

        } else if (batch !== undefined && batch !== null) {
            isInProgress = batch.isInProgress;
            isCompleted = batch.status === 'Completed' && batch.isSuccess;
        }

        component.set('v.state.isDryRunInProgress', isInProgress);
        component.set('v.state.isDryRunCompleted', isCompleted);
    },
    /****
    * @description Set data migration attributes
    */
    refreshMigration: function (component) {
        if (!component.isValid()) {
            return;
        }

        const state = component.get("v.state");
        if (state === undefined || state === null) {
            return;
        }

        const batch = component.get("v.migrationBatch");
        if (batch === undefined || batch === null) {
            component.set('v.state.isMigrationInProgress', false);
            component.set('v.state.isMigrationCompleted', false);

        } else {
            component.set('v.state.isMigrationInProgress', batch.isInProgress);

            const isMigrationCompleted = state.isMetaDeployConfirmed
                && batch.status === 'Completed'
                && batch.isSuccess;
            component.set('v.state.isMigrationCompleted', isMigrationCompleted);
        }
    },
    /****
    * @description Refreshes enable Recurring Donations section
    */
    refreshEnable: function (component) {
        let state = component.get("v.state");

        let enableProgress = 0;
        if (state.isEnabled) {
            enableProgress = 100;
        } else if (state.isConfirmed) {
            enableProgress = 50;
        }
        component.set('v.state.enableProgress', enableProgress);

        if (!state.isConfirmed || state.isEnabled) {
            this.disableEdit(component, "enableToggle");
        } else {
            this.enableEdit(component, "enableToggle");
        }
    },
    /****
    * @description Refreshes MetaDeploy section
    */
    refreshMetaDeploy: function (component) {
        let state = component.get("v.state");

        let metaDeployProgress = 0;
        if (state.isMetaDeployConfirmed) {
            metaDeployProgress = 100;
        } else if (state.isMetaDeployLaunched) {
            metaDeployProgress = 50;
        }
        component.set('v.state.metaDeployProgress', metaDeployProgress);

        let linkIcon = component.find('metadeployIcon');
        if (state.isEnabled) {
            this.enableEdit(component, "metadeployLink");
            $A.util.addClass(linkIcon, "activeIcon");
        } else {
            this.disableEdit(component, "metadeployLink");
            $A.util.removeClass(linkIcon, "activeIcon");
        }
    },
    /****
    * @description Hides component's element
    */
    hideElement: function (component, elementName) {
        let element = component.find(elementName);
        $A.util.addClass(element, "slds-hide");
    },
    /****
    * @description Displays component's element
    */
    displayElement: function (component, elementName) {
        let element = component.find(elementName);
        $A.util.removeClass(element, "slds-hide");
    },
    /****
    * @description Disables input field edit
    */
    disableEdit: function (component, inputName) {
        let inputComp = component.find(inputName);
        $A.util.addClass(inputComp, "disabledEdit");
    },
    /****
    * @description Enables input field edit
    */
    enableEdit: function (component, inputName) {
        let inputComp = component.find(inputName);
        $A.util.removeClass(inputComp, "disabledEdit");
    },
    /****
    * @description Clears the errors on the page
    */
    clearError: function (component) {
        component.set('v.errorSection', '');
        component.set('v.errorMessage', '');
    },
    /**
     * @description: Displays errors thrown by Apex method invocations
     * @param errors: Error list
     */
    handleError: function (component, errors, section) {
        let message;
        if (errors && errors[0] && errors[0].message) {
            message = errors[0].message;

        } else if (errors && errors.message) {
            message = errors.message;

        } else {
            message = $A.get('$Label.c.stgUnknownError');
        }

        component.set('v.errorSection', section);
        component.set('v.errorMessage', message);
    },
    /**
     * @description: shows specific spinner 
     */
    showSpinner: function (component, element) {
        var spinner = component.find(element);
        $A.util.removeClass(spinner, 'slds-hide');
    },
    /**
     * @description: hides specific spinner 
     */
    hideSpinner: function (component, element) {
        var spinner = component.find(element);
        $A.util.addClass(spinner, 'slds-hide');
    }
})
