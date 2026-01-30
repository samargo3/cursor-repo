const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Get command line arguments
const soqlFile = process.argv[2];
const outputFile = process.argv[3]; // Optional output file

if (!soqlFile) {
  console.log('🚀 Advanced SOQL File Runner');
  console.log('=============================');
  console.log('Usage: node scripts/run-soql-advanced.js <soql-file> [output-file]');
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
  console.log('  node scripts/run-soql-advanced.js leads-count');
  console.log('  node scripts/run-soql-advanced.js leads-sample results.json');
  console.log('  node scripts/run-soql-advanced.js qualified-leads qualified-leads.csv');
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
  let command;
  
  if (outputFile) {
    // Save results to file
    const outputPath = path.join(__dirname, '..', 'data', outputFile);
    console.log(`💾 Results will be saved to: ${outputPath}`);
    
    if (outputFile.endsWith('.json')) {
      command = `sf data query --query "${query}" --result-format json > "${outputPath}"`;
    } else if (outputFile.endsWith('.csv')) {
      command = `sf data query --query "${query}" --result-format csv > "${outputPath}"`;
    } else {
      command = `sf data query --query "${query}" > "${outputPath}"`;
    }
  } else {
    // Display results in terminal
    command = `sf data query --query "${query}"`;
  }
  
  const result = execSync(command, { 
    stdio: outputFile ? 'pipe' : 'inherit',
    encoding: 'utf8',
    cwd: path.join(__dirname, '..')
  });
  
  if (outputFile) {
    console.log(`✅ Query completed and saved to: data/${outputFile}`);
  } else {
    console.log('\n✅ Query completed successfully!');
  }
  
} catch (error) {
  console.error('❌ Error running SOQL query:', error.message);
  process.exit(1);
}

