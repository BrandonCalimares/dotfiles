import Quickshell

import QtQuick
import QtQuick.Layouts
import "themes"
import "bar"

ShellRoot {
    Notifications {}

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root
            property var modelData
            screen: modelData
            anchors.top: true
            anchors.left: true
            anchors.right: true
            margins.top: Theme.outerMargin / 2
            margins.left: Theme.outerMargin
            margins.right: Theme.outerMargin
            color: "transparent"

            implicitHeight: Theme.barHeight + Theme.barPadding * 2

            Rectangle {
                id: bar
                color: Theme.background
                radius: Theme.outerRadius
                anchors.fill: parent

                // Left side of the bar
                RowLayout {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: Theme.barPadding
                    spacing: Theme.barPadding

                    Apps {
                        screen: root.modelData
                    }
                    Workspaces {
                        Layout.leftMargin: 4
                    }
                }

                // Center of the bar
                Music {
                    screen: root.modelData
                    anchors.right: clock.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: Theme.barSpacing
                }
                Clock {
                    id: clock
                    anchors.centerIn: parent
                }

                // Right side of the bar
                RowLayout {
                    id: rightBar
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: Theme.barPadding
                    spacing: Theme.barSpacing

                    Tray {}
                    Keyboard {}
                    Internet {}
                    Volume {}
                    Power {
                        screen: root.modelData
                    }
                }
            }
        }
    }
}
