import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import getEinsteinScore from '@salesforce/apex/LeadQualificationAgent.qualifyLead';

// Lead fields
import LEAD_NAME_FIELD from '@salesforce/schema/Lead.Name';
import LEAD_COMPANY_FIELD from '@salesforce/schema/Lead.Company';
import LEAD_EMAIL_FIELD from '@salesforce/schema/Lead.Email';
import LEAD_PHONE_FIELD from '@salesforce/schema/Lead.Phone';
import LEAD_INDUSTRY_FIELD from '@salesforce/schema/Lead.Industry';
import LEAD_ANNUAL_REVENUE_FIELD from '@salesforce/schema/Lead.AnnualRevenue';
import LEAD_EMPLOYEES_FIELD from '@salesforce/schema/Lead.NumberOfEmployees';
import LEAD_SOURCE_FIELD from '@salesforce/schema/Lead.LeadSource';
import LEAD_STATUS_FIELD from '@salesforce/schema/Lead.Status';

const fields = [
    LEAD_NAME_FIELD, 
    LEAD_COMPANY_FIELD, 
    LEAD_EMAIL_FIELD, 
    LEAD_PHONE_FIELD,
    LEAD_INDUSTRY_FIELD,
    LEAD_ANNUAL_REVENUE_FIELD,
    LEAD_EMPLOYEES_FIELD,
    LEAD_SOURCE_FIELD,
    LEAD_STATUS_FIELD
];

export default class EnhancedEinsteinScoring extends LightningElement {
    @api recordId;
    @track einsteinScore;
    @track isLoading = false;
    @track showResults = false;
    @track showDetails = false;
    @track historicalScores = [];
    @track scoreTrend = 'stable';
    @track confidenceLevel = 'high';

    // Lead data
    leadName;
    leadCompany;
    leadEmail;
    leadPhone;
    leadIndustry;
    leadAnnualRevenue;
    leadEmployees;
    leadSource;
    leadStatus;

    @wire(getRecord, { recordId: '$recordId', fields })
    wiredLead({ error, data }) {
        if (data) {
            this.leadName = getFieldValue(data, LEAD_NAME_FIELD);
            this.leadCompany = getFieldValue(data, LEAD_COMPANY_FIELD);
            this.leadEmail = getFieldValue(data, LEAD_EMAIL_FIELD);
            this.leadPhone = getFieldValue(data, LEAD_PHONE_FIELD);
            this.leadIndustry = getFieldValue(data, LEAD_INDUSTRY_FIELD);
            this.leadAnnualRevenue = getFieldValue(data, LEAD_ANNUAL_REVENUE_FIELD);
            this.leadEmployees = getFieldValue(data, LEAD_EMPLOYEES_FIELD);
            this.leadSource = getFieldValue(data, LEAD_SOURCE_FIELD);
            this.leadStatus = getFieldValue(data, LEAD_STATUS_FIELD);
        } else if (error) {
            console.error('Error loading lead data:', error);
        }
    }

    get hasLeadData() {
        return this.leadName && this.leadCompany;
    }

    get scoreClass() {
        if (!this.einsteinScore) return '';
        const score = this.einsteinScore.data?.score || 0;
        if (score >= 80) return 'score-excellent';
        if (score >= 60) return 'score-good';
        if (score >= 40) return 'score-fair';
        return 'score-poor';
    }

    get gradeClass() {
        if (!this.einsteinScore) return '';
        const grade = this.einsteinScore.data?.grade || '';
        return `grade-${grade.toLowerCase()}`;
    }

    get scoreTrendIcon() {
        switch (this.scoreTrend) {
            case 'up': return 'utility:trending';
            case 'down': return 'utility:trending_down';
            default: return 'utility:trending_flat';
        }
    }

    get confidenceClass() {
        switch (this.confidenceLevel) {
            case 'high': return 'confidence-high';
            case 'medium': return 'confidence-medium';
            default: return 'confidence-low';
        }
    }

    get buttonLabel() {
        return this.showDetails ? 'Hide Details' : 'Show Details';
    }

    get dataCompleteness() {
        return this.calculateDataCompleteness();
    }

    handleGetEinsteinScore() {
        this.isLoading = true;
        this.showResults = false;

        getEinsteinScore({ leadId: this.recordId })
            .then(result => {
                console.log('Einstein Score Result:', result);
                this.einsteinScore = result;
                this.showResults = true;
                this.isLoading = false;
                
                // Simulate historical data and trends
                this.generateHistoricalData();
                this.calculateScoreTrend();
                this.calculateConfidenceLevel();
                
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Einstein Score Generated',
                        message: `Score: ${result.data?.score || 0}/100 (Grade: ${result.data?.grade || 'N/A'})`,
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                console.error('Error getting Einstein score:', error);
                this.isLoading = false;
                
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Failed to generate Einstein score: ' + error.body?.message,
                        variant: 'error'
                    })
                );
            });
    }

    generateHistoricalData() {
        // Simulate historical scores for trend analysis
        const baseScore = this.einsteinScore?.data?.score || 50;
        this.historicalScores = [
            { date: '2024-01-15', score: Math.max(0, baseScore - 15) },
            { date: '2024-02-15', score: Math.max(0, baseScore - 10) },
            { date: '2024-03-15', score: Math.max(0, baseScore - 5) },
            { date: '2024-04-15', score: baseScore }
        ];
    }

    calculateScoreTrend() {
        if (this.historicalScores.length < 2) return;
        
        const latest = this.historicalScores[this.historicalScores.length - 1].score;
        const previous = this.historicalScores[this.historicalScores.length - 2].score;
        
        if (latest > previous + 5) this.scoreTrend = 'up';
        else if (latest < previous - 5) this.scoreTrend = 'down';
        else this.scoreTrend = 'stable';
    }

    calculateConfidenceLevel() {
        const score = this.einsteinScore?.data?.score || 0;
        const dataCompleteness = this.calculateDataCompleteness();
        
        if (score >= 70 && dataCompleteness >= 80) this.confidenceLevel = 'high';
        else if (score >= 50 && dataCompleteness >= 60) this.confidenceLevel = 'medium';
        else this.confidenceLevel = 'low';
    }

    calculateDataCompleteness() {
        let completeness = 0;
        if (this.leadName) completeness += 20;
        if (this.leadEmail) completeness += 20;
        if (this.leadPhone) completeness += 20;
        if (this.leadIndustry) completeness += 20;
        if (this.leadAnnualRevenue) completeness += 20;
        return completeness;
    }

    handleToggleDetails() {
        this.showDetails = !this.showDetails;
    }

    handleClose() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleRefreshScore() {
        this.showResults = false;
        this.historicalScores = [];
        this.handleGetEinsteinScore();
    }
}
