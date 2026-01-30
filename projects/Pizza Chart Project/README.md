# FBref Scouting Report Scraper

A Python script to scrape player scouting reports from FBref.com.

## Installation

Install the required packages using `pip3`:

```bash
pip3 install pandas requests beautifulsoup4 lxml html5lib
```

Or install from requirements.txt:

```bash
pip3 install -r requirements.txt
```

## Usage

Run the script with `python3`:

```bash
python3 scrape_fbref_scout.py
```

## Customization

To scrape a different player, modify the URL in the `if __name__ == '__main__':` block:

```python
url = 'https://fbref.com/en/players/YOUR_PLAYER_ID/Player-Name'
```

## Output

The script returns a list of dictionaries with the following keys:
- `Statistic`: The name of the statistic
- `Per 90`: The value per 90 minutes
- `Percentile`: The percentile ranking
