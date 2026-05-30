import QtQuick
import Quickshell
import Quickshell.Widgets
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../../themes"

PanelWindow {
    id: root
    property bool expanded: false
    property bool opened: expanded || content.height > 0
    required property var audio

    visible: opened
    anchors.bottom: true
    exclusiveZone: 0
    margins.bottom: Theme.outerMargin * 3
    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight 
    color: "transparent"

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onEntered: closeTimer.stop()
        onExited: closeTimer.start()
    }

    Timer {
        id: closeTimer
        interval: 2000
        running: true
        repeat: false
        onTriggered: {
            root.expanded = false
        }
    }

    Connections {
        target: audio
        function onVolumeChanged() {
            if (!mouseArea.containsMouse) {
                closeTimer.restart()
            }
        }
        function onMutedChanged() {
            if (!mouseArea.containsMouse) {
                closeTimer.restart()
            }
        }
    }

    Rectangle {
        id: content
        anchors.bottom: parent.bottom 
        implicitWidth: column.implicitWidth + Theme.popupPadding * 3
        implicitHeight: column.implicitHeight + Theme.popupPadding * 3
        height: root.expanded ? implicitHeight : 0
        color: Theme.background
        radius: Theme.outerRadius
        border.color: Theme.surface0
        border.width: Theme.borderWidth
        clip: true

        Behavior on height {
            NumberAnimation {
                duration: Theme.popupDuration
                easing.type: Easing.InOutQuad
            }
        }

        ColumnLayout {
            id: column
            anchors.centerIn: parent
            spacing: Theme.popupSpacing
            implicitWidth: implicitHeight

            property string volumeIcon: {
                if (audio.muted || audio.volume === 0)
                    return "audio-volume-muted"
                else if (audio.volume < 0.33)
                    return "audio-volume-low"
                else if (audio.volume < 0.66)
                    return "audio-volume-medium"
                else
                    return "audio-volume-high"
            }

            // Audio Icon
            IconImage {
                Layout.alignment: Qt.AlignHCenter
                source: Quickshell.iconPath(column.volumeIcon)
                implicitSize: 90

                layer.enabled: true
                layer.effect: ColorOverlay {
                    color: root.audio.muted ? Theme.text : Theme.blue
                }
            }

            // Volume Bar
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: Theme.volumeBarHeight
                color: Theme.surface2
                radius: implicitHeight / 2

                MouseArea {
                    enabled: !audioTracker.node.audio.muted
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onPressed: mouse => {
                        root.audio.volume = Math.max(0, Math.min(1, mouse.x / parent.width));
                    }
                    onPositionChanged: mouse => {
                        root.audio.volume = Math.max(0, Math.min(1, mouse.x / parent.width));
                    }
                }

                Rectangle {
                    implicitWidth: parent.width * audioTracker.node.audio.volume
                    implicitHeight: Theme.volumeBarHeight
                    color: root.audio.muted ? Theme.subtext0 : Theme.blue
                    anchors.verticalCenter: parent.verticalCenter
                    radius: implicitHeight / 2

                    Rectangle {
                        implicitWidth: Theme.volumeBarHeight * 2
                        implicitHeight: Theme.volumeBarHeight * 2
                        color: Theme.text
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: parent.width - Theme.volumeBarHeight
                        radius: implicitHeight / 2
                    }
                }
            }
        }
    }
}
