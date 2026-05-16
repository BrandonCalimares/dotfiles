import QtQuick
import Quickshell.Io
import "components/internet"

Item {
    id: root
    implicitWidth: Theme.barWidth
    implicitHeight: Theme.barHeight
    property bool focused: mouseArea.containsMouse || popup.expanded

    Rectangle {
        id: rect
        border.color: Theme.surface1
        border.width: root.focused ? 0 : Theme.borderWidth
        anchors.fill: parent
        color: root.focused ? (netCheck.state === "up" ? Theme.mauve : Theme.red) : Theme.surface0
        radius: Theme.innerRadius

        Behavior on color {
            ColorAnimation {
                duration: Theme.colorDuration
                easing.type: Easing.InOutQuad
            }
        }

        Process {
            id: netCheck
            command: ["cat", "/sys/class/net/enp8s0/operstate"]
            running: true
            property string state: "down"

            stdout: SplitParser {
                onRead: data => netCheck.state = data.trim()
            }
        }

        Timer {
            interval: 5000
            running: true
            repeat: true
            onTriggered: netCheck.running = true
        }

        Text {
            id: networkIcon
            text: netCheck.state === "up" ? "󰍹" : "󰶐"
            color: root.focused ? Theme.base : (netCheck.state === "up" ? Theme.mauve : Theme.red)
            anchors.verticalCenter: parent.verticalCenter
            font: Theme.barFont
            anchors.centerIn: parent

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

    InternetPopUp {
        id: popup
        state: netCheck.state
    }
}
