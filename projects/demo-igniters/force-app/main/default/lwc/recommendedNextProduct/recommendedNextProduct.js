import { LightningElement, api, track } from 'lwc';
import getRecommendedProduct from '@salesforce/apex/RecommendedProductController.getRecommendedProduct';
import { NavigationMixin } from 'lightning/navigation';

export default class RecommendedNextProduct extends NavigationMixin(LightningElement) {
    @api recordId;
    @track product;
    @track error;
    loading = true;

    connectedCallback() {
        this.fetchRecommendation();
    }

    async fetchRecommendation() {
        this.loading = true;
        this.error = undefined;
        try {
            const result = await getRecommendedProduct({ accountId: this.recordId });
            this.product = result || null;
        } catch (e) {
            this.error = (e && (e.body && e.body.message)) ? e.body.message : 'Failed to load product recommendation';
            this.product = null;
        } finally {
            this.loading = false;
        }
    }

    get formattedPrice() {
        if (!this.product || this.product.unitPrice == null) return '';
        const currency = this.product.currencyIsoCode || 'USD';
        try {
            return new Intl.NumberFormat(undefined, { style: 'currency', currency }).format(this.product.unitPrice);
        } catch (_) {
            return `$${this.product.unitPrice}`;
        }
    }

    handleView() {
        if (!this.product || !this.product.id) return;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.product.id,
                objectApiName: 'Product2',
                actionName: 'view'
            }
        });
    }
}














