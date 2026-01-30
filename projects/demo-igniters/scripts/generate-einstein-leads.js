#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

/**
 * Enhanced Lead Generator for Einstein Lead Scoring
 * Generates high-tech B2B leads with all required fields for Einstein Lead Scoring
 */

class EinsteinLeadGenerator {
    constructor() {
        this.dataDir = path.join(__dirname, '..', 'data');
        this.ensureDataDirectory();
    }

    ensureDataDirectory() {
        if (!fs.existsSync(this.dataDir)) {
            fs.mkdirSync(this.dataDir, { recursive: true });
        }
    }

    // High-tech B2B company names with realistic tech companies
    generateTechCompanies() {
        return [
            // SaaS & Cloud
            'CloudScale Technologies', 'DataFlow Solutions', 'AI Innovations Inc', 'SmartAnalytics Corp',
            'CloudBridge Systems', 'Digital Dynamics', 'NextGen Software', 'TechFlow Enterprises',
            'InnovateSoft Solutions', 'CyberSecure Pro', 'Quantum Computing Corp', 'Blockchain Ventures',
            'IoT Solutions Inc', 'Machine Learning Co', 'Robotics Systems', 'Green Energy Tech',
            'Sustainable Solutions', 'CleanTech Innovations', 'EcoSmart Systems', 'Renewable Power',
            
            // Enterprise Software
            'Enterprise Solutions Inc', 'Business Intelligence Corp', 'Data Analytics Pro',
            'Customer Relationship Systems', 'Enterprise Resource Planning', 'Supply Chain Tech',
            'Inventory Management Systems', 'Logistics Solutions', 'Manufacturing Tech',
            'Industrial Solutions', 'Automation Systems', 'Quality Control Pro', 'Production Tech',
            
            // FinTech & Healthcare
            'Financial Services Pro', 'FinTech Innovations', 'Banking Solutions', 'Payment Systems',
            'Investment Tech', 'Healthcare Analytics', 'MedTech Solutions', 'Bioinformatics Corp',
            'Digital Health Systems', 'PatientCare Tech', 'Clinical Data Systems', 'Medical Records Pro',
            
            // E-commerce & Retail
            'Retail Solutions Inc', 'E-commerce Pro', 'Supply Chain Tech', 'Logistics Systems',
            'Inventory Management', 'Customer Experience Tech', 'Marketing Automation',
            'Digital Marketing Pro', 'SEO Technologies', 'Social Media Systems', 'Content Creation Tech',
            
            // Consulting & Services
            'Consulting Services', 'Business Solutions', 'Strategy Tech', 'Management Systems',
            'Advisory Services', 'Legal Technology', 'Law Practice Solutions', 'Case Management Systems',
            'Legal Analytics', 'Compliance Tech', 'Government Tech', 'Public Sector Solutions',
            'Civic Technology', 'Municipal Systems', 'Policy Analytics'
        ];
    }

    // High-tech industries with B2B focus
    generateTechIndustries() {
        return [
            'Technology', 'Software', 'SaaS', 'Cloud Computing', 'Artificial Intelligence',
            'Machine Learning', 'Data Analytics', 'Cybersecurity', 'FinTech', 'HealthTech',
            'EdTech', 'MarTech', 'AdTech', 'RegTech', 'InsurTech', 'PropTech', 'LegalTech',
            'Enterprise Software', 'E-commerce', 'Digital Marketing', 'Consulting',
            'Professional Services', 'Research & Development', 'Telecommunications',
            'Semiconductors', 'Hardware', 'Mobile Technology', 'Web Development'
        ];
    }

    // High-tech job titles for B2B decision makers
    generateTechTitles() {
        return [
            // C-Level
            'CEO', 'CTO', 'CFO', 'COO', 'CISO', 'CDO', 'CPO', 'CRO',
            
            // VPs
            'VP of Engineering', 'VP of Technology', 'VP of Product', 'VP of Sales',
            'VP of Marketing', 'VP of Operations', 'VP of Business Development',
            'VP of Customer Success', 'VP of Data & Analytics', 'VP of Security',
            
            // Directors
            'Director of Engineering', 'Director of Product', 'Director of Sales',
            'Director of Marketing', 'Director of Operations', 'Director of IT',
            'Director of Data Science', 'Director of Security', 'Director of Customer Success',
            'Director of Business Development', 'Director of Strategy',
            
            // Managers
            'Engineering Manager', 'Product Manager', 'Sales Manager', 'Marketing Manager',
            'IT Manager', 'Data Science Manager', 'Security Manager', 'Operations Manager',
            'Customer Success Manager', 'Business Development Manager', 'Project Manager',
            'Program Manager', 'Technical Manager', 'Solutions Manager',
            
            // Individual Contributors
            'Senior Software Engineer', 'Software Engineer', 'Data Scientist', 'Data Engineer',
            'DevOps Engineer', 'Security Engineer', 'Product Owner', 'Technical Lead',
            'Solutions Architect', 'Business Analyst', 'Sales Engineer', 'Account Executive',
            'Customer Success Specialist', 'Marketing Specialist', 'Technical Writer'
        ];
    }

    // Lead sources relevant to high-tech B2B
    generateTechLeadSources() {
        return [
            'Website', 'LinkedIn', 'GitHub', 'Tech Conference', 'Developer Meetup',
            'Online Search', 'Referral', 'Trade Show', 'Webinar', 'White Paper',
            'Case Study', 'Blog', 'Social Media', 'Email Campaign', 'Cold Outreach',
            'Partner Referral', 'Industry Publication', 'Tech News', 'Podcast',
            'YouTube', 'Twitter', 'Stack Overflow', 'Reddit', 'Hacker News'
        ];
    }

    // Lead statuses for B2B sales process
    generateLeadStatuses() {
        return [
            'New', 'Contacted', 'Qualified', 'Unqualified', 'Working - Contacted',
            'Working - Nurturing', 'Marketing Qualified Lead', 'Sales Qualified Lead',
            'Closed Won', 'Closed Lost', 'Not Contacted', 'Attempted Contact',
            'Engaged', 'Interested', 'Not Interested', 'Do Not Contact'
        ];
    }

    // Company sizes for B2B tech companies
    generateCompanySizes() {
        return [
            '1-10', '11-50', '51-200', '201-1000', '1001-5000', '5001+'
        ];
    }

    // Revenue ranges for B2B tech companies
    generateRevenueRanges() {
        return [
            '$0-$1M', '$1M-$10M', '$10M-$50M', '$50M-$100M', '$100M-$500M', '$500M+'
        ];
    }

    // Tech-focused states and cities
    generateTechLocations() {
        const states = ['CA', 'NY', 'TX', 'WA', 'MA', 'IL', 'FL', 'PA', 'OH', 'GA', 'NC', 'VA', 'CO', 'AZ', 'OR'];
        const cities = [
            'San Francisco', 'New York', 'Seattle', 'Boston', 'Austin', 'Los Angeles',
            'Chicago', 'Denver', 'Portland', 'San Diego', 'Miami', 'Atlanta', 'Dallas',
            'Phoenix', 'Philadelphia', 'Detroit', 'Minneapolis', 'Nashville', 'Raleigh',
            'Charlotte', 'Tampa', 'Orlando', 'Las Vegas', 'Salt Lake City', 'Boulder'
        ];
        
        return { states, cities };
    }

    // Generate realistic email addresses for tech companies
    generateTechEmail(firstName, lastName, company) {
        const cleanCompany = company.toLowerCase().replace(/[^a-z0-9]/g, '');
        const domains = ['gmail.com', 'yahoo.com', 'hotmail.com', 'outlook.com'];
        const companyDomain = cleanCompany + '.com';
        const personalDomain = domains[Math.floor(Math.random() * domains.length)];
        
        const emailPatterns = [
            `${firstName.toLowerCase()}.${lastName.toLowerCase()}@${companyDomain}`,
            `${firstName.toLowerCase()}${lastName.toLowerCase()}@${companyDomain}`,
            `${firstName.toLowerCase()}_${lastName.toLowerCase()}@${companyDomain}`,
            `${firstName.toLowerCase()}.${lastName.toLowerCase()}@${personalDomain}`,
            `${firstName.toLowerCase()}${Math.floor(Math.random() * 999)}@${personalDomain}`,
            `${lastName.toLowerCase()}.${firstName.toLowerCase()}@${companyDomain}`,
            `${firstName.toLowerCase()}@${companyDomain}`,
            `${lastName.toLowerCase()}@${companyDomain}`
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

    // Generate company metrics based on industry and size
    generateCompanyMetrics(industry, companySize) {
        const sizeRanges = {
            '1-10': { min: 1, max: 10, revenue: { min: 100000, max: 2000000 } },
            '11-50': { min: 11, max: 50, revenue: { min: 500000, max: 10000000 } },
            '51-200': { min: 51, max: 200, revenue: { min: 2000000, max: 50000000 } },
            '201-1000': { min: 201, max: 1000, revenue: { min: 10000000, max: 100000000 } },
            '1001-5000': { min: 1001, max: 5000, revenue: { min: 50000000, max: 500000000 } },
            '5001+': { min: 5001, max: 50000, revenue: { min: 100000000, max: 2000000000 } }
        };
        
        const range = sizeRanges[companySize] || sizeRanges['51-200'];
        const employees = Math.floor(Math.random() * (range.max - range.min + 1)) + range.min;
        const revenue = Math.floor(Math.random() * (range.revenue.max - range.revenue.min + 1)) + range.revenue.min;
        
        return { employees, revenue };
    }

    // Generate lead score based on various factors
    generateLeadScore(industry, title, companySize, leadSource) {
        let score = 0;
        
        // Industry scoring
        const industryScores = {
            'Technology': 85, 'Software': 90, 'SaaS': 95, 'Cloud Computing': 90,
            'Artificial Intelligence': 95, 'Machine Learning': 90, 'Data Analytics': 85,
            'Cybersecurity': 90, 'FinTech': 85, 'HealthTech': 80, 'EdTech': 75,
            'Enterprise Software': 85, 'E-commerce': 80, 'Consulting': 70
        };
        score += industryScores[industry] || 60;
        
        // Title scoring
        const titleScores = {
            'CEO': 100, 'CTO': 95, 'CFO': 90, 'VP of Engineering': 90,
            'VP of Technology': 90, 'VP of Product': 85, 'Director of Engineering': 85,
            'Engineering Manager': 80, 'Product Manager': 80, 'Sales Manager': 75,
            'Marketing Manager': 70, 'Software Engineer': 65, 'Data Scientist': 70
        };
        score += titleScores[title] || 50;
        
        // Company size scoring
        const sizeScores = {
            '1-10': 30, '11-50': 50, '51-200': 70, '201-1000': 85,
            '1001-5000': 95, '5001+': 100
        };
        score += sizeScores[companySize] || 50;
        
        // Lead source scoring
        const sourceScores = {
            'Website': 80, 'LinkedIn': 85, 'Tech Conference': 90, 'Referral': 95,
            'Webinar': 75, 'Trade Show': 80, 'Email Campaign': 70, 'Cold Outreach': 60,
            'Partner Referral': 90, 'Industry Publication': 75
        };
        score += sourceScores[leadSource] || 50;
        
        // Add some randomness
        score += Math.floor(Math.random() * 20) - 10;
        
        return Math.max(0, Math.min(100, score));
    }

    // Generate website URL
    generateWebsite(company) {
        const cleanCompany = company.toLowerCase().replace(/[^a-z0-9]/g, '');
        const domains = ['.com', '.io', '.co', '.tech', '.ai', '.app'];
        const domain = domains[Math.floor(Math.random() * domains.length)];
        return `https://www.${cleanCompany}${domain}`;
    }

    // Generate lead data with all Einstein-required fields
    generateLeadData() {
        const companies = this.generateTechCompanies();
        const industries = this.generateTechIndustries();
        const titles = this.generateTechTitles();
        const leadSources = this.generateTechLeadSources();
        const statuses = this.generateLeadStatuses();
        const companySizes = this.generateCompanySizes();
        const revenueRanges = this.generateRevenueRanges();
        const locations = this.generateTechLocations();
        
        const firstNames = [
            'John', 'Jane', 'Michael', 'Sarah', 'David', 'Lisa', 'Robert', 'Jennifer',
            'William', 'Mary', 'James', 'Linda', 'Richard', 'Patricia', 'Joseph',
            'Elizabeth', 'Thomas', 'Barbara', 'Christopher', 'Susan', 'Charles', 'Jessica',
            'Daniel', 'Sarah', 'Matthew', 'Karen', 'Anthony', 'Nancy', 'Mark', 'Betty',
            'Donald', 'Helen', 'Steven', 'Sandra', 'Paul', 'Donna', 'Andrew', 'Carol',
            'Joshua', 'Ruth', 'Kenneth', 'Sharon', 'Kevin', 'Michelle', 'Brian', 'Laura',
            'George', 'Emily', 'Edward', 'Kimberly', 'Ronald', 'Deborah', 'Timothy',
            'Dorothy', 'Jason', 'Lisa', 'Jeffrey', 'Nancy', 'Ryan', 'Karen', 'Jacob',
            'Betty', 'Gary', 'Helen', 'Nicholas', 'Sandra', 'Eric', 'Donna', 'Jonathan',
            'Carol', 'Stephen', 'Ruth', 'Larry', 'Sharon', 'Justin', 'Michelle', 'Scott',
            'Laura', 'Brandon', 'Emily', 'Benjamin', 'Kimberly', 'Samuel', 'Deborah',
            'Frank', 'Dorothy', 'Gregory', 'Lisa', 'Raymond', 'Nancy', 'Alexander',
            'Karen', 'Patrick', 'Betty', 'Jack', 'Helen', 'Dennis', 'Sandra', 'Jerry', 'Donna'
        ];
        
        const lastNames = [
            'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis',
            'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson',
            'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin', 'Lee', 'Perez', 'Thompson',
            'White', 'Harris', 'Sanchez', 'Clark', 'Ramirez', 'Lewis', 'Robinson', 'Walker',
            'Young', 'Allen', 'King', 'Wright', 'Scott', 'Torres', 'Nguyen', 'Hill', 'Flores',
            'Green', 'Adams', 'Nelson', 'Baker', 'Hall', 'Rivera', 'Campbell', 'Mitchell',
            'Carter', 'Roberts', 'Gomez', 'Phillips', 'Evans', 'Turner', 'Diaz', 'Parker',
            'Cruz', 'Edwards', 'Collins', 'Reyes', 'Stewart', 'Morris', 'Morales', 'Murphy',
            'Cook', 'Rogers', 'Gutierrez', 'Ortiz', 'Morgan', 'Cooper', 'Peterson', 'Bailey',
            'Reed', 'Kelly', 'Howard', 'Ramos', 'Kim', 'Cox', 'Ward', 'Richardson', 'Watson',
            'Brooks', 'Chavez', 'Wood', 'James', 'Bennett', 'Gray', 'Mendoza', 'Ruiz',
            'Hughes', 'Price', 'Alvarez', 'Castillo', 'Sanders', 'Patel', 'Myers', 'Long',
            'Ross', 'Foster', 'Jimenez'
        ];
        
        const firstName = firstNames[Math.floor(Math.random() * firstNames.length)];
        const lastName = lastNames[Math.floor(Math.random() * lastNames.length)];
        const company = companies[Math.floor(Math.random() * companies.length)];
        const industry = industries[Math.floor(Math.random() * industries.length)];
        const title = titles[Math.floor(Math.random() * titles.length)];
        const leadSource = leadSources[Math.floor(Math.random() * leadSources.length)];
        const status = statuses[Math.floor(Math.random() * statuses.length)];
        const companySize = companySizes[Math.floor(Math.random() * companySizes.length)];
        const revenueRange = revenueRanges[Math.floor(Math.random() * revenueRanges.length)];
        const state = locations.states[Math.floor(Math.random() * locations.states.length)];
        const city = locations.cities[Math.floor(Math.random() * locations.cities.length)];
        
        const metrics = this.generateCompanyMetrics(industry, companySize);
        const leadScore = this.generateLeadScore(industry, title, companySize, leadSource);
        const website = this.generateWebsite(company);
        
        // Generate dates
        const createdDate = new Date(Date.now() - Math.random() * 180 * 24 * 60 * 60 * 1000); // Last 6 months
        const lastActivityDate = new Date(createdDate.getTime() + Math.random() * (Date.now() - createdDate.getTime()));
        
        return {
            // Standard Lead fields
            FirstName: firstName,
            LastName: lastName,
            Company: company,
            Email: this.generateTechEmail(firstName, lastName, company),
            Phone: this.generatePhone(),
            Industry: industry,
            LeadSource: leadSource,
            Status: status,
            Title: title,
            State: state,
            City: city,
            Country: 'United States',
            Website: website,
            Description: `High-tech B2B lead for ${company} in ${industry} industry. ${firstName} ${lastName} is a ${title} at a ${companySize} company looking for enterprise solutions.`,
            
            // Einstein Lead Scoring fields
            AnnualRevenue: metrics.revenue,
            NumberOfEmployees: metrics.employees,
            Lead_Score__c: leadScore,
            
            // Additional fields for better scoring
            Company_Size__c: companySize,
            Revenue_Range__c: revenueRange,
            Tech_Stack__c: this.generateTechStack(industry),
            Decision_Maker__c: this.isDecisionMaker(title),
            Budget_Range__c: this.generateBudgetRange(companySize),
            Timeline__c: this.generateTimeline(),
            Pain_Points__c: this.generatePainPoints(industry),
            Use_Case__c: this.generateUseCase(industry),
            
            // Dates
            CreatedDate: createdDate.toISOString(),
            LastActivityDate: lastActivityDate.toISOString()
        };
    }

    // Generate tech stack based on industry
    generateTechStack(industry) {
        const techStacks = {
            'Technology': ['JavaScript', 'Python', 'React', 'Node.js', 'AWS'],
            'Software': ['Java', 'C#', '.NET', 'Azure', 'Docker'],
            'SaaS': ['React', 'Node.js', 'PostgreSQL', 'AWS', 'Kubernetes'],
            'Cloud Computing': ['AWS', 'Azure', 'GCP', 'Docker', 'Kubernetes'],
            'Artificial Intelligence': ['Python', 'TensorFlow', 'PyTorch', 'AWS', 'MLflow'],
            'Data Analytics': ['Python', 'R', 'SQL', 'Tableau', 'Power BI'],
            'Cybersecurity': ['Python', 'Go', 'AWS', 'Docker', 'Kubernetes'],
            'FinTech': ['Java', 'Python', 'React', 'PostgreSQL', 'AWS'],
            'HealthTech': ['Python', 'React', 'Node.js', 'MongoDB', 'AWS'],
            'EdTech': ['JavaScript', 'React', 'Node.js', 'MongoDB', 'AWS']
        };
        
        const stack = techStacks[industry] || ['JavaScript', 'Python', 'React', 'AWS'];
        return stack[Math.floor(Math.random() * stack.length)];
    }

    // Determine if title is decision maker
    isDecisionMaker(title) {
        const decisionMakers = ['CEO', 'CTO', 'CFO', 'COO', 'VP', 'Director', 'Manager'];
        return decisionMakers.some(role => title.includes(role));
    }

    // Generate budget range based on company size
    generateBudgetRange(companySize) {
        const budgetRanges = {
            '1-10': ['$0-$10K', '$10K-$50K'],
            '11-50': ['$10K-$50K', '$50K-$100K'],
            '51-200': ['$50K-$100K', '$100K-$500K'],
            '201-1000': ['$100K-$500K', '$500K-$1M'],
            '1001-5000': ['$500K-$1M', '$1M-$5M'],
            '5001+': ['$1M-$5M', '$5M+']
        };
        
        const ranges = budgetRanges[companySize] || ['$10K-$50K'];
        return ranges[Math.floor(Math.random() * ranges.length)];
    }

    // Generate timeline
    generateTimeline() {
        const timelines = ['Immediate', '1-3 months', '3-6 months', '6-12 months', '12+ months'];
        return timelines[Math.floor(Math.random() * timelines.length)];
    }

    // Generate pain points based on industry
    generatePainPoints(industry) {
        const painPoints = {
            'Technology': ['Scalability', 'Security', 'Performance', 'Integration'],
            'Software': ['Code Quality', 'Deployment', 'Testing', 'Maintenance'],
            'SaaS': ['User Adoption', 'Churn', 'Feature Requests', 'Support'],
            'Cloud Computing': ['Cost Optimization', 'Security', 'Compliance', 'Migration'],
            'Artificial Intelligence': ['Data Quality', 'Model Performance', 'Ethics', 'Integration'],
            'Data Analytics': ['Data Quality', 'Real-time Processing', 'Visualization', 'Governance'],
            'Cybersecurity': ['Threat Detection', 'Compliance', 'Incident Response', 'Training'],
            'FinTech': ['Compliance', 'Security', 'Regulation', 'Integration'],
            'HealthTech': ['Compliance', 'Data Privacy', 'Integration', 'User Experience'],
            'EdTech': ['User Engagement', 'Content Quality', 'Accessibility', 'Assessment']
        };
        
        const points = painPoints[industry] || ['Scalability', 'Security', 'Performance'];
        return points[Math.floor(Math.random() * points.length)];
    }

    // Generate use case based on industry
    generateUseCase(industry) {
        const useCases = {
            'Technology': ['Product Development', 'Customer Support', 'Sales Automation'],
            'Software': ['Development Tools', 'Testing', 'Deployment'],
            'SaaS': ['Customer Onboarding', 'Feature Usage', 'Support'],
            'Cloud Computing': ['Infrastructure', 'Migration', 'Optimization'],
            'Artificial Intelligence': ['Predictive Analytics', 'Automation', 'Personalization'],
            'Data Analytics': ['Business Intelligence', 'Reporting', 'Insights'],
            'Cybersecurity': ['Threat Detection', 'Compliance', 'Incident Response'],
            'FinTech': ['Payment Processing', 'Risk Management', 'Compliance'],
            'HealthTech': ['Patient Management', 'Clinical Data', 'Telemedicine'],
            'EdTech': ['Learning Management', 'Assessment', 'Content Delivery']
        };
        
        const cases = useCases[industry] || ['Product Development', 'Customer Support'];
        return cases[Math.floor(Math.random() * cases.length)];
    }

    // Generate leads
    generateLeads(numLeads = 1000) {
        console.log(`🎯 Generating ${numLeads} high-tech B2B leads for Einstein Lead Scoring...\n`);
        
        const leads = [];
        for (let i = 0; i < numLeads; i++) {
            leads.push(this.generateLeadData());
            
            if ((i + 1) % 100 === 0) {
                console.log(`  Generated ${i + 1} leads...`);
            }
        }
        
        return leads;
    }

    // Save leads to CSV
    saveLeadsToCSV(leads, filename = 'einstein-leads.csv') {
        const csvHeader = [
            'FirstName', 'LastName', 'Company', 'Email', 'Phone', 'Industry', 'LeadSource',
            'Status', 'Title', 'State', 'City', 'Country', 'Website', 'Description',
            'AnnualRevenue', 'NumberOfEmployees', 'Lead_Score__c', 'Company_Size__c',
            'Revenue_Range__c', 'Tech_Stack__c', 'Decision_Maker__c', 'Budget_Range__c',
            'Timeline__c', 'Pain_Points__c', 'Use_Case__c', 'CreatedDate', 'LastActivityDate'
        ].join(',');
        
        const csvContent = csvHeader + '\n' + leads.map(lead => 
            csvHeader.split(',').map(field => {
                const value = lead[field];
                return typeof value === 'string' && value.includes(',') ? `"${value}"` : value;
            }).join(',')
        ).join('\n');
        
        const outputPath = path.join(this.dataDir, filename);
        fs.writeFileSync(outputPath, csvContent);
        
        console.log(`\n✅ Saved ${leads.length} leads to ${outputPath}`);
        return outputPath;
    }

    // Generate summary statistics
    generateSummary(leads) {
        console.log('\n📊 Lead Generation Summary:');
        console.log(`- Total Leads: ${leads.length}`);
        console.log(`- Unique Companies: ${new Set(leads.map(l => l.Company)).size}`);
        console.log(`- Unique Industries: ${new Set(leads.map(l => l.Industry)).size}`);
        console.log(`- Unique Lead Sources: ${new Set(leads.map(l => l.LeadSource)).size}`);
        console.log(`- Unique Statuses: ${new Set(leads.map(l => l.Status)).size}`);
        console.log(`- Unique States: ${new Set(leads.map(l => l.State)).size}`);
        
        const avgLeadScore = leads.reduce((sum, lead) => sum + lead.Lead_Score__c, 0) / leads.length;
        console.log(`- Average Lead Score: ${avgLeadScore.toFixed(1)}`);
        
        const decisionMakers = leads.filter(l => l.Decision_Maker__c).length;
        console.log(`- Decision Makers: ${decisionMakers} (${((decisionMakers / leads.length) * 100).toFixed(1)}%)`);
        
        console.log('\n📈 Industry Distribution:');
        const industryCounts = {};
        leads.forEach(lead => {
            industryCounts[lead.Industry] = (industryCounts[lead.Industry] || 0) + 1;
        });
        Object.entries(industryCounts)
            .sort(([,a], [,b]) => b - a)
            .slice(0, 10)
            .forEach(([industry, count]) => {
                console.log(`  ${industry}: ${count} (${((count / leads.length) * 100).toFixed(1)}%)`);
            });
        
        console.log('\n📈 Status Distribution:');
        const statusCounts = {};
        leads.forEach(lead => {
            statusCounts[lead.Status] = (statusCounts[lead.Status] || 0) + 1;
        });
        Object.entries(statusCounts)
            .sort(([,a], [,b]) => b - a)
            .forEach(([status, count]) => {
                console.log(`  ${status}: ${count} (${((count / leads.length) * 100).toFixed(1)}%)`);
            });
    }
}

// CLI Interface
const args = process.argv.slice(2);
const numLeads = parseInt(args[0]) || 1000;

console.log('🚀 Einstein Lead Generator for High-Tech B2B');
console.log('============================================\n');

const generator = new EinsteinLeadGenerator();
const leads = generator.generateLeads(numLeads);
const csvPath = generator.saveLeadsToCSV(leads);
generator.generateSummary(leads);

console.log('\n🎉 Lead generation completed!');
console.log(`📁 CSV file: ${csvPath}`);
console.log('\n📋 Next steps:');
console.log('1. Deploy leads to your Salesforce org');
console.log('2. Enable Einstein Lead Scoring');
console.log('3. Wait for Einstein to process the leads (24-48 hours)');
console.log('4. Monitor lead scores in the Lead object');
