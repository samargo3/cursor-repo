# Pizza Charts Visualization System

A flexible system for creating pizza/radar charts from percentile-based metrics, inspired by [The Athletic's player analysis charts](https://www.nytimes.com/athletic/6457393/2025/08/07/player-pizza-charts-version-two-2025/).

## Overview

This project demonstrates how to:
1. Structure percentile-based metric data (0-99 scale)
2. Scrape and process data from [fbref.com](https://fbref.com/en/)
3. Generate pizza/radar charts for any context (sports, business, etc.)

## Key Concepts

### Data Structure
- **Metrics**: Individual measurements with percentile scores (0-99)
- **Categories**: Groupings of related metrics (e.g., Defence, Possession, Progression, Attack)
- **Profiles**: Complete sets of metrics for an entity (player, product, team, etc.)
- **Position/Context**: Optional grouping for context-specific metrics

### Percentile System
- Each metric is scored 0-99 compared to peers
- Higher = more frequent/efficient performance
- Allows easy comparison across different scales
- Works for any domain: sports, business, performance reviews, etc.

## Project Structure

```
pizza-charts/
├── models.py              # Data models and structures
├── scraper.py             # fbref.com data extraction
├── visualizer.py          # Chart generation
├── examples/              # Example scripts
│   ├── football_example.py
│   ├── business_example.py
│   └── README.md
├── data/                  # Stored data files and charts
├── requirements.txt       # Python dependencies
├── README.md             # This file
└── DATA_STRUCTURE_GUIDE.md # Detailed guide on data structure
```

## Quick Start

### Installation

```bash
pip install -r requirements.txt
```

### Basic Usage

```python
from models import EntityProfile, CategoryMetrics, Metric, MetricCategory
from visualizer import PizzaChartVisualizer

# Create a profile
profile = EntityProfile(
    entity_id="player-001",
    entity_name="Player Name",
    context="Center Back"
)

# Add metrics
defence = CategoryMetrics(category=MetricCategory.DEFENCE)
defence.add_metric(Metric("Aerial volume", 79, "Aerial duels per 90"))
defence.add_metric(Metric("Aerial success", 94, "% of aerial duels won"))
profile.add_category(defence)

# Visualize
viz = PizzaChartVisualizer()
viz.create_radar_chart(profile)
```

## Documentation

- **`DATA_STRUCTURE_GUIDE.md`**: Comprehensive guide on structuring data for pizza charts
- **`examples/README.md`**: Examples and use cases
- **`examples/football_example.py`**: Football/soccer examples
- **`examples/business_example.py`**: Business metric examples

## Key Features

✅ **Flexible Data Model**: Works for any domain (sports, business, performance, etc.)  
✅ **Percentile-Based**: Normalizes different scales for fair comparison  
✅ **Category Organization**: Group related metrics logically  
✅ **Multiple Visualizations**: Full profiles, category-specific, comparisons  
✅ **fbref.com Integration**: Scraper framework for football data (needs implementation)  
✅ **Extensible**: Easy to add new categories and metrics

## Use Cases

- **Sports Analytics**: Player performance analysis, team comparisons
- **Business Metrics**: Product performance, employee reviews, team analysis
- **Performance Reviews**: Individual or team assessments
- **Product Analysis**: Feature adoption, user engagement, quality metrics
- **Any Comparative Analysis**: Where you need to compare entities across multiple dimensions

## Next Steps

1. Read `DATA_STRUCTURE_GUIDE.md` to understand the data structure
2. Check `examples/` for working code samples
3. Adapt the models to your specific use case
4. Calculate percentiles for your metrics
5. Generate visualizations!

## Notes

- The fbref.com scraper is a framework - full implementation requires handling fbref's specific HTML structure
- Percentile calculations require reference data (peer groups)
- Always respect website terms of service and rate limits when scraping
