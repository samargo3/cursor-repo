import { LightningElement } from 'lwc';
import jiraLogo from '@salesforce/resourceUrl/jiraLogo';

export default class JiraIssueButton extends LightningElement {
    buttonLabel = 'Create Jira Issue';
    buttonVariant = 'brand';
    isCreated = false;
    jiraLogo = jiraLogo;

    get buttonClass() {
        return this.isCreated ? 'slds-m-left_x-small greyed-out' : 'slds-m-left_x-small';
    }

    handleCreateIssue() {
        // Toggle button label and variant when clicked
        if (this.isCreated) {
            this.buttonLabel = 'Create Jira Issue';
            this.buttonVariant = 'brand';
            this.isCreated = false;
        } else {
            this.buttonLabel = 'Jira Issue Created';
            this.buttonVariant = 'neutral';
            this.isCreated = true;
        }
    }
}

