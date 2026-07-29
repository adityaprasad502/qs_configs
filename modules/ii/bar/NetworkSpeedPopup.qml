import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

StyledPopup {
    id: root

    Column {
        anchors.centerIn: parent
        spacing: 8

        StyledPopupHeaderRow {
            anchors.horizontalCenter: parent.horizontalCenter
            icon: "lan"
            label: (Network.networkName && Network.networkName.length > 0) ? Network.networkName : Translation.tr("Network Traffic")
        }

        GridLayout {
            columns: 2
            rowSpacing: 5
            columnSpacing: 5
            uniformCellWidths: true

            NetworkCard {
                symbol: "arrow_downward"
                title: Translation.tr("Download")
                value: ResourceUsage.formatNetworkSpeed(ResourceUsage.networkRxSpeed)
            }
            NetworkCard {
                symbol: "arrow_upward"
                title: Translation.tr("Upload")
                value: ResourceUsage.formatNetworkSpeed(ResourceUsage.networkTxSpeed)
            }
            NetworkCard {
                symbol: "download"
                title: Translation.tr("Total Down")
                value: ResourceUsage.formatNetworkTotal(ResourceUsage.networkTotalRxBytes)
            }
            NetworkCard {
                symbol: "upload"
                title: Translation.tr("Total Up")
                value: ResourceUsage.formatNetworkTotal(ResourceUsage.networkTotalTxBytes)
            }
            NetworkCard {
                symbol: "router"
                title: Translation.tr("Local IP")
                value: Network.localIp || "---"
            }
            NetworkCard {
                symbol: Network.ethernet ? "settings_ethernet" : "wifi"
                title: Translation.tr("Type")
                value: Network.ethernet ? "Ethernet" : (Network.wifi ? "Wi-Fi" : "Offline")
            }
        }
    }
}
