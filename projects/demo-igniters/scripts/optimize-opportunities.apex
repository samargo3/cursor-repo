// Opportunity Data Optimization for Demo
// This script redistributes opportunities for better demo presentation

// Get all opportunities
List<Opportunity> allOpps = [SELECT Id, Name, StageName, OwnerId, Owner.Name, Type, Amount, Probability, CloseDate 
                            FROM Opportunity 
                            ORDER BY CreatedDate DESC];

System.debug('Total opportunities to optimize: ' + allOpps.size());

// Get all users for redistribution
List<User> allUsers = [SELECT Id, Name FROM User WHERE IsActive = true AND Profile.Name LIKE '%Sales%' LIMIT 10];
System.debug('Available users for redistribution: ' + allUsers.size());

// Get opportunities owned by Sam Argo (the over-represented user)
List<Opportunity> samOpps = [SELECT Id, Name, StageName, OwnerId, Owner.Name, Type, Amount, Probability, CloseDate 
                            FROM Opportunity 
                            WHERE Owner.Name = 'Sam Argo' 
                            ORDER BY CreatedDate DESC];

System.debug('Sam Argo opportunities: ' + samOpps.size());

// Redistribute Sam's opportunities to other users
List<Opportunity> oppsToUpdate = new List<Opportunity>();
Integer userIndex = 0;

for (Integer i = 0; i < samOpps.size(); i++) {
    Opportunity opp = samOpps[i];
    
    // Skip if this is one of the first 100 opportunities (keep some for Sam)
    if (i < 100) continue;
    
    // Assign to different user
    if (userIndex >= allUsers.size()) {
        userIndex = 0;
    }
    
    opp.OwnerId = allUsers[userIndex].Id;
    oppsToUpdate.add(opp);
    userIndex++;
}

System.debug('Opportunities to reassign: ' + oppsToUpdate.size());

// Update opportunities
if (!oppsToUpdate.isEmpty()) {
    try {
        update oppsToUpdate;
        System.debug('Successfully reassigned ' + oppsToUpdate.size() + ' opportunities');
    } catch (Exception e) {
        System.debug('Error reassigning opportunities: ' + e.getMessage());
    }
}

// Move some Closed Won opportunities to active stages for better demo flow
List<Opportunity> closedWonOpps = [SELECT Id, Name, StageName, OwnerId, Owner.Name, Type, Amount, Probability, CloseDate 
                                  FROM Opportunity 
                                  WHERE StageName = 'Closed Won' 
                                  ORDER BY CreatedDate DESC 
                                  LIMIT 200];

System.debug('Closed Won opportunities to move: ' + closedWonOpps.size());

List<Opportunity> stageOppsToUpdate = new List<Opportunity>();
String[] activeStages = new String[]{'Proposal/Quote', 'Negotiation', 'Discovery', 'Qualification'};
Integer stageIndex = 0;

for (Integer i = 0; i < Math.min(150, closedWonOpps.size()); i++) {
    Opportunity opp = closedWonOpps[i];
    
    // Move to active stage
    opp.StageName = activeStages[Math.mod(stageIndex, activeStages.size())];
    
    // Update probability based on stage
    if (opp.StageName == 'Discovery') {
        opp.Probability = 25;
    } else if (opp.StageName == 'Qualification') {
        opp.Probability = 40;
    } else if (opp.StageName == 'Proposal/Quote') {
        opp.Probability = 60;
    } else if (opp.StageName == 'Negotiation') {
        opp.Probability = 80;
    }
    
    // Update close date to be in the future
    opp.CloseDate = Date.today().addDays(30 + (Math.mod(i, 90)));
    
    stageOppsToUpdate.add(opp);
    stageIndex++;
}

System.debug('Opportunities to move to active stages: ' + stageOppsToUpdate.size());

// Update stage changes
if (!stageOppsToUpdate.isEmpty()) {
    try {
        update stageOppsToUpdate;
        System.debug('Successfully moved ' + stageOppsToUpdate.size() + ' opportunities to active stages');
    } catch (Exception e) {
        System.debug('Error moving opportunities: ' + e.getMessage());
    }
}

// Add variety to opportunity types
List<Opportunity> oppsToUpdateType = [SELECT Id, Name, StageName, OwnerId, Owner.Name, Type, Amount, Probability, CloseDate 
                                    FROM Opportunity 
                                    WHERE Type = null OR Type = 'Services' 
                                    ORDER BY CreatedDate DESC 
                                    LIMIT 50];

System.debug('Opportunities to update type: ' + oppsToUpdateType.size());

String[] newTypes = new String[]{'Renewal', 'Upsell', 'Cross-sell', 'New Business', 'Add-On Business'};
Integer typeIndex = 0;

for (Opportunity opp : oppsToUpdateType) {
    opp.Type = newTypes[Math.mod(typeIndex, newTypes.size())];
    typeIndex++;
}

if (!oppsToUpdateType.isEmpty()) {
    try {
        update oppsToUpdateType;
        System.debug('Successfully updated ' + oppsToUpdateType.size() + ' opportunity types');
    } catch (Exception e) {
        System.debug('Error updating opportunity types: ' + e.getMessage());
    }
}

// Ensure realistic amount distribution
List<Opportunity> oppsToUpdateAmount = [SELECT Id, Name, StageName, OwnerId, Owner.Name, Type, Amount, Probability, CloseDate 
                                       FROM Opportunity 
                                       WHERE Amount = null OR Amount = 0 
                                       ORDER BY CreatedDate DESC 
                                       LIMIT 100];

System.debug('Opportunities to update amount: ' + oppsToUpdateAmount.size());

for (Integer i = 0; i < oppsToUpdateAmount.size(); i++) {
    Opportunity opp = oppsToUpdateAmount[i];
    
    // Generate realistic amounts based on stage and type
    Decimal baseAmount = 0;
    
    if (opp.StageName == 'Discovery') {
        baseAmount = 5000 + (Math.random() * 15000); // $5K - $20K
    } else if (opp.StageName == 'Qualification') {
        baseAmount = 10000 + (Math.random() * 40000); // $10K - $50K
    } else if (opp.StageName == 'Proposal/Quote') {
        baseAmount = 25000 + (Math.random() * 75000); // $25K - $100K
    } else if (opp.StageName == 'Negotiation') {
        baseAmount = 50000 + (Math.random() * 150000); // $50K - $200K
    } else {
        baseAmount = 10000 + (Math.random() * 90000); // $10K - $100K
    }
    
    // Adjust based on type
    if (opp.Type == 'Renewal') {
        baseAmount = baseAmount * 0.7; // Renewals are typically smaller
    } else if (opp.Type == 'Upsell') {
        baseAmount = baseAmount * 1.3; // Upsells are typically larger
    } else if (opp.Type == 'Cross-sell') {
        baseAmount = baseAmount * 0.8; // Cross-sells are typically medium
    }
    
    opp.Amount = baseAmount.setScale(2);
}

if (!oppsToUpdateAmount.isEmpty()) {
    try {
        update oppsToUpdateAmount;
        System.debug('Successfully updated ' + oppsToUpdateAmount.size() + ' opportunity amounts');
    } catch (Exception e) {
        System.debug('Error updating opportunity amounts: ' + e.getMessage());
    }
}

System.debug('Opportunity optimization completed!');
System.debug('Check the new distribution with: SELECT StageName, COUNT(Id) FROM Opportunity GROUP BY StageName');
System.debug('Check owner distribution with: SELECT Owner.Name, COUNT(Id) FROM Opportunity GROUP BY Owner.Name');
