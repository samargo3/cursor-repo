"""
Scrape a player's Scouting Report from FBref.

This script fetches the scouting report table from a player's FBref page,
extracts key statistics, and returns them as a list of dictionaries.
"""

import pandas as pd
import requests
from bs4 import BeautifulSoup
from typing import List, Dict, Optional
import re
import urllib3
import warnings

# Suppress SSL warnings for testing (use with caution in production)
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


def scrape_scout_report(player_url: str) -> List[Dict[str, str]]:
    """
    Scrape a player's Scouting Report from FBref.
    
    Args:
        player_url: Full URL to the player's FBref page
                   Example: "https://fbref.com/en/players/1f44ac21/Erling-Haaland"
    
    Returns:
        List of dictionaries with keys: 'Statistic', 'Per 90', 'Percentile'
    """
    # Fetch the page
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
    }
    
    try:
        # Try with SSL verification first
        response = requests.get(player_url, headers=headers, timeout=10, verify=True)
        response.raise_for_status()
    except requests.exceptions.SSLError:
        # Fallback: try without SSL verification (for testing environments)
        warnings.warn("SSL verification failed, attempting without verification (not recommended for production)")
        try:
            response = requests.get(player_url, headers=headers, timeout=10, verify=False)
            response.raise_for_status()
        except requests.RequestException as e:
            raise Exception(f"Failed to fetch page even without SSL verification: {e}")
    except requests.RequestException as e:
        raise Exception(f"Failed to fetch page: {e}")
    
    # Parse HTML to find the scout table
    soup = BeautifulSoup(response.content, 'html.parser')
    
    # Find table with id containing 'scout_full'
    scout_table = soup.find('table', id=re.compile(r'scout_full'))
    
    if not scout_table:
        raise ValueError("Could not find scout_full table on the page")
    
    # Convert table to DataFrame using pd.read_html
    # We'll read from the HTML string of just the table
    try:
        dfs = pd.read_html(str(scout_table))
        if not dfs:
            raise ValueError("No tables found in scout_full element")
        df = dfs[0]
    except Exception as e:
        raise Exception(f"Failed to parse table: {e}")
    
    # Clean multi-level headers
    if isinstance(df.columns, pd.MultiIndex):
        # Flatten multi-level headers
        df.columns = ['_'.join(col).strip() for col in df.columns.values]
        # Remove any trailing underscores
        df.columns = [col.rstrip('_') for col in df.columns]
    
    # Find the columns we need (case-insensitive, handle variations)
    stat_col = None
    per90_col = None
    percentile_col = None
    
    for col in df.columns:
        col_lower = str(col).lower()
        if 'statistic' in col_lower or 'stat' in col_lower:
            stat_col = col
        elif 'per 90' in col_lower or 'per90' in col_lower or 'per_90' in col_lower:
            per90_col = col
        elif 'percentile' in col_lower:
            percentile_col = col
    
    if not stat_col:
        raise ValueError("Could not find 'Statistic' column")
    if not per90_col:
        raise ValueError("Could not find 'Per 90' column")
    if not percentile_col:
        raise ValueError("Could not find 'Percentile' column")
    
    # Select only the columns we need
    df_clean = df[[stat_col, per90_col, percentile_col]].copy()
    df_clean.columns = ['Statistic', 'Per 90', 'Percentile']
    
    # Filter out empty rows and header repeats
    # Remove rows where Statistic is NaN, empty, or looks like a header
    df_clean = df_clean.dropna(subset=['Statistic'])
    df_clean = df_clean[df_clean['Statistic'].astype(str).str.strip() != '']
    
    # Filter out rows that are likely headers (common header patterns)
    header_patterns = [
        'statistic', 'stat', 'metric', 'measure',
        'per 90', 'per90', 'percentile',
        'scouting', 'report'
    ]
    
    def is_header(row_value: str) -> bool:
        """Check if a row value looks like a header."""
        if pd.isna(row_value):
            return True
        row_str = str(row_value).strip().lower()
        return any(pattern in row_str for pattern in header_patterns) and len(row_str) < 30
    
    df_clean = df_clean[~df_clean['Statistic'].apply(is_header)]
    
    # Remove rows where all values are empty/NaN
    df_clean = df_clean.dropna(how='all')
    
    # Reset index
    df_clean = df_clean.reset_index(drop=True)
    
    # Convert to list of dictionaries
    result = df_clean.to_dict('records')
    
    # Clean up the values (convert to strings, handle NaN)
    for record in result:
        for key in record:
            if pd.isna(record[key]):
                record[key] = ''
            else:
                record[key] = str(record[key]).strip()
    
    return result


def scrape_scout_report_simple(player_url: str) -> List[Dict[str, str]]:
    """
    Simpler version that uses pd.read_html directly on the URL.
    
    This is a fallback if the BeautifulSoup approach doesn't work.
    """
    try:
        # Read all tables from the page
        # Note: pd.read_html may have SSL issues, so we'll try with verify=False if needed
        try:
            dfs = pd.read_html(player_url, attrs={'id': re.compile(r'scout_full')})
        except Exception as ssl_error:
            if 'SSL' in str(ssl_error) or 'certificate' in str(ssl_error).lower():
                warnings.warn("SSL verification failed, attempting without verification")
                # pd.read_html doesn't support verify parameter directly,
                # so we'll need to fetch the page first
                import requests
                headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'}
                response = requests.get(player_url, headers=headers, verify=False, timeout=10)
                response.raise_for_status()
                dfs = pd.read_html(response.text, attrs={'id': re.compile(r'scout_full')})
            else:
                raise
        
        if not dfs:
            raise ValueError("No scout_full table found")
        
        df = dfs[0]
        
        # Clean headers
        if isinstance(df.columns, pd.MultiIndex):
            df.columns = ['_'.join(col).strip() for col in df.columns.values]
            df.columns = [col.rstrip('_') for col in df.columns]
        
        # Find columns
        stat_col = None
        per90_col = None
        percentile_col = None
        
        for col in df.columns:
            col_lower = str(col).lower()
            if 'statistic' in col_lower:
                stat_col = col
            elif 'per 90' in col_lower or 'per90' in col_lower:
                per90_col = col
            elif 'percentile' in col_lower:
                percentile_col = col
        
        if not all([stat_col, per90_col, percentile_col]):
            raise ValueError("Could not find required columns")
        
        # Select and clean
        df_clean = df[[stat_col, per90_col, percentile_col]].copy()
        df_clean.columns = ['Statistic', 'Per 90', 'Percentile']
        
        # Filter
        df_clean = df_clean.dropna(subset=['Statistic'])
        df_clean = df_clean[df_clean['Statistic'].astype(str).str.strip() != '']
        
        # Remove header-like rows
        header_patterns = ['statistic', 'stat', 'per 90', 'percentile']
        df_clean = df_clean[
            ~df_clean['Statistic'].astype(str).str.lower().isin([p for p in header_patterns])
        ]
        
        return df_clean.to_dict('records')
        
    except Exception as e:
        raise Exception(f"Failed to scrape with simple method: {e}")


if __name__ == "__main__":
    # Example usage
    player_url = "https://fbref.com/en/players/1f44ac21/Erling-Haaland"
    
    print(f"Scraping scouting report from: {player_url}\n")
    
    try:
        # Try the main method first
        results = scrape_scout_report(player_url)
        
        print(f"Successfully extracted {len(results)} statistics:\n")
        
        # Display first 10 results
        for i, record in enumerate(results[:10], 1):
            print(f"{i}. {record['Statistic']}: {record['Per 90']} (Percentile: {record['Percentile']})")
        
        if len(results) > 10:
            print(f"\n... and {len(results) - 10} more statistics")
        
        print(f"\nTotal statistics extracted: {len(results)}")
        
    except Exception as e:
        print(f"Error with main method: {e}")
        print("\nTrying simple method...")
        
        try:
            results = scrape_scout_report_simple(player_url)
            print(f"Successfully extracted {len(results)} statistics with simple method")
            for i, record in enumerate(results[:10], 1):
                print(f"{i}. {record['Statistic']}: {record['Per 90']} (Percentile: {record['Percentile']})")
        except Exception as e2:
            print(f"Error with simple method: {e2}")
