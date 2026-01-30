const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

console.log('🚀 Starting lead deployment to Salesforce...\n');

// Check if leads.csv exists
const leadsPath = path.join(__dirname, '..', 'data', 'leads.csv');
if (!fs.existsSync(leadsPath)) {
  console.error('❌ leads.csv not found. Please run generate-leads.js first.');
  process.exit(1);
}

// Check if SFDX is installed
try {
  execSync('sfdx --version', { stdio: 'pipe' });
} catch (error) {
  console.error('❌ SFDX CLI not found. Please install Salesforce CLI first.');
  console.error('Visit: https://developer.salesforce.com/tools/sfdxcli');
  process.exit(1);
}

// Check if user is authenticated
try {
  execSync('sfdx force:org:display --json', { stdio: 'pipe' });
} catch (error) {
  console.error('❌ Not connected to a Salesforce org. Please authenticate first:');
  console.error('   sfdx force:auth:web:login -a YourOrgAlias');
  process.exit(1);
}

// Create a data import plan
console.log('📋 Creating data import plan...');

const importPlan = {
  "objects": [
    {
      "name": "Lead",
      "label": "Leads",
      "status": "Not Started",
      "fields": [
        {
          "name": "FirstName",
          "label": "First Name",
          "type": "string",
          "required": false
        },
        {
          "name": "LastName",
          "label": "Last Name",
          "type": "string",
          "required": true
        },
        {
          "name": "Company",
          "label": "Company",
          "type": "string",
          "required": true
        },
        {
          "name": "Email",
          "label": "Email",
          "type": "string",
          "required": false
        },
        {
          "name": "Phone",
          "label": "Phone",
          "type": "string",
          "required": false
        },
        {
          "name": "Industry",
          "label": "Industry",
          "type": "string",
          "required": false
        },
        {
          "name": "LeadSource",
          "label": "Lead Source",
          "type": "string",
          "required": false
        },
        {
          "name": "Status",
          "label": "Status",
          "type": "string",
          "required": false
        },
        {
          "name": "Title",
          "label": "Title",
          "type": "string",
          "required": false
        },
        {
          "name": "State",
          "label": "State/Province",
          "type": "string",
          "required": false
        },
        {
          "name": "City",
          "label": "City",
          "type": "string",
          "required": false
        },
        {
          "name": "Country",
          "label": "Country",
          "type": "string",
          "required": false
        },
        {
          "name": "Company_Size__c",
          "label": "Company Size",
          "type": "string",
          "required": false
        },
        {
          "name": "AnnualRevenue",
          "label": "Annual Revenue",
          "type": "string",
          "required": false
        },
        {
          "name": "NumberOfEmployees",
          "label": "Number of Employees",
          "type": "number",
          "required": false
        },
        {
          "name": "Lead_Score__c",
          "label": "Lead Score",
          "type": "number",
          "required": false
        },
        {
          "name": "Description",
          "label": "Description",
          "type": "string",
          "required": false
        }
      ]
    }
  ]
};

const importPlanPath = path.join(__dirname, '..', 'data', 'import-plan.json');
fs.writeFileSync(importPlanPath, JSON.stringify(importPlan, null, 2));

console.log('✅ Import plan created');

// Method 1: Try using Data Import Wizard via SFDX
console.log('\n📤 Attempting to import leads using SFDX data import...');

try {
  // First, let's check if we can use the data import API
  const result = execSync('sfdx force:data:import --help', { stdio: 'pipe' });
  console.log('✅ SFDX data import command available');
  
  // Import the leads
  console.log('🔄 Importing leads...');
  const importCommand = `sfdx force:data:import --sobjecttype Lead --file ${leadsPath} --upsertmode insert`;
  execSync(importCommand, { stdio: 'inherit' });
  
  console.log('✅ Leads imported successfully!');
  
} catch (error) {
  console.log('⚠️  SFDX data import not available, trying alternative methods...');
  
  // Method 2: Use Bulk API via SFDX
  try {
    console.log('🔄 Trying Bulk API import...');
    const bulkCommand = `sfdx force:data:bulk:upsert --sobjecttype Lead --file ${leadsPath} --externalid Id`;
    execSync(bulkCommand, { stdio: 'inherit' });
    console.log('✅ Leads imported via Bulk API!');
    
  } catch (bulkError) {
    console.log('⚠️  Bulk API import failed, trying manual import...');
    
    // Method 3: Create Apex script for import
    console.log('📝 Creating Apex import script...');
    
    const apexScript = `
public class LeadImportScript {
    public static void importLeads() {
        List<Lead> leadsToInsert = new List<Lead>();
        
        // Read CSV data and create leads
        String csvData = '${fs.readFileSync(leadsPath, 'utf8').replace(/'/g, "\\'").replace(/\n/g, "\\n")}';
        String[] lines = csvData.split('\\n');
        
        // Skip header
        for(Integer i = 1; i < lines.size(); i++) {
            String line = lines[i];
            if(String.isNotBlank(line)) {
                String[] fields = line.split(',');
                if(fields.size() >= 16) {
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
                    l.Company_Size__c = fields[12].removeStart('"').removeEnd('"');
                    l.AnnualRevenue = fields[13].removeStart('"').removeEnd('"');
                    l.NumberOfEmployees = Integer.valueOf(fields[14]);
                    l.Lead_Score__c = Decimal.valueOf(fields[15]);
                    l.Description = fields[16].removeStart('"').removeEnd('"');
                    
                    leadsToInsert.add(l);
                }
            }
        }
        
        if(!leadsToInsert.isEmpty()) {
            try {
                insert leadsToInsert;
                System.debug('Successfully imported ' + leadsToInsert.size() + ' leads');
            } catch(Exception e) {
                System.debug('Error importing leads: ' + e.getMessage());
            }
        }
    }
}`;

    const apexPath = path.join(__dirname, '..', 'force-app', 'main', 'default', 'classes', 'LeadImportScript.cls');
    fs.writeFileSync(apexPath, apexScript);
    
    // Deploy the Apex class
    console.log('🚀 Deploying Apex import script...');
    execSync('sfdx force:source:deploy -p force-app/main/default/classes/LeadImportScript.cls', { stdio: 'inherit' });
    
    // Execute the import
    console.log('🔄 Executing lead import...');
    execSync('sfdx force:apex:execute -f scripts/execute-import.apex', { stdio: 'inherit' });
    
    console.log('✅ Leads imported via Apex script!');
  }
}

console.log('\n🎉 Lead deployment completed!');
console.log('\n📊 Next steps:');
console.log('1. Check your Salesforce org to verify the leads were imported');
console.log('2. Enable Einstein Lead Scoring if not already enabled');
console.log('3. Wait for Einstein to process the leads (may take 24-48 hours)');
console.log('4. Monitor lead scores in the Lead object');

// Clean up temporary files
try {
  fs.unlinkSync(importPlanPath);
  console.log('\n🧹 Cleaned up temporary files');
} catch (error) {
  // Ignore cleanup errors
} 