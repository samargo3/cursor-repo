import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class ProductBoardSubmission extends NavigationMixin(LightningElement) {
    @api recordId; // Case record ID

    handleOpenFlow() {
        // Navigate to the Product Board Submission Screen Flow
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: `/flow/Product_Board_Submission_Screen_Flow?recordId=${this.recordId}`
            }
        });
    }
}