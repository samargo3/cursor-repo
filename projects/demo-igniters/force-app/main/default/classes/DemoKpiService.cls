/**
 * Demo KPI Service
 * Provides key performance indicators and metrics for Sales Demo Hub dashboard
 */
public with sharing class DemoKpiService {
    
    /**
     * Wrapper class for KPI data
     */
    public class KpiData {
        @AuraEnabled public Decimal totalRevenue;
        @AuraEnabled public Integer totalOpportunities;
        @AuraEnabled public Integer openOpportunities;
        @AuraEnabled public Integer wonOpportunities;
        @AuraEnabled public Decimal winRate;
        @AuraEnabled public Decimal averageDealSize;
        @AuraEnabled public Integer totalAccounts;
        @AuraEnabled public Integer totalContacts;
        @AuraEnabled public List<PipelineStage> pipelineData;
        @AuraEnabled public List<RecentActivity> recentActivities;
    }
    
    /**
     * Wrapper class for Pipeline Stage data
     */
    public class PipelineStage {
        @AuraEnabled public String stage;
        @AuraEnabled public Integer count;
        @AuraEnabled public Decimal value;
        
        public PipelineStage(String stage, Integer count, Decimal value) {
            this.stage = stage;
            this.count = count;
            this.value = value;
        }
    }
    
    /**
     * Wrapper class for Recent Activity
     */
    public class RecentActivity {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String type;
        @AuraEnabled public String status;
        @AuraEnabled public Decimal amount;
        @AuraEnabled public DateTime lastModified;
        
        public RecentActivity(String id, String name, String type, String status, Decimal amount, DateTime lastModified) {
            this.id = id;
            this.name = name;
            this.type = type;
            this.status = status;
            this.amount = amount;
            this.lastModified = lastModified;
        }
    }
    
    /**
     * Fetches all KPI data for the dashboard
     */
    @AuraEnabled(cacheable=true)
    public static KpiData getKpiData() {
        KpiData data = new KpiData();
        
        try {
            // Get aggregate opportunity data
            AggregateResult[] oppResults = [
                SELECT 
                    COUNT(Id) totalCount,
                    SUM(Amount) totalRevenue,
                    AVG(Amount) avgDeal
                FROM Opportunity 
                WHERE Amount != null
            ];
            
            if (!oppResults.isEmpty()) {
                data.totalOpportunities = (Integer)oppResults[0].get('totalCount');
                data.totalRevenue = (Decimal)oppResults[0].get('totalRevenue');
                data.averageDealSize = (Decimal)oppResults[0].get('avgDeal');
            }
            
            // Get open opportunities
            data.openOpportunities = [
                SELECT COUNT() 
                FROM Opportunity 
                WHERE IsClosed = false
            ];
            
            // Get won opportunities
            data.wonOpportunities = [
                SELECT COUNT() 
                FROM Opportunity 
                WHERE IsWon = true
            ];
            
            // Calculate win rate
            if (data.totalOpportunities != null && data.totalOpportunities > 0) {
                data.winRate = (Decimal.valueOf(data.wonOpportunities) / Decimal.valueOf(data.totalOpportunities)) * 100;
                data.winRate = data.winRate.setScale(1);
            } else {
                data.winRate = 0;
            }
            
            // Get account count
            data.totalAccounts = [SELECT COUNT() FROM Account];
            
            // Get contact count
            data.totalContacts = [SELECT COUNT() FROM Contact];
            
            // Get pipeline data by stage
            data.pipelineData = getPipelineByStage();
            
            // Get recent activities
            data.recentActivities = getRecentActivities();
            
            return data;
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching KPI data: ' + e.getMessage());
        }
    }
    
    /**
     * Gets pipeline data grouped by stage
     */
    private static List<PipelineStage> getPipelineByStage() {
        List<PipelineStage> pipeline = new List<PipelineStage>();
        
        AggregateResult[] results = [
            SELECT 
                StageName stage,
                COUNT(Id) stageCount,
                SUM(Amount) stageValue
            FROM Opportunity
            WHERE IsClosed = false AND Amount != null
            GROUP BY StageName
            ORDER BY SUM(Amount) DESC
        ];
        
        for (AggregateResult ar : results) {
            pipeline.add(new PipelineStage(
                (String)ar.get('stage'),
                (Integer)ar.get('stageCount'),
                (Decimal)ar.get('stageValue')
            ));
        }
        
        return pipeline;
    }
    
    /**
     * Gets recent opportunity activities
     */
    private static List<RecentActivity> getRecentActivities() {
        List<RecentActivity> activities = new List<RecentActivity>();
        
        List<Opportunity> recentOpps = [
            SELECT Id, Name, Type, StageName, Amount, LastModifiedDate
            FROM Opportunity
            ORDER BY LastModifiedDate DESC
            LIMIT 5
        ];
        
        for (Opportunity opp : recentOpps) {
            activities.add(new RecentActivity(
                opp.Id,
                opp.Name,
                opp.Type != null ? opp.Type : 'Opportunity',
                opp.StageName,
                opp.Amount,
                opp.LastModifiedDate
            ));
        }
        
        return activities;
    }
    
    /**
     * Quick action to create a sample opportunity
     */
    @AuraEnabled
    public static String createSampleOpportunity(String accountId) {
        try {
            Account acc;
            if (String.isNotBlank(accountId)) {
                acc = [SELECT Id, Name FROM Account WHERE Id = :accountId LIMIT 1];
            } else {
                // Get or create a default account
                List<Account> accounts = [SELECT Id, Name FROM Account LIMIT 1];
                if (accounts.isEmpty()) {
                    acc = new Account(Name = 'Sample Account');
                    insert acc;
                } else {
                    acc = accounts[0];
                }
            }
            
            Opportunity opp = new Opportunity(
                Name = 'Quick Opportunity - ' + acc.Name,
                AccountId = acc.Id,
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30),
                Amount = 75000,
                Probability = 10
            );
            insert opp;
            
            return opp.Id;
        } catch (Exception e) {
            throw new AuraHandledException('Error creating sample opportunity: ' + e.getMessage());
        }
    }
}

