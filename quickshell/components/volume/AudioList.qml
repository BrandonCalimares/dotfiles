import QtQuick
import Quickshell.Services.Pipewire
import QtQuick.Layouts
import "../.."

Rectangle {
    id: root
    color: Qt.alpha(Theme.surface0, 0.7)
    implicitWidth: audioSection.implicitWidth
    implicitHeight: column.implicitHeight + Theme.popupPadding * 2
    height: expanded ? implicitHeight : 0
    border.width: Theme.borderWidth
    border.color: Theme.surface1
    radius: Theme.innerRadius
    clip: true

    x: rootColumn.x + audioSection.x
    y: rootColumn.y + audioSection.y + audioSection.height + Theme.popupInnerSpacing / 2

    required property var audioSection
    required property string type
    required property var rootColumn

    PwNodeLinkTracker {
        id: audioTracker
        node: root.type === "sink" ? Pipewire.defaultAudioSink : Pipewire.defaultAudioSource
    }

    PwObjectTracker {
        id: audioSourceTracker
        objects: [audioTracker.node]
    }

    property var audio: audioTracker.node.audio
    property bool expanded: false

    Behavior on height {
        NumberAnimation {
            duration: Theme.popupDuration
            easing.type: Easing.InOutQuad
        }
    }

    ColumnLayout {
        id: column
        spacing: Theme.popupInnerSpacing
        anchors.centerIn: parent

        Repeater {
            model: Pipewire.nodes.values.filter(node => node.isSink === (root.type === "sink") && node.nickname != "" && node.isStream === false)

            Rectangle {
                color: modelData.id == audioTracker.node.id ? Theme.blue : (mouseArea.containsMouse ? Theme.surface2 : Theme.surface1)
                radius: Theme.innerRadius
                border.width: modelData.id == audioTracker.node.id ? 0 : Theme.borderWidth
                border.color: Theme.surface2
                implicitWidth: root.implicitWidth - Theme.popupPadding * 2
                implicitHeight: text.implicitHeight + Theme.popupPadding * 2
                Text {
                    id: text
                    text: modelData.nickname
                    color: modelData.id == audioTracker.node.id ? Theme.base : Theme.text
                    font: Theme.barFont
                    anchors.centerIn: parent
                    width: parent.implicitWidth - Theme.popupPadding * 2
                    elide: Text.ElideRight
                }

                PwObjectTracker {
                    objects: [modelData]
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    enabled: modelData.id != audioTracker.node.id
                    cursorShape: modelData.id == audioTracker.node.id ? Qt.ArrowCursor : Qt.PointingHandCursor
                    onClicked: {
                        if (root.type === "sink")
                            Pipewire.preferredDefaultAudioSink = modelData;
                        else
                            Pipewire.preferredDefaultAudioSource = modelData;
                        root.expanded = false;
                    }
                    hoverEnabled: true
                }
            }
        }
    }
}
