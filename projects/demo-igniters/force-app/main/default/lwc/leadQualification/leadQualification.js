import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import qualifyLead from '@salesforce/apex/LeadQualificationAgent.qualifyLead';

// Lead fields
import LEAD_NAME_FIELD from '@salesforce/schema/Lead.Name';
import LEAD_COMPANY_FIELD from '@salesforce/schema/Lead.Company';
import LEAD_EMAIL_FIELD from '@salesforce/schema/Lead.Email';
import LEAD_PHONE_FIELD from '@salesforce/schema/Lead.Phone';

const fields = [LEAD_NAME_FIELD, LEAD_COMPANY_FIELD, LEAD_EMAIL_FIELD, LEAD_PHONE_FIELD];

export default class LeadQualification extends LightningElement {
    @api recordId;
    @track qualificationResult;
    @track isLoading = false;
    @track showResults = false;

    @wire(getRecord, { recordId: '$recordId', fields })
    lead;

    get leadName() {
        return getFieldValue(this.lead.data, LEAD_NAME_FIELD);
    }

    get leadCompany() {
        return getFieldValue(this.lead.data, LEAD_COMPANY_FIELD);
    }

    get leadEmail() {
        return getFieldValue(this.lead.data, LEAD_EMAIL_FIELD);
    }

    get leadPhone() {
        return getFieldValue(this.lead.data, LEAD_PHONE_FIELD);
    }

    get hasLeadData() {
        return this.lead.data;
    }

    get scoreClass() {
        if (!this.qualificationResult?.score) return '';
        
        const score = this.qualificationResult.score;
        if (score >= 80) return 'score-high';
        if (score >= 60) return 'score-medium';
        return 'score-low';
    }

    get gradeClass() {
        if (!this.qualificationResult?.grade) return '';
        
        const grade = this.qualificationResult.grade;
        if (grade === 'A') return 'grade-a';
        if (grade === 'B') return 'grade-b';
        if (grade === 'C') return 'grade-c';
        return 'grade-d';
    }

    handleQualifyLead() {
        this.isLoading = true;
        this.showResults = false;

        qualifyLead({ leadId: this.recordId })
            .then(result => {
                console.log('Full result:', JSON.stringify(result));
                
                // The Apex method returns an AgentResponse with a data property
                if (result && result.success && result.data) {
                    this.qualificationResult = result.data;
                    this.showResults = true;
                    this.isLoading = false;
                    
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Lead Qualified Successfully',
                            message: `Score: ${result.data.score}/100 (Grade: ${result.data.grade})`,
                            variant: 'success'
                        })
                    );
                } else {
                    this.isLoading = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Qualification failed: ' + (result.message || 'Unknown error'),
                            variant: 'error'
                        })
                    );
                }
            })
            .catch(error => {
                console.error('Error qualifying lead:', error);
                this.isLoading = false;
                
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Failed to qualify lead: ' + (error.body?.message || error.message || 'Unknown error'),
                        variant: 'error'
                    })
                );
            });
    }

    handleClose() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleRefresh() {
        this.showResults = false;
        this.qualificationResult = null;
    }
}
