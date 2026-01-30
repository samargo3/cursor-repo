## Recommended Next Product (Account Page)

This guide explains what the component does and how to replicate it in your own org.

### What it does
- **Filter**: Active `Product2` records whose `Name` starts with `DLC`.
- **Pick**: Chooses one at random from the 10 most recently created matches.
- **Display**: Product name, family, price (from Standard Price Book), and a button to view the product.

**Source files**
- Apex: `force-app/main/default/classes/RecommendedProductController.cls`
- LWC: `force-app/main/default/lwc/recommendedNextProduct/*`

### Prerequisites
- Salesforce CLI installed (`sf --version`).
- An authenticated org alias (for example, `my-dev-org`).
- Permission to deploy source and edit Lightning pages.

### Step-by-step: replicate in a fresh org
1) Log in and set an alias
```bash
sf org login web --alias my-dev-org --set-default
```

2) Seed products that match the filter
- Option A: scrape and create products from the Latin American Distributors site
```bash
node scripts/scrape-products.js https://hostedresources.districtpublishing.com/Latin-American-Distributors/ my-dev-org
```
- Option B: manually create `Product2` records named like `DLC*` with active Standard Price Book entries

3) Deploy the controller and LWC
```bash
sf project deploy start \
  --source-dir force-app/main/default/classes/RecommendedProductController.cls \
  --source-dir force-app/main/default/classes/RecommendedProductController.cls-meta.xml \
  --source-dir force-app/main/default/lwc/recommendedNextProduct \
  --target-org my-dev-org --ignore-conflicts
```

4) Add to the Account page
- Open any Account record > gear icon > Edit Page
- Drag "Recommended Next Product" from Custom components onto the layout
- Save and Activate

5) Verify
- Open an Account; a DLC product should display
- If you see "No products available": ensure at least one active `Product2` with `Name` starting `DLC` and an active Standard Price Book price exists

### Behavior details
- Filter: `Name LIKE 'DLC%'` and `IsActive = true`
- Price: most recent active Standard Price Book `PricebookEntry`
- Selection: random among the 10 most recent matches
- Account-aware logic: not currently used (can be enhanced later)

### Useful commands
- Count DLC products
```bash
sf data query --query "SELECT COUNT() FROM Product2 WHERE IsActive = true AND Name LIKE 'DLC%'" --target-org my-dev-org --result-format table
```
- List newest products
```bash
sf data query --query "SELECT Id, Name, Family, CreatedDate FROM Product2 WHERE IsActive = true ORDER BY CreatedDate DESC LIMIT 10" --target-org my-dev-org --result-format table
```

### Troubleshooting
- Deployment errors about unrelated metadata: deploy only the class and LWC (see command above)
- Missing price: ensure Standard Price Book is active and product has an active `PricebookEntry`
- No matches: product names must start with `DLC` (case-sensitive) and be active
- Multiple orgs: pass the correct `--target-org` alias to all commands

### Enhancement ideas (optional)
- Prefer the single most recent product instead of random
- Require a Standard Price Book price (skip products without one)
- Use Account attributes (Industry/Region/Segment) to influence the pick
- Exclude products already purchased by the Account














