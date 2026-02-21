# demo-igniters: Project Evaluation & Improvement Plan

**Analyzed:** February 21, 2026
**Project path:** `projects/demo-igniters/`
**Salesforce API Version:** 64.0

---

## Executive Summary

demo-igniters is a well-structured Salesforce DX demo platform built for enterprise sales showcases, covering Agentforce AI agents, resource forecasting, data seeding, MCP server integration, and LWC dashboards. The codebase shows strong fundamentals in architecture and test coverage, but several concrete bugs and design gaps reduce its reliability and demo readiness.

**Overall rating: 7/10** — solid foundation, needs targeted fixes before high-stakes demos.

---

## Strengths

### 1. Architecture & Patterns
- Trigger handler pattern is correctly applied (`OpportunityResourceValidationHandler` separates trigger logic from business logic)
- `with sharing` enforced consistently across all Apex classes — security model respected
- Wire services and imperative Apex calls are appropriately separated in LWC components (read vs. mutate)
- MCP server uses a whitelist-only approach for scripts and file paths, reducing injection surface

### 2. Test Coverage
Coverage meets and exceeds Salesforce's 75% minimum on all critical classes:

| Class | Coverage |
|---|---|
| `ProformaManagerController` | ~97% |
| `OpportunityResourceValidationHandler` | 100% |
| `OpportunityFileRetriever` | 95%+ |
| `PromptBuilderDataProvider` | 95%+ |

### 3. Developer Experience
- Husky + lint-staged enforces formatting and linting on every commit
- Prettier configured for Apex, XML, LWC HTML — consistent style across all file types
- 40+ npm scripts cover every demo scenario (leads, products, flows, SOQL queries, MCP)
- 60+ documentation files cover deployment, agent guides, quick references, and checklists

### 4. Agentforce Integration
- Clean `@InvocableMethod` pattern in all agent classes with well-typed request/result inner classes
- File retrieval agents handle multiple file types, size formatting, and download URLs
- `PromptBuilderDataProvider` delivers rich AI-ready context with scoring, risk assessment, and urgency levels

---

## Bugs & Critical Issues

### BUG 1: `ContractAnalysisAgent` — All extraction methods return hardcoded values

**File:** `force-app/main/default/classes/ContractAnalysisAgent.cls`
**Lines:** 108–138

```apex
private static String extractPaymentTerms(List<ContentDocumentLink> docs) {
    return 'Net 30'; // Always returns this
}
private static Decimal extractUptimeRequirement(List<ContentDocumentLink> docs) {
    return 99.9;     // Always returns exactly 99.9
}
private static Decimal extractRolloverTerms(List<ContentDocumentLink> docs) {
    return 10.0;     // Always returns exactly 10
}
private static Decimal extractLiabilityCap(List<ContentDocumentLink> docs) {
    return 500000;   // Always returns exactly 500000
}
```

**Impact:** The risk scoring algorithm in `calculateRisk()` is built around these exact values being the "safe" thresholds. Since all four methods always return exactly the safe threshold value:
- Payment = 'Net 30' → no risk points added
- Uptime = 99.9 → condition is `> 99.9`, so no points
- Rollover = 10.0 → condition is `> 10`, so no points
- Liability = 500000 → condition is `> 1000000`, so no points

**Result: Every contract analysis demo will always return "Low" risk with no risk factors and no recommendations.** This completely defeats the purpose of the MSA Analysis Agent demo.

**Fix:** Add parameterized contract term values to `ContractAnalysisRequest` so the agent caller (Agentforce flow or test script) can inject different scenarios:

```apex
public class ContractAnalysisRequest {
    @InvocableVariable(required=true) public Id opportunityId;
    // Add these so flows/tests can drive different scenarios:
    @InvocableVariable public String paymentTerms;   // e.g. 'Net 60'
    @InvocableVariable public Decimal uptime;        // e.g. 99.99
    @InvocableVariable public Decimal rolloverPct;   // e.g. 15.0
    @InvocableVariable public Decimal liabilityCap;  // e.g. 2000000
}
```

Alternatively, integrate with Data Cloud RAG or store demo scenario parameters in a Custom Metadata Type.

---

### BUG 2: `package.json` — Duplicate `demo:setup` key

**File:** `package.json`
**Lines:** 49 and 72

```json
"demo:setup": "npm run flow:create && npm run flow:deploy && npm run setup:einstein",  // line 49 — silently overridden
...
"demo:setup": "npm run demo:deploy && npm run demo:permissions && npm run demo:seed",  // line 72 — this one wins
```

JSON does not allow duplicate keys. The second `demo:setup` silently overwrites the first. The flows and Einstein setup from line 49 are never run when a user calls `npm run demo:setup`.

**Fix:** Merge both into a single comprehensive setup script or rename one to `demo:setup:full`.

```json
"demo:setup": "npm run demo:deploy && npm run demo:permissions && npm run demo:seed && npm run flow:create && npm run flow:deploy && npm run setup:einstein"
```

---

### BUG 3: `DemoDataSeeder.cls` — `Math.random()` misuse for contact count

**File:** `force-app/main/default/classes/DemoDataSeeder.cls`
**Line:** 104

```apex
Integer numContacts = Math.mod(Integer.valueOf(Math.random() * 100), 2) + 2;
```

`Math.random()` returns a value in `[0.0, 1.0)`. Multiplying by 100 gives `[0.0, 100.0)`. `Integer.valueOf()` truncates — so values of 0.0–0.99 all become 0. When `Math.random()` returns a very small value (common in test contexts where it may return 0.0), `numContacts` = `Math.mod(0, 2) + 2` = 2, which is fine. But the intent appears to be 2 or 3 contacts — this is better expressed without the random call:

```apex
Integer numContacts = Math.mod(accounts.indexOf(acc), 2) + 2; // Deterministic: alternates 2 and 3
```

This also makes data seeding fully repeatable across orgs, which matters for demos.

---

### BUG 4: `MCP server` — Error response format doesn't match MCP protocol

**File:** `mcp/salesforce-mcp-server.js`
**Lines:** 243–249

```js
return {
    id,
    error: error.message,
    isError: true,  // This is in the tool result object, not the MCP content response
};
```

The MCP SDK expects errors to be surfaced via `isError: true` at the **content level** of the response, not embedded in the JSON payload. The current structure returns a successful MCP response whose text content happens to contain `{ isError: true }`. Clients that check the MCP `isError` flag on the content block will not detect the failure.

**Fix:**

```js
return {
    content: [{ type: "text", text: JSON.stringify({ error: error.message }) }],
    isError: true,
};
```

Propagate this from `handleToolCall` back to the `CallToolRequestSchema` handler.

---

## Design Issues & Improvement Opportunities

### 1. `ContractAnalysisAgent` — Missing test class

There is a `ContractAnalysisAgentTest.cls` file present but the agent extraction methods always return hardcoded values, meaning tests are not actually verifying business logic — they are only verifying that the hardcoded defaults flow through the scoring system correctly. Once the extraction logic is made dynamic (Bug 1 fix), the test class needs comprehensive scenarios:
- Net 90 payment terms → Critical risk
- 99.99% uptime SLA → Critical risk
- 20% rollover → High risk
- Combined factors → correct score accumulation

### 2. `ProformaManagerController` — Stale wire cache after saves

**File:** `force-app/main/default/classes/ProformaManagerController.cls`
**Line:** 12

```apex
@AuraEnabled(cacheable=true)
public static ProformaData getProformaData(Id opportunityId)
```

`cacheable=true` uses the Lightning Data Service cache. After `saveResourceForecasts()` or `deleteResourceForecast()` mutate data, the LWC must explicitly invalidate this cache using `refreshApex()`. If the `proformaManager` LWC doesn't call `refreshApex` after every mutation, the UI will show stale data until the cache expires.

**Check:** Verify that `proformaManager.js` calls `refreshApex(this._proformaData)` after every save/delete. If not, add it.

### 3. Documentation sprawl — 60+ markdown files in project root

The project root of `demo-igniters/` contains 60+ markdown files with no table of contents or folder structure. This makes it difficult for new team members or clients to find the right guide.

**Recommendation:** Consolidate into a `docs/` subdirectory with clear categories:

```
docs/
├── setup/
│   ├── DEPLOYMENT_GUIDE.md
│   ├── MCP_SETUP.md
│   └── QUICK_START_DEMO_HUB.md
├── agents/
│   ├── DEAL_DESK_AGENT_README.md
│   ├── EMPLOYEE_FAQ_AGENT_DEMO_GUIDE.md
│   └── MSA_AGENT_ARCHITECTURE.md
├── features/
│   ├── PROFORMA_RESOURCE_FORECASTING_GUIDE.md
│   └── EINSTEIN_LEAD_SCORING_GUIDE.md
└── INDEX.md  ← master table of contents
```

### 4. No CI/CD pipeline

There are no GitHub Actions workflows. Deploys to the demo org are manual (`npm run demo:deploy`).

**Recommended workflow additions:**
- **On PR:** Run `npm run lint` + `npm run test:unit:coverage`
- **On merge to main:** Auto-deploy to demo org via `sf project deploy start`
- Add test results as PR check so regressions are caught before demos

```yaml
# .github/workflows/ci.yml
name: CI
on: [pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20' }
      - run: npm ci
      - run: npm run lint
      - run: npm run test:unit:coverage
```

### 5. `OpportunityResourceValidationHandler` — Error message is not user-friendly

**File:** `force-app/main/default/classes/OpportunityResourceValidationHandler.cls`
**Lines:** 8–10

```apex
private static final String ERROR_MESSAGE =
    'Cannot close opportunity as Won without resource forecasting. ' +
    'Please add at least one Resource Forecast to proceed.';
```

The word "resource forecasting" is internal jargon. Sales reps seeing this error in the UI may not know what to do.

**Improvement:** Link to the relevant record page section or use a Custom Label so the message can be localized and updated without a code deployment:

```apex
private static final String ERROR_MESSAGE = System.Label.Opportunity_Resource_Forecast_Required;
```

### 6. `DemoDataSeeder` — Contacts reference `acc.Website` for email domain

**File:** `force-app/main/default/classes/DemoDataSeeder.cls`
**Line:** 112

```apex
Email = getFirstName(i).toLowerCase() + '.' + getLastName(i).toLowerCase() + '@' + acc.Website,
```

`acc.Website` is set to `demo1.example.com` (without protocol), so this produces emails like `james.smith@demo1.example.com`. This is technically correct but:
1. The same first+last name combination is reused across all accounts (all accounts get a "James Smith" contact at index 0)
2. If an org has email validation or uniqueness rules, this will fail for bulk seeding across multiple runs

**Improvement:** Use the account index in the email to ensure uniqueness:

```apex
Email = getFirstName(i).toLowerCase() + '.' + getLastName(i).toLowerCase()
      + accounts.indexOf(acc) + '@' + acc.Website,
```

### 7. MCP server — `scripts_run` passes unvalidated user args to child processes

**File:** `mcp/salesforce-mcp-server.js`
**Lines:** 234–236

```js
const finalArgs = Array.isArray(args.args) && args.args.length ? baseArgs.concat(args.args) : baseArgs;
const { stdout } = await execa(cmd, finalArgs, { stdout: "pipe", stderr: "pipe" });
```

User-supplied `args.args` are appended directly to the script argument list without validation. While `execa` prevents shell injection (it doesn't use a shell), an attacker with MCP access could pass unexpected flags to `generate-products.js` (e.g., `--output /etc/passwd` or similar depending on the script's argument handling).

**Improvement:** Whitelist which scripts accept additional args and define allowed arg patterns per script.

### 8. Missing bulk save error handling in `saveResourceForecasts`

**File:** `force-app/main/default/classes/ProformaManagerController.cls`
**Line:** 89

```apex
upsert forecastsToUpsert;
```

A DML statement without partial-success handling will throw on the first error and roll back everything. If a user submits 5 resource forecasts and one has a validation error, all 5 fail silently.

**Improvement:** Use Database.upsert with `allOrNone=false` and surface per-record errors:

```apex
List<Database.UpsertResult> results = Database.upsert(forecastsToUpsert, false);
List<String> errors = new List<String>();
for (Database.UpsertResult r : results) {
    if (!r.isSuccess()) {
        for (Database.Error e : r.getErrors()) {
            errors.add(e.getMessage());
        }
    }
}
if (!errors.isEmpty()) {
    throw new AuraHandledException('Some records failed: ' + String.join(errors, '; '));
}
```

---

## Priority Matrix

| # | Issue | Severity | Effort |
|---|---|---|---|
| 1 | ContractAnalysisAgent always returns Low risk (Bug 1) | **Critical** | Medium |
| 2 | `demo:setup` duplicate key in package.json (Bug 2) | **High** | Low (1 line) |
| 3 | MCP error response format wrong (Bug 4) | **High** | Low |
| 4 | `saveResourceForecasts` no partial-failure handling | **Medium** | Medium |
| 5 | `proformaManager` wire cache may be stale after mutations | **Medium** | Low |
| 6 | Add CI/CD GitHub Actions pipeline | Medium | Medium |
| 7 | DemoDataSeeder contact email uniqueness | **Low** | Low |
| 8 | MCP `scripts_run` arg validation | Low | Low |
| 9 | Error message UX / Custom Labels | Low | Low |
| 10 | Documentation restructure into `docs/` folder | Low | High |

---

## Quick Wins (< 1 hour each)

1. **Fix `demo:setup` duplicate key** — merge the two script values into one command chain
2. **Fix MCP error propagation** — update `handleToolCall` to return `isError: true` at content level
3. **Add `refreshApex` call** in `proformaManager.js` after save and delete operations
4. **Use Custom Label** for the resource validation error message
5. **Deduplicate contact emails** by adding the account index to the email address

---

## Longer-term Improvements

1. **ContractAnalysisAgent**: Integrate with Data Cloud RAG or store scenario parameters in Custom Metadata Types so the agent demonstrates real variable risk analysis during demos
2. **CI/CD**: Add GitHub Actions for lint + unit tests on PRs and auto-deploy on merge
3. **Docs**: Consolidate 60+ markdown files into a `docs/` directory with an `INDEX.md`
4. **Partial DML**: Add `allOrNone=false` pattern to all bulk DML operations in controller classes

---

## Conclusion

demo-igniters is a well-designed and well-documented platform. The architectural decisions are sound, test coverage is strong, and the developer tooling is thorough. The most impactful fix is **Bug 1** (ContractAnalysisAgent hardcoded returns) — without it, the MSA Agent demo is nonfunctional. After that, the `demo:setup` duplicate key and MCP error format are trivial one-line fixes that improve reliability.
