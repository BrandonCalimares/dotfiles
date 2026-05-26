import QtQuick
import Quickshell.Hyprland
import Quickshell
import "../themes"
import "../popups/power"

Item {
    id: root
    implicitWidth: Theme.barWidth
    implicitHeight: Theme.barHeight
    required property var screen
    property bool focused: mouseArea.containsMouse || (popupLoader.item ? popupLoader.item.expanded : false)

    Rectangle {
        id: rect
        anchors.fill: parent
        anchors.centerIn: parent
        color: root.focused ? Theme.red : Theme.surface0
        border.color: Theme.surface1
        border.width: root.focused ? 0 : Theme.borderWidth
        radius: Theme.innerRadius
        Behavior on color {
            ColorAnimation {
                duration: Theme.colorDuration
                easing.type: Easing.InOutQuad
            }
        }
        Text {
            text: "⏻"
            color: root.focused ? Theme.base : Theme.red
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
        sourceComponent: PowerPopUp {}
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
        name: "powermenu"
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