import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../themes"
import "../popups/music"

Item {
    id: root
    implicitWidth: Theme.barWidth
    implicitHeight: Theme.barHeight
    property bool focused: mouseArea.containsMouse || (popupLoader.item ? popupLoader.item.expanded : false)
    required property var screen

    Rectangle {
        border.color: Theme.surface1
        border.width: root.focused ? 0 : Theme.borderWidth
        radius: Theme.innerRadius
        anchors.fill: parent
        color: root.focused ? Theme.green : Theme.surface0

        Behavior on color {
            ColorAnimation {
                duration: Theme.colorDuration
                easing.type: Easing.InOutQuad
            }
        }

        Text {
            id: powerIcon
            text: ""
            color: root.focused ? Theme.base : Theme.green
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
        property int savedActiveIndex: 0

        active: false
        focus: true
        sourceComponent: MusicPopUp {}

        onLoaded: {
            popupLoader.item.activeIndex = popupLoader.savedActiveIndex;
            popupLoader.item.expanded = true;
        }
    }

    Connections {
        target: popupLoader.item
        function onOpenedChanged() {
            if (popupLoader.item && !popupLoader.item.opened) {
                popupLoader.active = false;
            }
        }

        function onActiveIndexChanged() {
            if (popupLoader.item) {
                popupLoader.savedActiveIndex = popupLoader.item.activeIndex;
            }
        }
    }

    GlobalShortcut {
        name: "musicmenu"
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
