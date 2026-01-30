# Salesforce Apex Standards

## Naming Conventions

### Classes
- Use PascalCase: `AccountTriggerHandler`, `LeadService`
- Suffix by purpose: `*Handler`, `*Service`, `*Controller`, `*Test`

### Methods
- Use camelCase: `calculateTotalRevenue()`, `sendEmail()`
- Start with verb: `get*`, `set*`, `calculate*`, `process*`

### Variables
- Use camelCase: `accountList`, `totalRevenue`, `isActive`
- Be descriptive, avoid abbreviations

## Code Structure

### Triggers
- One trigger per object
- Delegate to handler classes
- Use trigger context variables appropriately

```apex
trigger AccountTrigger on Account (before insert, before update) {
    AccountTriggerHandler.handle(Trigger.new, Trigger.oldMap);
}
```

### Bulkification
- Always assume bulk operations
- Use collections (List, Set, Map)
- Avoid SOQL/DML in loops

```apex
// ❌ Bad
for (Account acc : accounts) {
    Contact con = [SELECT Id FROM Contact WHERE AccountId = :acc.Id];
}

// ✅ Good
Set<Id> accountIds = new Set<Id>();
for (Account acc : accounts) {
    accountIds.add(acc.Id);
}
List<Contact> contacts = [SELECT Id, AccountId FROM Contact WHERE AccountId IN :accountIds];
```

### Error Handling
- Use try-catch for DML operations
- Log errors appropriately
- Provide meaningful error messages

## Testing Standards

### Coverage
- Minimum 75% code coverage
- Aim for 100% on business logic

### Test Class Naming
- Suffix with `Test`: `AccountTriggerHandlerTest`
- Match class being tested

### Test Structure
```apex
@isTest
private class AccountTriggerHandlerTest {
    @testSetup
    static void setup() {
        // Create test data
    }
    
    @isTest
    static void testPositiveScenario() {
        // Arrange
        // Act
        // Assert
    }
    
    @isTest
    static void testNegativeScenario() {
        // Arrange
        // Act
        // Assert
    }
}
```

### Test Data
- Use `@testSetup` for shared data
- Create realistic test data
- Test bulk operations (200+ records)

## Security

### CRUD/FLS
- Use `WITH SECURITY_ENFORCED` in SOQL
- Check permissions before DML
- Follow Security Review guidelines

### Sharing
- Use `with sharing` by default
- Document `without sharing` usage
- Respect sharing rules

---

**AI Instructions:** When writing Apex code, follow these standards strictly.
