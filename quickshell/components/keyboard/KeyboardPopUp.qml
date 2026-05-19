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
    required property var layouts
    required property int active
    property var selectedColor: Qt.alpha(Theme.lavender, 0.85)

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
            spacing: Theme.popupInnerSpacing

            Repeater {
                model: popup.layouts
                Rectangle {
                    color: index === popup.active ? popup.selectedColor : Theme.surface0
                    Layout.fillWidth: true
                    implicitHeight: row.implicitHeight + Theme.popupPadding * 2
                    implicitWidth: row.implicitWidth + Theme.popupPadding * 2
                    radius: Theme.innerRadius
                    border.width: index === popup.active ? 0 : Theme.borderWidth
                    border.color: Theme.surface1

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.colorDuration
                            easing.type: Easing.InOutQuad
                        }
                    }

                    RowLayout {
                        id: row
                        spacing: Theme.popupSpacing 
                        anchors.verticalCenter: parent.verticalCenter
                        x: Theme.popupPadding 

                        Rectangle {
                            implicitHeight: kbText.implicitHeight + Theme.popupPadding * 2
                            implicitWidth: implicitHeight
                            color: index === popup.active ? Theme.lavender : Theme.surface1
                            radius: Theme.innerRadius

                            Text {
                                id: kbText
                                text: modelData.slice(0, 2).toUpperCase()
                                font: Theme.barFont
                                color: index === popup.active ? Theme.base : Theme.lavender
                                anchors.centerIn: parent
                                
                                Behavior on color {
                                    ColorAnimation {
                                        duration: Theme.colorDuration
                                        easing.type: Easing.InOutQuad
                                    }
                                }
                            }
                            
                            Behavior on color {
                                ColorAnimation {
                                    duration: Theme.colorDuration
                                    easing.type: Easing.InOutQuad
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillHeight: true
                            Text {
                                text: layoutName.outside
                                font: Theme.barFont
                                color: index === popup.active ? Theme.base : Theme.text
                                Layout.alignment: Qt.AlignVCenter

                                Behavior on color {
                                    ColorAnimation {
                                        duration: Theme.colorDuration
                                        easing.type: Easing.InOutQuad
                                    }
                                }
                            }

                            Text {
                                text: layoutName.inParens
                                font: Theme.sFont
                                color: index === popup.active ? Theme.surface1 : Theme.subtext0
                                visible: layoutName.inParens.length > 0

                                Behavior on color {
                                    ColorAnimation {
                                        duration: Theme.colorDuration
                                        easing.type: Easing.InOutQuad
                                    }
                                }
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: index !== popup.active
                        cursorShape: index === popup.active ? Qt.ArrowCursor : Qt.PointingHandCursor
                        onClicked: {
                            switchLayout.command = ["hyprctl", "switchxkblayout", "current", index];
                            switchLayout.running = true;
                        }
                    }

                    Process {
                        id: switchLayout
                        running: false
                    }

                    Process {
                        id: layoutName
                        command: ["sh", "-c", `grep -m 1 '^\\s*${modelData}\\s' /usr/share/X11/xkb/rules/base.lst | sed 's/^\\s*${modelData}\\s*//'`]
                        running: true

                        property string outside: ""
                        property string inParens: ""

                        stdout: SplitParser {
                            onRead: data => {
                                const trimmed = data.trim();
                                const match = trimmed.match(/\(([^)]+)\)/);
                                layoutName.inParens = match ? match[1] : "";
                                layoutName.outside = trimmed.replace(/\s*\(.*?\)\s*/g, "").trim();
                            }
                        }
                    }
                }
            }
        }
    }
}
