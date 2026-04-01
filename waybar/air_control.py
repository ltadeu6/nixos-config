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
SEND_DELAY = 3
PENDING_TTL = 15
CONFIRM_TTL = 20

CACHE_DIR = os.path.expanduser("~/.cache")
STATE_FILE = os.path.join(CACHE_DIR, "waybar_air_state.json")


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


PENDING = {
    "temp": {
        "key": "temp",
        "cast": float,
        "setter": set_temperature,
        "after": None,
    },
    "mode": {
        "key": "mode",
        "cast": str,
        "setter": set_mode,
        "after": lambda: schedule("flush"),
    },
    "fan": {
        "key": "fan",
        "cast": str,
        "setter": set_fan_mode,
        "after": None,
    },
}


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


def load_json(path):
    try:
        with open(path) as f:
            return json.load(f)
    except FileNotFoundError:
        return None
    except (OSError, ValueError, json.JSONDecodeError):
        return None


def save_json(path, payload):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as f:
        json.dump(payload, f)


def load_state():
    data = load_json(STATE_FILE)
    if not isinstance(data, dict):
        return {}
    return data


def save_state(state):
    save_json(STATE_FILE, state)


def get_state_section(state, key):
    section = state.get(key)
    if isinstance(section, dict):
        return section
    return {}


def read_pending(key):
    state = load_state()
    pending_map = get_state_section(state, "pending")
    data = pending_map.get(key)
    if not isinstance(data, dict):
        return None
    value = data.get("value")
    ts = data.get("ts")
    sent = data.get("sent", False)
    sent_ts = data.get("sent_ts")
    if not isinstance(value, (int, float, str)) or not isinstance(ts, (int, float)):
        return None
    sent_ts_val = None
    if isinstance(sent_ts, (int, float)):
        sent_ts_val = float(sent_ts)
    return {
        "value": value,
        "ts": float(ts),
        "sent": bool(sent),
        "sent_ts": sent_ts_val,
    }


def write_pending(key, value, sent=False, sent_ts=None, ts=None):
    if ts is None:
        ts = time.time()
    payload = {"value": value, "ts": float(ts), "sent": bool(sent)}
    if sent_ts is not None:
        payload["sent_ts"] = float(sent_ts)
    state = load_state()
    pending_map = get_state_section(state, "pending")
    pending_map[key] = payload
    state["pending"] = pending_map
    save_state(state)


def clear_pending(key):
    state = load_state()
    pending_map = get_state_section(state, "pending")
    if key in pending_map:
        pending_map.pop(key, None)
        state["pending"] = pending_map
        save_state(state)


def read_last_mode():
    state = load_state()
    last_map = get_state_section(state, "last")
    mode = last_map.get("mode")
    if isinstance(mode, str):
        return mode
    return None


def write_last_mode(mode):
    state = load_state()
    last_map = get_state_section(state, "last")
    last_map["mode"] = mode
    state["last"] = last_map
    save_state(state)


def read_last_target():
    state = load_state()
    last_map = get_state_section(state, "last")
    value = last_map.get("target")
    if isinstance(value, (int, float)):
        return float(value)
    return None


def write_last_target(value):
    state = load_state()
    last_map = get_state_section(state, "last")
    last_map["target"] = float(value)
    state["last"] = last_map
    save_state(state)


def pending_active(pending):
    now = time.time()
    show = now - pending["ts"] <= PENDING_TTL
    if pending["sent"] and pending.get("sent_ts") is not None:
        show = show or (now - pending["sent_ts"] <= CONFIRM_TTL)
    return show


def mode_change_pending(state=None):
    pending = read_pending(PENDING["mode"]["key"])
    if not pending:
        return False
    if state and state.get("state") == pending.get("value"):
        return False
    return bool(pending_active(pending))


_MISSING = object()


def pending_value(key, cast=None, current_value=_MISSING, preserve_if_mode_pending=False):
    pending = read_pending(key)
    if pending is None:
        return (current_value, None) if current_value is not _MISSING else None
    value = cast(pending["value"]) if cast else pending["value"]
    if current_value is not _MISSING:
        if current_value == value:
            if preserve_if_mode_pending and mode_change_pending():
                return value, pending
            clear_pending(key)
            return current_value, None
        if pending_active(pending):
            return value, pending
        clear_pending(key)
        return current_value, None
    if pending_active(pending):
        return value
    clear_pending(key)
    return None


def pending_value_with_current(key, cast, current_value, preserve_if_mode_pending=False):
    result = pending_value(
        key,
        cast,
        current_value=current_value,
        preserve_if_mode_pending=preserve_if_mode_pending,
    )
    if result is None:
        return current_value, None
    return result


def get_effective_mode(state):
    if state:
        mode = state.get("state")
    else:
        mode = None
    pending = pending_value(PENDING["mode"]["key"], PENDING["mode"]["cast"])
    return pending if pending is not None else mode


def clamp(value, low, high):
    return max(low, min(high, value))


def get_state_attrs():
    state = get_state()
    if not state:
        return None, {}
    return state, state.get("attributes", {})


def resolve_current_target(state):
    current_target = None
    if state:
        attrs = state["attributes"]
        current_target = attrs.get("temperature")
        if current_target is None:
            current_target = attrs.get("current_temperature")
    pending_target = pending_value(PENDING["temp"]["key"], PENDING["temp"]["cast"])
    if pending_target is not None:
        current_target = pending_target
    if current_target is None:
        current_target = read_last_target()
    if current_target is None and state:
        current_target = state["attributes"].get("current_temperature")
    return current_target


def preserve_settings_on_mode_change(state):
    target = resolve_current_target(state)
    if isinstance(target, (int, float)) and read_pending(PENDING["temp"]["key"]) is None:
        write_pending(PENDING["temp"]["key"], float(target), sent=False)
        schedule("flush")
    if state:
        fan_mode = state["attributes"].get("fan_mode")
        if isinstance(fan_mode, str) and read_pending(PENDING["fan"]["key"]) is None:
            write_pending(PENDING["fan"]["key"], str(fan_mode), sent=False)
            schedule("flush-fan")


def flush_pending_generic(
    key, cast, setter, after=None, defer_cmd=None, state=None, force=False
):
    if not force and key != PENDING["mode"]["key"] and mode_change_pending(state):
        if defer_cmd is not None:
            schedule(defer_cmd)
        return False
    pending = read_pending(key)
    if pending is None:
        return False
    ts = pending["ts"]
    remaining = SEND_DELAY - (time.time() - ts)
    if remaining > 0:
        time.sleep(remaining)
    pending = read_pending(key)
    if pending is None:
        return False
    if pending["ts"] != ts:
        return False
    value = cast(pending["value"])
    setter(value)
    write_pending(key, value, sent=True, sent_ts=time.time(), ts=ts)
    if after is not None:
        after()
    return True


def schedule(cmd):
    subprocess.Popen(
        [sys.executable, os.path.abspath(__file__), cmd],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def display():
    state, attrs = get_state_attrs()
    if not state:
        print(json.dumps({"text": "-- - ", "class": "off"}))
        return
    mode = state["state"]

    current = attrs.get("current_temperature")
    target = attrs.get("temperature")
    target, _ = pending_value_with_current(
        PENDING["temp"]["key"],
        PENDING["temp"]["cast"],
        target,
        preserve_if_mode_pending=True,
    )
    if target is not None:
        write_last_target(target)

    mode, _ = pending_value_with_current(
        PENDING["mode"]["key"], PENDING["mode"]["cast"], mode
    )

    fan_mode = attrs.get("fan_mode")
    fan_mode, _ = pending_value_with_current(
        PENDING["fan"]["key"],
        PENDING["fan"]["cast"],
        fan_mode,
        preserve_if_mode_pending=True,
    )

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
    mode_key = mode if isinstance(mode, str) else "unknown"
    icon, css_class = mode_map.get(mode_key, ("", "other"))

    if mode in ("fan_only", "dry"):
        target_text = f"{current:.0f}"
    elif target is None:
        target_text = f"{current:.0f}"
    else:
        target_text = f"{target:.0f}"
    fan_text = ""
    if fan_mode is not None:
        fan_text = f"<span size='60%' rise='-1500'>{fan_mode}</span>"
    print(
        json.dumps(
            {
                "text": f"<span font_family='FiraCode Nerd Font Mono' rise='-1500' size='140%'>{icon}</span>{fan_text} {target_text} - ",
                "class": css_class,
            }
        )
    )


def change(delta):
    state, _ = get_state_attrs()
    effective_mode = get_effective_mode(state)
    if effective_mode in ("fan_only", "dry"):
        change_fan(delta)
        return
    current_target = resolve_current_target(state)
    if current_target is None:
        return

    new_temp = clamp(current_target + delta, MIN_TEMP, MAX_TEMP)
    write_pending(PENDING["temp"]["key"], float(new_temp), sent=False)
    schedule("flush")


def change_fan(delta):
    state, attrs = get_state_attrs()
    if not state:
        return
    modes = attrs.get("fan_modes")
    current = attrs.get("fan_mode")
    if not modes or current is None:
        return
    pending_fan = pending_value(PENDING["fan"]["key"], PENDING["fan"]["cast"])
    if pending_fan is not None:
        current = pending_fan
    try:
        idx = modes.index(current)
    except ValueError:
        idx = 0
    new_idx = (idx + delta) % len(modes)
    if new_idx != idx:
        write_pending(PENDING["fan"]["key"], modes[new_idx], sent=False)
        schedule("flush-fan")


def cycle_mode():
    state, attrs = get_state_attrs()
    if not state:
        return
    modes = attrs.get("hvac_modes") or []
    modes = [m for m in modes if m != "off"]
    if not modes:
        return
    current = get_effective_mode(state)
    try:
        idx = modes.index(current)
    except ValueError:
        idx = -1
    new_idx = (idx + 1) % len(modes)
    new_mode = modes[new_idx]
    write_pending(PENDING["mode"]["key"], new_mode, sent=False)
    preserve_settings_on_mode_change(state)
    schedule("flush-mode")


def toggle_mode():
    state, attrs = get_state_attrs()
    if not state:
        return
    modes = attrs.get("hvac_modes") or []
    current = get_effective_mode(state)
    if current == "off":
        last = read_last_mode()
        if last in modes and last != "off":
            write_pending(PENDING["mode"]["key"], last, sent=False)
            preserve_settings_on_mode_change(state)
            schedule("flush-mode")
            return
        for m in modes:
            if m != "off":
                write_pending(PENDING["mode"]["key"], m, sent=False)
                preserve_settings_on_mode_change(state)
                schedule("flush-mode")
                return
    else:
        clear_pending(PENDING["temp"]["key"])
        clear_pending(PENDING["fan"]["key"])
        set_mode("off")
        write_pending(
            PENDING["mode"]["key"], "off", sent=True, sent_ts=time.time(), ts=time.time()
        )


def cycle_fan():
    change_fan(1)


def flush_pending():
    meta = PENDING["temp"]
    state, _ = get_state_attrs()
    flush_pending_generic(
        meta["key"],
        meta["cast"],
        meta["setter"],
        meta["after"],
        defer_cmd="flush",
        state=state,
    )


def flush_mode():
    meta = PENDING["mode"]
    sent = flush_pending_generic(
        meta["key"], meta["cast"], meta["setter"], meta["after"]
    )
    if not sent:
        return
    temp_meta = PENDING["temp"]
    flush_pending_generic(
        temp_meta["key"],
        temp_meta["cast"],
        temp_meta["setter"],
        temp_meta["after"],
        force=True,
    )
    fan_meta = PENDING["fan"]
    flush_pending_generic(
        fan_meta["key"],
        fan_meta["cast"],
        fan_meta["setter"],
        fan_meta["after"],
        force=True,
    )


def flush_fan():
    meta = PENDING["fan"]
    state, _ = get_state_attrs()
    flush_pending_generic(
        meta["key"],
        meta["cast"],
        meta["setter"],
        meta["after"],
        defer_cmd="flush-fan",
        state=state,
    )


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
