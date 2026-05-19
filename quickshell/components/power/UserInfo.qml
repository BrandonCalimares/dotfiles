import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick.Layouts
import "../.."

RowLayout {
    id: userInfo
    Layout.margins: Theme.popupPadding / 2
    spacing: Theme.popupSpacing

    property string distroName: "Unknown"
    readonly property string avatarSource: Quickshell.env("HOME") + "/Pictures/pfp.png"

    // User avatar
    ClippingWrapperRectangle {
        radius: Theme.innerRadius
        Image {
            sourceSize.width: Theme.pfpSize
            sourceSize.height: Theme.pfpSize
            fillMode: Image.PreserveAspectFit
            smooth: true
            source: userInfo.avatarSource
        }
    }

    ColumnLayout {
        Layout.alignment: Qt.AlignTop

        // Username
        Text {
            text: Quickshell.env("USER")
            font: Theme.xlFont
            color: Theme.text
        }

        // Distro
        Process {
            command: ["bash", "-c", "grep '^PRETTY_NAME' /etc/os-release | cut -d'=' -f2 | tr -d '\"'"]
            running: true
            stdout: StdioCollector {
                onStreamFinished: userInfo.distroName = this.text.trim()
            }
        }

        Text {
            text: "󰣇 " + userInfo.distroName
            font: Theme.sFont
            color: Theme.blue
        }

        // Window Manager
        Text {
            text: "󱂬 " + Quickshell.env("XDG_CURRENT_DESKTOP")
            font: Theme.sFont
            color: Theme.subtext0
        }
    }

    Item {
        Layout.fillWidth: true
    }

    // TODO: make this a button that opens the settings app
    Rectangle {
        Layout.alignment: Qt.AlignTop
        implicitHeight: Theme.barHeight
        implicitWidth: Theme.barHeight
        color: Theme.surface1
        radius: Theme.innerRadius

        Text {
            id: settingsIcon
            text: ""
            font: Theme.barFont
            color: Theme.subtext0
            anchors.centerIn: parent
        }
    }
}
