import QtQuick
import Quickshell.Hyprland
import "../themes"

Row {
    id: workspaceRow
    spacing: Theme.barSpacing

    Repeater {
        model: 9

        Rectangle {
            property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
            property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
            implicitWidth: isActive ? Theme.barWidth : (ws ? Theme.barHeight - 5 : 0)
            implicitHeight: Theme.barHeight - Theme.barPadding
            radius: Theme.innerRadius

            Behavior on implicitWidth {
                NumberAnimation {
                    duration: Theme.widthDuration
                    easing.type: Easing.InOutQuad
                }
            }

            Text {
                anchors.centerIn: parent
                text: ws ? index + 1 : ""
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
