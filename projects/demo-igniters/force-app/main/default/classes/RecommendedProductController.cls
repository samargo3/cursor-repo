public with sharing class RecommendedProductController {
    public class RecommendedProductDTO {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
        @AuraEnabled public String family;
        @AuraEnabled public String productCode;
        @AuraEnabled public Decimal unitPrice;
        @AuraEnabled public String currencyIsoCode;
    }

    @AuraEnabled(cacheable=true)
    public static RecommendedProductDTO getRecommendedProduct(Id accountId) {
        // Only consider products whose Name starts with 'DLC'
        String dlcPrefix = 'DLC%';
        List<Product2> candidates = [
            SELECT Id, Name, Family, ProductCode, CreatedDate,
                (SELECT Id, UnitPrice, CurrencyIsoCode, IsActive FROM PricebookEntries
                 WHERE Pricebook2.IsStandard = true AND IsActive = true
                 ORDER BY CreatedDate DESC LIMIT 1)
            FROM Product2
            WHERE IsActive = true AND Name LIKE :dlcPrefix
            ORDER BY CreatedDate DESC
            LIMIT 10
        ];

        if (candidates.isEmpty()) {
            return null;
        }

        Integer pickIndex = 0;
        if (candidates.size() > 1) {
            // Use Math.random for a simple pseudo-random selection among recent products
            pickIndex = Integer.valueOf(Math.floor(Math.random() * candidates.size()));
        }

        Product2 selected = candidates[pickIndex];
        Decimal price = null;
        String currencyCode = null;
        if (selected.PricebookEntries != null && !selected.PricebookEntries.isEmpty()) {
            PricebookEntry pbe = selected.PricebookEntries[0];
            price = pbe.UnitPrice;
            currencyCode = pbe.CurrencyIsoCode;
        }

        RecommendedProductDTO dto = new RecommendedProductDTO();
        dto.id = selected.Id;
        dto.name = selected.Name;
        dto.family = selected.Family;
        dto.productCode = selected.ProductCode;
        dto.unitPrice = price;
        dto.currencyIsoCode = currencyCode;
        return dto;
    }
}


