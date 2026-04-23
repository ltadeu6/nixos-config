#!/usr/bin/env python3

import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path
from tempfile import NamedTemporaryFile


def iso_from_epoch(value):
    if value is None:
        return None
    return datetime.fromtimestamp(float(value), tz=timezone.utc).isoformat()


def clamp_percent(value):
    value = max(0.0, min(100.0, float(value)))
    return round(value, 2)


def extract_status(session_root):
    files = sorted(session_root.rglob("*.jsonl"), key=lambda p: p.stat().st_mtime, reverse=True)

    for path in files:
        try:
            with path.open("r", encoding="utf-8") as handle:
                lines = handle.readlines()
        except OSError:
            continue

        for line in reversed(lines):
            try:
                event = json.loads(line)
            except json.JSONDecodeError:
                continue

            if event.get("type") != "event_msg":
                continue

            payload = event.get("payload") or {}
            if payload.get("type") != "token_count":
                continue

            info = payload.get("info") or {}
            rate_limits = payload.get("rate_limits") or {}

            primary = rate_limits.get("primary") or {}
            secondary = rate_limits.get("secondary") or {}

            if "used_percent" not in primary or "used_percent" not in secondary:
                continue

            return {
                "plan_type": rate_limits.get("plan_type"),
                "five_hour_left_percent": clamp_percent(100.0 - float(primary["used_percent"])),
                "five_hour_resets_at": iso_from_epoch(primary.get("resets_at")),
                "weekly_left_percent": clamp_percent(100.0 - float(secondary["used_percent"])),
                "weekly_resets_at": iso_from_epoch(secondary.get("resets_at")),
                "exported_at": datetime.now(timezone.utc).isoformat(),
                "source_file": str(path),
            }

    return None


def main():
    output_path = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("/var/lib/hass/codex_status.json")
    session_root = Path(os.environ.get("CODEX_SESSION_ROOT", str(Path.home() / ".codex" / "sessions")))

    status = extract_status(session_root)
    if status is None:
        print(f"No Codex token_count event found under {session_root}", file=sys.stderr)
        return 1

    output_path.parent.mkdir(parents=True, exist_ok=True)
    with NamedTemporaryFile("w", encoding="utf-8", dir=output_path.parent, delete=False) as handle:
        json.dump(status, handle, ensure_ascii=False, separators=(",", ":"))
        handle.write("\n")
        temp_path = Path(handle.name)

    temp_path.replace(output_path)
    output_path.chmod(0o644)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
