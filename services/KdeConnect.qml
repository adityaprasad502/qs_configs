pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    // List of device objects: { id, name, reachable, charge, isCharging, networkType, netStrength }
    property var devices: []
    property bool anyReachable: {
        for (let d of devices) { if (d.reachable) return true; }
        return false;
    }

    function findPhone(deviceId) {
        Quickshell.execDetached(["kdeconnect-cli", "-d", deviceId, "--ring"]);
    }

    function updateDevice(data) {
        let list = devices.slice();
        let idx = list.findIndex(d => d.id === data.id);
        if (idx === -1) {
            // New device — insert it
            list.push(data);
        } else {
            // Merge only changed fields
            list[idx] = Object.assign({}, list[idx], data);
        }
        devices = list;
    }

    Process {
        id: listenerProc
        running: true
        command: ["python3", Quickshell.shellPath("scripts/kdeconnect-listen.py")]

        stdout: SplitParser {
            onRead: line => {
                try {
                    let data = JSON.parse(line);
                    if (data.event === "nodevices") {
                        root.devices = [];
                        return;
                    }
                    if (data.event === "state") {
                        root.updateDevice({
                            id:         data.id,
                            name:       data.name,
                            reachable:  data.reachable,
                            charge:     data.charge,
                            isCharging: data.charging,
                            networkType: data.netType,
                            netStrength: data.netStrength
                        });
                        return;
                    }
                    if (data.event === "battery") {
                        root.updateDevice({ id: data.id, charge: data.charge, isCharging: data.charging });
                        return;
                    }
                    if (data.event === "network") {
                        root.updateDevice({ id: data.id, networkType: data.netType, netStrength: data.netStrength });
                        return;
                    }
                    if (data.event === "reachable") {
                        root.updateDevice({ id: data.id, name: data.name, reachable: data.reachable });
                        return;
                    }
                } catch (e) {}
            }
        }

        // Auto-restart if the script exits unexpectedly
        onExited: {
            if (running === false) {
                restartTimer.start();
            }
        }
    }

    Timer {
        id: restartTimer
        interval: 5000
        onTriggered: listenerProc.running = true
    }
}
