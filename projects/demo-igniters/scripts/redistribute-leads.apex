// Evenly redistribute Leads across active sales users for demo realism
// - Excludes integration/queue/bot users
// - Skips converted leads
// - Preserves ownership for owners not in the pool unless includeOthers = true
// - Round-robin assignment prioritized to least-loaded users first

Boolean includeOthers = true; // set true to redistribute all leads regardless of current owner
Integer batchSize = 200;

// Identify target sales users (active humans)
List<User> candidateUsers = [
    SELECT Id, Name
    FROM User
    WHERE IsActive = true
      AND Profile.Name IN ('System Administrator','Sales User','Standard User')
      AND (UserType = 'Standard' OR UserType = 'CSPLitePortal')
      AND Name NOT LIKE '%Integration%'
      AND Name NOT LIKE '%Bot%'
      AND Name NOT LIKE '%API%'
    ORDER BY Name
];

if (candidateUsers.isEmpty()) {
    System.debug('No candidate users found for redistribution.');
    return;
}

List<Id> pool = new List<Id>();
for (User u : candidateUsers) {
    pool.add(u.Id);
}
Integer poolSize = pool.size();
System.debug('Candidate pool size: ' + poolSize + ' users');

// Get current counts per owner for info
AggregateResult[] ownerAgg = [
    SELECT OwnerId oid, COUNT(Id) cnt FROM Lead
    WHERE IsConverted = false
    GROUP BY OwnerId
];
Map<Id, Integer> currentCounts = new Map<Id, Integer>();
Integer totalLeads = 0;
for (AggregateResult ar : ownerAgg) {
    Id oid = (Id) ar.get('oid');
    Integer cnt = (Integer) ar.get('expr0');
    currentCounts.put(oid, cnt);
    totalLeads += cnt;
}
System.debug('Total open leads: ' + totalLeads);

// Compute target per user
Integer targetPerUser = (Integer) Math.floor((Decimal) totalLeads / poolSize);
Integer remainder = totalLeads - (targetPerUser * poolSize);
System.debug('Target per user: ' + targetPerUser + ', remainder: ' + remainder);

// Build list of leads to redistribute
List<Lead> toReassign = new List<Lead>();
Integer offsetVal = 0;
while (true) {
    List<Lead> page = [
        SELECT Id, OwnerId
        FROM Lead
        WHERE IsConverted = false
        ORDER BY CreatedDate DESC
        LIMIT :batchSize OFFSET :offsetVal
    ];
    if (page.isEmpty()) break;

    for (Lead l : page) {
        if (includeOthers || !pool.contains(l.OwnerId)) {
            toReassign.add(l);
        }
    }
    offsetVal += batchSize;
}
System.debug('Leads selected for redistribution: ' + toReassign.size());

// Prepare round-robin, seeded by current imbalance so users with fewer get first
List<Id> remaining = pool.deepClone();
List<Id> assignmentOrder = new List<Id>();
while (!remaining.isEmpty()) {
    Id minUser;
    Integer minCount;
    for (Id uid : remaining) {
        Integer c = currentCounts.containsKey(uid) ? currentCounts.get(uid) : 0;
        if (minUser == null || c < minCount) {
            minUser = uid;
            minCount = c;
        }
    }
    assignmentOrder.add(minUser);
    remaining.remove(minUser);
}

Integer idx = 0;
List<Lead> updates = new List<Lead>();
for (Lead l : toReassign) {
    Integer pos = Math.mod(idx, poolSize);
    Id assigned = assignmentOrder[pos];
    idx++;
    if (l.OwnerId == assigned) continue;
    updates.add(new Lead(Id = l.Id, OwnerId = assigned));
    // Batch update
    if (updates.size() == 200) {
        try { update updates; } catch (Exception e) { System.debug('Update error: ' + e.getMessage()); }
        updates.clear();
    }
}
if (!updates.isEmpty()) {
    try { update updates; } catch (Exception e) { System.debug('Final update error: ' + e.getMessage()); }
}

System.debug('Redistribution complete. Assigned ' + idx + ' leads in round-robin.');
