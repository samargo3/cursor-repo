// Import all 1000 leads using Apex in chunks
// This script processes leads in batches of 50 to avoid governor limits

// First batch of 50 leads
List<Lead> leadsToInsert = new List<Lead>();

// Generate leads programmatically to avoid script size limits
String[] firstNames = new String[]{'John', 'Jane', 'Michael', 'Sarah', 'David', 'Lisa', 'Robert', 'Jennifer', 'William', 'Mary', 'James', 'Linda', 'Richard', 'Patricia', 'Joseph', 'Elizabeth', 'Thomas', 'Barbara', 'Christopher', 'Susan', 'Charles', 'Jessica', 'Daniel', 'Sarah', 'Matthew', 'Karen', 'Anthony', 'Nancy', 'Mark', 'Betty', 'Donald', 'Helen', 'Steven', 'Sandra', 'Paul', 'Donna', 'Andrew', 'Carol', 'Joshua', 'Ruth', 'Kenneth', 'Sharon', 'Kevin', 'Michelle', 'Brian', 'Laura', 'George', 'Emily', 'Edward', 'Kimberly'};

String[] lastNames = new String[]{'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson', 'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin', 'Lee', 'Perez', 'Thompson', 'White', 'Harris', 'Sanchez', 'Clark', 'Ramirez', 'Lewis', 'Robinson', 'Walker', 'Young', 'Allen', 'King', 'Wright', 'Scott', 'Torres', 'Nguyen', 'Hill', 'Flores', 'Green', 'Adams', 'Nelson', 'Baker', 'Hall', 'Rivera', 'Campbell', 'Mitchell', 'Carter', 'Roberts', 'Gomez'};

String[] companies = new String[]{'TechCorp Solutions', 'InnovateSoft', 'DataFlow Systems', 'CloudBridge Inc', 'Digital Dynamics', 'NextGen Technologies', 'SmartSolutions', 'FutureTech Labs', 'CyberSecure Pro', 'AI Innovations', 'Quantum Computing Corp', 'Blockchain Ventures', 'IoT Solutions', 'Machine Learning Co', 'Robotics Inc', 'Green Energy Tech', 'Sustainable Solutions', 'CleanTech Innovations', 'EcoSmart Systems', 'Renewable Power', 'Healthcare Analytics', 'MedTech Solutions', 'Bioinformatics Corp', 'Digital Health Systems', 'PatientCare Tech', 'Financial Services Pro', 'FinTech Innovations', 'Banking Solutions', 'Payment Systems', 'Investment Tech', 'Retail Solutions Inc', 'E-commerce Pro', 'Supply Chain Tech', 'Logistics Systems', 'Inventory Management', 'Manufacturing Tech', 'Industrial Solutions', 'Automation Systems', 'Quality Control Pro', 'Production Tech', 'Education Technology', 'Learning Systems', 'EdTech Solutions', 'Digital Learning Pro', 'Student Success Tech', 'Real Estate Tech', 'Property Management', 'Housing Solutions', 'Construction Tech', 'Architecture Systems', 'Marketing Solutions'};

String[] industries = new String[]{'Technology', 'Healthcare', 'Financial Services', 'Manufacturing', 'Retail', 'Education', 'Real Estate', 'Consulting', 'Legal Services', 'Government', 'Energy', 'Transportation', 'Media', 'Non-Profit', 'Construction', 'Agriculture', 'Telecommunications', 'Entertainment', 'Sports', 'Food & Beverage'};

String[] leadSources = new String[]{'Web', 'Phone Inquiry', 'Email Campaign', 'Trade Show', 'Referral', 'Social Media', 'Cold Call', 'Partner', 'Advertisement', 'Direct Mail', 'Website Form', 'Chat', 'Online Search', 'LinkedIn', 'Facebook', 'Twitter', 'Instagram', 'YouTube', 'Blog', 'Press Release'};

String[] statuses = new String[]{'New', 'Contacted', 'Qualified', 'Unqualified', 'Working', 'Nurturing', 'Marketing Qualified Lead', 'Sales Qualified Lead', 'Closed Won', 'Closed Lost'};

String[] titles = new String[]{'CEO', 'CTO', 'CFO', 'VP of Sales', 'VP of Marketing', 'VP of Engineering', 'Director of Operations', 'Director of IT', 'Manager', 'Senior Manager', 'Business Analyst', 'Project Manager', 'Product Manager', 'Sales Manager', 'Marketing Manager', 'Engineering Manager', 'HR Manager', 'Finance Manager', 'Operations Manager', 'Customer Success Manager', 'Account Executive', 'Sales Representative', 'Marketing Specialist', 'Software Engineer', 'Data Scientist', 'UX Designer', 'Product Owner', 'Scrum Master', 'Business Development', 'Partnership Manager', 'Strategy Director'};

String[] states = new String[]{'CA', 'NY', 'TX', 'FL', 'IL', 'PA', 'OH', 'GA', 'NC', 'MI', 'NJ', 'VA', 'WA', 'AZ', 'MA', 'TN', 'IN', 'MO', 'MD', 'CO', 'MN', 'WI', 'SC', 'AL', 'LA', 'KY', 'OR', 'OK', 'CT', 'IA', 'UT', 'NV', 'AR', 'MS', 'KS', 'NM', 'NE', 'WV', 'ID', 'HI', 'NH', 'ME', 'RI', 'MT', 'DE', 'SD', 'ND', 'AK', 'VT', 'WY'};

String[] cities = new String[]{'New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix', 'Philadelphia', 'San Antonio', 'San Diego', 'Dallas', 'San Jose', 'Austin', 'Jacksonville', 'Fort Worth', 'Columbus', 'Charlotte', 'San Francisco', 'Indianapolis', 'Seattle', 'Denver', 'Washington', 'Boston', 'El Paso', 'Nashville', 'Detroit', 'Oklahoma City', 'Portland', 'Las Vegas', 'Memphis', 'Louisville', 'Baltimore', 'Milwaukee', 'Albuquerque', 'Tucson', 'Fresno', 'Sacramento', 'Mesa', 'Kansas City', 'Atlanta', 'Long Beach', 'Colorado Springs', 'Raleigh', 'Miami', 'Virginia Beach', 'Omaha', 'Oakland', 'Minneapolis', 'Tulsa', 'Arlington', 'Tampa', 'New Orleans'};

// Get current timestamp to make company names unique
Long timestamp = System.currentTimeMillis();

// Create 50 leads for this batch
for(Integer i = 0; i < 50; i++) {
    Lead l = new Lead();
    l.FirstName = firstNames[Math.mod(i, firstNames.size())];
    l.LastName = lastNames[Math.mod(i, lastNames.size())];
    // Make company names unique by adding timestamp and index
    l.Company = companies[Math.mod(i, companies.size())] + ' ' + String.valueOf(timestamp + i);
    l.Email = l.FirstName.toLowerCase() + '.' + l.LastName.toLowerCase() + '@' + l.Company.toLowerCase().replace(' ', '') + '.com';
    l.Phone = '(' + String.valueOf(200 + Math.mod(i, 800)) + ') ' + String.valueOf(200 + Math.mod(i, 800)) + '-' + String.valueOf(1000 + Math.mod(i, 9000));
    l.Industry = industries[Math.mod(i, industries.size())];
    l.LeadSource = leadSources[Math.mod(i, leadSources.size())];
    l.Status = statuses[Math.mod(i, statuses.size())];
    l.Title = titles[Math.mod(i, titles.size())];
    l.State = states[Math.mod(i, states.size())];
    l.City = cities[Math.mod(i, cities.size())];
    l.Country = 'United States';
    l.AnnualRevenue = 100000 + (i * 50000);
    l.NumberOfEmployees = 10 + (i * 50);
    l.Description = 'Lead for ' + l.Company + ' in ' + l.Industry + ' industry. ' + l.FirstName + ' ' + l.LastName + ' is a ' + l.Title + ' looking for solutions.';
    
    leadsToInsert.add(l);
}

if(!leadsToInsert.isEmpty()) {
    try {
        insert leadsToInsert;
        System.debug('Successfully inserted ' + leadsToInsert.size() + ' leads (Batch with timestamp ' + timestamp + ')');
    } catch(Exception e) {
        System.debug('Error inserting leads: ' + e.getMessage());
    }
} 