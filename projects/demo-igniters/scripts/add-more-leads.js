const { execSync } = require('child_process');

console.log('🚀 Adding more leads to your Salesforce org...\n');

// Get current count first
try {
  const currentCount = execSync('sfdx force:data:soql:query --query "SELECT COUNT() FROM Lead"', { 
    stdio: 'pipe',
    encoding: 'utf8'
  });
  
  const match = currentCount.match(/Total number of records retrieved: (\d+)/);
  if (match) {
    const count = parseInt(match[1]);
    console.log(`📊 Current lead count: ${count}`);
  }
} catch (error) {
  console.log('⚠️  Could not get current count');
}

// Calculate how many batches to run
const TARGET_LEADS = 1000;
const BATCH_SIZE = 50;
const BATCHES_TO_RUN = 12; // This will add 600 leads

console.log(`📦 Running ${BATCHES_TO_RUN} batches to add ${BATCHES_TO_RUN * BATCH_SIZE} leads\n`);

let successfulBatches = 0;

for (let i = 1; i <= BATCHES_TO_RUN; i++) {
  console.log(`🔄 Running Batch ${i}/${BATCHES_TO_RUN}...`);
  
  try {
    const result = execSync('sfdx force:apex:execute -f scripts/import-leads-unique.apex', { 
      stdio: 'pipe',
      encoding: 'utf8'
    });
    
    if (result.includes('Successfully inserted 50 unique leads')) {
      console.log(`✅ Batch ${i} completed: 50 leads added`);
      successfulBatches++;
    } else {
      console.log(`⚠️  Batch ${i} may have had issues`);
    }
    
  } catch (error) {
    console.error(`❌ Error in Batch ${i}:`, error.message);
  }
  
  // Wait between batches
  if (i < BATCHES_TO_RUN) {
    console.log('⏳ Waiting 3 seconds before next batch...\n');
    setTimeout(() => {}, 3000);
  }
}

console.log(`🎉 Completed! Successfully ran ${successfulBatches} batches`);

// Check final count
setTimeout(() => {
  try {
    const finalCount = execSync('sfdx force:data:soql:query --query "SELECT COUNT() FROM Lead"', { 
      stdio: 'pipe',
      encoding: 'utf8'
    });
    
    const match = finalCount.match(/Total number of records retrieved: (\d+)/);
    if (match) {
      const count = parseInt(match[1]);
      console.log(`📈 Final lead count: ${count}`);
      
      if (count >= 1000) {
        console.log('🎉 Success! You now have 1000+ leads for Einstein Lead Scoring!');
      } else {
        console.log(`📊 You have ${count} leads. Run more batches if needed.`);
      }
    }
  } catch (error) {
    console.log('⚠️  Could not verify final count');
  }
  
  console.log('\n📋 Next steps:');
  console.log('1. Enable Einstein Lead Scoring in your org');
  console.log('2. Wait 24-48 hours for Einstein to process the leads');
  console.log('3. Monitor lead scores in the Lead object');
}, 5000); 