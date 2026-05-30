import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Io
import "../../themes"

PanelWindow {
    id: root
    property bool expanded: false
    property bool opened: expanded || content.height > 0
    required property var layouts
    required property int active
    property var selectedColor: Qt.alpha(Theme.lavender, 0.85)

    visible: opened
    anchors.bottom: true
    exclusiveZone: 0
    margins.bottom: Theme.outerMargin * 3
    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight
    color: "transparent"

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onEntered: closeTimer.stop()
        onExited: closeTimer.start()
    }

    Timer {
        id: closeTimer
        interval: 2000
        running: true
        repeat: false
        onTriggered: {
            root.expanded = false;
        }
    }

    onActiveChanged: {
        if (!mouseArea.containsMouse) {
            closeTimer.restart();
        }
    }

    Rectangle {
        id: content
        anchors.bottom: parent.bottom
        implicitWidth: row.implicitWidth + Theme.popupPadding * 2
        implicitHeight: row.implicitHeight + Theme.popupPadding * 2
        height: root.expanded ? implicitHeight : 0
        color: Theme.background
        radius: Theme.outerRadius
        border.color: Theme.surface0
        border.width: Theme.borderWidth
        clip: true

        Behavior on height {
            NumberAnimation {
                duration: Theme.popupDuration
                easing.type: Easing.InOutQuad
            }
        }

        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: Theme.popupInnerSpacing

            Repeater {
                model: root.layouts
                Rectangle {
                    color: index === root.active ? root.selectedColor : Theme.surface0
                    Layout.fillWidth: true
                    implicitHeight: 90
                    implicitWidth: 120
                    radius: Theme.innerRadius
                    border.width: index === root.active ? 0 : Theme.borderWidth
                    border.color: Theme.surface1

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.colorDuration
                            easing.type: Easing.InOutQuad
                        }
                    }

                    ColumnLayout {
                        id: column
                        spacing: Theme.popupInnerSpacing
                        anchors.fill: parent
                        anchors.margins: Theme.popupPadding

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.slice(0, 2).toUpperCase()
                            font: Theme.xlFont
                            color: index === root.active ? Theme.base : Theme.lavender

                            Behavior on color {
                                ColorAnimation {
                                    duration: Theme.colorDuration
                                    easing.type: Easing.InOutQuad
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: layoutName.text
                            font: Theme.sFont
                            color: index === root.active ? Theme.base : Theme.subtext0
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter

                            Behavior on color {
                                ColorAnimation {
                                    duration: Theme.colorDuration
                                    easing.type: Easing.InOutQuad
                                }
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: index !== root.active
                        cursorShape: index === root.active ? Qt.ArrowCursor : Qt.PointingHandCursor
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

                        property string text: ""

                        stdout: SplitParser {
                            onRead: data => {
                                layoutName.text = data.trim();
                            }
                        }
                    }
                }
            }
        }
    }
}
