import QtQuick
import Quickshell
import Quickshell.Hyprland
import QtQuick.Layouts
import Quickshell.Io
import "../.."

PanelWindow {
    id: popup
    property bool expanded: false
    required property string state
    property bool opened: expanded || content.height > 0

    visible: opened

    anchors.top: true
    anchors.right: true
    aboveWindows: true
    margins.top: Theme.outerMargin / 2
    margins.right: Theme.outerMargin
    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight
    color: "transparent"

    HyprlandFocusGrab {
        id: grab
        windows: [popup]
        active: popup.expanded
        onCleared: popup.expanded = false
    }

    Rectangle {
        id: content
        implicitWidth: container.implicitWidth + Theme.popupPadding * 2
        implicitHeight: container.implicitHeight + Theme.popupPadding * 2
        height: popup.expanded ? implicitHeight : 0
        color: Theme.background
        radius: Theme.outerRadius
        clip: true

        Behavior on height {
            NumberAnimation {
                duration: Theme.popupDuration
                easing.type: Easing.InOutQuad
            }
        }

        Rectangle {
            id: container
            implicitWidth: row.implicitWidth + Theme.popupPadding * 2
            implicitHeight: row.implicitHeight + Theme.popupPadding * 2
            radius: Theme.innerRadius
            color: Theme.surface0
            anchors.centerIn: parent
            border.width: Theme.borderWidth
            border.color: Theme.surface1

            RowLayout {
                id: row
                anchors.centerIn: parent
                spacing: Theme.popupSpacing

                RowLayout {
                    spacing: Theme.popupInnerSpacing
                    Text {
                        text: popup.state === "up" ? "󰍹" : "󰶐"
                        font: Theme.bigFont
                        color: popup.state === "up" ? Theme.mauve : Theme.red
                    }
    
                    Text {
                        text: popup.state === "up" ? "Connected" : "No Internet"
                        font: Theme.bigFont
                        color: Theme.text
                    }
                }
                
                Text {
                    visible: popup.state === "up"
                    text: ipProc.ip
                    color: Theme.subtext0
                    font: Theme.smallFont
                }

                Process {
                    id: ipProc
                    property string ip: ""
                    command: ["sh", "-c", "ip -4 addr show | grep -oP '(?<=inet )\\d+\\.\\d+\\.\\d+\\.\\d+' | grep -v 127.0.0.1 | head -1"]
                    running: true

                    stdout: SplitParser {
                        onRead: data => ipProc.ip = data.trim()
                    }
                }
            }
        }
    }
}
