import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

StyledPopup {
    id: root
    // Time formatter helper
    function formatTime(seconds) {
        var h = Math.floor(seconds / 3600);
        var m = Math.floor((seconds % 3600) / 60);
        if (h > 0)
            return `${h}h ${m}m`;
        else
            return `${m}m`;
    }

    Column {
        anchors.centerIn: parent
        spacing: 8

        // Header
        StyledPopupHeaderRow {
            anchors.horizontalCenter: parent.horizontalCenter
            icon: Battery.isCharging ? "battery_charging_full" : "battery_full_alt"
            label: Translation.tr("Battery")
        }

        GridLayout {
            columns: 2
            rowSpacing: 5
            columnSpacing: 5
            uniformCellWidths: true

            StatCard {
                symbol: "percent"
                title: Translation.tr("Level")
                value: Math.round(Battery.percentage * 100) + "%"
            }

            StatCard {
                symbol: "heart_check"
                title: Translation.tr("Health")
                value: `${Battery.health.toFixed(1)}%`
            }

            StatCard {
                symbol: "bolt"
                title: {
                    if (Battery.chargeState == 4) return Translation.tr("Power");
                    return Battery.isCharging ? Translation.tr("Charging") : Translation.tr("Discharging");
                }
                value: Battery.chargeState == 4 ? "AC Power" : `${Battery.energyRate.toFixed(2)} W`
            }

            StatCard {
                symbol: "schedule"
                title: {
                    if (Battery.chargeState == 4) return Translation.tr("Time");
                    return Battery.isCharging ? Translation.tr("Time to Full") : Translation.tr("Time to Empty");
                }
                value: {
                    if (Battery.chargeState == 4) return "---";
                    let t = Battery.isCharging ? Battery.timeToFull : Battery.timeToEmpty;
                    if (t <= 0) return Translation.tr("Calculating...");
                    return root.formatTime(t);
                }
            }
        }

        // Phone section — only if there are paired KDE Connect devices
        Repeater {
            model: KdeConnect.devices
            delegate: Column {
                spacing: 6
                anchors.horizontalCenter: parent?.horizontalCenter

                // Divider + phone header
                StyledPopupHeaderRow {
                    anchors.horizontalCenter: parent.horizontalCenter
                    icon: modelData.reachable ? "smartphone" : "phonelink_erase"
                    label: modelData.name
                }

                GridLayout {
                    columns: 2
                    rowSpacing: 5
                    columnSpacing: 5
                    uniformCellWidths: true
                    visible: modelData.reachable

                    StatCard {
                        symbol: modelData.isCharging ? "battery_charging_full" : "battery_std"
                        title: modelData.isCharging
                            ? (modelData.charge >= 100 ? "Full" : "Charging")
                            : "Battery"
                        value: modelData.charge >= 0 ? (modelData.charge + "%") : "?"
                    }

                    StatCard {
                        symbol: modelData.netStrength > 0 ? "signal_cellular_alt" : "signal_cellular_off"
                        title: "Network"
                        value: {
                            if (modelData.netStrength <= 0) return "No Signal";
                            if (!modelData.networkType || modelData.networkType === "Unknown") return "Standby";
                            return modelData.networkType;
                        }
                    }
                }

                StyledText {
                    visible: !modelData.reachable
                    text: "Not reachable"
                    color: Appearance.colors.colSubtext
                    font.pixelSize: Appearance.font.pixelSize.small
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
}
