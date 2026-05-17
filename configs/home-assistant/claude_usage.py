#!/usr/bin/env python3

import json
import os
import shutil
import sqlite3
import sys
import urllib.error
import urllib.request
from datetime import datetime, timezone
from pathlib import Path
from tempfile import NamedTemporaryFile
from typing import Optional


def clamp_percent(value):
    value = max(0.0, min(100.0, float(value)))
    return round(value, 2)


def iso_passthrough(value):
    if value is None:
        return None
    return str(value)


def discover_zen_cookie_db(home_dir: Path) -> Optional[Path]:
    zen_root = home_dir / ".zen"
    if not zen_root.exists():
        return None

    for path in sorted(zen_root.glob("*/cookies.sqlite")):
        if path.is_file():
            return path

    return None


def read_claude_cookies(cookie_db: Path, context_prefix: str) -> dict[str, str]:
    with NamedTemporaryFile(delete=False) as handle:
        temp_db = Path(handle.name)

    try:
        shutil.copy2(cookie_db, temp_db)
        conn = sqlite3.connect(temp_db)
        try:
            rows = conn.execute(
                """
                SELECT name, value
                FROM moz_cookies
                WHERE host LIKE ?
                  AND originAttributes LIKE ?
                ORDER BY name
                """,
                ("%claude.ai", f"{context_prefix}%"),
            ).fetchall()
        finally:
            conn.close()
    finally:
        temp_db.unlink(missing_ok=True)

    return {name: value for name, value in rows}


def fetch_json(url: str, headers: dict[str, str]) -> dict:
    request = urllib.request.Request(url, headers=headers)
    with urllib.request.urlopen(request, timeout=20) as response:
        return json.load(response)


def load_cached_org_uuid(output_path: Path) -> Optional[str]:
    try:
        with output_path.open("r", encoding="utf-8") as handle:
            payload = json.load(handle)
    except (OSError, json.JSONDecodeError):
        return None

    org_uuid = payload.get("organization_uuid")
    if isinstance(org_uuid, str) and org_uuid:
        return org_uuid

    return None


def discover_org_uuid(base_headers: dict[str, str]) -> Optional[str]:
    bootstrap = fetch_json("https://claude.ai/api/bootstrap", base_headers)
    account = bootstrap.get("account") or {}
    memberships = account.get("memberships") or []
    for membership in memberships:
        org = membership.get("organization") or {}
        if org.get("uuid"):
            return org["uuid"]

    return None


def main():
    output_path = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("/var/lib/hass/claude_usage.json")
    home_dir = Path(os.environ.get("HOME", str(Path.home())))

    cookie_db = Path(
        os.environ.get("CLAUDE_COOKIE_DB")
        or discover_zen_cookie_db(home_dir)
        or ""
    )
    context_prefix = os.environ.get("CLAUDE_COOKIE_CONTEXT_PREFIX", "^userContextId=1")

    if not cookie_db.is_file():
        print("No claude.ai cookie database found", file=sys.stderr)
        return 1

    cookies = read_claude_cookies(cookie_db, context_prefix)
    if not cookies:
        print("No claude.ai cookies found", file=sys.stderr)
        return 1

    cookie_header = "; ".join(f"{name}={value}" for name, value in cookies.items())
    base_headers = {
        "Accept": "application/json",
        "Cookie": cookie_header,
        "Referer": "https://claude.ai/settings/usage",
        "User-Agent": "Mozilla/5.0 (X11; Linux x86_64; rv:150.0) Gecko/20100101 Firefox/150.0",
    }

    org_uuid = load_cached_org_uuid(output_path)
    if not org_uuid:
        try:
            org_uuid = discover_org_uuid(base_headers)
        except (OSError, urllib.error.HTTPError, urllib.error.URLError, json.JSONDecodeError) as e:
            print(f"Failed to fetch bootstrap: {e}", file=sys.stderr)
            return 1

    if not org_uuid:
        print("No organization UUID available for Claude usage export", file=sys.stderr)
        return 1

    try:
        usage_data = fetch_json(
            f"https://claude.ai/api/organizations/{org_uuid}/usage",
            base_headers,
        )
    except (OSError, urllib.error.HTTPError, urllib.error.URLError, json.JSONDecodeError) as e:
        if load_cached_org_uuid(output_path) == org_uuid:
            try:
                org_uuid = discover_org_uuid(base_headers)
                usage_data = fetch_json(
                    f"https://claude.ai/api/organizations/{org_uuid}/usage",
                    base_headers,
                )
            except (OSError, urllib.error.HTTPError, urllib.error.URLError, json.JSONDecodeError) as retry_error:
                print(f"Failed to fetch usage from org {org_uuid}: {retry_error}", file=sys.stderr)
                return 1
        else:
            print(f"Failed to fetch usage from org {org_uuid}: {e}", file=sys.stderr)
            return 1

    # Response shape:
    # {
    #   "five_hour": {"utilization": 78.0, "resets_at": "2026-05-17T20:40:00+00:00"},
    #   "seven_day":  {"utilization": 16.0, "resets_at": "2026-05-18T06:59:59+00:00"},
    #   ...
    # }
    five_hour = usage_data.get("five_hour") or {}
    seven_day = usage_data.get("seven_day") or {}

    if "utilization" not in five_hour or "utilization" not in seven_day:
        print(f"Unexpected usage structure. Keys: {list(usage_data.keys())}", file=sys.stderr)
        print(json.dumps(usage_data, indent=2), file=sys.stderr)
        return 1

    status = {
        "five_hour_left_percent": clamp_percent(100.0 - float(five_hour["utilization"])),
        "five_hour_resets_at": iso_passthrough(five_hour.get("resets_at")),
        "seven_day_left_percent": clamp_percent(100.0 - float(seven_day["utilization"])),
        "seven_day_resets_at": iso_passthrough(seven_day.get("resets_at")),
        "organization_uuid": org_uuid,
        "exported_at": datetime.now(timezone.utc).isoformat(),
        "source": "claude_web",
    }

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
