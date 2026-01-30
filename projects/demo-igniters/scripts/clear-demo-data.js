#!/usr/bin/env node

/**
 * Clear Demo Data Script
 * Removes all demo data from the org
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const ORG_ALIAS = process.argv[2] || 'a4sales-demo-org';

console.log('🧹 Clearing demo data...');
console.log(`📍 Target org: ${ORG_ALIAS}\n`);

const apexScript = `// Clear all demo data
Map<String, Integer> results = DemoDataSeeder.clearDemoData();

// Output results
System.debug('✅ Demo Data Cleared Successfully!');
System.debug('📊 Accounts deleted: ' + results.get('accountsDeleted'));
System.debug('👥 Contacts deleted: ' + results.get('contactsDeleted'));
System.debug('💼 Opportunities deleted: ' + results.get('opportunitiesDeleted'));
`;

try {
    console.log('📝 Executing Apex clearing script...\n');
    
    // Write to temp file
    const tempFile = path.join(__dirname, '.temp-clear.apex');
    fs.writeFileSync(tempFile, apexScript);
    
    // Execute the apex script
    execSync(`sf apex run --target-org ${ORG_ALIAS} --file ${tempFile}`, {
        stdio: 'inherit',
        encoding: 'utf-8'
    });
    
    // Clean up temp file
    fs.unlinkSync(tempFile);
    
    console.log('\n✅ Demo data cleared successfully!\n');
    
} catch (error) {
    console.error('❌ Error clearing demo data:', error.message);
    // Clean up temp file if it exists
    try {
        const tempFile = path.join(__dirname, '.temp-clear.apex');
        if (fs.existsSync(tempFile)) {
            fs.unlinkSync(tempFile);
        }
    } catch (cleanupError) {
        // Ignore cleanup errors
    }
    process.exit(1);
}

