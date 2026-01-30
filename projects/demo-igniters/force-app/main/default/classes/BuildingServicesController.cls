public with sharing class BuildingServicesController {
    public Building_Service__c buildingservice { get; set; }
    public BuildingServicesController() {
        List<Building_Service__c> results = [SELECT Id, Name, Controls__c, Energy_Management__c, Engineering_Phasing_Out__c, Engineering_Analysis__c, Engineering_Projects__c, Lighting__c, LL84_Current_Year__c, LL87__c, LL97_Filing__c, MPP__c, RCM_Repairs__c, Rebate_Facilitation__c FROM Building_Service__c LIMIT 1];
        if (!results.isEmpty()) {
            buildingservice = results[0];
        } else {
            buildingservice = new Building_Service__c();
        }
    }
} 