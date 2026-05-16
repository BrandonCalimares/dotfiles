import QtQuick
import Quickshell.Io
import Quickshell.Widgets
import QtQuick.Layouts
import "../.."

Rectangle {
    id: content
    Layout.fillWidth: true
    implicitHeight: userInfo.implicitHeight + Theme.popupPadding * 2
    color: Theme.surface0
    border.color: Theme.surface1
    border.width: Theme.borderWidth
    radius: Theme.innerRadius

    RowLayout {
        id: userInfo
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Theme.popupPadding
        anchors.rightMargin: Theme.popupPadding
        spacing: Theme.popupSpacing

        property string username: "User"
        property string distroName: "Unknown"

        ClippingWrapperRectangle {
            radius: Theme.innerRadius
            Image {
                sourceSize.width: Theme.pfpSize
                sourceSize.height: Theme.pfpSize
                fillMode: Image.PreserveAspectFit
                smooth: true
                source: "/home/brandonc/Pictures/pfp"
            }
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignTop

            // Username
            Process {
                id: whoamiProc
                command: ["whoami"]
                running: true
                stdout: StdioCollector {
                    onStreamFinished: {
                        let raw = this.text.trim();
                        userInfo.username = raw.charAt(0).toUpperCase() + raw.slice(1);
                    }
                }
            }

            Text {
                text: userInfo.username
                font: Theme.bigFont
                color: Theme.text
            }

            // Distro name
            Process {
                command: ["bash", "-c", "grep '^PRETTY_NAME' /etc/os-release | cut -d'=' -f2 | tr -d '\"'"]
                running: true
                stdout: StdioCollector {
                    onStreamFinished: userInfo.distroName = this.text.trim()
                }
            }

            Text {
                text: userInfo.distroName
                font: Theme.smallFont
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
}
