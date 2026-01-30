#!/usr/bin/env node

const readline = require('readline');
const { execSync } = require('child_process');
const path = require('path');

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

const industries = [
    'Technology',
    'Healthcare', 
    'Financial Services',
    'Manufacturing',
    'Retail',
    'Education',
    'Real Estate',
    'Consulting',
    'Legal Services',
    'Government'
];

function question(prompt) {
    return new Promise((resolve) => {
        rl.question(prompt, resolve);
    });
}

async function quickLeads() {
    console.log('\n🎯 Quick Lead Generator');
    console.log('======================\n');

    try {
        // Get company name
        const company = await question('Enter company name: ');
        if (!company.trim()) {
            console.log('❌ Company name is required');
            rl.close();
            return;
        }

        // Get website
        const website = await question('Enter website (e.g., company.com): ');
        if (!website.trim()) {
            console.log('❌ Website is required');
            rl.close();
            return;
        }

        // Show industries
        console.log('\nAvailable industries:');
        industries.forEach((industry, index) => {
            console.log(`${index + 1}. ${industry}`);
        });

        // Get industry selection
        const industryChoice = await question('\nSelect industry (1-10): ');
        const industryIndex = parseInt(industryChoice) - 1;
        
        if (industryIndex < 0 || industryIndex >= industries.length) {
            console.log('❌ Invalid industry selection');
            rl.close();
            return;
        }

        const industry = industries[industryIndex];

        // Get number of leads
        const numLeadsInput = await question('Number of leads to generate (default: 100): ');
        const numLeads = numLeadsInput.trim() ? parseInt(numLeadsInput) : 100;

        if (isNaN(numLeads) || numLeads <= 0) {
            console.log('❌ Invalid number of leads');
            rl.close();
            return;
        }

        // Get target org
        const targetOrg = await question('Target Salesforce org (default: sargo@demo.com): ');
        const org = targetOrg.trim() || 'sargo@demo.com';

        // Confirm details
        console.log('\n📋 Summary:');
        console.log(`Company: ${company}`);
        console.log(`Website: ${website}`);
        console.log(`Industry: ${industry}`);
        console.log(`Leads: ${numLeads}`);
        console.log(`Target Org: ${org}`);

        const confirm = await question('\nProceed? (y/N): ');
        if (confirm.toLowerCase() !== 'y' && confirm.toLowerCase() !== 'yes') {
            console.log('❌ Cancelled');
            rl.close();
            return;
        }

        // Generate and deploy
        console.log('\n🚀 Starting lead generation and deployment...\n');
        
        const command = `node scripts/generate-custom-leads.js "${company}" "${website}" "${industry}" ${numLeads} "${org}"`;
        execSync(command, { encoding: 'utf8', stdio: 'inherit' });

        console.log('\n✅ Process completed successfully!');

    } catch (error) {
        console.error('❌ Error:', error.message);
    } finally {
        rl.close();
    }
}

// Handle command line arguments for non-interactive mode
const args = process.argv.slice(2);

if (args.length >= 3) {
    // Non-interactive mode
    const [company, website, industry, numLeads = 100, targetOrg = 'sargo@demo.com'] = args;
    
    if (!company || !website || !industry) {
        console.log(`
🎯 Quick Lead Generator

Usage:
  node quick-leads.js                    # Interactive mode
  node quick-leads.js <company> <website> <industry> [numLeads] [targetOrg]

Examples:
  node quick-leads.js "TechCorp" "techcorp.com" "Technology" 200
  node quick-leads.js "HealthCare" "healthcare.com" "Healthcare" 150 "my-org"
`);
        process.exit(1);
    }

    const command = `node scripts/generate-custom-leads.js "${company}" "${website}" "${industry}" ${numLeads} "${targetOrg}"`;
    execSync(command, { encoding: 'utf8', stdio: 'inherit' });
} else {
    // Interactive mode
    quickLeads();
}















