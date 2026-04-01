#!/run/current-system/sw/bin/python3

import requests
import sys
import os
import json

HA_URL = "http://localhost:8123"
ENTITY = "climate.ar"
TOKEN_FILE = os.path.expanduser("~/.config/secrets/ha_token")

STEP = 1
MIN_TEMP = 18
MAX_TEMP = 30


def get_token():
    with open(TOKEN_FILE) as f:
        return f.read().strip()


HEADERS = {"Authorization": f"Bearer {get_token()}", "Content-Type": "application/json"}


def get_state():
    r = requests.get(f"{HA_URL}/api/states/{ENTITY}", headers=HEADERS)
    return r.json()


def set_temperature(temp):
    requests.post(
        f"{HA_URL}/api/services/climate/set_temperature",
        headers=HEADERS,
        json={"entity_id": ENTITY, "temperature": temp},
    )


def set_mode(mode):
    requests.post(
        f"{HA_URL}/api/services/climate/set_hvac_mode",
        headers=HEADERS,
        json={"entity_id": ENTITY, "hvac_mode": mode},
    )


def display():
    state = get_state()
    mode = state["state"]
    attrs = state["attributes"]

    current = attrs["current_temperature"]
    target = attrs.get("temperature")

    if mode == "off":
        print(json.dumps({"text": f"{current:.0f} - ", "class": "off"}))
        return

    if mode == "cool":
        icon = ""
        css_class = "cool"
    elif mode == "heat":
        icon = ""
        css_class = "heat"
    else:
        icon = ""
        css_class = "other"

    print(
        json.dumps(
            {
                "text": f"<span font_family='FiraCode Nerd Font Mono' rise='-1500' size='140%'>{icon}</span> {target:.0f} - ",
                "class": css_class,
            }
        )
    )


def change(delta):
    state = get_state()
    attrs = state["attributes"]
    current_target = attrs["temperature"]

    new_temp = max(MIN_TEMP, min(MAX_TEMP, current_target + delta))
    set_temperature(new_temp)


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


if __name__ == "__main__":
    main()
