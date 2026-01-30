const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Get the SOQL file path from command line argument
const soqlFile = process.argv[2];

if (!soqlFile) {
  console.log('🚀 SOQL File Runner');
  console.log('===================');
  console.log('Usage: node scripts/run-soql.js <soql-file>');
  console.log('');
  console.log('Available SOQL files:');
  
  const soqlDir = path.join(__dirname, 'soql');
  if (fs.existsSync(soqlDir)) {
    const files = fs.readdirSync(soqlDir).filter(file => file.endsWith('.soql'));
    files.forEach(file => {
      console.log(`  ${file.replace('.soql', '')}`);
    });
  }
  
  console.log('');
  console.log('Examples:');
  console.log('  node scripts/run-soql.js leads-count');
  console.log('  node scripts/run-soql.js leads-sample');
  console.log('  node scripts/run-soql.js qualified-leads');
  process.exit(1);
}

// Construct the full path to the SOQL file
const soqlFilePath = path.join(__dirname, 'soql', `${soqlFile}.soql`);

if (!fs.existsSync(soqlFilePath)) {
  console.error(`❌ SOQL file not found: ${soqlFilePath}`);
  process.exit(1);
}

// Read the SOQL query from the file
const query = fs.readFileSync(soqlFilePath, 'utf8').trim();

console.log(`🔍 Running SOQL query from: ${soqlFile}.soql`);
console.log(`📋 Query: ${query}`);
console.log('');

try {
  // Execute the SOQL query using Salesforce CLI
  const command = `sf data query --query "${query}"`;
  const result = execSync(command, { 
    stdio: 'inherit',
    encoding: 'utf8',
    cwd: path.join(__dirname, '..')
  });
  
  console.log('\n✅ Query completed successfully!');
  
} catch (error) {
  console.error('❌ Error running SOQL query:', error.message);
  process.exit(1);
}

