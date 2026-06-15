import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Io
import QtQml.Models
import QtQuick.Controls
import "themes"

PanelWindow {
    id: root
    property bool expanded: false
    property bool opened: expanded || scaleTransform.yScale > 0

    visible: opened
    exclusiveZone: 0
    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight
    color: "transparent"

    HyprlandFocusGrab {
        id: grab
        windows: [root]
        active: root.expanded
        onCleared: {
            root.expanded = false;
        }
    }

    GlobalShortcut {
        name: "clipboard"
        onPressed: {
            root.expanded = !root.expanded;
        }
    }

    ListModel {
        id: clipModel
    }

    property bool clipboard: true

    Process {
        id: cliphist
        command: ["cliphist", "list"]
        running: false

        stdout: SplitParser {
            onRead: data => {
                const tab = data.indexOf("\t");
                const entry = data.slice(tab + 1);
                const isImage = entry.includes("[[ binary data");
                clipModel.append({
                    fullLine: data,
                    entry: entry,
                    isImage: isImage,
                    imagePath: ""
                });
            }
        }
    }

    Process {
        id: clipRestore
        property string selectedEntry
        command: ["sh", "-c", `cliphist decode <<< '${selectedEntry}' | wl-copy`]
        running: false
    }

    onExpandedChanged: {
        if (expanded) {
            clipModel.clear();
            cliphist.running = false;
            cliphist.running = true;
        }
    }

    Rectangle {
        id: content
        anchors.bottom: parent.bottom
        implicitWidth: column.implicitWidth + Theme.popupPadding * 3
        implicitHeight: column.implicitHeight + Theme.popupPadding * 3
        color: Theme.background
        radius: Theme.outerRadius
        border.color: Theme.surface0
        border.width: Theme.borderWidth

        transform: Scale {
            id: scaleTransform
            origin.x: content.width / 2
            origin.y: content.height / 2
            xScale: root.expanded ? 1 : 0.85
            yScale: root.expanded ? 1 : 0

            Behavior on yScale {
                NumberAnimation {
                    duration: Theme.popupDuration
                    easing.type: Easing.InOutQuad
                }
            }
            Behavior on xScale {
                NumberAnimation {
                    duration: Theme.popupDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }
        opacity: root.expanded ? 1 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: Theme.popupDuration
                easing.type: Easing.InOutQuad
            }
        }

        ColumnLayout {
            id: column
            anchors.centerIn: parent
            spacing: Theme.popupInnerSpacing

            RowLayout {
                Rectangle {
                    implicitWidth: Theme.barWidth
                    implicitHeight: Theme.barHeight
                    radius: Theme.innerRadius
                    color: root.clipboard ? Theme.surface1 : Theme.surface0
                    border.color: Theme.surface1
                    border.width: Theme.borderWidth
                    Text {
                        text: "󰅍"
                        font: Theme.barFont
                        color: Theme.text
                        anchors.centerIn: parent
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (!root.clipboard) {
                                root.clipboard = true;
                                clipModel.clear();
                                cliphist.running = false;
                                cliphist.running = true;
                            }
                        }
                    }
                }

                Rectangle {
                    implicitWidth: Theme.barWidth
                    implicitHeight: Theme.barHeight
                    radius: Theme.innerRadius
                    color: !root.clipboard ? Theme.surface1 : Theme.surface0
                    border.color: Theme.surface1
                    border.width: Theme.borderWidth
                    Text {
                        text: "󱈕"
                        font: Theme.barFont
                        color: Theme.text
                        anchors.centerIn: parent
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.clipboard) {
                                root.clipboard = false;
                                clipModel.clear();
                            }
                        }
                    }
                }

                TextField {
                    id: input
                    placeholderText: ""
                    visible: !root.clipboard
                    focus: true
                    placeholderTextColor: Theme.overlay1
                    color: Theme.text
                    implicitHeight: Theme.barHeight
                    leftPadding: Theme.barPadding
                    padding: Theme.barPadding
                    font: Theme.sFont
                    Layout.fillWidth: true

                    background: Rectangle {
                        color: Theme.surface0
                        border.color: Theme.surface1
                        border.width: Theme.borderWidth
                        radius: Theme.innerRadius
                    }
                }

                Item {
                    Layout.fillWidth: true
                    visible: root.clipboard
                }

                Process {
                    id: clipClear
                    command: ["cliphist", "wipe"]
                    running: false
                }

                Text {
                    visible: root.clipboard
                    text: "Clear All"
                    font: Theme.sFont
                    color: clearArea.containsMouse ? "white" : Theme.accent
                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.colorDuration
                            easing.type: Easing.InOutQuad
                        }
                    }
                    MouseArea {
                        id: clearArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            clipModel.clear();
                            clipClear.running = true;
                        }
                    }
                }
            }

            // Clipboard
            ListView {
                id: listView
                visible: root.clipboard
                Layout.preferredWidth: 400
                Layout.preferredHeight: 300
                clip: true
                model: clipModel
                spacing: Theme.barSpacing

                delegate: Rectangle {
                    required property string fullLine
                    required property string entry
                    required property bool isImage
                    required property string imagePath
                    required property int index

                    width: listView.width
                    implicitHeight: isImage ? 80 : textItem.implicitHeight + Theme.barPadding * 2
                    color: mouseArea.containsMouse ? Theme.surface0 : Theme.base
                    radius: Theme.innerRadius
                    border.color: Theme.surface0
                    border.width: Theme.borderWidth

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.colorDuration
                            easing.type: Easing.InOutQuad
                        }
                    }

                    Process {
                        id: decodeProcess
                        command: ["sh", "-c", `cliphist decode <<< '${fullLine}' > /tmp/clip_${index}.png`]
                        running: isImage && imagePath === ""

                        onRunningChanged: {
                            if (!running && isImage) {
                                clipModel.setProperty(index, "imagePath", `/tmp/clip_${index}.png`);
                            }
                        }
                    }

                    Image {
                        visible: isImage
                        anchors.fill: parent
                        anchors.margins: Theme.barPadding
                        source: imagePath !== "" ? `file://${imagePath}` : ""
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                    }

                    Text {
                        id: textItem
                        visible: !isImage
                        width: parent.width - Theme.barPadding * 2
                        anchors.centerIn: parent
                        text: entry
                        elide: Text.ElideRight
                        font: Theme.mFont
                        color: mouseArea.containsMouse ? Theme.text : Theme.subtext0

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.colorDuration
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            clipRestore.selectedEntry = fullLine;
                            clipRestore.running = true;
                            root.expanded = false;
                        }
                    }
                }

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }
            }

            property list<var> emojis: []

            FileView {
                path: Qt.resolvedUrl("./assets/emojis.json")
                onTextChanged: {
                    column.emojis = JSON.parse(text()).emojis;
                }
            }

            property var filteredEmojis: emojis.filter(emoji => emoji.name.toLowerCase().includes(input.text.toLowerCase()))

            GridView {
                id: gridView
                visible: !root.clipboard
                Layout.preferredWidth: 400
                Layout.preferredHeight: 300
                clip: true
                model: column.filteredEmojis
                cellWidth: 40
                cellHeight: 40

                delegate: Text {
                    text: modelData.emoji
                    width: gridView.cellWidth
                    height: gridView.cellHeight
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.family: "Noto Color Emoji"
                    font.pixelSize: hoverArea.containsMouse ? 30 : 24

                    Behavior on font.pixelSize {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.OutQuad
                        }
                    }

                    Process {
                        id: emojiCopy
                        command: ["sh", "-c", "wl-copy '" + modelData.emoji + "'&& sleep 1 && cliphist delete-query '" + modelData.emoji + "'"]
                        running: false
                    }

                    MouseArea {
                        id: hoverArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            emojiCopy.running = true;
                            root.expanded = false;
                        }
                    }
                }

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }
            }
        }
    }
}
