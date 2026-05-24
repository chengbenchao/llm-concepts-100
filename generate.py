#!/usr/bin/env python3
"""Generate /var/www/llm/data.json from the concept files in this repo."""
import json, os, yaml

REPO = os.path.dirname(os.path.abspath(__file__))
WEB = "/var/www/llm"

# Load progress
with open(os.path.join(REPO, "progress.yaml")) as f:
    progress = yaml.safe_load(f)

# Build concept list from the 100-concepts-full.md structure
# For now, use the reference data
# (Future: parse individual concept/*.md files)

data = {
    "start_date": progress["start_date"],
    "total": 100,
    "completed": progress["metrics"]["completed"],
    "in_progress": progress["metrics"]["in_progress"],
    "current": progress["in_progress"],
    "concepts": []  # populated from reference
}

# This is the master reference - sync with llm-100-concepts.md
# For now loads existing data.json and updates progress fields
if os.path.exists(os.path.join(WEB, "data.json")):
    with open(os.path.join(WEB, "data.json")) as f:
        existing = json.load(f)
    for c in existing["concepts"]:
        # Update status from progress
        completed_ids = [e["id"] for e in progress.get("completed_list", [])]
        if c["id"] in completed_ids:
            c["status"] = "completed"
        elif c["id"] == progress["in_progress"]:
            c["status"] = "in_progress"
    data["concepts"] = existing["concepts"]

data["completed"] = progress["metrics"]["completed"]
data["in_progress"] = progress["metrics"]["in_progress"]
data["current"] = progress["in_progress"]

os.makedirs(WEB, exist_ok=True)
with open(os.path.join(WEB, "data.json"), "w") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print(f"✅ Synced: {data['completed']} done, {data['in_progress']} in progress, {100-data['completed']-data['in_progress']} pending")
