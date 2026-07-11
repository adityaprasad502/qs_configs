import qs.modules.common
import qs.modules.common.widgets
import qs.services
import qs
import qs.modules.common.functions

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Hyprland

Item {
    id: root
    property bool borderless: Config.options.bar.borderless
    readonly property MprisPlayer activePlayer: MprisController.activePlayer
    readonly property string cleanedTitle: StringUtils.cleanMusicTitle(activePlayer?.trackTitle) || Translation.tr("No media")

    property list<real> visualizerPoints: []

    onWidthChanged: {
        if (root.width > 100) {
            GlobalStates.topBarMediaWidth = root.width;
        }
    }
    Component.onCompleted: {
        if (root.width > 100) {
            GlobalStates.topBarMediaWidth = root.width;
        }
    }

    // State helpers
    readonly property bool isPlaying: activePlayer?.playbackState === MprisPlaybackState.Playing
    readonly property bool isPaused: activePlayer != null && !root.isPlaying
    readonly property bool hasLyrics: root.isPlaying && LyricsService.currentLyricLine && LyricsService.currentLyricLine.length > 0

    Process {
        id: cavaProc
        running: root.isPlaying
        onRunningChanged: {
            if (!cavaProc.running) {
                root.visualizerPoints = [];
            }
        }
        command: ["cava", "-p", `${FileUtils.trimFileProtocol(Directories.scriptPath)}/cava/raw_output_config.txt`]
        stdout: SplitParser {
            onRead: data => {
                let points = data.split(";").map(p => parseFloat(p.trim())).filter(p => !isNaN(p));
                root.visualizerPoints = points;
            }
        }
    }


    implicitHeight: Appearance.sizes.barHeight

    Timer {
        running: root.isPlaying
        interval: 1000
        repeat: true
        onTriggered: activePlayer.positionChanged()
    }

    // Background pill
    Rectangle {
        id: bgContainer
        anchors.fill: parent
        anchors.topMargin: 4
        anchors.bottomMargin: 4
        radius: Appearance.rounding.full
        color: {
            if (!activePlayer) return ColorUtils.transparentize(Appearance.colors.colLayer1, 0.7);
            if (hoverArea.containsMouse) return ColorUtils.transparentize(Appearance.colors.colLayer1, 0.25);
            return ColorUtils.transparentize(Appearance.colors.colLayer1, 0.45);
        }

        border.width: root.isPlaying ? 1 : 0
        border.color: ColorUtils.transparentize(Appearance.colors.colOutlineVariant, 0.4)
        Behavior on border.width { NumberAnimation { duration: 250 } }

        Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }

        // Clipped visualizer container
        Item {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            anchors.topMargin: 2
            anchors.bottomMargin: 2
            clip: true

            WaveVisualizer {
                id: visualizerBg
                anchors.fill: parent
                layer.enabled: false
                visible: opacity > 0
                opacity: (root.isPlaying && !GlobalStates.mediaControlsOpen && root.visualizerPoints.length > 0) ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                live: root.isPlaying && !GlobalStates.mediaControlsOpen
                points: root.visualizerPoints
                maxVisualizerValue: 1000
                smoothing: 2
                color: ColorUtils.transparentize(Appearance.colors.colPrimary, 0.45)
            }
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.MiddleButton | Qt.BackButton | Qt.ForwardButton | Qt.RightButton | Qt.LeftButton
        onDoubleClicked: (event) => {
            if (event.button === Qt.LeftButton) {
                GlobalStates.sidebarLeftOpen = !GlobalStates.sidebarLeftOpen;
            }
        }
        onPressed: (event) => {
            if (event.button === Qt.MiddleButton) {
                if (activePlayer) activePlayer.togglePlaying();
            } else if (event.button === Qt.BackButton) {
                if (activePlayer) activePlayer.previous();
            } else if (event.button === Qt.ForwardButton || event.button === Qt.RightButton) {
                if (activePlayer) activePlayer.next();
            } else if (event.button === Qt.LeftButton) {
                if (activePlayer) GlobalStates.mediaControlsOpen = !GlobalStates.mediaControlsOpen;
                else GlobalStates.sidebarLeftOpen = !GlobalStates.sidebarLeftOpen;
            }
        }
    }

    RowLayout {
        id: rowLayout
        spacing: 10
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 14

        // Contextual icon: quote sparkle / play-pause progress / paused
        Item {
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: 20
            implicitHeight: 20

            // Quote icon (no player active)
            MaterialSymbol {
                id: quoteIcon
                anchors.centerIn: parent
                fill: 1
                text: "auto_awesome"
                iconSize: Appearance.font.pixelSize.normal
                color: Appearance.colors.colSubtext
                visible: !activePlayer
                opacity: visible ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
            }

            // Circular progress with play/pause (player active)
            ClippedFilledCircularProgress {
                id: mediaCircProg
                anchors.centerIn: parent
                visible: activePlayer != null
                opacity: visible ? 1 : 0
                lineWidth: Appearance.rounding.unsharpen
                value: activePlayer?.position / activePlayer?.length
                implicitSize: 20
                colPrimary: Appearance.colors.colOnSecondaryContainer
                enableAnimation: false

                Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

                Item {
                    anchors.centerIn: parent
                    width: mediaCircProg.implicitSize
                    height: mediaCircProg.implicitSize

                    MaterialSymbol {
                        anchors.centerIn: parent
                        fill: 1
                        text: root.isPlaying ? "pause" : "play_arrow"
                        iconSize: Appearance.font.pixelSize.normal
                        color: Appearance.m3colors.m3onSecondaryContainer
                    }
                }
            }
        }

        StyledText {
            id: topBarMusicText
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            elide: Text.ElideRight
            textFormat: Text.PlainText
            color: Appearance.colors.colOnLayer1
            text: {
                if (!activePlayer) {
                    return "Everything happens for a reason";
                }
                if (root.hasLyrics) {
                    return LyricsService.currentLyricLine;
                }
                return `${cleanedTitle}${activePlayer?.trackArtist ? ' • ' + activePlayer.trackArtist : ''}`;
            }
        }

        StyledText {
            id: trackTimeText
            visible: activePlayer != null && (activePlayer?.length || 0) > 0
            Layout.alignment: Qt.AlignVCenter
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.colors.colSubtext
            text: {
                let pos = Math.max(0, activePlayer?.position || 0);
                let len = Math.max(0, activePlayer?.length || 0);
                let rem = Math.max(0, len - pos);
                return `-${StringUtils.friendlyTimeForSeconds(rem)}`;
            }
        }
    }
}
