# Quick Reference Guide

## Core Data Flow

```
Raw Data → Calculate Percentiles → Create EntityProfile → Visualize
```

## Essential Code Patterns

### 1. Create a Profile

```python
from models import EntityProfile, CategoryMetrics, Metric, MetricCategory

profile = EntityProfile(
    entity_id="unique-id",
    entity_name="Display Name",
    context="Position/Department/Context"
)
```

### 2. Add Metrics to a Category

```python
category = CategoryMetrics(category=MetricCategory.DEFENCE)
category.add_metric(Metric("Metric Name", 75, "Description"))
profile.add_category(category)
```

### 3. Visualize

```python
from visualizer import PizzaChartVisualizer

viz = PizzaChartVisualizer()
viz.create_radar_chart(profile)
```

### 4. Compare Multiple Entities

```python
profiles = [profile1, profile2, profile3]
viz.create_comparison_chart(profiles)
```

## Percentile Calculation

```python
def calculate_percentile(value, reference_values):
    """Calculate 0-99 percentile."""
    below = sum(1 for v in reference_values if v < value)
    return min(99, max(0, (below / len(reference_values)) * 100))
```

## Common Categories

### Sports
- `DEFENCE`, `POSSESSION`, `PROGRESSION`, `ATTACK`

### Business
- `PERFORMANCE`, `EFFICIENCY`, `QUALITY`

### Custom
```python
class MetricCategory(str, Enum):
    YOUR_CATEGORY = "your_category"
```

## Metric Structure

```python
Metric(
    name="Metric Name",           # Required
    value=75,                     # Required: 0-99 percentile
    description="What it measures", # Optional
    raw_value=15.5,               # Optional: original value
    unit="per 90"                 # Optional: unit of measurement
)
```

## Visualization Options

```python
# Full profile
viz.create_radar_chart(profile)

# Specific categories only
viz.create_radar_chart(profile, categories=[MetricCategory.DEFENCE, MetricCategory.ATTACK])

# Save to file
viz.create_radar_chart(profile, save_path="output.png", show=False)

# Category-specific charts
viz.create_category_charts(profile, save_dir="output/")

# Comparison
viz.create_comparison_chart([profile1, profile2])
```

## Data Structure Checklist

- [ ] Define your metrics and categories
- [ ] Collect raw data for each metric
- [ ] Establish reference group (peers)
- [ ] Calculate percentiles (0-99) for each metric
- [ ] Handle inverted metrics (lower is better)
- [ ] Create EntityProfile objects
- [ ] Add metadata (team, season, etc.)
- [ ] Visualize!

## Common Issues

**Percentile out of range (0-99)**
- Check your calculation
- Ensure reference group is correct
- Handle edge cases (min/max values)

**Missing metrics**
- Use 0 as default, or exclude from visualization
- Document missing data in metadata

**Inverted metrics**
- Calculate: `100 - original_percentile`
- Or invert raw value before calculating percentile

## File Structure

```
pizza-charts/
├── models.py          # Data structures
├── scraper.py         # Web scraping (fbref)
├── visualizer.py       # Chart generation
├── examples/          # Working examples
└── data/             # Output files
```

## Next Steps

1. **Start Simple**: Create one profile manually
2. **Add Categories**: Expand to multiple categories
3. **Automate**: Build data pipeline for your use case
4. **Compare**: Create comparison charts
5. **Customize**: Adjust colors, styles, categories
