#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

/**
 * Deploy Einstein-Optimized Leads to Salesforce
 * Deploys high-tech B2B leads with all fields needed for Einstein Lead Scoring
 */

class EinsteinLeadDeployer {
    constructor(targetOrg = 'agentforce-for-sales-demo-org') {
        this.targetOrg = targetOrg;
        this.dataDir = path.join(__dirname, '..', 'data');
    }

    // Deploy leads using Bulk API (recommended for large datasets)
    async deployLeadsBulk(csvPath) {
        console.log(`🚀 Deploying leads to ${this.targetOrg} using Bulk API...\n`);
        
        if (!fs.existsSync(csvPath)) {
            console.error(`❌ CSV file not found: ${csvPath}`);
            return false;
        }

        try {
            // Read CSV to get count
            const csvContent = fs.readFileSync(csvPath, 'utf8');
            const lines = csvContent.split('\n').filter(line => line.trim() !== '');
            const dataLines = lines.slice(1); // Skip header
            console.log(`📊 Found ${dataLines.length} leads to import`);

            // Split into batches of 200 (Bulk API limit)
            const BATCH_SIZE = 200;
            const batches = [];
            
            for (let i = 0; i < dataLines.length; i += BATCH_SIZE) {
                batches.push(dataLines.slice(i, i + BATCH_SIZE));
            }

            console.log(`📦 Creating ${batches.length} batches of ${BATCH_SIZE} leads each\n`);

            let totalImported = 0;
            let successfulBatches = 0;

            for (let batchIndex = 0; batchIndex < batches.length; batchIndex++) {
                const batch = batches[batchIndex];
                const batchNumber = batchIndex + 1;
                
                console.log(`🔄 Processing Batch ${batchNumber}/${batches.length} (${batch.length} leads)...`);
                
                // Create CSV file for this batch
                const header = lines[0];
                const batchCsv = header + '\n' + batch.join('\n');
                const batchCsvPath = path.join(__dirname, `batch-${batchNumber}.csv`);
                fs.writeFileSync(batchCsvPath, batchCsv);
                
                try {
                    // Use Bulk API to insert
                    console.log(`📤 Importing Batch ${batchNumber} via Bulk API...`);
                    const result = execSync(`sfdx force:data:bulk:upsert --sobject Lead --file ${batchCsvPath} --target-org ${this.targetOrg}`, { 
                        stdio: 'pipe',
                        encoding: 'utf8'
                    });
                    
                    // Extract job ID for status check
                    const jobMatch = result.match(/Check batch #1's status with the command:\nsf force data bulk status -i ([^-]+) -b ([^-]+)/);
                    
                    if (jobMatch) {
                        const jobId = jobMatch[1];
                        const batchId = jobMatch[2];
                        
                        // Wait for processing
                        console.log('⏳ Waiting for batch to process...');
                        await this.sleep(5000);
                        
                        try {
                            const statusResult = execSync(`sfdx force:data:bulk:status -i ${jobId} -b ${batchId} --target-org ${this.targetOrg}`, { 
                                stdio: 'pipe',
                                encoding: 'utf8'
                            });
                            
                            if (statusResult.includes('Completed') && !statusResult.includes('Failed')) {
                                const processedMatch = statusResult.match(/numberRecordsProcessed:\s+(\d+)/);
                                if (processedMatch) {
                                    const processed = parseInt(processedMatch[1]);
                                    totalImported += processed;
                                    successfulBatches++;
                                    console.log(`✅ Batch ${batchNumber} completed: ${processed} leads imported`);
                                } else {
                                    console.log(`✅ Batch ${batchNumber} completed`);
                                    successfulBatches++;
                                }
                            } else {
                                console.log(`⚠️  Batch ${batchNumber} may have had issues. Check the status above.`);
                            }
                        } catch (statusError) {
                            console.log(`⚠️  Could not check status for Batch ${batchNumber}`);
                        }
                        
                    } else {
                        console.log(`✅ Batch ${batchNumber} submitted for processing`);
                        successfulBatches++;
                    }
                    
                } catch (error) {
                    console.error(`❌ Error importing Batch ${batchNumber}:`, error.message);
                }
                
                // Clean up the temporary CSV file
                try {
                    fs.unlinkSync(batchCsvPath);
                } catch (error) {
                    // Ignore cleanup errors
                }
                
                // Wait between batches to avoid overwhelming the API
                if (batchIndex < batches.length - 1) {
                    console.log('⏳ Waiting 3 seconds before next batch...\n');
                    await this.sleep(3000);
                }
            }

            console.log(`\n🎉 Bulk deployment completed!`);
            console.log(`📊 Successful batches: ${successfulBatches}/${batches.length}`);
            console.log(`📈 Total leads processed: ${totalImported}`);
            
            return { success: true, totalImported, successfulBatches, totalBatches: batches.length };
            
        } catch (error) {
            console.error('❌ Bulk deployment failed:', error.message);
            return { success: false, error: error.message };
        }
    }

    // Deploy leads using Apex (alternative method)
    async deployLeadsApex(csvPath) {
        console.log(`🚀 Deploying leads to ${this.targetOrg} using Apex...\n`);
        
        if (!fs.existsSync(csvPath)) {
            console.error(`❌ CSV file not found: ${csvPath}`);
            return false;
        }

        try {
            const csvContent = fs.readFileSync(csvPath, 'utf8');
            const lines = csvContent.split('\n').filter(line => line.trim() !== '');
            const header = lines[0];
            const dataLines = lines.slice(1);
            
            console.log(`📊 Found ${dataLines.length} leads to import`);

            // Split into batches of 200
            const BATCH_SIZE = 200;
            const batches = [];
            
            for (let i = 0; i < dataLines.length; i += BATCH_SIZE) {
                batches.push(dataLines.slice(i, i + BATCH_SIZE));
            }

            console.log(`📦 Creating ${batches.length} batches of ${BATCH_SIZE} leads each\n`);

            let totalImported = 0;
            let successfulBatches = 0;

            for (let batchIndex = 0; batchIndex < batches.length; batchIndex++) {
                const batch = batches[batchIndex];
                const batchNumber = batchIndex + 1;
                
                console.log(`🔄 Processing Batch ${batchNumber}/${batches.length} (${batch.length} leads)...`);
                
                // Create Apex script for this batch
                const apexScript = this.createApexScript(batch, header, batchNumber);
                const apexPath = path.join(__dirname, `batch-${batchNumber}.apex`);
                fs.writeFileSync(apexPath, apexScript);
                
                try {
                    console.log(`📤 Executing Batch ${batchNumber}...`);
                    const result = execSync(`sfdx force:apex:execute -f ${apexPath} --target-org ${this.targetOrg}`, { 
                        stdio: 'pipe',
                        encoding: 'utf8'
                    });
                    
                    if (result.includes('Successfully inserted')) {
                        const match = result.match(/Successfully inserted (\d+) leads/);
                        if (match) {
                            const imported = parseInt(match[1]);
                            totalImported += imported;
                            successfulBatches++;
                            console.log(`✅ Batch ${batchNumber} completed: ${imported} leads imported`);
                        } else {
                            console.log(`✅ Batch ${batchNumber} completed`);
                            successfulBatches++;
                        }
                    } else {
                        console.log(`⚠️  Batch ${batchNumber} may have had issues. Check the output above.`);
                    }
                    
                } catch (error) {
                    console.error(`❌ Error executing Batch ${batchNumber}:`, error.message);
                }
                
                // Clean up the temporary Apex file
                try {
                    fs.unlinkSync(apexPath);
                } catch (error) {
                    // Ignore cleanup errors
                }
                
                console.log(''); // Empty line for readability
            }

            console.log(`\n🎉 Apex deployment completed!`);
            console.log(`📊 Successful batches: ${successfulBatches}/${batches.length}`);
            console.log(`📈 Total leads imported: ${totalImported}`);
            
            return { success: true, totalImported, successfulBatches, totalBatches: batches.length };
            
        } catch (error) {
            console.error('❌ Apex deployment failed:', error.message);
            return { success: false, error: error.message };
        }
    }

    // Create Apex script for batch processing
    createApexScript(batch, header, batchNumber) {
        const csvData = header + '\n' + batch.join('\n');
        
        return `// Batch ${batchNumber} - Import ${batch.length} Einstein-optimized leads
String csvData = '${csvData.replace(/'/g, "\\'").replace(/\n/g, "\\n")}';

String[] lines = csvData.split('\\n');
List<Lead> leadsToInsert = new List<Lead>();

// Skip header
for(Integer i = 1; i < lines.size(); i++) {
    String line = lines[i];
    if(String.isNotBlank(line)) {
        String[] fields = line.split(',');
        if(fields.size() >= 20) {
            Lead l = new Lead();
            
            // Standard fields
            l.FirstName = fields[0].removeStart('"').removeEnd('"');
            l.LastName = fields[1].removeStart('"').removeEnd('"');
            l.Company = fields[2].removeStart('"').removeEnd('"');
            l.Email = fields[3].removeStart('"').removeEnd('"');
            l.Phone = fields[4].removeStart('"').removeEnd('"');
            l.Industry = fields[5].removeStart('"').removeEnd('"');
            l.LeadSource = fields[6].removeStart('"').removeEnd('"');
            l.Status = fields[7].removeStart('"').removeEnd('"');
            l.Title = fields[8].removeStart('"').removeEnd('"');
            l.State = fields[9].removeStart('"').removeEnd('"');
            l.City = fields[10].removeStart('"').removeEnd('"');
            l.Country = fields[11].removeStart('"').removeEnd('"');
            l.Website = fields[12].removeStart('"').removeEnd('"');
            l.Description = fields[13].removeStart('"').removeEnd('"');
            
            // Einstein-optimized fields
            l.AnnualRevenue = Decimal.valueOf(fields[14]);
            l.NumberOfEmployees = Integer.valueOf(fields[15]);
            l.Lead_Score__c = Decimal.valueOf(fields[16]);
            l.Company_Size__c = fields[17].removeStart('"').removeEnd('"');
            l.Revenue_Range__c = fields[18].removeStart('"').removeEnd('"');
            l.Tech_Stack__c = fields[19].removeStart('"').removeEnd('"');
            l.Decision_Maker__c = Boolean.valueOf(fields[20]);
            l.Budget_Range__c = fields[21].removeStart('"').removeEnd('"');
            l.Timeline__c = fields[22].removeStart('"').removeEnd('"');
            l.Pain_Points__c = fields[23].removeStart('"').removeEnd('"');
            l.Use_Case__c = fields[24].removeStart('"').removeEnd('"');
            
            leadsToInsert.add(l);
        }
    }
}

if(!leadsToInsert.isEmpty()) {
    try {
        insert leadsToInsert;
        System.debug('Successfully inserted ' + leadsToInsert.size() + ' Einstein-optimized leads (Batch ${batchNumber})');
    } catch(Exception e) {
        System.debug('Error inserting leads: ' + e.getMessage());
    }
}`;
    }

    // Verify deployment
    async verifyDeployment() {
        console.log('\n🔍 Verifying deployment...');
        
        try {
            const countResult = execSync(`sfdx force:data:soql:query --query "SELECT COUNT() FROM Lead" --target-org ${this.targetOrg}`, { 
                stdio: 'pipe',
                encoding: 'utf8'
            });
            
            const match = countResult.match(/Total number of records retrieved: (\d+)/);
            if (match) {
                const finalCount = parseInt(match[1]);
                console.log(`📈 Total leads in org: ${finalCount}`);
                return finalCount;
            }
        } catch (error) {
            console.log('⚠️  Could not verify lead count');
        }
        
        return 0;
    }

    // Check Einstein Lead Scoring status
    async checkEinsteinStatus() {
        console.log('\n🧠 Checking Einstein Lead Scoring status...');
        
        try {
            // Check if Einstein is enabled
            const einsteinResult = execSync(`sfdx force:data:soql:query --query "SELECT Id, Name FROM EinsteinLeadScoringSettings LIMIT 1" --target-org ${this.targetOrg}`, { 
                stdio: 'pipe',
                encoding: 'utf8'
            });
            
            if (einsteinResult.includes('Total number of records retrieved: 1')) {
                console.log('✅ Einstein Lead Scoring is enabled');
            } else {
                console.log('⚠️  Einstein Lead Scoring may not be enabled');
                console.log('   Please enable it in Setup → Einstein → Lead Scoring');
            }
        } catch (error) {
            console.log('⚠️  Could not check Einstein status');
        }
    }

    // Sleep utility
    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    // Main deployment method
    async deploy(csvPath, method = 'bulk') {
        console.log('🚀 Einstein Lead Deployer');
        console.log('========================\n');
        
        if (!fs.existsSync(csvPath)) {
            console.error(`❌ CSV file not found: ${csvPath}`);
            return false;
        }

        console.log(`📁 CSV file: ${csvPath}`);
        console.log(`🏢 Target org: ${this.targetOrg}`);
        console.log(`🔧 Method: ${method.toUpperCase()}\n`);

        let result;
        if (method === 'bulk') {
            result = await this.deployLeadsBulk(csvPath);
        } else {
            result = await this.deployLeadsApex(csvPath);
        }

        if (result.success) {
            await this.verifyDeployment();
            await this.checkEinsteinStatus();
            
            console.log('\n📋 Next steps:');
            console.log('1. Verify leads in your Salesforce org');
            console.log('2. Enable Einstein Lead Scoring if not already enabled');
            console.log('3. Wait for Einstein to process the leads (24-48 hours)');
            console.log('4. Monitor lead scores in the Lead object');
            console.log('5. Set up Einstein Lead Scoring models and rules');
        }

        return result;
    }
}

// CLI Interface
const args = process.argv.slice(2);
const csvPath = args[0] || path.join(__dirname, '..', 'data', 'einstein-leads.csv');
const method = args[1] || 'bulk';
const targetOrg = args[2] || 'agentforce-for-sales-demo-org';

if (args.length === 0 || args.includes('--help')) {
    console.log(`
🚀 Einstein Lead Deployer

Usage:
  node deploy-einstein-leads.js [csvPath] [method] [targetOrg]

Arguments:
  csvPath    Path to CSV file (default: data/einstein-leads.csv)
  method     Deployment method: 'bulk' or 'apex' (default: bulk)
  targetOrg  Target Salesforce org alias (default: agentforce-for-sales-demo-org)

Examples:
  node deploy-einstein-leads.js
  node deploy-einstein-leads.js data/my-leads.csv
  node deploy-einstein-leads.js data/my-leads.csv apex
  node deploy-einstein-leads.js data/my-leads.csv bulk my-org

Methods:
  bulk  - Uses Salesforce Bulk API (recommended for large datasets)
  apex  - Uses Apex scripts (alternative method)
`);
    process.exit(0);
}

const deployer = new EinsteinLeadDeployer(targetOrg);
deployer.deploy(csvPath, method);
