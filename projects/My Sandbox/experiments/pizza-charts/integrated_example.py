"""
Integrated example: Scrape FBref data and visualize with PyPizza.

This script demonstrates the complete workflow:
1. Scrape scouting report from FBref
2. Process and clean the data
3. Visualize with mplsoccer's PyPizza
"""

import sys
import os

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from scrape_scout_report import scrape_scout_report
from visualize_scout_report import visualize_scout_report, visualize_scout_report_with_categories


def create_pizza_from_fbref(
    player_url: str,
    player_name: str = None,
    style: str = "athletic_dark",
    save_path: str = None,
    show: bool = True
):
    """
    Complete workflow: scrape FBref and create pizza chart.
    
    Args:
        player_url: FBref player URL
        player_name: Optional player name (extracted from URL if not provided)
        style: Chart style ('athletic_dark' or 'athletic_light')
        save_path: Optional path to save chart
        show: Whether to display chart
    """
    print(f"Scraping data from: {player_url}")
    
    # Scrape the data
    try:
        data = scrape_scout_report(player_url)
        print(f"✓ Successfully scraped {len(data)} statistics")
    except Exception as e:
        print(f"Error scraping data: {e}")
        return None
    
    # Extract player name from URL if not provided
    if not player_name:
        player_name = player_url.split('/')[-1].replace('-', ' ').title()
    
    # Create visualization
    print(f"Creating pizza chart for {player_name}...")
    
    try:
        fig, ax = visualize_scout_report(
            data,
            player_name=player_name,
            style=style,
            save_path=save_path,
            show=show
        )
        print("✓ Chart created successfully!")
        return fig, ax
    except Exception as e:
        print(f"Error creating chart: {e}")
        return None


if __name__ == "__main__":
    # Example usage
    player_url = "https://fbref.com/en/players/1f44ac21/Erling-Haaland"
    
    # Create chart
    create_pizza_from_fbref(
        player_url,
        player_name="Erling Haaland",
        style="athletic_dark",
        save_path="data/haaland_pizza.png",
        show=False
    )
