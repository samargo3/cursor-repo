import { LightningElement } from 'lwc';

export default class MyFirstLwc extends LightningElement {
    showMessage = false;

    handleClick() {
        this.showMessage = true;
    }
} 