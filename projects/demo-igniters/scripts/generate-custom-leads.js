#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

class CustomLeadGenerator {
    constructor() {
        this.dataDir = path.join(__dirname, '..', 'data');
        this.ensureDataDirectory();
    }

    ensureDataDirectory() {
        if (!fs.existsSync(this.dataDir)) {
            fs.mkdirSync(this.dataDir, { recursive: true });
        }
    }

    // Industry-specific company name generators
    generateCompanyNames(industry, count = 50) {
        const industryPrefixes = {
            'Technology': ['Tech', 'Digital', 'Cyber', 'AI', 'Cloud', 'Data', 'Smart', 'Future', 'Next', 'Innovate'],
            'Healthcare': ['Health', 'Med', 'Bio', 'Care', 'Wellness', 'Life', 'Medical', 'Clinical', 'Therapy', 'Pharma'],
            'Financial Services': ['Finance', 'Capital', 'Bank', 'Credit', 'Investment', 'Wealth', 'Asset', 'Trust', 'Equity', 'Fund'],
            'Manufacturing': ['Manufacturing', 'Industrial', 'Production', 'Factory', 'Machinery', 'Equipment', 'Automation', 'Precision', 'Quality', 'Process'],
            'Retail': ['Retail', 'Store', 'Shop', 'Market', 'Outlet', 'Mall', 'Boutique', 'Department', 'Supermarket', 'Convenience'],
            'Education': ['Education', 'Learning', 'Academy', 'School', 'University', 'Institute', 'Training', 'Knowledge', 'Study', 'Teach'],
            'Real Estate': ['Real Estate', 'Property', 'Housing', 'Development', 'Construction', 'Building', 'Architecture', 'Design', 'Planning', 'Urban'],
            'Consulting': ['Consulting', 'Advisory', 'Strategy', 'Management', 'Business', 'Solutions', 'Partners', 'Group', 'Associates', 'Experts'],
            'Legal Services': ['Legal', 'Law', 'Attorney', 'Counsel', 'Justice', 'Rights', 'Advocacy', 'Litigation', 'Compliance', 'Regulatory'],
            'Government': ['Government', 'Public', 'Civic', 'Municipal', 'Federal', 'State', 'Local', 'Administration', 'Services', 'Agency']
        };

        const suffixes = ['Solutions', 'Systems', 'Corp', 'Inc', 'LLC', 'Partners', 'Group', 'Associates', 'Enterprises', 'Ventures', 'Technologies', 'Services', 'Consulting', 'Management', 'International', 'Global', 'Worldwide', 'Regional', 'Local', 'National'];

        const prefixes = industryPrefixes[industry] || ['Business', 'Professional', 'Advanced', 'Modern', 'Strategic', 'Dynamic', 'Progressive', 'Innovative', 'Leading', 'Premier'];
        
        const companies = [];
        for (let i = 0; i < count; i++) {
            const prefix = prefixes[Math.floor(Math.random() * prefixes.length)];
            const suffix = suffixes[Math.floor(Math.random() * suffixes.length)];
            companies.push(`${prefix} ${suffix}`);
        }
        
        return companies;
    }

    // Generate industry-specific job titles
    generateJobTitles(industry) {
        const titleTemplates = {
            'Technology': [
                'CTO', 'VP of Engineering', 'Software Engineer', 'Data Scientist', 'DevOps Engineer',
                'Product Manager', 'Technical Lead', 'System Administrator', 'Network Engineer',
                'Cybersecurity Specialist', 'AI Engineer', 'Cloud Architect', 'UX Designer',
                'QA Engineer', 'Scrum Master', 'Technical Architect', 'Solutions Engineer'
            ],
            'Healthcare': [
                'Chief Medical Officer', 'VP of Clinical Operations', 'Physician', 'Nurse Manager',
                'Clinical Director', 'Medical Director', 'Healthcare Administrator', 'Practice Manager',
                'Clinical Research Coordinator', 'Medical Technologist', 'Health Informatics Specialist',
                'Patient Care Manager', 'Quality Assurance Manager', 'Compliance Officer'
            ],
            'Financial Services': [
                'CFO', 'VP of Finance', 'Financial Analyst', 'Investment Manager', 'Risk Manager',
                'Portfolio Manager', 'Compliance Officer', 'Treasury Manager', 'Credit Analyst',
                'Financial Advisor', 'Account Manager', 'Operations Manager', 'Audit Manager'
            ],
            'Manufacturing': [
                'VP of Operations', 'Plant Manager', 'Production Manager', 'Quality Manager',
                'Supply Chain Manager', 'Operations Director', 'Manufacturing Engineer',
                'Process Engineer', 'Maintenance Manager', 'Safety Manager', 'Logistics Manager'
            ],
            'Retail': [
                'VP of Sales', 'Store Manager', 'District Manager', 'Merchandising Manager',
                'Buyer', 'Category Manager', 'Retail Operations Manager', 'Customer Service Manager',
                'Loss Prevention Manager', 'Inventory Manager', 'E-commerce Manager'
            ]
        };

        return titleTemplates[industry] || [
            'CEO', 'CTO', 'CFO', 'VP of Sales', 'VP of Marketing', 'Director', 'Manager',
            'Senior Manager', 'Business Analyst', 'Project Manager', 'Account Executive'
        ];
    }

    // Generate industry-specific lead sources
    generateLeadSources(industry) {
        const industrySources = {
            'Technology': ['Web', 'LinkedIn', 'GitHub', 'Tech Conference', 'Developer Meetup', 'Online Search', 'Referral', 'Trade Show'],
            'Healthcare': ['Medical Conference', 'Referral', 'Professional Association', 'Medical Journal', 'Healthcare Website', 'Trade Show'],
            'Financial Services': ['Financial Conference', 'Referral', 'Professional Network', 'Financial Website', 'Trade Publication', 'Industry Event'],
            'Manufacturing': ['Trade Show', 'Industry Conference', 'Supplier Referral', 'Manufacturing Website', 'Trade Publication', 'Direct Mail'],
            'Retail': ['E-commerce', 'Social Media', 'Retail Conference', 'Trade Show', 'Online Search', 'Referral', 'Advertisement']
        };

        return industrySources[industry] || [
            'Web', 'Phone Inquiry', 'Email Campaign', 'Trade Show', 'Referral',
            'Social Media', 'Cold Call', 'Partner', 'Advertisement', 'Direct Mail'
        ];
    }

    // Generate realistic email addresses
    generateEmail(firstName, lastName, company, website) {
        const cleanCompany = company.toLowerCase().replace(/[^a-z0-9]/g, '');
        const cleanWebsite = website.replace(/^https?:\/\//, '').replace(/^www\./, '').split('.')[0];
        
        const emailPatterns = [
            `${firstName.toLowerCase()}.${lastName.toLowerCase()}@${cleanWebsite}`,
            `${firstName.toLowerCase()}${lastName.toLowerCase()}@${cleanWebsite}`,
            `${firstName.toLowerCase()}_${lastName.toLowerCase()}@${cleanWebsite}`,
            `${firstName.toLowerCase()}.${lastName.toLowerCase()}@${cleanCompany}.com`,
            `${firstName.toLowerCase()}${Math.floor(Math.random() * 999)}@${cleanWebsite}`,
            `${lastName.toLowerCase()}.${firstName.toLowerCase()}@${cleanWebsite}`,
            `${firstName.toLowerCase()}@${cleanWebsite}`,
            `${lastName.toLowerCase()}@${cleanWebsite}`
        ];

        return emailPatterns[Math.floor(Math.random() * emailPatterns.length)];
    }

    // Generate phone numbers
    generatePhone() {
        const areaCode = Math.floor(Math.random() * 800) + 200;
        const prefix = Math.floor(Math.random() * 800) + 200;
        const line = Math.floor(Math.random() * 9000) + 1000;
        return `(${areaCode}) ${prefix}-${line}`;
    }

    // Generate company sizes and revenue based on industry
    generateCompanyMetrics(industry) {
        const industryMetrics = {
            'Technology': {
                employees: { min: 10, max: 5000 },
                revenue: { min: 500000, max: 50000000 }
            },
            'Healthcare': {
                employees: { min: 50, max: 10000 },
                revenue: { min: 1000000, max: 100000000 }
            },
            'Financial Services': {
                employees: { min: 100, max: 20000 },
                revenue: { min: 5000000, max: 500000000 }
            },
            'Manufacturing': {
                employees: { min: 200, max: 15000 },
                revenue: { min: 2000000, max: 200000000 }
            },
            'Retail': {
                employees: { min: 20, max: 10000 },
                revenue: { min: 500000, max: 100000000 }
            }
        };

        const metrics = industryMetrics[industry] || {
            employees: { min: 10, max: 5000 },
            revenue: { min: 500000, max: 50000000 }
        };

        return {
            numberOfEmployees: Math.floor(Math.random() * (metrics.employees.max - metrics.employees.min + 1)) + metrics.employees.min,
            annualRevenue: Math.floor(Math.random() * (metrics.revenue.max - metrics.revenue.min + 1)) + metrics.revenue.min
        };
    }

    // Generate lead data
    generateLeadData(company, website, industry, firstName, lastName, title) {
        const metrics = this.generateCompanyMetrics(industry);
        const leadSource = this.generateLeadSources(industry)[Math.floor(Math.random() * this.generateLeadSources(industry).length)];
        
        const states = ['CA', 'NY', 'TX', 'FL', 'IL', 'PA', 'OH', 'GA', 'NC', 'MI', 'NJ', 'VA', 'WA', 'AZ', 'MA'];
        const cities = ['New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix', 'Philadelphia', 'San Antonio', 'San Diego', 'Dallas', 'San Jose', 'Austin', 'Jacksonville', 'Fort Worth', 'Columbus', 'Charlotte'];
        
        const state = states[Math.floor(Math.random() * states.length)];
        const city = cities[Math.floor(Math.random() * cities.length)];
        
        const statuses = ['New', 'Contacted', 'Qualified', 'Working', 'Nurturing', 'Marketing Qualified Lead', 'Sales Qualified Lead'];
        const status = statuses[Math.floor(Math.random() * statuses.length)];

        const createdDate = new Date(Date.now() - Math.random() * 90 * 24 * 60 * 60 * 1000); // Random date within last 90 days
        const lastActivityDate = new Date(createdDate.getTime() + Math.random() * (Date.now() - createdDate.getTime()));

        return {
            FirstName: firstName,
            LastName: lastName,
            Company: company,
            Email: this.generateEmail(firstName, lastName, company, website),
            Phone: this.generatePhone(),
            Industry: industry,
            LeadSource: leadSource,
            Status: status,
            Title: title,
            State: state,
            City: city,
            Country: 'United States',
            AnnualRevenue: metrics.annualRevenue,
            NumberOfEmployees: metrics.numberOfEmployees,
            Website: website,
            Description: `Lead for ${company} in ${industry} industry. ${firstName} ${lastName} is a ${title} looking for solutions. Company website: ${website}`,
            CreatedDate: createdDate.toISOString(),
            LastActivityDate: lastActivityDate.toISOString()
        };
    }

    // Generate leads for a specific company/website
    generateLeadsForCompany(company, website, industry, numLeads = 100) {
        console.log(`\n🎯 Generating ${numLeads} leads for ${company} (${website}) in ${industry} industry...`);

        const companies = this.generateCompanyNames(industry, Math.min(numLeads, 50));
        const titles = this.generateJobTitles(industry);
        
        const firstNames = ['John', 'Jane', 'Michael', 'Sarah', 'David', 'Lisa', 'Robert', 'Jennifer', 'William', 'Mary', 'James', 'Linda', 'Richard', 'Patricia', 'Joseph', 'Elizabeth', 'Thomas', 'Barbara', 'Christopher', 'Susan', 'Charles', 'Jessica', 'Daniel', 'Sarah', 'Matthew', 'Karen', 'Anthony', 'Nancy', 'Mark', 'Betty', 'Donald', 'Helen', 'Steven', 'Sandra', 'Paul', 'Donna', 'Andrew', 'Carol', 'Joshua', 'Ruth', 'Kenneth', 'Sharon', 'Kevin', 'Michelle', 'Brian', 'Laura', 'George', 'Emily', 'Edward', 'Kimberly', 'Ronald', 'Deborah'];
        const lastNames = ['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson', 'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin', 'Lee', 'Perez', 'Thompson', 'White', 'Harris', 'Sanchez', 'Clark', 'Ramirez', 'Lewis', 'Robinson', 'Walker', 'Young', 'Allen', 'King', 'Wright', 'Scott', 'Torres', 'Nguyen', 'Hill', 'Flores', 'Green', 'Adams', 'Nelson', 'Baker', 'Hall', 'Rivera', 'Campbell', 'Mitchell', 'Carter', 'Roberts', 'Gomez', 'Phillips', 'Evans', 'Turner', 'Diaz', 'Parker', 'Cruz', 'Edwards', 'Collins', 'Reyes', 'Stewart', 'Morris', 'Morales', 'Murphy', 'Cook', 'Rogers', 'Gutierrez', 'Ortiz', 'Morgan', 'Cooper', 'Peterson', 'Bailey', 'Reed', 'Kelly', 'Howard', 'Ramos', 'Kim', 'Cox', 'Ward', 'Richardson', 'Watson', 'Brooks', 'Chavez', 'Wood', 'James', 'Bennett', 'Gray', 'Mendoza', 'Ruiz', 'Hughes', 'Price', 'Alvarez', 'Castillo', 'Sanders', 'Patel', 'Myers', 'Long', 'Ross', 'Foster', 'Jimenez'];

        const leads = [];
        
        for (let i = 0; i < numLeads; i++) {
            const firstName = firstNames[Math.floor(Math.random() * firstNames.length)];
            const lastName = lastNames[Math.floor(Math.random() * lastNames.length)];
            const title = titles[Math.floor(Math.random() * titles.length)];
            const leadCompany = companies[Math.floor(Math.random() * companies.length)];
            
            leads.push(this.generateLeadData(leadCompany, website, industry, firstName, lastName, title));
            
            if ((i + 1) % 20 === 0) {
                console.log(`  Generated ${i + 1} leads...`);
            }
        }

        return leads;
    }

    // Save leads to CSV
    saveLeadsToCSV(leads, filename) {
        const csvHeader = 'FirstName,LastName,Company,Email,Phone,Industry,LeadSource,Status,Title,State,City,Country,AnnualRevenue,NumberOfEmployees,Website,Description,CreatedDate,LastActivityDate\n';

        const csvContent = csvHeader + leads.map(lead => 
            Object.values(lead).map(value => 
                typeof value === 'string' && value.includes(',') ? `"${value}"` : value
            ).join(',')
        ).join('\n');

        const outputPath = path.join(this.dataDir, filename);
        fs.writeFileSync(outputPath, csvContent);
        
        console.log(`\n✅ Saved ${leads.length} leads to ${outputPath}`);
        return outputPath;
    }

    // Deploy leads to Salesforce
    deployLeadsToSalesforce(csvPath, targetOrg = 'sargo@demo.com') {
        try {
            console.log(`\n🚀 Deploying leads to Salesforce org: ${targetOrg}`);
            
            // Use the existing deployment script
            const command = `node scripts/import-leads-final.js ${csvPath} ${targetOrg}`;
            execSync(command, { encoding: 'utf8', stdio: 'inherit' });
            
            console.log('✅ Leads deployed successfully!');
            return true;
        } catch (error) {
            console.error('❌ Failed to deploy leads:', error.message);
            return false;
        }
    }

    // Complete process: generate and deploy
    async generateAndDeploy(company, website, industry, numLeads = 100, targetOrg = 'sargo@demo.com') {
        console.log(`\n🎯 Starting lead generation process for ${company}`);
        console.log(`📊 Target: ${numLeads} leads in ${industry} industry`);
        console.log(`🌐 Website: ${website}`);
        console.log(`🏢 Target Org: ${targetOrg}`);

        // Generate leads
        const leads = this.generateLeadsForCompany(company, website, industry, numLeads);
        
        // Create filename based on company
        const cleanCompany = company.toLowerCase().replace(/[^a-z0-9]/g, '-');
        const filename = `leads-${cleanCompany}-${Date.now()}.csv`;
        
        // Save to CSV
        const csvPath = this.saveLeadsToCSV(leads, filename);
        
        // Deploy to Salesforce
        const deployed = this.deployLeadsToSalesforce(csvPath, targetOrg);
        
        if (deployed) {
            console.log(`\n🎉 Successfully generated and deployed ${numLeads} leads for ${company}!`);
            console.log(`📁 CSV saved as: ${filename}`);
            console.log(`🏢 Deployed to: ${targetOrg}`);
        } else {
            console.log(`\n⚠️  Leads generated but deployment failed. CSV saved as: ${filename}`);
        }

        return { leads, csvPath, deployed };
    }
}

// CLI Interface
const args = process.argv.slice(2);

if (args.length === 0) {
    console.log(`
🎯 Custom Lead Generator

Usage:
  node generate-custom-leads.js <company> <website> <industry> [numLeads] [targetOrg]

Examples:
  node generate-custom-leads.js "TechCorp Solutions" "techcorp.com" "Technology" 200
  node generate-custom-leads.js "HealthCare Inc" "healthcare.com" "Healthcare" 150 "my-demo-org"
  node generate-custom-leads.js "Finance Pro" "financepro.com" "Financial Services" 100

Industries:
  Technology, Healthcare, Financial Services, Manufacturing, Retail, 
  Education, Real Estate, Consulting, Legal Services, Government

Default:
  numLeads: 100
  targetOrg: sargo@demo.com
`);
    process.exit(0);
}

const [company, website, industry, numLeads = 100, targetOrg = 'sargo@demo.com'] = args;

if (!company || !website || !industry) {
    console.error('❌ Please provide company, website, and industry');
    process.exit(1);
}

const generator = new CustomLeadGenerator();
generator.generateAndDeploy(company, website, industry, parseInt(numLeads), targetOrg);















