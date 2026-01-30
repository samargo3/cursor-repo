const { execSync } = require('child_process');

console.log('🚀 Running multiple batches to reach 1000 leads...\n');

// We need to run the Apex script multiple times to get to 1000 leads
// Current: 432 leads, Target: 1000 leads, Need: ~568 more leads
// Each batch adds 50 leads, so we need about 12 more batches

const TOTAL_BATCHES = 12;
let currentBatch = 1;

for (let i = 0; i < TOTAL_BATCHES; i++) {
  console.log(`🔄 Running Batch ${currentBatch} (${i + 1}/${TOTAL_BATCHES})...`);
  
  try {
    const result = execSync('sfdx force:apex:execute -f scripts/import-all-leads-apex.apex', { 
      stdio: 'pipe',
      encoding: 'utf8'
    });
    
    if (result.includes('Successfully inserted 50 leads')) {
      console.log(`✅ Batch ${currentBatch} completed: 50 leads imported`);
      currentBatch++;
    } else {
      console.log(`⚠️  Batch ${currentBatch} may have had issues`);
    }
    
  } catch (error) {
    console.error(`❌ Error in Batch ${currentBatch}:`, error.message);
  }
  
  // Wait between batches
  if (i < TOTAL_BATCHES - 1) {
    console.log('⏳ Waiting 3 seconds before next batch...\n');
    setTimeout(() => {}, 3000);
  }
}

console.log(`🎉 All batches completed!`);

// Check final count
setTimeout(() => {
  try {
    const countResult = execSync('sfdx force:data:soql:query --query "SELECT COUNT() FROM Lead"', { 
      stdio: 'pipe',
      encoding: 'utf8'
    });
    
    const match = countResult.match(/Total number of records retrieved: (\d+)/);
    if (match) {
      const finalCount = parseInt(match[1]);
      console.log(`📈 Final lead count in org: ${finalCount}`);
      
      if (finalCount >= 1000) {
        console.log('🎉 Success! You now have 1000+ leads for Einstein Lead Scoring!');
      } else {
        console.log(`📊 You have ${finalCount} leads. Run more batches if needed.`);
      }
    }
  } catch (error) {
    console.log('⚠️  Could not verify final lead count');
  }
  
  console.log('\n📋 Next steps:');
  console.log('1. Enable Einstein Lead Scoring in your org');
  console.log('2. Wait 24-48 hours for Einstein to process the leads');
  console.log('3. Monitor lead scores in the Lead object');
}, 5000); 