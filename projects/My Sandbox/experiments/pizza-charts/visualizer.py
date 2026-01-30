"""
Pizza/Radar chart visualization module.

Creates radar charts (pizza charts) from percentile-based metrics.
Works with any EntityProfile, not just sports data.
"""

import matplotlib.pyplot as plt
import numpy as np
from typing import Dict, List, Optional, Tuple
from models import EntityProfile, MetricCategory, CategoryMetrics


class PizzaChartVisualizer:
    """
    Creates pizza/radar charts from EntityProfile data.
    """
    
    def __init__(
        self,
        figsize: Tuple[int, int] = (10, 10),
        style: str = 'seaborn-v0_8',
        color_scheme: Optional[Dict[str, str]] = None
    ):
        """
        Initialize visualizer.
        
        Args:
            figsize: Figure size (width, height)
            style: Matplotlib style
            color_scheme: Optional dict of category -> color
        """
        self.figsize = figsize
        self.style = style
        self.color_scheme = color_scheme or {
            MetricCategory.DEFENCE: '#FF6B6B',
            MetricCategory.POSSESSION: '#4ECDC4',
            MetricCategory.PROGRESSION: '#45B7D1',
            MetricCategory.ATTACK: '#FFA07A',
            MetricCategory.PERFORMANCE: '#98D8C8',
            MetricCategory.EFFICIENCY: '#F7DC6F',
            MetricCategory.QUALITY: '#BB8FCE',
        }
        plt.style.use(style)
    
    def create_radar_chart(
        self,
        profile: EntityProfile,
        categories: Optional[List[MetricCategory]] = None,
        save_path: Optional[str] = None,
        show: bool = True,
        title: Optional[str] = None
    ) -> plt.Figure:
        """
        Create a radar chart for an entity profile.
        
        Args:
            profile: EntityProfile to visualize
            categories: Optional list of categories to include (default: all)
            save_path: Optional path to save the chart
            show: Whether to display the chart
            title: Optional custom title
            
        Returns:
            Matplotlib figure
        """
        if categories is None:
            categories = list(profile.categories.keys())
        
        # Collect all metrics
        all_metrics = []
        all_values = []
        category_colors = []
        
        for category in categories:
            cat_metrics = profile.get_category(category)
            if not cat_metrics:
                continue
            
            for metric_name, metric in cat_metrics.metrics.items():
                all_metrics.append(metric_name)
                all_values.append(metric.value)
                category_colors.append(self.color_scheme.get(category, '#808080'))
        
        if not all_metrics:
            raise ValueError("No metrics found for specified categories")
        
        # Set up the radar chart
        num_metrics = len(all_metrics)
        angles = np.linspace(0, 2 * np.pi, num_metrics, endpoint=False).tolist()
        
        # Complete the circle
        all_values += all_values[:1]
        angles += angles[:1]
        
        # Create figure
        fig, ax = plt.subplots(figsize=self.figsize, subplot_kw=dict(projection='polar'))
        
        # Plot the radar chart
        ax.plot(angles, all_values, 'o-', linewidth=2, color='#2C3E50')
        ax.fill(angles, all_values, alpha=0.25, color='#3498DB')
        
        # Add category-colored segments
        for i, (angle, value, color) in enumerate(zip(angles[:-1], all_values[:-1], category_colors)):
            next_angle = angles[i + 1] if i < len(angles) - 1 else angles[0]
            ax.fill_between(
                [angle, next_angle],
                [0, 0],
                [value, all_values[i + 1] if i < len(all_values) - 1 else all_values[0]],
                alpha=0.1,
                color=color
            )
        
        # Set labels
        ax.set_xticks(angles[:-1])
        ax.set_xticklabels(all_metrics, fontsize=9, wrap=True)
        
        # Set y-axis (percentile scale)
        ax.set_ylim(0, 99)
        ax.set_yticks([0, 25, 50, 75, 99])
        ax.set_yticklabels(['0', '25', '50', '75', '99'], fontsize=8)
        ax.grid(True, alpha=0.3)
        
        # Title
        chart_title = title or f"{profile.entity_name}"
        if profile.context:
            chart_title += f" ({profile.context})"
        ax.set_title(chart_title, size=14, fontweight='bold', pad=20)
        
        # Add percentile labels at each point
        for angle, value, metric_name in zip(angles[:-1], all_values[:-1], all_metrics):
            ax.text(
                angle, value + 5, f'{int(value)}',
                ha='center', va='center', fontsize=7, fontweight='bold'
            )
        
        plt.tight_layout()
        
        if save_path:
            plt.savefig(save_path, dpi=300, bbox_inches='tight')
            print(f"Chart saved to {save_path}")
        
        if show:
            plt.show()
        else:
            plt.close()
        
        return fig
    
    def create_category_charts(
        self,
        profile: EntityProfile,
        save_dir: Optional[str] = None,
        show: bool = True
    ) -> Dict[MetricCategory, plt.Figure]:
        """
        Create separate charts for each category.
        
        Args:
            profile: EntityProfile to visualize
            save_dir: Optional directory to save charts
            show: Whether to display charts
            
        Returns:
            Dictionary of category -> figure
        """
        figures = {}
        
        for category in profile.categories.keys():
            fig = self.create_radar_chart(
                profile,
                categories=[category],
                save_path=f"{save_dir}/{category.value}.png" if save_dir else None,
                show=show,
                title=f"{profile.entity_name} - {category.value.title()}"
            )
            figures[category] = fig
        
        return figures
    
    def create_comparison_chart(
        self,
        profiles: List[EntityProfile],
        categories: Optional[List[MetricCategory]] = None,
        save_path: Optional[str] = None,
        show: bool = True
    ) -> plt.Figure:
        """
        Create a comparison chart for multiple entities.
        
        Args:
            profiles: List of EntityProfiles to compare
            categories: Optional list of categories to include
            save_path: Optional path to save the chart
            show: Whether to display the chart
            
        Returns:
            Matplotlib figure
        """
        if not profiles:
            raise ValueError("At least one profile required")
        
        # Use first profile to determine metrics structure
        reference_profile = profiles[0]
        if categories is None:
            categories = list(reference_profile.categories.keys())
        
        # Collect all metrics (assuming same structure)
        all_metrics = []
        for category in categories:
            cat_metrics = reference_profile.get_category(category)
            if cat_metrics:
                all_metrics.extend(cat_metrics.metrics.keys())
        
        if not all_metrics:
            raise ValueError("No metrics found")
        
        # Set up radar chart
        num_metrics = len(all_metrics)
        angles = np.linspace(0, 2 * np.pi, num_metrics, endpoint=False).tolist()
        angles += angles[:1]
        
        # Create figure
        fig, ax = plt.subplots(figsize=self.figsize, subplot_kw=dict(projection='polar'))
        
        # Colors for different entities
        colors = plt.cm.Set3(np.linspace(0, 1, len(profiles)))
        
        # Plot each profile
        for i, profile in enumerate(profiles):
            values = []
            for metric_name in all_metrics:
                # Find metric across all categories
                found = False
                for category in categories:
                    cat_metrics = profile.get_category(category)
                    if cat_metrics and metric_name in cat_metrics.metrics:
                        values.append(cat_metrics.metrics[metric_name].value)
                        found = True
                        break
                if not found:
                    values.append(0)
            
            values += values[:1]
            
            ax.plot(angles, values, 'o-', linewidth=2, label=profile.entity_name, color=colors[i])
            ax.fill(angles, values, alpha=0.1, color=colors[i])
        
        # Set labels
        ax.set_xticks(angles[:-1])
        ax.set_xticklabels(all_metrics, fontsize=9, wrap=True)
        
        # Set y-axis
        ax.set_ylim(0, 99)
        ax.set_yticks([0, 25, 50, 75, 99])
        ax.set_yticklabels(['0', '25', '50', '75', '99'], fontsize=8)
        ax.grid(True, alpha=0.3)
        
        # Title and legend
        ax.set_title("Player Comparison", size=14, fontweight='bold', pad=20)
        ax.legend(loc='upper right', bbox_to_anchor=(1.3, 1.1))
        
        plt.tight_layout()
        
        if save_path:
            plt.savefig(save_path, dpi=300, bbox_inches='tight')
            print(f"Comparison chart saved to {save_path}")
        
        if show:
            plt.show()
        else:
            plt.close()
        
        return fig


def create_business_pizza_chart_example():
    """
    Example of how to use pizza charts for business metrics.
    
    This demonstrates the flexibility of the system.
    """
    from models import EntityProfile, CategoryMetrics, Metric, MetricCategory
    
    # Example: Product performance profile
    product_profile = EntityProfile(
        entity_id="product-001",
        entity_name="Product A",
        context="Q4 2024"
    )
    
    # Performance category
    performance = CategoryMetrics(category=MetricCategory.PERFORMANCE)
    performance.add_metric(Metric("Revenue Growth", 85, "Year-over-year revenue growth percentile"))
    performance.add_metric(Metric("Market Share", 72, "Market share percentile"))
    performance.add_metric(Metric("Customer Satisfaction", 91, "NPS percentile"))
    product_profile.add_category(performance)
    
    # Efficiency category
    efficiency = CategoryMetrics(category=MetricCategory.EFFICIENCY)
    efficiency.add_metric(Metric("Cost per Acquisition", 65, "Lower is better - inverted percentile"))
    efficiency.add_metric(Metric("Conversion Rate", 78, "Visitor to customer conversion"))
    efficiency.add_metric(Metric("Retention Rate", 88, "Customer retention percentile"))
    product_profile.add_category(efficiency)
    
    # Quality category
    quality = CategoryMetrics(category=MetricCategory.QUALITY)
    quality.add_metric(Metric("Bug Rate", 82, "Lower is better - inverted percentile"))
    quality.add_metric(Metric("Uptime", 95, "Service availability percentile"))
    quality.add_metric(Metric("Code Quality Score", 76, "Static analysis percentile"))
    product_profile.add_category(quality)
    
    # Visualize
    viz = PizzaChartVisualizer()
    viz.create_radar_chart(
        product_profile,
        title="Product A Performance Profile"
    )
    
    return product_profile
