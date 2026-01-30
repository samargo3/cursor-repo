import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getProformaData from '@salesforce/apex/ProformaManagerController.getProformaData';
import getRolePicklistValues from '@salesforce/apex/ProformaManagerController.getRolePicklistValues';
import saveResourceForecasts from '@salesforce/apex/ProformaManagerController.saveResourceForecasts';
import deleteResourceForecast from '@salesforce/apex/ProformaManagerController.deleteResourceForecast';

export default class ProformaManager extends LightningElement {
    @api recordId; // Opportunity ID from record page
    
    @track forecasts = [];
    @track roleOptions = [];
    @track isLoading = false;
    @track hasChanges = false;
    
    opportunity;
    wiredProformaDataResult;
    
    // Columns for the data table
    columns = [
        { 
            label: 'Role', 
            fieldName: 'Role__c', 
            type: 'picklistColumn',
            editable: true,
            typeAttributes: {
                placeholder: 'Select Role',
                options: { fieldName: 'roleOptions' },
                value: { fieldName: 'Role__c' },
                context: { fieldName: 'Id' }
            }
        },
        { 
            label: 'Expected Hours', 
            fieldName: 'Expected_Hours__c', 
            type: 'number',
            editable: true,
            typeAttributes: {
                minimumFractionDigits: 2,
                maximumFractionDigits: 2
            }
        },
        { 
            label: 'Hourly Cost', 
            fieldName: 'Hourly_Cost__c', 
            type: 'currency',
            editable: true,
            typeAttributes: {
                currencyCode: 'USD',
                step: '0.01'
            }
        },
        { 
            label: 'Total Estimated Cost', 
            fieldName: 'Total_Estimated_Cost__c', 
            type: 'currency',
            editable: false,
            typeAttributes: {
                currencyCode: 'USD'
            }
        },
        {
            type: 'action',
            typeAttributes: {
                rowActions: [
                    { label: 'Delete', name: 'delete' }
                ]
            }
        }
    ];
    
    // Wire to get proforma data
    @wire(getProformaData, { opportunityId: '$recordId' })
    wiredProformaData(result) {
        this.wiredProformaDataResult = result;
        
        if (result.data) {
            this.opportunity = result.data.opportunity;
            this.forecasts = result.data.resourceForecasts.map(forecast => ({
                ...forecast,
                roleOptions: this.roleOptions
            }));
        } else if (result.error) {
            this.showToast('Error', 'Error loading data: ' + this.getErrorMessage(result.error), 'error');
        }
    }
    
    // Wire to get role picklist values
    @wire(getRolePicklistValues)
    wiredRoleOptions({ error, data }) {
        if (data) {
            this.roleOptions = data;
        } else if (error) {
            this.showToast('Error', 'Error loading role options: ' + this.getErrorMessage(error), 'error');
        }
    }
    
    // Computed properties
    get totalResourceCost() {
        return this.opportunity?.Total_Resource_Cost__c || 0;
    }
    
    get opportunityAmount() {
        return this.opportunity?.Amount || 0;
    }
    
    get dealProfitability() {
        return this.opportunityAmount - this.totalResourceCost;
    }
    
    get profitabilityClass() {
        return this.dealProfitability >= 0 ? 'profitability-positive' : 'profitability-negative';
    }
    
    get profitMarginPercentage() {
        if (this.opportunityAmount === 0) return 0;
        return ((this.dealProfitability / this.opportunityAmount) * 100).toFixed(2);
    }
    
    get hasForecastsForDisplay() {
        return this.forecasts && this.forecasts.length > 0;
    }
    
    get opportunityAmountFormatted() {
        return this.formatCurrency(this.opportunityAmount);
    }
    
    get totalResourceCostFormatted() {
        return this.formatCurrency(this.totalResourceCost);
    }
    
    get dealProfitabilityFormatted() {
        return this.formatCurrency(this.dealProfitability);
    }
    
    get profitabilityValueClass() {
        const baseClass = 'card-value';
        return this.dealProfitability >= 0 
            ? `${baseClass} card-value-success` 
            : `${baseClass} card-value-error`;
    }
    
    get profitabilityCardClass() {
        const baseClass = 'summary-card';
        return this.dealProfitability >= 0 
            ? `${baseClass} card-green` 
            : `${baseClass} card-red`;
    }
    
    // Format currency
    formatCurrency(value) {
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD'
        }).format(value || 0);
    }
    
    // Handle individual field changes
    handleRoleChange(event) {
        this.updateForecast(event.target.dataset.id, 'Role__c', event.detail.value);
    }
    
    handleHoursChange(event) {
        this.updateForecast(event.target.dataset.id, 'Expected_Hours__c', parseFloat(event.detail.value) || 0);
    }
    
    handleCostChange(event) {
        this.updateForecast(event.target.dataset.id, 'Hourly_Cost__c', parseFloat(event.detail.value) || 0);
    }
    
    handleDeleteRow(event) {
        const forecastId = event.currentTarget.dataset.id;
        this.handleDeleteForecast(forecastId);
    }
    
    // Update forecast in array
    updateForecast(forecastId, fieldName, value) {
        this.forecasts = this.forecasts.map(forecast => {
            if (forecast.Id === forecastId) {
                const updated = { ...forecast, [fieldName]: value };
                // Recalculate total
                if (fieldName === 'Expected_Hours__c' || fieldName === 'Hourly_Cost__c') {
                    updated.Total_Estimated_Cost__c = 
                        (updated.Expected_Hours__c || 0) * (updated.Hourly_Cost__c || 0);
                }
                return updated;
            }
            return forecast;
        });
        this.hasChanges = true;
    }
    
    // Handle inline editing
    handleCellChange(event) {
        const draftValues = event.detail.draftValues;
        
        // Update forecasts with draft values
        this.forecasts = this.forecasts.map(forecast => {
            const draft = draftValues.find(d => d.Id === forecast.Id);
            if (draft) {
                return { ...forecast, ...draft };
            }
            return forecast;
        });
        
        this.hasChanges = true;
    }
    
    // Handle row actions
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        
        if (actionName === 'delete') {
            this.handleDeleteForecast(row.Id);
        }
    }
    
    // Add new forecast row
    handleAddRow() {
        const newForecast = {
            Id: 'temp-' + Date.now(),
            Role__c: '',
            Expected_Hours__c: 0,
            Hourly_Cost__c: 0,
            Total_Estimated_Cost__c: 0,
            roleOptions: this.roleOptions,
            isNew: true
        };
        
        this.forecasts = [...this.forecasts, newForecast];
        this.hasChanges = true;
    }
    
    // Save changes
    async handleSave() {
        this.isLoading = true;
        
        try {
            // Validate data
            const validationError = this.validateForecasts();
            if (validationError) {
                this.showToast('Validation Error', validationError, 'error');
                this.isLoading = false;
                return;
            }
            
            // Prepare forecasts for save
            const forecastsToSave = this.forecasts.map(forecast => {
                const { roleOptions, isNew, ...cleanForecast } = forecast;
                // Remove temp IDs
                if (cleanForecast.Id && cleanForecast.Id.startsWith('temp-')) {
                    delete cleanForecast.Id;
                }
                return cleanForecast;
            });
            
            // Call Apex to save
            await saveResourceForecasts({ 
                forecasts: forecastsToSave, 
                opportunityId: this.recordId 
            });
            
            this.showToast('Success', 'Resource forecasts saved successfully', 'success');
            this.hasChanges = false;
            
            // Refresh data
            await refreshApex(this.wiredProformaDataResult);
            
        } catch (error) {
            this.showToast('Error', 'Error saving forecasts: ' + this.getErrorMessage(error), 'error');
        } finally {
            this.isLoading = false;
        }
    }
    
    // Cancel changes
    handleCancel() {
        this.hasChanges = false;
        // Refresh to get original data
        return refreshApex(this.wiredProformaDataResult);
    }
    
    // Delete forecast
    async handleDeleteForecast(forecastId) {
        this.isLoading = true;
        
        try {
            // If it's a temporary row, just remove from array
            if (forecastId.startsWith('temp-')) {
                this.forecasts = this.forecasts.filter(f => f.Id !== forecastId);
                this.hasChanges = true;
            } else {
                // Delete from database
                await deleteResourceForecast({ forecastId });
                this.showToast('Success', 'Resource forecast deleted', 'success');
                
                // Refresh data
                await refreshApex(this.wiredProformaDataResult);
            }
        } catch (error) {
            this.showToast('Error', 'Error deleting forecast: ' + this.getErrorMessage(error), 'error');
        } finally {
            this.isLoading = false;
        }
    }
    
    // Validate forecasts
    validateForecasts() {
        for (let forecast of this.forecasts) {
            if (!forecast.Role__c) {
                return 'Please select a role for all forecasts';
            }
            if (!forecast.Expected_Hours__c || forecast.Expected_Hours__c <= 0) {
                return 'Expected hours must be greater than 0';
            }
            if (!forecast.Hourly_Cost__c || forecast.Hourly_Cost__c <= 0) {
                return 'Hourly cost must be greater than 0';
            }
        }
        return null;
    }
    
    // Show toast notification
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
    
    // Get error message from error object
    getErrorMessage(error) {
        if (error.body && error.body.message) {
            return error.body.message;
        } else if (error.message) {
            return error.message;
        } else if (typeof error === 'string') {
            return error;
        }
        return 'Unknown error occurred';
    }
}
