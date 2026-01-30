"""
Example: Creating pizza charts for football players.

This demonstrates how to use the system with football data,
either from fbref.com scraping or manual data entry.
"""

from pathlib import Path
import sys

# Ensure the project root (where models.py lives) is on sys.path
PROJECT_ROOT = Path(__file__).resolve().parents[1]
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from models import EntityProfile, CategoryMetrics, Metric, MetricCategory, create_football_profile
from visualizer import PizzaChartVisualizer


def example_manual_player_profile():
    """
    Example: Create a player profile manually with percentile data.
    
    In a real scenario, you'd scrape this from fbref.com and calculate
    percentiles against position peers.
    """
    # Example: Virgil van Dijk (from The Athletic article)
    vvd_profile = create_football_profile(
        entity_id="vvd-001",
        entity_name="Virgil van Dijk",
        position="Center Back",
        metrics_data={
            "defence": {
                "Front-foot defending": 45,
                "Tackle success": 31,
                "Back-foot defending": 91,
                "Loose ball recoveries": 68,
                "Aerial volume": 79,
                "Aerial success": 94,
            },
            "possession": {
                "Link-up play": 65,
                "Ball retention": 88,
                "Launched passes": 42,
            },
            "progression": {
                "Creative threat": 25,
                "Cross volume": 15,
                "Dribble volume": 12,
                "Pass progression": 55,
                "Carry progression": 38,
                "Progressive receptions": 45,
            },
            "attack": {
                "Goal threat": 35,
                "Shot frequency": 8,
                "Box threat": 12,
                "Shot quality": 45,
            }
        },
        metadata={
            "team": "Liverpool",
            "season": "2024-2025",
            "league": "Premier League"
        }
    )
    
    # Visualize
    viz = PizzaChartVisualizer()
    
    # Full profile chart
    viz.create_radar_chart(
        vvd_profile,
        save_path="../../data/vvd_full_profile.png",
        show=False
    )
    
    # Category-specific charts
    viz.create_category_charts(
        vvd_profile,
        save_dir="../../data/vvd_categories",
        show=False
    )
    
    print("✓ Created Virgil van Dijk profile charts")
    return vvd_profile


def example_multiple_players_comparison():
    """
    Example: Compare multiple players.
    """
    # Create profiles for comparison
    profiles = []
    
    # Player 1: Center Back
    cb_profile = create_football_profile(
        entity_id="cb-001",
        entity_name="Player A",
        position="Center Back",
        metrics_data={
            "defence": {
                "Front-foot defending": 60,
                "Tackle success": 70,
                "Back-foot defending": 85,
                "Aerial volume": 75,
                "Aerial success": 80,
            }
        }
    )
    profiles.append(cb_profile)
    
    # Player 2: Attacking Midfielder
    am_profile = create_football_profile(
        entity_id="am-001",
        entity_name="Player B",
        position="Attacking Midfielder",
        metrics_data={
            "progression": {
                "Creative threat": 90,
                "Dribble volume": 85,
                "Pass progression": 70,
            },
            "attack": {
                "Goal threat": 88,
                "Shot frequency": 75,
                "Box threat": 82,
            }
        }
    )
    profiles.append(am_profile)
    
    # Create comparison chart
    viz = PizzaChartVisualizer()
    viz.create_comparison_chart(
        profiles,
        save_path="../../data/player_comparison.png",
        show=False
    )
    
    print("✓ Created player comparison chart")
    return profiles


def example_fbref_integration():
    """
    Example: Using the fbref scraper (commented out - requires actual implementation).
    
    This shows the intended workflow once the scraper is fully implemented.
    """
    # from scraper import scrape_player_for_pizza_chart
    # 
    # # Scrape player data
    # player_data = scrape_player_for_pizza_chart(
    #     player_name="Virgil van Dijk",
    #     season="2024-2025",
    #     reference_data_path="../../data/player_reference_data.csv"
    # )
    # 
    # # Convert to EntityProfile
    # profile = create_football_profile(
    #     entity_id=player_data['player_info']['url'],
    #     entity_name=player_data['player_info']['name'],
    #     position="Center Back",
    #     metrics_data=player_data['metrics']
    # )
    # 
    # # Visualize
    # viz = PizzaChartVisualizer()
    # viz.create_radar_chart(profile)
    
    print("ℹ️  fbref integration example (requires full scraper implementation)")


if __name__ == "__main__":
    print("Creating football player pizza charts...\n")
    
    # Example 1: Manual profile
    vvd = example_manual_player_profile()
    
    # Example 2: Comparison
    players = example_multiple_players_comparison()
    
    # Example 3: fbref integration (placeholder)
    example_fbref_integration()
    
    print("\n✓ All examples completed!")
