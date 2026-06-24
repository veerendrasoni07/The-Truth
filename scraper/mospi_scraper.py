import asyncio
import json
import os
import random
from pathlib import Path

from playwright.async_api import async_playwright

# Override with MOSPI_TARGET_URL when the real dashboard is known.
PLACEHOLDER_URL = "https://example.gov.in/dashboard"
TARGET_URL = os.environ.get("MOSPI_TARGET_URL", PLACEHOLDER_URL)

ROOT = Path(__file__).resolve().parent
FIXTURE_PATH = ROOT / "fixtures" / "sample_dashboard.html"
OUTPUT_DIR = "data"
OUTPUT_FILE = os.path.join(OUTPUT_DIR, "projects.json")


def resolve_target_url() -> str:
    """Use local fixture when the placeholder URL is still configured."""
    use_fixture = os.environ.get("USE_FIXTURE", "").lower() in ("1", "true", "yes")
    if use_fixture or TARGET_URL == PLACEHOLDER_URL:
        if not FIXTURE_PATH.is_file():
            raise FileNotFoundError(f"Fixture not found: {FIXTURE_PATH}")
        print(
            "Using local fixture (placeholder URL is not live). "
            "Set MOSPI_TARGET_URL to scrape the real dashboard."
        )
        return FIXTURE_PATH.as_uri()
    return TARGET_URL


async def random_sleep(min_seconds=2.5, max_seconds=5.3):
    """Mimic human reading delays to avoid bot detection."""
    delay = random.uniform(min_seconds, max_seconds)
    print(f"Sleeping for {delay:.2f} seconds...")
    await asyncio.sleep(delay)


async def run_scraper():
    url = resolve_target_url()
    projects_data = []

    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        context = await browser.new_context(
            user_agent=(
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
                "AppleWebKit/537.36 (KHTML, like Gecko) "
                "Chrome/120.0.0.0 Safari/537.36"
            )
        )
        page = await context.new_page()

        try:
            print(f"Navigating to {url}...")
            await page.goto(url, wait_until="domcontentloaded", timeout=60000)

            await page.wait_for_load_state("networkidle")
            await random_sleep()

            table_selector = ".project-data-table"
            await page.wait_for_selector(table_selector, timeout=10000)

            rows = await page.locator(f"{table_selector} tr").all()
            print(f"Found {len(rows)} rows. Extracting data...")

            for row in rows[1:]:
                try:
                    cells = await row.locator("td").all()

                    if len(cells) < 5:
                        continue

                    project = {
                        "project_name": await cells[0].inner_text(),
                        "budget_crores": await cells[1].inner_text(),
                        "start_date": await cells[2].inner_text(),
                        "status": await cells[3].inner_text(),
                        "last_updated": await cells[4].inner_text(),
                    }
                    project = {k: v.strip() for k, v in project.items()}
                    projects_data.append(project)

                except Exception as row_err:
                    print(f"Skipping malformed row: {row_err}")

        except Exception as e:
            print(f"Error during scrape: {e}")

        finally:
            await browser.close()

    if not os.path.exists(OUTPUT_DIR):
        os.makedirs(OUTPUT_DIR)

    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        json.dump(projects_data, f, indent=2, ensure_ascii=False)

    print(f"Successfully saved {len(projects_data)} projects to {OUTPUT_FILE}")


if __name__ == "__main__":
    asyncio.run(run_scraper())
