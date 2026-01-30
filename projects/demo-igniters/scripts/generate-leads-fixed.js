const fs = require('fs');
const path = require('path');

// Lead generation configuration
const NUM_LEADS = 1000;

// Company data for realistic lead generation
const companies = [
  'TechCorp Solutions', 'InnovateSoft', 'DataFlow Systems', 'CloudBridge Inc', 'Digital Dynamics',
  'NextGen Technologies', 'SmartSolutions', 'FutureTech Labs', 'CyberSecure Pro', 'AI Innovations',
  'Quantum Computing Corp', 'Blockchain Ventures', 'IoT Solutions', 'Machine Learning Co', 'Robotics Inc',
  'Green Energy Tech', 'Sustainable Solutions', 'CleanTech Innovations', 'EcoSmart Systems', 'Renewable Power',
  'Healthcare Analytics', 'MedTech Solutions', 'Bioinformatics Corp', 'Digital Health Systems', 'PatientCare Tech',
  'Financial Services Pro', 'FinTech Innovations', 'Banking Solutions', 'Payment Systems', 'Investment Tech',
  'Retail Solutions Inc', 'E-commerce Pro', 'Supply Chain Tech', 'Logistics Systems', 'Inventory Management',
  'Manufacturing Tech', 'Industrial Solutions', 'Automation Systems', 'Quality Control Pro', 'Production Tech',
  'Education Technology', 'Learning Systems', 'EdTech Solutions', 'Digital Learning Pro', 'Student Success Tech',
  'Real Estate Tech', 'Property Management', 'Housing Solutions', 'Construction Tech', 'Architecture Systems',
  'Marketing Solutions', 'Digital Marketing Pro', 'SEO Technologies', 'Social Media Systems', 'Content Creation Tech',
  'Consulting Services', 'Business Solutions', 'Strategy Tech', 'Management Systems', 'Advisory Services',
  'Legal Technology', 'Law Practice Solutions', 'Case Management Systems', 'Legal Analytics', 'Compliance Tech',
  'Government Tech', 'Public Sector Solutions', 'Civic Technology', 'Municipal Systems', 'Policy Analytics'
];

const industries = [
  'Technology', 'Healthcare', 'Financial Services', 'Manufacturing', 'Retail',
  'Education', 'Real Estate', 'Consulting', 'Legal Services', 'Government',
  'Energy', 'Transportation', 'Media', 'Non-Profit', 'Construction',
  'Agriculture', 'Telecommunications', 'Entertainment', 'Sports', 'Food & Beverage'
];

const leadSources = [
  'Web', 'Phone Inquiry', 'Email Campaign', 'Trade Show', 'Referral',
  'Social Media', 'Cold Call', 'Partner', 'Advertisement', 'Direct Mail',
  'Website Form', 'Chat', 'Online Search', 'LinkedIn', 'Facebook',
  'Twitter', 'Instagram', 'YouTube', 'Blog', 'Press Release'
];

const statuses = [
  'New', 'Contacted', 'Qualified', 'Unqualified', 'Working',
  'Nurturing', 'Marketing Qualified Lead', 'Sales Qualified Lead', 'Closed Won', 'Closed Lost'
];

const titles = [
  'CEO', 'CTO', 'CFO', 'VP of Sales', 'VP of Marketing', 'VP of Engineering',
  'Director of Operations', 'Director of IT', 'Manager', 'Senior Manager',
  'Business Analyst', 'Project Manager', 'Product Manager', 'Sales Manager',
  'Marketing Manager', 'Engineering Manager', 'HR Manager', 'Finance Manager',
  'Operations Manager', 'Customer Success Manager', 'Account Executive',
  'Sales Representative', 'Marketing Specialist', 'Software Engineer',
  'Data Scientist', 'UX Designer', 'Product Owner', 'Scrum Master',
  'Business Development', 'Partnership Manager', 'Strategy Director'
];

const states = [
  'CA', 'NY', 'TX', 'FL', 'IL', 'PA', 'OH', 'GA', 'NC', 'MI',
  'NJ', 'VA', 'WA', 'AZ', 'MA', 'TN', 'IN', 'MO', 'MD', 'CO',
  'MN', 'WI', 'SC', 'AL', 'LA', 'KY', 'OR', 'OK', 'CT', 'IA',
  'UT', 'NV', 'AR', 'MS', 'KS', 'NM', 'NE', 'WV', 'ID', 'HI',
  'NH', 'ME', 'RI', 'MT', 'DE', 'SD', 'ND', 'AK', 'VT', 'WY'
];

const cities = [
  'New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix',
  'Philadelphia', 'San Antonio', 'San Diego', 'Dallas', 'San Jose',
  'Austin', 'Jacksonville', 'Fort Worth', 'Columbus', 'Charlotte',
  'San Francisco', 'Indianapolis', 'Seattle', 'Denver', 'Washington',
  'Boston', 'El Paso', 'Nashville', 'Detroit', 'Oklahoma City',
  'Portland', 'Las Vegas', 'Memphis', 'Louisville', 'Baltimore',
  'Milwaukee', 'Albuquerque', 'Tucson', 'Fresno', 'Sacramento',
  'Mesa', 'Kansas City', 'Atlanta', 'Long Beach', 'Colorado Springs',
  'Raleigh', 'Miami', 'Virginia Beach', 'Omaha', 'Oakland',
  'Minneapolis', 'Tulsa', 'Arlington', 'Tampa', 'New Orleans'
];

// Generate random data functions
function getRandomElement(array) {
  return array[Math.floor(Math.random() * array.length)];
}

function getRandomNumber(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function getRandomEmail(firstName, lastName, company) {
  const domains = ['gmail.com', 'yahoo.com', 'hotmail.com', 'outlook.com'];
  const companyDomain = company.toLowerCase().replace(/[^a-z0-9]/g, '') + '.com';
  const personalDomain = getRandomElement(domains);
  
  const emailTypes = [
    `${firstName.toLowerCase()}.${lastName.toLowerCase()}@${companyDomain}`,
    `${firstName.toLowerCase()}${lastName.toLowerCase()}@${companyDomain}`,
    `${firstName.toLowerCase()}_${lastName.toLowerCase()}@${companyDomain}`,
    `${firstName.toLowerCase()}.${lastName.toLowerCase()}@${personalDomain}`,
    `${firstName.toLowerCase()}${getRandomNumber(1, 999)}@${personalDomain}`
  ];
  
  return getRandomElement(emailTypes);
}

function getRandomPhone() {
  const areaCode = getRandomNumber(200, 999);
  const prefix = getRandomNumber(100, 999);
  const line = getRandomNumber(1000, 9999);
  return `(${areaCode}) ${prefix}-${line}`;
}

function getRandomDate(start, end) {
  return new Date(start.getTime() + Math.random() * (end.getTime() - start.getTime()));
}

function generateLeadData() {
  const firstName = getRandomElement(['John', 'Jane', 'Michael', 'Sarah', 'David', 'Lisa', 'Robert', 'Jennifer', 'William', 'Mary', 'James', 'Linda', 'Richard', 'Patricia', 'Joseph', 'Elizabeth', 'Thomas', 'Barbara', 'Christopher', 'Susan', 'Charles', 'Jessica', 'Daniel', 'Sarah', 'Matthew', 'Karen', 'Anthony', 'Nancy', 'Mark', 'Betty', 'Donald', 'Helen', 'Steven', 'Sandra', 'Paul', 'Donna', 'Andrew', 'Carol', 'Joshua', 'Ruth', 'Kenneth', 'Sharon', 'Kevin', 'Michelle', 'Brian', 'Laura', 'George', 'Emily', 'Edward', 'Kimberly', 'Ronald', 'Deborah', 'Timothy', 'Dorothy', 'Jason', 'Lisa', 'Jeffrey', 'Nancy', 'Ryan', 'Karen', 'Jacob', 'Betty', 'Gary', 'Helen', 'Nicholas', 'Sandra', 'Eric', 'Donna', 'Jonathan', 'Carol', 'Stephen', 'Ruth', 'Larry', 'Sharon', 'Justin', 'Michelle', 'Scott', 'Laura', 'Brandon', 'Emily', 'Benjamin', 'Kimberly', 'Samuel', 'Deborah', 'Frank', 'Dorothy', 'Gregory', 'Lisa', 'Raymond', 'Nancy', 'Alexander', 'Karen', 'Patrick', 'Betty', 'Jack', 'Helen', 'Dennis', 'Sandra', 'Jerry', 'Donna']);
  
  const lastName = getRandomElement(['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson', 'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin', 'Lee', 'Perez', 'Thompson', 'White', 'Harris', 'Sanchez', 'Clark', 'Ramirez', 'Lewis', 'Robinson', 'Walker', 'Young', 'Allen', 'King', 'Wright', 'Scott', 'Torres', 'Nguyen', 'Hill', 'Flores', 'Green', 'Adams', 'Nelson', 'Baker', 'Hall', 'Rivera', 'Campbell', 'Mitchell', 'Carter', 'Roberts', 'Gomez', 'Phillips', 'Evans', 'Turner', 'Diaz', 'Parker', 'Cruz', 'Edwards', 'Collins', 'Reyes', 'Stewart', 'Morris', 'Morales', 'Murphy', 'Cook', 'Rogers', 'Gutierrez', 'Ortiz', 'Morgan', 'Cooper', 'Peterson', 'Bailey', 'Reed', 'Kelly', 'Howard', 'Ramos', 'Kim', 'Cox', 'Ward', 'Richardson', 'Watson', 'Brooks', 'Chavez', 'Wood', 'James', 'Bennett', 'Gray', 'Mendoza', 'Ruiz', 'Hughes', 'Price', 'Alvarez', 'Castillo', 'Sanders', 'Patel', 'Myers', 'Long', 'Ross', 'Foster', 'Jimenez']);
  
  const company = getRandomElement(companies);
  const industry = getRandomElement(industries);
  const leadSource = getRandomElement(leadSources);
  const status = getRandomElement(statuses);
  const title = getRandomElement(titles);
  const state = getRandomElement(states);
  const city = getRandomElement(cities);
  
  // Generate realistic revenue and employee counts
  // Use numeric values for AnnualRevenue (in thousands)
  const revenueRanges = [
    { min: 0, max: 1000 },      // $0-$1M
    { min: 1000, max: 10000 },  // $1M-$10M
    { min: 10000, max: 50000 }, // $10M-$50M
    { min: 50000, max: 100000 }, // $50M-$100M
    { min: 100000, max: 1000000 } // $100M+
  ];
  const selectedRange = getRandomElement(revenueRanges);
  const annualRevenue = getRandomNumber(selectedRange.min, selectedRange.max);
  const numberOfEmployees = getRandomNumber(1, 10000);
  
  return {
    FirstName: firstName,
    LastName: lastName,
    Company: company,
    Email: getRandomEmail(firstName, lastName, company),
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
console.log(`Generating ${NUM_LEADS} leads with standard fields only...`);

const leads = [];
for (let i = 0; i < NUM_LEADS; i++) {
  leads.push(generateLeadData());
  
  if ((i + 1) % 100 === 0) {
    console.log(`Generated ${i + 1} leads...`);
  }
}

// Write to CSV file - ONLY standard fields
const csvHeader = 'FirstName,LastName,Company,Email,Phone,Industry,LeadSource,Status,Title,State,City,Country,AnnualRevenue,NumberOfEmployees,Description\n';

const csvContent = csvHeader + leads.map(lead => 
  Object.values(lead).map(value => 
    typeof value === 'string' && value.includes(',') ? `"${value}"` : value
  ).join(',')
).join('\n');

const outputPath = path.join(__dirname, '..', 'data', 'leads-standard.csv');
fs.writeFileSync(outputPath, csvContent);

console.log(`\n✅ Generated ${NUM_LEADS} leads with standard fields and saved to ${outputPath}`);
console.log('\n📊 Lead Distribution:');
console.log(`- Companies: ${new Set(leads.map(l => l.Company)).size} unique`);
console.log(`- Industries: ${new Set(leads.map(l => l.Industry)).size} unique`);
console.log(`- Lead Sources: ${new Set(leads.map(l => l.LeadSource)).size} unique`);
console.log(`- Statuses: ${new Set(leads.map(l => l.Status)).size} unique`);
console.log(`- States: ${new Set(leads.map(l => l.State)).size} unique`);

// Generate summary statistics
const statusCounts = {};
leads.forEach(lead => {
  statusCounts[lead.Status] = (statusCounts[lead.Status] || 0) + 1;
});
console.log('\n📈 Status Distribution:');
Object.entries(statusCounts).forEach(([status, count]) => {
  console.log(`  ${status}: ${count} (${((count / NUM_LEADS) * 100).toFixed(1)}%)`);
});

console.log('\n🔧 This version uses only standard Salesforce Lead fields to avoid custom field errors.');
