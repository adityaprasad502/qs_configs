import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

StyledPopup {
    id: root
    property var phone: null

    Column {
        anchors.centerIn: parent
        spacing: 8

        StyledPopupHeaderRow {
            anchors.horizontalCenter: parent.horizontalCenter
            icon: root.phone?.reachable ? "smartphone" : "phonelink_erase"
            label: root.phone?.name ?? ""
        }

        GridLayout {
            columns: 2
            rowSpacing: 5
            columnSpacing: 5
            uniformCellWidths: true
            visible: root.phone?.reachable ?? false

            // Row 1: Current Live State
            StatCard {
                symbol: root.phone?.isCharging ? "battery_charging_full" : "battery_std"
                title: root.phone?.isCharging
                    ? (root.phone?.charge >= 100 ? "Full" : "Charging")
                    : "Battery"
                value: (root.phone?.charge ?? -1) >= 0 ? (root.phone.charge + "%") : "?"
            }

            StatCard {
                symbol: {
                    const bars = ["signal_cellular_0_bar", "signal_cellular_1_bar",
                                  "signal_cellular_2_bar", "signal_cellular_3_bar",
                                  "signal_cellular_4_bar"]
                    return bars[Math.max(0, Math.min(4, root.phone?.netStrength ?? 0))]
                }
                title: "Network"
                value: {
                    if ((root.phone?.netStrength ?? 0) <= 0) return "No Signal"
                    if (!root.phone?.networkType || root.phone.networkType === "Unknown") return "Standby"
                    return root.phone.networkType
                }
            }

            // Row 2: Session Context (How long, how much)
            StatCard {
                symbol: "link"
                title: Translation.tr("Connected")
                value: {
                    void(DateTime.clock.date)
                    const secs = (Date.now() - (root.phone?.sessionStartTime ?? Date.now())) / 1000
                    const h = Math.floor(secs / 3600)
                    const m = Math.floor((secs % 3600) / 60)
                    return h > 0 ? `${h}h ${m}m` : `${m}m`
                }
            }

            StatCard {
                symbol: "history"
                title: Translation.tr("This Session")
                value: {
                    const delta = (root.phone?.charge ?? 0) - (root.phone?.sessionStartCharge ?? root.phone?.charge ?? 0)
                    return (delta > 0 ? "+" : "") + delta + "%"
                }
            }

            // Row 3: Current Estimates & Pace (Hidden when discharging)
            StatCard {
                visible: root.phone?.isCharging ?? false
                symbol: "avg_pace"
                title: Translation.tr("Avg Rate")
                value: {
                    void(DateTime.clock.date)
                    const mins = (Date.now() - (root.phone?.sessionStartTime ?? Date.now())) / 60000
                    const delta = (root.phone?.charge ?? 0) - (root.phone?.sessionStartCharge ?? root.phone?.charge ?? 0)
                    if (mins < 1) return "---"
                    const avg = delta / mins
                    return (avg > 0 ? "+" : "") + avg.toFixed(1) + "%/min"
                }
            }

            StatCard {
                visible: root.phone?.isCharging ?? false
                symbol: root.phone?.isCharging
                    ? ((root.phone?.charge ?? 0) >= 100 ? "task_alt" : "schedule")
                    : "timelapse"
                title: root.phone?.isCharging
                    ? ((root.phone?.charge ?? 0) >= 100 ? Translation.tr("Full For") : Translation.tr("Time to Full"))
                    : Translation.tr("Time to Empty")
                value: {
                    if (root.phone?.isCharging && (root.phone?.charge ?? 0) >= 100 && root.phone?.timeReachedFull) {
                        void(DateTime.clock.date) // Refresh every minute
                        const secs = (Date.now() - root.phone.timeReachedFull) / 1000
                        const h = Math.floor(secs / 3600)
                        const m = Math.floor((secs % 3600) / 60)
                        return h > 0 ? `${h}h ${m}m` : `${m}m`
                    }

                    const rate = Math.abs(root.phone?.chargeRate ?? 0)
                    if (rate < 0.05) return "---"
                    const remaining = root.phone?.isCharging
                        ? (100 - (root.phone?.charge ?? 0))
                        : (root.phone?.charge ?? 0)
                    const mins = Math.round(remaining / rate)
                    if (mins <= 0) return "---"
                    const h = Math.floor(mins / 60)
                    const m = mins % 60
                    return h > 0 ? `${h}h ${m}m` : `${m}m`
                }
            }

            // Row 4: Session Extremes (Hidden when discharging)
            StatCard {
                visible: root.phone?.isCharging ?? false
                symbol: "trending_up"
                title: Translation.tr("Peak Rate")
                value: {
                    const peak = root.phone?.peakChargeRate ?? 0
                    if (peak < 0.05) return "---"
                    return "+" + peak.toFixed(1) + "%/min"
                }
            }

            StatCard {
                visible: root.phone?.isCharging ?? false
                symbol: "trending_down"
                title: Translation.tr("Low Rate")
                value: {
                    const low = root.phone?.minChargeRate ?? 0
                    if (low < 0.05) return "---"
                    return "+" + low.toFixed(1) + "%/min"
                }
            }
        }

        StyledText {
            visible: !(root.phone?.reachable ?? false)
            text: "Not reachable"
            color: Appearance.colors.colSubtext
            font.pixelSize: Appearance.font.pixelSize.small
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
