import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import seedAllDemoData from '@salesforce/apex/DemoDataSeeder.seedAllDemoData';
import clearDemoData from '@salesforce/apex/DemoDataSeeder.clearDemoData';

export default class DemoAdminPanel extends LightningElement {
    isLoading = false;
    loadingMessage = '';
    showResults = false;
    results = {};
    dataStats = null;

    connectedCallback() {
        this.loadDataStats();
    }

    handleSeedData() {
        this.isLoading = true;
        this.loadingMessage = 'Seeding demo data...';
        this.showResults = false;

        seedAllDemoData()
            .then(result => {
                this.results = result;
                this.showResults = true;
                this.showToast(
                    'Success!',
                    `Created ${result.accounts} accounts, ${result.contacts} contacts, and ${result.opportunities} opportunities`,
                    'success'
                );
                // Refresh stats
                return this.loadDataStats();
            })
            .catch(error => {
                this.showToast('Error', this.extractErrorMessage(error), 'error');
            })
            .finally(() => {
                this.isLoading = false;
                this.loadingMessage = '';
            });
    }

    handleClearData() {
        this.isLoading = true;
        this.loadingMessage = 'Clearing demo data...';
        this.showResults = false;

        clearDemoData()
            .then(result => {
                this.results = result;
                this.showResults = true;
                this.showToast(
                    'Data Cleared',
                    `Deleted ${result.accountsDeleted} accounts, ${result.contactsDeleted} contacts, and ${result.opportunitiesDeleted} opportunities`,
                    'success'
                );
                // Refresh stats
                return this.loadDataStats();
            })
            .catch(error => {
                this.showToast('Error', this.extractErrorMessage(error), 'error');
            })
            .finally(() => {
                this.isLoading = false;
                this.loadingMessage = '';
            });
    }

    handleResetData() {
        this.isLoading = true;
        this.loadingMessage = 'Resetting demo data (clearing + seeding)...';
        this.showResults = false;

        // First clear
        clearDemoData()
            .then(clearResult => {
                this.loadingMessage = 'Data cleared, now seeding fresh data...';
                // Then seed
                return seedAllDemoData();
            })
            .then(seedResult => {
                this.results = seedResult;
                this.showResults = true;
                this.showToast(
                    'Data Reset Complete',
                    `Created ${seedResult.accounts} accounts, ${seedResult.contacts} contacts, and ${seedResult.opportunities} opportunities`,
                    'success'
                );
                // Refresh stats
                return this.loadDataStats();
            })
            .catch(error => {
                this.showToast('Error', this.extractErrorMessage(error), 'error');
            })
            .finally(() => {
                this.isLoading = false;
                this.loadingMessage = '';
            });
    }

    loadDataStats() {
        // This is a simple approach - you could also create a dedicated Apex method
        // For now, we'll set some default text encouraging users to refresh
        this.dataStats = {
            accountCount: '...',
            contactCount: '...',
            opportunityCount: '...'
        };

        // In a real implementation, you'd call an Apex method to get counts
        // For now, we'll just show placeholder text
        setTimeout(() => {
            this.dataStats = {
                accountCount: 'Check SOQL',
                contactCount: 'Check SOQL',
                opportunityCount: 'Check SOQL'
            };
        }, 1000);
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
                mode: 'sticky'
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

