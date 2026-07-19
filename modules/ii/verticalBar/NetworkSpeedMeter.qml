import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import qs.modules.ii.bar as Bar

MouseArea {
    id: root
    implicitHeight: columnLayout.implicitHeight
    implicitWidth: columnLayout.implicitWidth
    hoverEnabled: !Config.options.bar.tooltips.clickToShow

    TextMetrics {
        id: speedTextMetrics
        text: "88.8 MB/s"
        font.pixelSize: Appearance.font.pixelSize.smallest
    }

    ColumnLayout {
        id: columnLayout
        spacing: 4
        anchors.fill: parent

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 2
            MaterialSymbol {
                text: "arrow_downward"
                iconSize: Appearance.font.pixelSize.smaller
                color: ResourceUsage.networkRxSpeed > 1024 ? Appearance.colors.colPrimary : Appearance.colors.colSubtext
            }
            Item {
                implicitWidth: speedTextMetrics.width
                implicitHeight: speedTextMetrics.height
                StyledText {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: Appearance.font.pixelSize.smallest
                    text: ResourceUsage.formatNetworkSpeed(ResourceUsage.networkRxSpeed)
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 2
            MaterialSymbol {
                text: "arrow_upward"
                iconSize: Appearance.font.pixelSize.smaller
                color: ResourceUsage.networkTxSpeed > 1024 ? Appearance.colors.colPrimary : Appearance.colors.colSubtext
            }
            Item {
                implicitWidth: speedTextMetrics.width
                implicitHeight: speedTextMetrics.height
                StyledText {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: Appearance.font.pixelSize.smallest
                    text: ResourceUsage.formatNetworkSpeed(ResourceUsage.networkTxSpeed)
                }
            }
        }
    }

    Bar.NetworkSpeedPopup {
        hoverTarget: root
    }
}
