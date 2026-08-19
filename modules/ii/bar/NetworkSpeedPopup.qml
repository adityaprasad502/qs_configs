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

            StatCard {
                symbol: "arrow_downward"
                title: Translation.tr("Download")
                value: ResourceUsage.formatNetworkSpeed(ResourceUsage.networkRxSpeed)
            }
            StatCard {
                symbol: "arrow_upward"
                title: Translation.tr("Upload")
                value: ResourceUsage.formatNetworkSpeed(ResourceUsage.networkTxSpeed)
            }
            StatCard {
                symbol: "download"
                title: Translation.tr("Total Down")
                value: ResourceUsage.formatNetworkTotal(ResourceUsage.networkTotalRxBytes)
            }
            StatCard {
                symbol: "upload"
                title: Translation.tr("Total Up")
                value: ResourceUsage.formatNetworkTotal(ResourceUsage.networkTotalTxBytes)
            }
            StatCard {
                symbol: Network.ethernet ? "settings_ethernet" : "wifi"
                title: Translation.tr("Type")
                value: Network.ethernet ? "Ethernet" : (Network.wifi ? "Wi-Fi" : "Offline")
            }
            StatCard {
                symbol: "router"
                title: Translation.tr("Interface")
                value: Network.interfaceName || "---"
            }
            // Wi-Fi-only: band and signal
            StatCard {
                visible: Network.wifi && !Network.ethernet
                symbol: "wifi_tethering"
                title: Translation.tr("Band")
                value: {
                    const freq = Network.active?.frequency ?? 0;
                    if (freq <= 0) return "---";
                    if (freq >= 5945) return "6 GHz";
                    if (freq >= 5000) return "5 GHz";
                    return "2.4 GHz";
                }
            }
            StatCard {
                visible: Network.wifi && !Network.ethernet
                symbol: "signal_cellular_alt"
                title: Translation.tr("Signal")
                value: Network.active ? (Network.active.strength + "%") : "---"
            }
        }
    }
}
