"""Entry point: scrape dashboards and write data/issues.json."""

from scraper.scraper import save_json, scrape_all


def main() -> None:
    payload = scrape_all()
    save_json(payload)
    count = payload["meta"]["issue_count"]
    errors = payload["meta"]["errors"]
    print(f"Wrote {count} issue(s) to data/issues.json")
    if errors:
        print(f"Warning: {len(errors)} source(s) failed:")
        for err in errors:
            print(f"  - {err['source_id']}: {err['error']}")


if __name__ == "__main__":
    main()
