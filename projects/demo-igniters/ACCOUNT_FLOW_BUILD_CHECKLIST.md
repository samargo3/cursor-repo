# Account Contract Comparison Flow - Build Checklist

Print this checklist and check off items as you build the flow.

---

## ☑️ Pre-Flight Check

Before you start:

- [ ] I have access to **Prompt Builder** in my org
- [ ] **AccountOpportunityFilesRetriever.cls** is deployed
- [ ] I have a test account with 2+ opportunities
- [ ] Test opportunities have PDF/DOCX files attached
- [ ] I'm in **Lightning Experience**
- [ ] I have **Modify All Data** or **Customize Application** permission

**Estimated Time:** 30-40 minutes

---

## 📝 Part 1: Build the Prompt Template (15 mins)

- [ ] Navigate to **Setup > Prompt Builder**
- [ ] Click **New Prompt Template**

### Basic Info
- [ ] Template Name: `Account Multi-Opportunity Contract Comparison`
- [ ] Description: `Analyzes and compares contract terms across opportunities`
- [ ] Template Type: **Flex**
- [ ] Click **Next**

### Create Input Resources
- [ ] Resource 1: `accountName` (Text) ✅ Required
- [ ] Resource 2: `opportunityCount` (Number) ✅ Required
- [ ] Resource 3: `totalFiles` (Number) ✅ Required
- [ ] Resource 4: `fileSummary` (Text Area Long) ✅ Required

### Write the Prompt
- [ ] Copy prompt from guide (starts with "You are a highly specialized...")
- [ ] Paste into Prompt Template Body
- [ ] Review the sections (Executive Summary, Comparison Table, etc.)

### Test & Save
- [ ] Click **Preview** (optional)
- [ ] Enter test values and generate (optional)
- [ ] Click **Save**
- [ ] Click **Activate**
- [ ] ✅ Write down API name: `_______________________________`

---

## 🔄 Part 2: Build the Screen Flow (15 mins)

- [ ] Navigate to **Setup > Flows**
- [ ] Click **New Flow**
- [ ] Select **Screen Flow**
- [ ] Click **Create**

### Create Variables (7 variables)
- [ ] Variable 1: `recordId` (Text) - ✅ Available for input
- [ ] Variable 2: `varAccountName` (Text)
- [ ] Variable 3: `varOppCount` (Number)
- [ ] Variable 4: `varTotalFiles` (Number)
- [ ] Variable 5: `varFileSummary` (Text Area Long)
- [ ] Variable 6: `varAnalysisResult` (Text Area Long)
- [ ] Variable 7: `varSuccess` (Boolean)

### Add Flow Elements

**Element 1: Action - Get Files**
- [ ] Add **Action** to canvas
- [ ] Search: "Get Account Opportunity Files"
- [ ] Select the action
- [ ] **Input:** Account ID = `{!recordId}`
- [ ] **Input:** File Types Filter = `pdf,docx,doc`
- [ ] **Input:** Max Total Files = `20`
- [ ] **Outputs:** Map all 5 outputs to variables
  - [ ] Success → varSuccess
  - [ ] Account Name → varAccountName
  - [ ] Opportunity Count → varOppCount
  - [ ] Total File Count → varTotalFiles
  - [ ] Aggregated File Summary → varFileSummary
- [ ] Click **Done**

**Element 2: Decision - Check Success**
- [ ] Add **Decision** after action
- [ ] Label: `Check Success`
- [ ] Outcome: `Success`
  - [ ] Condition: varSuccess Equals True
  - [ ] AND varTotalFiles Greater Than 0
- [ ] Default Outcome: `Error`
- [ ] Click **Done**

**Element 3: Action - Call Prompt (from Success path)**
- [ ] Add **Action** from Success path
- [ ] Search for your prompt template name
- [ ] Select it
- [ ] **Inputs:** Map 4 prompt inputs
  - [ ] accountName = varAccountName
  - [ ] opportunityCount = varOppCount
  - [ ] totalFiles = varTotalFiles
  - [ ] fileSummary = varFileSummary
- [ ] **Output:** Response → varAnalysisResult
- [ ] Click **Done**

**Element 4: Screen - Display Results (after prompt)**
- [ ] Add **Screen** after prompt action
- [ ] Label: `Display Contract Analysis`
- [ ] Add **Display Text** component #1 (Header)
  - [ ] Copy HTML from guide (header with account name)
  - [ ] Use `{!varAccountName}`, `{!varOppCount}`, `{!varTotalFiles}`
- [ ] Add **Display Text** component #2 (AI Output)
  - [ ] Insert: `{!varAnalysisResult}`
- [ ] Add **Display Text** component #3 (File Details - optional)
  - [ ] Label: Document Details
  - [ ] Insert: `{!varFileSummary}`
- [ ] Screen settings: Show Finish ✅, Finish label: "Close"
- [ ] Click **Done**

**Element 5: Screen - Error (from Error path)**
- [ ] Add **Screen** from Error path
- [ ] Label: `Error Screen`
- [ ] Add **Display Text** component
  - [ ] Copy HTML from guide (warning message)
- [ ] Screen settings: Show Finish ✅
- [ ] Click **Done**

### Save & Activate
- [ ] Click **Save**
- [ ] Flow Label: `Account Contract Comparison`
- [ ] Flow API Name: `Account_Contract_Comparison`
- [ ] Description: `Analyzes contracts across opportunities`
- [ ] Click **Save**
- [ ] Click **Debug** (optional - test with Account ID)
- [ ] Click **Activate**

---

## 📄 Part 3: Add to Account Page (5 mins)

- [ ] Navigate to any **Account** record
- [ ] Click **⚙️ Setup Gear** > **Edit Page**

### Add Flow to Page
- [ ] Find **Flow** component in left sidebar
- [ ] Drag **Flow** to desired location
- [ ] Click on Flow component

### Configure Component
- [ ] **Flow:** Select `Account Contract Comparison`
- [ ] **Pass record ID:** Select `recordId`
- [ ] **Height:** `800px` (or adjust)

### Activate Page
- [ ] Click **Save**
- [ ] Click **Activation...**
- [ ] Choose assignment (e.g., Org Default)
- [ ] Select App (e.g., Sales)
- [ ] Click **Save**

---

## ✅ Part 4: Test the Flow (5 mins)

### Prepare Test Data
- [ ] Create test account: "Test Account Corp"
- [ ] Create 2-3 test opportunities
- [ ] Upload 2-4 PDF/Word files to opportunities
- [ ] Rename files descriptively (MSA, SOW, etc.)

### Run Test
- [ ] Navigate to test account
- [ ] Scroll to Flow component
- [ ] Flow runs automatically (or click Run)
- [ ] Wait 5-15 seconds

### Verify Output
- [ ] ✅ See account name, opp count, file count
- [ ] ✅ See AI analysis with sections:
  - [ ] Executive Summary
  - [ ] Comparison Table
  - [ ] Inconsistencies
  - [ ] Risk Assessment
  - [ ] Recommendations
  - [ ] Document Inventory
- [ ] ✅ Results make sense for test data

### Test Error Handling
- [ ] Navigate to account with NO opportunities
- [ ] Run flow
- [ ] ✅ See error message screen

---

## 🎯 Optional Enhancements

Add these features if needed:

- [ ] **Email Alert:** Send analysis to account owner
- [ ] **Create Task:** Auto-create follow-up task
- [ ] **Save to Field:** Store results in custom Account field
- [ ] **Filter by Stage:** Only analyze certain opp stages
- [ ] **Add Loading Screen:** Show "Analyzing..." message

---

## 🐛 Troubleshooting Checks

If something doesn't work:

- [ ] Flow is **Activated** (not draft)
- [ ] `recordId` variable has "Available for input" ✅
- [ ] Prompt template is **Activated**
- [ ] Test account has opportunities with files
- [ ] File types match filter (pdf, docx, doc)
- [ ] User has ContentDocument read permissions
- [ ] Refresh browser and clear cache

### Debug Mode
- [ ] Open Flow in builder
- [ ] Click **Debug**
- [ ] Enter test Account ID
- [ ] Click **Run**
- [ ] Review each element's output
- [ ] Check for red error icons

---

## 📊 Success Metrics

Your flow is successful if:

- [ ] ✅ Runs without errors on test account
- [ ] ✅ Displays account name and file counts
- [ ] ✅ AI analysis is relevant and formatted
- [ ] ✅ Comparison table shows multiple opportunities
- [ ] ✅ Error screen appears when no files exist
- [ ] ✅ Flow completes in under 15 seconds
- [ ] ✅ Users can understand the output

---

## 📚 Documentation Checklist

After building:

- [ ] Document the solution for users
- [ ] Create training guide for Account Managers
- [ ] Add instructions to onboarding docs
- [ ] Update any internal wikis
- [ ] Share with Deal Desk team
- [ ] Schedule demo/training session

---

## 🚀 Rollout Checklist

Before org-wide deployment:

- [ ] Test with 5+ different accounts
- [ ] Get feedback from 2-3 pilot users
- [ ] Refine prompt based on feedback
- [ ] Verify performance (timing, accuracy)
- [ ] Create support documentation
- [ ] Set up monitoring/feedback channel
- [ ] Communicate to all users
- [ ] Schedule office hours for questions

---

## ⏱️ Time Tracker

Track your actual time:

| Task | Estimated | Actual | Notes |
|------|-----------|--------|-------|
| Prompt Template | 15 min | _____ min | _____________ |
| Screen Flow | 15 min | _____ min | _____________ |
| Add to Page | 5 min | _____ min | _____________ |
| Testing | 5 min | _____ min | _____________ |
| **Total** | **40 min** | **_____ min** | |

---

## 📞 Support Resources

If you get stuck:

- [ ] **Guide:** ACCOUNT_CONTRACT_COMPARISON_GUIDE.md
- [ ] **Comparison:** CONTRACT_FLOW_COMPARISON.md
- [ ] **Salesforce Docs:** search "Screen Flow" in Help
- [ ] **Prompt Builder Docs:** search "Prompt Builder" in Setup
- [ ] **Trailhead:** "Build Flows with Flow Builder"
- [ ] **Community:** Ask in Salesforce Trailblazer Community

---

## ✅ Final Checklist

Before marking complete:

- [ ] Flow activates successfully
- [ ] Appears on Account page
- [ ] Runs without errors
- [ ] Produces readable output
- [ ] Tested with 3+ accounts
- [ ] Error handling works
- [ ] Documentation created
- [ ] Team trained (if applicable)
- [ ] Feedback mechanism in place

---

**🎉 Congratulations! You've built an AI-powered contract comparison flow!**

**Next Steps:**
1. Share with your team
2. Gather feedback
3. Refine prompt
4. Monitor usage
5. Celebrate your success! 🚀

---

## Notes Section

Use this space for your own notes:

```
Org: _________________________________

Account ID used for testing: _________________________________

Prompt Template API Name: _________________________________

Flow API Name: _________________________________

Date Completed: _________________________________

Tested By: _________________________________

Issues Encountered:
- 
- 
- 

Customizations Made:
- 
- 
- 

```

---

**Version:** 1.0  
**Last Updated:** November 2025  
**Created by:** Your friendly AI assistant 🤖


