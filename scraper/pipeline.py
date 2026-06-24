import asyncio
import json
import os
from pathlib import Path
from typing import List, Literal

from google import genai
from google.genai import types
from pydantic import BaseModel, Field

SCRAPER_ROOT = Path(__file__).resolve().parent
LEDGER_PATH = SCRAPER_ROOT / "data" / "ledger.json"


class TimelineEvent(BaseModel):
    date: str = Field(description="ISO Date format YYYY-MM or YYYY-MM-DD string")
    event_description: str = Field(
        description="Objective, factual description of what happened"
    )


class ProjectLedgerSchema(BaseModel):
    project_id: str = Field(
        description="Unique snake_case identifier based on project name"
    )
    title: str = Field(description="Official name of the project")
    budget_crores: float = Field(description="Latest total cost/budget in INR Crores")
    expected_completion: str = Field(description="Current expected completion date")
    status: Literal["Ongoing", "Delayed", "Completed", "Stalled"]
    timeline: List[TimelineEvent]


def load_config() -> dict:
    config_path = SCRAPER_ROOT / "config.json"
    if config_path.is_file():
        with config_path.open("r", encoding="utf-8") as f:
            return json.load(f)
    return {}


def load_ledger() -> dict:
    if LEDGER_PATH.is_file():
        with LEDGER_PATH.open("r", encoding="utf-8") as f:
            return json.load(f)
    return {}


def save_ledger(data: dict) -> None:
    LEDGER_PATH.parent.mkdir(parents=True, exist_ok=True)
    with LEDGER_PATH.open("w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write("\n")


async def mock_fetch_raw_text() -> str:
    """Simulated raw input from a messy government infrastructure portal."""
    return """
    UPDATE: The Delhi-Dehradun Expressway project progress reviewed. The original cost of 12000 Crores has been updated to 13000 Crores due to land acquisition delays.
    While originally slated for December 2024, the newly announced expected operations will begin in June 2025. National Highways Authority of India noted 72% overall physical completion as of today, June 2026.
    """


def extract_with_gemini(raw_text: str, model_name: str) -> dict:
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        raise RuntimeError(
            "GEMINI_API_KEY is not set. Add it to GitHub Secrets or your local environment."
        )

    client = genai.Client(api_key=api_key)

    prompt = (
        "Extract structural data from this government update text. "
        "Return factual fields only. Build timeline events from dated milestones "
        "mentioned in the text.\n\n"
        f"{raw_text}"
    )

    print("Parsing unstructured data via Gemini API...")
    response = client.models.generate_content(
        model=model_name,
        contents=prompt,
        config=types.GenerateContentConfig(
            response_mime_type="application/json",
            response_schema=ProjectLedgerSchema,
        ),
    )

    if response.parsed is not None:
        return response.parsed.model_dump()

    return json.loads(response.text)


def merge_into_ledger(ledger: dict, extracted_data: dict) -> dict:
    project_id = extracted_data["project_id"]

    if project_id in ledger:
        existing_dates = {e["date"] for e in ledger[project_id].get("timeline", [])}
        new_events = [
            e for e in extracted_data["timeline"] if e["date"] not in existing_dates
        ]

        ledger[project_id]["budget_crores"] = extracted_data["budget_crores"]
        ledger[project_id]["expected_completion"] = extracted_data["expected_completion"]
        ledger[project_id]["status"] = extracted_data["status"]
        ledger[project_id]["title"] = extracted_data["title"]
        ledger[project_id].setdefault("timeline", []).extend(new_events)
    else:
        ledger[project_id] = extracted_data

    return ledger


async def main() -> None:
    config = load_config()
    model_name = config.get("gemini_model", "gemini-2.5-flash")

    raw_scraped_text = await mock_fetch_raw_text()
    extracted_data = extract_with_gemini(raw_scraped_text, model_name)

    ledger = load_ledger()
    ledger = merge_into_ledger(ledger, extracted_data)
    save_ledger(ledger)

    project_id = extracted_data["project_id"]
    print(f"Ledger entry for '{project_id}' updated cleanly.")


if __name__ == "__main__":
    asyncio.run(main())
