#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

console.log('🚀 Starting Einstein-optimized lead import using Bulk API...\n');

// Read the Einstein-optimized CSV file
const csvPath = path.join(__dirname, '..', 'data', 'einstein-leads.csv');
if (!fs.existsSync(csvPath)) {
  console.error('❌ einstein-leads.csv not found. Please run generate-einstein-leads.js first.');
  process.exit(1);
}

const csvContent = fs.readFileSync(csvPath, 'utf8');
const lines = csvContent.split('\n');
const header = lines[0];
const dataLines = lines.slice(1).filter(line => line.trim() !== '');

console.log(`📊 Found ${dataLines.length} Einstein-optimized leads to import`);

// Split into smaller batches of 50 (to avoid size limits)
const BATCH_SIZE = 50;
const batches = [];

for (let i = 0; i < dataLines.length; i += BATCH_SIZE) {
  batches.push(dataLines.slice(i, i + BATCH_SIZE));
}

console.log(`📦 Creating ${batches.length} batches of ${BATCH_SIZE} leads each\n`);

// Process each batch
let totalImported = 0;

for (let batchIndex = 0; batchIndex < batches.length; batchIndex++) {
  const batch = batches[batchIndex];
  const batchNumber = batchIndex + 1;
  
  console.log(`🔄 Processing Batch ${batchNumber}/${batches.length} (${batch.length} leads)...`);
  
  // Create CSV file for this batch
  const batchCsv = header + '\n' + batch.join('\n');
  const batchCsvPath = path.join(__dirname, `batch-${batchNumber}.csv`);
  fs.writeFileSync(batchCsvPath, batchCsv);
  
  // Use Bulk API to insert (not upsert, just insert)
  try {
    console.log(`📤 Importing Batch ${batchNumber} via Bulk API...`);
    const result = execSync(`sfdx force:data:bulk:insert --sobject Lead --file ${batchCsvPath} --target-org agentforce-for-sales-demo-org`, { 
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
      setTimeout(() => {
        try {
          const statusResult = execSync(`sfdx force:data:bulk:status -i ${jobId} -b ${batchId} --target-org agentforce-for-sales-demo-org`, { 
            stdio: 'pipe',
            encoding: 'utf8'
          });
          
          if (statusResult.includes('Completed') && !statusResult.includes('Failed')) {
            const processedMatch = statusResult.match(/numberRecordsProcessed:\s+(\d+)/);
            if (processedMatch) {
              const processed = parseInt(processedMatch[1]);
              totalImported += processed;
              console.log(`✅ Batch ${batchNumber} completed: ${processed} leads imported`);
            } else {
              console.log(`✅ Batch ${batchNumber} completed`);
              totalImported += batch.length;
            }
          } else {
            console.log(`⚠️  Batch ${batchNumber} may have had issues. Check the status above.`);
          }
        } catch (statusError) {
          console.log(`⚠️  Could not check status for Batch ${batchNumber}`);
        }
      }, 3000);
      
    } else {
      console.log(`✅ Batch ${batchNumber} submitted for processing`);
      totalImported += batch.length;
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
    console.log('⏳ Waiting 2 seconds before next batch...\n');
    setTimeout(() => {}, 2000);
  }
}

console.log(`🎉 Einstein-optimized lead import completed!`);
console.log(`📊 Total leads processed: ${dataLines.length}`);
console.log(`✅ Total leads imported: ${totalImported}`);

// Wait a bit for final processing, then check count
setTimeout(() => {
  try {
    const countResult = execSync('sfdx force:data:soql:query --query "SELECT COUNT() FROM Lead" --target-org agentforce-for-sales-demo-org', { 
      stdio: 'pipe',
      encoding: 'utf8'
    });
    
    const match = countResult.match(/Total number of records retrieved: (\d+)/);
    if (match) {
      const finalCount = parseInt(match[1]);
      console.log(`📈 Final lead count in org: ${finalCount}`);
    }
  } catch (error) {
    console.log('⚠️  Could not verify final lead count');
  }
  
  console.log('\n📋 Next steps:');
  console.log('1. Check your Salesforce org to verify the leads were imported');
  console.log('2. Enable Einstein Lead Scoring if not already enabled');
  console.log('3. Wait for Einstein to process the leads (24-48 hours)');
  console.log('4. Monitor lead scores in the Lead object');
  console.log('5. Set up Einstein Lead Scoring models and rules');
}, 10000);
