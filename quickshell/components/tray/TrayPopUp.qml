import QtQuick
import Quickshell
import Quickshell.Hyprland
import QtQuick.Layouts
import "../.."

PanelWindow {
    id: root
    property bool expanded: false
    required property var trayItem
    property var parentMenu: null
    property bool opened: (expanded || content.height > 0) && opener.children.values.length > 0

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
        windows: [root]
        active: root.expanded
        onCleared: root.expanded = false
    }

    QsMenuOpener {
        id: opener
        menu: root.trayItem.menu
    }

    onOpenedChanged: {
        if (!opened && parentMenu != null) {
            opener.menu = root.parentMenu;
            root.parentMenu = null;
        }
    }

    Rectangle {
        id: content
        implicitWidth: container.implicitWidth + Theme.popupPadding * 2
        implicitHeight: container.implicitHeight + Theme.popupPadding * 2
        height: root.expanded ? implicitHeight : 0
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
            implicitWidth: column.implicitWidth + Theme.popupPadding * 2
            implicitHeight: column.implicitHeight + Theme.popupPadding * 2
            radius: Theme.innerRadius
            color: Theme.surface0
            anchors.centerIn: parent
            border.width: Theme.borderWidth
            border.color: Theme.surface1

            ColumnLayout {
                id: column
                anchors.centerIn: parent
                spacing: Theme.popupSpacing

                Repeater {
                    model: opener.children

                    Item {
                        Layout.fillWidth: true
                        implicitHeight: modelData.isSeparator ? separator.implicitHeight : item.implicitHeight
                        implicitWidth: row.implicitWidth

                        RowLayout {
                            id: row
                            spacing: Theme.popupInnerSpacing
                            anchors.fill: parent

                            Image {
                                id: icon
                                source: modelData.icon
                                Layout.preferredHeight: 16
                                Layout.preferredWidth: 16
                                visible: modelData.icon !== ""
                                sourceSize.width: width
                                sourceSize.height: width
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                            }

                            Text {
                                id: item
                                visible: !modelData.isSeparator
                                text: modelData.text
                                color: modelData.enabled ? (mouseArea.containsMouse ? "white" : Theme.text) : Theme.subtext0
                                font: Theme.smallFont

                                Behavior on color {
                                    ColorAnimation {
                                        duration: Theme.colorDuration
                                        easing.type: Easing.InOutQuad
                                    }
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Text {
                                visible: modelData.hasChildren
                                text: ""
                                color: modelData.enabled ? (mouseArea.containsMouse ? "white" : Theme.text) : Theme.subtext0
                                font: Theme.smallFont
                                Behavior on color {
                                    ColorAnimation {
                                        duration: Theme.colorDuration
                                        easing.type: Easing.InOutQuad
                                    }
                                }
                            }
                        }

                        Rectangle {
                            id: separator
                            visible: modelData.isSeparator
                            height: Theme.borderWidth
                            width: parent.width
                            color: Theme.surface1
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            enabled: modelData.enabled
                            cursorShape: modelData.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                modelData.triggered();
                                if (modelData.hasChildren) {
                                    root.parentMenu = opener.menu;
                                    opener.menu = modelData;
                                } else
                                    root.expanded = false;
                            }

                            hoverEnabled: true
                        }
                    }
                }
                
                Rectangle {
                    visible: root.parentMenu!= null
                    color: backArea.containsMouse ? Theme.text : Theme.surface1
                    implicitHeight: back.implicitHeight + Theme.barPadding * 2
                    implicitWidth: back.implicitWidth + Theme.barPadding * 2
                    radius: Theme.innerRadius
                    border.width: backArea.containsMouse ? 0 : Theme.borderWidth
                    border.color: Theme.surface2

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.colorDuration
                            easing.type: Easing.InOutQuad
                        }
                    }

                    Text {
                        id: back
                        anchors.centerIn: parent
                        text: " Back"
                        color: backArea.containsMouse ? Theme.surface0 : Theme.text
                        font: Theme.mediumFont

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.colorDuration
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }

                    MouseArea {
                        id: backArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            opener.menu = root.parentMenu;
                            root.parentMenu = null;
                        }
                    }
                }
            }
        }
    }
}
