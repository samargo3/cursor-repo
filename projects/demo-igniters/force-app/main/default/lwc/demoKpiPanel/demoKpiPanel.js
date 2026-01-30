import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getKpiData from '@salesforce/apex/DemoKpiService.getKpiData';
import createSampleOpportunity from '@salesforce/apex/DemoKpiService.createSampleOpportunity';

export default class DemoKpiPanel extends NavigationMixin(LightningElement) {
    kpiData;
    error;
    isLoading = true;
    wiredKpiResult;

    @wire(getKpiData)
    wiredKpi(result) {
        this.wiredKpiResult = result;
        this.isLoading = true;
        
        if (result.data) {
            this.kpiData = this.processPipelineData(result.data);
            this.error = undefined;
            this.isLoading = false;
            this.updatePipelineAndActivityFormatting();
        } else if (result.error) {
            this.error = this.extractErrorMessage(result.error);
            this.kpiData = undefined;
            this.isLoading = false;
        }
    }

    processPipelineData(data) {
        try {
            // Create a deep copy to avoid mutating the wire adapter's read-only proxy
            const processedData = JSON.parse(JSON.stringify(data));
            
            // Add formatted amounts to pipeline and activities
            if (processedData.pipelineData) {
                processedData.pipelineData = processedData.pipelineData.map(stage => ({
                    ...stage,
                    formattedValue: this.formatCurrency(stage.value)
                }));
            }
            if (processedData.recentActivities) {
                processedData.recentActivities = processedData.recentActivities.map(activity => ({
                    ...activity,
                    formattedAmount: this.formatCurrency(activity.amount)
                }));
            }
            return processedData;
        } catch (e) {
            console.error('Error processing pipeline data:', e);
            return data;
        }
    }

    updatePipelineAndActivityFormatting() {
        // Update pipeline values in DOM after render
        setTimeout(() => {
            const pipelineValues = this.template.querySelectorAll('.stage-value');
            pipelineValues.forEach(elem => {
                const value = elem.dataset.value;
                if (value) {
                    elem.textContent = this.formatCurrency(parseFloat(value));
                }
            });

            const activityAmounts = this.template.querySelectorAll('.activity-amount');
            activityAmounts.forEach(elem => {
                const amount = elem.dataset.amount;
                if (amount) {
                    elem.textContent = this.formatCurrency(parseFloat(amount));
                }
            });
        }, 0);
    }

    get formattedRevenue() {
        return this.formatCurrency(this.kpiData?.totalRevenue);
    }

    get formattedAvgDeal() {
        return this.formatCurrency(this.kpiData?.averageDealSize);
    }

    get hasPipelineData() {
        return this.kpiData?.pipelineData && this.kpiData.pipelineData.length > 0;
    }

    get hasRecentActivities() {
        return this.kpiData?.recentActivities && this.kpiData.recentActivities.length > 0;
    }

    formatCurrency(value) {
        if (!value) return '$0';
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD',
            minimumFractionDigits: 0,
            maximumFractionDigits: 0
        }).format(value);
    }

    handleRefresh() {
        this.isLoading = true;
        refreshApex(this.wiredKpiResult)
            .then(() => {
                this.showToast('Success', 'Dashboard refreshed successfully', 'success');
            })
            .catch(error => {
                this.showToast('Error', this.extractErrorMessage(error), 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleCreateSampleOpp() {
        this.isLoading = true;
        createSampleOpportunity({ accountId: null })
            .then(oppId => {
                this.showToast('Success', 'Sample opportunity created successfully', 'success');
                // Navigate to the new opportunity
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: oppId,
                        objectApiName: 'Opportunity',
                        actionName: 'view'
                    }
                });
                // Refresh the dashboard
                return refreshApex(this.wiredKpiResult);
            })
            .catch(error => {
                this.showToast('Error', this.extractErrorMessage(error), 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleActivityClick(event) {
        const recordId = event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Opportunity',
                actionName: 'view'
            }
        });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }

    extractErrorMessage(error) {
        if (Array.isArray(error.body)) {
            return error.body.map(e => e.message).join(', ');
        } else if (error.body && typeof error.body.message === 'string') {
            return error.body.message;
        } else if (typeof error.message === 'string') {
            return error.message;
        }
        return 'Unknown error occurred';
    }
}

