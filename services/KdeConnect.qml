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
                            id:               data.id,
                            name:             data.name,
                            reachable:        data.reachable,
                            charge:           data.charge,
                            isCharging:       data.charging,
                            networkType:      data.netType,
                            netStrength:      data.netStrength,
                            chargeRate:       0,
                            lastBatteryTime:  Date.now(),
                            sessionStartCharge: data.charge,
                            sessionStartTime: Date.now(),
                            timeReachedFull:  data.charge >= 100 ? Date.now() : null,
                        });
                        return;
                    }
                    if (data.event === "battery") {
                        const prev = root.devices.find(d => d.id === data.id)
                        const now = Date.now()
                        let chargeRate = prev?.chargeRate ?? 0
                        if (prev?.lastBatteryTime) {
                            const deltaSec = (now - prev.lastBatteryTime) / 1000
                            const deltaCharge = data.charge - prev.charge
                            // Only update rate if ≥30s elapsed, same charge direction, and charge actually moved
                            if (deltaSec >= 30 && deltaCharge !== 0 && (prev.isCharging === data.charging)) {
                                chargeRate = (deltaCharge / deltaSec) * 60 // %/min
                            }
                        }
                        
                        let timeReachedFull = prev?.timeReachedFull ?? null;
                        if (data.charge >= 100 && (prev?.charge ?? 0) < 100) {
                            timeReachedFull = now;
                        } else if (data.charge < 100) {
                            timeReachedFull = null;
                        }

                        const chargingFlipped = prev && (prev.isCharging !== data.charging);

                        root.updateDevice({
                            id:              data.id,
                            charge:          data.charge,
                            isCharging:      data.charging,
                            chargeRate:      chargingFlipped ? 0 : chargeRate,
                            lastBatteryTime: now,
                            sessionStartCharge: chargingFlipped ? data.charge : (prev?.sessionStartCharge ?? data.charge),
                            sessionStartTime:   chargingFlipped ? now : (prev?.sessionStartTime ?? now),
                            timeReachedFull:    timeReachedFull,
                            // Peak/low only updated from positive (charging) measurements
                            peakChargeRate: chargingFlipped ? 0 : (chargeRate > 0
                                ? Math.max(chargeRate, prev?.peakChargeRate ?? 0)
                                : (prev?.peakChargeRate ?? 0)),
                            minChargeRate: chargingFlipped ? 0 : (chargeRate > 0
                                ? (prev?.minChargeRate > 0
                                    ? Math.min(chargeRate, prev.minChargeRate)
                                    : chargeRate)
                                : (prev?.minChargeRate ?? 0)),
                        });
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
