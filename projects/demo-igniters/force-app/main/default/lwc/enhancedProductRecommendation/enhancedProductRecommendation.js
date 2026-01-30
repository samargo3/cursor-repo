import { LightningElement, api, track } from 'lwc';
import getRecommendedProduct from '@salesforce/apex/RecommendedProductController.getRecommendedProduct';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class EnhancedProductRecommendation extends NavigationMixin(LightningElement) {
    @api recordId;
    @track products = [];
    @track error;
    @track selectedProducts = [];
    @track showComparison = false;
    loading = true;

    connectedCallback() {
        this.fetchRecommendations();
    }

    async fetchRecommendations() {
        this.loading = true;
        this.error = undefined;
        try {
            // Get multiple recommendations (simulating by calling the same method multiple times)
            const result = await getRecommendedProduct({ accountId: this.recordId });
            
            // Create mock multiple products for demonstration
            this.products = [
                result,
                {
                    id: 'mock-product-2',
                    name: 'Premium Analytics Suite',
                    family: 'Software',
                    unitPrice: 299.99,
                    currencyIsoCode: 'USD',
                    description: 'Advanced analytics and reporting tools'
                },
                {
                    id: 'mock-product-3', 
                    name: 'Enterprise Integration Platform',
                    family: 'Software',
                    unitPrice: 499.99,
                    currencyIsoCode: 'USD',
                    description: 'Seamless third-party integrations'
                }
            ].filter(product => product != null);
            
        } catch (e) {
            this.error = (e && (e.body && e.body.message)) ? e.body.message : 'Failed to load product recommendations';
            this.products = [];
        } finally {
            this.loading = false;
        }
    }

    get formattedProducts() {
        return this.products.map(product => ({
            ...product,
            formattedPrice: this.formatPrice(product.unitPrice, product.currencyIsoCode),
            isSelected: this.selectedProducts.includes(product.id)
        }));
    }

    formatPrice(price, currency = 'USD') {
        if (price == null) return '';
        try {
            return new Intl.NumberFormat(undefined, { style: 'currency', currency }).format(price);
        } catch (_) {
            return `$${price}`;
        }
    }

    handleProductSelect(event) {
        const productId = event.target.dataset.productId;
        if (this.selectedProducts.includes(productId)) {
            this.selectedProducts = this.selectedProducts.filter(id => id !== productId);
        } else {
            this.selectedProducts = [...this.selectedProducts, productId];
        }
    }

    handleViewProduct(event) {
        const productId = event.target.dataset.productId;
        if (!productId) return;
        
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: productId,
                objectApiName: 'Product2',
                actionName: 'view'
            }
        });
    }

    handleCompareProducts() {
        if (this.selectedProducts.length < 2) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Selection Required',
                    message: 'Please select at least 2 products to compare',
                    variant: 'warning'
                })
            );
            return;
        }
        this.showComparison = true;
    }

    handleCloseComparison() {
        this.showComparison = false;
        this.selectedProducts = [];
    }

    get canCompare() {
        return this.selectedProducts.length < 2;
    }

    get comparisonProducts() {
        return this.products.filter(product => this.selectedProducts.includes(product.id));
    }

    get hasProducts() {
        return this.products && this.products.length > 0;
    }
}
