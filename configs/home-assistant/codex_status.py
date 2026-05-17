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


def iso_from_epoch(value):
    if value is None:
        return None
    return datetime.fromtimestamp(float(value), tz=timezone.utc).isoformat()


def clamp_percent(value):
    value = max(0.0, min(100.0, float(value)))
    return round(value, 2)


def discover_zen_cookie_db(home_dir: Path) -> Optional[Path]:
    zen_root = home_dir / ".zen"
    if not zen_root.exists():
        return None

    for path in sorted(zen_root.glob("*/cookies.sqlite")):
        if path.is_file():
            return path

    return None


def read_chatgpt_cookies(cookie_db: Path, context_prefix: str) -> dict[str, str]:
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
                ("%chatgpt.com", f"{context_prefix}%"),
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


def build_web_status(home_dir: Path):
    cookie_db = Path(
        os.environ.get("CHATGPT_COOKIE_DB")
        or discover_zen_cookie_db(home_dir)
        or ""
    )
    context_prefix = os.environ.get("CHATGPT_COOKIE_CONTEXT_PREFIX", "^userContextId=1")

    if not cookie_db.is_file():
        return None

    cookies = read_chatgpt_cookies(cookie_db, context_prefix)
    if not cookies:
        return None

    cookie_header = "; ".join(f"{name}={value}" for name, value in cookies.items())
    base_headers = {
        "Accept": "application/json",
        "Cookie": cookie_header,
        "Referer": "https://chatgpt.com/codex/cloud/settings/analytics",
        "User-Agent": "Mozilla/5.0 (X11; Linux x86_64; rv:150.0) Gecko/20100101 Firefox/150.0",
    }

    try:
        session_data = fetch_json("https://chatgpt.com/api/auth/session", base_headers)
    except (OSError, sqlite3.Error, urllib.error.HTTPError, urllib.error.URLError, json.JSONDecodeError):
        return None

    access_token = session_data.get("accessToken")
    if not access_token:
        return None

    wham_headers = {
        **base_headers,
        "Accept": "application/json, text/plain, */*",
        "Authorization": f"Bearer {access_token}",
        "Origin": "https://chatgpt.com",
    }

    try:
        usage_data = fetch_json("https://chatgpt.com/backend-api/wham/usage", wham_headers)
    except (OSError, urllib.error.HTTPError, urllib.error.URLError, json.JSONDecodeError):
        return None

    rate_limit = usage_data.get("rate_limit") or {}
    primary = rate_limit.get("primary_window") or {}
    secondary = rate_limit.get("secondary_window") or {}

    if "used_percent" not in primary or "used_percent" not in secondary:
        return None

    return {
        "plan_type": usage_data.get("plan_type"),
        "five_hour_left_percent": clamp_percent(100.0 - float(primary["used_percent"])),
        "five_hour_resets_at": iso_from_epoch(primary.get("reset_at")),
        "weekly_left_percent": clamp_percent(100.0 - float(secondary["used_percent"])),
        "weekly_resets_at": iso_from_epoch(secondary.get("reset_at")),
        "exported_at": datetime.now(timezone.utc).isoformat(),
        "source": "chatgpt_web",
        "source_file": str(cookie_db),
    }


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
    home_dir = Path(os.environ.get("HOME", str(Path.home())))
    session_root = Path(os.environ.get("CODEX_SESSION_ROOT", str(home_dir / ".codex" / "sessions")))

    status = build_web_status(home_dir) or extract_status(session_root)
    if status is None:
        print(
            f"No Codex web usage data or token_count event found for {home_dir}",
            file=sys.stderr,
        )
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
