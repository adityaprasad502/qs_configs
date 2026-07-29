import QtQuick
import QtQuick.Layouts

import qs.modules.common
import qs.modules.common.widgets

Rectangle {
    id: root
    radius: Appearance.rounding.small
    color: Appearance.colors.colSurfaceContainerHigh
    property alias title: title.text
    property alias value: value.text
    property alias symbol: symbol.text

    TextMetrics {
        id: valueMetrics
        text: "192.168.888.888"
        font.pixelSize: Appearance.font.pixelSize.small
        font.weight: Font.DemiBold
    }

    implicitWidth: Math.max(columnLayout.implicitWidth, valueMetrics.advanceWidth) + 14 * 2
    implicitHeight: columnLayout.implicitHeight + 10 * 2
    Layout.fillWidth: true

    ColumnLayout {
        id: columnLayout
        anchors.centerIn: parent
        spacing: 2

        MaterialSymbol {
            id: symbol
            Layout.alignment: Qt.AlignHCenter
            fill: 0
            iconSize: Appearance.font.pixelSize.larger
            color: Appearance.colors.colOnSurfaceVariant
        }

        StyledText {
            id: title
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: Appearance.font.pixelSize.smaller
            color: Appearance.colors.colSubtext
        }

        StyledText {
            id: value
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: Appearance.font.pixelSize.small
            font.weight: Font.DemiBold
            color: Appearance.colors.colOnSurfaceVariant
        }
    }
}
