import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import "../.."

ColumnLayout {
    id: root
    spacing: Theme.popupInnerSpacing
    required property string type
    required property var audioList

    PwNodeLinkTracker {
        id: audioTracker
        node: root.type === "sink" ? Pipewire.defaultAudioSink : Pipewire.defaultAudioSource
    }

    PwObjectTracker {
        id: audioSourceTracker
        objects: [audioTracker.node]
    }

    property var audio: audioTracker.node.audio

    property var audioIcon: {
        if (root.type === "sink") {
            if (root.audio.muted)
                return "";
            if (root.audio.volume < 0.33)
                return "";
            if (root.audio.volume < 0.66)
                return "";
            return "";
        } else {
            if (root.audio.muted)
                return "";
            return "";
        }
    }

    // Volume Control
    RowLayout {
        id: audioRow
        spacing: Theme.popupPadding
        Layout.topMargin: Theme.popupPadding
        Layout.bottomMargin: Theme.popupPadding

        Text {
            id: maxText
            text: "100"
            font: Theme.bigFont
            visible: false
        }

        // Audio Icon
        Item {
            implicitWidth: maxText.implicitWidth
            implicitHeight: maxText.implicitHeight

            Text {
                text: root.audioIcon
                color: Theme.text
                font: Theme.bigFont
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.audio.muted = !root.audio.muted;
                    }
                }
                anchors.centerIn: parent
            }
        }

        // Volume Bar
        Rectangle {
            implicitWidth: Theme.volumeBarWidth
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
                implicitWidth: parent.implicitWidth * audioTracker.node.audio.volume
                implicitHeight: Theme.volumeBarHeight
                color: root.audio.muted ? Theme.subtext0 : Theme.blue
                anchors.verticalCenter: parent.verticalCenter
                radius: implicitHeight / 2

                Rectangle {
                    implicitWidth: 14
                    implicitHeight: 14
                    color: Theme.text
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: parent.width - 10
                    radius: implicitHeight / 2
                }
            }
        }

        // Volume Percentage
        Item {
            implicitWidth: maxText.implicitWidth
            implicitHeight: maxText.implicitHeight

            Text {
                text: Math.trunc(root.audio.volume * 100)
                color: Theme.text
                font: Theme.bigFont
                anchors.centerIn: parent
            }
        }
    }

    // Device Name and Dropdown
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: deviceRow.implicitHeight + Theme.popupPadding + Theme.popupInnerSpacing
        color: Theme.surface0
        radius: Theme.innerRadius
        border.width: Theme.borderWidth
        border.color: Theme.surface1

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.audioList.expanded = !root.audioList.expanded;
            }
        }

        RowLayout {
            id: deviceRow
            anchors.fill: parent
            anchors.margins: Theme.popupPadding
            spacing: Theme.popupPadding

            Text {
                text: audioTracker.node.nickname
                color: Theme.subtext1
                font: Theme.barFont
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Item {
                implicitWidth: maxText.implicitWidth
                implicitHeight: maxText.implicitHeight

                Text {
                    id: dropdownIcon
                    text: !root.audioList.expanded ? "" : ""
                    font: Theme.bigFont
                    color: Theme.text
                    anchors.centerIn: parent
                }
            }
        }
    }
}
