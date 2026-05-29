import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import QtQuick.Layouts
import "../../themes"

PanelWindow {
    id: root
    property bool expanded: false
    property bool opened: expanded || content.width > 0
    required property var audio

    visible: opened
    anchors.right: true
    exclusiveZone: 0
    margins.top: Theme.outerMargin / 2
    margins.right: Theme.outerMargin * 2
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
        anchors.right: parent.right 
        implicitWidth: column.implicitWidth + Theme.popupPadding * 3
        implicitHeight: column.implicitHeight + Theme.popupPadding * 3
        width: root.expanded ? implicitWidth : 0
        color: Theme.background
        radius: Theme.outerRadius
        border.color: Theme.surface0
        border.width: Theme.borderWidth
        clip: true

        Behavior on width {
            NumberAnimation {
                duration: Theme.popupDuration
                easing.type: Easing.InOutQuad
            }
        }

        ColumnLayout {
            id: column
            anchors.centerIn: parent
            spacing: Theme.popupSpacing

            Text {
                id: maxText
                text: "100"
                font: Theme.barFont
                visible: false
            }

            Rectangle {
                implicitWidth: Theme.barFont.pixelSize
                implicitHeight: Theme.volumeBarWidth
                Layout.alignment: Qt.AlignHCenter
                color: Theme.surface1
                radius: Theme.innerRadius

                MouseArea {
                    enabled: !audioTracker.node.audio.muted
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onPressed: mouse => {
                        root.audio.volume = Math.max(0, Math.min(1, (parent.height - mouse.y) / parent.height));
                    }
                    onPositionChanged: mouse => {
                        root.audio.volume = Math.max(0, Math.min(1, (parent.height - mouse.y) / parent.height));
                    }
                    onPressAndHold: mouse => {
                        closeTimer.stop()
                    }
                }

                Rectangle {
                    implicitWidth: parent.width
                    implicitHeight: parent.implicitHeight * root.audio.volume
                    color: root.audio.muted ? Theme.subtext0 : Theme.blue
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    radius: Theme.innerRadius
                }
            }
            
            Item {
                implicitWidth: maxText.implicitWidth
                implicitHeight: maxText.implicitHeight
                Layout.alignment: Qt.AlignHCenter

                Text {
                    anchors.centerIn: parent
                    text: audio && audio.muted ? "" : Math.trunc(audio.volume * 100)
                    font: Theme.barFont
                    color: Theme.text
                }
            }
        }
    }
}
