"""Scraper configuration — edit targets and selectors for your dashboards."""

from pathlib import Path

# Project root (parent of scraper/)
ROOT = Path(__file__).resolve().parent.parent
DATA_DIR = ROOT / "data"
OUTPUT_FILE = DATA_DIR / "issues.json"

# Dashboards to scrape. Add one entry per source.
DASHBOARDS = [
    {
        "id": "example-infrastructure",
        "name": "Example Government Infrastructure Dashboard",
        "url": "https://example.gov/infrastructure-status",
        # CSS selectors — customize per dashboard
        "selectors": {
            "issue_rows": "table tbody tr",
            "issue_id": "td:nth-child(1)",
            "title": "td:nth-child(2)",
            "status": "td:nth-child(3)",
            "updated": "td:nth-child(4)",
        },
        "wait_for": "table tbody tr",  # wait until data is rendered
    },
]

# Playwright settings
HEADLESS = True
PAGE_TIMEOUT_MS = 60_000
NAVIGATION_TIMEOUT_MS = 90_000
