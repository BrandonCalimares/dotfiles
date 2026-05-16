import QtQuick
import Quickshell.Hyprland

Row {
    id: workspaceRow
    spacing: 5

    Repeater {
        model: 9

        Rectangle {
            property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
            property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
            width: isActive ? 32 : (ws || index < 2 ? Theme.barHeight - 5 : 0)
            height: Theme.barHeight - 6
            radius: 8

            Behavior on width {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }

            Text {
                anchors.centerIn: parent
                
                text: ws || index < 2 ? ws.name : ""
                color: Theme.base
                font: Theme.barFont
            }

            color: isActive ? Theme.accent : (mouseArea.containsMouse ? Theme.subtext1 : Theme.subtext0)
            MouseArea {
                id: mouseArea
                anchors.fill: parent
                onClicked: Hyprland.dispatch(`hl.dsp.focus({workspace =${index + 1}})`)
                cursorShape: isActive ? Qt.ArrowCursor : Qt.PointingHandCursor
                hoverEnabled: true
            }
        }
    }
}
