"""
Example: Using pizza charts for business metrics.

This demonstrates how the same system can be used for non-sports contexts,
showing the flexibility of the data structure.
"""

from pathlib import Path
import sys

# Ensure the project root (where models.py lives) is on sys.path
PROJECT_ROOT = Path(__file__).resolve().parents[1]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from models import EntityProfile, CategoryMetrics, Metric, MetricCategory
from visualizer import PizzaChartVisualizer


def example_product_performance():
    """
    Example: Product performance analysis.
    """
    product = EntityProfile(
        entity_id="product-001",
        entity_name="Product A",
        context="Q4 2024"
    )
    
    # Performance metrics
    performance = CategoryMetrics(category=MetricCategory.PERFORMANCE)
    performance.add_metric(Metric("Revenue Growth", 85, "YoY revenue growth vs industry"))
    performance.add_metric(Metric("Market Share", 72, "Market share vs competitors"))
    performance.add_metric(Metric("Customer Satisfaction", 91, "NPS vs industry average"))
    performance.add_metric(Metric("User Growth", 78, "Monthly active users growth"))
    product.add_category(performance)
    
    # Efficiency metrics
    efficiency = CategoryMetrics(category=MetricCategory.EFFICIENCY)
    efficiency.add_metric(Metric("Cost Efficiency", 65, "Cost per acquisition (inverted)"))
    efficiency.add_metric(Metric("Conversion Rate", 78, "Visitor to customer conversion"))
    efficiency.add_metric(Metric("Retention Rate", 88, "Customer retention percentile"))
    efficiency.add_metric(Metric("Time to Value", 82, "Time for customer to see value (inverted)"))
    product.add_category(efficiency)
    
    # Quality metrics
    quality = CategoryMetrics(category=MetricCategory.QUALITY)
    quality.add_metric(Metric("Reliability", 95, "Uptime and error rate (inverted)"))
    quality.add_metric(Metric("Code Quality", 76, "Static analysis and test coverage"))
    quality.add_metric(Metric("Security Score", 88, "Security audit percentile"))
    quality.add_metric(Metric("Documentation", 70, "Documentation completeness"))
    product.add_category(quality)
    
    # Visualize
    viz = PizzaChartVisualizer()
    viz.create_radar_chart(
        product,
        save_path="../../data/product_performance.png",
        show=False,
        title="Product A - Performance Profile"
    )
    
    print("✓ Created product performance chart")
    return product


def example_employee_performance():
    """
    Example: Employee performance review.
    """
    employee = EntityProfile(
        entity_id="emp-001",
        entity_name="John Doe",
        context="Software Engineer"
    )
    
    # Technical skills
    technical = CategoryMetrics(category=MetricCategory.PERFORMANCE)
    technical.add_metric(Metric("Code Quality", 85, "Code review scores"))
    technical.add_metric(Metric("Problem Solving", 92, "Complex problem resolution"))
    technical.add_metric(Metric("Technical Knowledge", 88, "Domain expertise"))
    technical.add_metric(Metric("Innovation", 75, "New ideas and improvements"))
    employee.add_category(technical)
    
    # Collaboration
    collaboration = CategoryMetrics(category=MetricCategory.EFFICIENCY)
    collaboration.add_metric(Metric("Communication", 80, "Clear and effective communication"))
    collaboration.add_metric(Metric("Teamwork", 85, "Collaboration effectiveness"))
    collaboration.add_metric(Metric("Mentoring", 70, "Helping others grow"))
    collaboration.add_metric(Metric("Cross-functional", 78, "Working across teams"))
    employee.add_category(collaboration)
    
    # Delivery
    delivery = CategoryMetrics(category=MetricCategory.QUALITY)
    delivery.add_metric(Metric("On-time Delivery", 90, "Meeting deadlines"))
    delivery.add_metric(Metric("Quality", 88, "Bug rate and rework (inverted)"))
    delivery.add_metric(Metric("Velocity", 82, "Story points completed"))
    delivery.add_metric(Metric("Ownership", 95, "Taking responsibility"))
    employee.add_category(delivery)
    
    # Visualize
    viz = PizzaChartVisualizer()
    viz.create_radar_chart(
        employee,
        save_path="../../data/employee_performance.png",
        show=False,
        title="John Doe - Performance Review"
    )
    
    print("✓ Created employee performance chart")
    return employee


def example_team_comparison():
    """
    Example: Compare multiple teams/departments.
    """
    teams = []
    
    # Team A
    team_a = EntityProfile(
        entity_id="team-001",
        entity_name="Engineering Team A",
        context="Q4 2024"
    )
    perf_a = CategoryMetrics(category=MetricCategory.PERFORMANCE)
    perf_a.add_metric(Metric("Velocity", 85))
    perf_a.add_metric(Metric("Quality", 90))
    perf_a.add_metric(Metric("Innovation", 75))
    team_a.add_category(perf_a)
    teams.append(team_a)
    
    # Team B
    team_b = EntityProfile(
        entity_id="team-002",
        entity_name="Engineering Team B",
        context="Q4 2024"
    )
    perf_b = CategoryMetrics(category=MetricCategory.PERFORMANCE)
    perf_b.add_metric(Metric("Velocity", 70))
    perf_b.add_metric(Metric("Quality", 85))
    perf_b.add_metric(Metric("Innovation", 88))
    team_b.add_category(perf_b)
    teams.append(team_b)
    
    # Compare
    viz = PizzaChartVisualizer()
    viz.create_comparison_chart(
        teams,
        save_path="../../data/team_comparison.png",
        show=False
    )
    
    print("✓ Created team comparison chart")
    return teams


if __name__ == "__main__":
    print("Creating business metric pizza charts...\n")
    
    # Example 1: Product performance
    product = example_product_performance()
    
    # Example 2: Employee performance
    employee = example_employee_performance()
    
    # Example 3: Team comparison
    teams = example_team_comparison()
    
    print("\n✓ All business examples completed!")
