"""
Web scraper for extracting player data from fbref.com.

This module handles:
- Fetching player statistics pages
- Parsing HTML tables
- Extracting relevant metrics
- Converting raw values to percentiles (requires reference data)
"""

import requests
from bs4 import BeautifulSoup
import pandas as pd
from typing import Dict, List, Optional, Tuple
import time
import json
from urllib.parse import urljoin, urlparse


class FBRefScraper:
    """
    Scraper for fbref.com football statistics.
    
    Note: Always respect robots.txt and rate limits.
    Consider using official APIs when available.
    """
    
    BASE_URL = "https://fbref.com"
    HEADERS = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
    }
    
    def __init__(self, delay: float = 1.0):
        """
        Initialize scraper.
        
        Args:
            delay: Delay between requests in seconds (be respectful!)
        """
        self.delay = delay
        self.session = requests.Session()
        self.session.headers.update(self.HEADERS)
    
    def get_page(self, url: str) -> BeautifulSoup:
        """
        Fetch and parse a page.
        
        Args:
            url: Full URL or path relative to BASE_URL
            
        Returns:
            BeautifulSoup object
        """
        if not url.startswith('http'):
            url = urljoin(self.BASE_URL, url)
        
        time.sleep(self.delay)  # Rate limiting
        
        try:
            response = self.session.get(url, timeout=10)
            response.raise_for_status()
            return BeautifulSoup(response.content, 'html.parser')
        except requests.RequestException as e:
            raise Exception(f"Failed to fetch {url}: {e}")
    
    def search_player(self, player_name: str) -> List[Dict[str, str]]:
        """
        Search for a player by name.
        
        Args:
            player_name: Player name to search for
            
        Returns:
            List of player results with name, url, and team info
        """
        # fbref search URL pattern
        search_url = f"{self.BASE_URL}/en/search/search.fcgi?search={player_name}"
        soup = self.get_page(search_url)
        
        results = []
        # Parse search results (structure may vary)
        # This is a simplified version - actual parsing depends on fbref's HTML structure
        search_results = soup.find_all('div', class_='search-item', limit=10)
        
        for result in search_results:
            link = result.find('a')
            if link:
                results.append({
                    'name': link.get_text(strip=True),
                    'url': link.get('href', ''),
                    'team': result.find('span', class_='team') or ''
                })
        
        return results
    
    def get_player_stats(self, player_url: str, season: Optional[str] = None) -> Dict:
        """
        Extract player statistics from their fbref page.
        
        Args:
            player_url: URL path to player's page
            season: Optional season filter (e.g., "2024-2025")
            
        Returns:
            Dictionary of statistics by category
        """
        soup = self.get_page(player_url)
        
        stats = {}
        
        # Find all stat tables on the page
        # fbref uses various table IDs like "stats_standard", "stats_defense", etc.
        tables = soup.find_all('table', id=lambda x: x and 'stats' in x)
        
        for table in tables:
            table_id = table.get('id', '')
            
            try:
                # Convert HTML table to pandas DataFrame
                df = pd.read_html(str(table))[0]
                
                # Clean column names (fbref has multi-level headers)
                if isinstance(df.columns, pd.MultiIndex):
                    df.columns = ['_'.join(col).strip() for col in df.columns.values]
                
                # Store by table type
                if 'standard' in table_id:
                    stats['standard'] = df.to_dict('records')
                elif 'defense' in table_id or 'defensive' in table_id:
                    stats['defense'] = df.to_dict('records')
                elif 'passing' in table_id:
                    stats['passing'] = df.to_dict('records')
                elif 'shooting' in table_id:
                    stats['shooting'] = df.to_dict('records')
                elif 'possession' in table_id:
                    stats['possession'] = df.to_dict('records')
                else:
                    stats[table_id] = df.to_dict('records')
                    
            except Exception as e:
                print(f"Warning: Could not parse table {table_id}: {e}")
                continue
        
        return stats
    
    def extract_metrics_for_pizza_chart(
        self,
        player_stats: Dict,
        position: str = "outfield"
    ) -> Dict[str, Dict[str, float]]:
        """
        Extract and map fbref stats to pizza chart metrics.
        
        This is a simplified mapping - you'll need to:
        1. Calculate percentiles based on position-specific peer groups
        2. Handle missing data
        3. Apply the formulas from The Athletic article
        
        Args:
            player_stats: Dictionary of stats from get_player_stats()
            position: Player position for percentile calculation
            
        Returns:
            Dictionary of category -> metric_name -> raw_value
            (percentiles need to be calculated separately with reference data)
        """
        metrics = {
            "defence": {},
            "possession": {},
            "progression": {},
            "attack": {}
        }
        
        # Extract from standard stats
        standard = player_stats.get('standard', [{}])[0] if player_stats.get('standard') else {}
        defense = player_stats.get('defense', [{}])[0] if player_stats.get('defense') else {}
        passing = player_stats.get('passing', [{}])[0] if player_stats.get('passing') else {}
        shooting = player_stats.get('shooting', [{}])[0] if player_stats.get('shooting') else {}
        possession = player_stats.get('possession', [{}])[0] if player_stats.get('possession') else {}
        
        # Helper to safely get numeric value
        def get_value(data: dict, key: str, default: float = 0.0) -> float:
            val = data.get(key, default)
            try:
                return float(val) if val not in [None, '', '—'] else default
            except (ValueError, TypeError):
                return default
        
        # DEFENCE metrics (simplified - needs proper calculation)
        # Front-foot defending: tackles, challenges, fouls, interceptions, blocked passes per 90
        # Back-foot defending: blocked shots, clearances per 90
        # Aerial volume: aerial duels per 90
        # Aerial success: aerial duel win %
        
        # POSSESSION metrics
        # Link-up play: short/medium passes %
        # Ball retention: pass completion %
        # Launched passes: long passes %
        
        # PROGRESSION metrics
        # Creative threat: xA + assists (80/20)
        # Cross volume: crosses per 100 touches in attacking third
        # Dribble volume: dribbles per 100 touches
        # Pass progression: progressive passes %
        # Carry progression: progressive carries %
        
        # ATTACK metrics
        # Goal threat: xG + goals (70/30)
        # Shot frequency: shots per 100 touches
        # Box threat: penalty area touches %
        # Shot quality: xG per shot
        
        # This is a placeholder - actual implementation requires:
        # 1. Proper field name mapping from fbref
        # 2. Per-90 calculations
        # 3. Percentile calculations against position peers
        # 4. Formula implementations from The Athletic article
        
        return metrics


def calculate_percentiles(
    raw_values: Dict[str, float],
    reference_data: pd.DataFrame,
    position: Optional[str] = None
) -> Dict[str, float]:
    """
    Calculate percentile scores (0-99) for metrics.
    
    Args:
        raw_values: Dictionary of metric_name -> raw_value
        reference_data: DataFrame with reference data for all players
        position: Optional position filter for peer group
        
    Returns:
        Dictionary of metric_name -> percentile (0-99)
    """
    percentiles = {}
    
    # Filter by position if provided
    if position and 'position' in reference_data.columns:
        ref_data = reference_data[reference_data['position'] == position]
    else:
        ref_data = reference_data
    
    for metric_name, value in raw_values.items():
        if metric_name not in ref_data.columns:
            continue
        
        # Calculate percentile
        percentile = (ref_data[metric_name] < value).sum() / len(ref_data) * 100
        percentiles[metric_name] = min(99, max(0, percentile))
    
    return percentiles


# Example usage function
def scrape_player_for_pizza_chart(
    player_name: str,
    season: Optional[str] = None,
    reference_data_path: Optional[str] = None
) -> Dict:
    """
    Complete workflow: search, scrape, and prepare data for pizza chart.
    
    Args:
        player_name: Name of player to search
        season: Optional season filter
        reference_data_path: Path to CSV with reference data for percentiles
        
    Returns:
        Dictionary ready for EntityProfile creation
    """
    scraper = FBRefScraper()
    
    # Search for player
    results = scraper.search_player(player_name)
    if not results:
        raise ValueError(f"Player '{player_name}' not found")
    
    # Use first result (could add selection logic)
    player = results[0]
    
    # Get stats
    stats = scraper.get_player_stats(player['url'], season)
    
    # Extract metrics (raw values)
    raw_metrics = scraper.extract_metrics_for_pizza_chart(stats)
    
    # Calculate percentiles if reference data provided
    if reference_data_path:
        ref_data = pd.read_csv(reference_data_path)
        # This would need proper implementation based on your reference data structure
        pass
    
    return {
        'player_info': player,
        'stats': stats,
        'metrics': raw_metrics
    }
