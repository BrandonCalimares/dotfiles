import QtQuick
import Quickshell
import Quickshell.Hyprland
import QtQuick.Layouts
import "../.."

Rectangle {
    id: root
    required property var date
                    color: Theme.surface0
                    radius: Theme.innerRadius
                    border.width: Theme.borderWidth
                    border.color: Theme.surface1
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: Theme.popupSpacing

                        Text {
                            text: Qt.formatDateTime(root.date, "hh\nmm")
                            color: Theme.text
                            font: Theme.xxlFont
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Text {
                            text: Qt.formatDateTime(root.date, "dddd, dd")
                            color: Theme.text
                            font: Theme.barFont
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }