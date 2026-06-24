"""Playwright-based scraper for JavaScript-rendered dashboards."""

from __future__ import annotations

import json
import re
from datetime import datetime, timezone
from typing import Any

from playwright.sync_api import Page, sync_playwright

from scraper.config import (
    DASHBOARDS,
    HEADLESS,
    NAVIGATION_TIMEOUT_MS,
    OUTPUT_FILE,
    PAGE_TIMEOUT_MS,
)


def _text(el) -> str:
    if el is None:
        return ""
    return re.sub(r"\s+", " ", el.inner_text()).strip()


def _scrape_dashboard(page: Page, dashboard: dict[str, Any]) -> list[dict[str, Any]]:
    """Extract issue rows from a single dashboard."""
    url = dashboard["url"]
    selectors = dashboard["selectors"]
    wait_for = dashboard.get("wait_for")

    page.set_default_timeout(PAGE_TIMEOUT_MS)
    page.goto(url, wait_until="networkidle", timeout=NAVIGATION_TIMEOUT_MS)

    if wait_for:
        page.wait_for_selector(wait_for, timeout=PAGE_TIMEOUT_MS)

    issues: list[dict[str, Any]] = []
    rows = page.query_selector_all(selectors["issue_rows"])

    for row in rows:
        def cell(key: str):
            sel = selectors.get(key)
            if not sel:
                return ""
            return _text(row.query_selector(sel))

        issue_id = cell("issue_id")
        title = cell("title")
        if not issue_id and not title:
            continue

        issues.append(
            {
                "id": issue_id or None,
                "title": title or None,
                "status": cell("status") or None,
                "updated": cell("updated") or None,
                "source_id": dashboard["id"],
                "source_name": dashboard["name"],
                "source_url": url,
            }
        )

    return issues


def scrape_all() -> dict[str, Any]:
    """Scrape every configured dashboard and return the API payload."""
    all_issues: list[dict[str, Any]] = []
    errors: list[dict[str, str]] = []

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=HEADLESS)
        context = browser.new_context(
            user_agent=(
                "Mozilla/5.0 (compatible; GitScraper/1.0; "
                "+https://github.com/public-issue-tracker)"
            )
        )
        page = context.new_page()

        for dashboard in DASHBOARDS:
            try:
                issues = _scrape_dashboard(page, dashboard)
                all_issues.extend(issues)
            except Exception as exc:  # noqa: BLE001 — collect per-source failures
                errors.append(
                    {
                        "source_id": dashboard["id"],
                        "url": dashboard["url"],
                        "error": str(exc),
                    }
                )

        browser.close()

    return {
        "meta": {
            "scraped_at": datetime.now(timezone.utc).isoformat(),
            "sources": len(DASHBOARDS),
            "issue_count": len(all_issues),
            "errors": errors,
        },
        "issues": all_issues,
    }


def save_json(payload: dict[str, Any], path=OUTPUT_FILE) -> None:
    """Write payload to a flat JSON file (our public API)."""
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2, ensure_ascii=False)
        f.write("\n")
