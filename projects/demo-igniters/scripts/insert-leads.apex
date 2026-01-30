// Read the CSV file and insert leads
String csvData = 'FirstName,LastName,Company,Email,Phone,Industry,LeadSource,Status,Title,State,City,Country,AnnualRevenue,NumberOfEmployees,Description,CreatedDate,LastActivityDate\nLisa,Williams,Digital Dynamics,lisa_williams@digitaldynamics.com,(461) 977-9631,Agriculture,Cold Call,New,Marketing Specialist,WY,Houston,United States,2347,93,Lead for Digital Dynamics in Agriculture industry. Lisa Williams is a Marketing Specialist looking for solutions.,2024-02-02T04:44:13.941Z,2024-08-24T05:14:14.655Z\nMichael,Sanchez,Manufacturing Tech,michael924@gmail.com,(716) 986-2074,Manufacturing,LinkedIn,Working,HR Manager,MT,Atlanta,United States,5900,5,Lead for Manufacturing Tech in Manufacturing industry. Michael Sanchez is a HR Manager looking for solutions.,2024-09-23T22:53:24.539Z,2024-11-10T07:04:27.277Z\nEmily,Torres,Construction Tech,emily.torres@constructiontech.com,(378) 957-9400,Education,Advertisement,Unqualified,Director of Operations,TX,San Jose,United States,2437,60,Lead for Construction Tech in Education industry. Emily Torres is a Director of Operations looking for solutions.,2025-01-24T09:11:06.919Z,2025-08-02T22:20:48.759Z\nKaren,Price,Strategy Tech,karen.price@yahoo.com,(472) 710-1929,Retail,Email Campaign,New,Manager,OK,Kansas City,United States,7812,31,Lead for Strategy Tech in Retail industry. Karen Price is a Manager looking for solutions.,2025-07-22T22:58:11.845Z,2025-08-05T06:37:36.053Z\nKaren,Rivera,PatientCare Tech,karen_rivera@patientcaretech.com,(723) 926-1702,Energy,Web,New,Director of IT,NJ,Louisville,United States,8871,92,Lead for PatientCare Tech in Energy industry. Karen Rivera is a Director of IT looking for solutions.,2023-12-19T18:49:58.518Z,2025-07-01T15:21:20.808Z';

String[] lines = csvData.split('\n');
List<Lead> leadsToInsert = new List<Lead>();

// Skip header
for(Integer i = 1; i < lines.size(); i++) {
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
        }
    }
}

if(!leadsToInsert.isEmpty()) {
    try {
        insert leadsToInsert;
        System.debug('Successfully inserted ' + leadsToInsert.size() + ' leads');
    } catch(Exception e) {
        System.debug('Error inserting leads: ' + e.getMessage());
    }
} 