#!/run/current-system/sw/bin/python3

import sys
import os
import json
import time
import subprocess
import urllib.request
import urllib.error

HA_URL = "http://localhost:8123"
ENTITY = "climate.ar"
TOKEN_FILE = os.path.expanduser("~/.config/secrets/ha_token")

STEP = 1
MIN_TEMP = 18
MAX_TEMP = 30
PENDING_FILE = os.path.expanduser("~/.cache/waybar_air_pending.json")
SEND_DELAY = 3
PENDING_TTL = 15
CONFIRM_TTL = 20


def get_token():
    with open(TOKEN_FILE) as f:
        return f.read().strip()


HEADERS = {"Authorization": f"Bearer {get_token()}", "Content-Type": "application/json"}


def get_state():
    return request_json("GET", f"/api/states/{ENTITY}")


def set_temperature(temp):
    request_json(
        "POST",
        "/api/services/climate/set_temperature",
        {"entity_id": ENTITY, "temperature": temp},
    )


def set_mode(mode):
    request_json(
        "POST",
        "/api/services/climate/set_hvac_mode",
        {"entity_id": ENTITY, "hvac_mode": mode},
    )


def request_json(method, path, payload=None):
    url = f"{HA_URL}{path}"
    data = None
    headers = dict(HEADERS)
    if payload is not None:
        data = json.dumps(payload).encode("utf-8")
        headers["Content-Type"] = "application/json"
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            body = resp.read()
    except (urllib.error.URLError, urllib.error.HTTPError, TimeoutError, ValueError):
        return None
    if not body:
        return None
    try:
        return json.loads(body)
    except json.JSONDecodeError:
        return None


def read_pending():
    try:
        with open(PENDING_FILE) as f:
            data = json.load(f)
        temp = data.get("temperature")
        ts = data.get("ts")
        sent = data.get("sent", False)
        sent_ts = data.get("sent_ts")
        if isinstance(temp, (int, float)) and isinstance(ts, (int, float)):
            sent_ts_val = None
            if isinstance(sent_ts, (int, float)):
                sent_ts_val = float(sent_ts)
            return {
                "temperature": float(temp),
                "ts": float(ts),
                "sent": bool(sent),
                "sent_ts": sent_ts_val,
            }
    except FileNotFoundError:
        return None
    except (OSError, ValueError, json.JSONDecodeError):
        return None
    return None


def write_pending(temp, sent=False, sent_ts=None, ts=None):
    os.makedirs(os.path.dirname(PENDING_FILE), exist_ok=True)
    if ts is None:
        ts = time.time()
    payload = {"temperature": float(temp), "ts": float(ts), "sent": bool(sent)}
    if sent_ts is not None:
        payload["sent_ts"] = float(sent_ts)
    with open(PENDING_FILE, "w") as f:
        json.dump(payload, f)


def clear_pending():
    try:
        os.remove(PENDING_FILE)
    except FileNotFoundError:
        pass
    except OSError:
        pass


def display():
    state = get_state()
    if not state:
        print(json.dumps({"text": "-- - ", "class": "off"}))
        return
    mode = state["state"]
    attrs = state["attributes"]

    current = attrs.get("current_temperature")
    target = attrs.get("temperature")
    pending = read_pending()
    if pending is not None:
        pending_temp = pending["temperature"]
        pending_ts = pending["ts"]
        now = time.time()
        show_pending = now - pending_ts <= PENDING_TTL
        if pending["sent"] and pending.get("sent_ts") is not None:
            show_pending = show_pending or (now - pending["sent_ts"] <= CONFIRM_TTL)
        if target == pending_temp:
            clear_pending()
        elif show_pending:
            target = pending_temp
        else:
            clear_pending()

    if current is None:
        current = 0

    if mode == "off":
        print(
            json.dumps(
                {
                    "text": f"<span font_family='FiraCode Nerd Font Mono' rise='-1500' size='140%'></span> {current:.0f} - ",
                    "class": "off",
                }
            )
        )
        return

    mode_map = {
        "cool": ("", "cool"),
        "heat": ("", "heat"),
        "dry": ("", "dry"),
        "fan_only": ("󰈐", "fan"),
    }
    icon, css_class = mode_map.get(mode, ("", "other"))

    if target is None:
        target_text = f"{current:.0f}"
    else:
        target_text = f"{target:.0f}"
    print(
        json.dumps(
            {
                "text": f"<span font_family='FiraCode Nerd Font Mono' rise='-1500' size='140%'>{icon}</span> {target_text} - ",
                "class": css_class,
            }
        )
    )


def change(delta):
    state = get_state()
    if state:
        attrs = state["attributes"]
        current_target = attrs.get("temperature")
        if current_target is None:
            current_target = attrs.get("current_temperature")
    else:
        current_target = None
    pending = read_pending()
    if pending is not None:
        current_target = pending["temperature"]
    if current_target is None:
        return

    new_temp = max(MIN_TEMP, min(MAX_TEMP, current_target + delta))
    write_pending(new_temp, sent=False)
    subprocess.Popen(
        [sys.executable, os.path.abspath(__file__), "flush"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def flush_pending():
    pending = read_pending()
    if pending is None:
        return
    ts = pending["ts"]
    remaining = SEND_DELAY - (time.time() - ts)
    if remaining > 0:
        time.sleep(remaining)
    pending = read_pending()
    if pending is None:
        return
    temp2 = pending["temperature"]
    ts2 = pending["ts"]
    if ts2 != ts:
        return
    set_temperature(temp2)
    write_pending(temp2, sent=True, sent_ts=time.time(), ts=ts2)


def main():
    if len(sys.argv) == 1:
        display()
        return

    cmd = sys.argv[1]

    if cmd == "heat":
        set_mode("heat")
    elif cmd == "cool":
        set_mode("cool")
    elif cmd == "off":
        set_mode("off")
    elif cmd == "up":
        change(STEP)
    elif cmd == "down":
        change(-STEP)
    elif cmd == "flush":
        flush_pending()


if __name__ == "__main__":
    main()
