// Import leads with completely unique data to bypass duplicate detection
// This script generates leads with unique emails and company names

List<Lead> leadsToInsert = new List<Lead>();

// Get current timestamp for uniqueness
Long timestamp = System.currentTimeMillis();
String uniqueSuffix = String.valueOf(timestamp);

// Create 50 leads with completely unique data
for(Integer i = 0; i < 50; i++) {
    Lead l = new Lead();
    
    // Generate unique names
    l.FirstName = 'Lead' + uniqueSuffix + '_' + String.valueOf(i);
    l.LastName = 'User' + uniqueSuffix + '_' + String.valueOf(i);
    
    // Generate unique company name
    l.Company = 'Company_' + uniqueSuffix + '_' + String.valueOf(i);
    
    // Generate unique email
    l.Email = 'lead' + uniqueSuffix + '_' + String.valueOf(i) + '@uniquecompany' + uniqueSuffix + '.com';
    
    // Generate unique phone
    l.Phone = '(' + String.valueOf(100 + Math.mod(i, 900)) + ') ' + String.valueOf(100 + Math.mod(i, 900)) + '-' + String.valueOf(1000 + Math.mod(i, 9000));
    
    // Set other fields
    l.Industry = 'Technology';
    l.LeadSource = 'Web';
    l.Status = 'New';
    l.Title = 'Manager';
    l.State = 'CA';
    l.City = 'San Francisco';
    l.Country = 'United States';
    l.AnnualRevenue = 100000 + (i * 10000);
    l.NumberOfEmployees = 10 + (i * 5);
    l.Description = 'Unique lead ' + uniqueSuffix + '_' + String.valueOf(i) + ' for testing purposes.';
    
    leadsToInsert.add(l);
}

if(!leadsToInsert.isEmpty()) {
    try {
        insert leadsToInsert;
        System.debug('Successfully inserted ' + leadsToInsert.size() + ' unique leads with suffix ' + uniqueSuffix);
    } catch(Exception e) {
        System.debug('Error inserting leads: ' + e.getMessage());
    }
} 