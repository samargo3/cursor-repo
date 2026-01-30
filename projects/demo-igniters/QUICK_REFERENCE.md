# Cursor + Salesforce CLI Quick Reference

## Table of Contents
- [Salesforce CLI Commands](#salesforce-cli-commands)
- [Cursor Development](#cursor-development)
- [Common Patterns](#common-patterns)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

---

## Salesforce CLI Commands

### Authentication & Organization Management
```bash
# Login to Salesforce org
sf org login web --instance-url https://your-instance.salesforce.com

# List all orgs
sf org list --all

# Set default org
sf config set target-org your-org-alias

# Display org info
sf org display --target-org your-org-alias

# Open org in browser
sf org open --target-org your-org-alias
```

### Project Management
```bash
# Deploy source to org
sf project deploy start --source-dir force-app --target-org your-org-alias

# Retrieve source from org
sf project retrieve start --source-dir force-app --target-org your-org-alias

# Validate deployment
sf project deploy validate --source-dir force-app --target-org your-org-alias

# Create new project
sf project generate --name my-project

# Initialize project
sf project init --name my-project
```

### Data Operations
```bash
# Query data
sf data query --query "SELECT Id, Name FROM Account LIMIT 10" --target-org your-org-alias

# Export data to CSV
sf data export tree --query "SELECT Id, Name FROM Account" --output-dir data/

# Import data from CSV
sf data import tree --files data/accounts.csv --target-org your-org-alias

# Bulk upsert
sf data bulk upsert --sobjecttype Lead --csvfile data/leads.csv --external-id-field Email

# Delete records
sf data delete --sobjecttype Lead --where "CreatedDate = LAST_N_DAYS:30"
```

### Flow Management
```bash
# Deploy flows
sf flow deploy --source-dir force-app/main/default/flows --target-org your-org-alias

# Test flow
sf flow test run --flow-name My_Flow_Name --target-org your-org-alias

# List flows
sf flow list --target-org your-org-alias

# Activate flow
sf flow activate --flow-name My_Flow_Name --target-org your-org-alias
```

### Apex Development
```bash
# Execute Apex code
sf apex run --file scripts/debug.apex --target-org your-org-alias

# Execute anonymous Apex
sf apex run --code "System.debug('Hello World');" --target-org your-org-alias

# Run tests
sf apex test run --class-names MyTestClass --target-org your-org-alias

# Generate test report
sf apex test report --test-run-id 707000000000000 --target-org your-org-alias
```

### Metadata Operations
```bash
# Deploy metadata
sf project deploy start --metadata ApexClass,Flow --target-org your-org-alias

# Retrieve metadata
sf project retrieve start --metadata ApexClass,Flow --target-org your-org-alias

# List metadata
sf project list metadata --metadata-type ApexClass --target-org your-org-alias
```

---

## Cursor Development

### Project Setup
```bash
# Install dependencies
npm install

# Run linting
npm run lint

# Format code
npm run prettier

# Run tests
npm run test

# Run tests with coverage
npm run test:unit:coverage
```

### Script Execution
```bash
# Generate test data
npm run generate:leads

# Deploy data
npm run deploy:leads

# Import data
npm run import:leads:batch

# Run SOQL queries
npm run soql:count
npm run soql:sample
npm run soql:status

# Create and deploy flows
npm run flow:create
npm run flow:deploy
```

### Git Workflow
```bash
# Create feature branch
git checkout -b feature/use-case-name

# Stage changes
git add .

# Commit with conventional format
git commit -m "feat(leads): implement bulk lead import functionality"

# Push to remote
git push origin feature/use-case-name

# Create pull request
gh pr create --title "Add bulk lead import feature" --body "Implements bulk lead import functionality with validation and error handling"
```

---

## Common Patterns

### Script Template Pattern
```javascript
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

class ScriptTemplate {
    constructor(options = {}) {
        this.options = {
            logLevel: 'info',
            dryRun: false,
            ...options
        };
        this.logger = this.setupLogger();
    }

    setupLogger() {
        // Logger implementation
    }

    async execute() {
        try {
            this.logger.info('Starting script execution');
            await this.validate();
            await this.run();
            await this.cleanup();
            this.logger.info('Script execution completed successfully');
        } catch (error) {
            this.logger.error('Script execution failed', error);
            throw error;
        }
    }

    async validate() {
        // Validation logic
    }

    async run() {
        // Main execution logic
    }

    async cleanup() {
        // Cleanup logic
    }
}

module.exports = ScriptTemplate;
```

### Error Handling Pattern
```javascript
class ErrorHandler {
    static handle(error, context = {}) {
        const errorInfo = {
            message: error.message,
            stack: error.stack,
            context,
            timestamp: new Date().toISOString(),
            environment: process.env.NODE_ENV
        };

        console.error('Error occurred:', JSON.stringify(errorInfo, null, 2));
        return errorInfo;
    }

    static async withRetry(fn, maxRetries = 3, delay = 1000) {
        for (let i = 0; i < maxRetries; i++) {
            try {
                return await fn();
            } catch (error) {
                if (i === maxRetries - 1) throw error;
                await new Promise(resolve => setTimeout(resolve, delay * (i + 1)));
            }
        }
    }
}
```

### Bulk Operations Pattern
```javascript
class BulkOperations {
    static async processInBatches(records, batchSize = 200, operation) {
        const batches = [];
        for (let i = 0; i < records.length; i += batchSize) {
            batches.push(records.slice(i, i + batchSize));
        }

        const results = [];
        for (const batch of batches) {
            const batchResult = await operation(batch);
            results.push(batchResult);
            await this.delay(100); // Respect API limits
        }

        return results;
    }

    static delay(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}
```

### Data Validation Pattern
```javascript
class DataValidator {
    static validateEmail(email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    }

    static validateRequired(record, requiredFields) {
        const missing = requiredFields.filter(field => !record[field]);
        return {
            isValid: missing.length === 0,
            missingFields: missing
        };
    }

    static validateRecord(record, rules) {
        const errors = [];
        
        for (const [field, rule] of Object.entries(rules)) {
            if (rule.required && !record[field]) {
                errors.push(`${field} is required`);
            }
            
            if (record[field] && rule.validator) {
                const isValid = rule.validator(record[field]);
                if (!isValid) {
                    errors.push(`${field} failed validation`);
                }
            }
        }
        
        return {
            isValid: errors.length === 0,
            errors
        };
    }
}
```

---

## Troubleshooting

### Common Salesforce CLI Issues

**Authentication Issues:**
```bash
# Clear stored credentials
sf org logout --all

# Re-authenticate
sf org login web --instance-url https://your-instance.salesforce.com

# Check org status
sf org display --target-org your-org-alias
```

**Permission Issues:**
```bash
# Check user permissions
sf org display user --target-org your-org-alias

# List available orgs
sf org list --all

# Check org access
sf org open --target-org your-org-alias
```

**Connection Issues:**
```bash
# Set timeout
sf config set timeout 120000

# Check network connectivity
ping your-instance.salesforce.com

# Clear cache
sf config unset target-org
```

### Common Cursor Issues

**Extension Conflicts:**
```bash
# Disable extensions
code --disable-extensions

# Reset Cursor settings
code --reset-extensions

# Check extension status
code --list-extensions
```

**Performance Issues:**
```bash
# Disable GPU acceleration
code --disable-gpu

# Increase memory limit
code --max-memory=4096

# Clear workspace cache
rm -rf ~/.cursor/workspaceStorage/*
```

**Debugging:**
```bash
# Enable verbose logging
code --verbose

# Open developer tools
code --inspect-extensions

# Check logs
code --log-level=debug
```

---

## Best Practices

### Code Organization
- Use consistent naming conventions
- Implement proper error handling
- Write self-documenting code
- Follow DRY principle
- Use meaningful variable names

### Salesforce Development
- Respect governor limits
- Use bulk operations for large datasets
- Implement proper sharing and security
- Write comprehensive test coverage
- Use metadata API for deployments

### Performance Optimization
- Use selective queries
- Implement proper indexing
- Use SOSL for text searches
- Limit result sets
- Use aggregate queries when possible

### Security Best Practices
- Use OAuth 2.0 for API access
- Implement proper session management
- Use least privilege principle
- Regular security audits
- Secure credential storage

### Documentation Standards
- Document all public APIs
- Use JSDoc for JavaScript functions
- Keep README files updated
- Document deployment procedures
- Maintain change logs

### Testing Strategy
- Write unit tests for all functions
- Implement integration tests
- Use test data factories
- Mock external dependencies
- Maintain test coverage > 80%

---

## Environment Variables

### Required Variables
```bash
# Salesforce Authentication
SF_USERNAME=your-username
SF_PASSWORD=your-password
SF_SECURITY_TOKEN=your-token
SF_INSTANCE_URL=https://your-instance.salesforce.com

# Development Settings
NODE_ENV=development
DEBUG=true
LOG_LEVEL=debug

# API Limits & Timeouts
BULK_API_TIMEOUT=300000
SOQL_QUERY_LIMIT=2000
BATCH_SIZE=200
```

### Optional Variables
```bash
# Performance Tuning
MAX_CONCURRENT_REQUESTS=5
RETRY_DELAY=1000
MAX_RETRIES=3

# Monitoring
ENABLE_METRICS=true
METRICS_ENDPOINT=https://your-metrics-endpoint.com

# Security
ENCRYPTION_KEY=your-encryption-key
AUDIT_LOG_ENABLED=true
```

---

## Quick Commands Reference

### Development Workflow
```bash
# Start new feature
git checkout -b feature/new-feature
npm install
npm run lint

# Make changes and test
npm run test:unit
npm run prettier

# Commit and push
git add .
git commit -m "feat: add new feature"
git push origin feature/new-feature
```

### Data Operations
```bash
# Generate test data
npm run generate:leads:simple

# Import data
npm run import:leads:batch

# Query data
npm run soql:count

# Deploy data
npm run deploy:leads
```

### Flow Management
```bash
# Create flows
npm run flow:create

# Deploy flows
npm run flow:deploy

# List flows
npm run flow:list
```

### Testing
```bash
# Run all tests
npm run test

# Run with coverage
npm run test:unit:coverage

# Run specific test
npm run test -- --testNamePattern="specific test"
```

---

## Support Resources

### Documentation
- [Salesforce CLI Documentation](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)
- [Cursor Documentation](https://cursor.sh/docs)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)

### Community Resources
- Salesforce Developer Community
- Stack Overflow
- GitHub repositories
- Official Salesforce blogs

### Support Channels
- Salesforce Developer Support
- Cursor Support
- Community forums
- Professional networks













