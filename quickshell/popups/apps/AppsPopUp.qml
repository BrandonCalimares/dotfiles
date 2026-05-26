import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import QtQuick.Layouts
import QtQuick.Controls
import "../../themes"

PanelWindow {
    id: popup
    property bool expanded: false
    property bool opened: expanded || content.height > 0
    property int numApps: 8
    property int selectedIndex: 0

    visible: opened

    anchors.top: true
    anchors.left: true
    aboveWindows: true
    margins.top: Theme.outerMargin / 2
    margins.left: Theme.outerMargin
    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight
    color: "transparent"

    onOpenedChanged: {
        if (!opened) {
            input.text = "";
            popup.selectedIndex = 0;
        }
    }

    HyprlandFocusGrab {
        id: grab
        windows: [popup]
        active: popup.expanded
        onCleared: popup.expanded = false
    }

    Rectangle {
        id: content
        implicitWidth: Theme.appWidth + Theme.popupPadding * 2
        implicitHeight: (appSize.implicitHeight + 5) * popup.numApps + input.implicitHeight + Theme.popupInnerSpacing + Theme.popupPadding * 2
        height: popup.expanded ? container.implicitHeight + Theme.popupPadding * 2 : 0
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
            id: appSize
            implicitHeight: rowSize.implicitHeight + Theme.popupPadding * 2
            visible: false

            RowLayout {
                id: rowSize

                Rectangle {
                    implicitHeight: 24 + Theme.popupPadding
                }

                Text {
                    text: "text"
                    font: Theme.mFont
                }
            }
        }

        ColumnLayout {
            id: container
            spacing: Theme.popupInnerSpacing
            width: Theme.appWidth
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: Theme.popupPadding

            Item {
                Layout.fillWidth: true
                implicitHeight: input.implicitHeight

                TextField {
                    id: input
                    placeholderText: "Enter app..."
                    focus: true
                    anchors.fill: parent
                    placeholderTextColor: Theme.overlay1
                    color: Theme.text
                    leftPadding: Theme.popupPadding * 2 + inputIcon.width
                    padding: Theme.popupPadding
                    font: Theme.mFont

                    background: Rectangle {
                        color: Theme.surface0
                        border.color: Theme.sapphire
                        border.width: Theme.borderWidth
                        radius: Theme.innerRadius
                    }

                    Keys.onReturnPressed: {
                        container.filteredApps[popup.selectedIndex].execute();
                        popup.expanded = false;
                        event.accepted = true
                    }

                    Keys.onUpPressed: {
                        popup.selectedIndex = Math.max(0, popup.selectedIndex - 1)
                        event.accepted = true
                    }

                    Keys.onDownPressed: {
                        popup.selectedIndex = Math.min(container.filteredApps.length - 1, popup.selectedIndex + 1)
                        event.accepted = true
                    }

                }

                Text {
                    id: inputIcon
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.popupPadding
                    anchors.verticalCenter: parent.verticalCenter
                    text: ""
                    font: Theme.lFont
                    color: Theme.sapphire
                }
            }

            property var filteredApps: DesktopEntries.applications.values.filter(app => app.name.toLowerCase().includes(input.text.toLowerCase())).slice(0, popup.numApps)

            onFilteredAppsChanged: {
                popup.selectedIndex = 0;
            }

            ColumnLayout {
                id: column
                spacing: 5

                Repeater {
                    model: container.filteredApps
                    Rectangle {
                        property bool selected: (index == popup.selectedIndex) || mouseArea.containsMouse

                        Layout.fillWidth: true
                        Layout.preferredWidth: Theme.appWidth
                        implicitHeight: row.implicitHeight + Theme.popupPadding * 2
                        color: selected ? Theme.surface1 : Theme.surface0
                        radius: Theme.innerRadius
                        border.color: Theme.surface1
                        border.width: Theme.borderWidth
                        clip: true

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                modelData.execute();
                                popup.expanded = false;
                            }
                            hoverEnabled: true
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.colorDuration
                                easing.type: Easing.InOutQuad
                            }
                        }

                        RowLayout {
                            id: row
                            anchors.verticalCenter: parent.verticalCenter
                            x: Theme.popupPadding
                            width: parent.width - Theme.popupPadding * 2
                            spacing: Theme.popupSpacing

                            Rectangle {
                                implicitHeight: icon.implicitHeight + Theme.popupPadding
                                implicitWidth: icon.implicitWidth + Theme.popupPadding
                                radius: Theme.innerRadius
                                color: selected ? Theme.surface2 : Theme.surface1

                                Behavior on color {
                                    ColorAnimation {
                                        duration: Theme.colorDuration
                                        easing.type: Easing.InOutQuad
                                    }
                                }

                                IconImage {
                                    id: icon
                                    source: Quickshell.iconPath(modelData.icon, true)
                                    implicitSize: 24
                                    anchors.centerIn: parent
                                }
                            }

                            Text {
                                text: modelData.name
                                font: Theme.mFont
                                color: Theme.text
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Text {
                                text: ""
                                font.family: Theme.sFont.family
                                font.pixelSize: 13
                                font.weight: Font.Bold
                                color: Theme.overlay2
                            }
                        }
                    }
                }
            }
        }
    }
}
