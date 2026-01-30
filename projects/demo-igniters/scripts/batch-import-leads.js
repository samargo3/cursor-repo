const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

console.log('🚀 Starting batch import of 1000 leads...\n');

// Read the CSV file
const csvPath = path.join(__dirname, '..', 'data', 'leads-simple.csv');
if (!fs.existsSync(csvPath)) {
  console.error('❌ leads-simple.csv not found. Please run generate-leads-simple.js first.');
  process.exit(1);
}

const csvContent = fs.readFileSync(csvPath, 'utf8');
const lines = csvContent.split('\n');
const header = lines[0];
const dataLines = lines.slice(1).filter(line => line.trim() !== '');

console.log(`📊 Found ${dataLines.length} leads to import`);

// Split into batches of 200
const BATCH_SIZE = 200;
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
  
  // Create Apex script for this batch
  const apexScript = createApexScript(batch, header, batchNumber);
  const apexPath = path.join(__dirname, `batch-${batchNumber}.apex`);
  fs.writeFileSync(apexPath, apexScript);
  
  // Execute the Apex script
  try {
    console.log(`📤 Executing Batch ${batchNumber}...`);
    const result = execSync(`sfdx force:apex:execute -f ${apexPath}`, { 
      stdio: 'pipe',
      encoding: 'utf8'
    });
    
    // Check if leads were inserted successfully
    if (result.includes('Successfully inserted')) {
      const match = result.match(/Successfully inserted (\d+) leads/);
      if (match) {
        const imported = parseInt(match[1]);
        totalImported += imported;
        console.log(`✅ Batch ${batchNumber} completed: ${imported} leads imported`);
      } else {
        console.log(`✅ Batch ${batchNumber} completed`);
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

console.log(`🎉 Batch import completed!`);
console.log(`📊 Total leads processed: ${dataLines.length}`);
console.log(`✅ Total leads imported: ${totalImported}`);

// Verify the final count
try {
  const countResult = execSync('sfdx force:data:soql:query --query "SELECT COUNT() FROM Lead"', { 
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
console.log('3. Wait for Einstein to process the leads (may take 24-48 hours)');
console.log('4. Monitor lead scores in the Lead object');

function createApexScript(batch, header, batchNumber) {
  const csvData = header + '\n' + batch.join('\n');
  
  return `// Batch ${batchNumber} - Import ${batch.length} leads
String csvData = '${csvData.replace(/'/g, "\\'").replace(/\n/g, "\\n")}';

String[] lines = csvData.split('\\n');
List<Lead> leadsToInsert = new List<Lead>();

// Skip header
for(Integer i = 1; i < lines.size(); i++) {
    String line = lines[i];
    if(String.isNotBlank(line)) {
        String[] fields = line.split(',');
        if(fields.size() >= 15) {
            Lead l = new Lead();
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
            l.AnnualRevenue = Decimal.valueOf(fields[12]);
            l.NumberOfEmployees = Integer.valueOf(fields[13]);
            l.Description = fields[14].removeStart('"').removeEnd('"');
            
            leadsToInsert.add(l);
        }
    }
}

if(!leadsToInsert.isEmpty()) {
    try {
        insert leadsToInsert;
        System.debug('Successfully inserted ' + leadsToInsert.size() + ' leads (Batch ${batchNumber})');
    } catch(Exception e) {
        System.debug('Error inserting leads: ' + e.getMessage());
    }
}`;
} 