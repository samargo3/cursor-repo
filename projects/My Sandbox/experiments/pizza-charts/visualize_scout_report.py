"""
Visualize FBref Scouting Report data using mplsoccer's PyPizza.

This script creates pizza charts styled like The Athletic's player analysis charts.
"""

import matplotlib.pyplot as plt
from mplsoccer import PyPizza, FontManager
from typing import List, Dict, Optional
import numpy as np


def visualize_scout_report(
    data: List[Dict[str, str]],
    player_name: str = "Player",
    style: str = "athletic_dark",
    save_path: Optional[str] = None,
    show: bool = True
):
    """
    Create a pizza chart from scouting report data.
    
    Args:
        data: List of dictionaries with keys 'Statistic', 'Per 90', 'Percentile'
        player_name: Name of the player for the title
        style: Style theme ('athletic_dark' or 'athletic_light')
        save_path: Optional path to save the chart
        show: Whether to display the chart
    """
    # Extract data
    params = []
    values = []
    per90_values = []
    
    for record in data:
        stat = record.get('Statistic', '').strip()
        percentile_str = record.get('Percentile', '').strip()
        per90_str = record.get('Per 90', '').strip()
        
        if stat and percentile_str:
            try:
                percentile = int(float(percentile_str))
                params.append(stat)
                values.append(percentile)
                per90_values.append(per90_str if per90_str else '')
            except (ValueError, TypeError):
                continue
    
    if not params:
        raise ValueError("No valid data to visualize")
    
    # Define color groups (you can customize this based on your data)
    # Example: First 5 are Attacking, next 5 are Possession, etc.
    num_params = len(params)
    
    # Default grouping - you can customize this
    if num_params <= 5:
        slice_colors = ["#FF6B6B"] * num_params  # All one color if few params
    elif num_params <= 10:
        slice_colors = ["#FF6B6B"] * 5 + ["#4ECDC4"] * (num_params - 5)  # First 5, rest
    elif num_params <= 15:
        slice_colors = ["#FF6B6B"] * 5 + ["#4ECDC4"] * 5 + ["#45B7D1"] * (num_params - 10)
    else:
        # More sophisticated grouping
        slice_colors = (
            ["#FF6B6B"] * 5 +  # Attacking
            ["#4ECDC4"] * 5 +  # Possession
            ["#45B7D1"] * 5 +  # Progression
            ["#FFA07A"] * (num_params - 15)  # Defence/Other
        )
    
    # Set up the style
    if style == "athletic_dark":
        background_color = "#1a1a1a"
        text_color = "#ffffff"
        slice_colors = [c for c in slice_colors]  # Keep original colors
    else:  # athletic_light
        background_color = "#ffffff"
        text_color = "#000000"
        # Slightly adjust colors for light background
        slice_colors = [c for c in slice_colors]
    
    # Create the pizza chart
    baker = PyPizza(
        params=params,
        background_color=background_color,
        straight_line_color="#FFFFFF" if style == "athletic_dark" else "#000000",
        straight_line_lw=1,
        last_circle_lw=1,
        last_circle_color="#FFFFFF" if style == "athletic_dark" else "#000000",
        other_circle_lw=1,
        other_circle_color="#FFFFFF" if style == "athletic_dark" else "#000000",
        inner_circle_size=20
    )
    
    # Make the pizza
    fig, ax = baker.make_pizza(
        values,
        figsize=(12, 12),
        color_blank_space="same",  # Use same color for blank spaces
        slice_colors=slice_colors,
        value_colors=slice_colors,
        value_bck_colors=slice_colors,
        blank_alpha=0.4,
        kwargs_slices=dict(
            edgecolor="#FFFFFF" if style == "athletic_dark" else "#000000",
            zorder=2, linewidth=2
        ),
        kwargs_params=dict(
            color=text_color,
            fontsize=11,
            va="center"
        ),
        kwargs_values=dict(
            color=text_color,
            fontsize=11,
            zorder=3,
            bbox=dict(
                edgecolor="#FFFFFF" if style == "athletic_dark" else "#000000",
                facecolor=background_color,
                boxstyle="round,pad=0.3",
                linewidth=1.5
            )
        )
    )
    
    # Add per 90 values as text inside slices
    # Calculate positions for text
    num_params = len(params)
    angles = np.linspace(0, 2 * np.pi, num_params, endpoint=False)
    
    for i, (angle, per90_val, value) in enumerate(zip(angles, per90_values, values)):
        if not per90_val or per90_val == '':
            continue
        
        # Position text inside the slice (at about 60% of the radius)
        radius = 60
        x = radius * np.cos(angle - np.pi / 2)  # Adjust for matplotlib's angle convention
        y = radius * np.sin(angle - np.pi / 2)
        
        # Add text
        ax.text(
            x, y, per90_val,
            ha='center', va='center',
            fontsize=9,
            color=text_color,
            weight='bold',
            bbox=dict(
                boxstyle='round,pad=0.2',
                facecolor=background_color,
                edgecolor=slice_colors[i],
                linewidth=1,
                alpha=0.8
            ),
            zorder=4
        )
    
    # Add title
    title_text = f"{player_name}\nScouting Report"
    ax.text(
        0, 0,
        title_text,
        ha='center', va='center',
        fontsize=16,
        fontweight='bold',
        color=text_color,
        zorder=5
    )
    
    # Set background
    fig.patch.set_facecolor(background_color)
    ax.set_facecolor(background_color)
    
    plt.tight_layout()
    
    if save_path:
        plt.savefig(save_path, dpi=300, bbox_inches='tight', facecolor=background_color)
        print(f"Chart saved to {save_path}")
    
    if show:
        plt.show()
    else:
        plt.close()
    
    return fig, ax


def visualize_scout_report_with_categories(
    data: List[Dict[str, str]],
    category_mapping: Dict[str, List[str]],
    player_name: str = "Player",
    style: str = "athletic_dark",
    save_path: Optional[str] = None,
    show: bool = True
):
    """
    Create a pizza chart with explicit category grouping and colors.
    
    Args:
        data: List of dictionaries with keys 'Statistic', 'Per 90', 'Percentile'
        category_mapping: Dict mapping category names to lists of statistic names
                         Example: {"Attacking": ["Goals", "xG"], "Possession": ["Passes", "Pass %"]}
        player_name: Name of the player
        style: Style theme
        save_path: Optional path to save
        show: Whether to display
    """
    # Organize data by category
    category_colors = {
        "Attacking": "#FF6B6B",
        "Possession": "#4ECDC4",
        "Progression": "#45B7D1",
        "Defence": "#FFA07A",
        "Other": "#98D8C8"
    }
    
    # Create a lookup for statistics
    data_dict = {record['Statistic'].strip(): record for record in data}
    
    # Build params, values, and colors in category order
    params = []
    values = []
    per90_values = []
    slice_colors = []
    
    for category, stat_names in category_mapping.items():
        color = category_colors.get(category, "#808080")
        for stat_name in stat_names:
            if stat_name in data_dict:
                record = data_dict[stat_name]
                params.append(stat_name)
                try:
                    values.append(int(float(record['Percentile'])))
                except (ValueError, TypeError):
                    values.append(0)
                per90_values.append(record.get('Per 90', ''))
                slice_colors.append(color)
    
    # Add any remaining stats not in categories
    for stat_name, record in data_dict.items():
        if stat_name not in params:
            params.append(stat_name)
            try:
                values.append(int(float(record['Percentile'])))
            except (ValueError, TypeError):
                values.append(0)
            per90_values.append(record.get('Per 90', ''))
            slice_colors.append(category_colors.get("Other", "#808080"))
    
    # Now use the main visualization function with custom colors
    return visualize_scout_report_custom(
        params, values, per90_values, slice_colors,
        player_name, style, save_path, show
    )


def visualize_scout_report_custom(
    params: List[str],
    values: List[int],
    per90_values: List[str],
    slice_colors: List[str],
    player_name: str = "Player",
    style: str = "athletic_dark",
    save_path: Optional[str] = None,
    show: bool = True
):
    """
    Create a pizza chart with fully custom parameters.
    
    Args:
        params: List of statistic names
        values: List of percentile values (0-99)
        per90_values: List of per 90 values as strings
        slice_colors: List of colors for each slice
        player_name: Player name
        style: Style theme
        save_path: Optional save path
        show: Whether to display
    """
    if style == "athletic_dark":
        background_color = "#1a1a1a"
        text_color = "#ffffff"
    else:
        background_color = "#ffffff"
        text_color = "#000000"
    
    # Create the pizza chart
    baker = PyPizza(
        params=params,
        background_color=background_color,
        straight_line_color="#FFFFFF" if style == "athletic_dark" else "#000000",
        straight_line_lw=1,
        last_circle_lw=1,
        last_circle_color="#FFFFFF" if style == "athletic_dark" else "#000000",
        other_circle_lw=1,
        other_circle_color="#FFFFFF" if style == "athletic_dark" else "#000000",
        inner_circle_size=20
    )
    
    # Make the pizza
    fig, ax = baker.make_pizza(
        values,
        figsize=(12, 12),
        color_blank_space="same",
        slice_colors=slice_colors,
        value_colors=slice_colors,
        value_bck_colors=slice_colors,
        blank_alpha=0.4,
        kwargs_slices=dict(
            edgecolor="#FFFFFF" if style == "athletic_dark" else "#000000",
            zorder=2, linewidth=2
        ),
        kwargs_params=dict(
            color=text_color,
            fontsize=11,
            va="center"
        ),
        kwargs_values=dict(
            color=text_color,
            fontsize=11,
            zorder=3,
            bbox=dict(
                edgecolor="#FFFFFF" if style == "athletic_dark" else "#000000",
                facecolor=background_color,
                boxstyle="round,pad=0.3",
                linewidth=1.5
            )
        )
    )
    
    # Add per 90 values as text inside slices
    num_params = len(params)
    angles = np.linspace(0, 2 * np.pi, num_params, endpoint=False)
    
    for i, (angle, per90_val, value) in enumerate(zip(angles, per90_values, values)):
        if not per90_val or per90_val == '':
            continue
        
        radius = 60
        x = radius * np.cos(angle - np.pi / 2)
        y = radius * np.sin(angle - np.pi / 2)
        
        ax.text(
            x, y, per90_val,
            ha='center', va='center',
            fontsize=9,
            color=text_color,
            weight='bold',
            bbox=dict(
                boxstyle='round,pad=0.2',
                facecolor=background_color,
                edgecolor=slice_colors[i],
                linewidth=1,
                alpha=0.8
            ),
            zorder=4
        )
    
    # Add title
    title_text = f"{player_name}\nScouting Report"
    ax.text(
        0, 0,
        title_text,
        ha='center', va='center',
        fontsize=16,
        fontweight='bold',
        color=text_color,
        zorder=5
    )
    
    fig.patch.set_facecolor(background_color)
    ax.set_facecolor(background_color)
    
    plt.tight_layout()
    
    if save_path:
        plt.savefig(save_path, dpi=300, bbox_inches='tight', facecolor=background_color)
        print(f"Chart saved to {save_path}")
    
    if show:
        plt.show()
    else:
        plt.close()
    
    return fig, ax


if __name__ == "__main__":
    # Sample data (example from a scouting report)
    sample_data = [
        {"Statistic": "Non-Penalty Goals", "Per 90": "0.85", "Percentile": "95"},
        {"Statistic": "xG", "Per 90": "0.78", "Percentile": "92"},
        {"Statistic": "Shots", "Per 90": "4.2", "Percentile": "88"},
        {"Statistic": "Touches in Attacking Penalty Area", "Per 90": "8.5", "Percentile": "90"},
        {"Statistic": "Progressive Passes Received", "Per 90": "12.3", "Percentile": "85"},
        {"Statistic": "Passes Attempted", "Per 90": "28.5", "Percentile": "45"},
        {"Statistic": "Pass Completion %", "Per 90": "78.5", "Percentile": "65"},
        {"Statistic": "Progressive Passes", "Per 90": "5.2", "Percentile": "55"},
        {"Statistic": "Progressive Carries", "Per 90": "8.1", "Percentile": "70"},
        {"Statistic": "Successful Take-Ons", "Per 90": "2.3", "Percentile": "75"},
        {"Statistic": "Tackles", "Per 90": "0.8", "Percentile": "25"},
        {"Statistic": "Interceptions", "Per 90": "0.5", "Percentile": "30"},
        {"Statistic": "Pressures", "Per 90": "12.5", "Percentile": "60"},
        {"Statistic": "Aerials Won", "Per 90": "3.2", "Percentile": "80"},
        {"Statistic": "Clearances", "Per 90": "1.5", "Percentile": "40"},
    ]
    
    # Example with category mapping
    category_mapping = {
        "Attacking": [
            "Non-Penalty Goals", "xG", "Shots", "Touches in Attacking Penalty Area"
        ],
        "Possession": [
            "Passes Attempted", "Pass Completion %", "Progressive Passes Received"
        ],
        "Progression": [
            "Progressive Passes", "Progressive Carries", "Successful Take-Ons"
        ],
        "Defence": [
            "Tackles", "Interceptions", "Pressures", "Aerials Won", "Clearances"
        ]
    }
    
    print("Creating sample pizza chart...")
    
    # Create visualization
    visualize_scout_report(
        sample_data,
        player_name="Erling Haaland",
        style="athletic_dark",
        save_path="data/haaland_scout_report.png",
        show=False
    )
    
    print("✓ Sample chart created!")
    
    # Example with explicit categories
    print("\nCreating chart with category grouping...")
    visualize_scout_report_with_categories(
        sample_data,
        category_mapping,
        player_name="Erling Haaland",
        style="athletic_dark",
        save_path="data/haaland_scout_report_categorized.png",
        show=False
    )
    
    print("✓ Categorized chart created!")
