// Import leads safely by checking for existing records first
// This script avoids duplicate detection issues

// Get current timestamp for uniqueness
Long timestamp = System.currentTimeMillis();
String uniqueSuffix = String.valueOf(timestamp);

// Check how many leads we currently have
Integer currentLeadCount = [SELECT COUNT() FROM Lead];
System.debug('Current lead count: ' + currentLeadCount);

// Create 50 leads with completely unique data
List<Lead> leadsToInsert = new List<Lead>();

for(Integer i = 0; i < 50; i++) {
    Lead l = new Lead();
    
    // Generate unique names with timestamp
    l.FirstName = 'TestLead' + uniqueSuffix + '_' + String.valueOf(i);
    l.LastName = 'TestUser' + uniqueSuffix + '_' + String.valueOf(i);
    
    // Generate unique company name
    l.Company = 'TestCompany_' + uniqueSuffix + '_' + String.valueOf(i);
    
    // Generate unique email
    l.Email = 'testlead' + uniqueSuffix + '_' + String.valueOf(i) + '@testcompany' + uniqueSuffix + '.test';
    
    // Generate unique phone
    l.Phone = '(' + String.valueOf(900 + Math.mod(i, 100)) + ') ' + String.valueOf(900 + Math.mod(i, 100)) + '-' + String.valueOf(1000 + Math.mod(i, 9000));
    
    // Set other fields
    l.Industry = 'Technology';
    l.LeadSource = 'Web';
    l.Status = 'New';
    l.Title = 'Test Manager';
    l.State = 'CA';
    l.City = 'Test City';
    l.Country = 'United States';
    l.AnnualRevenue = 100000 + (i * 10000);
    l.NumberOfEmployees = 10 + (i * 5);
    l.Description = 'Test lead ' + uniqueSuffix + '_' + String.valueOf(i) + ' for testing purposes.';
    
    leadsToInsert.add(l);
}

if(!leadsToInsert.isEmpty()) {
    try {
        insert leadsToInsert;
        System.debug('Successfully inserted ' + leadsToInsert.size() + ' test leads with suffix ' + uniqueSuffix);
        
        // Check new count
        Integer newLeadCount = [SELECT COUNT() FROM Lead];
        System.debug('New lead count: ' + newLeadCount);
        System.debug('Leads added: ' + (newLeadCount - currentLeadCount));
        
    } catch(Exception e) {
        System.debug('Error inserting leads: ' + e.getMessage());
        System.debug('Error details: ' + e.getStackTraceString());
    }
} 