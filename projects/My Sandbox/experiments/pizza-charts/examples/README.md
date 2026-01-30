# Pizza Charts Examples

This directory contains example scripts demonstrating different use cases.

## Football Examples

### `football_example.py`
- Manual player profile creation
- Multiple player comparison
- fbref.com integration workflow (placeholder)

**Usage:**
```bash
python football_example.py
```

## Business Examples

### `business_example.py`
- Product performance analysis
- Employee performance reviews
- Team/department comparison

**Usage:**
```bash
python business_example.py
```

## Key Takeaways

1. **Flexible Data Structure**: The same `EntityProfile` model works for any context
2. **Percentile System**: All metrics use 0-99 scale for easy comparison
3. **Category Grouping**: Metrics are organized by logical categories
4. **Reusable Visualization**: Same visualizer works across all contexts

## Extending to Your Use Case

1. Define your metrics and categories
2. Calculate percentiles (0-99) against your reference group
3. Create `EntityProfile` objects
4. Use `PizzaChartVisualizer` to generate charts
