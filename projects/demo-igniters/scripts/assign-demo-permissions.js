#!/usr/bin/env node

/**
 * Assign Demo Permissions Script
 * Assigns the Demo_Permissions permission set to a user
 */

const { execSync } = require('child_process');

const ORG_ALIAS = process.argv[2] || 'a4sales-demo-org';
const USERNAME = process.argv[3]; // Optional - if not provided, uses default user

console.log('🔐 Assigning demo permissions...');
console.log(`📍 Target org: ${ORG_ALIAS}\n`);

try {
    let userFlag = '';
    
    if (USERNAME) {
        console.log(`👤 Target user: ${USERNAME}`);
        userFlag = `--on-behalf-of ${USERNAME}`;
    } else {
        // Get default username
        const result = execSync(`sf org display --target-org ${ORG_ALIAS} --json`, {
            encoding: 'utf-8'
        });
        const orgInfo = JSON.parse(result);
        const defaultUser = orgInfo.result.username;
        console.log(`👤 Target user: ${defaultUser} (default)`);
    }
    
    // Assign permission set
    const cmd = `sf org assign permset --name Demo_Permissions --target-org ${ORG_ALIAS} ${userFlag}`;
    
    console.log('\n📝 Assigning permission set...\n');
    execSync(cmd, { stdio: 'inherit' });
    
    console.log('\n✅ Demo_Permissions assigned successfully!\n');
    console.log('🎯 The user now has access to:');
    console.log('   - Sales Demo Hub app');
    console.log('   - Demo KPIs dashboard');
    console.log('   - Demo data seeder');
    console.log('   - All necessary Apex classes and components\n');
    
} catch (error) {
    console.error('❌ Error assigning permissions:', error.message);
    process.exit(1);
}

