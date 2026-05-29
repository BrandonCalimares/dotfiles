import QtQuick
import Quickshell.Services.Pipewire
import Quickshell.Hyprland
import QtQuick.Layouts
import "../themes"
import "../popups/volume"

Item {
    id: root
    implicitWidth: root.audio && root.audio.muted ? Theme.barWidth : maxSizeRow.implicitWidth + Theme.barPadding * 2
    implicitHeight: Theme.barHeight
    property bool focused: mouseArea.containsMouse || (popupLoader.item ? popupLoader.item.expanded : false)
    required property var screen

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Theme.widthDuration
            easing.type: Easing.InOutQuad
        }
    }

    // Audio Sink Tracker
    PwNodeLinkTracker {
        id: audioTracker
        node: Pipewire.defaultAudioSink
    }

    PwObjectTracker {
        id: audioSinkTracker
        objects: [audioTracker.node]
    }

    property var audio: audioTracker.node ? audioTracker.node.audio : null

    Rectangle {
        anchors.fill: parent
        color: root.focused ? Theme.blue : Theme.surface0
        radius: Theme.innerRadius
        border.color: Theme.surface1
        border.width: root.focused ? 0 : Theme.borderWidth

        Behavior on color {
            ColorAnimation {
                duration: Theme.colorDuration
                easing.type: Easing.InOutQuad
            }
        }

        RowLayout {
            id: maxSizeRow
            spacing: Theme.barSpacing

            Text {
                text: ""
                font: Theme.barFont
            }

            Text {
                text: "100%"
                font: Theme.barFont
            }
            visible: false
        }

        RowLayout {
            spacing: Theme.barSpacing
            anchors.centerIn: parent

            Text {
                text: {
                    if (root.audio && root.audio.muted)
                        return "";
                    if (root.audio && root.audio.volume < 0.33)
                        return "";
                    if (root.audio && root.audio.volume < 0.66)
                        return "";
                    return "";
                }

                color: root.focused ? Theme.base : Theme.blue
                font: Theme.barFont

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.colorDuration
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            Text {
                text: {
                    if (root.audio && root.audio.muted)
                        return "";
                    if (root.audio)
                        return Math.trunc(root.audio.volume * 100) + "%";
                    return "";
                }

                color: root.focused ? Theme.base : Theme.blue
                font: Theme.barFont
                visible: root.audio ? !root.audio.muted : false

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.colorDuration
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: popupLoader.active = true
        }
    }

    Loader {
        id: popupLoader
        active: false
        focus: true
        sourceComponent: VolumePopUp {}
        onLoaded: popupLoader.item.expanded = true
    }

    Connections {
        target: popupLoader.item
        function onOpenedChanged() {
            if (popupLoader.item && !popupLoader.item.opened) {
                popupLoader.active = false;
            }
        }
    }

    Connections {
        target: root.audio
        enabled: root.audio != null

        function onVolumeChanged() {
            if (!popupLoader.active && Hyprland.focusedMonitor.name == root.screen.name) {
                osdLoader.active = true;
            }
        }

        function onMutedChanged() {
            if (!popupLoader.active && Hyprland.focusedMonitor.name == root.screen.name) {
                osdLoader.active = true;
            }
        }
    }

    Loader {
        id: osdLoader
        active: false
        focus: true
        sourceComponent: VolumeOSD {
            screen: root.screen
            audio: root.audio
        }
        onLoaded: osdLoader.item.expanded = true
    }

    Connections {
        target: osdLoader.item
        function onOpenedChanged() {
            if (osdLoader.item && !osdLoader.item.opened) {
                osdLoader.active = false;
            }
        }
    }
}
