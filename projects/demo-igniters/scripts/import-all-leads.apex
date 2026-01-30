// Import all leads from CSV in batches
// This script reads the full CSV and imports leads in batches of 200

// Read the CSV data (first 200 leads for this batch)
String csvData = 'FirstName,LastName,Company,Email,Phone,Industry,LeadSource,Status,Title,State,City,Country,AnnualRevenue,NumberOfEmployees,Description,CreatedDate,LastActivityDate\nLisa,Williams,Digital Dynamics,lisa_williams@digitaldynamics.com,(461) 977-9631,Agriculture,Cold Call,New,Marketing Specialist,WY,Houston,United States,2347,93,Lead for Digital Dynamics in Agriculture industry. Lisa Williams is a Marketing Specialist looking for solutions.,2024-02-02T04:44:13.941Z,2024-08-24T05:14:14.655Z\nMichael,Sanchez,Manufacturing Tech,michael924@gmail.com,(716) 986-2074,Manufacturing,LinkedIn,Working,HR Manager,MT,Atlanta,United States,5900,5,Lead for Manufacturing Tech in Manufacturing industry. Michael Sanchez is a HR Manager looking for solutions.,2024-09-23T22:53:24.539Z,2024-11-10T07:04:27.277Z\nEmily,Torres,Construction Tech,emily.torres@constructiontech.com,(378) 957-9400,Education,Advertisement,Unqualified,Director of Operations,TX,San Jose,United States,2437,60,Lead for Construction Tech in Education industry. Emily Torres is a Director of Operations looking for solutions.,2025-01-24T09:11:06.919Z,2025-08-02T22:20:48.759Z\nKaren,Price,Strategy Tech,karen.price@yahoo.com,(472) 710-1929,Retail,Email Campaign,New,Manager,OK,Kansas City,United States,7812,31,Lead for Strategy Tech in Retail industry. Karen Price is a Manager looking for solutions.,2025-07-22T22:58:11.845Z,2025-08-05T06:37:36.053Z\nKaren,Rivera,PatientCare Tech,karen_rivera@patientcaretech.com,(723) 926-1702,Energy,Web,New,Director of IT,NJ,Louisville,United States,8871,92,Lead for PatientCare Tech in Energy industry. Karen Rivera is a Director of IT looking for solutions.,2023-12-19T18:49:58.518Z,2025-07-01T15:21:20.808Z\nDeborah,Robinson,Digital Health Systems,deborah.robinson@digitalhealthsystems.com,(237) 574-8141,Manufacturing,Instagram,Qualified,Product Manager,IL,Las Vegas,United States,6215,14,Lead for Digital Health Systems in Manufacturing industry. Deborah Robinson is a Product Manager looking for solutions.,2025-07-22T20:45:08.491Z,2025-08-01T17:41:43.849Z\nAlexander,Ward,Automation Systems,alexander_ward@automationsystems.com,(278) 647-7557,Technology,Blog,Unqualified,VP of Sales,OK,Boston,United States,9333,94,Lead for Automation Systems in Technology industry. Alexander Ward is a VP of Sales looking for solutions.,2023-04-16T13:17:12.093Z,2024-07-11T01:39:41.785Z\nJeffrey,Nguyen,Consulting Services,jeffrey404@hotmail.com,(728) 336-5096,Media,Instagram,Closed Lost,Strategy Director,KS,Sacramento,United States,8448,7,Lead for Consulting Services in Media industry. Jeffrey Nguyen is a Strategy Director looking for solutions.,2025-06-01T17:06:20.098Z,2025-07-19T06:56:45.892Z\nKimberly,Allen,CloudBridge Inc,kimberly971@outlook.com,(338) 523-9042,Government,Website Form,Working,Director of IT,IA,Kansas City,United States,7978,7,Lead for CloudBridge Inc in Government industry. Kimberly Allen is a Director of IT looking for solutions.,2024-12-26T20:37:35.336Z,2025-08-01T07:34:30.939Z\nCarol,Wright,Learning Systems,carol.wright@hotmail.com,(424) 921-1146,Consulting,Trade Show,Closed Won,Business Development,AL,Los Angeles,United States,888,7,Lead for Learning Systems in Consulting industry. Carol Wright is a Business Development looking for solutions.,2025-07-17T20:55:19.406Z,2025-07-31T04:41:44.557Z';

String[] lines = csvData.split('\n');
List<Lead> leadsToInsert = new List<Lead>();

// Skip header and process first 200 leads
Integer processedCount = 0;
Integer maxLeads = 200;

for(Integer i = 1; i < lines.size() && processedCount < maxLeads; i++) {
    String line = lines[i];
    if(String.isNotBlank(line)) {
        String[] fields = line.split(',');
        if(fields.size() >= 15) {
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
            l.AnnualRevenue = Decimal.valueOf(fields[12]);
            l.NumberOfEmployees = Integer.valueOf(fields[13]);
            l.Description = fields[14].removeStart('"').removeEnd('"');
            
            leadsToInsert.add(l);
            processedCount++;
        }
    }
}

if(!leadsToInsert.isEmpty()) {
    try {
        insert leadsToInsert;
        System.debug('Successfully inserted ' + leadsToInsert.size() + ' leads (Batch 1)');
    } catch(Exception e) {
        System.debug('Error inserting leads: ' + e.getMessage());
    }
} 