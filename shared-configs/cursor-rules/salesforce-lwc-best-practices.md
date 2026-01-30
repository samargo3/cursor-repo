# Lightning Web Component Best Practices

## Component Structure

### File Organization
```
myComponent/
├── myComponent.html       # Template
├── myComponent.js         # Controller
├── myComponent.css        # Styles
├── myComponent.js-meta.xml # Metadata
└── __tests__/
    └── myComponent.test.js
```

### Naming Conventions
- Folder: camelCase (`myComponent`)
- Files: match folder name
- Classes: PascalCase in JS (`MyComponent`)

## JavaScript Patterns

### Properties
```javascript
import { LightningElement, api, track, wire } from 'lwc';

export default class MyComponent extends LightningElement {
    @api publicProperty;    // Exposed to parent
    @track privateProperty; // Reactive private property
    
    @wire(getRecord, { recordId: '$recordId' })
    wiredRecord({ error, data }) {
        if (data) {
            // Handle data
        } else if (error) {
            // Handle error
        }
    }
}
```

### Event Handling
```javascript
// Dispatch custom event
handleClick() {
    this.dispatchEvent(new CustomEvent('select', {
        detail: { recordId: this.recordId }
    }));
}
```

## HTML Best Practices

### Conditional Rendering
```html
<template>
    <template if:true={isLoading}>
        <lightning-spinner></lightning-spinner>
    </template>
    
    <template if:true={hasData}>
        <!-- Show data -->
    </template>
</template>
```

### Looping
```html
<template for:each={items} for:item="item">
    <div key={item.id}>
        {item.name}
    </div>
</template>
```

## Accessibility

- Use semantic HTML
- Add ARIA labels
- Support keyboard navigation
- Test with screen readers

```html
<lightning-input
    label="Email"
    type="email"
    required
    aria-describedby="email-help"
></lightning-input>
```

## Performance

### Getters for Computed Values
```javascript
get fullName() {
    return `${this.firstName} ${this.lastName}`;
}
```

### Avoid Heavy Operations in Render
- Use lifecycle hooks appropriately
- Cache expensive calculations
- Lazy load data when possible

## Error Handling

```javascript
async connectedCallback() {
    try {
        this.data = await fetchData();
    } catch (error) {
        this.error = error.message;
        this.showToast('Error', error.message, 'error');
    }
}
```

---

**AI Instructions:** When creating LWC components, follow these patterns.
