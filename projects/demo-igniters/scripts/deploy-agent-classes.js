#!/usr/bin/env node

/**
 * @description Deploy Salesforce Agent APEX classes
 * @author Solution Engineering Team
 * @version 1.0
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

class AgentDeploymentManager {
    constructor(options = {}) {
        this.options = {
            testLevel: 'NoTestRun',
            waitTime: 10,
            verbose: true,
            ...options
        };
        this.agentClasses = [
            'AgentActionController',
            'LeadQualificationAgent', 
            'OpportunityInsightAgent',
            'CustomerServiceAgent'
        ];
    }

    /**
     * Deploy all Agent classes
     */
    async deployAll() {
        console.log('🚀 Starting Agent APEX classes deployment...\n');
        
        try {
            // Validate prerequisites
            await this.validatePrerequisites();
            
            // Deploy classes
            await this.deployClasses();
            
            // Verify deployment
            await this.verifyDeployment();
            
            console.log('✅ Agent classes deployed successfully!');
            this.printUsageInstructions();
            
        } catch (error) {
            console.error('❌ Deployment failed:', error.message);
            process.exit(1);
        }
    }

    /**
     * Validate deployment prerequisites
     */
    async validatePrerequisites() {
        console.log('🔍 Validating prerequisites...');
        
        // Check if Salesforce CLI is available
        try {
            execSync('sf --version', { stdio: 'pipe' });
            console.log('✅ Salesforce CLI found');
        } catch (error) {
            throw new Error('Salesforce CLI not found. Please install sf CLI.');
        }
        
        // Check if authenticated to org
        try {
            execSync('sf org display', { stdio: 'pipe' });
            console.log('✅ Authenticated to Salesforce org');
        } catch (error) {
            throw new Error('Not authenticated to Salesforce org. Please run: sf org login web');
        }
        
        // Check if classes exist
        for (const className of this.agentClasses) {
            const classPath = path.join(__dirname, '..', 'force-app', 'main', 'default', 'classes', `${className}.cls`);
            if (!fs.existsSync(classPath)) {
                throw new Error(`Agent class not found: ${className}.cls`);
            }
        }
        
        console.log('✅ All prerequisites validated\n');
    }

    /**
     * Deploy Agent classes
     */
    async deployClasses() {
        console.log('📦 Deploying Agent classes...');
        
        const deployCommand = [
            'sf project deploy start',
            '--source-dir force-app/main/default/classes',
            `--test-level ${this.options.testLevel}`,
            `--wait ${this.options.waitTime}`,
            this.options.verbose ? '--verbose' : ''
        ].filter(Boolean).join(' ');
        
        try {
            console.log(`Executing: ${deployCommand}`);
            execSync(deployCommand, { stdio: 'inherit' });
            console.log('✅ Classes deployed successfully\n');
        } catch (error) {
            throw new Error(`Deployment failed: ${error.message}`);
        }
    }

    /**
     * Verify deployment
     */
    async verifyDeployment() {
        console.log('🔍 Verifying deployment...');
        
        for (const className of this.agentClasses) {
            try {
                const queryCommand = `sf data query --query "SELECT Id, Name FROM ApexClass WHERE Name = '${className}'" --json`;
                const result = execSync(queryCommand, { stdio: 'pipe', encoding: 'utf8' });
                const parsed = JSON.parse(result);
                
                if (parsed.result && parsed.result.records && parsed.result.records.length > 0) {
                    console.log(`✅ ${className} deployed successfully`);
                } else {
                    throw new Error(`${className} not found in org`);
                }
            } catch (error) {
                throw new Error(`Verification failed for ${className}: ${error.message}`);
            }
        }
        
        console.log('✅ All classes verified\n');
    }

    /**
     * Print usage instructions
     */
    printUsageInstructions() {
        console.log('🎯 Agent Classes Usage Instructions:');
        console.log('=====================================\n');
        
        console.log('1. Lead Qualification Agent:');
        console.log('   - Qualify leads: LeadQualificationAgent.qualifyLead(leadId)');
        console.log('   - Batch qualify: LeadQualificationAgent.batchQualifyLeads(leadIds)');
        console.log('   - Get insights: LeadQualificationAgent.getQualificationInsights(leadId)\n');
        
        console.log('2. Opportunity Insight Agent:');
        console.log('   - Analyze opportunity: OpportunityInsightAgent.analyzeOpportunity(oppId)');
        console.log('   - Analyze pipeline: OpportunityInsightAgent.analyzePipeline(ownerId)');
        console.log('   - Get at-risk opps: OpportunityInsightAgent.getAtRiskOpportunities(ownerId)\n');
        
        console.log('3. Customer Service Agent:');
        console.log('   - Analyze case: CustomerServiceAgent.analyzeCase(caseId)');
        console.log('   - Get metrics: CustomerServiceAgent.getServiceMetrics(ownerId, daysBack)');
        console.log('   - Auto-assign: CustomerServiceAgent.autoAssignCase(caseId)\n');
        
        console.log('📚 For detailed usage examples, see:');
        console.log('   - AGENT_APEX_GUIDE.md');
        console.log('   - scripts/apex/agent-examples.apex\n');
        
        console.log('🔧 To test the agents:');
        console.log('   - Run: node scripts/test-agent-classes.js');
        console.log('   - Or use: sf apex run --file scripts/apex/agent-examples.apex\n');
    }
}

// CLI execution
if (require.main === module) {
    const args = process.argv.slice(2);
    const options = {};
    
    // Parse command line arguments
    for (let i = 0; i < args.length; i++) {
        switch (args[i]) {
            case '--test-level':
                options.testLevel = args[++i];
                break;
            case '--wait':
                options.waitTime = parseInt(args[++i]);
                break;
            case '--verbose':
                options.verbose = true;
                break;
            case '--help':
                console.log(`
Usage: node deploy-agent-classes.js [options]

Options:
  --test-level <level>    Test level: NoTestRun, RunSpecifiedTests, RunLocalTests, RunAllTestsInOrg
  --wait <minutes>        Wait time for deployment (default: 10)
  --verbose              Enable verbose output
  --help                 Show this help message

Examples:
  node scripts/deploy-agent-classes.js
  node scripts/deploy-agent-classes.js --test-level RunLocalTests --wait 15
                `);
                process.exit(0);
        }
    }
    
    const deployer = new AgentDeploymentManager(options);
    deployer.deployAll();
}

module.exports = AgentDeploymentManager;
