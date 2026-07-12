import QtQuick
import qs.services
import qs.modules.common
import qs.modules.common.widgets

Item {
    id: root
    readonly property bool showUnreadCount: Config.options.bar.indicators.notifications.showUnreadCount
    
    // Ensure the width fully covers the icon + the overhanging badge
    implicitWidth: icon.implicitWidth + (showUnreadCount ? 6 : 0)
    implicitHeight: Math.max(icon.implicitHeight, notifPing.implicitHeight)

    MaterialSymbol {
        id: icon
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: Notifications.silent ? "notifications_paused" : "notifications"
        iconSize: Appearance.font.pixelSize.larger
        color: rightSidebarButton.colText
    }

    Rectangle {
        id: notifPing
        visible: !Notifications.silent && Notifications.unread > 0
        anchors {
            left: icon.right
            leftMargin: root.showUnreadCount ? -10 : -4
            top: icon.top
            topMargin: root.showUnreadCount ? -4 : 3
        }
        radius: Appearance.rounding.full
        color: Appearance.colors.colOnLayer0
        z: 1

        implicitHeight: root.showUnreadCount ? Math.max(12, notificationCounterText.implicitHeight) : 8
        implicitWidth: root.showUnreadCount ? Math.max(implicitHeight, notificationCounterText.implicitWidth + 6) : 8

        StyledText {
            id: notificationCounterText
            visible: root.showUnreadCount
            anchors.centerIn: parent
            font.pixelSize: Appearance.font.pixelSize.smallest
            color: Appearance.colors.colLayer0
            text: Notifications.unread
        }
    }
}
