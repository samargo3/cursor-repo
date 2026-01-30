#!/usr/bin/env node

/**
 * Seed Demo Data Script
 * Seeds the org with demo accounts, contacts, and opportunities
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const ORG_ALIAS = process.argv[2] || 'a4sales-demo-org';

console.log('🌱 Seeding demo data...');
console.log(`📍 Target org: ${ORG_ALIAS}\n`);

const apexScript = `// Seed all demo data
Map<String, Integer> results = DemoDataSeeder.seedAllDemoData();

// Output results
System.debug('✅ Demo Data Seeded Successfully!');
System.debug('📊 Accounts created: ' + results.get('accounts'));
System.debug('👥 Contacts created: ' + results.get('contacts'));
System.debug('💼 Opportunities created: ' + results.get('opportunities'));
`;

try {
    console.log('📝 Executing Apex seeding script...\n');
    
    // Write to temp file
    const tempFile = path.join(__dirname, '.temp-seed.apex');
    fs.writeFileSync(tempFile, apexScript);
    
    // Execute the apex script
    execSync(`sf apex run --target-org ${ORG_ALIAS} --file ${tempFile}`, {
        stdio: 'inherit',
        encoding: 'utf-8'
    });
    
    // Clean up temp file
    fs.unlinkSync(tempFile);
    
    console.log('\n✅ Demo data seeded successfully!');
    console.log('\n📊 Summary:');
    console.log('   - 10 Accounts');
    console.log('   - 20-30 Contacts');
    console.log('   - 10-30 Opportunities');
    console.log('\n🚀 Open your Sales Demo Hub app to view the data!\n');
    
} catch (error) {
    console.error('❌ Error seeding demo data:', error.message);
    // Clean up temp file if it exists
    try {
        const tempFile = path.join(__dirname, '.temp-seed.apex');
        if (fs.existsSync(tempFile)) {
            fs.unlinkSync(tempFile);
        }
    } catch (cleanupError) {
        // Ignore cleanup errors
    }
    process.exit(1);
}

