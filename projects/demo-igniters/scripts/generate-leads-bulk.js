const fs = require('fs');
const path = require('path');

console.log('🚀 Generating realistic leads for Bulk API import...\n');

// Realistic data arrays
const firstNames = ['John', 'Jane', 'Michael', 'Sarah', 'David', 'Lisa', 'Robert', 'Jennifer', 'William', 'Mary', 'James', 'Linda', 'Richard', 'Patricia', 'Joseph', 'Elizabeth', 'Thomas', 'Barbara', 'Christopher', 'Susan', 'Charles', 'Jessica', 'Daniel', 'Sarah', 'Matthew', 'Karen', 'Anthony', 'Nancy', 'Mark', 'Betty', 'Donald', 'Helen', 'Steven', 'Sandra', 'Paul', 'Donna', 'Andrew', 'Carol', 'Joshua', 'Ruth', 'Kenneth', 'Sharon', 'Kevin', 'Michelle', 'Brian', 'Laura', 'George', 'Emily', 'Edward', 'Kimberly', 'Ronald', 'Deborah', 'Timothy', 'Dorothy', 'Jason', 'Lisa', 'Jeffrey', 'Nancy', 'Ryan', 'Karen', 'Jacob', 'Betty', 'Gary', 'Helen', 'Nicholas', 'Sandra', 'Eric', 'Donna', 'Jonathan', 'Carol', 'Stephen', 'Ruth', 'Larry', 'Sharon', 'Justin', 'Michelle', 'Scott', 'Laura', 'Brandon', 'Emily', 'Benjamin', 'Kimberly', 'Samuel', 'Deborah', 'Frank', 'Dorothy', 'Gregory', 'Lisa', 'Raymond', 'Nancy', 'Alexander', 'Karen', 'Patrick', 'Betty', 'Jack', 'Helen', 'Dennis', 'Sandra', 'Jerry', 'Donna'];

const lastNames = ['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson', 'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin', 'Lee', 'Perez', 'Thompson', 'White', 'Harris', 'Sanchez', 'Clark', 'Ramirez', 'Lewis', 'Robinson', 'Walker', 'Young', 'Allen', 'King', 'Wright', 'Scott', 'Torres', 'Nguyen', 'Hill', 'Flores', 'Green', 'Adams', 'Nelson', 'Baker', 'Hall', 'Rivera', 'Campbell', 'Mitchell', 'Carter', 'Roberts', 'Gomez', 'Phillips', 'Evans', 'Turner', 'Diaz', 'Parker', 'Cruz', 'Edwards', 'Collins', 'Reyes', 'Stewart', 'Morris', 'Morales', 'Murphy', 'Cook', 'Rogers', 'Gutierrez', 'Ortiz', 'Morgan', 'Cooper', 'Peterson', 'Bailey', 'Reed', 'Kelly', 'Howard', 'Ramos', 'Kim', 'Cox', 'Ward', 'Richardson', 'Watson', 'Brooks', 'Chavez', 'Wood', 'James', 'Bennett', 'Gray', 'Mendoza', 'Ruiz', 'Hughes', 'Price', 'Alvarez', 'Castillo', 'Sanders', 'Patel', 'Myers', 'Long', 'Ross', 'Foster', 'Jimenez'];

const companies = ['TechCorp Solutions', 'InnovateSoft', 'DataFlow Systems', 'CloudBridge Inc', 'Digital Dynamics', 'NextGen Technologies', 'SmartSolutions', 'FutureTech Labs', 'CyberSecure Pro', 'AI Innovations', 'Quantum Computing Corp', 'Blockchain Ventures', 'IoT Solutions', 'Machine Learning Co', 'Robotics Inc', 'Green Energy Tech', 'Sustainable Solutions', 'CleanTech Innovations', 'EcoSmart Systems', 'Renewable Power', 'Healthcare Analytics', 'MedTech Solutions', 'Bioinformatics Corp', 'Digital Health Systems', 'PatientCare Tech', 'Financial Services Pro', 'FinTech Innovations', 'Banking Solutions', 'Payment Systems', 'Investment Tech', 'Retail Solutions Inc', 'E-commerce Pro', 'Supply Chain Tech', 'Logistics Systems', 'Inventory Management', 'Manufacturing Tech', 'Industrial Solutions', 'Automation Systems', 'Quality Control Pro', 'Production Tech', 'Education Technology', 'Learning Systems', 'EdTech Solutions', 'Digital Learning Pro', 'Student Success Tech', 'Real Estate Tech', 'Property Management', 'Housing Solutions', 'Construction Tech', 'Architecture Systems', 'Marketing Solutions'];

const industries = ['Technology', 'Healthcare', 'Financial Services', 'Manufacturing', 'Retail', 'Education', 'Real Estate', 'Consulting', 'Legal Services', 'Government', 'Energy', 'Transportation', 'Media', 'Non-Profit', 'Construction', 'Agriculture', 'Telecommunications', 'Entertainment', 'Sports', 'Food & Beverage'];

const leadSources = ['Web', 'Phone Inquiry', 'Email Campaign', 'Trade Show', 'Referral', 'Social Media', 'Cold Call', 'Partner', 'Advertisement', 'Direct Mail', 'Website Form', 'Chat', 'Online Search', 'LinkedIn', 'Facebook', 'Twitter', 'Instagram', 'YouTube', 'Blog', 'Press Release'];

const statuses = ['New', 'Contacted', 'Qualified', 'Unqualified', 'Working', 'Nurturing', 'Marketing Qualified Lead', 'Sales Qualified Lead', 'Closed Won', 'Closed Lost'];

const titles = ['CEO', 'CTO', 'CFO', 'VP of Sales', 'VP of Marketing', 'VP of Engineering', 'Director of Operations', 'Director of IT', 'Manager', 'Senior Manager', 'Business Analyst', 'Project Manager', 'Product Manager', 'Sales Manager', 'Marketing Manager', 'Engineering Manager', 'HR Manager', 'Finance Manager', 'Operations Manager', 'Customer Success Manager', 'Account Executive', 'Sales Representative', 'Marketing Specialist', 'Software Engineer', 'Data Scientist', 'UX Designer', 'Product Owner', 'Scrum Master', 'Business Development', 'Partnership Manager', 'Strategy Director'];

const states = ['CA', 'NY', 'TX', 'FL', 'IL', 'PA', 'OH', 'GA', 'NC', 'MI', 'NJ', 'VA', 'WA', 'AZ', 'MA', 'TN', 'IN', 'MO', 'MD', 'CO', 'MN', 'WI', 'SC', 'AL', 'LA', 'KY', 'OR', 'OK', 'CT', 'IA', 'UT', 'NV', 'AR', 'MS', 'KS', 'NM', 'NE', 'WV', 'ID', 'HI', 'NH', 'ME', 'RI', 'MT', 'DE', 'SD', 'ND', 'AK', 'VT', 'WY'];

const cities = ['New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix', 'Philadelphia', 'San Antonio', 'San Diego', 'Dallas', 'San Jose', 'Austin', 'Jacksonville', 'Fort Worth', 'Columbus', 'Charlotte', 'San Francisco', 'Indianapolis', 'Seattle', 'Denver', 'Washington', 'Boston', 'El Paso', 'Nashville', 'Detroit', 'Oklahoma City', 'Portland', 'Las Vegas', 'Memphis', 'Louisville', 'Baltimore', 'Milwaukee', 'Albuquerque', 'Tucson', 'Fresno', 'Sacramento', 'Mesa', 'Kansas City', 'Atlanta', 'Long Beach', 'Colorado Springs', 'Raleigh', 'Miami', 'Virginia Beach', 'Omaha', 'Oakland', 'Minneapolis', 'Tulsa', 'Arlington', 'Tampa', 'New Orleans'];

// Helper functions
function getRandomElement(array) {
  return array[Math.floor(Math.random() * array.length)];
}

function getRandomNumber(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function getRandomEmail(firstName, lastName, company) {
  const domains = ['gmail.com', 'yahoo.com', 'hotmail.com', 'outlook.com', 'company.com', 'business.com'];
  const domain = getRandomElement(domains);
  const emailFormats = [
    `${firstName.toLowerCase()}.${lastName.toLowerCase()}@${domain}`,
    `${firstName.toLowerCase()}${lastName.toLowerCase()}@${domain}`,
    `${firstName.toLowerCase()}_${lastName.toLowerCase()}@${domain}`,
    `${firstName.toLowerCase()}${getRandomNumber(1, 999)}@${domain}`
  ];
  return getRandomElement(emailFormats);
}

function getRandomPhone() {
  const areaCode = getRandomNumber(200, 999);
  const prefix = getRandomNumber(200, 999);
  const lineNumber = getRandomNumber(1000, 9999);
  return `(${areaCode}) ${prefix}-${lineNumber}`;
}

function generateLeadData(index) {
  const firstName = getRandomElement(firstNames);
  const lastName = getRandomElement(lastNames);
  const company = getRandomElement(companies);
  const industry = getRandomElement(industries);
  const leadSource = getRandomElement(leadSources);
  const status = getRandomElement(statuses);
  const title = getRandomElement(titles);
  const state = getRandomElement(states);
  const city = getRandomElement(cities);
  const numberOfEmployees = getRandomNumber(1, 10000);
  const annualRevenue = getRandomNumber(100000, 10000000);
  const email = getRandomEmail(firstName, lastName, company);
  
  return {
    // External ID - using email as the unique identifier
    Email: email,
    
    // Standard Lead fields
    FirstName: firstName,
    LastName: lastName,
    Company: company,
    Phone: getRandomPhone(),
    Industry: industry,
    LeadSource: leadSource,
    Status: status,
    Title: title,
    State: state,
    City: city,
    Country: 'United States',
    AnnualRevenue: annualRevenue,
    NumberOfEmployees: numberOfEmployees,
    Description: `Lead for ${company} in ${industry} industry. ${firstName} ${lastName} is a ${title} looking for solutions.`
  };
}

// Generate leads
const leads = [];
const numLeads = 1000;

console.log(`📊 Generating ${numLeads} realistic leads...`);

for (let i = 0; i < numLeads; i++) {
  const lead = generateLeadData(i);
  leads.push(lead);
}

// Create CSV content
const csvPath = path.join(__dirname, '..', 'data', 'leads-bulk-api.csv');
const headers = ['Email', 'FirstName', 'LastName', 'Company', 'Phone', 'Industry', 'LeadSource', 'Status', 'Title', 'State', 'City', 'Country', 'AnnualRevenue', 'NumberOfEmployees', 'Description'];

let csvContent = headers.join(',') + '\n';

leads.forEach(lead => {
  const row = headers.map(header => {
    const value = lead[header];
    // Escape commas and quotes in CSV
    if (typeof value === 'string' && (value.includes(',') || value.includes('"'))) {
      return `"${value.replace(/"/g, '""')}"`;
    }
    return value;
  });
  csvContent += row.join(',') + '\n';
});

// Write to file
fs.writeFileSync(csvPath, csvContent);

console.log(`✅ Generated ${leads.length} realistic leads`);
console.log(`📁 Saved to: ${csvPath}`);
console.log(`📊 Sample lead: ${leads[0].FirstName} ${leads[0].LastName} at ${leads[0].Company}`);

console.log('\n🚀 Next steps:');
console.log('1. Run: sfdx force:data:bulk:upsert --sobject Lead --file data/leads-bulk-api.csv --external-id Email');
console.log('2. This will use Email as the external ID for upsert operations');
console.log('3. Duplicate emails will be updated, new emails will be inserted'); 