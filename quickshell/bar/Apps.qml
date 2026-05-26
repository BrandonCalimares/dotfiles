import QtQuick
import Quickshell.Hyprland
import "../themes"
import "../popups/apps"

Item {
    id: root
    implicitWidth: Theme.barWidth
    implicitHeight: Theme.barHeight
    property bool focused: mouseArea.containsMouse || (popupLoader.item ? popupLoader.item.expanded : false)
    required property var screen

    Rectangle {
        id: rect
        border.color: Theme.surface1
        border.width: root.focused ? 0 : Theme.borderWidth
        anchors.fill: parent
        color: root.focused ? Theme.sapphire : Theme.surface0
        radius: Theme.innerRadius

        Behavior on color {
            ColorAnimation {
                duration: Theme.colorDuration
                easing.type: Easing.InOutQuad
            }
        }

        Text {
            id: powerIcon
            text: "󰣇"
            color: root.focused ? Theme.base : Theme.sapphire
            anchors.centerIn: parent
            font: Theme.barFont

            Behavior on color {
                ColorAnimation {
                    duration: Theme.colorDuration
                    easing.type: Easing.InOutQuad
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
        sourceComponent: AppsPopUp {}
        onLoaded: popupLoader.item.expanded = true
    }

    Connections {
        target: popupLoader.item
        function onOpenedChanged() {
            if (popupLoader.item && !popupLoader.item.opened) {
                popupLoader.active = false
            }
        }
    }

    GlobalShortcut {
        name: "launcher"
        onPressed: {
            if (Hyprland.focusedMonitor.name == root.screen.name) {
                if (popupLoader.item) {
                    popupLoader.item.expanded = !popupLoader.item.expanded
                } else {
                    popupLoader.active = true
                }
            }
        }
    }
    
}
