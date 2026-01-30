# Data Structure Guide for Pizza Charts

This guide explains how to structure data for pizza/radar chart visualizations, applicable to any domain (sports, business, etc.).

## Core Principles

### 1. Percentile-Based System (0-99 Scale)

**Why percentiles?**
- Normalizes different scales (goals vs. passes vs. percentages)
- Enables fair comparison across different metrics
- Easy to interpret: higher = better relative to peers

**How to calculate:**
```
percentile = (number of peers below this value / total peers) × 100
```

**Example:**
- Player A: 15 goals in a season
- Reference group: 100 players, 80 scored fewer than 15
- Percentile: (80/100) × 100 = 80

### 2. Category Organization

Group related metrics into logical categories:

**Sports Example:**
- Defence: defensive actions, tackles, clearances
- Possession: passing, ball retention
- Progression: creative passes, dribbles, carries
- Attack: goals, shots, xG

**Business Example:**
- Performance: revenue, growth, market share
- Efficiency: cost per acquisition, conversion rate
- Quality: uptime, bug rate, customer satisfaction

### 3. Context-Specific Metrics

Different contexts (positions, departments, product lines) may need different metrics:

- **Center Back**: Focus on aerial duels, clearances, defensive actions
- **Attacking Midfielder**: Focus on creative threat, progressive passes, goal threat
- **Product Manager**: Focus on user growth, feature adoption, revenue
- **Engineer**: Focus on code quality, velocity, bug rate

## Data Structure Design

### EntityProfile Structure

```python
EntityProfile(
    entity_id: str,           # Unique identifier
    entity_name: str,        # Display name
    context: str,            # Position, department, etc.
    categories: {            # Dictionary of categories
        Category: {
            metric_name: {
                value: float,        # 0-99 percentile
                description: str,    # What it measures
                raw_value: float,    # Original value (optional)
                unit: str           # Unit of measurement (optional)
            }
        }
    },
    metadata: {}             # Additional info (team, season, etc.)
)
```

### Example: Football Player

```python
{
    "entity_id": "vvd-001",
    "entity_name": "Virgil van Dijk",
    "context": "Center Back",
    "categories": {
        "defence": {
            "Aerial volume": {"value": 79, "description": "Aerial duels per 90"},
            "Aerial success": {"value": 94, "description": "% of aerial duels won"},
            "Back-foot defending": {"value": 91, "description": "Clearances per 90"}
        },
        "possession": {
            "Ball retention": {"value": 88, "description": "Pass completion %"}
        }
    },
    "metadata": {
        "team": "Liverpool",
        "season": "2024-2025"
    }
}
```

### Example: Business Product

```python
{
    "entity_id": "product-001",
    "entity_name": "Product A",
    "context": "Q4 2024",
    "categories": {
        "performance": {
            "Revenue Growth": {"value": 85, "description": "YoY growth vs industry"},
            "Market Share": {"value": 72, "description": "Market share percentile"}
        },
        "efficiency": {
            "Cost per Acquisition": {"value": 65, "description": "Lower is better (inverted)"},
            "Conversion Rate": {"value": 78, "description": "Visitor to customer %"}
        }
    },
    "metadata": {
        "department": "Product",
        "quarter": "Q4 2024"
    }
}
```

## Building Your Data Pipeline

### Step 1: Define Your Metrics

List all metrics you want to track, grouped by category:

```python
METRICS = {
    "category_1": {
        "metric_a": "Description of what it measures",
        "metric_b": "Description..."
    },
    "category_2": {
        "metric_c": "Description..."
    }
}
```

### Step 2: Collect Raw Data

Gather raw values for each metric:
- From databases
- From APIs
- From web scraping
- From manual entry

### Step 3: Calculate Percentiles

For each metric, calculate percentiles against a reference group:

```python
def calculate_percentile(value, reference_values):
    """Calculate percentile (0-99) for a value."""
    below = sum(1 for v in reference_values if v < value)
    return (below / len(reference_values)) * 100
```

**Important considerations:**
- **Reference group**: Should be peers (same position, same industry, same role)
- **Sample size**: Larger is better (minimum 20-30 for meaningful percentiles)
- **Time period**: Compare similar time periods (same season, same quarter)

### Step 4: Handle Inverted Metrics

Some metrics are "lower is better" (e.g., bug rate, cost per acquisition):

```python
# Option 1: Invert the percentile
percentile = 100 - original_percentile

# Option 2: Invert the raw value before calculating
inverted_value = max(reference_values) - value
percentile = calculate_percentile(inverted_value, inverted_reference)
```

### Step 5: Structure the Data

Create `EntityProfile` objects with your calculated percentiles:

```python
from models import EntityProfile, CategoryMetrics, Metric, MetricCategory

profile = EntityProfile(
    entity_id="your-id",
    entity_name="Your Entity",
    context="Your Context"
)

category = CategoryMetrics(category=MetricCategory.YOUR_CATEGORY)
category.add_metric(Metric(
    name="Your Metric",
    value=calculated_percentile,
    description="What it measures",
    raw_value=original_value,
    unit="per 90"  # or whatever unit
))

profile.add_category(category)
```

## Best Practices

### 1. Consistent Reference Groups
- Always compare against the same peer group
- Update reference data regularly
- Document your reference group (size, criteria, time period)

### 2. Meaningful Categories
- Group related metrics together
- 3-6 metrics per category works well
- Too many categories can clutter the visualization

### 3. Clear Descriptions
- Each metric should have a clear description
- Explain what "higher" means (is 99 always better?)
- Note if a metric is inverted

### 4. Handle Missing Data
- Decide on a strategy: exclude, impute, or mark as N/A
- Document missing data in metadata
- Consider showing confidence intervals

### 5. Validation
- Ensure all percentiles are 0-99
- Check for outliers (investigate if needed)
- Verify calculations with known examples

## Common Patterns

### Pattern 1: Position-Specific Metrics

```python
# Different metrics for different positions
if position == "Center Back":
    metrics = ["Aerial volume", "Aerial success", "Clearances"]
elif position == "Attacking Midfielder":
    metrics = ["Creative threat", "Progressive passes", "Goal threat"]
```

### Pattern 2: Weighted Combinations

```python
# Combine multiple raw metrics into one percentile
creative_threat = 0.8 * xA_percentile + 0.2 * assists_percentile
```

### Pattern 3: Time-Based Comparisons

```python
# Compare current period vs. previous period
current_percentile = calculate_percentile(current_value, current_reference)
previous_percentile = calculate_percentile(previous_value, previous_reference)
improvement = current_percentile - previous_percentile
```

## Extending to New Domains

1. **Identify your entities**: What are you comparing? (players, products, teams, etc.)
2. **Define your metrics**: What do you want to measure?
3. **Establish reference groups**: Who are the peers?
4. **Calculate percentiles**: Convert raw values to 0-99 scale
5. **Organize by categories**: Group related metrics
6. **Visualize**: Use the same `PizzaChartVisualizer`

The beauty of this system is that once you have percentile data structured correctly, the visualization works the same way regardless of domain!
