import QtQuick
import Quickshell.Io
import Quickshell.Hyprland
import "components/keyboard"

Item {
    implicitWidth: powerIcon.implicitWidth + Theme.barPadding * 2
    implicitHeight: Theme.barHeight
    property bool focused: mouseArea.containsMouse || popup.expanded

    Rectangle {
        id: rect
        border.color: Theme.surface1
        border.width: focused ? 0 : Theme.borderWidth
        anchors.fill: parent
        color: focused ? Theme.lavender : Theme.surface0
        radius: Theme.innerRadius

        Behavior on color {
            ColorAnimation {
                duration: Theme.colorDuration
                easing.type: Easing.InOutQuad
            }
        }

        Process {
            id: kbLayout
            command: ["sh", "-c", "hyprctl devices -j | jq -rc '{layouts:.keyboards[1].layout,index:.keyboards[1].active_layout_index}'"]
            running: true

            property int active: 0
            property var layouts: []
            property string layout: "??"

            stdout: SplitParser {
                onRead: data => {
                    const obj = JSON.parse(data)
                    const newLayouts = obj.layouts.split(",").map(s => s.trim())
                    if (newLayouts.join(",") !== kbLayout.layouts.join(",")) {
                        kbLayout.layouts = newLayouts
                    }
                    kbLayout.active = obj.index
                    kbLayout.layout = kbLayout.layouts[obj.index].slice(0, 2) ?? "??"
                }
            }
        }

        Connections {
            target: Hyprland
            function onRawEvent(event) {
                if (event.name === "activelayout") {
                    kbLayout.running = true;
                }
            }
        }

        Text {
            id: powerIcon
            text: "  " + kbLayout.layout.toUpperCase()
            color: focused ? Theme.base : Theme.lavender
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
            onClicked: popup.expanded = !popup.expanded
        }
    }

    KeyboardPopUp {
        id: popup
        layouts: kbLayout.layouts
        active: kbLayout.active
    }
}
