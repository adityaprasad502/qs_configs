#!/usr/bin/env python3
"""
KDE Connect D-Bus signal listener for Quickshell.
Outputs one JSON line on startup (initial state), then one JSON line
per event whenever battery, network, or reachability changes.
Also sends desktop notifications for important phone battery events.
Runs persistently — Quickshell's SplitParser reads each line as it arrives.
"""
import sys
import json
import subprocess
import dbus
import dbus.mainloop.glib
from gi.repository import GLib

dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
bus = dbus.SessionBus()

KDC = "org.kde.kdeconnect"
LOW_THRESHOLD = 20   # notify when battery drops below this while discharging
FULL_THRESHOLD = 100 # notify when battery reaches this while charging

def notify(summary, body, urgency="normal", icon="phone", app_name="Phone"):
    try:
        subprocess.Popen([
            "notify-send",
            f"--app-name={app_name}",
            f"--urgency={urgency}",
            f"--icon={icon}",
            summary,
            body
        ])
    except Exception:
        pass

def get_prop(path, iface, prop):
    try:
        obj = bus.get_object(KDC, path)
        props = dbus.Interface(obj, "org.freedesktop.DBus.Properties")
        return props.Get(iface, prop)
    except:
        return None

def emit(data):
    print(json.dumps(data), flush=True)

def get_paired_devices():
    try:
        import xml.etree.ElementTree as ET
        mgr = bus.get_object(KDC, "/modules/kdeconnect/devices")
        iface = dbus.Interface(mgr, "org.freedesktop.DBus.Introspectable")
        xml = iface.Introspect()
        root = ET.fromstring(xml)
        result = []
        for node in root.findall("node"):
            dev_id = node.get("name")
            if not dev_id:
                continue
            path = f"/modules/kdeconnect/devices/{dev_id}"
            try:
                obj = bus.get_object(KDC, path)
                props = dbus.Interface(obj, "org.freedesktop.DBus.Properties")
                if not props.Get("org.kde.kdeconnect.device", "isPaired"):
                    continue
                name = props.Get("org.kde.kdeconnect.device", "name")
                result.append((str(dev_id), str(name)))
            except:
                pass
        return result
    except:
        return []

def emit_device_state(dev_id, name):
    path = f"/modules/kdeconnect/devices/{dev_id}"
    reachable  = get_prop(path, "org.kde.kdeconnect.device", "isReachable")
    charge     = get_prop(f"{path}/battery", "org.kde.kdeconnect.device.battery", "charge")
    charging   = get_prop(f"{path}/battery", "org.kde.kdeconnect.device.battery", "isCharging")
    net_type   = get_prop(f"{path}/connectivity_report", "org.kde.kdeconnect.device.connectivity_report", "cellularNetworkType")
    net_str    = get_prop(f"{path}/connectivity_report", "org.kde.kdeconnect.device.connectivity_report", "cellularNetworkStrength")
    emit({
        "event":      "state",
        "id":         dev_id,
        "name":       name,
        "reachable":  bool(reachable),
        "charge":     int(charge)    if charge    is not None else -1,
        "charging":   bool(charging) if charging  is not None else False,
        "netType":    str(net_type)  if net_type  is not None else "",
        "netStrength":int(net_str)   if net_str   is not None else 0,
    })

def make_battery_handler(dev_id, name, state):
    """
    state dict tracks last seen values to avoid duplicate notifications.
    Keys: charge, charging, low_notified, full_notified
    """
    def handler(is_charging, charge, **kw):
        charge = int(charge)
        is_charging = bool(is_charging)
        prev_charging = state.get("charging")

        emit({"event": "battery", "id": dev_id, "charge": charge, "charging": is_charging})

        # Charging plugged in / unplugged
        if prev_charging is not None and prev_charging != is_charging:
            if is_charging:
                notify(f"Charging", f"Battery at {charge}%", urgency="low", icon="battery-caution-charging", app_name=name)
                state["low_notified"]  = False
                state["full_notified"] = False
            else:
                notify(f"Unplugged", f"Battery at {charge}%", urgency="low", icon="battery-good", app_name=name)
                state["low_notified"]  = False
                state["full_notified"] = False

        # Battery full
        if is_charging and charge >= FULL_THRESHOLD and not state.get("full_notified"):
            notify(f"Fully charged", f"Battery is at {charge}% — safe to unplug", urgency="normal", icon="battery-full-charged", app_name=name)
            state["full_notified"] = True
            state["low_notified"]  = False

        # Battery low (only while discharging)
        if not is_charging and charge < LOW_THRESHOLD and not state.get("low_notified"):
            notify(f"Battery low", f"Battery at {charge}% — please charge", urgency="critical", icon="battery-caution", app_name=name)
            state["low_notified"]  = True
            state["full_notified"] = False

        # Reset full_notified if battery drops meaningfully after unplugging
        if not is_charging and charge < (FULL_THRESHOLD - 5):
            state["full_notified"] = False

        state["charge"]   = charge
        state["charging"] = is_charging

    return handler

def make_network_handler(dev_id):
    def handler(net_type, strength, **kw):
        emit({"event": "network", "id": dev_id, "netType": str(net_type), "netStrength": int(strength)})
    return handler

def make_reachable_handler(dev_id, name, reachable_state):
    def handle(reachable, **kw):
        reachable = bool(reachable)
        prev = reachable_state.get("reachable")
        reachable_state["reachable"] = reachable
        if prev == reachable:
            return  # no change, skip duplicate notifications
        emit({"event": "reachable", "id": dev_id, "name": name, "reachable": reachable})
        if reachable:
            notify("Connected", "Phone is now reachable", urgency="low", icon="phone", app_name=name)
        else:
            notify("Disconnected", "Phone is out of range", urgency="low", icon="phone-missed", app_name=name)
    return handle

def make_properties_changed_handler(dev_id, name, reachable_state):
    """Fallback: catches isReachable changes via generic PropertiesChanged signal."""
    reachable_handler = make_reachable_handler(dev_id, name, reachable_state)
    def handle(interface, changed, invalidated, **kw):
        if "isReachable" in changed:
            reachable_handler(bool(changed["isReachable"]))
    return handle



# --- Main ---

devices = get_paired_devices()
if not devices:
    emit({"event": "nodevices"})

for dev_id, name in devices:
    path = f"/modules/kdeconnect/devices/{dev_id}"
    emit_device_state(dev_id, name)

    battery_state  = {"low_notified": False, "full_notified": False, "charging": None, "charge": -1}
    reachable_state = {"reachable": None}  # tracks last known reachability

    bus.add_signal_receiver(
        make_battery_handler(dev_id, name, battery_state),
        signal_name="refreshed",
        dbus_interface="org.kde.kdeconnect.device.battery",
        path=f"{path}/battery"
    )
    bus.add_signal_receiver(
        make_network_handler(dev_id),
        signal_name="refreshed",
        dbus_interface="org.kde.kdeconnect.device.connectivity_report",
        path=f"{path}/connectivity_report"
    )
    # Primary signal
    bus.add_signal_receiver(
        make_reachable_handler(dev_id, name, reachable_state),
        signal_name="reachableChanged",
        dbus_interface="org.kde.kdeconnect.device",
        path=path
    )
    # Fallback: generic PropertiesChanged on isReachable
    bus.add_signal_receiver(
        make_properties_changed_handler(dev_id, name, reachable_state),
        signal_name="PropertiesChanged",
        dbus_interface="org.freedesktop.DBus.Properties",
        path=path
    )

GLib.MainLoop().run()
