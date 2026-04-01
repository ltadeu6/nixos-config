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
PENDING_TEMP_FILE = os.path.expanduser("~/.cache/waybar_air_pending.json")
PENDING_MODE_FILE = os.path.expanduser("~/.cache/waybar_air_pending_mode.json")
PENDING_FAN_FILE = os.path.expanduser("~/.cache/waybar_air_pending_fan.json")
LAST_MODE_FILE = os.path.expanduser("~/.cache/waybar_air_last_mode.json")
LAST_TARGET_FILE = os.path.expanduser("~/.cache/waybar_air_last_target.json")
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


def set_fan_mode(mode):
    request_json(
        "POST",
        "/api/services/climate/set_fan_mode",
        {"entity_id": ENTITY, "fan_mode": mode},
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


def read_pending(path):
    try:
        with open(path) as f:
            data = json.load(f)
        value = data.get("value")
        ts = data.get("ts")
        sent = data.get("sent", False)
        sent_ts = data.get("sent_ts")
        if isinstance(value, (int, float, str)) and isinstance(ts, (int, float)):
            sent_ts_val = None
            if isinstance(sent_ts, (int, float)):
                sent_ts_val = float(sent_ts)
            return {
                "value": value,
                "ts": float(ts),
                "sent": bool(sent),
                "sent_ts": sent_ts_val,
            }
    except FileNotFoundError:
        return None
    except (OSError, ValueError, json.JSONDecodeError):
        return None
    return None


def write_pending(path, value, sent=False, sent_ts=None, ts=None):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    if ts is None:
        ts = time.time()
    payload = {"value": value, "ts": float(ts), "sent": bool(sent)}
    if sent_ts is not None:
        payload["sent_ts"] = float(sent_ts)
    with open(path, "w") as f:
        json.dump(payload, f)


def clear_pending(path):
    try:
        os.remove(path)
    except FileNotFoundError:
        pass
    except OSError:
        pass


def read_last_mode():
    try:
        with open(LAST_MODE_FILE) as f:
            data = json.load(f)
        mode = data.get("mode")
        if isinstance(mode, str):
            return mode
    except FileNotFoundError:
        return None
    except (OSError, ValueError, json.JSONDecodeError):
        return None
    return None


def write_last_mode(mode):
    os.makedirs(os.path.dirname(LAST_MODE_FILE), exist_ok=True)
    with open(LAST_MODE_FILE, "w") as f:
        json.dump({"mode": mode}, f)


def read_last_target():
    try:
        with open(LAST_TARGET_FILE) as f:
            data = json.load(f)
        value = data.get("value")
        if isinstance(value, (int, float)):
            return float(value)
    except FileNotFoundError:
        return None
    except (OSError, ValueError, json.JSONDecodeError):
        return None
    return None


def write_last_target(value):
    os.makedirs(os.path.dirname(LAST_TARGET_FILE), exist_ok=True)
    with open(LAST_TARGET_FILE, "w") as f:
        json.dump({"value": float(value)}, f)


def pending_active(pending):
    now = time.time()
    show = now - pending["ts"] <= PENDING_TTL
    if pending["sent"] and pending.get("sent_ts") is not None:
        show = show or (now - pending["sent_ts"] <= CONFIRM_TTL)
    return show


def display():
    state = get_state()
    if not state:
        print(json.dumps({"text": "-- - ", "class": "off"}))
        return
    mode = state["state"]
    attrs = state["attributes"]

    current = attrs.get("current_temperature")
    target = attrs.get("temperature")
    pending_temp = read_pending(PENDING_TEMP_FILE)
    if pending_temp is not None:
        pending_temp_value = float(pending_temp["value"])
        if target == pending_temp_value:
            clear_pending(PENDING_TEMP_FILE)
        elif pending_active(pending_temp):
            target = pending_temp_value
        else:
            clear_pending(PENDING_TEMP_FILE)
    if target is not None:
        write_last_target(target)

    pending_mode = read_pending(PENDING_MODE_FILE)
    if pending_mode is not None:
        pending_mode_value = str(pending_mode["value"])
        if mode == pending_mode_value:
            clear_pending(PENDING_MODE_FILE)
        elif pending_active(pending_mode):
            mode = pending_mode_value
        else:
            clear_pending(PENDING_MODE_FILE)

    pending_fan = read_pending(PENDING_FAN_FILE)
    if pending_fan is not None:
        current_fan = attrs.get("fan_mode")
        if current_fan == pending_fan["value"]:
            clear_pending(PENDING_FAN_FILE)
        elif not pending_active(pending_fan):
            clear_pending(PENDING_FAN_FILE)

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
    write_last_mode(mode)

    mode_map = {
        "cool": ("", "cool"),
        "heat": ("", "heat"),
        "dry": ("", "dry"),
        "fan_only": ("󰈐", "fan"),
    }
    icon, css_class = mode_map.get(mode, ("", "other"))

    if mode in ("fan_only", "dry"):
        target_text = f"{current:.0f}"
    elif target is None:
        target_text = f"{current:.0f}"
    else:
        target_text = f"{target:.0f}"
    fan_value = attrs.get("fan_mode")
    if pending_fan is not None and pending_active(pending_fan):
        fan_value = pending_fan["value"]
    fan_text = ""
    if fan_value is not None:
        fan_text = f"<span size='60%' rise='-1500'>{fan_value}</span>"
    print(
        json.dumps(
            {
                "text": f"<span font_family='FiraCode Nerd Font Mono' rise='-1500' size='140%'>{icon}</span>{fan_text} {target_text} - ",
                "class": css_class,
            }
        )
    )


def change(delta):
    state = get_state()
    if state and state.get("state") == "fan_only":
        change_fan(delta)
        return
    if state:
        attrs = state["attributes"]
        current_target = attrs.get("temperature")
        if current_target is None:
            current_target = attrs.get("current_temperature")
    else:
        current_target = None
    pending = read_pending(PENDING_TEMP_FILE)
    if pending is not None and pending_active(pending):
        current_target = float(pending["value"])
    elif pending is not None:
        clear_pending(PENDING_TEMP_FILE)
    if current_target is None:
        current_target = read_last_target()
    if current_target is None and state:
        current_target = state["attributes"].get("current_temperature")
    if current_target is None:
        return

    new_temp = max(MIN_TEMP, min(MAX_TEMP, current_target + delta))
    write_pending(PENDING_TEMP_FILE, float(new_temp), sent=False)
    subprocess.Popen(
        [sys.executable, os.path.abspath(__file__), "flush"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def change_fan(delta):
    state = get_state()
    if not state:
        return
    attrs = state["attributes"]
    modes = attrs.get("fan_modes")
    current = attrs.get("fan_mode")
    if not modes or current is None:
        return
    pending = read_pending(PENDING_FAN_FILE)
    if pending is not None and pending_active(pending):
        current = pending["value"]
    elif pending is not None:
        clear_pending(PENDING_FAN_FILE)
    try:
        idx = modes.index(current)
    except ValueError:
        idx = 0
    new_idx = (idx + delta) % len(modes)
    if new_idx != idx:
        write_pending(PENDING_FAN_FILE, modes[new_idx], sent=False)
        subprocess.Popen(
            [sys.executable, os.path.abspath(__file__), "flush-fan"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )


def cycle_mode():
    state = get_state()
    if not state:
        return
    attrs = state["attributes"]
    modes = attrs.get("hvac_modes") or []
    modes = [m for m in modes if m != "off"]
    if not modes:
        return
    current = state.get("state")
    pending = read_pending(PENDING_MODE_FILE)
    if pending is not None and pending_active(pending):
        current = pending["value"]
    elif pending is not None:
        clear_pending(PENDING_MODE_FILE)
    try:
        idx = modes.index(current)
    except ValueError:
        idx = -1
    new_idx = (idx + 1) % len(modes)
    new_mode = modes[new_idx]
    write_pending(PENDING_MODE_FILE, new_mode, sent=False)
    subprocess.Popen(
        [sys.executable, os.path.abspath(__file__), "flush-mode"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def toggle_mode():
    state = get_state()
    if not state:
        return
    attrs = state["attributes"]
    modes = attrs.get("hvac_modes") or []
    current = state.get("state")
    pending = read_pending(PENDING_MODE_FILE)
    if pending is not None and pending_active(pending):
        current = pending["value"]
    elif pending is not None:
        clear_pending(PENDING_MODE_FILE)
    if current == "off":
        last = read_last_mode()
        if last in modes and last != "off":
            write_pending(PENDING_MODE_FILE, last, sent=False)
            subprocess.Popen(
                [sys.executable, os.path.abspath(__file__), "flush-mode"],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
            return
        for m in modes:
            if m != "off":
                write_pending(PENDING_MODE_FILE, m, sent=False)
                subprocess.Popen(
                    [sys.executable, os.path.abspath(__file__), "flush-mode"],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
                return
    else:
        write_pending(PENDING_MODE_FILE, "off", sent=False)
        subprocess.Popen(
            [sys.executable, os.path.abspath(__file__), "flush-mode"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )


def cycle_fan():
    change_fan(1)


def flush_pending():
    pending = read_pending(PENDING_TEMP_FILE)
    if pending is None:
        return
    ts = pending["ts"]
    remaining = SEND_DELAY - (time.time() - ts)
    if remaining > 0:
        time.sleep(remaining)
    pending = read_pending(PENDING_TEMP_FILE)
    if pending is None:
        return
    temp2 = float(pending["value"])
    ts2 = pending["ts"]
    if ts2 != ts:
        return
    set_temperature(temp2)
    write_pending(PENDING_TEMP_FILE, float(temp2), sent=True, sent_ts=time.time(), ts=ts2)


def flush_mode():
    pending = read_pending(PENDING_MODE_FILE)
    if pending is None:
        return
    ts = pending["ts"]
    remaining = SEND_DELAY - (time.time() - ts)
    if remaining > 0:
        time.sleep(remaining)
    pending = read_pending(PENDING_MODE_FILE)
    if pending is None:
        return
    mode2 = str(pending["value"])
    ts2 = pending["ts"]
    if ts2 != ts:
        return
    set_mode(mode2)
    write_pending(PENDING_MODE_FILE, mode2, sent=True, sent_ts=time.time(), ts=ts2)
    subprocess.Popen(
        [sys.executable, os.path.abspath(__file__), "flush"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def flush_fan():
    pending = read_pending(PENDING_FAN_FILE)
    if pending is None:
        return
    ts = pending["ts"]
    remaining = SEND_DELAY - (time.time() - ts)
    if remaining > 0:
        time.sleep(remaining)
    pending = read_pending(PENDING_FAN_FILE)
    if pending is None:
        return
    fan2 = str(pending["value"])
    ts2 = pending["ts"]
    if ts2 != ts:
        return
    set_fan_mode(fan2)
    write_pending(PENDING_FAN_FILE, fan2, sent=True, sent_ts=time.time(), ts=ts2)


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
    elif cmd == "fan-up":
        change_fan(STEP)
    elif cmd == "fan-down":
        change_fan(-STEP)
    elif cmd == "cycle-mode":
        cycle_mode()
    elif cmd == "toggle":
        toggle_mode()
    elif cmd == "cycle-fan":
        cycle_fan()
    elif cmd == "flush":
        flush_pending()
    elif cmd == "flush-mode":
        flush_mode()
    elif cmd == "flush-fan":
        flush_fan()


if __name__ == "__main__":
    main()
