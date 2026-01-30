# 🎫 Jira Issue Button - Integration Demo Component

## 🎯 Overview

The **Jira Issue Button** is a simple, elegant Lightning Web Component that mimics creating an issue in Jira. It demonstrates basic LWC toggle functionality with visual state changes - perfect for showing integration concepts without requiring actual API connections.

**Use Case**: Show how Salesforce can integrate with external systems like Jira for issue tracking, without the complexity of setting up OAuth or API credentials during demos.

---

## ✨ What It Does

- **Button displays**: "Create Jira Issue" (blue/active)
- **After click**: Changes to "Jira Issue Created" (greyed out)
- **After second click**: Toggles back to "Create Jira Issue" (blue/active)
- **Visual feedback**: Opacity changes (50%) to show greyed-out state
- **Always clickable**: Button remains functional even when greyed out

### Demo Value
- ✅ Shows integration concept without actual Jira setup
- ✅ Clean, professional UI for customer demos
- ✅ Can be placed on any record page (Account, Contact, Lead, Opportunity, Case)
- ✅ Easy to understand and explain
- ✅ Quick to deploy and test

---

## 📦 What Was Deployed

### Lightning Web Component Files
- **jiraIssueButton.html** - Template with Lightning card and button
- **jiraIssueButton.js** - Controller with toggle logic
- **jiraIssueButton.css** - Custom styling for greyed-out appearance
- **jiraIssueButton.js-meta.xml** - Metadata configuration for page placement

**Component Name**: `jiraIssueButton`  
**API Version**: 65.0

---

## 🚀 Quick Start

### Prerequisites
- Salesforce CLI installed (`sf --version`)
- An authenticated org (e.g., `my-demo-org`)
- Permission to deploy metadata and edit Lightning pages

### Deploy to Your Org

```bash
# Authenticate to your org
sf org login web --alias my-demo-org

# Deploy the component
sf project deploy start \
  --target-org my-demo-org \
  --source-dir force-app/main/default/lwc/jiraIssueButton
```

### Add to a Page

1. Navigate to any **Account, Contact, Lead, Opportunity, or Case** record
2. Click the **⚙️ gear icon** → **Edit Page**
3. In Lightning App Builder:
   - Find **jiraIssueButton** in the custom components list (left sidebar)
   - Drag it onto your page layout
   - Click **Save** → **Activate**
4. Refresh the page to see your component!

---

## 🎨 Component Features

### Visual States

**State 1: Ready to Create**
- Label: "Create Jira Issue"
- Variant: `brand` (blue button)
- Opacity: 100% (full color)
- Clickable: ✅

**State 2: Issue Created**
- Label: "Jira Issue Created"
- Variant: `neutral` (grey button)
- Opacity: 50% (greyed out via CSS)
- Clickable: ✅ (still functional!)

### Toggle Behavior
```javascript
// Click 1: Create → Created (greyed out)
// Click 2: Created → Create (active)
// Click 3: Create → Created (greyed out)
// ... continues infinitely
```

---

## 🛠️ Technical Details

### File Structure
```
force-app/main/default/lwc/jiraIssueButton/
├── jiraIssueButton.html          # Lightning card template
├── jiraIssueButton.js            # Toggle logic & state management
├── jiraIssueButton.css           # Greyed-out styling
└── jiraIssueButton.js-meta.xml   # Metadata & page targets
```

### HTML Template
```html
<template>
    <lightning-card title="Jira Integration" icon-name="custom:custom63">
        <div class="slds-p-around_medium">
            <lightning-button
                label={buttonLabel}
                variant={buttonVariant}
                onclick={handleCreateIssue}
                class={buttonClass}
            ></lightning-button>
        </div>
    </lightning-card>
</template>
```

### JavaScript Controller
```javascript
export default class JiraIssueButton extends LightningElement {
    buttonLabel = 'Create Jira Issue';
    buttonVariant = 'brand';
    isCreated = false;

    get buttonClass() {
        return this.isCreated ? 
            'slds-m-left_x-small greyed-out' : 
            'slds-m-left_x-small';
    }

    handleCreateIssue() {
        // Toggle between states
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
```

### CSS Styling
```css
.greyed-out {
    opacity: 0.5;
    cursor: pointer;
}
```

### Metadata Configuration
Available on:
- ✅ App Pages (`lightning__AppPage`)
- ✅ Record Pages (`lightning__RecordPage`)
- ✅ Home Pages (`lightning__HomePage`)

Supported Objects:
- Account
- Contact
- Lead
- Opportunity
- Case

---

## 🎭 Demo Scenarios

### Scenario 1: Integration Demo
**Story**: "When a customer has an urgent issue, your team can create a Jira ticket directly from Salesforce."

1. Open an Account record
2. Scroll to the Jira Integration component
3. Click **"Create Jira Issue"**
4. Point out: "Now a ticket has been created in Jira" (button shows greyed out)
5. Optional: Click again to show toggle (simulate creating another ticket)

### Scenario 2: Support Case Integration
**Story**: "Support reps can escalate cases to engineering via Jira without leaving Salesforce."

1. Open a Case record
2. Show the Jira Integration component
3. Demonstrate the one-click issue creation
4. Highlight the visual feedback (greyed out = ticket created)

### Scenario 3: Service Cloud Enhancement
**Story**: "Seamlessly connect your service team with your development team."

1. Add component to Case page layout
2. Show how agents can file bugs or feature requests
3. Visual confirmation prevents duplicate tickets

---

## 🔧 Customization Ideas

### Enhance the Button Text
Edit `jiraIssueButton.js`:
```javascript
// Change default labels
buttonLabel = 'File Bug Report';
// After click
this.buttonLabel = 'Bug Reported to Engineering';
```

### Add More Visual Feedback
Add to `jiraIssueButton.css`:
```css
.greyed-out {
    opacity: 0.5;
    cursor: pointer;
    filter: grayscale(50%); /* Extra grey effect */
}
```

### Change Card Title
Edit `jiraIssueButton.html`:
```html
<lightning-card title="Engineering Escalation" icon-name="custom:custom63">
```

### Add Different Icons
Popular icon options:
- `custom:custom63` - Default settings icon
- `utility:ticket` - Ticket icon
- `utility:bug` - Bug icon
- `utility:task` - Task icon
- `action:new_task` - New task icon

---

## 🚀 Advanced: Make It Actually Work

While this is a demo component, you can easily extend it to make real Jira API calls:

### Add Apex Controller
```apex
public with sharing class JiraIntegrationController {
    @AuraEnabled
    public static String createJiraIssue(String recordId) {
        // Add your Jira REST API callout here
        // Return the Jira ticket ID
        return 'JIRA-12345';
    }
}
```

### Update LWC to Call Apex
```javascript
import createJiraIssue from '@salesforce/apex/JiraIntegrationController.createJiraIssue';
import { getRecord } from 'lightning/uiRecordApi';

// Wire record ID if on record page
@api recordId;

async handleCreateIssue() {
    try {
        const ticketId = await createJiraIssue({ recordId: this.recordId });
        this.buttonLabel = `Jira Issue Created: ${ticketId}`;
        this.isCreated = true;
    } catch (error) {
        // Handle error
    }
}
```

### Add Named Credential
1. Setup → Named Credentials
2. Create credential for Jira
3. Add OAuth or API key authentication
4. Reference in Apex callout

---

## 📍 Where to Add It

### Recommended Placements

#### Account Pages
**Why**: Create issues related to account problems or feature requests
- Sidebar or main content area
- Near related lists

#### Contact Pages  
**Why**: Log contacts' reported issues
- Top of page for quick access
- Near activity timeline

#### Lead Pages
**Why**: Track pre-sales technical questions
- Qualification section
- Near lead scoring

#### Opportunity Pages
**Why**: Escalate deal-blocking technical issues
- Deal blockers section
- Near closed-lost reasons

#### Case Pages
**Why**: Most natural placement - escalate support cases
- Case details section
- Near case comments

---

## 🎬 Demo Script

### Setup (30 seconds)
1. "Let me show you how we've integrated Salesforce with our engineering team's Jira board."
2. Navigate to a Case or Account record
3. Scroll to show the Jira Integration component

### Action (15 seconds)
4. "With one click, I can create a Jira ticket for engineering to investigate."
5. Click **"Create Jira Issue"**
6. Point out the visual change: "Notice the button confirms the ticket was created"

### Explanation (30 seconds)
7. "This gives our support team instant escalation to engineering"
8. "No need to switch systems or copy/paste information"
9. "The integration passes all the Salesforce context automatically"

### Optional - Show Toggle (15 seconds)
10. Click again: "And if needed, we can create additional tickets"
11. Shows flexibility and reliability

**Total Time**: ~90 seconds for complete flow

---

## 🛠️ Step-by-Step: Build It Yourself

### Create the Component Structure
```bash
# From your Salesforce DX project root
mkdir -p force-app/main/default/lwc/jiraIssueButton
cd force-app/main/default/lwc/jiraIssueButton
```

### 1. Create HTML Template
**File**: `jiraIssueButton.html`
```html
<template>
    <lightning-card title="Jira Integration" icon-name="custom:custom63">
        <div class="slds-p-around_medium">
            <lightning-button
                label={buttonLabel}
                variant={buttonVariant}
                onclick={handleCreateIssue}
                class={buttonClass}
            ></lightning-button>
        </div>
    </lightning-card>
</template>
```

### 2. Create JavaScript Controller
**File**: `jiraIssueButton.js`
```javascript
import { LightningElement } from 'lwc';

export default class JiraIssueButton extends LightningElement {
    buttonLabel = 'Create Jira Issue';
    buttonVariant = 'brand';
    isCreated = false;

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
```

### 3. Create CSS Styling
**File**: `jiraIssueButton.css`
```css
.greyed-out {
    opacity: 0.5;
    cursor: pointer;
}
```

### 4. Create Metadata Configuration
**File**: `jiraIssueButton.js-meta.xml`
```xml
<?xml version="1.0" encoding="UTF-8"?>
<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>65.0</apiVersion>
    <isExposed>true</isExposed>
    <targets>
        <target>lightning__AppPage</target>
        <target>lightning__RecordPage</target>
        <target>lightning__HomePage</target>
    </targets>
    <targetConfigs>
        <targetConfig targets="lightning__RecordPage">
            <objects>
                <object>Account</object>
                <object>Contact</object>
                <object>Lead</object>
                <object>Opportunity</object>
                <object>Case</object>
            </objects>
        </targetConfig>
    </targetConfigs>
</LightningComponentBundle>
```

### 5. Deploy to Your Org
```bash
sf project deploy start \
  --target-org my-demo-org \
  --source-dir force-app/main/default/lwc/jiraIssueButton
```

---

## 🧪 Testing the Component

### Manual Testing Checklist
- [ ] Component appears on page after activation
- [ ] Button shows "Create Jira Issue" initially
- [ ] Button is blue/brand colored initially
- [ ] Click changes label to "Jira Issue Created"
- [ ] Button appears greyed out (50% opacity)
- [ ] Button is still clickable when greyed out
- [ ] Second click toggles back to "Create Jira Issue"
- [ ] Button returns to blue/brand color
- [ ] Can toggle indefinitely

### Verify Deployment
```bash
# Check component is deployed
sf project deploy report --target-org my-demo-org

# List all LWC components
sf project list metadata --target-org my-demo-org --metadata-type LightningComponentBundle
```

---

## 📱 Responsive Design

### Desktop View
- Card width adapts to page layout
- Button sized appropriately
- Padding and spacing per SLDS guidelines

### Mobile View
- Touch-friendly button size
- Card stacks naturally in mobile layout
- Full functionality maintained

### Tablet View
- Optimized for both portrait and landscape
- Component scales smoothly

---

## 🔄 How the Toggle Works

### State Management
The component uses three reactive properties:

1. **`buttonLabel`** - Controls button text
2. **`buttonVariant`** - Controls button color (`brand` or `neutral`)
3. **`isCreated`** - Tracks current state (boolean)

### Computed Property
```javascript
get buttonClass() {
    // Dynamically returns CSS class based on state
    return this.isCreated ? 
        'slds-m-left_x-small greyed-out' : 
        'slds-m-left_x-small';
}
```

### Event Handler
```javascript
handleCreateIssue() {
    if (this.isCreated) {
        // State 2 → State 1: Reset to create mode
    } else {
        // State 1 → State 2: Switch to created mode
    }
}
```

---

## 🎯 Use Cases for Solution Engineers

### Sales Demos
**Scenario**: "Show how sales reps can escalate technical questions"
- Add to Opportunity pages
- Demonstrate during qualification stage
- Show collaboration between sales and engineering

### Service Cloud Demos
**Scenario**: "Support agents create engineering tickets without leaving Salesforce"
- Add to Case pages
- Perfect for technical support workflows
- Highlight integrated customer service

### Partner Demos
**Scenario**: "Platform integration capabilities"
- Show how easy it is to build custom integrations
- Demonstrate LWC development speed
- Highlight Lightning component framework

### ISV/AppExchange Demos
**Scenario**: "Mock third-party integrations"
- Show component in action
- Explain how partners can build similar components
- Demonstrate AppExchange-ready components

---

## 💡 Enhancement Ideas

### Add Toast Notification
```javascript
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

handleCreateIssue() {
    // ... existing toggle code ...
    
    if (!this.isCreated) {
        // Show success toast
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: 'Jira issue created successfully!',
            variant: 'success'
        }));
    }
}
```

### Add Spinner During "Creation"
```javascript
handleCreateIssue() {
    this.isLoading = true;
    
    // Simulate API call delay
    setTimeout(() => {
        // Toggle logic here
        this.isLoading = false;
    }, 1000);
}
```

### Pass Record Context
```javascript
import { api } from 'lwc';

export default class JiraIssueButton extends LightningElement {
    @api recordId; // Automatically available on record pages
    
    handleCreateIssue() {
        console.log('Creating issue for record:', this.recordId);
        // Use recordId in API callout
    }
}
```

### Add Issue Counter
```javascript
issueCount = 0;

handleCreateIssue() {
    if (!this.isCreated) {
        this.issueCount++;
        this.buttonLabel = `Jira Issue Created (#${this.issueCount})`;
    }
}
```

---

## 🎨 Customization Options

### Change Button Colors

**Edit**: `jiraIssueButton.js`
```javascript
// Use different button variants
buttonVariant = 'success';  // Green button
buttonVariant = 'destructive';  // Red button
buttonVariant = 'brand-outline';  // Outlined blue
```

### Adjust Greyed-Out Intensity

**Edit**: `jiraIssueButton.css`
```css
.greyed-out {
    opacity: 0.3;  /* More greyed (was 0.5) */
    opacity: 0.7;  /* Less greyed (was 0.5) */
    cursor: pointer;
}
```

### Change Card Icon

**Edit**: `jiraIssueButton.html`
```html
<!-- Different icon options -->
icon-name="utility:ticket"
icon-name="utility:bug"  
icon-name="utility:task"
icon-name="action:new_task"
```

### Rename the Component

If you want to use this for a different integration:

1. Copy the entire `jiraIssueButton` folder
2. Rename to your integration (e.g., `serviceNowButton`)
3. Update all file names and class names
4. Change labels and card title
5. Deploy the new component

---

## 🧩 Integration with Other Components

### Add to Demo Admin Panel
You could add this as a demo setup option alongside seed/clear/reset data.

### Combine with Einstein
Show how AI recommendations can trigger Jira issues automatically.

### Link to Flows
Trigger a Flow when the button is clicked to automate additional actions.

### Connect to Reports
Create a report showing "Issues Created" over time (requires actual data storage).

---

## 🐛 Troubleshooting

### Component Not Appearing in Lightning App Builder
**Solution**:
1. Verify deployment was successful
2. Check `isExposed` is `true` in metadata
3. Confirm you're editing a supported page type
4. Hard refresh browser (Cmd+Shift+R or Ctrl+Shift+F5)

### Button Not Toggling
**Solution**:
1. Check browser console for JavaScript errors
2. Verify `handleCreateIssue` is spelled correctly in HTML
3. Clear Salesforce cache and refresh

### Styling Not Applied
**Solution**:
1. Ensure `.css` file deployed successfully
2. Check `buttonClass` getter is returning correct value
3. Verify CSS class name matches (`greyed-out`)

### Can't Click Greyed Button
**Solution**:
1. Confirm `disabled={isCreated}` is NOT in the HTML
2. Verify only `class={buttonClass}` is controlling visual state
3. Check CSS has `cursor: pointer` for greyed-out state

---

## 📊 Metrics & Success Indicators

### After Deployment, Verify:
- ✅ Component visible in Lightning App Builder custom components
- ✅ Can be added to multiple page types
- ✅ Functions correctly on all target objects
- ✅ Visual state changes work smoothly
- ✅ No console errors when clicking

### During Demo, Watch For:
- ✅ Audience understands the integration concept
- ✅ Visual feedback is clear and obvious
- ✅ Toggle demonstrates reliability
- ✅ Questions about actual integration (great opportunity!)

---

## 🎓 Learning Outcomes

### For Solution Engineers
After building this, you'll understand:
- ✅ How to create Lightning Web Components from scratch
- ✅ Reactive property binding in LWC
- ✅ Computed properties (getters) for dynamic values
- ✅ Event handling in LWC
- ✅ Custom CSS in Lightning components
- ✅ Metadata configuration for page targets
- ✅ Deploying LWC components via CLI

### For Prospects/Customers
After seeing this demo, they'll understand:
- ✅ How easy Salesforce integrations can be
- ✅ Lightning component capabilities
- ✅ Custom UI development on the platform
- ✅ Visual feedback and user experience
- ✅ Potential for their own integrations

---

## 🔗 Related Components

### In This Project
- **demoAdminPanel** - Similar card-based UI pattern
- **demoKpiPanel** - Dashboard with multiple interactive elements
- **recommendedNextProduct** - Another integration example with actual Apex

### Salesforce Examples
- [LWC Recipes](https://github.com/trailheadapps/lwc-recipes)
- [Component Library](https://developer.salesforce.com/docs/component-library)

---

## 🎯 Next Steps

### Option 1: Enhance This Component
- Add real Jira API integration
- Include issue description modal
- Show created ticket details
- Add issue type selector

### Option 2: Create Similar Components
- ServiceNow incident button
- Slack notification button  
- Email escalation button
- GitHub issue creator

### Option 3: Build Complete Integration
- Two-way sync with Jira
- Display Jira issues in Salesforce
- Update tickets from Salesforce
- Automated issue creation via Flow

---

## 📚 Additional Resources

### Documentation
- [LWC Developer Guide](https://developer.salesforce.com/docs/component-library/documentation/en/lwc)
- [Lightning Design System](https://www.lightningdesignsystem.com/)
- [Jira REST API](https://developer.atlassian.com/cloud/jira/platform/rest/v3/)

### Trailhead Modules
- [Lightning Web Components Basics](https://trailhead.salesforce.com/content/learn/modules/lightning-web-components-basics)
- [External Services](https://trailhead.salesforce.com/content/learn/modules/external-services)

### Community
- [Salesforce Stack Exchange](https://salesforce.stackexchange.com/)
- [SFXD Discord](https://discordapp.com/invite/sfxd)

---

## ✅ Deployment Checklist

Before your demo, ensure:
- [ ] Component deployed to target org
- [ ] Added to at least one page layout
- [ ] Tested toggle functionality
- [ ] Verified visual states (active/greyed)
- [ ] Practiced demo script
- [ ] Prepared answers for "how does it really work?" questions
- [ ] Know how to show the code if asked

---

## 🎉 Success!

You now have a professional, demo-ready Jira integration component that:
- ✨ Looks polished and production-ready
- 🔄 Toggles smoothly between states
- 🎨 Provides clear visual feedback
- 💡 Opens conversations about real integrations
- ⚡ Deploys in seconds to any org

**Component is live at**: `force-app/main/default/lwc/jiraIssueButton/`

**Happy demoing!** 🚀

