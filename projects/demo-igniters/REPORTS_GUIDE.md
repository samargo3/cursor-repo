# Sales Demo Hub - Reports Guide

## Overview
This guide provides information about the custom reports deployed to your Sales Demo Hub.

## Available Reports

All reports are located in the **Sales Demo Reports** folder and can be accessed from the Reports tab in your Sales Demo Hub app.

### 1. All Opportunities
**Purpose**: Complete list of all opportunities across all stages  
**Format**: Tabular (List View)  
**Fields Displayed**:
- Opportunity Name
- Account Name
- Stage
- Amount
- Close Date
- Probability
- Type

**Sorted By**: Close Date (Descending - Most Recent First)

**Use Case**: Get a comprehensive view of your entire opportunity pipeline

---

### 2. Open Opportunities
**Purpose**: All opportunities currently in the sales pipeline (not closed)  
**Format**: Tabular (List View)  
**Filter**: Only open opportunities (Closed = False)  
**Fields Displayed**:
- Opportunity Name
- Account Name
- Stage
- Amount
- Close Date
- Probability
- Lead Source

**Sorted By**: Amount (Descending - Highest Value First)

**Use Case**: Focus on active deals that need attention

---

### 3. Closed Won Opportunities
**Purpose**: Track successfully closed deals  
**Format**: Tabular (List View)  
**Filter**: Only won opportunities (Won = True)  
**Fields Displayed**:
- Opportunity Name
- Account Name
- Amount
- Close Date
- Type
- Created Date

**Sorted By**: Amount (Descending - Biggest Wins First)

**Use Case**: Analyze past successes and celebrate wins

---

### 4. High Value Opportunities
**Purpose**: Focus on opportunities worth more than $50,000  
**Format**: Tabular (List View)  
**Filter**: Amount > $50,000  
**Fields Displayed**:
- Opportunity Name
- Account Name
- Stage
- Amount
- Close Date
- Probability

**Sorted By**: Amount (Descending - Highest Value First)

**Use Case**: Prioritize your biggest deals

---

### 5. Demo Accounts with Contacts
**Purpose**: View all demo accounts and their associated contacts  
**Format**: Tabular (List View)  
**Filter**: Account Name contains "Demo"  
**Fields Displayed**:
- First Name
- Last Name
- Title
- Email
- Account Name
- Created Date

**Sorted By**: Account Name (Ascending)

**Use Case**: See the full demo dataset with contacts

---

## How to Access Reports

1. Open your Salesforce org
2. Switch to the **Sales Demo Hub** app
3. Click the **Reports** tab
4. Navigate to **Sales Demo Reports** folder
5. Click any report to view it

## Creating Charts from Reports

You can easily convert any of these tabular reports into charts:

1. Open a report
2. Click **Customize**
3. Click **Add Chart**
4. Select your chart type (Bar, Line, Donut, etc.)
5. Configure the grouping and summary fields
6. Save the report

## Building Dashboards

Once you have reports with charts, you can create dashboards:

1. Go to **Dashboards** tab
2. Click **New Dashboard**
3. Drag and drop report charts onto the dashboard
4. Add metrics and components
5. Save and share with your team

## Tips for Demo Presentations

- **All Opportunities**: Start here to show the full scope of your sales pipeline
- **Open Opportunities**: Filter by stage to demonstrate pipeline progression
- **High Value Opportunities**: Highlight your most important deals
- **Closed Won**: Show successful outcomes and revenue generated

## Customizing Reports

To modify any report:

1. Open the report
2. Click **Edit**
3. Add/remove columns using the left panel
4. Add filters to refine the data
5. Change grouping and sorting
6. Save your changes

## Export Reports

All reports can be exported:
- Click **Export** button
- Choose format (Excel, CSV, etc.)
- Download and share with stakeholders

---

## Next Steps

**Want More Advanced Analytics?**

Consider building:
- Summary reports with groupings (e.g., Opportunities by Stage)
- Matrix reports for cross-tabulation
- Joined reports combining multiple report types
- Custom dashboards with multiple visualizations

**Pro Tip**: Use the Report Builder UI for complex reports - it provides autocomplete for fields and validates in real-time, making it much easier than creating reports programmatically!

---

For questions or support, refer to the main [Sales Demo Hub Guide](./SALES_DEMO_HUB_GUIDE.md).

