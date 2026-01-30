// Lead Data Normalization for Demo Realism
// - Standardizes Phone, Email, Title casing
// - Maps miscellaneous Industries and LeadSources to canonical sets
// - Buckets Company_Size__c from NumberOfEmployees when missing
// - Cleans up outlier Status values to a simpler funnel

Integer batchSize = 200;
Integer processed = 0;

// Canonical lists
Set<String> canonicalIndustries = new Set<String>{
    'Technology','Manufacturing','Healthcare','Financial Services','Retail','Education','Energy','Transportation','Media','Government'
};

Map<String, String> industryMap = new Map<String, String>{
    'Tech' => 'Technology',
    'Software' => 'Technology',
    'Hi-Tech' => 'Technology',
    'EdTech' => 'Education',
    'FinTech' => 'Financial Services',
    'Banking' => 'Financial Services',
    'Insurance' => 'Financial Services',
    'Public Sector' => 'Government',
    'Gov' => 'Government',
    'Media & Entertainment' => 'Media',
    'Logistics' => 'Transportation',
    'Energy & Utilities' => 'Energy'
};

Set<String> canonicalSources = new Set<String>{
    'Website','Referral','Event','Email Campaign','Social Media','Partner','Webinar','Inbound Call','Online Search','Cold Call'
};

Map<String, String> sourceMap = new Map<String, String>{
    'LinkedIn' => 'Social Media',
    'Twitter' => 'Social Media',
    'Reddit' => 'Social Media',
    'Hacker News' => 'Social Media',
    'YouTube' => 'Social Media',
    'GitHub' => 'Social Media',
    'Stack Overflow' => 'Online Search',
    'Blog' => 'Online Search',
    'Trade Show' => 'Event',
    'Tech Conference' => 'Event',
    'Marketing Event' => 'Event',
    'Developer Meetup' => 'Event',
    'Case Study' => 'Website',
    'White Paper' => 'Website',
    'Community' => 'Website',
    'Sales Bot' => 'Website',
    'Cold Outreach' => 'Cold Call',
    'Partner Referral' => 'Partner'
};

Map<String, String> statusMap = new Map<String, String>{
    'Draft' => 'New',
    'Submitted' => 'New',
    'Approved' => 'New',
    'Working - Contacted' => 'Working',
    'Working - Nurturing' => 'Working',
    'Not Contacted' => 'New',
    'Attempted Contact' => 'Working',
    'Engaged' => 'Working',
    'Interested' => 'Working',
    'Sales Qualified Lead' => 'Qualified',
    'Marketing Qualified Lead' => 'Qualified'
};

// Helpers
String toTitleCase(String s) {
    if (String.isBlank(s)) return s;
    List<String> parts = s.toLowerCase().split(' ');
    for (Integer i = 0; i < parts.size(); i++) {
        String p = parts[i];
        if (p.length() > 0) parts[i] = p.substring(0,1).toUpperCase() + (p.length() > 1 ? p.substring(1) : '');
    }
    return String.join(parts, ' ');
}

String normalizePhone(String phone) {
    if (String.isBlank(phone)) return phone;
    String digits = phone.replaceAll('[^0-9]', '');
    if (digits.length() == 11 && digits.startsWith('1')) digits = digits.substring(1);
    if (digits.length() == 10) {
        return '(' + digits.substring(0,3) + ') ' + digits.substring(3,6) + '-' + digits.substring(6);
    }
    return phone; // leave as-is if unexpected
}

String companyToDomain(String company) {
    if (String.isBlank(company)) return 'example.com';
    String base = company.toLowerCase().replaceAll('[^a-z0-9]+', '-');
    base = base.replaceAll('^-+|-+$','');
    if (String.isBlank(base)) base = 'example';
    return base + '.com';
}

String normalizeIndustry(String v) {
    if (String.isBlank(v)) return null;
    String s = v.trim();
    if (industryMap.containsKey(s)) return industryMap.get(s);
    if (canonicalIndustries.contains(s)) return s;
    // fallback bucket by keyword
    String low = s.toLowerCase();
    if (low.contains('tech') || low.contains('software')) return 'Technology';
    if (low.contains('educ')) return 'Education';
    if (low.contains('bank') || low.contains('fin') || low.contains('insur')) return 'Financial Services';
    if (low.contains('gov') || low.contains('public')) return 'Government';
    if (low.contains('manuf')) return 'Manufacturing';
    if (low.contains('retail') || low.contains('ecomm')) return 'Retail';
    if (low.contains('health') || low.contains('med')) return 'Healthcare';
    if (low.contains('energy') || low.contains('util')) return 'Energy';
    if (low.contains('trans') || low.contains('logi')) return 'Transportation';
    if (low.contains('media') || low.contains('entertain')) return 'Media';
    return 'Technology';
}

String normalizeSource(String v) {
    if (String.isBlank(v)) return 'Website';
    String s = v.trim();
    if (sourceMap.containsKey(s)) return sourceMap.get(s);
    if (canonicalSources.contains(s)) return s;
    // keyword fallback
    String low = s.toLowerCase();
    if (low.contains('web') || low.contains('site') || low.contains('form')) return 'Website';
    if (low.contains('refer') || low.contains('partner')) return 'Referral';
    if (low.contains('event') || low.contains('trade') || low.contains('conf') || low.contains('show')) return 'Event';
    if (low.contains('email')) return 'Email Campaign';
    if (low.contains('social') || low.contains('linkedin') || low.contains('twitter') || low.contains('reddit')) return 'Social Media';
    if (low.contains('call')) return 'Cold Call';
    if (low.contains('search')) return 'Online Search';
    return 'Website';
}

String bucketCompanySize(Integer employees) {
    if (employees == null) return null;
    if (employees <= 10) return '1-10';
    if (employees <= 50) return '11-50';
    if (employees <= 200) return '51-200';
    if (employees <= 500) return '201-500';
    if (employees <= 1000) return '501-1000';
    if (employees <= 5000) return '1001-5000';
    return '5001+';
}

// Fetch leads in pages
Integer offsetVal = 0;
while (true) {
    List<Lead> leads = [
        SELECT Id, FirstName, LastName, Company, Email, Phone, Industry, LeadSource, Status,
               Title, City, State, Country, AnnualRevenue, NumberOfEmployees, Description
        FROM Lead
        ORDER BY CreatedDate DESC
        LIMIT :batchSize OFFSET :offsetVal
    ];
    if (leads.isEmpty()) break;

    List<Lead> updates = new List<Lead>();
    // Detect optional custom fields
    Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Lead.fields.getMap();
    Boolean hasCompanySize = fieldMap.containsKey('Company_Size__c');
    for (Lead l : leads) {
        Lead u = new Lead(Id = l.Id);

        // Phone
        if (l.Phone != null) u.Phone = normalizePhone(l.Phone);

        // Email lowercasing and fallback domain if malformed
        if (l.Email != null) {
            u.Email = l.Email.toLowerCase();
        } else if (l.LastName != null && l.Company != null) {
            String dom = companyToDomain(l.Company);
            String first = (l.FirstName == null) ? 'contact' : l.FirstName.toLowerCase().replaceAll('[^a-z]','');
            String last = l.LastName.toLowerCase().replaceAll('[^a-z]','');
            u.Email = first + '.' + last + '@' + dom;
        }

        // Title casing
        if (l.Title != null) u.Title = toTitleCase(l.Title);
        if (l.City != null) u.City = toTitleCase(l.City);

        // Industry/Source normalization
        if (l.Industry != null) u.Industry = normalizeIndustry(l.Industry);
        u.LeadSource = normalizeSource(l.LeadSource);

        // Company size bucket if missing (only if field exists)
        if (hasCompanySize) {
            String sizeBucket = bucketCompanySize(l.NumberOfEmployees);
            if (sizeBucket != null) {
                // use dynamic put to avoid compile-time dependency if field is absent
                ((SObject)u).put('Company_Size__c', sizeBucket);
            }
        }

        // Status cleanup (don’t change Converted/Closed Won/Lost if used downstream)
        if (l.Status != null && statusMap.containsKey(l.Status)) {
            u.Status = statusMap.get(l.Status);
        }

        updates.add(u);
    }

    try {
        update updates;
        processed += updates.size();
        System.debug('Updated ' + updates.size() + ' leads');
    } catch (Exception e) {
        System.debug('Lead update error: ' + e.getMessage());
    }

    offsetVal += batchSize;
}

System.debug('Lead normalization complete. Total updated: ' + processed);


