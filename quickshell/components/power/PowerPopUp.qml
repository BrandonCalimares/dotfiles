import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick.Layouts
import "../.."

PanelWindow {
    id: popup
    property bool expanded: false
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
        implicitWidth: column.implicitWidth + Theme.popupPadding * 2
        implicitHeight: column.implicitHeight + Theme.popupPadding * 2
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

        ColumnLayout {
            id: column
            anchors.centerIn: parent
            spacing: Theme.popupSpacing

            UserInfo {
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.popupInnerSpacing

                UsageStat {
                    statType: "cpu"
                    timer: updateTimer
                    Layout.fillWidth: true
                }

                UsageStat {
                    statType: "ram"
                    timer: updateTimer
                    Layout.fillWidth: true
                }

                Timer {
                    id: updateTimer
                    interval: 1000
                    running: true
                    repeat: true
                }
            }

            RowLayout {
                spacing: Theme.popupInnerSpacing

                PowerButton {
                    btnText: "󰐥"
                    process: shutdown
                    btnColor: Theme.red
                    Layout.fillWidth: true
                }

                PowerButton {
                    btnText: "󰜉"
                    process: restart
                    btnColor: Theme.yellow
                    Layout.fillWidth: true
                }

                PowerButton {
                    btnText: "󰤄"
                    process: sleep
                    btnColor: Theme.mauve
                    Layout.fillWidth: true
                }

                PowerButton {
                    btnText: "󰍃"
                    process: logoff
                    btnColor: Theme.blue
                    Layout.fillWidth: true
                }
            }
        }
    }

    Process {
        id: shutdown
        command: ["hyprshutdown", "--post-cmd", "shutdown -P 0"]
    }

    Process {
        id: restart
        command: ["hyprshutdown", "--post-cmd", "reboot"]
    }

    Process {
        id: sleep
        command: ["hyprshutdown", "--post-cmd", "systemctl suspend"]
    }

    Process {
        id: logoff
        command: ["hyprshutdown", "--post-cmd", "hyprctl dispatch 'hl.dsp.exit()'"]
    }
}
