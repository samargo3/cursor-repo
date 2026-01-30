const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

console.log('🚀 Starting lead deployment to Salesforce (Standard Fields Only)...\n');

// Check if leads-standard.csv exists
const leadsPath = path.join(__dirname, '..', 'data', 'leads-standard.csv');
if (!fs.existsSync(leadsPath)) {
  console.error('❌ leads-standard.csv not found. Please run generate-leads-fixed.js first.');
  process.exit(1);
}

// Check if SFDX is installed
try {
  execSync('sf --version', { stdio: 'pipe' });
} catch (error) {
  console.error('❌ Salesforce CLI not found. Please install Salesforce CLI first.');
  console.error('Visit: https://developer.salesforce.com/tools/sfdxcli');
  process.exit(1);
}

// Check if user is authenticated
try {
  execSync('sf org display --json', { stdio: 'pipe' });
} catch (error) {
  console.error('❌ Not connected to a Salesforce org. Please authenticate first:');
  console.error('   sf org login web -a YourOrgAlias');
  process.exit(1);
}

console.log('📊 Using Bulk API to import leads...');

try {
  // Use Bulk API to insert leads
  const command = `sf data upsert bulk --sobject Lead --file ${leadsPath} --external-id Email --wait 10`;
  console.log(`Executing: ${command}`);
  
  const result = execSync(command, { 
    stdio: 'pipe',
    encoding: 'utf8',
    cwd: path.join(__dirname, '..')
  });
  
  console.log('✅ Bulk API import completed successfully!');
  console.log('\n📋 Import Summary:');
  console.log(result);
  
} catch (error) {
  console.error('❌ Bulk API import failed. Trying alternative method...');
  
  try {
    // Alternative: Use data import with smaller batches
    console.log('🔄 Trying data import with smaller batches...');
    
    // Read the CSV and split into smaller chunks
    const csvContent = fs.readFileSync(leadsPath, 'utf8');
    const lines = csvContent.split('\n');
    const header = lines[0];
    const dataLines = lines.slice(1).filter(line => line.trim());
    
    const batchSize = 100;
    const batches = [];
    
    for (let i = 0; i < dataLines.length; i += batchSize) {
      const batch = [header, ...dataLines.slice(i, i + batchSize)];
      const batchPath = path.join(__dirname, '..', 'data', `leads-batch-${Math.floor(i/batchSize) + 1}.csv`);
      fs.writeFileSync(batchPath, batch.join('\n'));
      batches.push(batchPath);
    }
    
    console.log(`📦 Created ${batches.length} batches of ${batchSize} leads each`);
    
    let totalImported = 0;
    for (let i = 0; i < batches.length; i++) {
      console.log(`📤 Importing batch ${i + 1}/${batches.length}...`);
      
      try {
        const command = `sf data upsert bulk --sobject Lead --file ${batches[i]} --external-id Email --wait 10`;
        const result = execSync(command, { 
          stdio: 'pipe',
          encoding: 'utf8',
          cwd: path.join(__dirname, '..')
        });
        
        console.log(`✅ Batch ${i + 1} imported successfully`);
        totalImported += batchSize;
        
        // Clean up batch file
        fs.unlinkSync(batches[i]);
        
      } catch (batchError) {
        console.error(`❌ Batch ${i + 1} failed:`, batchError.message);
      }
    }
    
    console.log(`\n🎉 Import completed! Total leads processed: ${totalImported}`);
    
  } catch (alternativeError) {
    console.error('❌ All import methods failed. Please check your Salesforce org configuration.');
    console.error('Error details:', alternativeError.message);
    
    console.log('\n🔧 Manual Import Instructions:');
    console.log('1. Download the generated CSV file: data/leads-standard.csv');
    console.log('2. Go to Setup → Data Import Wizard in Salesforce');
    console.log('3. Select "Leads" as the object to import');
    console.log('4. Upload the CSV file');
    console.log('5. Map the fields and import');
    
    process.exit(1);
  }
}

console.log('\n🎉 Lead deployment completed successfully!');
console.log('\n📊 Next steps:');
console.log('1. Check your Salesforce org to verify the leads were imported');
console.log('2. Go to Setup → Lead object to see the imported records');
console.log('3. If you want to enable Einstein Lead Scoring:');
console.log('   - Go to Setup → Einstein Lead Scoring');
console.log('   - Follow the setup wizard');
console.log('   - Wait 24-48 hours for processing');

// Clean up
try {
  if (fs.existsSync(leadsPath)) {
    console.log('\n🧹 Keeping leads-standard.csv for reference');
  }
} catch (cleanupError) {
  console.log('Note: Could not clean up temporary files');
}
