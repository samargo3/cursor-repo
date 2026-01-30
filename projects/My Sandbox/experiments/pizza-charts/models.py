"""
Data models for pizza chart visualization system.

This module defines flexible data structures that can be used for
sports analytics, business metrics, or any percentile-based comparison.
"""

from dataclasses import dataclass, field
from typing import Dict, List, Optional, Any
from enum import Enum


class MetricCategory(str, Enum):
    """Categories for grouping related metrics."""
    DEFENCE = "defence"
    POSSESSION = "possession"
    PROGRESSION = "progression"
    ATTACK = "attack"
    # Add more categories as needed
    PERFORMANCE = "performance"
    EFFICIENCY = "efficiency"
    QUALITY = "quality"


@dataclass
class Metric:
    """
    Represents a single metric with its percentile score.
    
    Attributes:
        name: Human-readable name of the metric
        value: Percentile score (0-99)
        description: Optional description of what the metric measures
        raw_value: Optional raw value before percentile conversion
        unit: Optional unit of measurement (e.g., "per 90", "percentage")
    """
    name: str
    value: float  # 0-99 percentile
    description: Optional[str] = None
    raw_value: Optional[float] = None
    unit: Optional[str] = None
    
    def __post_init__(self):
        """Validate percentile value."""
        if not 0 <= self.value <= 99:
            raise ValueError(f"Percentile value must be between 0 and 99, got {self.value}")


@dataclass
class CategoryMetrics:
    """
    Groups metrics by category.
    
    Attributes:
        category: The category name
        metrics: Dictionary of metric name -> Metric object
    """
    category: MetricCategory
    metrics: Dict[str, Metric] = field(default_factory=dict)
    
    def add_metric(self, metric: Metric):
        """Add a metric to this category."""
        self.metrics[metric.name] = metric
    
    def get_metric(self, name: str) -> Optional[Metric]:
        """Get a metric by name."""
        return self.metrics.get(name)
    
    def get_all_values(self) -> Dict[str, float]:
        """Get all metric names and their percentile values."""
        return {name: metric.value for name, metric in self.metrics.items()}


@dataclass
class EntityProfile:
    """
    Complete profile of an entity (player, product, team, etc.) with all metrics.
    
    Attributes:
        entity_id: Unique identifier
        entity_name: Display name
        context: Optional context (e.g., position, department, product line)
        categories: Dictionary of category -> CategoryMetrics
        metadata: Additional metadata (e.g., team, season, date)
    """
    entity_id: str
    entity_name: str
    context: Optional[str] = None  # e.g., "Center Back", "Q4 2024", "Product Line A"
    categories: Dict[MetricCategory, CategoryMetrics] = field(default_factory=dict)
    metadata: Dict[str, Any] = field(default_factory=dict)
    
    def add_category(self, category_metrics: CategoryMetrics):
        """Add a category of metrics to this profile."""
        self.categories[category_metrics.category] = category_metrics
    
    def get_category(self, category: MetricCategory) -> Optional[CategoryMetrics]:
        """Get metrics for a specific category."""
        return self.categories.get(category)
    
    def get_all_metrics(self) -> Dict[str, Metric]:
        """Get all metrics flattened across all categories."""
        all_metrics = {}
        for category_metrics in self.categories.values():
            all_metrics.update(category_metrics.metrics)
        return all_metrics
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert profile to dictionary for serialization."""
        return {
            "entity_id": self.entity_id,
            "entity_name": self.entity_name,
            "context": self.context,
            "categories": {
                cat.value: {
                    "metrics": {
                        name: {
                            "value": metric.value,
                            "description": metric.description,
                            "raw_value": metric.raw_value,
                            "unit": metric.unit
                        }
                        for name, metric in cat_metrics.metrics.items()
                    }
                }
                for cat, cat_metrics in self.categories.items()
            },
            "metadata": self.metadata
        }
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> "EntityProfile":
        """Create profile from dictionary."""
        profile = cls(
            entity_id=data["entity_id"],
            entity_name=data["entity_name"],
            context=data.get("context"),
            metadata=data.get("metadata", {})
        )
        
        for cat_name, cat_data in data.get("categories", {}).items():
            category = MetricCategory(cat_name)
            category_metrics = CategoryMetrics(category=category)
            
            for metric_name, metric_data in cat_data.get("metrics", {}).items():
                metric = Metric(
                    name=metric_name,
                    value=metric_data["value"],
                    description=metric_data.get("description"),
                    raw_value=metric_data.get("raw_value"),
                    unit=metric_data.get("unit")
                )
                category_metrics.add_metric(metric)
            
            profile.add_category(category_metrics)
        
        return profile


# Example: Football-specific metric definitions
FOOTBALL_METRICS = {
    MetricCategory.DEFENCE: {
        "Front-foot defending": "Tackles, challenges, fouls, interceptions, blocked passes per 90 (possession adjusted)",
        "Tackle success": "Percentage of tackles won vs attempted",
        "Back-foot defending": "Blocked shots and clearances per 90 (possession adjusted)",
        "Loose ball recoveries": "Ball recoveries when neither side has possession per 90",
        "Aerial volume": "Aerial duels contested per 90",
        "Aerial success": "Percentage of aerial duels won",
    },
    MetricCategory.POSSESSION: {
        "Link-up play": "Percentage of short/medium passes vs total passes",
        "Ball retention": "Pass completion percentage",
        "Launched passes": "Percentage of long passes vs total passes",
    },
    MetricCategory.PROGRESSION: {
        "Creative threat": "Expected assists + actual assists per 90 (80/20 weighting)",
        "Cross volume": "Crosses per 100 touches in attacking third",
        "Dribble volume": "Dribbles per 100 touches",
        "Pass progression": "Progressive passes as share of total passes",
        "Carry progression": "Progressive carries as share of total carries",
        "Progressive receptions": "Progressive passes received as share of total passes received",
    },
    MetricCategory.ATTACK: {
        "Goal threat": "Expected goals + actual goals per 90 (70/30 weighting)",
        "Shot frequency": "Non-penalty shots per 100 touches",
        "Box threat": "Touches in penalty area as share of attacking third touches",
        "Shot quality": "Average xG per shot",
    }
}


def create_football_profile(
    entity_id: str,
    entity_name: str,
    position: str,
    metrics_data: Dict[str, Dict[str, float]],
    metadata: Optional[Dict[str, Any]] = None
) -> EntityProfile:
    """
    Helper function to create a football player profile.
    
    Args:
        entity_id: Player ID
        entity_name: Player name
        position: Player position
        metrics_data: Dict of category -> metric_name -> percentile_value
        metadata: Additional metadata
    
    Returns:
        EntityProfile object
    """
    profile = EntityProfile(
        entity_id=entity_id,
        entity_name=entity_name,
        context=position,
        metadata=metadata or {}
    )
    
    for category, metrics_dict in metrics_data.items():
        try:
            category_enum = MetricCategory(category.lower())
        except ValueError:
            continue
        
        category_metrics = CategoryMetrics(category=category_enum)
        
        for metric_name, percentile_value in metrics_dict.items():
            description = FOOTBALL_METRICS.get(category_enum, {}).get(metric_name)
            metric = Metric(
                name=metric_name,
                value=percentile_value,
                description=description
            )
            category_metrics.add_metric(metric)
        
        profile.add_category(category_metrics)
    
    return profile
