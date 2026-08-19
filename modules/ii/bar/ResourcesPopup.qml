import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

StyledPopup {
    id: root

    // Helper function to format KB to GB
    function formatKB(kb) {
        if (kb === 0) return "0 GB";
        return (kb / (1024 * 1024)).toFixed(1) + " GB";
    }

    Column {
        anchors.centerIn: parent
        spacing: 8

        StyledPopupHeaderRow {
            anchors.horizontalCenter: parent.horizontalCenter
            icon: "memory"
            label: Translation.tr("System Resources")
        }

        GridLayout {
            columns: 3
            rowSpacing: 5
            columnSpacing: 5
            uniformCellWidths: true

            // RAM
            StatCard {
                symbol: "clock_loader_60"
                title: Translation.tr("RAM Used")
                value: root.formatKB(ResourceUsage.memoryUsed)
            }
            StatCard {
                symbol: "check_circle"
                title: Translation.tr("RAM Free")
                value: root.formatKB(ResourceUsage.memoryFree)
            }
            StatCard {
                symbol: "empty_dashboard"
                title: Translation.tr("RAM Total")
                value: root.formatKB(ResourceUsage.memoryTotal)
            }

            // Swap
            StatCard {
                visible: ResourceUsage.swapTotal > 0
                symbol: "clock_loader_60"
                title: Translation.tr("Swap Used")
                value: root.formatKB(ResourceUsage.swapUsed)
            }
            StatCard {
                visible: ResourceUsage.swapTotal > 0
                symbol: "check_circle"
                title: Translation.tr("Swap Free")
                value: root.formatKB(ResourceUsage.swapFree)
            }
            StatCard {
                visible: ResourceUsage.swapTotal > 0
                symbol: "empty_dashboard"
                title: Translation.tr("Swap Total")
                value: root.formatKB(ResourceUsage.swapTotal)
            }

            // CPU
            StatCard {
                symbol: "bolt"
                title: Translation.tr("CPU Load")
                value: `${Math.round(ResourceUsage.cpuUsage * 100)}%`
            }
            StatCard {
                symbol: "speed"
                title: Translation.tr("CPU Freq")
                value: ResourceUsage.cpuCurrentFreqString
            }
            StatCard {
                symbol: "thermostat"
                title: Translation.tr("CPU Temp")
                value: ResourceUsage.cpuTempString
            }
        }
    }
}
