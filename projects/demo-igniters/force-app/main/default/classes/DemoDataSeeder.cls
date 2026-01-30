/**
 * Demo Data Seeder
 * Generates sample Accounts, Contacts, and Opportunities for Sales Demo Hub
 */
public with sharing class DemoDataSeeder {
    
    /**
     * Seeds all demo data: Accounts, Contacts, and Opportunities
     * @return Map with counts of created records
     */
    @AuraEnabled
    public static Map<String, Integer> seedAllDemoData() {
        Map<String, Integer> results = new Map<String, Integer>();
        
        try {
            // Create Accounts
            List<Account> accounts = createDemoAccounts();
            insert accounts;
            results.put('accounts', accounts.size());
            
            // Create Contacts for each Account
            List<Contact> contacts = createDemoContacts(accounts);
            insert contacts;
            results.put('contacts', contacts.size());
            
            // Create Opportunities for each Account
            List<Opportunity> opportunities = createDemoOpportunities(accounts);
            insert opportunities;
            results.put('opportunities', opportunities.size());
            
            return results;
        } catch (Exception e) {
            throw new AuraHandledException('Error seeding demo data: ' + e.getMessage());
        }
    }
    
    /**
     * Clears all demo data (only records created by this seeder)
     */
    @AuraEnabled
    public static Map<String, Integer> clearDemoData() {
        Map<String, Integer> results = new Map<String, Integer>();
        
        try {
            // Delete Opportunities with 'Demo - ' prefix
            List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE Name LIKE 'Demo - %'];
            delete opps;
            results.put('opportunitiesDeleted', opps.size());
            
            // Delete Contacts from demo accounts
            List<Contact> contacts = [SELECT Id FROM Contact WHERE Account.Name LIKE 'Demo Corp -%'];
            delete contacts;
            results.put('contactsDeleted', contacts.size());
            
            // Delete Accounts with 'Demo Corp -' prefix
            List<Account> accounts = [SELECT Id FROM Account WHERE Name LIKE 'Demo Corp -%'];
            delete accounts;
            results.put('accountsDeleted', accounts.size());
            
            return results;
        } catch (Exception e) {
            throw new AuraHandledException('Error clearing demo data: ' + e.getMessage());
        }
    }
    
    /**
     * Creates sample Accounts
     */
    private static List<Account> createDemoAccounts() {
        List<Account> accounts = new List<Account>();
        List<String> industries = new List<String>{'Technology', 'Healthcare', 'Financial Services', 'Manufacturing', 'Retail'};
        List<String> types = new List<String>{'Customer', 'Prospect', 'Partner'};
        
        for (Integer i = 1; i <= 10; i++) {
            Account acc = new Account(
                Name = 'Demo Corp - ' + getCompanyName(i),
                Industry = industries[Math.mod(i, industries.size())],
                Type = types[Math.mod(i, types.size())],
                AnnualRevenue = 1000000 + (i * 250000),
                NumberOfEmployees = 50 + (i * 50),
                Phone = '(555) ' + String.valueOf(1000 + i) + '-' + String.valueOf(2000 + i),
                Website = 'demo' + i + '.example.com',
                BillingStreet = i + ' Main Street',
                BillingCity = getCityName(i),
                BillingState = getStateName(i),
                BillingPostalCode = String.valueOf(10000 + i),
                BillingCountry = 'USA'
            );
            accounts.add(acc);
        }
        
        return accounts;
    }
    
    /**
     * Creates sample Contacts for Accounts
     */
    private static List<Contact> createDemoContacts(List<Account> accounts) {
        List<Contact> contacts = new List<Contact>();
        List<String> titles = new List<String>{'CEO', 'CFO', 'VP Sales', 'Director of Operations', 'IT Manager'};
        
        for (Account acc : accounts) {
            // Create 2-3 contacts per account
            Integer numContacts = Math.mod(Integer.valueOf(Math.random() * 100), 2) + 2;
            
            for (Integer i = 0; i < numContacts; i++) {
                Contact con = new Contact(
                    AccountId = acc.Id,
                    FirstName = getFirstName(i),
                    LastName = getLastName(i),
                    Title = titles[Math.mod(i, titles.size())],
                    Email = getFirstName(i).toLowerCase() + '.' + getLastName(i).toLowerCase() + '@' + acc.Website,
                    Phone = acc.Phone,
                    MobilePhone = '(555) ' + String.valueOf(5000 + i) + '-' + String.valueOf(6000 + i)
                );
                contacts.add(con);
            }
        }
        
        return contacts;
    }
    
    /**
     * Creates sample Opportunities for Accounts
     */
    private static List<Opportunity> createDemoOpportunities(List<Account> accounts) {
        List<Opportunity> opportunities = new List<Opportunity>();
        List<String> stages = new List<String>{'Prospecting', 'Qualification', 'Needs Analysis', 'Value Proposition', 'Negotiation/Review', 'Closed Won'};
        List<String> types = new List<String>{'New Business', 'Existing Business', 'Renewal'};
        
        Integer oppCounter = 1;
        for (Account acc : accounts) {
            // Create 1-3 opportunities per account
            Integer numOpps = Math.mod(Integer.valueOf(Math.random() * 100), 3) + 1;
            
            for (Integer i = 0; i < numOpps; i++) {
                String stage = stages[Math.mod(oppCounter, stages.size())];
                Integer probability = getProbabilityForStage(stage);
                
                Opportunity opp = new Opportunity(
                    Name = 'Demo - ' + acc.Name + ' ' + types[Math.mod(i, types.size())],
                    AccountId = acc.Id,
                    StageName = stage,
                    Amount = 50000 + (oppCounter * 15000),
                    CloseDate = Date.today().addDays(30 + (oppCounter * 10)),
                    Probability = probability,
                    Type = types[Math.mod(i, types.size())],
                    LeadSource = getLeadSource(oppCounter)
                );
                opportunities.add(opp);
                oppCounter++;
            }
        }
        
        return opportunities;
    }
    
    // Helper methods for generating realistic data
    private static String getCompanyName(Integer index) {
        List<String> names = new List<String>{'Acme Solutions', 'Global Innovations', 'TechVentures', 'Pinnacle Systems', 
            'Summit Industries', 'Horizon Group', 'Catalyst Partners', 'Nexus Technologies', 'Vertex Solutions', 'Apex Enterprises'};
        return names[Math.mod(index - 1, names.size())];
    }
    
    private static String getCityName(Integer index) {
        List<String> cities = new List<String>{'San Francisco', 'New York', 'Chicago', 'Austin', 'Seattle', 
            'Boston', 'Denver', 'Atlanta', 'Los Angeles', 'Miami'};
        return cities[Math.mod(index - 1, cities.size())];
    }
    
    private static String getStateName(Integer index) {
        List<String> states = new List<String>{'CA', 'NY', 'IL', 'TX', 'WA', 'MA', 'CO', 'GA', 'CA', 'FL'};
        return states[Math.mod(index - 1, states.size())];
    }
    
    private static String getFirstName(Integer index) {
        List<String> names = new List<String>{'James', 'Sarah', 'Michael', 'Jennifer', 'David', 
            'Emily', 'Robert', 'Jessica', 'William', 'Amanda'};
        return names[Math.mod(index, names.size())];
    }
    
    private static String getLastName(Integer index) {
        List<String> names = new List<String>{'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 
            'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez'};
        return names[Math.mod(index, names.size())];
    }
    
    private static String getLeadSource(Integer index) {
        List<String> sources = new List<String>{'Web', 'Phone Inquiry', 'Partner Referral', 'Purchased List', 'Trade Show'};
        return sources[Math.mod(index, sources.size())];
    }
    
    private static Integer getProbabilityForStage(String stage) {
        Map<String, Integer> stageProbability = new Map<String, Integer>{
            'Prospecting' => 10,
            'Qualification' => 20,
            'Needs Analysis' => 40,
            'Value Proposition' => 60,
            'Negotiation/Review' => 80,
            'Closed Won' => 100,
            'Closed Lost' => 0
        };
        return stageProbability.containsKey(stage) ? stageProbability.get(stage) : 50;
    }
}

