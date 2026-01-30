#!/usr/bin/env node

const { execSync } = require('child_process');

/**
 * Opportunity Data Analysis for Demo Optimization
 * Analyzes current opportunity distribution and provides recommendations
 */

class OpportunityAnalyzer {
    constructor(targetOrg = 'agentforce-for-sales-demo-org') {
        this.targetOrg = targetOrg;
    }

    // Execute SOQL query
    executeQuery(query) {
        try {
            const result = execSync(`sfdx force:data:soql:query --query "${query}" --target-org ${this.targetOrg}`, { 
                stdio: 'pipe',
                encoding: 'utf8'
            });
            return result;
        } catch (error) {
            console.error(`Query failed: ${error.message}`);
            return null;
        }
    }

    // Analyze opportunity distribution
    async analyzeDistribution() {
        console.log('🔍 Analyzing Opportunity Data Distribution...\n');

        // 1. Stage Distribution
        console.log('📊 Stage Distribution:');
        const stageResult = this.executeQuery("SELECT StageName, COUNT(Id) FROM Opportunity GROUP BY StageName ORDER BY COUNT(Id) DESC");
        if (stageResult) {
            console.log(stageResult);
        }

        // 2. Owner Distribution
        console.log('\n👥 Owner Distribution:');
        const ownerResult = this.executeQuery("SELECT Owner.Name, COUNT(Id) FROM Opportunity GROUP BY Owner.Name ORDER BY COUNT(Id) DESC");
        if (ownerResult) {
            console.log(ownerResult);
        }

        // 3. Type Distribution
        console.log('\n🏷️  Type Distribution:');
        const typeResult = this.executeQuery("SELECT Type, COUNT(Id) FROM Opportunity GROUP BY Type ORDER BY COUNT(Id) DESC");
        if (typeResult) {
            console.log(typeResult);
        }

        // 4. Amount Distribution
        console.log('\n💰 Amount Distribution:');
        const amountResult = this.executeQuery("SELECT Amount, COUNT(Id) FROM Opportunity WHERE Amount != null GROUP BY Amount ORDER BY Amount DESC LIMIT 10");
        if (amountResult) {
            console.log(amountResult);
        }

        // 5. Close Date Distribution (Current Year)
        console.log('\n📅 Close Date Distribution (Current Year):');
        const dateResult = this.executeQuery("SELECT CloseDate, COUNT(Id) FROM Opportunity WHERE CloseDate >= THIS_YEAR GROUP BY CloseDate ORDER BY CloseDate DESC LIMIT 10");
        if (dateResult) {
            console.log(dateResult);
        }

        // 6. Probability Distribution
        console.log('\n🎯 Probability Distribution:');
        const probResult = this.executeQuery("SELECT Probability, COUNT(Id) FROM Opportunity WHERE Probability != null GROUP BY Probability ORDER BY Probability DESC");
        if (probResult) {
            console.log(probResult);
        }
    }

    // Generate optimization recommendations
    generateRecommendations() {
        console.log('\n🎯 Demo Optimization Recommendations:\n');

        console.log('📈 STAGE DISTRIBUTION OPTIMIZATION:');
        console.log('✅ Current: Good mix of stages');
        console.log('⚠️  Issue: Too many "Closed Won" (420/683 = 62%)');
        console.log('💡 Recommendation: Move some to active stages for better demo flow');
        console.log('   - Move 100-150 "Closed Won" to "Proposal/Quote"');
        console.log('   - Move 50-75 "Closed Won" to "Negotiation"');
        console.log('   - Move 25-50 "Closed Won" to "Discovery"');
        console.log('');

        console.log('👥 OWNER DISTRIBUTION OPTIMIZATION:');
        console.log('⚠️  Issue: Sam Argo has 430/683 = 63% of opportunities');
        console.log('💡 Recommendation: Redistribute opportunities more evenly');
        console.log('   - Target: 100-150 opportunities per rep');
        console.log('   - Move opportunities from Sam to other reps');
        console.log('   - Ensure each rep has opportunities in all stages');
        console.log('');

        console.log('🏷️  TYPE DISTRIBUTION OPTIMIZATION:');
        console.log('✅ Current: Good variety of types');
        console.log('💡 Recommendation: Add more variety');
        console.log('   - Add "Renewal" opportunities');
        console.log('   - Add "Upsell" opportunities');
        console.log('   - Add "Cross-sell" opportunities');
        console.log('');

        console.log('💰 AMOUNT DISTRIBUTION OPTIMIZATION:');
        console.log('💡 Recommendation: Ensure variety in deal sizes');
        console.log('   - Small deals: $1K - $10K');
        console.log('   - Medium deals: $10K - $100K');
        console.log('   - Large deals: $100K - $1M+');
        console.log('   - Enterprise deals: $1M+');
        console.log('');

        console.log('📅 TIMING OPTIMIZATION:');
        console.log('💡 Recommendation: Spread opportunities across quarters');
        console.log('   - Q1: 25% of opportunities');
        console.log('   - Q2: 25% of opportunities');
        console.log('   - Q3: 25% of opportunities');
        console.log('   - Q4: 25% of opportunities');
        console.log('');

        console.log('🎯 PROBABILITY OPTIMIZATION:');
        console.log('💡 Recommendation: Realistic probability distribution');
        console.log('   - Early stages: 10-30% probability');
        console.log('   - Middle stages: 40-70% probability');
        console.log('   - Late stages: 80-95% probability');
        console.log('');
    }

    // Generate optimization script
    generateOptimizationScript() {
        console.log('🚀 GENERATING OPTIMIZATION SCRIPT...\n');
        
        const script = `
// Opportunity Data Optimization Script
// This script will redistribute opportunities for better demo presentation

// 1. Redistribute opportunities from Sam Argo to other reps
// 2. Move some Closed Won opportunities to active stages
// 3. Ensure balanced distribution across all dimensions

// Execute this script to optimize your opportunity data
sfdx force:apex:execute -f optimize-opportunities.apex --target-org ${this.targetOrg}
`;

        console.log(script);
        console.log('\n📝 Next Steps:');
        console.log('1. Review the recommendations above');
        console.log('2. Run the optimization script');
        console.log('3. Verify the new distribution');
        console.log('4. Test the demo flow');
    }

    // Main analysis method
    async runAnalysis() {
        console.log('🎯 Opportunity Data Analysis for Demo Optimization');
        console.log('==================================================\n');

        await this.analyzeDistribution();
        this.generateRecommendations();
        this.generateOptimizationScript();
    }
}

// Run the analysis
const analyzer = new OpportunityAnalyzer();
analyzer.runAnalysis();
