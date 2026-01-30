import pandas as pd
import requests
import time
from typing import List, Dict
from bs4 import BeautifulSoup


def scrape_fbref_scout(url: str) -> List[Dict]:
    """
    Scrape a player's Scouting Report from FBref.
    
    Args:
        url: FBref player URL (e.g., https://fbref.com/en/players/1f44ac21/Erling-Haaland)
    
    Returns:
        List of dictionaries with 'Statistic', 'Per 90', and 'Percentile' keys
    """
    # Fetch the HTML content with realistic browser headers
    headers = {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.9',
        'Accept-Encoding': 'gzip, deflate, br',
        'DNT': '1',
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': '1',
        'Sec-Fetch-Dest': 'document',
        'Sec-Fetch-Mode': 'navigate',
        'Sec-Fetch-Site': 'none',
        'Sec-Fetch-User': '?1',
        'Cache-Control': 'max-age=0'
    }
    
    # Use a session to handle cookies
    session = requests.Session()
    
    # Add a small delay to be respectful to the server
    time.sleep(1.5)
    
    response = session.get(url, headers=headers, timeout=10)
    response.raise_for_status()
    
    # Find the table with 'scout_full' in its id
    soup = BeautifulSoup(response.text, 'html.parser')
    
    scout_table = soup.find('table', id=lambda x: x and 'scout_full' in x)
    if not scout_table:
        raise ValueError("No table with 'scout_full' in id found")
    
    # Get the table index by finding which table in all_tables matches
    # We'll read the specific table directly
    df = pd.read_html(str(scout_table))[0]
    
    # Flatten multi-level headers
    if isinstance(df.columns, pd.MultiIndex):
        # Flatten by joining column levels with underscore
        df.columns = ['_'.join(col).strip() for col in df.columns.values]
    else:
        df.columns = [str(col).strip() for col in df.columns]
    
    # Find columns that contain our target column names (case-insensitive)
    stat_col = None
    per90_col = None
    percentile_col = None
    
    for col in df.columns:
        col_lower = col.lower()
        if 'statistic' in col_lower and stat_col is None:
            stat_col = col
        elif 'per 90' in col_lower or 'per90' in col_lower.replace(' ', ''):
            per90_col = col
        elif 'percentile' in col_lower:
            percentile_col = col
    
    if not all([stat_col, per90_col, percentile_col]):
        raise ValueError(f"Could not find required columns. Found columns: {list(df.columns)}")
    
    # Select only the three columns we need
    df_clean = df[[stat_col, per90_col, percentile_col]].copy()
    df_clean.columns = ['Statistic', 'Per 90', 'Percentile']
    
    # Filter out empty rows and header rows
    # Remove rows where Statistic is empty, NaN, or matches common header patterns
    df_clean = df_clean.dropna(subset=['Statistic'])
    df_clean = df_clean[df_clean['Statistic'].astype(str).str.strip() != '']
    
    # Filter out rows that look like headers (case-insensitive matching)
    header_patterns = ['statistic', 'per 90', 'percentile', 'scout', 'player']
    df_clean = df_clean[
        ~df_clean['Statistic'].astype(str).str.lower().isin(header_patterns)
    ]
    
    # Reset index
    df_clean = df_clean.reset_index(drop=True)
    
    # Convert to list of dictionaries
    result = df_clean.to_dict('records')
    
    return result


if __name__ == '__main__':
    # Example usage
    url = 'https://fbref.com/en/players/1f44ac21/Erling-Haaland'
    try:
        data = scrape_fbref_scout(url)
        print(f"Scraped {len(data)} statistics:")
        for item in data[:5]:  # Print first 5 as example
            print(item)
    except Exception as e:
        print(f"Error: {e}")
